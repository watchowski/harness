# P04 — Disposable Blueprint

> "Never implement without a saved, versioned plan artifact. And never fall in love with one."

## Why This Matters

A plan in Claude's working memory is invisible to everyone else and disappears when the session ends. A saved plan in `docs/superpowers/plans/` is reviewable, linkable, and survives session boundaries. Plans also expose assumptions — writing one out reveals what you don't know before you've committed to an approach.

## In This Project

Every significant implementation starts with a plan in `docs/superpowers/plans/YYYY-MM-DD-<feature>.md`, committed before any code is written. When the plan changes mid-implementation, the file is updated to reflect reality.

## Watch For

Starting to implement a task without an agreed, committed plan. Discovering mid-implementation that the approach is wrong and not updating the plan. Treating a completed plan as a contract rather than a record.
