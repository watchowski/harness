---
step: 2
name: Parallel
agent-count: ~10
role: orchestrator
rev: v3-2026-07-23
---

# Step 2 — Parallel

**One engineer orchestrates 5–10 agents.** You review final diffs, not keystrokes. Claude checks its own work first.

## Newly active at this step (vs. Step 1)

| Component | Why |
|---|---|
| Auto mode with narrow P08 gates | Parallelism requires it |
| Worktree isolation | Multiple concurrent agents cannot collide |
| Generator/evaluator triad (P06) | You cannot personally review 10 streams |
| `/harness-review` with N verifier contexts | Weighted rubrics, calibration examples |
| OTel export (P07 required) | You cannot personally watch 10 streams either |
| Pre-approved allowlists in `settings.json` | Auto mode is meaningless without allowlists |

## Inert (present but not loaded)

- Event log, brain-hand runtime, memory + dreaming — Step 3+.
- Org-level identity, cost controls on automation — Step 4.

## Bottleneck at this step

**Reviewing output and steering.** You're hand-writing less code and instead reading six streams of diffs — that itself starts to consume your day.

## How to know you're ready for Step 3

- Claude reliably kicks off related tasks on its own initiative and you want that formalized.
- Your review capacity is the constraint; verifier contexts routinely catch things a human review would.
- You need agent trees deeper than one level (agents dispatching subagents).

## Products that match this step

- Auto mode.
- Agent view.
- Claude Code Review / Claude Security Review.
- Claude Code on Mobile, cloud execution.
- Worktree isolation in CLI and Desktop.
- Claude Tag (single task).
