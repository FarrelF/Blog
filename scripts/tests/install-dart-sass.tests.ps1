#Requires -Version 5.1
<#
.SYNOPSIS
  Integration tests for scripts/install-dart-sass.ps1.

.DESCRIPTION
  Runs the Windows Dart Sass installer against a loopback fixture server, so
  the suite needs no GitHub access, administrator rights, Pester, or Python.
  Each case starts the real installer as a child process and asserts on the
  exit code, stdout/stderr, and the files it produced.

  Run from the repository root:

    powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/install-dart-sass.tests.ps1
    pwsh -NoProfile -File scripts/tests/install-dart-sass.tests.ps1

  Options:
    -Keep    Keep the temporary workspace after the run.
    -Filter  Run only cases whose name matches the regular expression.
#>
[CmdletBinding()]
param(
  [switch]$Keep,
  [string]$Filter = ''
)

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $here 'installer-test-helpers.ps1')

$repoRoot = Split-Path -Parent (Split-Path -Parent $here)
$installer = Join-Path (Join-Path $repoRoot 'scripts') 'install-dart-sass.ps1'
if (-not (Test-Path -LiteralPath $installer)) {
  throw "installer not found: $installer"
}

$work = New-TestWorkspace 'sass-installer'
$fixtures = Join-Path $work 'fixtures'
$arch = Get-TestArch
$assetArch = if ($arch -eq 'amd64') { 'x64' } elseif ($arch -eq '386') { 'ia32' } else { $arch }
$server = $null
$baseArgs = @()

function Write-FixtureText {
  param([string]$Path, [string]$Text)
  $parent = Split-Path -Parent $Path
  if (-not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }
  [IO.File]::WriteAllText($Path, $Text, (New-Object Text.UTF8Encoding -ArgumentList $false))
}

function New-SassAsset {
  param([string]$Tag, [string]$Version)
  $directory = Join-Path (Join-Path $fixtures 'assets') $Tag
  New-Item -ItemType Directory -Path $directory -Force | Out-Null
  $path = Join-Path $directory "dart-sass-$Version-windows-$assetArch.zip"
  New-FakeSassZip $path $Version
  return $path
}

function Write-ReleaseJson {
  param([string]$Tag, [hashtable[]]$Assets)
  $path = Join-Path (Join-Path $fixtures 'api') ($Tag + '.json')
  $payload = @{ tag_name = $Tag; assets = $Assets }
  Write-FixtureText $path ($payload | ConvertTo-Json -Depth 6)
}

function Add-DigestRelease {
  param([string]$Version, [string]$ZipPath)
  Write-ReleaseJson $Version @(
    @{ name = "dart-sass-$Version-windows-$assetArch.zip"; digest = 'sha256:' + (Get-Sha256Hex $ZipPath) }
  )
}

function Invoke-Sass {
  param(
    [string[]]$Arguments = @(),
    [hashtable]$Environment = @{},
    [string[]]$BaseArguments = @()
  )
  $saved = @{}
  foreach ($key in @($Environment.Keys)) {
    $saved[$key] = [Environment]::GetEnvironmentVariable($key)
    [Environment]::SetEnvironmentVariable($key, [string]$Environment[$key])
  }
  try {
    $all = @($baseArgs)
    if ($BaseArguments.Count -gt 0) { $all = @($BaseArguments) }
    $all += @($Arguments)
    return Invoke-InstallerScript -ScriptPath $installer -Arguments $all -WorkDirectory $work
  } finally {
    foreach ($key in @($Environment.Keys)) {
      [Environment]::SetEnvironmentVariable($key, $saved[$key])
    }
  }
}

function Case {
  param([string]$Name, [scriptblock]$Body)
  if (-not [string]::IsNullOrEmpty($Filter) -and $Name -notmatch $Filter) {
    return
  }
  Test-Case $Name $Body
}

function Assert-ExitCode {
  param($Result, [int]$Expected = 0)
  if ($Result.ExitCode -ne $Expected) {
    throw "expected exit code $Expected, got $($Result.ExitCode). Output:`n$($Result.Output)"
  }
}

