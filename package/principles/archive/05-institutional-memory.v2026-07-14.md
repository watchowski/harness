# 05 · The Institutional Memory Principle

**Rule:** When an agent makes a mistake, don't just correct it — codify it forever.

## Agent protocol
1. A mistake was made and corrected (wrong API usage, broken assumption, bad default)? Append an entry to `harness/LESSONS.md` using `harness/templates/LESSONS.md` format: date, context, mistake, correction, rule going forward.
2. Read `LESSONS.md` at the start of every non-trivial task. Its rules rank just below direct human instructions.
3. Repeating a codified lesson is a **BLOCKER** severity event.
4. When a lesson generalizes, promote it: into CLAUDE.md, a lint rule, or a tool (Principle 10).

## Anti-patterns
- Fixing the same class of bug in three sessions with no written trace.
- Lessons phrased as stories instead of actionable rules.

## Done when
The same mistake made twice becomes structurally difficult to make a third time.
