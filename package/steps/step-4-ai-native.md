---
step: 4
name: AI-native
agent-count: 1000+
role: VP steering by intent
rev: v3-2026-07-23
---

# Step 4 — AI-native

**The loop is closed.** Most agents are kicked off by Claude. Hundreds to thousands run concurrently. You steer by intent and monitor by exception.

## Newly active at this step (vs. Step 3)

| Component | Why |
|---|---|
| Org-level harness identity | A single agent identity steered concurrently by many people (e.g. Claude Tag in Slack) |
| Shared organizational credentials & context | Repositories, tickets, docs available on day one |
| Cost controls on automation | Programmatic budget caps per use case |
| Exception-based monitoring | You watch failures, not successes |

## Bottleneck at this step

**Identifying and automating the right work, and enforcing the right guardrails per work type.** Not every task deserves 100 agents; deciding which do is the job.

## Products that match this step

- Claude Agent SDK for programmatic agent scheduling.
- Claude Tag in most channels with proactive replies.
- Model selection tuned per use case (advisors, LSPs, lazy Skills).
- Automation cost dashboards.

## Ceiling caveat

Step 4 is aspirational for most orgs in 2026. This harness supports it in spec but does not ship deployment infrastructure. Read the Anthropic engineering post on harness design before committing.
