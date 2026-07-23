---
principle: 01
name: Hardening
tier: 1+
rev: v3-2026-07-23
supersedes: archive/01-hardening.v2026-07-14.md
model-limitation: LLMs re-derive the same transformation with subtle drift each time.
---

# 01 · The Hardening Principle

**Rule:** Every fuzzy LLM step that must behave identically every time must eventually be replaced by a deterministic tool.

## When it applies
- You performed the same transformation (formatting, scaffolding, renaming, data munging) more than once by reasoning.
- A step's output is verified by eyeballing instead of by a check.

## Agent protocol
1. Second occurrence of an identical fuzzy step → flag it: "This should be hardened."
2. Propose the smallest deterministic replacement: script, codegen template, lint rule, test, git hook.
3. Put the tool in `tools/` (or the project's script dir), make it emit clear exit codes (see Principle 07), and register it in `TOOLKIT.md`.
4. Before adding scaffolding, apply Principle 11: name the limitation the tool compensates for; delete when the limitation no longer holds.

## Anti-patterns
- Re-prompting the model to "do it exactly like last time."
- Hand-editing generated files that a template could produce.

## Done when
The step can be run by anyone (or CI) with zero model involvement and identical output.
