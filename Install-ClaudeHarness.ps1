<#
.SYNOPSIS
    Installs a Claude Code "harness" implementing the 10 Principles from
    https://jdforsythe.github.io/10-principles/ as native Claude Code
    mechanisms: CLAUDE.md guidance, PowerShell hooks, specialist subagents,
    and slash commands.

.DESCRIPTION
    The article is a philosophy piece, not a single installable package.
    It references two companion tools (Forge, jig) by the same author;
    jig is explicitly unsupported on Windows and Forge installs via a
    Claude-Code-internal `/plugin add` command, not a shell script. So
    instead of wrapping those, this script hand-builds a lightweight,
    native equivalent using Claude Code's own hook/agent/command system,
    which works the same on Windows as anywhere else.

    Each of the 10 principles maps to a concrete mechanism:
      1. Hardening              -> PreToolUse hook, deterministic deny-list
      2. Context Hygiene        -> CLAUDE.md guidance + Stop-hook reminder in auto mode
      3. Living Documentation   -> CLAUDE.md guidance + docs-reviewer agent + Stop-hook gate in auto mode
      4. Disposable Blueprint   -> /plan command -> .claude/plans/*.md + Stop-hook reminder in auto mode
      5. Institutional Memory   -> /learn command -> .claude/LEARNINGS.md + Stop-hook gate in auto mode
      6. Specialized Review     -> /review command + 3 specialist agents + Stop-hook gate in auto mode
      7. Observability          -> PostToolUse hook -> .claude/logs/tool-use.log
      8. Strategic Human Gate   -> PreToolUse hook, deterministic ask-list
      9. Token Economy          -> CLAUDE.md guidance + Stop-hook reminder in auto mode
      10. Toolkit               -> this script itself (tools, not just prose)

    Principles 1, 7, 8 are hook-enforced unconditionally, regardless of
    Claude Code's permission mode. Principles 2-6, 9, 10 previously relied
    entirely on CLAUDE.md being remembered -- nothing stopped an unattended
    "auto" mode session from silently skipping /review, /learn, or docs
    upkeep. Stop-hook `principles-auto-gate.ps1` closes that gap: when
    permission_mode is auto/bypassPermissions/dontAsk (i.e. no human is
    realistically watching), it blocks the turn once per session if code
    was edited with no specialist review dispatched, and folds reminders
    for the non-mechanically-checkable principles into the same message.
    See CLAUDE.md's "Auto-Mode Guarantee" section for the full rationale.

.PARAMETER Scope
    Global   installs into $env:USERPROFILE\.claude (applies to every project).
    Project  installs into .\.claude and .\CLAUDE.md under -ProjectPath.
    Both     does both.

.PARAMETER ProjectPath
    Root of the project to install into when Scope is Project or Both.
    Defaults to the current directory.

.PARAMETER Force
    Overwrite existing harness template files. Originals are backed up
    alongside with a .bak-<timestamp> suffix first. Without -Force,
    existing files are left untouched and reported as skipped.
    settings.json is always merged (never blindly overwritten) and is
    always backed up before being rewritten, regardless of -Force.

.EXAMPLE
    .\Install-ClaudeHarness.ps1 -Scope Project

.EXAMPLE
    .\Install-ClaudeHarness.ps1 -Scope Global

.EXAMPLE
    .\Install-ClaudeHarness.ps1 -Scope Both -ProjectPath C:\code\my-app -Force
#>

[CmdletBinding()]
param(
    [ValidateSet('Global', 'Project', 'Both')]
    [string]$Scope = 'Project',

    [string]$ProjectPath = (Get-Location).Path,

    [switch]$Force
)

$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

function Write-Section {
    param([string]$Text)
    Write-Host ""
    Write-Host "== $Text ==" -ForegroundColor Cyan
}

function Write-FileUtf8NoBom {
    param([string]$Path, [string]$Content, [switch]$AlwaysWrite)

    $dir = Split-Path -Parent $Path
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }

    if ((Test-Path $Path) -and -not $Force -and -not $AlwaysWrite) {
        Write-Host "  skip (exists): $Path" -ForegroundColor DarkYellow
        return
    }
    if (Test-Path $Path) {
        $backup = "$Path.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item -Path $Path -Destination $backup -Force
        Write-Host "  backed up -> $backup" -ForegroundColor DarkGray
    }
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $enc)
    Write-Host "  wrote: $Path" -ForegroundColor Green
}

function Add-HookEntry {
    param(
        [Parameter(Mandatory)] $SettingsObj,
        [Parameter(Mandatory)] [string]$Event,
        [Parameter(Mandatory)] [string]$Matcher,
        [Parameter(Mandatory)] [hashtable]$HookCommand,
        [Parameter(Mandatory)] [string]$DedupeKey
    )

    if (-not $SettingsObj.PSObject.Properties['hooks']) {
        $SettingsObj | Add-Member -MemberType NoteProperty -Name 'hooks' -Value ([pscustomobject]@{})
    }
    if (-not $SettingsObj.hooks.PSObject.Properties[$Event]) {
        $SettingsObj.hooks | Add-Member -MemberType NoteProperty -Name $Event -Value @()
    }

    $existingArray = @($SettingsObj.hooks.$Event)
    $already = $false
    foreach ($block in $existingArray) {
        foreach ($h in @($block.hooks)) {
            $cmdStr = [string]$h.command + ' ' + (@($h.args) -join ' ')
            if ($cmdStr -like "*$DedupeKey*") { $already = $true }
        }
    }
    if ($already) {
        Write-Host "  hook already registered for $Event (skip)" -ForegroundColor DarkYellow
        return $SettingsObj
    }
    $Script:HookChanged = $true

    $newBlock = [pscustomobject]@{
        matcher = $Matcher
        hooks   = @([pscustomobject]$HookCommand)
    }
    $SettingsObj.hooks.$Event = $existingArray + @($newBlock)
    Write-Host "  registered hook for $Event ($DedupeKey)" -ForegroundColor Green
    return $SettingsObj
}

function Write-SettingsJson {
    param([string]$Path, $SettingsObj)

    $dir = Split-Path -Parent $Path
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    if (Test-Path $Path) {
        $backup = "$Path.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item -Path $Path -Destination $backup -Force
        Write-Host "  backed up -> $backup" -ForegroundColor DarkGray
    }
    $json = $SettingsObj | ConvertTo-Json -Depth 20
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $json, $enc)
    Write-Host "  wrote: $Path" -ForegroundColor Green
}

# ---------------------------------------------------------------------------
# Template content (all static -- no PowerShell interpolation needed inside)
# ---------------------------------------------------------------------------

$claudeMdTemplate = @'
# Claude Code Harness

This project (or user profile) has a harness installed implementing the
10 Principles from https://jdforsythe.github.io/10-principles/. Each
principle below is backed by a concrete mechanism, not just prose --
follow the mechanism, don't just read the description.

## 1. Hardening Principle
Deterministic checks beat fuzzy judgment for irreversible actions.
`.claude/hooks/pre-tool-guard.ps1` runs on every Bash call and hard-denies
a fixed deny-list (force-push to main, `rm -rf /`, recursive drive wipes,
fork bombs) regardless of how the request was phrased. Don't try to argue
around it -- if it fires, the command was actually dangerous; find another way.

## 2. Context Hygiene Principle
Treat the context window as a scarce resource:
- Prefer Grep/Glob over reading whole files when you only need a symbol or pattern.
- Use forks/subagents for open-ended research so raw exploration output
  doesn't bloat the main conversation.
- Don't re-read files you already have current content for.

## 3. Living Documentation Principle
Stale docs poison future context more than no docs. When you change
behavior, interfaces, or conventions, update this file and any relevant
README in the same change -- not as a follow-up. The `docs-reviewer`
agent (see below) checks for this on request.

## 4. Disposable Blueprint Principle
Plans are versioned artifacts, not commitments. Use `/plan <slug>` to
write a dated plan into `.claude/plans/`. Revise or discard plans freely
as understanding improves -- never let a stale plan drive implementation.

## 5. Institutional Memory Principle
Mistakes should cost the team once, not repeatedly. Use `/learn <summary>`
to append an entry to `.claude/LEARNINGS.md` whenever you (or the user)
catch a real mistake, a surprising gotcha, or a non-obvious rule. At the
start of nontrivial work, skim `.claude/LEARNINGS.md` if it exists.

## 6. Specialized Review Principle
A single generalist pass misses category-specific issues. Use `/review`
to dispatch the relevant specialist agent(s) instead of reviewing
everything yourself:
- `code-reviewer` -- correctness, simplification, consistency
- `security-reviewer` -- auth, secrets, input handling, injection, deps
- `docs-reviewer` -- doc/interface drift

In unattended permission modes (see "Auto-Mode Guarantee" below), skipping
`/review` after editing code isn't just a missed best practice -- it's a
condition `.claude/hooks/principles-auto-gate.ps1` will block the turn on.

## 7. Observability Imperative
`.claude/hooks/observability-log.ps1` appends one compact line per tool
call to `.claude/logs/tool-use.log` (timestamp, tool, short summary).
This is for after-the-fact visibility into what an agent actually did --
not for you to optimize around.

## 8. Strategic Human Gate Principle
Some actions are legitimate but high-stakes and must never be rubber-stamped.
`pre-tool-guard.ps1` forces an explicit confirmation prompt (rather than
silent allow) for things like force-pushes, `npm publish`, `terraform apply`,
`kubectl delete`, and deploy commands. Never suggest bypassing this gate
(e.g. `--no-verify`-style workarounds) to make a prompt "go away."

## 9. Token Economy Principle
Tokens are computational currency, not a free resource:
- Summarize instead of pasting large tool output back into the conversation.
- Batch independent tool calls in parallel instead of serial round-trips.
- Close out finished subagents/forks rather than keeping their full
  transcripts live in context.

## 10. Toolkit Principle
These principles are enforced by tools (hooks, agents, commands) installed
by `Install-ClaudeHarness.ps1`, not by hoping the model remembers prose
instructions. If you notice a recurring failure mode this harness doesn't
catch, the fix is to extend a hook/agent/command -- propose that concretely
rather than just trying to "be more careful" next time.

## Auto-Mode Guarantee
Claude Code reports a `permission_mode` on every hook payload: `default`,
`plan`, `acceptEdits`, `auto`, `dontAsk`, or `bypassPermissions`. Hooks fire
identically in every mode -- permission mode only controls whether *tool
prompts* are auto-approved, not whether hooks run. That means:

- **Principles 1, 7, 8** are hook-enforced (`pre-tool-guard.ps1`,
  `observability-log.ps1`) on every single tool call, in every mode,
  with or without a human watching. Nothing new needed here.
- **Principles 3, 5, 6** (docs, learnings, review) previously existed only
  as CLAUDE.md prose plus manually-typed `/plan`, `/learn`, `/review`
  commands -- nothing forced them when unattended. `.claude/hooks/
  principles-auto-gate.ps1` closes that gap: on `Stop`, when
  `permission_mode` is `auto`, `bypassPermissions`, or `dontAsk` (the
  modes where no human is realistically watching every action), it checks
  this session's `.claude/logs/tool-use.log` for a code edit with no
  matching `/review` (or reviewer subagent) dispatch, and if found,
  **blocks the turn once** with a reminder covering docs and learnings
  too. It fires at most once per `session_id` so a Claude that ignores the
  nudge doesn't get stuck in a block loop.
- **Principles 2, 4, 9, 10** (context hygiene, plan discipline, token
  economy, toolkit itself) aren't mechanically checkable -- there's no
  script that can tell "you should have used Grep instead of Read" after
  the fact. The same `principles-auto-gate.ps1` block message restates
  them as required reading alongside the enforced items, so they're at
  least surfaced every gated session instead of relying purely on this
  file being remembered.
- In `default`/`plan`/`acceptEdits` mode the gate stays silent -- a human
  is presumed to be reviewing the work directly, so this file's prose is
  considered sufficient there.
'@

$learningsMdTemplate = @'
# Learnings

Institutional memory ledger (Principle 5: Institutional Memory).
Append entries with `/learn <summary>`. Keep each entry short --
this is a lesson ledger, not a postmortem doc.

<!-- entries below this line -->
'@

$preToolGuardPs1 = @'
# Harness hook: PreToolUse guard (Principles 1 and 8)
# Reads the PreToolUse payload from stdin and either:
#   - hard-denies a fixed list of irreversible/destructive Bash patterns
#   - forces an explicit "ask" gate for legitimate-but-high-stakes patterns
# Anything else falls through with no decision (normal permission flow applies).

$ErrorActionPreference = 'Stop'

$raw = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($raw)) { exit 0 }

try {
    $payload = $raw | ConvertFrom-Json
} catch {
    exit 0
}

$cmd = $payload.tool_input.command
if ([string]::IsNullOrWhiteSpace($cmd)) { exit 0 }

function Emit-Decision {
    param([string]$Decision, [string]$Reason)
    $out = [pscustomobject]@{
        hookSpecificOutput = [pscustomobject]@{
            hookEventName            = 'PreToolUse'
            permissionDecision       = $Decision
            permissionDecisionReason = $Reason
        }
    }
    $out | ConvertTo-Json -Depth 5 | Write-Output
}

# Deterministic deny list: irreversible / destructive regardless of intent or phrasing.
$denyPatterns = @(
    'rm\s+-rf\s+/(\s|$)',
    'Remove-Item\s+.*-Recurse.*-Force.*[A-Za-z]:\\\s*$',
    'git\s+push\s+.*--force\b.*\b(main|master)\b',
    'git\s+reset\s+--hard\s+HEAD~',
    '\bformat\s+[A-Za-z]:',
    ':\(\)\s*\{\s*:\s*\|\s*:\s*&\s*\}\s*;\s*:'   # classic fork bomb
)
foreach ($p in $denyPatterns) {
    if ($cmd -match $p) {
        Emit-Decision -Decision 'deny' `
            -Reason "Harness hardening guard: matched deterministic deny pattern. This class of command is irreversible and is blocked regardless of context. See CLAUDE.md Principle 1."
        exit 0
    }
}

# Ask list: legitimate but high-stakes -- force an explicit human gate instead of silent allow.
$askPatterns = @(
    'git\s+push\b.*--force',
    'npm\s+publish',
    'terraform\s+apply',
    'kubectl\s+delete',
    '\bdeploy\b'
)
foreach ($p in $askPatterns) {
    if ($cmd -match $p) {
        Emit-Decision -Decision 'ask' `
            -Reason "Harness human-gate guard: this command is high-stakes. Confirm explicitly with the user before proceeding. See CLAUDE.md Principle 8."
        exit 0
    }
}

exit 0
'@

$observabilityLogPs1 = @'
# Harness hook: PostToolUse observability log (Principle 7)
# Appends one compact line per tool call to .claude/logs/tool-use.log
# under the project the tool call actually ran in (from the payload's cwd),
# so this works the same whether the harness is installed globally or per-project.

$ErrorActionPreference = 'Stop'

$raw = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($raw)) { exit 0 }

try {
    $payload = $raw | ConvertFrom-Json
} catch {
    exit 0
}

$cwd = $payload.cwd
if ([string]::IsNullOrWhiteSpace($cwd)) { exit 0 }

$logDir = Join-Path $cwd '.claude\logs'
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Force -Path $logDir | Out-Null }
$logPath = Join-Path $logDir 'tool-use.log'

$summary = $null
if ($payload.tool_input) {
    if ($payload.tool_input.command) { $summary = [string]$payload.tool_input.command }
    elseif ($payload.tool_input.file_path) { $summary = [string]$payload.tool_input.file_path }
    elseif ($payload.tool_input.notebook_path) { $summary = [string]$payload.tool_input.notebook_path }
    elseif ($payload.tool_input.description) { $summary = [string]$payload.tool_input.description }
}
if ($summary -and $summary.Length -gt 200) { $summary = $summary.Substring(0, 200) + '...' }

# Captured separately from summary so the Stop-hook auto-mode gate (Principle 6)
# can tell *which* skill or subagent ran (e.g. "review", "code-reviewer") without
# having to re-parse tool_input itself.
$extra = $null
if ($payload.tool_input) {
    if ($payload.tool_input.skill) { $extra = [string]$payload.tool_input.skill }
    elseif ($payload.tool_input.subagent_type) { $extra = [string]$payload.tool_input.subagent_type }
}

$line = [pscustomobject]@{
    ts      = (Get-Date).ToString('o')
    session = $payload.session_id
    tool    = $payload.tool_name
    summary = $summary
    extra   = $extra
} | ConvertTo-Json -Compress

Add-Content -Path $logPath -Value $line -Encoding UTF8
exit 0
'@

$principlesAutoGatePs1 = @'
# Harness hook: Stop-event auto-mode principles gate (Principles 2, 3, 4, 5, 6, 9, 10)
#
# Problem this closes: PreToolUse/PostToolUse hooks already enforce Principles
# 1, 7, 8 regardless of permission mode. But Principles 2-6, 9, 10 only exist
# as CLAUDE.md prose and manually-typed slash commands -- nothing stops an
# unattended auto-mode session from just never running /review, /learn, or
# touching docs. This hook is the mechanical backstop for that gap.
#
# Only activates when Claude Code reports an unattended-style permission_mode
# (auto / bypassPermissions / dontAsk) -- in default/plan/acceptEdits a human
# is presumed to be watching, so we don't add friction there.
#
# Detection is heuristic and deliberately narrow to avoid false positives:
# it only fires when this session actually edited a non-doc file AND never
# dispatched a review skill/subagent. Principles 3 and 5 (docs, learnings)
# can't be verified mechanically -- they ride along as required reading in
# the same block message instead of being separately (unreliably) detected.
# Principles 2, 4, 9, 10 are pure judgment calls; they're restated as a
# reminder in the same message rather than gated on their own.
#
# Fires at most once per session_id (state file) so a Claude that ignores
# the nudge and stops again doesn't get blocked forever.

$ErrorActionPreference = 'Stop'

$raw = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($raw)) { exit 0 }

try {
    $payload = $raw | ConvertFrom-Json
} catch {
    exit 0
}

$cwd = $payload.cwd
if ([string]::IsNullOrWhiteSpace($cwd)) { exit 0 }

$sessionId = $payload.session_id
if ([string]::IsNullOrWhiteSpace($sessionId)) { exit 0 }

$autoModes = @('auto', 'bypassPermissions', 'dontAsk')
if ($autoModes -notcontains $payload.permission_mode) { exit 0 }

$logPath = Join-Path $cwd '.claude\logs\tool-use.log'
if (-not (Test-Path $logPath)) { exit 0 }

$codeEditTools = @('Edit', 'Write', 'MultiEdit', 'NotebookEdit')
$codeEdited = $false
$reviewRan = $false

foreach ($rawLine in Get-Content -Path $logPath -ErrorAction SilentlyContinue) {
    if ($codeEdited -and $reviewRan) { break }
    if ([string]::IsNullOrWhiteSpace($rawLine)) { continue }
    try {
        $entry = $rawLine | ConvertFrom-Json
    } catch {
        continue
    }
    if ($entry.session -ne $sessionId) { continue }

    if ($codeEditTools -contains $entry.tool -and $entry.summary -and ($entry.summary -notmatch '\.md$')) {
        $codeEdited = $true
    }
    # 'Skill'/'review' covers the model dispatching /review via the Skill tool;
    # 'Agent'/<reviewer> covers dispatching a reviewer subagent directly. Either
    # satisfies Principle 6 -- the Agent branch is the one actually exercised
    # in practice, since not every Claude Code build routes /review through Skill.
    if ($entry.tool -eq 'Skill' -and $entry.extra -eq 'review') {
        $reviewRan = $true
    }
    if ($entry.tool -eq 'Agent' -and $entry.extra -match 'code-reviewer|security-reviewer|docs-reviewer') {
        $reviewRan = $true
    }
}

if (-not $codeEdited) { exit 0 }
if ($reviewRan) { exit 0 }

$stateDir = Join-Path $cwd '.claude\logs\.principles-gate'
$stateFile = Join-Path $stateDir "$sessionId.json"
if (Test-Path $stateFile) { exit 0 }

$reason = @"
Harness auto-mode gate (permission_mode=$($payload.permission_mode)): this session edited code with no human watching, and no specialist review was dispatched. Before ending the turn:
1) Run /review (Principle 6) against the files you changed.
2) Check whether CLAUDE.md/README still describe current behavior -- update them now if you changed an interface or convention (Principle 3).
3) If you hit a non-obvious gotcha or mistake this session, run /learn to record it (Principle 5).
Also while finishing up: prefer Grep/Glob over full-file reads and close out subagents you no longer need (Principle 2); don't let a stale /plan silently drive further work (Principle 4); batch independent tool calls and summarize large output instead of pasting it (Principle 9); if this gate itself missed something, extend the harness rather than just being more careful next time (Principle 10).
This nudge fires once per session in unattended permission modes -- see CLAUDE.md.
"@

# Emit the decision before writing the one-shot marker: if anything below the
# Write-Output were to throw, we'd rather risk a duplicate nudge next Stop
# than silently burn the session's only nudge without ever delivering it.
[pscustomobject]@{ decision = 'block'; reason = $reason } | ConvertTo-Json -Depth 5 -Compress | Write-Output

try {
    if (-not (Test-Path $stateDir)) { New-Item -ItemType Directory -Force -Path $stateDir | Out-Null }
    [pscustomobject]@{ ts = (Get-Date).ToString('o'); permission_mode = $payload.permission_mode } |
        ConvertTo-Json -Compress | Set-Content -Path $stateFile -Encoding UTF8
} catch {
    # Fail open: worst case the gate nudges again next Stop for this session.
}
exit 0
'@

$sessionStartBriefPs1 = @'
# Harness hook: SessionStart brief (Principles 2, 3, 5)
# Surfaces a one-line reminder of open plans / recorded learnings so
# institutional memory actually gets read instead of silently accumulating.

$ErrorActionPreference = 'Stop'

$raw = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($raw)) { exit 0 }

try {
    $payload = $raw | ConvertFrom-Json
} catch {
    exit 0
}

$cwd = $payload.cwd
if ([string]::IsNullOrWhiteSpace($cwd)) { exit 0 }

$plansDir = Join-Path $cwd '.claude\plans'
$learningsPath = Join-Path $cwd '.claude\LEARNINGS.md'

$planCount = 0
if (Test-Path $plansDir) {
    $planCount = @(Get-ChildItem -Path $plansDir -Filter '*.md' -File -ErrorAction SilentlyContinue).Count
}

$learningCount = 0
if (Test-Path $learningsPath) {
    $learningCount = @(Select-String -Path $learningsPath -Pattern '^## ' -ErrorAction SilentlyContinue).Count
}

if ($planCount -gt 0 -or $learningCount -gt 0) {
    $msg = "Harness: $planCount open plan(s) in .claude/plans, $learningCount entr(y/ies) in .claude/LEARNINGS.md -- worth a skim before starting."
    $out = [pscustomobject]@{ systemMessage = $msg }
    $out | ConvertTo-Json -Depth 3 | Write-Output
}

exit 0
'@

$codeReviewerAgent = @'
---
name: code-reviewer
description: Reviews code changes for correctness, simplification, and consistency. Use after non-trivial edits, before considering work done.
tools: Read, Grep, Glob, Bash
model: inherit
---

You are a specialist code reviewer (Principle 6: Specialized Review).
Scope: correctness bugs, unnecessary complexity, inconsistency with
surrounding code, dead code, missing edge cases. You are read-only --
report findings, do not edit files. Be specific: file, line, concrete
failure scenario. Skip style nits that a formatter would catch.
'@

$securityReviewerAgent = @'
---
name: security-reviewer
description: Reviews changes touching auth, secrets, input handling, network/file/exec calls, or dependencies for security issues. Use when a diff touches any of those areas.
tools: Read, Grep, Glob, Bash
model: inherit
---

You are a specialist security reviewer (Principle 6: Specialized Review).
Scope: injection (SQL/command/template), auth/session handling, secret
handling and storage, unsafe deserialization, path traversal, SSRF,
dependency risk, and OWASP Top 10 classes generally. You are read-only --
report findings, do not edit files. For each finding give the concrete
exploit scenario, not just "this could be unsafe."
'@

$docsReviewerAgent = @'
---
name: docs-reviewer
description: Checks whether documentation (CLAUDE.md, README, doc comments) still matches the code after a change. Use when public interfaces, conventions, or setup steps changed.
tools: Read, Grep, Glob
model: inherit
---

You are a specialist documentation reviewer (Principle 3: Living
Documentation). Scope: does CLAUDE.md / README / doc comments still
accurately describe current behavior, setup, and conventions after the
change under review? Flag drift, not missing docs for things that were
never documented. You are read-only -- report findings, do not edit files.
'@

$planCommand = @'
---
description: Write a new disposable-blueprint plan file (Principle 4)
argument-hint: <slug-describing-the-task>
---

Follow the Disposable Blueprint Principle from CLAUDE.md.

1. Ensure `.claude/plans/` exists in the project root; create it if missing.
2. Determine today's date (YYYY-MM-DD).
3. Write a new file `.claude/plans/<date>-$ARGUMENTS.md` containing:
   - A one-line note at the top: "Disposable blueprint -- supersede or
     delete once the work is done or the approach changes. Not a contract."
   - Goal (one paragraph)
   - Approach (numbered steps)
   - Open questions / risks
4. Show the plan to the user for feedback before starting implementation,
   unless they've already approved a specific approach in this conversation.
'@

$learnCommand = @'
---
description: Record a lesson learned into institutional memory (Principle 5)
argument-hint: <short summary of the mistake or insight>
---

Follow the Institutional Memory Principle from CLAUDE.md.

1. Ensure `.claude/LEARNINGS.md` exists in the project root; create it with
   a one-line header if missing.
2. Append a new entry at the end in this format:

   ## <YYYY-MM-DD> -- <short title>
   **What happened:** ...
   **Root cause:** ...
   **Rule going forward:** ...

3. Base the entry on $ARGUMENTS, and on the mistake/insight just discussed
   in this conversation if $ARGUMENTS is brief or absent.
4. Keep it to a few lines -- this is a lesson ledger, not a postmortem.
'@

$reviewCommand = @'
---
description: Dispatch specialist reviewer subagents for the current changes (Principle 6)
argument-hint: [optional: which reviewers to run, e.g. "security,code"]
---

Follow the Specialized Review Principle from CLAUDE.md: use specialist
reviewers instead of one generalist pass.

1. Identify the pending changes (diff / recently edited files).
2. Decide which specialist agents apply:
   - `code-reviewer` -- any code change
   - `security-reviewer` -- auth, secrets, input handling, dependencies,
     network/file/exec calls
   - `docs-reviewer` -- CLAUDE.md/README touched, or public interfaces
     changed without doc updates
3. If $ARGUMENTS names specific reviewers, use only those.
4. Launch the applicable agent(s), each scoped to only the relevant
   files/diff.
5. Synthesize their findings into one summary; do not just relay them
   verbatim.
'@

$gitignoreTemplate = @'
# Harness-generated, disposable by design (Principles 4 and 7)
logs/
plans/
'@

# ---------------------------------------------------------------------------
# Per-scope install
# ---------------------------------------------------------------------------

function Install-HarnessScope {
    param(
        [Parameter(Mandatory)] [string]$ClaudeDir,   # e.g. ~\.claude  or  <project>\.claude
        [Parameter(Mandatory)] [string]$ClaudeMdPath, # where CLAUDE.md itself lives
        [Parameter(Mandatory)] [bool]$IsProject
    )

    Write-Section "Installing into $ClaudeDir"

    foreach ($sub in @('hooks', 'agents', 'commands', 'plans', 'logs')) {
        $p = Join-Path $ClaudeDir $sub
        if (-not (Test-Path $p)) {
            New-Item -ItemType Directory -Force -Path $p | Out-Null
            Write-Host "  created dir: $p" -ForegroundColor Green
        }
    }

    Write-FileUtf8NoBom -Path $ClaudeMdPath -Content $claudeMdTemplate
    Write-FileUtf8NoBom -Path (Join-Path $ClaudeDir 'LEARNINGS.md') -Content $learningsMdTemplate

    Write-FileUtf8NoBom -Path (Join-Path $ClaudeDir 'hooks\pre-tool-guard.ps1') -Content $preToolGuardPs1
    Write-FileUtf8NoBom -Path (Join-Path $ClaudeDir 'hooks\observability-log.ps1') -Content $observabilityLogPs1
    Write-FileUtf8NoBom -Path (Join-Path $ClaudeDir 'hooks\session-start-brief.ps1') -Content $sessionStartBriefPs1
    Write-FileUtf8NoBom -Path (Join-Path $ClaudeDir 'hooks\principles-auto-gate.ps1') -Content $principlesAutoGatePs1

    Write-FileUtf8NoBom -Path (Join-Path $ClaudeDir 'agents\code-reviewer.md') -Content $codeReviewerAgent
    Write-FileUtf8NoBom -Path (Join-Path $ClaudeDir 'agents\security-reviewer.md') -Content $securityReviewerAgent
    Write-FileUtf8NoBom -Path (Join-Path $ClaudeDir 'agents\docs-reviewer.md') -Content $docsReviewerAgent

    Write-FileUtf8NoBom -Path (Join-Path $ClaudeDir 'commands\plan.md') -Content $planCommand
    Write-FileUtf8NoBom -Path (Join-Path $ClaudeDir 'commands\learn.md') -Content $learnCommand
    Write-FileUtf8NoBom -Path (Join-Path $ClaudeDir 'commands\review.md') -Content $reviewCommand

    if ($IsProject) {
        Write-FileUtf8NoBom -Path (Join-Path $ClaudeDir '.gitignore') -Content $gitignoreTemplate
    }

    # --- settings.json hook registration -----------------------------------
    $settingsPath = Join-Path $ClaudeDir 'settings.json'
    $Script:HookChanged = $false
    if (Test-Path $settingsPath) {
        $raw = Get-Content -Raw -Path $settingsPath
        if ([string]::IsNullOrWhiteSpace($raw)) {
            $settings = [pscustomobject]@{}
            $Script:HookChanged = $true
        } else {
            try {
                $settings = $raw | ConvertFrom-Json
            } catch {
                throw "Existing settings.json at $settingsPath is not valid JSON -- aborting to avoid corrupting it. Fix or remove it and re-run."
            }
        }
    } else {
        $settings = [pscustomobject]@{}
        $Script:HookChanged = $true
    }

    if ($IsProject) {
        $preToolPath   = '${CLAUDE_PROJECT_DIR}\.claude\hooks\pre-tool-guard.ps1'
        $postToolPath  = '${CLAUDE_PROJECT_DIR}\.claude\hooks\observability-log.ps1'
        $sessionPath   = '${CLAUDE_PROJECT_DIR}\.claude\hooks\session-start-brief.ps1'
        $stopPath      = '${CLAUDE_PROJECT_DIR}\.claude\hooks\principles-auto-gate.ps1'
    } else {
        $preToolPath   = Join-Path $ClaudeDir 'hooks\pre-tool-guard.ps1'
        $postToolPath  = Join-Path $ClaudeDir 'hooks\observability-log.ps1'
        $sessionPath   = Join-Path $ClaudeDir 'hooks\session-start-brief.ps1'
        $stopPath      = Join-Path $ClaudeDir 'hooks\principles-auto-gate.ps1'
    }

    $psArgs = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File')

    $preToolHookCmd = @{
        type    = 'command'
        command = 'powershell.exe'
        args    = $psArgs + @($preToolPath)
        timeout = 10
    }
    $postToolHookCmd = @{
        type    = 'command'
        command = 'powershell.exe'
        args    = $psArgs + @($postToolPath)
        timeout = 10
    }
    $sessionHookCmd = @{
        type    = 'command'
        command = 'powershell.exe'
        args    = $psArgs + @($sessionPath)
        timeout = 10
    }
    $stopHookCmd = @{
        type    = 'command'
        command = 'powershell.exe'
        args    = $psArgs + @($stopPath)
        timeout = 10
    }

    $settings = Add-HookEntry -SettingsObj $settings -Event 'PreToolUse'   -Matcher 'Bash' -HookCommand $preToolHookCmd  -DedupeKey 'pre-tool-guard.ps1'
    $settings = Add-HookEntry -SettingsObj $settings -Event 'PostToolUse'  -Matcher '*'    -HookCommand $postToolHookCmd -DedupeKey 'observability-log.ps1'
    $settings = Add-HookEntry -SettingsObj $settings -Event 'SessionStart' -Matcher '*'    -HookCommand $sessionHookCmd  -DedupeKey 'session-start-brief.ps1'
    $settings = Add-HookEntry -SettingsObj $settings -Event 'Stop'         -Matcher '*'    -HookCommand $stopHookCmd     -DedupeKey 'principles-auto-gate.ps1'

    if ($Script:HookChanged) {
        Write-SettingsJson -Path $settingsPath -SettingsObj $settings
    } else {
        Write-Host "  settings.json already up to date (skip)" -ForegroundColor DarkYellow
    }
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

Write-Host "Claude Code Harness Installer" -ForegroundColor Magenta
Write-Host "Scope: $Scope" -ForegroundColor Magenta

if ($Scope -eq 'Global' -or $Scope -eq 'Both') {
    $globalDir = Join-Path $env:USERPROFILE '.claude'
    if (-not (Test-Path $globalDir)) {
        throw "Global Claude directory not found at $globalDir -- run Claude Code at least once first."
    }
    Install-HarnessScope -ClaudeDir $globalDir -ClaudeMdPath (Join-Path $globalDir 'CLAUDE.md') -IsProject $false
}

if ($Scope -eq 'Project' -or $Scope -eq 'Both') {
    if (-not (Test-Path $ProjectPath)) {
        throw "ProjectPath not found: $ProjectPath"
    }
    $ProjectPath = (Resolve-Path $ProjectPath).Path
    $projectClaudeDir = Join-Path $ProjectPath '.claude'
    Install-HarnessScope -ClaudeDir $projectClaudeDir -ClaudeMdPath (Join-Path $ProjectPath 'CLAUDE.md') -IsProject $true
}

Write-Section "Done"
Write-Host "Restart Claude Code (or start a new session) for hooks and commands to take effect." -ForegroundColor White
