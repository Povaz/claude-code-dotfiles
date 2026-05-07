#!/usr/bin/env bash
# ~/.claude/statusline.sh
#
# Claude Code status line script.
# Receives a JSON payload via stdin and prints a formatted status line.

input=$(cat)

# --- Colors (ANSI; tuned for dark terminals like PyCharm Darcula / New UI Dark) ---
# Disabled automatically if stdout isn't a TTY or NO_COLOR is set.
if [ -n "${NO_COLOR:-}" ]; then
    C_RESET=""; C_DIM=""; C_MODEL=""; C_PROJ=""; C_BRANCH=""
    C_LABEL=""; C_COST=""; C_OK=""; C_WARN=""; C_CRIT=""
else
    C_RESET=$'\033[0m'
    C_DIM=$'\033[2;37m'
    C_MODEL=$'\033[1;96m'
    C_PROJ=$'\033[95m'
    C_BRANCH=$'\033[92m'
    C_LABEL=$'\033[90m'
    C_COST=$'\033[93m'
    C_OK=$'\033[32m'
    C_WARN=$'\033[33m'
    C_CRIT=$'\033[1;31m'
fi
SEP="  ${C_DIM}|${C_RESET}  "

threshold_color() {
    # Echo the ANSI color for a 0-100 percentage: OK <50, WARN <80, CRIT ≥80.
    awk -v p="$1" -v ok="$C_OK" -v warn="$C_WARN" -v crit="$C_CRIT" 'BEGIN {
        if (p == "" || p+0 != p) { print ""; exit }
        if (p >= 80) print crit
        else if (p >= 50) print warn
        else print ok
    }'
}

# --- Model ---
model=$(echo "$input" | jq -r '.model.display_name // "Claude"' | sed 's/ context//')

# --- Context window usage (braille dot bar + current/total) ---
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // 0')

fmt_k() {
    awk -v n="$1" 'BEGIN { printf "%.1fK", n / 1000 }'
}

fmt_ctx_size() {
    # Format context window size: 1000000 → "1M", 200000 → "200K"
    awk -v n="$1" 'BEGIN {
        if (n >= 1000000) printf "%.0fM", n / 1000000
        else printf "%.0fK", n / 1000
    }'
}

if [ -n "$used_pct" ]; then
    filled=$(echo "$used_pct" | awk '{printf "%d", int($1 * 15 / 100 + 0.5)}')
    [ "$filled" -lt 0 ] 2>/dev/null && filled=0
    [ "$filled" -gt 15 ] 2>/dev/null && filled=15
    empty=$((15 - filled))
    bar=""
    for i in $(seq 1 "$filled"); do bar="${bar}⣿"; done
    for i in $(seq 1 "$empty");  do bar="${bar}⣀"; done
    ctx_color=$(threshold_color "$used_pct")
    ctx_display="${ctx_color}${bar} $(printf '%.2f' "$used_pct")%${C_RESET}"
else
    ctx_display="${C_DIM}⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀ --.--%${C_RESET}"
fi

# --- Token counts (formatted as K) ---
input_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
output_tokens=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')

in_k=$(fmt_k "$input_tokens")
out_k=$(fmt_k "$output_tokens")

# --- Cache tokens ---
cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
cache_read_k=$(fmt_k "$cache_read")

# --- Session cost (estimated from token counts) ---
model_id=$(echo "$input" | jq -r '.model.id // ""')

if echo "$model_id" | grep -qi "haiku"; then
    cost=$(awk -v i="$input_tokens" -v o="$output_tokens" \
        'BEGIN { printf "%.2f", (i * 0.80 + o * 4.00) / 1000000 }')
elif echo "$model_id" | grep -qi "opus"; then
    cost=$(awk -v i="$input_tokens" -v o="$output_tokens" \
        'BEGIN { printf "%.2f", (i * 15.00 + o * 75.00) / 1000000 }')
else
    cost=$(awk -v i="$input_tokens" -v o="$output_tokens" \
        'BEGIN { printf "%.2f", (i * 3.00 + o * 15.00) / 1000000 }')
fi

# --- Rate limits (Team/Pro/Max only) ---
rl_5h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
rl_7d=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

rate_display=""
if [ -n "$rl_5h" ] || [ -n "$rl_7d" ]; then
    if [ -n "$rl_5h" ]; then
        rl_5h_fmt="$(threshold_color "$rl_5h")$(printf '%.0f%%' "$rl_5h")${C_RESET}"
    else
        rl_5h_fmt="${C_DIM}--%${C_RESET}"
    fi
    if [ -n "$rl_7d" ]; then
        rl_7d_fmt="$(threshold_color "$rl_7d")$(printf '%.0f%%' "$rl_7d")${C_RESET}"
    else
        rl_7d_fmt="${C_DIM}--%${C_RESET}"
    fi
    rate_display="${SEP}${C_LABEL}5h${C_RESET} ${rl_5h_fmt} ${C_LABEL}7d${C_RESET} ${rl_7d_fmt}"
fi

# --- Project + git branch ---
proj_dir=$(echo "$input" | jq -r '.workspace.project_dir // .workspace.current_dir // ""')
proj_display=""
if [ -n "$proj_dir" ]; then
    proj_name=$(basename "$proj_dir")
    branch=$(git -C "$proj_dir" rev-parse --abbrev-ref HEAD 2>/dev/null || true)
    if [ -n "$branch" ]; then
        proj_display="${SEP}${C_PROJ}${proj_name}${C_RESET} ${C_DIM}@${C_RESET} ${C_BRANCH}${branch}${C_RESET}"
    else
        proj_display="${SEP}${C_PROJ}${proj_name}${C_RESET}"
    fi
fi

# --- Assemble ---
printf "%s%s%s%s%s%s${C_LABEL}in${C_RESET} %s  ${C_LABEL}out${C_RESET} %s  ${C_LABEL}cache${C_RESET} %s%s${C_COST}\$%s${C_RESET}" \
    "${C_MODEL}${model}${C_RESET}" "$SEP" \
    "$ctx_display" "$rate_display" "$proj_display" "$SEP" \
    "$in_k" "$out_k" "$cache_read_k" "$SEP" \
    "$cost"
