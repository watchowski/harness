# 04 · The Disposable Blueprint Principle

**Rule:** Never implement structural work without a saved, versioned plan artifact. And never fall in love with one.

## Agent protocol
1. For `structural` tasks, create `docs/plans/PLAN-<YYYY-MM-DD>-<slug>.md` from `harness/templates/PLAN.md` **before** writing code.
2. Get the plan through the human gate (Principle 08).
3. During implementation, if reality contradicts the plan (wrong assumption, hidden coupling): **stop**, mark the plan `SUPERSEDED`, write a new one. Do not silently drift.
4. Keep superseded plans in the repo — they are institutional memory.

## Anti-patterns
- Plans that live only in the chat scrollback.
- "Adjusting" the implementation away from the plan without updating either.
- Treating the plan as a contract to defend rather than a hypothesis to test.

## Done when
The merged change matches the latest non-superseded plan artifact.
