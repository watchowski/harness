# Harness v3

An **installable engineering harness** for agentic coding, portable across
Claude Code, OpenAI Codex, Google Antigravity, and OpenCode.

## What this is

A rulebook + runtime spec that shapes how an AI coding agent works with you.
Not a style guide — a persistent context architecture and execution protocol.
Synthesized from four public sources:

- [jdforsythe's 10 Claude Code Principles](https://jdforsythe.github.io/10-principles/) — governance rulebook.
- [Lance Martin, "Claude for Long-Horizon Tasks" (Anthropic)](https://www.youtube.com/watch?v=9QebvrrY3KY) — long-running architecture (brain/hand, event log, memory + dreaming).
- [Anthropic engineering, "Harness Design for Long-Running Apps"](https://www.anthropic.com/engineering/harness-design-long-running-apps) — multi-agent tactics (generator/evaluator, sprint contracts, context resets).
- Boris Cherny, "Steps of AI Adoption" — the maturity model that decides which components activate when.

## Why v3

- **Step-tiered.** Components activate per your org's adoption step (1–4). Higher-tier files ship on disk but stay inert until you promote.
- **Cross-tool.** One install target, four tools wired up automatically.
- **Portable.** No Node, no Python, no external services required.
- **Minimalist-by-principle** (P11). Every component names the model limitation it compensates for. If the current model no longer needs it, it's deleted.

## Install

```bash
# POSIX (macOS, Linux, WSL, git-bash on Windows)
./install.sh

# Windows PowerShell
powershell -ExecutionPolicy Bypass -File install.ps1
```

The installer:
1. Detects which tools (Claude Code / Codex / Antigravity / OpenCode) you have.
2. Asks 6 questions to place you on the adoption step (1–4).
3. Copies the harness to `~/.harness-v3/`.
4. Inlines the harness entry point into each selected tool's global instruction file, between `<!-- harness-v3:begin -->` / `<!-- harness-v3:end -->` markers.
5. Backs up any prior install and any prior tool config to a timestamped directory.

See `INSTALL.md` for detail.

## Layout

```
~/.harness-v3/
├── HARNESS.md               # entry point (inlined by each tool)
├── STEP.md                  # your step + diagnostic answers
├── principles/              # 11 principles, tiered
│   └── archive/             # prior versions preserved
├── architecture/            # runtime specs (Step 3+ mostly inert)
├── steps/                   # per-step activation lists
├── templates/               # PLAN, CONTRACT, REVIEW, LESSONS, EXCEPTIONS
└── scripts/                 # set-step, uninstall
```

## Uninstall / rollback

Every install run writes a backup to `~/.harness-v3.bak.<timestamp>/` including
the pre-install state of every tool config file it touched. A `rollback.sh`
(or `.ps1`) in that backup restores everything.

## License

MIT — see `LICENSE` (add your own before redistributing).
