# PLAN-<YYYY-MM-DD>-<slug>

**Status:** DRAFT | APPROVED | SUPERSEDED (by: <plan>) | DONE
**Task class:** structural
**Approved by:** <human> on <date>   ← Principle 08 gate
**Step tier:** <1|2|3|4>

## 1. Goal
One paragraph. What is true after this change that isn't true now?

## 2. Non-goals
Explicitly out of scope (prevents drift).

## 3. Current state
Relevant files/modules and how they behave today. Cite paths, not vibes.

## 4. Proposed change
Step-by-step. Each step small enough to verify independently.

| # | Step | Files touched | Verification |
|---|------|---------------|--------------|
| 1 |      |               |              |

## 5. Risks & blast radius
What breaks if this goes wrong? Rollback path?

## 6. Human gates in this plan
List every step that requires explicit approval — the four P08 gates only:
- (a) plan approval, (b) destructive ops, (c) new deps, (d) prod deploy.

## 7. Docs impacted (Principle 03)
Which docs must be updated in the same change set?

## 8. Lessons consulted (Principle 05)
Relevant LESSONS.md entries: <ids or "none">

## 9. P11 minimalism check
For each harness component this plan will invoke (verifier passes, event log,
memory dreaming, etc.), name the model limitation it compensates for. If any
component has no live justification against the current model, propose deletion
here.
