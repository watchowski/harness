# Claude Code Harness Installer (Windows PowerShell)
# Usage: irm https://raw.githubusercontent.com/<OWNER>/harness/main/install.ps1 | iex

$ErrorActionPreference = "Stop"

$Owner  = "<OWNER>"
$Repo   = "harness"
$Branch = "main"
$Base   = "https://raw.githubusercontent.com/$Owner/$Repo/$Branch"

function Write-Info { param($Msg) Write-Host "[harness] $Msg" -ForegroundColor Green  }
function Write-Warn { param($Msg) Write-Host "[harness] $Msg" -ForegroundColor Yellow }
function Write-Err  { param($Msg) Write-Host "[harness] $Msg" -ForegroundColor Red    }

Write-Host ""
Write-Host "  Claude Code Harness"
Write-Host "  github.com/$Owner/$Repo"
Write-Host ""

# Warn if not in git repo
try   { git rev-parse --git-dir 2>$null | Out-Null }
catch { Write-Warn "Not in a git repository. Proceeding anyway." }

function Confirm-Overwrite {
  param($File)
  if (Test-Path $File) {
    Write-Warn "Existing $File found."
    $reply = Read-Host "  Overwrite? [y/N]"
    if ($reply -notmatch '^[Yy]$') {
      Write-Warn "  Skipping $File"
      return $false
    }
  }
  return $true
}

function Get-HarnessFile {
  param($Src, $Dst)
  $dir = Split-Path $Dst -Parent
  if ($dir -and -not (Test-Path $dir)) {
    New-Item -ItemType Directory -Force $dir | Out-Null
  }
  try {
    Invoke-WebRequest -Uri "$Base/$Src" -OutFile $Dst -UseBasicParsing
    Write-Info "  + $Dst"
  } catch {
    Write-Err "  x Failed: $Src"
    throw
  }
}

$ContentFiles = @(
  "CLAUDE.md",
  ".harness/principles.md",
  ".harness/a11y/A11Y.md",
  ".harness/a11y/references/forms.md",
  ".harness/a11y/references/navigation.md",
  ".harness/a11y/references/modals.md",
  ".harness/a11y/references/contrast.md",
  ".harness/a11y/references/images.md",
  ".harness/a11y/REPORT.md",
  ".claude/hooks/pre-commit",
  ".claude/hooks/stop",
  "docs/harness/overview.md",
  "docs/harness/principles/01-hardening.md",
  "docs/harness/principles/02-context-hygiene.md",
  "docs/harness/principles/03-living-documentation.md",
  "docs/harness/principles/04-disposable-blueprint.md",
  "docs/harness/principles/05-institutional-memory.md",
  "docs/harness/principles/06-specialized-review.md",
  "docs/harness/principles/07-observability.md",
  "docs/harness/principles/08-strategic-human-gate.md",
  "docs/harness/principles/09-token-economy.md",
  "docs/harness/principles/10-toolkit.md"
)

$ProtectedFiles = @(
  ".harness/a11y/EXCEPTIONS.md",
  ".claude/settings.json"
)

foreach ($f in $ContentFiles)   { Get-HarnessFile $f $f }
foreach ($f in $ProtectedFiles) { if (Confirm-Overwrite $f) { Get-HarnessFile $f $f } }

# Seed learnings file if absent
if (-not (Test-Path "docs/harness/learnings.md")) {
  New-Item -ItemType Directory -Force "docs/harness" | Out-Null
  @"
# Institutional Learnings

Lessons codified from agent mistakes per Principle 05 — Institutional Memory.

---

<!-- Entries added here by the Stop hook after each session -->
"@ | Set-Content "docs/harness/learnings.md" -Encoding utf8
  Write-Info "  + docs/harness/learnings.md (created)"
}

Write-Host ""
Write-Info "Harness installed. Open Claude Code in this directory to activate."
Write-Host ""
