# CONTRACT-<slug>-<n>

**Status:** DRAFT | SIGNED | DONE | ABANDONED
**Signed by:** generator <id> on <date>, evaluator <id> on <date>
**Parent plan:** `docs/plans/PLAN-<date>-<slug>.md`
**Chunk of work:** <one-line description>

## 1. Scope of this chunk
What exactly is the generator committing to build in this contract? What is
explicitly deferred to a later chunk?

## 2. Success criteria (weighted)

Fill each criterion with a weight (0–100, sum ≤ 100) and a calibration example.
Weights bias evaluator scoring toward what matters on this chunk — do not
weight everything equally.

| Criterion | Weight | 3/5 looks like | 5/5 looks like |
|---|---|---|---|
| e.g. Correctness on golden path | 30 |  |  |
| e.g. Handles empty-input edge | 15 |  |  |
| e.g. Test coverage of new paths | 25 |  |  |
| e.g. Naming / readability | 10 |  |  |
| e.g. No regressions in <module> | 20 |  |  |

## 3. Out of scope
Anything the evaluator must NOT grade for. Prevents scope creep.

## 4. Verification method
- Automated (tests, lint, typecheck, playwright, curl-and-diff) — list commands
- Manual observation — list what the evaluator will look at
- Fresh-context requirement (P06): confirm evaluator runs in a fresh context

## 5. Definition of done
- All criteria above scored, weighted sum ≥ <threshold>.
- No BLOCKER or CRITICAL findings from any P06 verifier pass.
- Event log (if Step 3+) closes cleanly on this contract.

## 6. Divergence protocol
If during work the generator finds the contract cannot be met as written:
- STOP. Do not silently redefine "done."
- Amend the contract (new revision) and re-sign, or
- Abandon this contract and write a new one, or
- Escalate to the parent plan (may trigger plan supersession per P04).
