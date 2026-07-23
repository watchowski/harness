# REVIEW.md — Specialized Review Passes (Principle 06)

Run each pass independently. Report findings per pass with severity
(BLOCKER / CRITICAL / MAJOR / MINOR) or an explicit "clean".

## Pass 1 · Security
- [ ] No secrets/keys/tokens in code or logs
- [ ] All external input validated/escaped (injection: SQL/shell/path/HTML)
- [ ] AuthZ checked at every new endpoint/action, not just AuthN
- [ ] No unsafe deserialization, eval, or dynamic code from input
- [ ] Dependencies added? Check advisories & necessity (gate — Principle 08)

## Pass 2 · Correctness
- [ ] Error paths handled (not swallowed — Principle 07)
- [ ] Edge cases: empty, null, unicode, huge, concurrent
- [ ] Off-by-one / boundary conditions in loops & ranges
- [ ] Tests cover the change's intent, not just its lines

## Pass 3 · Performance
- [ ] No N+1 queries / repeated I/O in loops
- [ ] Hot paths free of needless allocation/copies
- [ ] Blocking calls not on async/UI threads

## Pass 4 · Accessibility (UI changes only)
- [ ] Semantic elements (button, nav, label) over div+onClick
- [ ] Full keyboard operability, visible focus, ESC closes modals
- [ ] Dynamic updates announced (aria-live) where users need them
- [ ] Contrast meets WCAG 2.2 AA

## Pass 5 · Maintainability
- [ ] Names reveal intent; no dead code left behind
- [ ] Docs/comments updated with the change (Principle 03)
- [ ] New repeated fuzzy step? Flag for hardening (Principle 01)
