# Claude Code Harness

A project-level harness for [Claude Code](https://claude.ai/code) that encodes:

- **10 engineering principles** from [jdforsythe.github.io/10-principles](https://jdforsythe.github.io/10-principles/)
- **WCAG 2.2 AA accessibility rules** modeled on [fecarrico/A11Y.md](https://github.com/fecarrico/A11Y.md)

Drop it into any project with one command.

---

## Install

**Linux / macOS / WSL:**
```bash
curl -sSL https://raw.githubusercontent.com/watchowski/harness/main/install.sh | bash
```

**Windows (PowerShell 5+):**
```powershell
irm https://raw.githubusercontent.com/watchowski/harness/main/install.ps1 | iex
```

Run from the root of your project. Git is recommended but not required.

---

## What Gets Installed

| File | Purpose |
|---|---|
| `CLAUDE.md` | Session entry point — Claude reads this at every session start |
| `.harness/principles.md` | 10 engineering principles with examples |
| `.harness/a11y/A11Y.md` | Accessibility rules matrix (WCAG 2.2 AA) |
| `.harness/a11y/references/` | Domain guides: forms, navigation, modals, contrast, images |
| `.harness/a11y/REPORT.md` | Pre-merge accessibility checklist template |
| `.harness/a11y/EXCEPTIONS.md` | Exception log for justified rule deviations |
| `.claude/settings.json` | Hook event registrations |
| `.claude/hooks/pre-commit` | Reminds Claude to complete `REPORT.md` before UI commits |
| `.claude/hooks/stop` | Prompts institutional memory capture at end of each turn |
| `docs/harness/overview.md` | Team-readable: what the harness is and why |
| `docs/harness/principles/` | Team-readable rationale for each of the 10 principles |
| `docs/harness/learnings.md` | Accumulated lessons from past mistakes (you fill this in) |

---

## How It Works

`CLAUDE.md` is the entry point. Claude Code reads it at the start of every session in this project. It imports `.harness/principles.md` and `.harness/a11y/A11Y.md` via `@` references, so Claude has the full rule set in context without a bloated `CLAUDE.md`.

Two hooks run automatically:
- **pre-commit** (`PreToolUse / Bash`): when Claude stages UI files for a git commit, it's reminded to complete `REPORT.md` first
- **stop** (`Stop`): at the end of every turn, Claude is prompted to document any mistakes in `docs/harness/learnings.md`

---

## Updating

Re-run the installer. Content files update automatically. `EXCEPTIONS.md` and `settings.json` prompt before overwriting (you may have edited them).

---

## Customising

**Add project-specific rules:**
Edit `CLAUDE.md` and add a `## Project Rules` section beneath the existing imports.

**Adjust hooks:**
Edit `.claude/hooks/pre-commit` or `.claude/hooks/stop` directly. They're plain Python 3 scripts.

**Record learnings:**
The Stop hook will prompt Claude, but you can also add entries to `docs/harness/learnings.md` manually. That file is part of Claude's persistent context.

**Log exceptions:**
When a rule in `A11Y.md` can't be met, add an entry to `.harness/a11y/EXCEPTIONS.md` before merging.

---

## Requirements

- [Claude Code](https://claude.ai/code) CLI
- Python 3 (for hooks)
- curl (Linux/macOS install) or PowerShell 5+ (Windows install)
- Git (recommended — the harness is designed to be version-controlled with your project)

---

## License

MIT
