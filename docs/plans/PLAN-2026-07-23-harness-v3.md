---
plan: harness-v3
date: 2026-07-23
revision: 2
status: DRAFT — awaiting human approval
supersedes: ~/.claude/harness/ (v1/v2), installed as replacement
---

# Harness v3 — installable package, multi-tool, step-tiered

## Goal

Deliver an **installable harness package** that:

1. Replaces the existing `~/.claude/harness/` installation.
2. Preserves prior versions as sibling files (not overwrites).
3. Ships the full stack of components (Steps 1 → 4), inert until promoted.
4. Installs on **Claude Code, Codex, Antigravity, and OpenCode** using each
   tool's native instruction-file convention.
5. Includes an install-time **step diagnostic** so users at different
   adoption points get the right baseline out of the box.

## Human-approved decisions (from prompt)

- **Q1 — Replace `~/.claude/harness/`.** Package installs as replacement.
  This dev workspace builds the package; end users run the installer.
- **Q2 — Preserve prior versions as separate files.** Not commented
  audit trail. Historical files live in `archive/` with version suffixes.
- **Q3 — Reuse `/harness-review` command name.**

## Source reconciliation

| # | Source | Role in v3 |
|---|---|---|
| A | jdforsythe 10 Principles | Governance rulebook (all steps) |
| B | Lance Martin — long-horizon architecture | Runtime architecture (Step 3+) |
| C | Anthropic — harness design for long-running apps | Multi-agent tactics (Step 2+) |
| D | Boris Cherny — Steps of AI Adoption | Meta-layer: activation per step |

## Non-goals

- Not shipping production infra (event log, sandbox, vault); only **specs**.
- No org-level identity implementation (Step 4-only, spec-only in v3).
- Installer is not a package manager. No auto-updates, no versioned pins.
  Users re-run installer to update.

## Repository layout (this workspace = package source)

```
harnessv3/                             # this workspace
├── install.sh                         # POSIX installer (macOS, Linux, WSL, git-bash)
├── install.ps1                        # Windows PowerShell installer
├── INSTALL.md                         # human-readable install docs
├── README.md                          # what this is, why, how to use
├── package/                           # installer copies this to ~/.harness-v3/
│   ├── HARNESS.md                     # entry point loaded by every tool
│   ├── STEP.md                        # written by installer with detected step
│   ├── principles/
│   │   ├── 01-hardening.md            # v3 current
│   │   ├── 02-context-hygiene.md
│   │   ├── 03-living-documentation.md
│   │   ├── 04-disposable-blueprint.md
│   │   ├── 05-institutional-memory.md
│   │   ├── 06-specialized-review.md
│   │   ├── 07-observability.md
│   │   ├── 08-strategic-human-gate.md
│   │   ├── 09-token-economy.md
│   │   ├── 10-toolkit.md
│   │   ├── 11-harness-minimalism.md   # NEW
│   │   └── archive/                   # prior versions preserved per §Versioning
│   │       ├── 01-hardening.v2026-07-14.md
│   │       └── ...
│   ├── steps/
│   │   ├── step-1-assisted.md         # activation list per step
│   │   ├── step-2-parallel.md
│   │   ├── step-3-supervised.md
│   │   └── step-4-ai-native.md
│   ├── templates/
│   │   ├── PLAN.md                    # intent artifact
│   │   ├── CONTRACT.md                # NEW — sprint contract
│   │   ├── REVIEW.md                  # weighted-rubric review
│   │   ├── LESSONS.md
│   │   └── EXCEPTIONS.md
│   └── architecture/                  # Step 3+ specs (inert markers on higher-tier)
│       ├── brain-hand.md
│       ├── event-log.md
│       ├── memory.md
│       └── vault.md                   # active from Step 1 — cheap
├── scripts/
│   ├── step-diagnostic.sh             # sourced by install.sh
│   ├── step-diagnostic.ps1            # sourced by install.ps1
│   └── link-tool.sh|.ps1              # per-tool wire-up helpers
└── docs/plans/PLAN-2026-07-23-harness-v3.md   # this file
```

## Install destination (single shared location)

The installer copies `package/` to `~/.harness-v3/`. All four tools reference
that same location — no duplication. Rationale: one source of truth, one
place to update, works regardless of which tools the user has installed.

## Tool wire-up (marker-delimited include block)

For each selected tool, the installer edits the tool's global instruction
file, inserting or updating a block between markers:

```
<!-- harness-v3:begin -->
@~/.harness-v3/HARNESS.md
<!-- harness-v3:end -->
```

- **Claude Code:** edits `~/.claude/CLAUDE.md`. Uses `@` include (Claude Code
  native syntax). Removes any prior `<!-- claude-harness:begin -->` block
  (v1/v2 marker).
- **Codex:** edits `~/.codex/AGENTS.md` (creates if missing). Inline-copies
  HARNESS.md content between markers if Codex version doesn't support `@`
  includes; else uses `@`.
- **Antigravity:** edits `~/.gemini/GEMINI.md` (global rules per Antigravity
  docs). Also creates project-level `AGENTS.md` referrer when a project is
  provided. Inline-copies content.
- **OpenCode:** edits `~/.config/opencode/AGENTS.md`. OpenCode's rule
  system supports directory-walked rule files; single global include is
  correct default.

Re-running the installer updates only the block between markers —
user-authored content outside markers is preserved.

## Step diagnostic (install-time questionnaire)

The installer asks 6 short questions. Each answer scores 1–4 (matching Boris's
step numbering). The result is the **median of answers, rounded down**
(conservative — infra floor caps ambition). User sees the score and can
override. The chosen step is written to `~/.harness-v3/STEP.md`.

