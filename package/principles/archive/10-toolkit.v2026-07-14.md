# 10 · The Toolkit Principle

**Rule:** Knowledge without automation decays. Encode your principles into tools that enforce them automatically.

## Agent protocol
1. **Two-strike rule:** any harness rule violated twice gets a proposed enforcement tool — pre-commit hook, lint rule, CI check, slash command, or template.
2. Register every such tool in `TOOLKIT.md` at the project root: name, what rule it enforces, how to run it.
3. Tools obey Principle 07 (observable) and Principle 01 (deterministic).
4. Periodically (e.g., at plan time) scan LESSONS.md for lessons ready to be promoted into tools.

## The compounding loop
Mistake → LESSON (05) → repeated? → TOOL (10) → enforced forever (01) → context freed (02).

## Done when
The harness gets *more* reliable over time without anyone needing to remember it.
