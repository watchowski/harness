# REVIEW.md — Specialized Review Passes (Principle 06, v3 format)

Run each pass independently, each in a **fresh context** (never the context
that produced the code). Each pass produces:

- Per-criterion score (0–5)
- Weighted total
- Findings with severity (BLOCKER / CRITICAL / MAJOR / MINOR / clean)

Delivery: `/harness-review` fans out to per-specialty verifier contexts and
returns per-pass results.

---

## Pass 1 · Security

| Criterion | Weight | 3/5 | 5/5 |
|---|---|---|---|
| Secrets/keys/tokens absent from code and logs | 20 | none found on grep of common patterns | dedicated secret scan run and clean |
| External input validated/escaped (SQL/shell/path/HTML) | 25 | validated at obvious boundaries | validated at every boundary with test coverage |
| AuthZ checked at every new endpoint/action | 20 | present on new endpoints | present + tests + fails-closed on unknown roles |
| No unsafe deserialization / eval / dynamic code from input | 20 | no obvious cases | statically checked or explicitly justified |
| Dependencies vetted (P08 gate) | 15 | new deps have known maintainers | + no known advisories + minimal surface |

## Pass 2 · Correctness

| Criterion | Weight | 3/5 | 5/5 |
|---|---|---|---|
| Golden path works | 25 | happy path passes | + regression tests added |
| Error paths handled, not swallowed (P07) | 25 | errors raised, not `|| true`'d | + every error path has a test |
| Edge cases: empty, null, unicode, huge, concurrent | 25 | obvious edges covered | property-based tests where possible |
| Test intent, not just line coverage | 25 | tests assert behavior | + tests would fail on the pre-change bug |

## Pass 3 · Performance

| Criterion | Weight | 3/5 | 5/5 |
|---|---|---|---|
| No N+1 queries / repeated I/O in loops | 40 | none in hot paths | benched and profiled |
| Hot paths free of needless allocation/copies | 30 | plausible on inspection | measured |
| Blocking calls off async/UI threads | 30 | no obvious violations | statically checked |

## Pass 4 · Accessibility (UI changes only)

| Criterion | Weight | 3/5 | 5/5 |
|---|---|---|---|
| Semantic elements (button, nav, label) over `div+onClick` | 25 | mostly semantic | fully semantic |
| Full keyboard operability, visible focus, ESC closes modals | 30 | tab order works | + focus trap + ESC + skip-to-main |
| Dynamic updates announced (aria-live) | 20 | present where obvious needed | tested with screen reader |
| Contrast meets WCAG 2.2 AA | 25 | eyeballed OK | contrast-checked with tool |

## Pass 5 · Maintainability

| Criterion | Weight | 3/5 | 5/5 |
|---|---|---|---|
| Names reveal intent | 20 | mostly clear | reads without comments |
| No dead code left behind | 20 | none obvious | grep-clean |
| Docs updated with the change (P03) | 30 | touched docs updated | + newcomer-audit clean |
| Repeated fuzzy step flagged for hardening (P01) | 15 | none found | + candidate tool proposed |
| P11 minimalism check | 15 | no new vestigial scaffolding | + one prior component identified as removable |

---

## Reporting

Per pass, emit:

```
PASS: <name>
CONTEXT: <fresh-context-id>
SCORE: <weighted total>/5
FINDINGS:
  - severity: <B|C|MJ|MN|clean>
    criterion: <name>
    note: <one line>
```

Report the raw structure; do not summarize away findings.
