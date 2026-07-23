---
principle: 10
name: Toolkit
tier: 1+
rev: v3-2026-07-23
supersedes: archive/10-toolkit.v2026-07-14.md
model-limitation: Rules held only in prose are re-interpreted (and re-violated) on every task; automation removes the option.
---

# 10 · The Toolkit Principle

**Rule:** Knowledge without automation decays. Encode your principles into tools that enforce them automatically.

## Agent protocol
1. **Two-strike rule:** any harness rule violated twice gets a proposed enforcement tool — pre-commit hook, lint rule, CI check, slash command, or template.
2. Register every such tool in `TOOLKIT.md` at the project root: name, what rule it enforces, how to run it.
3. Tools obey Principle 07 (observable) and Principle 01 (deterministic).
4. Periodically (e.g., at plan time) scan LESSONS.md for lessons ready to be promoted into tools.
5. Every new tool triggers Principle 11 justification: what model limitation does this tool exist to compensate for? If the answer is "none anymore," delete it.

## The compounding loop
Mistake → LESSON (05) → repeated? → TOOL (10) → enforced forever (01) → context freed (02) → re-justified per task (11).

## Done when
The harness gets *more* reliable over time without anyone needing to remember it — and *smaller* over time as model capability absorbs former scaffolding.
