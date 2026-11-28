#Requires -Version 5.1
<#
.SYNOPSIS
  Run the PowerShell installer integration suites.

.DESCRIPTION
  Runs install-hugo.tests.ps1 and install-dart-sass.tests.ps1 with the same
  PowerShell edition that started this script. Both suites use a loopback
  fixture server, so no GitHub access, administrator rights, Pester, or Python
  is required.

  From the repository root:

    powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/run-installer-tests.ps1
    pwsh -NoProfile -File scripts/tests/run-installer-tests.ps1

  Options:
    -Keep    Keep the temporary workspace of each suite.
    -Filter  Run only cases whose name matches the regular expression.
#>
[CmdletBinding()]
param(
  [switch]$Keep,
  [string]$Filter = ''
)

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

$powerShell = ''
try { $powerShell = (Get-Process -Id $PID).Path } catch { }
if ([string]::IsNullOrEmpty($powerShell) -or -not (Test-Path -LiteralPath $powerShell)) {
  if ($PSVersionTable.PSEdition -eq 'Core') {
    $powerShell = Join-Path $PSHOME 'pwsh.exe'
  } else {
    $powerShell = Join-Path $PSHOME 'powershell.exe'
  }
}

$suites = @(
  'install-hugo.tests.ps1',
  'install-dart-sass.tests.ps1'
)

$failed = @()
foreach ($suite in $suites) {
  $path = Join-Path $here $suite
  if (-not (Test-Path -LiteralPath $path)) {
    Write-Host "MISSING $suite" -ForegroundColor Red
    $failed += $suite
    continue
  }

  $arguments = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $path)
  if ($Keep) { $arguments += '-Keep' }
  if (-not [string]::IsNullOrEmpty($Filter)) { $arguments += @('-Filter', $Filter) }

  Write-Host ''
  Write-Host "== $suite ==" -ForegroundColor Cyan
  & $powerShell @arguments
  if ($LASTEXITCODE -ne 0) {
    $failed += $suite
  }
}

Write-Host ''
if ($failed.Count -gt 0) {
  Write-Host ("FAILED: " + ($failed -join ', ')) -ForegroundColor Red
  exit 1
}
Write-Host 'All PowerShell installer suites passed.' -ForegroundColor Green
exit 0
