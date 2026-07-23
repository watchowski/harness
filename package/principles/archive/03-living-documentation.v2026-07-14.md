# 03 · The Living Documentation Principle

**Rule:** Documentation is context. Stale documentation is poisoned context.

## Agent protocol
1. Before relying on a README/comment/spec, check its plausibility against the code it describes. If they disagree, the code wins — and the doc must be fixed.
2. Any change that invalidates a doc (README, API doc, this harness, CLAUDE.md) updates it **in the same change set**.
3. Docs that cannot be kept true should be deleted, not tolerated.
4. Date significant docs (plans, decisions) so staleness is detectable.

## Anti-patterns
- "I'll update the docs in a follow-up." (There is no follow-up.)
- Comments that restate code instead of recording *why*.

## Done when
A newcomer (human or agent) reading only the docs would not be misled about how the system currently works.
