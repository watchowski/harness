# STEP.md

> Written by the installer. Overwritten if you re-run the installer or run
> `scripts/set-step.sh <N>` / `scripts/set-step.ps1 <N>`.

**Current step:** <not-yet-installed>

**Diagnostic answers:** <not-yet-installed>

**Installed on:** <date>

**Selected tools:** <list>

---

## What this means

Components tagged with a `tier:` higher than the current step number are
present on disk but must not be loaded into active context. See
`steps/step-<N>-*.md` for the activation list at this step.

## Changing step

Re-run the diagnostic or bump manually:

```bash
~/.harness-v3/scripts/set-step.sh 3        # bash
~/.harness-v3/scripts/set-step.ps1 3       # PowerShell
```
