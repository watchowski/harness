# step-diagnostic.ps1 - re-run the 6-question diagnostic and update STEP.md.
$ErrorActionPreference = 'Stop'
$HomeDir = $env:USERPROFILE
$InstallDir = Join-Path $HomeDir '.harness-v3'
$StepFile = Join-Path $InstallDir 'STEP.md'
if (-not (Test-Path $StepFile)) {
    Write-Error "$StepFile not found - run install.ps1 first"
    exit 1
}

Write-Host ""
Write-Host "=== Step diagnostic (6 questions, ~90 seconds) ==="
Write-Host ""

$questions = @(
    @{ Q = "Concurrent agents in a normal session?";
       Opts = @("one at a time", "2-5 in parallel", "~10 with subagents", "hundreds, mostly agent-initiated") },
    @{ Q = "What do you review?";
       Opts = @("every response and edit", "final diffs + evaluator reports", "exceptions and drift signals", "intent and outcomes, not diffs") },
    @{ Q = "How is agent work verified before you see it?";
       Opts = @("I read the output", "auto tests + lint + typecheck run first", "separate verifier context grades it", "full CI + verifier + auto-remediation") },
    @{ Q = "Auto mode / permission prompts?";
       Opts = @("never, I approve each action", "on for most, prompted for structural", "always on with narrow gates", "always on, cost caps govern") },
    @{ Q = "Observability?";
       Opts = @("terminal output only", "dashboard or analytics UI", "OTel export + alerts", "OTel + budget caps + exception dashboards") },
    @{ Q = "Who initiates work?";
       Opts = @("only me", "me + some scheduled routines", "mostly me but the agent proactively starts related tasks", "mostly the agent - I steer by intent") }
)

$scores = @()
$i = 1
foreach ($item in $questions) {
    Write-Host "Q$i. $($item.Q)"
    for ($k=0; $k -lt 4; $k++) { Write-Host ("  {0}) {1}" -f ($k+1), $item.Opts[$k]) }
    while ($true) {
        Write-Host -NoNewline "  answer [1-4]: "
        $a = Read-Host
        if ($a -match '^[1-4]$') { $scores += [int]$a; break }
        Write-Host "  please enter 1, 2, 3, or 4"
    }
    Write-Host ""
    $i++
}

$sorted = $scores | Sort-Object
$median = [Math]::Floor(($sorted[2] + $sorted[3]) / 2)

Write-Host ("Answers: {0}" -f ($scores -join ' '))
Write-Host "Median (floored): $median"
Write-Host ""

Write-Host -NoNewline "Accept step $median? [Y/n]: "
$accept = Read-Host
if (-not [string]::IsNullOrWhiteSpace($accept) -and ($accept.ToLower() -notin @('y','yes'))) {
    Write-Host -NoNewline "Override to which step? [1-4]: "
    $override = Read-Host
    if ($override -notmatch '^[1-4]$') { Write-Error "invalid"; exit 2 }
    $median = [int]$override
}

$content = Get-Content -Raw -Path $StepFile -Encoding UTF8
$content = $content -replace '(?m)^\*\*Current step:\*\* .*$', "**Current step:** $median"
$content = $content -replace '(?m)^\*\*Diagnostic answers:\*\* .*$', ("**Diagnostic answers:** " + ($scores -join ' '))
Set-Content -Path $StepFile -Value $content -Encoding UTF8

Write-Host "STEP.md updated. Current step: $median."
