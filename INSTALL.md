# INSTALL.md

## Requirements

- Bash (POSIX) OR PowerShell 5.1+.
- Write access to your home directory.
- At least one of: Claude Code, Codex, Antigravity, OpenCode installed.

No Node, no Python, no external network calls.

## Quick start

### POSIX (macOS / Linux / WSL / git-bash on Windows)

```bash
./install.sh
```

### Windows PowerShell

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

## What the installer does

1. **Detect tools.** Looks for the config directories:
   - Claude Code: `~/.claude/`
   - Codex: `~/.codex/`
   - Antigravity: `~/.gemini/`
   - OpenCode: `~/.config/opencode/`
2. **Confirm targets.** Prints the list; you accept or edit.
3. **Step diagnostic.** Six questions, terminal-only, ~90 seconds. Result written to `~/.harness-v3/STEP.md`. You can override.
4. **Backup.** Any prior `~/.harness-v3/` is moved to `~/.harness-v3.bak.<timestamp>/`. Each tool's target config file is copied into that backup dir before edits.
5. **Copy.** `package/` → `~/.harness-v3/`. Prior principle files preserved under `principles/archive/` with date tags.
6. **Wire tools.** For each selected tool, inserts or updates a marker block:
   ```
   <!-- harness-v3:begin -->
   [inlined HARNESS.md content]
   <!-- harness-v3:end -->
   ```
   Content outside markers is preserved. Prior `<!-- claude-harness:begin -->` blocks from v2 are removed.

## Where each tool reads the harness from

| Tool | File edited |
|---|---|
| Claude Code | `~/.claude/CLAUDE.md` |
| Codex | `~/.codex/AGENTS.md` (created if absent) |
| Antigravity | `~/.gemini/GEMINI.md` |
| OpenCode | `~/.config/opencode/AGENTS.md` (created if absent) |

## Changing your step later

```bash
~/.harness-v3/scripts/set-step.sh 3
~/.harness-v3/scripts/set-step.ps1 3
```

Or re-run the diagnostic:

```bash
~/.harness-v3/scripts/step-diagnostic.sh
```

## Rollback

Each install writes `~/.harness-v3.bak.<timestamp>/rollback.sh` (or `.ps1`).
Running it restores every tool config to its pre-install state and removes
`~/.harness-v3/`.

## Uninstall

Run the latest backup's `rollback.sh`. That's it.

## Non-interactive install

The installers accept flags for scripted use:

```bash
./install.sh --tools claude,codex --step 2 --yes
```

```powershell
.\install.ps1 -Tools claude,codex -Step 2 -Yes
```

## Known limitations

- Antigravity is new (2026). If the AGENTS.md / GEMINI.md conventions shift, the installer may need updating. The rollback is always safe.
- On Windows without PowerShell 7, the `.ps1` uses PS 5.1 syntax and avoids `??`/ternary.
- Symlinks are not used — every tool file is a plain-text edit between markers.
