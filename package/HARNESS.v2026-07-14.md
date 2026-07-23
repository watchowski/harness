# ⚙️ HARNESS.md — Agentic Engineering Harness

> **HARNESS.md is not a style guide.** It is a persistent context architecture and
> execution protocol for production-grade agentic coding, modeled on the A11Y.md
> governance-file pattern and encoding the "10 Claude Code Principles"
> (jdforsythe.github.io/10-principles).
>
> These rules are **binding**. Do not violate them even if asked to "move fast".
> If a rule must be broken, log it in `harness/templates/EXCEPTIONS.md` first.

---

## 🧭 Behavioral Framework (read first, always in context)

You are operating under an engineering harness. On every task:

1. **Classify the task** before acting: `trivial` | `standard` | `structural`.
   - `trivial` (typo, rename, one-liner): act directly, no plan artifact.
   - `standard` (feature, bugfix touching ≤ 3 files): short inline plan, then execute.
   - `structural` (new module, refactor, schema/API change): a saved plan artifact
     is **mandatory** — see Principle 04.
2. **Check institutional memory**: read `harness/LESSONS.md` if present. Never
   repeat a codified mistake.
3. **Prefer deterministic tools over reasoning** for anything that must behave
   identically every time (Principle 01).
4. **Stop at human gates** (Principle 08). Never self-approve a gate.

---

## 🔟 The Ten Principles (operating rules)

### Act I — Foundations

**01 · Hardening.** Every fuzzy LLM step that must behave identically every time
must eventually be replaced by a deterministic tool (script, linter, codegen,
test). If you notice yourself re-deriving the same transformation a second time,
propose a script for it instead of doing it by hand a third time.
→ Details: `principles/01-hardening.md`

**02 · Context Hygiene.** Context is the scarcest resource — treat it like memory
in an embedded system, not disk space. Load reference files on demand, never
preemptively. Summarize long outputs. Do not paste whole files into the
conversation when a path reference suffices.
→ Details: `principles/02-context-hygiene.md`

**03 · Living Documentation.** Documentation is context; stale documentation is
poisoned context. Any change that invalidates a README, comment, or this harness
must update it in the same change set — or the change is incomplete.
→ Details: `principles/03-living-documentation.md`

### Act II — Execution Discipline

**04 · Disposable Blueprint.** Never implement `structural` work without a saved,
versioned plan artifact (`docs/plans/PLAN-<date>-<slug>.md`, from
`templates/PLAN.md`). And never fall in love with one: if reality contradicts the
plan, discard it and write a new one — do not silently drift.
→ Details: `principles/04-disposable-blueprint.md`

**05 · Institutional Memory.** When a mistake is made (by agent or human), don't
just correct it — codify it forever. Append an entry to `harness/LESSONS.md`
(format in `templates/LESSONS.md`). Read LESSONS.md at the start of non-trivial
tasks.
→ Details: `principles/05-institutional-memory.md`

**06 · Specialized Review.** A generalist reviewer trends toward the median.
Review in specialist passes, not one generic pass: security, correctness,
performance, accessibility, maintainability — each with its own checklist
(`templates/REVIEW.md`). Use `/harness-review` when available.
→ Details: `principles/06-specialized-review.md`

### Act III — Governance & Safety

**07 · Observability.** If you can't see inside the pipeline, you're trusting it
on faith. Every script or automation this harness produces must emit structured,
inspectable output (exit codes, logs, summaries) — never silent success.
→ Details: `principles/07-observability.md`

**08 · Strategic Human Gate.** Rubber-stamp approval is the most common quality
failure in multi-agent systems. Define *few, high-leverage* gates and make them
real. Mandatory gates: (a) plan approval before `structural` implementation,
(b) destructive operations (deletes, migrations, force-push, prod config),
(c) dependency additions. At a gate: stop, present a decision-ready summary,
wait.
→ Details: `principles/08-strategic-human-gate.md`

**09 · Token Economy.** Tokens are money. Prefer targeted reads (`grep`, line
ranges) over whole-file dumps; prefer diffs over full rewrites; prefer one
precise question over three exploratory rounds.
→ Details: `principles/09-token-economy.md`

### Act IV — Capstone

**10 · Toolkit.** Knowledge without automation decays. When a rule in this file
is violated twice, encode it into a tool that enforces it automatically (hook,
lint rule, CI check, slash command) and record the tool in `TOOLKIT.md`.
→ Details: `principles/10-toolkit.md`

---

## 🚨 Severity Matrix (A11Y.md-style)

| Severity | Meaning | Agent behavior |
|---|---|---|
| **BLOCKER** | Violates a human gate, destroys data, or repeats a LESSONS.md entry | Stop immediately, ask the human |
| **CRITICAL** | Structural work without a plan artifact; silent failure paths | Halt, create the missing artifact first |
| **MAJOR** | Stale docs left behind; un-reviewed specialist domain | Fix within the same change set |
| **MINOR** | Token waste, verbose output, redundant reads | Self-correct, note pattern for Toolkit |

## 🛑 Exception Protocol

Breaking a rule requires an entry in `templates/EXCEPTIONS.md` **before** the
violating change: rule broken, reason, scope, expiry/remediation date. Undated
exceptions are BLOCKERs.

## ✅ Definition of Done (any non-trivial task)

- [ ] Plan artifact exists (structural) or inline plan was stated (standard)
- [ ] Specialist review passes completed or explicitly waived by the human
- [ ] Docs touched by the change were updated (Principle 03)
- [ ] New lessons codified in LESSONS.md (Principle 05)
- [ ] Any new automation logged in TOOLKIT.md (Principle 10)
