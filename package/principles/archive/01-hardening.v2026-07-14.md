# 01 · The Hardening Principle

**Rule:** Every fuzzy LLM step that must behave identically every time must eventually be replaced by a deterministic tool.

## When it applies
- You performed the same transformation (formatting, scaffolding, renaming, data munging) more than once by reasoning.
- A step's output is verified by eyeballing instead of by a check.

## Agent protocol
1. Second occurrence of an identical fuzzy step → flag it: "This should be hardened."
2. Propose the smallest deterministic replacement: script, codegen template, lint rule, test, git hook.
3. Put the tool in `tools/` (or the project's script dir), make it emit clear exit codes (see Principle 07), and register it in `TOOLKIT.md`.

## Anti-patterns
- Re-prompting the model to "do it exactly like last time."
- Hand-editing generated files that a template could produce.

## Done when
The step can be run by anyone (or CI) with zero model involvement and identical output.
