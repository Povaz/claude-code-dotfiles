#!/usr/bin/env bash
# ~/.claude/statusline.sh
#
# Claude Code status line script.
# Receives a JSON payload via stdin and prints a formatted status line.

input=$(cat)

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
    ctx_display="${bar} $(printf '%.2f' "$used_pct")%"
else
    ctx_display="⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀ --.--%"
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
    rl_5h_fmt=$([ -n "$rl_5h" ] && printf '%.0f%%' "$rl_5h" || echo "--%")
    rl_7d_fmt=$([ -n "$rl_7d" ] && printf '%.0f%%' "$rl_7d" || echo "--%")
    rate_display="  |  5h ${rl_5h_fmt} 7d ${rl_7d_fmt}"
fi

# --- Assemble ---
printf "%s  |  %s%s  |  in %s  out %s  cache %s  |  \$%s" \
    "$model" "$ctx_display" "$rate_display" "$in_k" "$out_k" "$cache_read_k" \
    "$cost"
