---
component: brain-hand
tier: 3+
status: inert-until-step-3
rev: v3-2026-07-23
supersedes: (new in v3)
model-limitation: A model context that both orchestrates and executes cannot survive its own crashes or credential leaks.
source: Lance Martin — Claude for Long-Horizon Tasks (Anthropic)
---

# Brain-Hand Decoupling

**Spec-only in v3.** This document describes the runtime architecture that activates at Step 3+ (supervised autonomy). Nothing in this file is loaded into an agent's active context at Step 1 or 2.

## Components

- **Harness (brain)** — a stateless orchestrator process. Reads sessions and event logs; dispatches work. Not the model context itself; the process that *invokes* the model.
- **Session** — an append-only event log serving as the single source of truth. Persists across crashes. See `architecture/event-log.md`.
- **Hands** — ephemeral sandboxed containers that perform actual work. Disposable. If a sandbox dies, the harness spawns a new one and resumes from the event log.
- **Credential vault** — separate from execution containers; the hand cannot enumerate or exfiltrate credentials. See `architecture/vault.md`. (Note: vault is active at Step 1+; the rest of brain-hand is Step 3+.)

## Failure semantics

- Sandbox crash → harness re-dispatches with the same session ID; the new hand replays the event log to reach current state.
- Model context loss → same handling; the log is the truth.
- No destructive in-place compaction of context is required, because context can always be rebuilt from the immutable log (P02 alignment).

## Interfaces (Step 3+ implementation notes)

- Event log schema: JSONL, one event per line, monotonic sequence numbers, event types include `plan.approved`, `contract.signed`, `tool.call`, `tool.result`, `review.finding`, `gate.reached`, `gate.approved`.
- Sandbox contract: hands receive session state via read of the event log; write events by append; cannot mutate history.
- Vault contract: hands request secrets by role; vault returns short-lived tokens; every request emits a `vault.access` event to the session log.

## Not in scope for v3

Actual container runtime, secret-store backend, and sandbox tooling are deployment concerns. v3 specifies the contract; the deployment picks the implementation.
