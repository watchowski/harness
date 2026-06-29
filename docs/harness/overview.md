# Harness Overview

This project uses a Claude Code harness — a set of persistent context files, hooks, and documentation that shapes how Claude behaves when working in this codebase.

## What It Does

- **Engineering discipline**: Claude follows the 10 principles from [jdforsythe.github.io/10-principles](https://jdforsythe.github.io/10-principles/) at every session
- **Accessibility compliance**: Claude generates WCAG 2.2 AA-compliant code and completes a review checklist before any UI PR merges
- **Institutional memory**: A Stop hook prompts Claude to document mistakes; learnings accumulate in `docs/harness/learnings.md`

## File Map

| File | Who reads it | Purpose |
|---|---|---|
| `CLAUDE.md` | Claude Code | Session entry point — imports all AI-facing rules |
| `.harness/principles.md` | Claude Code | 10 engineering principles |
| `.harness/a11y/A11Y.md` | Claude Code | Accessibility rules |
| `.harness/a11y/references/` | Claude Code (selective) | Domain-specific a11y patterns |
| `.harness/a11y/REPORT.md` | Claude Code + PR reviewer | Pre-merge a11y checklist |
| `.harness/a11y/EXCEPTIONS.md` | Team | Justified deviation log |
| `.claude/settings.json` | Claude Code | Hook registrations |
| `docs/harness/` | Team | Human-readable docs (this folder) |
| `docs/harness/learnings.md` | Claude Code + team | Accumulated lessons from past mistakes |

## Updating the Harness

Re-run the installer to pull updates. Your `EXCEPTIONS.md` and `settings.json` will be protected (you'll be prompted before overwrite).

To add a project-specific rule, edit `CLAUDE.md` directly under a `## Project Rules` section.
