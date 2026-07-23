---
step: 1
name: Assisted
agent-count: ~1
role: pair programmer
rev: v3-2026-07-23
---

# Step 1 — Assisted

**You + one agent, mostly supervised.** You run one session at a time and review nearly every change.

## Active components

| Component | Notes |
|---|---|
| 10 Principles (amended) | All active |
| P11 Harness Minimalism | Active — most likely to flag components as vestigial at this step |
| Plan artifact (P04) | Required for structural work |
| Human at every meaningful action | Yes — this is the differentiator vs. Step 2 |
| Credential vault | Active (see `architecture/vault.md`) |

## Inert (present but not loaded)

- Sprint contract, event log, memory + dreaming, org identity — all Step 3+ or Step 4-only.
- Auto mode is off or approve-per-action.
- OTel is optional (single user; terminal output usually suffices).

## Bottleneck at this step

**Your attention.** The trap is that low trust in model output makes you inspect every response — you never look away, so parallelism never begins.

## How to know you're ready for Step 2

- You trust a self-verification loop: tests + build + lint + smoke test run automatically and their pass is meaningful.
- You want auto mode on for common safe operations, gates only on the four P08 mandatory ones.
- Reviewing keystroke-by-keystroke has started to feel wasteful.

## Products that match this step (Claude ecosystem)

- Claude Code in Desktop, CLI, or IDE.
- Plan mode.
- Per-seat spend caps and centrally managed policy.
- Claude Cowork, Claude Design.
