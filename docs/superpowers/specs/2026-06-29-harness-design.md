# Harness — Design Spec
**Date:** 2026-06-29
**Status:** Approved

---

## Overview

A project-level Claude Code harness that installs via a single shell command into any git repository. Encodes the 10 Claude Code engineering principles (jdforsythe.github.io/10-principles/) and an accessibility compliance system modeled on A11Y.md (github.com/fecarrico/A11Y.md). Shareable as a public GitHub repository.

---

## Goals

1. Drop a complete, opinionated Claude Code harness into any project in under 30 seconds
2. Encode engineering discipline (10 principles) and a11y compliance (WCAG 2.2 AA) as persistent context
3. Make the harness self-improving via institutional memory hooks
4. Stay maintainable: each piece evolves independently, nothing is monolithic

---

## Repository Structure

The GitHub repo layout is identical to what gets installed into the target project.

```
harness/
├── install.sh                        # curl-pipeable installer (Linux/macOS/WSL)
├── install.ps1                       # PowerShell installer (Windows)
├── README.md                         # Docs + one-liner install commands
│
├── CLAUDE.md                         # Short orchestrator, references harness files
│
├── .harness/
│   ├── principles.md                 # 10 principles with rules, explanations, examples
│   └── a11y/
│       ├── A11Y.md                   # Core accessibility rules matrix
│       ├── references/
│       │   ├── forms.md
│       │   ├── navigation.md
│       │   ├── modals.md
│       │   ├── contrast.md
│       │   └── images.md
│       ├── REPORT.md                 # Pre-merge a11y completion checklist template
│       └── EXCEPTIONS.md            # Exception log with justification template
│
├── .claude/
│   ├── settings.json                 # Hook registrations
│   └── hooks/
│       ├── pre-commit                # Reminds to complete REPORT.md before UI commits
│       └── stop                      # Institutional memory prompt at end of turn
│
└── docs/
    └── harness/
        ├── overview.md               # Team-readable: what this harness is and why
        └── principles/               # One doc per principle, human-readable rationale
            ├── 01-hardening.md
            ├── 02-context-hygiene.md
            ├── 03-living-documentation.md
            ├── 04-disposable-blueprint.md
            ├── 05-institutional-memory.md
            ├── 06-specialized-review.md
            ├── 07-observability.md
            ├── 08-strategic-human-gate.md
            ├── 09-token-economy.md
            └── 10-toolkit.md
```

---

## Component Details

### CLAUDE.md (Orchestrator)

Short by design — context hygiene (Principle 02). Imports heavy content via `@` references so Claude reads full rules without bloating the file itself.

```markdown
# Project Harness

## Engineering Discipline
@.harness/principles.md

## Accessibility
@.harness/a11y/A11Y.md

## Behavioral Rules (always active)
- Before any implementation, save a versioned plan artifact (Principle 04)
- When an agent makes a mistake, codify it in docs/harness/learnings.md (Principle 05)
- Never rubber-stamp. Flag ambiguous requirements before proceeding (Principle 08)
- Treat context window as a scarce resource. Prune aggressively (Principle 02)
```

### .harness/principles.md

One section per principle. Each section contains:
- The one-line rule (verbatim from jdforsythe)
- 2–3 sentence explanation
- Concrete do/don't example

Covers all 10 principles:
1. Hardening — replace fuzzy LLM steps with deterministic tools
2. Context Hygiene — context is scarce; treat it like embedded memory
3. Living Documentation — stale docs are poisoned context
4. Disposable Blueprint — always plan first; never fall in love with the plan
5. Institutional Memory — codify every mistake, not just correct it
6. Specialized Review — specialists find what generalists miss
7. Observability Imperative — if you can't see inside the pipeline, you're trusting on faith
8. Strategic Human Gate — rubber-stamp approval is the #1 quality failure
9. Token Economy — tokens are money; most people burn it
10. Toolkit Principle — encode principles into tools that enforce them automatically

