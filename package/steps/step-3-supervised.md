---
step: 3
name: Supervised autonomy
agent-count: ~100
role: manager of managers
rev: v3-2026-07-23
---

# Step 3 — Supervised autonomy

**Claude writes all or nearly all of the code.** You stop asking "did you read the code?" and start asking "what context was the model missing, and how do we solve it for next time?"

## Newly active at this step (vs. Step 2)

| Component | Why |
|---|---|
| Brain-hand runtime (`architecture/brain-hand.md`) | Sessions must survive individual crashes |
| Append-only event log (`architecture/event-log.md`) | Replayable, auditable, resumable state |
| Model-owned `memory/` + offline dreaming (`architecture/memory.md`) | Recurring confabulations must be caught out-of-band |
| Subagent orchestration (`/loop`, `/batch`, routines) | Repetitive work fans out |
| Sprint contracts (`templates/CONTRACT.md`) | Generator/evaluator must agree on "done" before code is written |
| Cost controls | Usage grows faster than human review capacity |
| Agent sandboxing | Blast-radius containment matters more |

## Bottleneck at this step

**Trust in the loop and team decision throughput.** The agent tree is too deep to babysit; the trap is scaling agent count before the loop has earned widespread trust. Also: token cost per useful outcome — monitor via OTel and cull vestigial harness components (P11).

## How to know you're ready for Step 4

- Domain-specific use cases have PMF (feedback loops closed, cost known per outcome).
- Claude routinely proposes work you would have had to kick off manually.
- You steer by outcome, not by task.

## Products that match this step

- Subagents with worktree isolation.
- Routines, `/loop`, `/batch`, `/goal`.
- Dynamic workflows.
- Claude Tag with channel/data-source monitoring.
- CLAUDE.md / AGENTS.md / GEMINI.md + Skills to encode standards.
- Auto mode classifier tuning.
