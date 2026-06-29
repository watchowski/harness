# P01 — Hardening

> "Every fuzzy LLM step that must behave identically every time must eventually be replaced by a deterministic tool."

## Why This Matters

LLMs are probabilistic. The same prompt can produce different output on different runs. When your workflow depends on consistent, verifiable output — date parsing, JSON transformation, file writing — that dependency is a risk. Tool calls (shell commands, API calls, file operations) are deterministic. They either succeed or they don't, and their output is inspectable.

## In This Project

Claude Code uses tool calls (Bash, Edit, Write, Grep) for every concrete action. The harness hooks are shell scripts with predictable, testable behavior — not prompts asking Claude to "remember to check a11y." That's Principle 10 (Toolkit) applied to Principle 01.

## Watch For

Workflows where Claude is asked to "consistently" produce formatted output — config generation, boilerplate, structured data. These are candidates for deterministic tools.