Questions:

1. **Concurrent agents in a normal session?**
   - one at a time (1) / 2–5 in parallel (2) / ~10 with subagents (3) /
     hundreds, mostly agent-initiated (4)
2. **What do you review?**
   - every response and edit (1) / final diffs + evaluator reports (2) /
     exceptions and drift signals (3) / intent and outcomes, not diffs (4)
3. **How is agent work verified before you see it?**
   - I read the output (1) / auto tests + lint + typecheck run first (2) /
     a separate verifier context grades it (3) / full CI + verifier +
     auto-remediation (4)
4. **Auto mode / permission prompts?**
   - never, I approve each action (1) / on for most, prompted for
     structural (2) / always on with narrow gates (3) / always on, cost caps
     govern (4)
5. **Observability?**
   - terminal output only (1) / dashboard or analytics UI (2) /
     OTel export + alerts (3) / OTel + budget caps + exception dashboards (4)
6. **Who initiates work?**
   - only me (1) / me + some scheduled routines (2) / mostly me but the
     agent proactively starts related tasks (3) / mostly the agent — I
     steer by intent (4)

Median → step. Example: answers `[2,2,2,1,2,1]` → median 2 → Step 2.
Example: `[3,2,3,3,1,2]` → median 2.5 → floor 2 → Step 2 (infra floor).

## Versioning of principle files

- Active files at `package/principles/NN-name.md` are v3.
- Prior versions live in `package/principles/archive/NN-name.<version>.md`
  where `<version>` is a date tag (e.g. `v2026-07-14`) matching the source
  filesystem's timestamp.
- Installer preserves both. `HARNESS.md` links only to active v3 files;
  archives are reachable via `archive/` for audit and diff.
- Users who want to pin to a legacy principle can `@` the archived file
  from their own AGENTS.md.

## Amendments to the 10 Principles (unchanged from rev 1)

- **P02** — "summarize" scoped to within-turn tool output; cross-session
  state uses reset + handoff.
- **P03** — split `docs/` (human) vs `memory/` (model).
- **P04** — three artifacts: plan, sprint contract, event log.
- **P05** — adds offline dreaming reconciliation.
- **P06** — delivered as N verifier contexts with weighted rubrics.
- **P07** — OTel export mandatory at Step 2+.
- **P08** — narrowed to four gates (structural plan approval, destructive
  ops, new deps, prod deploy); auto-mode compatible.
- **P11 (new)** — Harness Minimalism: every component declares (i) the
  model limitation it compensates for and (ii) its step tier.

## Step activation table (unchanged)

| Component | S1 | S2 | S3 | S4 |
|---|---|---|---|---|
| 10 Principles (amended) | ● | ● | ● | ● |
| Plan artifact | ● | ● | ● | ● |
| Human at every gate | ● | — | — | — |
| Auto mode + narrow gates | — | ● | ● | ● |
| Worktree isolation | — | ● | ● | ● |
| Generator/evaluator triad | — | ● | ● | ● |
| `/harness-review` (N verifiers) | — | ● | ● | ● |
| OTel / analytics | — | ● | ● | ● |
| Credential vault | ● | ● | ● | ● |
| Brain-hand + event log | — | — | ● | ● |
| Model-owned memory + dreaming | — | — | ● | ● |
| Subagent orchestration | — | — | ● | ● |
| Org-level identity | — | — | — | ● |
| Cost controls on automation | — | — | ● | ● |

## Installer flow (both `install.sh` and `install.ps1`)

1. Detect: which of {Claude Code, Codex, Antigravity, OpenCode} have config
   dirs present. Print the list.
2. Ask: which tools to install for (default = all detected; multi-select).
3. Run diagnostic (6 questions above). Compute step. Show result. Let user
   override.
4. Backup: if `~/.harness-v3/` exists, move to `~/.harness-v3.bak.<timestamp>/`.
   If prior `~/.claude/harness/` exists, copy each file into
   `~/.harness-v3/package/principles/archive/` before overwriting.
5. Copy: `package/` → `~/.harness-v3/`.
6. Write `~/.harness-v3/STEP.md` with the chosen step and diagnostic answers.
7. Wire up each selected tool: insert/update marker-delimited block.
8. Print: summary of what was installed, path to STEP.md, and how to
   change step later (`~/.harness-v3/scripts/set-step.sh N`).

## Rollback

Every installer run writes a backup dir. `~/.harness-v3.bak.<ts>/` is a
full copy of the previous install. A `rollback.sh|.ps1` script in the
backup restores the previous state including tool wire-ups.

## Cross-platform considerations

- `install.sh`: POSIX, works on macOS, Linux, WSL, and git-bash for Windows.
- `install.ps1`: PowerShell 7+ preferred, PowerShell 5.1 compatible for
  Windows out-of-box.
- Both scripts use the same diagnostic question wording and step mapping.
- Path handling: use `HOME` (POSIX) / `$env:USERPROFILE` (PowerShell).
- No external runtime dependencies (no Node, Python, jq). Pure shell.

## Resolved decisions (rev 2 final)

- **Antigravity target:** `~/.gemini/GEMINI.md` only. Per Antigravity's own
  docs, this is the global-rules location. No dual-write.
- **Include style:** uniform across all four tools — installer inlines
  HARNESS.md's content between markers. HARNESS.md names sibling files by
  absolute path so the agent reads deeper files on demand (aligns with
  P02 Context Hygiene). No `@`-include semantics required. No symlinks.
- **Diagnostic UX:** terminal-only. Dependency-free.

## Gate

Rev 2 final. Implementation proceeds in one pass; stops only on blocker.