function New-InstallDir {
  param([string]$Name)
  $path = Join-Path $work $Name
  if (Test-Path -LiteralPath $path) { Remove-Item -LiteralPath $path -Recurse -Force }
  return $path
}

# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------

$assetLatest = New-SassAsset '1.108.2' '1.108.2'
Add-DigestRelease '1.108.2' $assetLatest

$assetOld = New-SassAsset '1.89.0' '1.89.0'
Write-ReleaseJson '1.89.0' @()

$assetBadDigest = New-SassAsset '1.94.0' '1.94.0'
Write-ReleaseJson '1.94.0' @(
  @{ name = "dart-sass-1.94.0-windows-$assetArch.zip"; digest = 'sha256:' + ('0' * 64) }
)

$assetNoDigest = New-SassAsset '1.95.0' '1.95.0'

$zipSlip = Join-Path (Join-Path (Join-Path $fixtures 'assets') '1.96.0') "dart-sass-1.96.0-windows-$assetArch.zip"
New-Item -ItemType Directory -Path (Split-Path -Parent $zipSlip) -Force | Out-Null
New-ZipSlipFixture $zipSlip
Add-DigestRelease '1.96.0' $zipSlip

$badLayoutDir = Join-Path $work 'bad-layout'
New-Item -ItemType Directory -Path $badLayoutDir -Force | Out-Null
[IO.File]::WriteAllText((Join-Path $badLayoutDir 'sass.bat'), "@echo off`r`necho 1.97.0`r`n", [Text.ASCIIEncoding]::new())
$badLayout = Join-Path (Join-Path (Join-Path $fixtures 'assets') '1.97.0') "dart-sass-1.97.0-windows-$assetArch.zip"
New-Item -ItemType Directory -Path (Split-Path -Parent $badLayout) -Force | Out-Null
New-FixtureZip $badLayoutDir $badLayout
Add-DigestRelease '1.97.0' $badLayout

$assetFlaky = New-SassAsset '1.98.0' '1.98.0'
Add-DigestRelease '1.98.0' $assetFlaky

$assetGiveUp = New-SassAsset '1.99.0' '1.99.0'
Add-DigestRelease '1.99.0' $assetGiveUp

$corrupt = Join-Path (Join-Path (Join-Path $fixtures 'assets') '1.99.1') "dart-sass-1.99.1-windows-$assetArch.zip"
Write-FixtureText $corrupt 'this is not a zip archive'
Write-ReleaseJson '1.99.1' @(
  @{ name = "dart-sass-1.99.1-windows-$assetArch.zip"; digest = 'sha256:' + (Get-Sha256Hex $corrupt) }
)

# ---------------------------------------------------------------------------
# Server
# ---------------------------------------------------------------------------

