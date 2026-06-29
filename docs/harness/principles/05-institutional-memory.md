# P05 — Institutional Memory

> "When an agent makes a mistake, don't just correct it — codify it forever."

## Why This Matters

Corrections that live only in the session transcript are lost when the session ends. The next session — or the next agent — has no access to that history and will make the same mistake. The only correction that matters permanently is one that changes what future agents read.

## In This Project

The Stop hook fires at the end of every Claude turn and asks: did any mistake or unexpected behavior occur? If yes, it should be added to `docs/harness/learnings.md`. That file is part of the persistent context system.

## Watch For

Accepting a corrected output and moving on without asking why the first attempt was wrong. Entries in `learnings.md` that are vague ("Claude got confused about X") rather than actionable ("When X, Claude will Y — prevent this by Z").
