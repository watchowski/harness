# LESSONS.md — Institutional Memory (Principle 05)

> Append-only. Read at the start of every non-trivial task.
> Repeating a codified lesson is a BLOCKER.

## Entry format

### L-<NNN> · <short title>
- **Date:** YYYY-MM-DD
- **Context:** where/how it happened (file, feature, command)
- **Mistake:** what went wrong, in one sentence
- **Correction:** what fixed it
- **Rule going forward:** imperative, testable ("Always X", "Never Y without Z")
- **Promoted to tool?** no | yes → <TOOLKIT.md entry> (Principle 10)
- **Discovered by:** in-band | offline reconciliation (Step 3+, see architecture/memory.md)

---

### L-001 · (example) PowerShell scripts failed under default execution policy
- **Date:** 2026-07-03
- **Context:** install.ps1 on a fresh Windows machine
- **Mistake:** assumed scripts run without `-ExecutionPolicy Bypass`
- **Correction:** documented the bypass invocation in README
- **Rule going forward:** Always show the `powershell -ExecutionPolicy Bypass -File` invocation for any .ps1 handed to users.
- **Promoted to tool?** no
- **Discovered by:** in-band