try {
  $server = Start-FixtureServer -Root $fixtures -WorkDirectory $work -LatestTag '1.108.2'
  $baseArgs = @(
    '-RepoUrl', $server.BaseUrl,
    '-ApiBase', ($server.BaseUrl + '/api'),
    '-ReleaseBase', ($server.BaseUrl + '/releases/download')
  )

  $isAdmin = $false
  try {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal -ArgumentList $identity
    $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  } catch { }

  $elevationUnavailable = (-not $isAdmin) -and (
    [Console]::IsInputRedirected -or -not [Environment]::UserInteractive -or -not [string]::IsNullOrEmpty($env:CI)
  )

  # -------------------------------------------------------------------------
  # CLI and validation
  # -------------------------------------------------------------------------

  Case 'help prints usage and exits zero' {
    $result = Invoke-Sass @('-Help')
    Assert-ExitCode $result
    Assert-Contains $result.Output 'install-dart-sass.ps1'
    Assert-Contains $result.Output '-InstallDir DIR'
  }

  Case 'rejects an invalid version' {
    $result = Invoke-Sass @('-Version', '1..2', '-DryRun')
    Assert-ExitCode $result 1
    Assert-Contains $result.Output 'invalid Dart Sass version'
  }

  Case 'rejects -User with -System' {
    $result = Invoke-Sass @('-User', '-System', '-DryRun')
    Assert-ExitCode $result 1
    Assert-Contains $result.Output 'cannot combine -User with -System'
  }

  Case 'rejects -User with -InstallDir' {
    $result = Invoke-Sass @('-User', '-InstallDir', (Join-Path $work 'nope'), '-DryRun')
    Assert-ExitCode $result 1
    Assert-Contains $result.Output 'cannot combine -User with -InstallDir'
  }

  Case 'rejects -System with -NoEscalate' {
    $result = Invoke-Sass @('-System', '-NoEscalate', '-DryRun')
    Assert-ExitCode $result 1
    Assert-Contains $result.Output 'cannot combine -System with -NoEscalate'
  }

  Case 'rejects a non-native libc' {
    $result = Invoke-Sass @('-Libc', 'musl', '-DryRun')
    Assert-ExitCode $result 1
    Assert-Contains $result.Output "invalid -Libc value: 'musl'"
  }

  Case 'rejects an unknown downloader' {
    $downloaderDir = New-InstallDir 'install-bad-downloader'
    $result = Invoke-Sass @('-Version', '1.108.2', '-InstallDir', $downloaderDir, '-Downloader', 'no-such-downloader', '-Yes')
    Assert-ExitCode $result 1
    Assert-Contains $result.Output "downloader 'no-such-downloader' is not installed"
  }

  Case 'rejects -Uninstall with -PrintEnv' {
    $result = Invoke-Sass @('-Uninstall', '-PrintEnv')
    Assert-ExitCode $result 1
    Assert-Contains $result.Output 'cannot combine -Uninstall with -PrintEnv'
  }

  if ($elevationUnavailable) {
    Case 'fails -System when UAC is unavailable' {
      $result = Invoke-Sass @('-Version', '1.108.2', '-System', '-DryRun')
      Assert-ExitCode $result 1
      Assert-Contains $result.Output 'cannot install into'
    }
  } else {
    Skip-Case 'fails -System when UAC is unavailable' 'UAC or an elevated shell is available'
  }

  # -------------------------------------------------------------------------
  # Dry-run resolution
  # -------------------------------------------------------------------------

  Case 'resolves latest through the releases redirect' {
    $result = Invoke-Sass @('-User', '-DryRun')
    Assert-ExitCode $result
    Assert-Contains $result.Output 'version=1.108.2'
    Assert-Contains $result.Output "asset=dart-sass-1.108.2-windows-$assetArch.zip"
  }

  Case 'strips a leading v from the version' {
    $result = Invoke-Sass @('-Version', 'v1.108.2', '-User', '-DryRun')
    Assert-ExitCode $result
    Assert-Contains $result.Output 'version=1.108.2'
  }

  Case 'dry-run reports the native layout and escalation' {
    $result = Invoke-Sass @('-Version', '1.108.2', '-User', '-DryRun')
    Assert-ExitCode $result
    Assert-Contains $result.Output 'method=binary'
    Assert-Contains $result.Output 'os=windows'
    Assert-Contains $result.Output 'libc=native'
    Assert-Contains $result.Output 'escalation=none'
    Assert-Contains $result.Output 'bin='
  }

  Case 'dry-run prints DART_SASS_VERSION, DART_SASS_BIN, and DART_SASS_DIR' {
    $result = Invoke-Sass @('-Version', '1.108.2', '-User', '-DryRun', '-PrintEnv')
    Assert-ExitCode $result
    Assert-Contains $result.StdOut 'DART_SASS_VERSION=1.108.2'
    Assert-Contains $result.StdOut 'DART_SASS_BIN='
    Assert-Contains $result.StdOut 'DART_SASS_DIR='
    Assert-NotContains $result.StdOut 'version='
  }

  Case 'dry-run prints only the directory with -PrintPath' {
    $result = Invoke-Sass @('-Version', '1.108.2', '-User', '-DryRun', '-PrintPath')
    Assert-ExitCode $result
    $lines = @($result.StdOut -split "`r?`n" | Where-Object { $_ })
    Assert-Equal $lines.Count 1 'line count'
    Assert-Match $lines[0] 'Programs\\Dart Sass$'
  }

  Case 'reads DART_SASS_VERSION from the environment' {
    $result = Invoke-Sass @('-User', '-DryRun') @{ DART_SASS_VERSION = '1.89.0' }
    Assert-ExitCode $result
    Assert-Contains $result.Output 'version=1.89.0'
  }

  Case 'reads DART_SASS_INSTALL_DIR from the environment' {
    $target = Join-Path $work 'env-install-dir'
    $result = Invoke-Sass @('-Version', '1.108.2', '-DryRun') @{ DART_SASS_INSTALL_DIR = $target }
    Assert-ExitCode $result
    Assert-Contains $result.Output "install_dir=$target"
  }

  # -------------------------------------------------------------------------
  # Install
  # -------------------------------------------------------------------------

  $mainDir = New-InstallDir 'install-main'
  Case 'installs the payload and verifies the digest' {
    $result = Invoke-Sass @('-Version', '1.108.2', '-InstallDir', $mainDir, '-Yes')
    Assert-ExitCode $result
    Assert-FileExists (Join-Path $mainDir 'sass.bat')
    Assert-FileExists (Join-Path $mainDir 'sass')
    Assert-FileExists (Join-Path $mainDir 'src\dart.exe')
    Assert-FileExists (Join-Path $mainDir 'src\sass.snapshot')
    Assert-Contains $result.Output 'SHA-256 verification succeeded'
    Assert-Contains $result.Output 'smoke test passed'
    Assert-Contains $result.Output 'Dart Sass 1.108.2 installed at'
  }

  Case 'skips an already installed version' {
    $result = Invoke-Sass @('-Version', '1.108.2', '-InstallDir', $mainDir, '-Yes')
    Assert-ExitCode $result
    Assert-Contains $result.Output 'already installed'
    Assert-NotContains $result.Output 'downloading'
  }

  Case 'reinstalls with -Force' {
    $result = Invoke-Sass @('-Version', '1.108.2', '-InstallDir', $mainDir, '-Yes', '-Force')
    Assert-ExitCode $result
    Assert-Contains $result.Output 'downloading'
    Assert-Contains $result.Output 'smoke test passed'
  }

  Case 'requires -Yes to replace another version' {
    $result = Invoke-Sass @('-Version', '1.89.0', '-InstallDir', $mainDir)
    Assert-ExitCode $result 1
    Assert-Contains $result.Output 'pass -Yes'
  }

  Case 'replaces another version with -Yes' {
    $result = Invoke-Sass @('-Version', '1.89.0', '-InstallDir', $mainDir, '-Yes')
    Assert-ExitCode $result
    Assert-Contains $result.Output 'replacing Dart Sass 1.108.2'
    Assert-Contains $result.Output 'Dart Sass 1.89.0 installed at'
  }

  Case 'skips verification with -NoVerify' {
    $noVerify = New-InstallDir 'install-noverify'
    $result = Invoke-Sass @('-Version', '1.108.2', '-InstallDir', $noVerify, '-Yes', '-NoVerify')
    Assert-ExitCode $result
    Assert-Contains $result.Output 'verification is disabled'
    Assert-FileExists (Join-Path $noVerify 'sass.bat')
  }

  Case 'warns that pre-1.89.1 releases have no digest' {
    $oldDir = New-InstallDir 'install-old'
    $result = Invoke-Sass @('-Version', '1.89.0', '-InstallDir', $oldDir, '-Yes')
    Assert-ExitCode $result
    Assert-Contains $result.Output 'predates the first release with published SHA-256 asset digests'
    Assert-FileExists (Join-Path $oldDir 'sass.bat')
  }

  Case 'aborts on a digest mismatch' {
    $badDir = New-InstallDir 'install-bad-digest'
    $result = Invoke-Sass @('-Version', '1.94.0', '-InstallDir', $badDir, '-Yes')
    Assert-ExitCode $result 1
    Assert-Contains $result.Output 'SHA-256 mismatch'
    Assert-FileMissing (Join-Path $badDir 'sass.bat')
  }

  Case 'installs when the release publishes no digest' {
    $noDigestDir = New-InstallDir 'install-no-digest'
    $result = Invoke-Sass @('-Version', '1.95.0', '-InstallDir', $noDigestDir, '-Yes')
    Assert-ExitCode $result
    Assert-Contains $result.Output 'skipping verification'
    Assert-FileExists (Join-Path $noDigestDir 'sass.bat')
  }

  Case 'refuses a zip-slip archive entry' {
    $slipDir = New-InstallDir 'install-zipslip'
    $result = Invoke-Sass @('-Version', '1.96.0', '-InstallDir', $slipDir, '-Yes')
    Assert-ExitCode $result 1
    Assert-Contains $result.Output 'unsafe archive entry'
    Assert-FileMissing (Join-Path $slipDir 'sass.bat')
  }

  Case 'refuses an unexpected archive layout' {
    $layoutDir = New-InstallDir 'install-bad-layout'
    $result = Invoke-Sass @('-Version', '1.97.0', '-InstallDir', $layoutDir, '-Yes')
    Assert-ExitCode $result 1
    Assert-Contains $result.Output "no top-level 'dart-sass' directory"
    Assert-FileMissing (Join-Path $layoutDir 'sass.bat')
  }

  Case 'retries a transient 500 response' {
    $retryDir = New-InstallDir 'install-retry'
    $flaky = @(
      '-RepoUrl', $server.BaseUrl,
      '-ApiBase', ($server.BaseUrl + '/api'),
      '-ReleaseBase', ($server.BaseUrl + '/flaky-zip/500/1/releases/download')
    )
    $result = Invoke-Sass @('-Version', '1.98.0', '-InstallDir', $retryDir, '-Yes') @{} $flaky
    Assert-ExitCode $result
    Assert-Contains $result.Output 'download attempt 1 failed'
    Assert-FileExists (Join-Path $retryDir 'sass.bat')
  }

  Case 'gives up after two failed download attempts' {
    $giveUpDir = New-InstallDir 'install-giveup'
    $flaky = @(
      '-RepoUrl', $server.BaseUrl,
      '-ApiBase', ($server.BaseUrl + '/api'),
      '-ReleaseBase', ($server.BaseUrl + '/flaky-zip/503/5/releases/download')
    )
    $result = Invoke-Sass @('-Version', '1.99.0', '-InstallDir', $giveUpDir, '-Yes') @{} $flaky
    Assert-ExitCode $result 1
    Assert-Contains $result.Output 'failed to download'
    Assert-FileMissing (Join-Path $giveUpDir 'sass.bat')
  }

  Case 'refuses a download that is not a zip archive' {
    $corruptDir = New-InstallDir 'install-corrupt'
    $result = Invoke-Sass @('-Version', '1.99.1', '-InstallDir', $corruptDir, '-Yes')
    Assert-ExitCode $result 1
    Assert-Contains $result.Output 'error:'
    Assert-FileMissing (Join-Path $corruptDir 'sass.bat')
  }

  Case 'writes GITHUB_OUTPUT and GITHUB_PATH' {
    $ciDir = New-InstallDir 'install-ci'
    $outputFile = Join-Path $work 'github-output.txt'
    $pathFile = Join-Path $work 'github-path.txt'
    Remove-Item -LiteralPath $outputFile, $pathFile -Force -ErrorAction SilentlyContinue
    $result = Invoke-Sass @('-Version', '1.108.2', '-InstallDir', $ciDir, '-Yes') @{
      DART_SASS_NO_PATH = '0'
      GITHUB_OUTPUT = $outputFile
      GITHUB_PATH = $pathFile
    }
    Assert-ExitCode $result
    Assert-FileExists $outputFile
    Assert-FileExists $pathFile
    $output = [IO.File]::ReadAllText($outputFile)
    Assert-Contains $output 'dart-sass-version=1.108.2'
    Assert-Contains $output 'dart-sass-path='
    $pathText = [IO.File]::ReadAllText($pathFile)
    Assert-Contains $pathText $ciDir
  }

  # -------------------------------------------------------------------------
  # PATH handling
  # -------------------------------------------------------------------------

  Case 'dry-run reports the PATH scope' {
    $dir = New-InstallDir 'install-path-scope'
    $result = Invoke-Sass -Arguments @('-Version', '1.108.2', '-InstallDir', $dir, '-DryRun', '-PathScope', 'Process') -Environment @{ DART_SASS_NO_PATH = '0' }
    Assert-ExitCode $result
    Assert-Contains $result.Output 'path_scope=Process'
  }

  Case 'dry-run with -NoPath disables the PATH update' {
    $dir = New-InstallDir 'install-path-nopath'
    $result = Invoke-Sass @('-Version', '1.108.2', '-InstallDir', $dir, '-DryRun', '-NoPath')
    Assert-ExitCode $result
    Assert-Contains $result.Output 'path_update=disabled'
  }

  Case '-NoPath suppresses GITHUB_PATH' {
    $dir = New-InstallDir 'install-path-gha-nopath'
    $pathFile = Join-Path $work 'github-path-nopath.txt'
    Remove-Item -LiteralPath $pathFile -Force -ErrorAction SilentlyContinue
    $result = Invoke-Sass @('-Version', '1.108.2', '-InstallDir', $dir, '-Yes', '-NoPath') @{ GITHUB_PATH = $pathFile }
    Assert-ExitCode $result
    if (Test-Path -LiteralPath $pathFile) {
      Assert-NotContains ([IO.File]::ReadAllText($pathFile)) $dir
    }
  }

  Case 'install adds the PATH entry and uninstall removes it' {
    $dir = New-InstallDir 'install-path-entry'
    $install = Invoke-Sass -Arguments @('-Version', '1.108.2', '-InstallDir', $dir, '-Yes', '-PathScope', 'Process') -Environment @{ DART_SASS_NO_PATH = '0' }
    Assert-ExitCode $install
    Assert-Contains $install.Output 'Process PATH'
    $remove = Invoke-Sass -Arguments @('-Uninstall', '-InstallDir', $dir, '-Yes', '-PathScope', 'Process') -Environment @{ DART_SASS_NO_PATH = '0' }
    Assert-ExitCode $remove
    Assert-FileMissing (Join-Path $dir 'sass.bat')
  }

  # -------------------------------------------------------------------------
  # Uninstall
  # -------------------------------------------------------------------------

  Case 'uninstall dry-run lists the files' {
    $result = Invoke-Sass @('-Uninstall', '-InstallDir', $mainDir, '-DryRun', '-Yes')
    Assert-ExitCode $result
    Assert-Contains $result.Output 'uninstall=1'
    Assert-Contains $result.Output 'method=windows'
    Assert-Contains $result.Output "remove=$(Join-Path $mainDir 'sass.bat')"
  }

  Case 'uninstall removes the payload' {
    $result = Invoke-Sass @('-Uninstall', '-InstallDir', $mainDir, '-Yes')
    Assert-ExitCode $result
    Assert-FileMissing (Join-Path $mainDir 'sass.bat')
    Assert-FileMissing (Join-Path $mainDir 'sass')
    Assert-FileMissing (Join-Path $mainDir 'src')
    Assert-Contains $result.Output 'Dart Sass removed from'
  }

  Case 'uninstall is a no-op when nothing is installed' {
    $empty = New-InstallDir 'install-empty'
    $result = Invoke-Sass @('-Uninstall', '-InstallDir', $empty, '-Yes')
    Assert-ExitCode $result
    Assert-Contains $result.Output 'nothing to remove'
  }

  Case 'print-env reports the installed version when skipping' {
    $envDir = New-InstallDir 'install-printenv'
    $install = Invoke-Sass @('-Version', '1.108.2', '-InstallDir', $envDir, '-Yes')
    Assert-ExitCode $install
    $result = Invoke-Sass @('-Version', '1.108.2', '-InstallDir', $envDir, '-Yes', '-PrintEnv')
    Assert-ExitCode $result
    Assert-Contains $result.StdOut 'DART_SASS_VERSION=1.108.2'
    Assert-Contains $result.StdOut 'DART_SASS_BIN='
    Assert-Contains $result.StdOut 'DART_SASS_DIR='
  }
} finally {
  Stop-FixtureServer $server
  if (-not $Keep) {
    Remove-TestWorkspace $work
  } else {
    Write-Host "kept workspace: $work"
  }
}

Exit-TestRun 'install-dart-sass.ps1'
