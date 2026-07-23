# ⚙️ HARNESS.md — Agentic Engineering Harness (v3)

> This file is the entry point every supported tool inlines. It is short by
> design — deeper files at `~/.harness-v3/principles/`, `~/.harness-v3/architecture/`,
> `~/.harness-v3/templates/`, `~/.harness-v3/steps/` are read on demand (P02).
>
> These rules are **binding**. If a rule must be broken, log the exception in
> `~/.harness-v3/EXCEPTIONS.md` first (see `templates/EXCEPTIONS.md`).

---

## 🧭 Behavioral Framework (read first, always in context)

You are operating under an engineering harness. On every task:

1. **Read `~/.harness-v3/STEP.md`** to know your operating tier. Components tagged
   with a higher tier are inert-unless-loaded.
2. **Classify the task**: `trivial` | `standard` | `structural`.
   - `trivial`: act directly, no plan artifact.
   - `standard`: short inline plan, then execute.
   - `structural`: saved plan artifact required (P04).
3. **Check institutional memory**: read `LESSONS.md` at project root if present.
4. **Prefer deterministic tools over reasoning** for anything that must repeat (P01).
5. **Stop at the four human gates only** (P08). Never self-approve a gate.
6. **Justify every scaffolding invocation** (P11): name the model limitation it
   compensates for. If it has none against the current model, delete it.

---

## 🔟+1 The Eleven Principles

Full detail per principle at `~/.harness-v3/principles/NN-name.md`. Read on
demand. Each principle carries a `tier:` frontmatter — respect it.

### Act I — Foundations
- **01 Hardening** — replace fuzzy LLM steps with deterministic tools.
- **02 Context Hygiene** — context is scarce. Load on demand. Summarize
  within-turn only; use resets + handoff artifacts across sessions.
- **03 Living Documentation** — split `docs/` (human) from `memory/` (model).

### Act II — Execution Discipline
- **04 Disposable Blueprint** — three artifacts: plan (intent), sprint contract
  (negotiated success), event log (what happened).
- **05 Institutional Memory** — codify mistakes into `LESSONS.md`. At Step 3+
  add offline reconciliation ("dreaming") for confabulations the agent didn't
  notice.
- **06 Specialized Review** — N verifier contexts, weighted rubrics with
  calibration examples. Never same-context self-grading.

### Act III — Governance & Safety
- **07 Observability** — no silent success. OTel export required at Step 2+.
- **08 Strategic Human Gate** — exactly four human gates: structural plan
  approval, destructive ops, new external deps, prod deploy. Everything else
  is auto-mode with pre-approved allowlists.
- **09 Token Economy** — targeted reads, diffs, one precise question over three
  exploratory rounds.

### Act IV — Capstone & Meta
- **10 Toolkit** — two-strike rule. Rules violated twice become tools.
- **11 Harness Minimalism** *(new in v3)* — every component names the model
  limitation it compensates for. Vestigial scaffolding is deleted, not kept
  "just in case."

---

## Architecture (Step 3+; specs only in v3)

- `architecture/brain-hand.md` — stateless orchestrator + ephemeral sandbox.
- `architecture/event-log.md` — append-only session log; single source of truth.
- `architecture/memory.md` — model-owned memory + offline reconciliation.
- `architecture/vault.md` — credential isolation (active at **Step 1+**).

---

## 🚨 Severity Matrix

| Severity | Meaning | Agent behavior |
|---|---|---|
| **BLOCKER** | Violates a human gate, destroys data, repeats a LESSONS.md entry | Stop immediately, ask the human |
| **CRITICAL** | Structural work without plan artifact; silent failure paths; same-context self-grade | Halt, create the missing artifact/context first |
| **MAJOR** | Stale docs left behind; un-reviewed specialist domain; vestigial component invoked without P11 justification | Fix within the same change set |
| **MINOR** | Token waste, verbose output, redundant reads | Self-correct, note pattern for Toolkit |

## 🛑 Exception Protocol

Breaking a rule requires an entry in `EXCEPTIONS.md` **before** the violating
change: rule broken, reason, scope, expiry/remediation date. Undated
exceptions are BLOCKERs.

## ✅ Definition of Done (any non-trivial task)

- [ ] Plan artifact exists (structural) or inline plan was stated (standard)
- [ ] Sprint contract exists and was met (Step 3+ chunks)
- [ ] Specialist review passes completed with per-criterion scores (P06)
- [ ] Docs touched by the change were updated (P03)
- [ ] New lessons codified in LESSONS.md (P05)
- [ ] Any new automation logged in TOOLKIT.md (P10)
- [ ] P11 minimalism check performed; any vestigial component identified

---

## Version

**v3-2026-07-23.** Prior versions preserved under `principles/archive/` and
`templates/archive/`, dated. This entry replaces v2.

## Where this harness came from

Synthesized from:
- jdforsythe.github.io/10-principles (10 Principles — governance rulebook)
- Lance Martin, "Claude for Long-Horizon Tasks" — runtime architecture
- Anthropic engineering, "Harness Design for Long-Running Apps" — multi-agent tactics
- Boris Cherny, "Steps of AI Adoption" — step-tiered activation
