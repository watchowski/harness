---
principle: 11
name: Harness Minimalism
tier: 1+
rev: v3-2026-07-23
supersedes: (new in v3)
model-limitation: Harness scaffolding built for a previous model generation silently becomes vestigial, adding token cost and cognitive load without benefit.
---

# 11 · The Harness Minimalism Principle

**Rule:** Every harness component must justify its existence against the current model. Components without a live justification are deleted.

*"Every component in a harness encodes an assumption about what the model can't do on its own, and those assumptions are worth stress testing."* — Anthropic engineering, Harness Design for Long-Running Apps

## Per-task check

At the start of every structural task, for each harness component you're about to invoke:

1. **Name the limitation it compensates for.** "This exists because the model tends to X."
2. **Stress-test the assumption once.** Would the current model make the same mistake if the scaffolding were removed? Run a small unaided pass. If not, the component is vestigial.
3. **Mark vestigial components for deletion** in the next non-trivial change touching that area. Not a quarterly ritual — a per-task discipline.

## Frontmatter contract

Every principle, template, and architecture file in this harness carries a `model-limitation:` frontmatter field naming what agent tendency it compensates for. If that field cannot be filled honestly, the file is scaffolding for its own sake and should be removed.

## Tension with defaults

The harness ships with the full stack from Step 1 to Step 4 (per install-time choice). That means some components will be inert-but-present at your current step. Inert-but-present is fine; inert-but-loaded-into-context is not. The `tier:` frontmatter and step activation table (`steps/step-N-*.md`) govern loading.

## When components come back

Deleting a component today does not mean never again. If the underlying limitation resurfaces (model regression, new task class, new failure mode), the component returns — and its `supersedes:` frontmatter carries the audit trail.

## Anti-patterns
- Keeping a hardening tool because "it might still catch something."
- Preloading Step 3 architecture at Step 2 because "we'll need it eventually."
- Justifying a component with "best practice" instead of a named model limitation.

## Done when
Every active component in the harness has a live, testable justification against the current model on the current task class.
