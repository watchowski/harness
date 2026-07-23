# install.ps1 - Harness v3 installer (Windows PowerShell)
# Works on PowerShell 5.1+ and 7+.
# No external dependencies.

[CmdletBinding()]
param(
    [string]$Tools = "",
    [ValidateRange(1,4)] [int]$Step = 0,
    [switch]$Yes
)

$ErrorActionPreference = 'Stop'

# -------- Paths --------
$ScriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$PackageDir  = Join-Path $ScriptDir 'package'
$HomeDir     = $env:USERPROFILE
$InstallDir  = Join-Path $HomeDir '.harness-v3'
$Timestamp   = Get-Date -Format 'yyyyMMdd-HHmmss'
$BackupDir   = Join-Path $HomeDir ".harness-v3.bak.$Timestamp"

$ClaudeFile      = Join-Path $HomeDir '.claude\CLAUDE.md'
$CodexFile       = Join-Path $HomeDir '.codex\AGENTS.md'
$AntigravityFile = Join-Path $HomeDir '.gemini\GEMINI.md'
$OpenCodeFile    = Join-Path $HomeDir '.config\opencode\AGENTS.md'

$BeginMarker  = '<!-- harness-v3:begin -->'
$EndMarker    = '<!-- harness-v3:end -->'
$LegacyBegin  = '<!-- claude-harness:begin -->'
$LegacyEnd    = '<!-- claude-harness:end -->'

# -------- Helpers --------
function Get-ToolFile {
    param([string]$Name)
    switch ($Name) {
        'claude'      { return $ClaudeFile }
        'codex'       { return $CodexFile }
        'antigravity' { return $AntigravityFile }
        'opencode'    { return $OpenCodeFile }
        default       { throw "unknown tool: $Name" }
    }
}

function Detect-Tools {
    $found = @()
    if (Test-Path (Join-Path $HomeDir '.claude'))          { $found += 'claude' }
    if (Test-Path (Join-Path $HomeDir '.codex'))           { $found += 'codex' }
    if (Test-Path (Join-Path $HomeDir '.gemini'))          { $found += 'antigravity' }
    if (Test-Path (Join-Path $HomeDir '.config\opencode')) { $found += 'opencode' }
    return $found
}

function Backup-File {
    param([string]$Src)
    if (-not (Test-Path $Src)) { return }
    $rel = $Src.Substring($HomeDir.Length).TrimStart('\','/')
    $dst = Join-Path $BackupDir "tool-files\$rel"
    $dstDir = Split-Path -Parent $dst
    if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Force -Path $dstDir | Out-Null }
    Copy-Item $Src $dst -Force
}

function Remove-MarkerBlock {
    param([string]$File, [string]$Begin, [string]$End)
    if (-not (Test-Path $File)) { return }
    $lines = Get-Content -Raw -Path $File -Encoding UTF8
    if ([string]::IsNullOrEmpty($lines)) { return }
    $arr = $lines -split "`r?`n"
    $out = New-Object System.Collections.Generic.List[string]
    $skip = $false
    foreach ($line in $arr) {
        if ($line.Contains($Begin)) { $skip = $true; continue }
        if ($line.Contains($End))   { $skip = $false; continue }
        if (-not $skip) { $out.Add($line) }
    }
    # rejoin without trailing empties
    $joined = ($out -join "`r`n").TrimEnd()
    Set-Content -Path $File -Value $joined -Encoding UTF8
}

function Write-Block {
    param([string]$File)
    $dir = Split-Path -Parent $File
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    Remove-MarkerBlock -File $File -Begin $BeginMarker -End $EndMarker
    Remove-MarkerBlock -File $File -Begin $LegacyBegin -End $LegacyEnd

    $existing = ''
    if (Test-Path $File) { $existing = (Get-Content -Raw -Path $File -Encoding UTF8).TrimEnd() }

    $harness = Get-Content -Raw -Path (Join-Path $InstallDir 'HARNESS.md') -Encoding UTF8

    $block = @"
$BeginMarker
# Engineering Harness v3 (auto-installed - do not edit between markers)
# Full harness at: $InstallDir

$harness

$EndMarker
"@

    if ($existing.Length -gt 0) {
        $final = $existing + "`r`n`r`n" + $block
    } else {
        $final = $block
    }
    Set-Content -Path $File -Value $final -Encoding UTF8
}

function Confirm-Yes {
    param([string]$Prompt, [string]$Default = 'y')
    if ($Yes) { return ($Default -eq 'y') }
    Write-Host -NoNewline "$Prompt "
    $r = Read-Host
    if ([string]::IsNullOrWhiteSpace($r)) { $r = $Default }
    return ($r.ToLower() -in @('y','yes'))
}

