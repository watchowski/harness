---
component: event-log
tier: 3+
status: inert-until-step-3
rev: v3-2026-07-23
supersedes: (new in v3)
model-limitation: Conversation history is lossy and non-replayable; without a durable log there is no way to resume a crashed session or audit a completed one.
source: Lance Martin — Claude for Long-Horizon Tasks (Anthropic)
---

# Event Log

**Spec-only in v3.** Activates at Step 3+.

## Format

- JSON Lines (`.jsonl`), one event per line, UTF-8, LF-terminated.
- Append-only. Never rewrite history in place. Corrections are new events referencing the corrected event ID.
- Location: `sessions/<session-id>/events.jsonl`.

## Event envelope

```json
{
  "seq": 1234,
  "ts": "2026-07-23T14:35:01.234Z",
  "session": "sess-abc123",
  "actor": "harness|agent|human|verifier",
  "type": "plan.approved",
  "payload": { ... }
}
```

- `seq` is monotonic within a session. Gaps are BLOCKERs.
- `ts` is ISO-8601 UTC with millisecond precision.
- `actor` names the party responsible for the event.
- `type` uses dotted namespaces (`plan.*`, `contract.*`, `tool.*`, `review.*`, `gate.*`, `vault.access`, `memory.write`).

## Required event types

| Type | Payload |
|---|---|
| `session.open` | `{ plan_ref, contract_refs, step }` |
| `plan.approved` | `{ plan_ref, approver, at }` |
| `contract.signed` | `{ contract_ref, generator, evaluator }` |
| `tool.call` | `{ tool, args_hash, args_ref }` |
| `tool.result` | `{ tool.call_seq, exit_code, summary }` |
| `review.finding` | `{ pass, severity, criterion, score, note }` |
| `gate.reached` | `{ gate, decision_ref }` |
| `gate.approved` \| `gate.denied` | `{ gate, actor, at, note? }` |
| `memory.write` | `{ path, hash }` |
| `vault.access` | `{ role, tool, at }` |
| `plan.superseded` | `{ old_plan_ref, new_plan_ref, reason }` |
| `session.close` | `{ status: done \| aborted, reason? }` |

## Replay

A hand starting on an existing session:

1. Read the log start-to-end.
2. Reconstruct: current plan, active contract, memory state, unfinished tool calls.
3. Resume from the last uncommitted point.

Replay must be deterministic given the log; hands must not consult external state that isn't reflected in events.

## Divergence detection (P07)

A separate observer process compares the plan artifact against the event log. Material divergence (steps in the log that are not in the plan; steps in the plan that never occurred) fires a `plan.superseded` candidate for the human's next gate — the plan is either amended or explicitly superseded.
