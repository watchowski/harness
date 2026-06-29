# P09 — Token Economy

> "Tokens are money. Most people are burning it."

## Why This Matters

Token cost compounds. A 200k-context session costs more to infer, takes longer, and produces worse results than a focused 20k-context session. Most projects spend the majority of their token budget re-reading context that hasn't changed, re-deriving decisions that were already made, and carrying stale tool output.

## In This Project

Domain reference files are loaded on demand — not always in context. Completed sessions are summarized before handoff. Plans live in files — not in the prompt — so they don't need to be restated.

## Watch For

Starting every session by re-reading all project files from scratch. Leaving large tool outputs in context after they've been acted on. Using large models for tasks a smaller model handles equally well.
