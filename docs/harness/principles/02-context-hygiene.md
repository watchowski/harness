# P02 — Context Hygiene

> "Context is your scarcest resource. Treat it like memory in an embedded system, not disk space on a server."

## Why This Matters

Claude's context window is finite and expensive. Tokens loaded into context slow inference, increase cost, and — critically — dilute attention. A 200k-token context where 80% is stale tool output is worse than a focused 10k-token context.

## In This Project

`CLAUDE.md` is kept short deliberately. Domain reference guides (`.harness/a11y/references/*.md`) are not loaded by default — Claude should reference them selectively when working in that domain. The `@` import syntax loads files when needed, not always.

## Watch For

Letting tool results accumulate in context. Pasting full file contents when a path reference would do. Starting a new session without summarizing where the previous one left off.
