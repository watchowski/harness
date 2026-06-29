# P07 — Observability Imperative

> "If you can't see inside your pipeline, you're trusting it on faith."

## Why This Matters

A pipeline that silently succeeds tells you nothing about why it succeeded. When something goes wrong, you have no signal — no record of what happened, no basis for diagnosis. Observability is the foundation of improvement.

## In This Project

`docs/harness/learnings.md` is the project's observability log. The Stop hook creates a natural audit boundary at every session end. Hook output is surfaced in Claude's context — not swallowed — so unexpected behavior is visible.

## Watch For

Hooks that always exit 0 with no output — they're invisible. Long stretches with no new entries in `learnings.md` — either nothing is being learned or the hook isn't prompting effectively.
