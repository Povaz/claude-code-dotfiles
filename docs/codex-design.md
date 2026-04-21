# Dual Claude Code and Codex Dotfiles Design

This repository should remain a single source of truth for both Claude Code and
Codex. The goal is to set up the repository once, then propagate compatible
configuration to both tools while keeping tool-specific features isolated.

The existing repository already has the right operating model: keep managed
configuration in the repo, symlink it into the tool's home directory, and avoid
copying machine-local credentials or runtime state. The main design change is to
move from one projection (`dotclaude/` -> `~/.claude/`) to two projections:

- `dotclaude/` -> `~/.claude/`
- `dotcodex/` -> `~/.codex/`

Shared content should live once and be projected into both formats where
possible. Tool-specific content should remain under the matching tool directory.

## Design Principles

1. **One repository, two tool homes.**
   Keep a single Git repository, but install into both `~/.claude/` and
   `~/.codex/`.

2. **Shared source, tool-specific projection.**
   Store reusable concepts once when the file format and semantics are close
   enough. Project them into Claude Code or Codex files when their formats
   differ.

3. **No lowest-common-denominator design.**
   If a feature exists only in Claude Code, keep it Claude-only. If a feature
   exists only in Codex, keep it Codex-only.

4. **No silent lossy conversion.**
   If two tools support similar concepts but with incompatible metadata, keep a
   shared canonical body plus explicit tool-specific wrappers.

5. **Credentials and machine-local state stay out.**
   Continue excluding credentials, sessions, telemetry, cache, project state,
   and other local files from sync.

## Recommended Repository Shape

```text
ai-code-dotfiles/
├── setup.sh
├── teardown.sh
├── status.sh
├── README.md
├── CLAUDE.md
├── AGENTS.md
├── shared/
│   ├── instructions/
│   │   └── global.md
│   ├── agents/
│   │   └── code-reviewer.md
│   └── skills/
│       └── user-stories/
│           └── SKILL.md
├── dotclaude/
│   ├── CLAUDE.md
│   ├── settings.managed.json
│   ├── statusline.sh
│   ├── commands/
│   ├── agents/
│   │   └── code-reviewer.md
│   └── skills/
│       └── user-stories/
│           └── SKILL.md
└── dotcodex/
    ├── AGENTS.md
    ├── agents/
    │   └── code-reviewer.toml
    └── skills/
        └── user-stories/
            └── SKILL.md
```

`shared/` is the canonical authoring area for content that should exist in both
tools. `dotclaude/` and `dotcodex/` are install manifests for symlinked files,
with one exception: `dotclaude/settings.managed.json` is a managed patch applied
to the local `~/.claude/settings.json`, not a symlink target.

The root `CLAUDE.md` and `AGENTS.md` are project-level instructions for working
on this dotfiles repository itself. They are not the same as the global
installed instructions under `dotclaude/CLAUDE.md` and `dotcodex/AGENTS.md`.

## Projection Model

| Shared concept | Claude Code projection | Codex projection | Propagation rule |
|---|---|---|---|
| Global AI working instructions | `dotclaude/CLAUDE.md` | `dotcodex/AGENTS.md` | Shared body can be reused, but filename and instruction-discovery semantics differ. |
| User stories skill | `dotclaude/skills/user-stories/SKILL.md` | `dotcodex/skills/user-stories/SKILL.md` | Direct propagation is reasonable because both use a `SKILL.md` with `name` and `description`. |
| Code reviewer agent body | `dotclaude/agents/code-reviewer.md` | `dotcodex/agents/code-reviewer.toml` | Share the instruction body, but keep separate wrappers because Claude uses Markdown frontmatter and Codex uses TOML fields. |
| Claude status line | `dotclaude/statusline.sh` plus a managed `statusLine` patch in `~/.claude/settings.json` | No direct equivalent | Claude-only. Symlink the script, but patch the local settings file instead of symlinking the whole file. |
| Claude custom slash commands | `dotclaude/commands/` | No documented equivalent | Claude-only. Codex currently documents built-in slash commands, not a user command directory. |
| Codex custom agents | No exact extra beyond Claude agents | `dotcodex/agents/*.toml` | Codex-specific metadata belongs in TOML; shared behavior can come from `shared/agents/`. |

## Feature Mapping

