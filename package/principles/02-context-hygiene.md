---
principle: 02
name: Context Hygiene
tier: 1+
rev: v3-2026-07-23
supersedes: archive/02-context-hygiene.v2026-07-14.md
model-limitation: Context bloat causes model to lose salient facts and drift toward premature wrap-up.
---

# 02 · The Context Hygiene Principle

**Rule:** Context is your scarcest resource. Treat it like memory in an embedded system, not disk space on a server.

## Agent protocol
- Load reference material **on demand**, never preemptively. This harness is split into small files for exactly that reason.
- Prefer `grep`/targeted line ranges over reading whole files.
- **Summarize long *tool output* within a turn** — do not carry raw dumps forward into the next turn.
- **Do not compact conversation state in-place.** When a session's context approaches its ceiling, prefer a **context reset with a handoff artifact** (see P04 — the plan or sprint contract *is* the handoff) over destructive in-place summarization. In-place compaction produces "context anxiety": the model begins wrapping up prematurely as it senses limits approaching.
- Keep instruction-file imports shallow: the master file points to detail files; detail files do not import further.
- When a conversation drifts across unrelated tasks, recommend a fresh session with a handoff summary.

## Amendment from v2
- v2 said "summarize long outputs." v3 scopes that to **within-turn tool output only**. Cross-session state uses reset + handoff artifact, not compaction. Rationale: Anthropic's harness-design work documents context anxiety as a real failure mode of in-place summarization.

## Anti-patterns
- Pasting a 2,000-line file to change 5 lines.
- Importing every principle file at session start.
- Letting stale plan text ride along after the plan was superseded (see P04).
- Compacting mid-task instead of resetting with a handoff artifact.

## Done when
Everything currently in context is either actively needed or a one-line pointer to where the details live.
