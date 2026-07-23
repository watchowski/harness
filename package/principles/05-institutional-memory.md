---
principle: 05
name: Institutional Memory
tier: 1+
rev: v3-2026-07-23
supersedes: archive/05-institutional-memory.v2026-07-14.md
model-limitation: Same mistake recurs across sessions because the agent has no durable, actionable record of prior errors.
---

# 05 · The Institutional Memory Principle

**Rule:** When an agent makes a mistake, don't just correct it — codify it forever.

## Agent protocol
1. A mistake was made and corrected (wrong API usage, broken assumption, bad default)? Append an entry to `LESSONS.md` using `templates/LESSONS.md` format: date, context, mistake, correction, rule going forward.
2. Read `LESSONS.md` at the start of every non-trivial task. Its rules rank just below direct human instructions.
3. Repeating a codified lesson is a **BLOCKER** severity event.
4. When a lesson generalizes, promote it: into the harness entry file, a lint rule, or a tool (Principle 10).

## Offline reconciliation ("dreaming") — Step 3+

At Step 3+, memory has two phases:

- **In-band writing.** During a task, the agent may write notes under `memory/` using whatever abstractions it chooses. No prescribed schema.
- **Offline reconciliation.** At end-of-task, a separate context replays the event log against `memory/`, identifies inconsistencies between stated beliefs and actual events, and rewrites memory. Inconsistencies discovered here become candidate LESSONS.md entries.

See `architecture/memory.md` for the reconciliation protocol. At Step 1–2 the agent writes lessons directly without the offline pass.

## Amendment from v2
- v2 had only in-band lesson writing during a task. v3 adds an offline reconciliation pass at Step 3+ to catch mistakes the agent did not itself notice — the Pokémon-agent recurring-location-error class of failure documented by Lance Martin.

## Anti-patterns
- Fixing the same class of bug in three sessions with no written trace.
- Lessons phrased as stories instead of actionable rules.
- Prescribing a memory schema for the model to fill in — let the model choose its own abstractions.

## Done when
The same mistake made twice becomes structurally difficult to make a third time.
