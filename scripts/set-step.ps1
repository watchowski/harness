# set-step.ps1 - change the installed harness step tier.
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)] [ValidateRange(1,4)] [int]$Step
)
$ErrorActionPreference = 'Stop'
$HomeDir = $env:USERPROFILE
$StepFile = Join-Path $HomeDir '.harness-v3\STEP.md'
if (-not (Test-Path $StepFile)) {
    Write-Error "$StepFile not found - run install.ps1 first"
    exit 1
}
$content = Get-Content -Raw -Path $StepFile -Encoding UTF8
$new = $content -replace '(?m)^\*\*Current step:\*\* .*$', "**Current step:** $Step"
Set-Content -Path $StepFile -Value $new -Encoding UTF8
Write-Host "Step set to $Step. See $StepFile."