| Current Claude Code feature | Codex equivalent | Single-repo decision |
|---|---|---|
| `dotclaude/` symlinked into `~/.claude/` | `dotcodex/` symlinked into `~/.codex/` | Keep both install manifests in the same repo and update scripts to manage both. |
| `dotclaude/CLAUDE.md` | `dotcodex/AGENTS.md` | Put common guidance in `shared/instructions/global.md`; project it into both tool filenames. |
| `statusLine.command` in `~/.claude/settings.json` | No direct equivalent | Manage only this Claude settings fragment by patching the local settings file. Do not symlink or sync the whole settings file. |
| `dotclaude/agents/code-reviewer.md` | `dotcodex/agents/code-reviewer.toml` | Store the reviewer instructions once in `shared/agents/code-reviewer.md`; wrap them per tool. |
| Claude agent `model: inherit` | Omit Codex model fields | Preserve inheritance intent using each tool's native mechanism. |
| Claude agent `color: red` | No documented Codex color field | Claude-only. Optional Codex `nickname_candidates` can be added separately if useful. |
| `dotclaude/skills/user-stories/SKILL.md` | `dotcodex/skills/user-stories/SKILL.md` | Share directly. The current file is already close to Codex's skill format. |
| `dotclaude/commands/` | No documented custom Codex command directory | Claude-only. |

## Setup Script Design

The current `setup.sh` should become a dual installer.

Recommended behavior:

1. Print both target directories:
   - Claude Code: `~/.claude`
   - Codex: `~/.codex`
2. Ask for one confirmation before touching either target.
3. For each enabled projection, discover every top-level entry under its
   manifest directory, excluding managed patch files:
   - `dotclaude/*`
   - `dotcodex/*`
4. Back up conflicting symlink targets into tool-specific backup directories:
   - `~/.claude/backups/<timestamp>/`
   - `~/.codex/backups/<timestamp>/`
5. Create symlinks:
   - `~/.claude/<item>` -> `<repo>/dotclaude/<item>`
   - `~/.codex/<item>` -> `<repo>/dotcodex/<item>`
6. Apply the managed Claude settings patch for the status line:
   - preserve the existing local `~/.claude/settings.json`
   - update only the `statusLine` key using `jq` (with a friendly warning if `jq` is not installed)
   - do not overwrite or sync live/session-local keys
7. Skip links that are already correct.
8. Report a per-tool summary, including whether the managed settings patch is
   already applied.

The script should support flags so users can install one tool or both:

```bash
./setup.sh              # install both Claude Code and Codex projections
./setup.sh --claude     # install only Claude Code
./setup.sh --codex      # install only Codex
```

`teardown.sh` and `status.sh` should mirror this behavior with the same flags.
`status.sh` should iterate through both manifests and clearly print separate blocks (e.g., `[Claude Code System Status]` vs `[Codex System Status]`) so users can independently verify each tool's symlink health without confusion.

## Shared Content Strategy

There are two viable ways to manage shared content.

### Option A: Shared Files with Symlinks

Use symlinks inside the repo when a file can be identical for both tools:

```text
dotclaude/skills/user-stories/SKILL.md -> ../../../shared/skills/user-stories/SKILL.md
dotcodex/skills/user-stories/SKILL.md -> ../../../shared/skills/user-stories/SKILL.md
```

This is simple and works well for skills, because both tools use a compatible
`SKILL.md` shape.

**Note on Option A (The "Double-Symlink" Problem):**
If `setup.sh` symlinks `~/.claude/.../SKILL.md` to `dotclaude/.../SKILL.md` (which is itself a symlink to `../../../shared/...`), it creates a nested symlink chain. This breaks the current `teardown.sh` assumption, which uses standard `readlink` and would mistakenly extract a relative path instead of copying the file content back to the user's home directory.

If Option A is chosen, one of these design choices must be made:
- **Choice A1:** Abandon in-repo symlinks. Use hard links or simply commit identical files between `shared/`, `dotclaude/`, and `dotcodex/`.
- **Choice A2:** Update `teardown.sh` to use `readlink -f` (or equivalent absolute resolution) and ensure it copies the final file *contents* rather than trying to restore a broken symlink.

### Option B: Generate Tool-Specific Wrappers

Use a small generation script when the same content needs different wrappers:

```text
shared/agents/code-reviewer.md
dotclaude/agents/code-reviewer.md
dotcodex/agents/code-reviewer.toml
```

The shared file owns the long instruction body. The Claude file adds YAML
frontmatter. The Codex file adds TOML fields such as `name`, `description`, and
`developer_instructions`.

**Note on Option B (Build Lifecycle):**
To avoid disrupting the simplicity of the current deploy scripts, generation should *not* happen in `setup.sh`. Instead, these wrappers should be pre-generated and committed to Git via a separate script (e.g., `build-agents.sh`) or a pre-commit hook. This keeps `setup.sh` strictly as a local installer.

This is the better pattern for agents because Claude and Codex use different
agent definition formats.

