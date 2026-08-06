# Claude Code Harness

A single PowerShell installer, `Install-ClaudeHarness.ps1`, that implements
the [10 Principles](https://jdforsythe.github.io/10-principles/) for
agentic coding as native Claude Code mechanisms -- PreToolUse/PostToolUse/
SessionStart/Stop hooks, CLAUDE.md guidance, specialist subagents, and
slash commands -- rather than as prose you hope the model remembers.

The article itself is a philosophy piece, not a single installable
package; it references two companion tools (Forge, jig) by the same
author, but jig is explicitly unsupported on Windows and Forge installs
via a Claude-Code-internal `/plugin add` command, not a shell script. This
repo hand-builds a lightweight, native equivalent using Claude Code's own
hook/agent/command system instead, which works the same on Windows as
anywhere else.

## What each principle maps to

| # | Principle | Mechanism |
|---|-----------|-----------|
| 1 | Hardening | PreToolUse hook, deterministic Bash deny-list |
| 2 | Context Hygiene | CLAUDE.md guidance + Stop-hook reminder in auto mode |
| 3 | Living Documentation | CLAUDE.md guidance + `docs-reviewer` agent + Stop-hook gate in auto mode |
| 4 | Disposable Blueprint | `/plan` command -> `.claude/plans/*.md` + Stop-hook reminder in auto mode |
| 5 | Institutional Memory | `/learn` command -> `.claude/LEARNINGS.md` + Stop-hook gate in auto mode |
| 6 | Specialized Review | `/review` command + 3 specialist agents + Stop-hook gate in auto mode |
| 7 | Observability | PostToolUse hook -> `.claude/logs/tool-use.log` |
| 8 | Strategic Human Gate | PreToolUse hook, deterministic ask-list |
| 9 | Token Economy | CLAUDE.md guidance + Stop-hook reminder in auto mode |
| 10 | Toolkit | this installer itself (tools, not just prose) |

Principles 1, 7, and 8 are hook-enforced unconditionally, regardless of
Claude Code's permission mode. Principles 2-6, 9, and 10 previously relied
entirely on CLAUDE.md being remembered -- nothing stopped an unattended
`auto`-mode session from silently skipping `/review`, `/learn`, or docs
upkeep. The `principles-auto-gate.ps1` Stop hook closes that gap: when
`permission_mode` is `auto`, `bypassPermissions`, or `dontAsk` (i.e. no
human is realistically watching), it blocks the turn once per session if
code was edited with no specialist review dispatched, and folds reminders
for the non-mechanically-checkable principles into the same message.

## Usage

```powershell
# Install into your global ~/.claude (applies to every project)
.\Install-ClaudeHarness.ps1 -Scope Global

# Install into a specific project
.\Install-ClaudeHarness.ps1 -Scope Project -ProjectPath C:\code\my-app

# Both, overwriting existing harness files (originals are backed up first)
.\Install-ClaudeHarness.ps1 -Scope Both -ProjectPath C:\code\my-app -Force
```

- `-Scope Global` installs into `$env:USERPROFILE\.claude`.
- `-Scope Project` installs into `.\.claude` and `.\CLAUDE.md` under `-ProjectPath` (defaults to the current directory).
- `-Force` overwrites existing harness template files; originals are backed up alongside with a `.bak-<timestamp>` suffix first. Without `-Force`, existing files are left untouched. `settings.json` is always merged (never blindly overwritten) and always backed up before being rewritten, regardless of `-Force`.

Restart Claude Code (or start a new session) after installing for hooks
and commands to take effect.
