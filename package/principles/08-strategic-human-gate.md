---
principle: 08
name: Strategic Human Gate
tier: 1+
rev: v3-2026-07-23
supersedes: archive/08-strategic-human-gate.v2026-07-14.md
model-limitation: Absent explicit gates, the agent will take irreversible actions on debatable inputs; with too many gates, humans rubber-stamp.
---

# 08 · The Strategic Human Gate Principle

**Rule:** Rubber-stamp approval is the single most common quality failure in multi-agent systems. Few gates, real gates.

## Mandatory gates (v3 — narrowed to four)

Stop and wait for explicit human approval at:

1. **Structural plan approval** — before implementing a structural task (P04).
2. **Destructive operations** — deletions of non-trivial code/data, migrations, force-push, history rewrites, production configuration.
3. **New external dependencies** — adding or upgrading libraries, changing toolchains.
4. **Production deploy** — any push of code or config to a production environment.

Everything else is pre-approved (via tool-native allowlists like `settings.json`) and runs under auto mode. This makes the harness compatible with Step 2+ where auto mode is required to unblock parallelism.

## Verifier gates for everything else

Non-human, mechanically gradeable checkpoints run under `/harness-review` and per-tool verification hooks. These are P06 verifier contexts, not P08 human gates. They must always run; a failed verifier gate is a BLOCKER regardless of whether a human is watching.

## Agent protocol
- At a human gate, present a **decision-ready summary**: what, why, alternatives considered, blast radius, rollback path. Then stop.
- Never bundle gated and non-gated changes so approval of one smuggles in the other.
- Do not create so many human gates that the human starts rubber-stamping — if a gate is always approved without thought, propose removing it or converting it to a verifier gate.

## Amendment from v2
- v2 listed three mandatory gates. v3 lists four and explicitly names production deploy.
- v2 was silent on auto mode. v3 declares that auto mode with pre-approved allowlists **satisfies** this principle at Step 2+, provided the four gates remain human.

## Anti-patterns
- "I went ahead and also migrated the schema."
- Asking for approval with a wall of text and no recommendation.
- Gating trivia (a formatting choice) while auto-approving structural work.
