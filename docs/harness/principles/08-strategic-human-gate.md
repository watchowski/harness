# P08 — Strategic Human Gate

> "Rubber-stamp approval is the single most common quality failure in multi-agent systems."

## Why This Matters

Review processes that always approve provide false safety. A developer approving a diff they haven't read is worse than no review — it implies the work was checked when it wasn't. Gates should be positioned where human judgment actually adds value: at ambiguous requirements, at architectural decisions, at PR merge.

## In This Project

Claude flags ambiguous requirements before implementing — not after. The `REPORT.md` checklist is a structured gate that forces a real review, not a "ship it" click.

## Watch For

Prompting Claude with underspecified requirements and accepting the output without reviewing against intent. Merging PRs without reading the diff. Approving a plan in a message without actually evaluating it.
