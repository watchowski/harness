# 07 · The Observability Imperative

**Rule:** If you can't see inside your pipeline, you're trusting it on faith.

## Agent protocol
- Every script/hook/tool produced under this harness must: use meaningful exit codes, print a one-line machine-parseable summary, and log enough to reconstruct *why* it did what it did.
- No silent success and no swallowed errors: `catch {}` blocks and `|| true` require a written justification.
- Long-running agentic work should leave a trail: plan artifact → commits referencing it → review findings → LESSONS entries.
- Prefer verifiable checks ("tests pass", "linter clean") over self-assessment ("looks correct").

## Anti-patterns
- Scripts that print nothing and exit 0 no matter what.
- Claiming success on work whose verification was never run.

## Done when
A human can audit any harness-driven change after the fact using artifacts alone, without replaying the conversation.
