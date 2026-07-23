---
principle: 04
name: Disposable Blueprint
tier: 1+
rev: v3-2026-07-23
supersedes: archive/04-disposable-blueprint.v2026-07-14.md
model-limitation: Self-authored plans drift silently as implementation surprises accumulate; no artifact means no divergence signal.
---

# 04 · The Disposable Blueprint Principle

**Rule:** Never implement structural work without a saved, versioned plan artifact. And never fall in love with one.

## Three artifact types (v3)

v3 splits what v2 called "the plan" into three distinct artifacts with different lifecycles:

| Artifact | Author | Lifecycle | Location | Template |
|---|---|---|---|---|
| **Plan** — intent | Human ± planner-context | Approved once, superseded when reality diverges | `docs/plans/PLAN-<date>-<slug>.md` | `templates/PLAN.md` |
| **Sprint contract** — negotiated success criteria | Generator ↔ evaluator | Per-chunk, discarded on completion | `contracts/<slug>-<n>.md` | `templates/CONTRACT.md` |
| **Event log** — what happened | Harness runtime | Append-only, immutable | `sessions/<id>/events.jsonl` | `architecture/event-log.md` |

- Plan = **what we intend**.
- Sprint contract = **what "done" looks like for this chunk, agreed before code is written**.
- Event log = **what the agent actually did**, in order.

Divergence between plan and event log is a signal, surfaced via Principle 07.

The sprint contract and event log are Step-3+ machinery; the plan artifact is required at every step where structural work occurs.

## Agent protocol
1. For `structural` tasks, create `docs/plans/PLAN-<YYYY-MM-DD>-<slug>.md` from `templates/PLAN.md` **before** writing code.
2. Get the plan through the human gate (Principle 08).
3. Before each chunk of work at Step 3+, write a sprint contract from `templates/CONTRACT.md`. Generator and evaluator must agree on the criteria before the generator starts.
4. During implementation, if reality contradicts the plan (wrong assumption, hidden coupling): **stop**, mark the plan `SUPERSEDED`, write a new one. Do not silently drift.
5. Keep superseded plans in the repo — they are institutional memory.

## Amendment from v2
- v2 had one artifact type ("the plan"). v3 formalizes plan / sprint contract / event log as three distinct artifacts.
- The sprint contract is the load-bearing piece in generator/evaluator loops — an unweighted rubric and self-authored spec were failure modes documented in Anthropic's harness-design piece.

## Anti-patterns
- Plans that live only in the chat scrollback.
- "Adjusting" the implementation away from the plan without updating either.
- Treating the plan as a contract to defend rather than a hypothesis to test.
- Merging plan and contract into one artifact — one is intent, the other is negotiated success.

## Done when
The merged change matches the latest non-superseded plan artifact, and each chunk that was done under a sprint contract met its stated criteria.