## Tool-Specific Areas

### Claude Code Only

Keep these under `dotclaude/` only:

- `statusline.sh`
- `settings.managed.json`, containing only the managed statusline patch
- `commands/`
- Claude-only agent metadata such as `color`

### Codex Only

Keep these under `dotcodex/` only:

- Codex custom agent TOML files

### Shared or Projected

Keep these in `shared/` and project them:

- General working instructions
- Long reusable agent instruction bodies
- Skills whose `SKILL.md` format works in both tools
- Shared references, scripts, or assets used by skills

## Current Feature Port Notes

### User Stories Skill

The current `dotclaude/skills/user-stories/SKILL.md` is the strongest candidate
for direct sharing. Codex skills also use a directory containing `SKILL.md`,
with required `name` and `description` metadata, plus optional scripts,
references, assets, and `agents/openai.yaml`.

Recommended placement:

```text
shared/skills/user-stories/SKILL.md
dotclaude/skills/user-stories/SKILL.md -> shared/skills/user-stories/SKILL.md
dotcodex/skills/user-stories/SKILL.md -> shared/skills/user-stories/SKILL.md
```

### Code Reviewer Agent

The current Claude agent combines:

- Claude frontmatter: `name`, `description`, `model`, `color`
- The reusable reviewer instruction body

For the dual-tool design:

```text
shared/agents/code-reviewer.md
dotclaude/agents/code-reviewer.md
dotcodex/agents/code-reviewer.toml
```

The Claude wrapper should keep `model: inherit` and `color: red`. The Codex
wrapper should omit model fields to inherit from the parent session. Codex has
no documented color equivalent, so that metadata should not be projected.

### Global Instructions

Claude Code uses `CLAUDE.md`; Codex uses `AGENTS.md`.

Recommended placement:

```text
shared/instructions/global.md
dotclaude/CLAUDE.md
dotcodex/AGENTS.md
```

These can be identical if the guidance is genuinely tool-neutral. If the
instructions mention tool behavior, keep the shared section in
`shared/instructions/global.md` and add short tool-specific notes in the
projected files.

### Settings

Do not symlink or sync whole settings files.

Claude Code mutates `~/.claude/settings.json` while the tool is in use. Some of
those values are live/session-local preferences, so committing and propagating
them is noisy and often meaningless. Codex configuration may also contain local
policy choices that should not be overwritten by this repository.

The only settings behavior this proposal keeps is the Claude status line hook.
Represent that as a managed patch:

```text
dotclaude/settings.managed.json
```

Suggested content:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh"
  }
}
```

`setup.sh` should merge only this key into the local
`~/.claude/settings.json`. It will require `jq` to handle this JSON merge safely (e.g., `jq -s '.[0] * .[1]'`). If `jq` is missing, the script should fail gracefully with a warning rather than corrupting the configuration. It should preserve unrelated local keys such as
reasoning effort, permission prompt state, plugin enablement, model selection,
or any other tool-managed values. `dotcodex/config.toml` should not be part of
the initial synced design.

## Unsupported or Partial Cross-Propagation

Do not propagate these features until the target tool supports an equivalent:

- Claude `statusLine.command` -> Codex: no direct documented arbitrary command
  statusline hook. Keep the managed settings patch Claude-only.
- Claude `commands/` -> Codex: no documented user-defined slash-command
  directory.
- Claude agent `color` -> Codex: no documented custom color field.
- Claude and Codex full settings files: do not sync. They can contain live,
  local, or session-specific values.

## Documentation Sources

Local sources:

- `README.md`: documents the current `dotclaude/` symlink model and synced
  Claude Code files.
- `setup.sh`: implements symlink installation into `~/.claude/`.
- `status.sh`: reports current symlink and backup state.
- `teardown.sh`: removes managed symlinks and leaves standalone local copies.
- `dotclaude/settings.json`: current Claude Code settings, used here as the
  source for identifying the statusline setting that should become a managed
  patch.
- `dotclaude/agents/code-reviewer.md`: current Claude Code custom agent.
- `dotclaude/skills/user-stories/SKILL.md`: current shared-candidate skill.

OpenAI Codex sources:

- Codex config reference:
  <https://developers.openai.com/codex/config-reference>
- Codex `AGENTS.md` custom instructions:
  <https://developers.openai.com/codex/guides/agents-md>
- Codex skills:
  <https://developers.openai.com/codex/skills>
- Codex subagents:
  <https://developers.openai.com/codex/subagents>
- Codex slash commands:
  <https://developers.openai.com/codex/cli/slash-commands>
- Codex plugins:
  <https://developers.openai.com/codex/plugins>