# -------- Step diagnostic --------
function Run-Diagnostic {
    Write-Host ""
    Write-Host "=== Step diagnostic (6 questions, ~90 seconds) ==="
    Write-Host "Choose the number that best matches your current practice."
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
        for ($k=0; $k -lt 4; $k++) {
            Write-Host ("  {0}) {1}" -f ($k+1), $item.Opts[$k])
        }
        while ($true) {
            Write-Host -NoNewline "  answer [1-4]: "
            $a = Read-Host
            if ($a -match '^[1-4]$') { $scores += [int]$a; break }
            Write-Host "  please enter 1, 2, 3, or 4"
        }
        Write-Host ""
        $i++
    }

    # median of 6 = average of sorted[2] and sorted[3], floored
    $sorted = $scores | Sort-Object
    $median = [Math]::Floor(($sorted[2] + $sorted[3]) / 2)

    Write-Host "=== Diagnostic complete ==="
    Write-Host ("Answers: {0}" -f ($scores -join ' '))
    Write-Host "Median (floored): $median"
    Write-Host ""

    return @{ Step = $median; Answers = ($scores -join ' ') }
}

# -------- Main --------
Write-Host "Harness v3 installer"
Write-Host "===================="

if (-not (Test-Path $PackageDir)) { Write-Error "package/ not found at $PackageDir"; exit 1 }
if (-not (Test-Path (Join-Path $PackageDir 'HARNESS.md'))) { Write-Error "package\HARNESS.md missing"; exit 1 }

# Detect tools.
Write-Host ""
Write-Host "Detecting installed tools..."
$detected = Detect-Tools
if ($detected.Count -eq 0) {
    Write-Host "  (no supported tools detected)"
    Write-Host "  Supported: claude, codex, antigravity, opencode"
} else {
    Write-Host ("  Found: {0}" -f ($detected -join ', '))
}

# Choose tools.
if ($Tools -ne '') {
    $selected = $Tools -split ','
} elseif ($detected.Count -eq 0) {
    Write-Host ""
    Write-Host "No tools auto-detected. Enter comma-separated tool names to install for anyway,"
    Write-Host "or press Enter to abort: (choices: claude,codex,antigravity,opencode)"
    if ($Yes) { exit 0 }
    Write-Host -NoNewline "  tools: "
    $line = Read-Host
    if ([string]::IsNullOrWhiteSpace($line)) { Write-Host "aborting."; exit 0 }
    $selected = $line -split ','
} else {
    if (Confirm-Yes "Install for all detected tools? [Y/n]:" 'y') {
        $selected = $detected
    } else {
        Write-Host -NoNewline "Enter comma-separated tool names: "
        $line = Read-Host
        $selected = $line -split ','
    }
}

$selected = $selected | ForEach-Object { $_.Trim().ToLower() } | Where-Object { $_ -ne '' }
Write-Host ""
Write-Host ("Selected: {0}" -f ($selected -join ', '))

# Diagnostic.
if ($Step -gt 0) {
    $chosenStep = $Step
    $answers = "(skipped via -Step)"
} else {
    $d = Run-Diagnostic
    $chosenStep = $d.Step
    $answers = $d.Answers
}

# Confirm.
Write-Host "Will install to: $InstallDir"
Write-Host "Backup dir:      $BackupDir"
Write-Host "Step:            $chosenStep"
Write-Host ("Tools:           {0}" -f ($selected -join ', '))
Write-Host ""
if (-not (Confirm-Yes "Proceed? [Y/n]:" 'y')) { Write-Host "aborted."; exit 0 }

# Backup prior install.
New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
if (Test-Path $InstallDir) {
    Write-Host "Backing up existing $InstallDir..."
    Move-Item $InstallDir (Join-Path $BackupDir "harness-v3.previous")
}

# Backup prior tool files. Also record which files were created fresh so
# rollback can delete them.
New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
$CreatedList = Join-Path $BackupDir 'created-fresh.txt'
Set-Content -Path $CreatedList -Value '' -Encoding UTF8
Write-Host "Backing up tool config files..."
foreach ($t in $selected) {
    $f = Get-ToolFile -Name $t
    if (Test-Path $f) {
        Backup-File -Src $f
    } else {
        Add-Content -Path $CreatedList -Value $f -Encoding UTF8
    }
}

# Back up legacy Claude harness dir if present.
$legacyClaude = Join-Path $HomeDir '.claude\harness'
if (Test-Path $legacyClaude) {
    Write-Host "Backing up legacy ~/.claude/harness/ ..."
    Copy-Item $legacyClaude (Join-Path $BackupDir 'claude-harness.legacy') -Recurse -Force
}

# Copy package.
Write-Host "Copying package to $InstallDir..."
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
Copy-Item (Join-Path $PackageDir '*') $InstallDir -Recurse -Force

