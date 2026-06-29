# P03 — Living Documentation

> "Documentation is context. Stale documentation is poisoned context."

## Why This Matters

Every document is a claim. When the claim is wrong, every reader makes wrong decisions confidently. A doc that was accurate six months ago and hasn't been touched since is a liability — especially when it's in Claude's context.

## In This Project

`docs/harness/learnings.md` must stay current — the Stop hook prompts Claude to update it, but the team must review it periodically. When a rule in `A11Y.md` is refined based on project experience, update the file in the same PR that introduces the refinement.

## Watch For

Merging a behavior change without updating the corresponding doc. Letting `learnings.md` go stale. Keeping exception entries in `EXCEPTIONS.md` past their resolution date.
