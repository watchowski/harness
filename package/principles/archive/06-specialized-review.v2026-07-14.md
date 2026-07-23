# 06 · The Specialized Review Principle

**Rule:** A generalist reviewer trends toward the median. Specialists find what generalists can't.

## Agent protocol
1. Review non-trivial changes in **separate specialist passes**, each with a narrow mandate (checklists in `harness/templates/REVIEW.md`):
   - Security (injection, secrets, authz, unsafe deserialization)
   - Correctness (edge cases, error paths, concurrency)
   - Performance (N+1, allocations in hot paths, blocking I/O)
   - Accessibility (if UI — semantic HTML, keyboard, ARIA; see A11Y.md if adopted)
   - Maintainability (naming, coupling, dead code, docs drift)
2. Run each pass as if it were your only job; report findings per pass with severity.
3. Prefer separate subagents/sessions per specialty when tooling allows — a fresh context per specialty avoids anchoring.

## Anti-patterns
- One "LGTM overall" pass covering everything.
- Skipping the security pass because "it's just a UI change."

## Done when
Each relevant specialty produced explicit findings (or an explicit clean bill), not an implied one.