### .harness/a11y/A11Y.md (Rules Matrix)

Three foundational pillars: Human-Centric, AI-Ready, Certifiable. Rules organized by domain:

- **Interactive elements**: keyboard accessibility, focus order, ARIA roles
- **Forms**: label associations, error announcements via aria-live, required field marking
- **Modals & overlays**: focus trapping, Escape key behavior, aria-modal
- **Contrast**: WCAG 2.2 AA ratios (4.5:1 text, 3:1 UI components)
- **Images**: alt text rules, decorative image handling, complex image descriptions
- **Navigation**: skip links, landmark regions, heading hierarchy

All rules mapped to WCAG 2.2 AA criteria for audit traceability.

### .harness/a11y/references/

Domain-specific guides loaded selectively — not always in context (Principle 02). Each file is a short, focused rule set for one domain. Claude references the relevant file when working in that domain.

### .harness/a11y/REPORT.md

Pre-merge quality gate. Claude fills this out before any UI-touching PR merges. Structured for copy-paste into PR description. Checklist format covering all rule categories.

### .harness/a11y/EXCEPTIONS.md

Exception log. Fields: rule violated, justification, owner, date, expiry. Satisfies the "certifiable" pillar — deviations are tracked, not silently ignored.

### .claude/hooks/

**pre-commit**: Fires before commits touching UI files (`.html`, `.tsx`, `.jsx`, `.vue`, `.svelte`, `.css`). Reminds Claude to complete `REPORT.md` and confirm no a11y regressions. Non-blocking — reminds and logs, does not abort the commit.

**Stop**: Fires when Claude finishes a turn. Prompts Claude to reflect on whether any mistakes or corrections occurred during the session and, if so, to codify the lesson in `docs/harness/learnings.md`. Implements Principle 05 (Institutional Memory) automatically. Uses the `Stop` hook event (not `PostToolUse`, which fires after every tool call and would be too noisy).

### .claude/settings.json

Registers hooks. Minimal — only what the harness needs. If a `.claude/settings.json` already exists in the target project, the installer prompts before overwriting. The harness `settings.json` only declares the `hooks` key; projects can extend it freely without conflict.

### docs/harness/

Human-readable team documentation. `overview.md` explains what the harness is and why it exists. `principles/` has one file per principle with rationale and team-facing guidance (distinct from the AI-facing rules in `.harness/principles.md`).

---

## Installer Design

### install.sh (Linux / macOS / WSL)

```
Steps:
1. Detect git repo (warn if not found, continue)
2. Check for existing CLAUDE.md — prompt before overwriting
3. Copy all harness files into current directory
4. chmod +x .claude/hooks/*
5. Print summary of installed files
```

Source URL: `https://raw.githubusercontent.com/<owner>/harness/main/install.sh`

One-liner: `curl -sSL https://raw.githubusercontent.com/<owner>/harness/main/install.sh | bash`

### install.ps1 (Windows PowerShell)

Same logic as install.sh, PowerShell syntax. Uses `Invoke-WebRequest` to fetch each file individually from the raw GitHub URLs (no curl dependency).

One-liner: `irm https://raw.githubusercontent.com/<owner>/harness/main/install.ps1 | iex`

### Update behavior

Re-running the installer updates all harness files. `CLAUDE.md` and `EXCEPTIONS.md` prompt before overwriting (may contain user edits). All other files overwrite silently.

---

## Out of Scope

- Global (`~/.claude/`) installation — project-level only
- Module selection / config-driven installs — full harness only
- Node.js / npx packaging
- CI/CD integration (separate concern)

---

## Success Criteria

1. Running the one-liner on a fresh directory installs all files in under 30 seconds
2. Claude Code reads CLAUDE.md and has full access to principles and a11y rules at session start
3. Hooks fire at the correct lifecycle events
4. The repo itself is the source of truth — updating it makes the latest harness available immediately to anyone re-running the installer