# Copy scripts.
$scriptsDst = Join-Path $InstallDir 'scripts'
if (-not (Test-Path $scriptsDst)) { New-Item -ItemType Directory -Force -Path $scriptsDst | Out-Null }
$scriptsSrc = Join-Path $ScriptDir 'scripts'
if (Test-Path $scriptsSrc) {
    Copy-Item (Join-Path $scriptsSrc '*') $scriptsDst -Force -ErrorAction SilentlyContinue
}

# Write STEP.md.
$stepMd = @"
# STEP.md

**Current step:** $chosenStep

**Diagnostic answers:** $answers

**Installed on:** $(Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ')

**Selected tools:** $($selected -join ', ')

**See:** ``steps/step-$chosenStep-*.md`` for the activation list at this step.

## Changing step

``````powershell
& "$InstallDir\scripts\set-step.ps1" <1|2|3|4>
``````

Or re-run the diagnostic:

``````powershell
& "$InstallDir\scripts\step-diagnostic.ps1"
``````
"@
Set-Content -Path (Join-Path $InstallDir 'STEP.md') -Value $stepMd -Encoding UTF8

# Wire tools.
Write-Host "Wiring tools..."
foreach ($t in $selected) {
    $f = Get-ToolFile -Name $t
    Write-Host "  $t -> $f"
    Write-Block -File $f
}

# Write rollback scripts into backup dir.
$rollbackPs = @'
$ErrorActionPreference = 'Stop'
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$home_dir = $env:USERPROFILE
Write-Host "Rolling back harness-v3..."
Write-Host "Backup dir: $dir"

if (Test-Path "$dir\tool-files") {
    Get-ChildItem -Recurse -File "$dir\tool-files" | ForEach-Object {
        $rel = $_.FullName.Substring("$dir\tool-files\".Length)
        $dst = Join-Path $home_dir $rel
        $dstDir = Split-Path -Parent $dst
        if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Force -Path $dstDir | Out-Null }
        Copy-Item $_.FullName $dst -Force
        Write-Host "  restored $dst"
    }
}

$createdList = Join-Path $dir "created-fresh.txt"
if (Test-Path $createdList) {
    Get-Content $createdList | Where-Object { $_ -ne '' } | ForEach-Object {
        if (Test-Path $_) {
            Remove-Item -Force $_
            Write-Host "  removed $_ (created by install)"
        }
    }
}

$installDir = Join-Path $home_dir ".harness-v3"
if (Test-Path $installDir) {
    Remove-Item -Recurse -Force $installDir
    Write-Host "  removed $installDir"
}

$prev = Join-Path $dir "harness-v3.previous"
if (Test-Path $prev) {
    Copy-Item $prev $installDir -Recurse -Force
    Write-Host "  restored $installDir (from previous install)"
}

Write-Host "Rollback complete."
'@
Set-Content -Path (Join-Path $BackupDir 'rollback.ps1') -Value $rollbackPs -Encoding UTF8

$rollbackSh = @'
#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME:-$USERPROFILE}"
echo "Rolling back harness-v3..."
echo "Backup dir: $DIR"
if [ -d "$DIR/tool-files" ]; then
  cd "$DIR/tool-files"
  find . -type f | while read -r rel; do
    dst="$HOME_DIR/${rel#./}"
    mkdir -p "$(dirname "$dst")"
    cp "$rel" "$dst"
    echo "  restored $dst"
  done
  cd - >/dev/null
fi
if [ -f "$DIR/created-fresh.txt" ]; then
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    if [ -f "$f" ]; then
      rm "$f"
      echo "  removed $f (created by install)"
    fi
  done < "$DIR/created-fresh.txt"
fi
if [ -d "$HOME_DIR/.harness-v3" ]; then
  rm -rf "$HOME_DIR/.harness-v3"
  echo "  removed $HOME_DIR/.harness-v3"
fi
if [ -d "$DIR/harness-v3.previous" ]; then
  cp -R "$DIR/harness-v3.previous" "$HOME_DIR/.harness-v3"
  echo "  restored $HOME_DIR/.harness-v3 (from previous install)"
fi
echo "Rollback complete."
'@
Set-Content -Path (Join-Path $BackupDir 'rollback.sh') -Value $rollbackSh -Encoding UTF8

# Summary.
Write-Host ""
Write-Host "=== Install complete ==="
Write-Host "  Harness:  $InstallDir"
Write-Host "  Step:     $chosenStep  (see $InstallDir\STEP.md)"
Write-Host ("  Tools:    {0}" -f ($selected -join ', '))
Write-Host "  Backup:   $BackupDir"
Write-Host ""
Write-Host "Rollback anytime with:  $BackupDir\rollback.ps1"
Write-Host ""
