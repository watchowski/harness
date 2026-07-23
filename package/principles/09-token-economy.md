---
principle: 09
name: Token Economy
tier: 1+
rev: v3-2026-07-23
supersedes: archive/09-token-economy.v2026-07-14.md
model-limitation: Under time pressure, the model prefers broad exploratory reads over targeted retrieval, compounding cost.
---

# 09 · The Token Economy Principle

**Rule:** Tokens are money. Most people are burning it.

## Agent protocol
- Targeted reads: `grep -n` / line ranges instead of whole files; whole file only when genuinely needed.
- Diffs and surgical edits instead of full-file rewrites.
- One precise clarifying question beats three exploratory tool rounds.
- Batch related tool calls; don't re-read a file you just wrote.
- Route work to the cheapest capable model/mode when the platform allows (subagents for mechanical work).
- Keep responses proportional: a one-line fix earns a one-line explanation.

## Anti-patterns
- Re-listing a directory every turn "to be safe."
- Regenerating an entire file to change a constant.
- Verbose narration of every internal step.

## Done when
The task result is identical to the expensive path, achieved with materially fewer tokens.
