---
principle: 07
name: Observability
tier: 1+
rev: v3-2026-07-23
supersedes: archive/07-observability.v2026-07-14.md
model-limitation: The agent cannot correct what it cannot see; silent success paths let drift accumulate invisibly.
---

# 07 · The Observability Imperative

**Rule:** If you can't see inside your pipeline, you're trusting it on faith.

## Agent protocol
- Every script/hook/tool produced under this harness must: use meaningful exit codes, print a one-line machine-parseable summary, and log enough to reconstruct *why* it did what it did.
- No silent success and no swallowed errors: `catch {}` blocks and `|| true` require a written justification.
- Long-running agentic work should leave a trail: plan artifact → sprint contract → event log → commits → review findings → LESSONS entries.
- Prefer verifiable checks ("tests pass", "linter clean") over self-assessment ("looks correct").

## OpenTelemetry — required at Step 2+

At Step 2 and above, structured telemetry export is **required**, not aspirational:

- Agent-run activity exported via OpenTelemetry (OTel) to the org's existing observability stack (SIEM, tracing backend, or analytics warehouse).
- Metrics: agent invocations, tool calls, token usage, review-pass outcomes, gate approvals.
- Divergence signal (P04): flag when the event log diverges materially from the approved plan.
- At Step 1 (single-user, single-agent) terminal output can suffice; at Step 2+ it does not.

## Amendment from v2
- v2 named observability as principle without a concrete deliverable at any step. v3 makes OTel export the concrete deliverable, required at Step 2 and above.

## Anti-patterns
- Scripts that print nothing and exit 0 no matter what.
- Claiming success on work whose verification was never run.
- Running 5 parallel agents at Step 2 with no telemetry — you are flying blind.

## Done when
A human can audit any harness-driven change after the fact using artifacts and telemetry alone, without replaying the conversation.
