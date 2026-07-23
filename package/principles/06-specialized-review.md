---
principle: 06
name: Specialized Review
tier: 2+
rev: v3-2026-07-23
supersedes: archive/06-specialized-review.v2026-07-14.md
model-limitation: A single context that both produces and grades its work confabulates positive assessments; generalist review trends to the median.
---

# 06 · The Specialized Review Principle

**Rule:** A generalist reviewer trends toward the median. Specialists find what generalists can't. And no context should grade its own work.

## Delivery mechanism (v3)

v2 delivered this as human-run checklists. v3 delivers it as **N independent verifier contexts**, each with:

- A **narrow mandate** (security / correctness / performance / accessibility / maintainability).
- A **runnable rubric** with criterion weights and calibration examples (`templates/REVIEW.md`).
- A **fresh context** — never the context that produced the code.

The invocation is `/harness-review` (reused from v2), which fans out to per-specialty verifier contexts and returns per-pass findings with severity.

## Agent protocol
1. Review non-trivial changes in **separate specialist passes**, each fresh context, each with a narrow mandate:
   - Security (injection, secrets, authz, unsafe deserialization)
   - Correctness (edge cases, error paths, concurrency)
   - Performance (N+1, allocations in hot paths, blocking I/O)
   - Accessibility (if UI — semantic HTML, keyboard, ARIA)
   - Maintainability (naming, coupling, dead code, docs drift)
2. Each rubric is weighted. Report criterion-level scores, not just pass/fail.
3. Each pass reports findings independently, with severity.
4. Never invoke the review from the same context that produced the code.

## Anti-patterns
- One "LGTM overall" pass covering everything.
- Skipping the security pass because "it's just a UI change."
- Same-context self-grading.
- Unweighted rubrics (every criterion equal makes design/originality invisible).

## Amendment from v2
- v2: human-run specialist checklists.
- v3: N verifier contexts, runnable rubrics with weights and calibration examples. Compatible with (and preferred at) Step 2+.

## Done when
Each relevant specialty produced explicit findings with per-criterion scores, from a fresh context, using a weighted rubric.
