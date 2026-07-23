---
component: memory
tier: 3+
status: inert-until-step-3
rev: v3-2026-07-23
supersedes: (new in v3)
model-limitation: Prescribed memory schemas produce shallow, brittle notes; unreconciled in-band memory accumulates confabulations that recur as identical failures.
source: Lance Martin — Claude for Long-Horizon Tasks (Anthropic)
---

# Memory & Offline Reconciliation ("Dreaming")

**Spec-only in v3.** Activates at Step 3+. At Step 1–2, the agent writes LESSONS.md directly (P05) without offline reconciliation.

## Location

- `memory/` at the project root (model-owned) or at the session root (session-scoped, ephemeral).
- Structure is chosen by the model. Do not prescribe a schema. Directories, filenames, formats: model's choice.

## Two phases

### In-band writing (during a task)

- The agent writes notes freely under `memory/`.
- Every write emits a `memory.write` event to the session log (P07).
- No validation, no schema enforcement.

### Offline reconciliation ("dreaming")

At end-of-session (or on schedule at Step 4), a **separate context** runs the reconciliation pass:

1. Read the session's event log start to end.
2. Read `memory/` state at session close.
3. Identify inconsistencies: memory that contradicts the log; memory referencing things that never happened; recurring wrong facts.
4. Rewrite memory to reflect what actually occurred.
5. For each inconsistency, propose a LESSONS.md entry (P05).

The reconciliation context must be **fresh** — never the context that wrote the memory. Same-context self-review reproduces the confabulation (P06 alignment).

## Rationale

Lance Martin: a Pokémon-playing agent failed identically 5/5 times because its memory recorded the wrong location. Same-context self-review missed it. Offline reconciliation caught it and failures ceased. The failure class is "beliefs the agent commits to during a task and then trusts on subsequent tasks."

## Cost

Reconciliation is additional inference. Deployment justification per use case:
- If the same failure recurs across sessions and you can't figure out why, dream.
- If you're at Step 3+ with unattended runs, dream by default.
- If you're at Step 1–2, direct LESSONS.md writing is sufficient — dreaming is P11-vestigial at that step.
