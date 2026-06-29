# P06 — Specialized Review

> "A generalist reviewer trends toward the median. Specialists find what generalists can't."

## Why This Matters

A prompt like "review this code" produces feedback shaped by average expectations. A focused prompt — "check only for missing aria attributes" — produces deeper, domain-specific findings. The `REPORT.md` checklist is an operationalization of this principle for accessibility.

## In This Project

Before any UI PR merges, Claude completes `REPORT.md` item by item. The pre-commit hook reminds Claude when UI files are staged. This forces a dedicated a11y review pass separate from the general code review.

## Watch For

Skipping `REPORT.md` for "small" UI changes — accessibility regressions often come from small changes (removing a label, swapping a div for a button, tweaking CSS that breaks focus visibility).
