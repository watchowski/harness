# P10 — Toolkit Principle

> "Knowledge without automation decays. Encode your principles into tools that enforce them automatically."

## Why This Matters

A principle that requires a human to remember to apply it will be forgotten. Rules in documentation are aspirational; rules in hooks are operational. The gap between what a team says it does and what it actually does is often explained by this gap — principles that exist only in docs.

## In This Project

- Principle 05 (Institutional Memory) is enforced by the Stop hook
- Principle 06 (Specialized Review) is enforced by the pre-commit hook reminding Claude to complete `REPORT.md`
- This harness itself is an expression of Principle 10 — the principles are encoded in tools, not just described in text

## Watch For

Identifying a repeated mistake and responding only by adding a note to a doc. The right response is a hook, a skill, or a rule in `CLAUDE.md` — something that fires automatically.
