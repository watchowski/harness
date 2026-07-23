---
principle: 03
name: Living Documentation
tier: 1+
rev: v3-2026-07-23
supersedes: archive/03-living-documentation.v2026-07-14.md
model-limitation: Model trusts stated documentation over observed code state; stale docs mislead more than absent docs.
---

# 03 · The Living Documentation Principle

**Rule:** Documentation is context. Stale documentation is poisoned context.

## Two audiences, two directories

v3 splits documentation from agent memory:

- **`docs/`** — human-authored, human-audience. Updated by the same change set that invalidates it. Governed by this principle.
- **`memory/`** — model-authored, model-audience. Working notes, scratchpads, session-note fragments. Governed by Principle 05 and reconciled offline (see `architecture/memory.md`, active at Step 3+).

Do not conflate them. Human docs are not memory; agent memory is not documentation.

## Agent protocol
1. Before relying on a README/comment/spec, check its plausibility against the code it describes. If they disagree, the code wins — and the doc must be fixed.
2. Any change that invalidates a doc (README, API doc, this harness, CLAUDE.md/AGENTS.md/GEMINI.md) updates it **in the same change set**.
3. Docs that cannot be kept true should be deleted, not tolerated.
4. Date significant docs (plans, decisions) so staleness is detectable.
5. Agent-owned notes go under `memory/`, not `docs/`. They follow their own lifecycle.

## Anti-patterns
- "I'll update the docs in a follow-up." (There is no follow-up.)
- Comments that restate code instead of recording *why*.
- Model-authored scratch notes committed under `docs/` as if they were maintained documentation.

## Done when
A newcomer (human or agent) reading only the `docs/` tree would not be misled about how the system currently works.
