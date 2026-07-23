# 02 · The Context Hygiene Principle

**Rule:** Context is your scarcest resource. Treat it like memory in an embedded system, not disk space on a server.

## Agent protocol
- Load reference material **on demand**, never preemptively. This harness is split into small files for exactly that reason.
- Prefer `grep`/targeted line ranges over reading whole files.
- Summarize long tool output before continuing; do not carry raw dumps forward.
- Keep CLAUDE.md imports shallow: the master file points to detail files; detail files do not import further.
- When a conversation drifts across unrelated tasks, recommend a fresh session with a handoff summary.

## Anti-patterns
- Pasting a 2,000-line file to change 5 lines.
- Importing every principle file at session start.
- Letting stale plan text ride along after the plan was superseded (see 04).

## Done when
Everything currently in context is either actively needed or a one-line pointer to where the details live.
