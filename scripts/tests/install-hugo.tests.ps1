#Requires -Version 5.1
<#
.SYNOPSIS
  Integration tests for scripts/install-hugo.ps1.

.DESCRIPTION
  Runs the Windows installer against a loopback fixture server, so the suite
  needs no GitHub access, administrator rights, Pester, or Python. Each case
  starts the real installer as a child process and asserts on the exit code,
  stdout/stderr, and the files it produced.

  Run from the repository root:

    powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/install-hugo.tests.ps1
    pwsh -NoProfile -File scripts/tests/install-hugo.tests.ps1

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
$installer = Join-Path (Join-Path $repoRoot 'scripts') 'install-hugo.ps1'
if (-not (Test-Path -LiteralPath $installer)) {
  throw "installer not found: $installer"
}

$work = New-TestWorkspace 'hugo-installer'
$fixtures = Join-Path $work 'fixtures'
$arch = Get-TestArch
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

function New-ReleaseAsset {
  param(
    [string]$Tag,
    [string]$AssetName,
    [string]$Binary,
    [switch]$Raw
  )
  $directory = Join-Path (Join-Path $fixtures 'assets') $Tag
  New-Item -ItemType Directory -Path $directory -Force | Out-Null
  $destination = Join-Path $directory $AssetName
  if ($Raw) {
    Copy-Item -LiteralPath $Binary -Destination $destination -Force
    return $destination
  }

  $stage = Join-Path $work ('stage-' + [Guid]::NewGuid().ToString('N'))
  New-Item -ItemType Directory -Path $stage -Force | Out-Null
  try {
    Copy-Item -LiteralPath $Binary -Destination (Join-Path $stage 'hugo.exe') -Force
    New-FixtureZip $stage $destination
  } finally {
    Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue
  }
  return $destination
}

function Add-ChecksumFile {
  param([string]$Tag, [string[]]$Paths)
  $version = $Tag.TrimStart('v')
  $directory = Join-Path (Join-Path $fixtures 'assets') $Tag
  $lines = @()
  foreach ($path in $Paths) {
    $lines += ((Get-Sha256Hex $path) + '  ' + [IO.Path]::GetFileName($path))
  }
  Write-FixtureText (Join-Path $directory ("hugo_${version}_checksums.txt")) (($lines -join "`n") + "`n")
}

function Write-ReleaseJson {
  param([string]$Tag, [hashtable[]]$Assets)
  $path = Join-Path (Join-Path $fixtures 'api') ($Tag + '.json')
  $payload = @{ tag_name = $Tag; assets = $Assets }
  Write-FixtureText $path ($payload | ConvertTo-Json -Depth 6)
}

function Invoke-Hugo {
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

$bin152 = Join-Path $work 'fake-hugo-0.152.2.exe'
$bin150 = Join-Path $work 'fake-hugo-0.150.0.exe'
$bin1503 = Join-Path $work 'fake-hugo-0.150.3.exe'
New-FakeHugoExe $bin152 '0.152.2'
New-FakeHugoExe $bin150 '0.150.0'
New-FakeHugoExe $bin1503 '0.150.3'

$assets152 = @()
$assets152 += New-ReleaseAsset 'v0.152.2' "hugo_0.152.2_windows-$arch.zip" $bin152
$assets152 += New-ReleaseAsset 'v0.152.2' "hugo_extended_0.152.2_windows-$arch.zip" $bin152
$assets152 += New-ReleaseAsset 'v0.152.2' "hugo_extended_withdeploy_0.152.2_windows-$arch.zip" $bin152
Add-ChecksumFile 'v0.152.2' $assets152
Write-ReleaseJson 'v0.152.2' @(
  @{ name = "hugo_0.152.2_windows-$arch.zip"; digest = 'sha256:' + (Get-Sha256Hex $assets152[0]) }
)

$asset150 = New-ReleaseAsset 'v0.150.0' "hugo_0.150.0_windows-$arch.zip" $bin150
Write-ReleaseJson 'v0.150.0' @(
  @{ name = "hugo_0.150.0_windows-$arch.zip"; digest = 'sha256:' + (Get-Sha256Hex $asset150) }
)

$asset1501 = New-ReleaseAsset 'v0.150.1' "hugo_0.150.1_windows-$arch.zip" $bin1503
Write-FixtureText (Join-Path (Join-Path (Join-Path $fixtures 'assets') 'v0.150.1') 'hugo_0.150.1_checksums.txt') `
  (('0' * 64) + '  ' + [IO.Path]::GetFileName($asset1501) + "`n")

$asset1502 = New-ReleaseAsset 'v0.150.2' "hugo_0.150.2_windows-$arch.zip" $bin1503
Write-ReleaseJson 'v0.150.2' @(
  @{ name = "hugo_0.150.2_windows-$arch.zip"; digest = 'sha256:' + ('0' * 64) }
)

$null = New-ReleaseAsset 'v0.150.3' "hugo_0.150.3_windows-$arch.zip" $bin1503

$asset1504 = New-ReleaseAsset 'v0.150.4' "hugo_0.150.4_windows-$arch.zip" $bin152
Add-ChecksumFile 'v0.150.4' @($asset1504)

$asset1505 = New-ReleaseAsset 'v0.150.5' "hugo_0.150.5_windows-$arch.zip" $bin152
Add-ChecksumFile 'v0.150.5' @($asset1505)

$corrupt1506 = Join-Path (Join-Path (Join-Path $fixtures 'assets') 'v0.150.6') "hugo_0.150.6_windows-$arch.zip"
Write-FixtureText $corrupt1506 'this is not a zip archive'
Add-ChecksumFile 'v0.150.6' @($corrupt1506)

$asset137 = New-ReleaseAsset 'v0.137.1' "hugo_extended_withdeploy_0.137.1_windows-$arch.zip" $bin152
Add-ChecksumFile 'v0.137.1' @($asset137)

$asset170 = New-ReleaseAsset 'v0.170.0' "hugo_withdeploy_0.170.0_windows-$arch.zip" $bin152
Add-ChecksumFile 'v0.170.0' @($asset170)

$asset102 = New-ReleaseAsset 'v0.102.3' 'hugo_0.102.3_Windows-64bit.zip' $bin152
Add-ChecksumFile 'v0.102.3' @($asset102)

$null = New-ReleaseAsset 'v0.16' 'hugo_0.16_windows-64bit.zip' $bin152
$null = New-ReleaseAsset 'v0.8' 'hugo-windows-amd64' $bin152 -Raw

$asset40 = New-ReleaseAsset 'v0.40' 'hugo_0.40_Windows-64bit.zip' $bin152
Add-ChecksumFile 'v0.40' @($asset40)

$zipSlip = Join-Path (Join-Path (Join-Path $fixtures 'assets') 'v0.151.0') "hugo_0.151.0_windows-$arch.zip"
New-Item -ItemType Directory -Path (Split-Path -Parent $zipSlip) -Force | Out-Null
New-ZipSlipFixture $zipSlip
Add-ChecksumFile 'v0.151.0' @($zipSlip)

# A release tag that exists but publishes no Hugo archive for Windows.
$emptyRelease = Join-Path (Join-Path (Join-Path $fixtures 'assets') 'v0.148.0') 'README.txt'
Write-FixtureText $emptyRelease 'no Windows assets in this release'

# ---------------------------------------------------------------------------
# Server
# ---------------------------------------------------------------------------

try {
  $server = Start-FixtureServer -Root $fixtures -WorkDirectory $work -LatestTag 'v0.152.2'
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
    $result = Invoke-Hugo @('-Help')
    Assert-ExitCode $result
    Assert-Contains $result.Output 'install-hugo.ps1'
    Assert-Contains $result.Output '-InstallDir DIR'
  }

  Case 'rejects an invalid version' {
    $result = Invoke-Hugo @('-Version', 'abc', '-DryRun')
    Assert-ExitCode $result 1
    Assert-Contains $result.Output "invalid Hugo version: 'abc'"
  }

  Case 'rejects -User with -System' {
    $result = Invoke-Hugo @('-User', '-System', '-DryRun')
    Assert-ExitCode $result 1
    Assert-Contains $result.Output 'cannot combine -User with -System'
  }

  Case 'rejects -User with -InstallDir' {
    $result = Invoke-Hugo @('-User', '-InstallDir', (Join-Path $work 'nope'), '-DryRun')
    Assert-ExitCode $result 1
    Assert-Contains $result.Output 'cannot combine -User with -InstallDir'
  }

  Case 'rejects -System with -NoEscalate' {
    $result = Invoke-Hugo @('-System', '-NoEscalate', '-DryRun')
    Assert-ExitCode $result 1
    Assert-Contains $result.Output 'cannot combine -System with -NoEscalate'
  }

  Case 'rejects the Termux package method on Windows' {
    $result = Invoke-Hugo @('-Method', 'pkg', '-DryRun')
    Assert-ExitCode $result 1
    Assert-Contains $result.Output 'not available on Windows'
  }

  Case 'rejects an unknown completion shell' {
    $result = Invoke-Hugo @('-Completions', 'bogus', '-DryRun')
    Assert-ExitCode $result 1
    Assert-Contains $result.Output "unknown completion shell: 'bogus'"
  }

  Case 'rejects an unknown downloader' {
    $downloaderDir = New-InstallDir 'install-bad-downloader'
    $result = Invoke-Hugo @('-Version', '0.152.2', '-InstallDir', $downloaderDir, '-Downloader', 'no-such-downloader', '-Yes', '-NoMan', '-NoCompletions')
    Assert-ExitCode $result 1
    Assert-Contains $result.Output "downloader 'no-such-downloader' is not installed"
  }

  Case 'rejects -Uninstall with -PrintEnv' {
    $result = Invoke-Hugo @('-Uninstall', '-PrintEnv')
    Assert-ExitCode $result 1
    Assert-Contains $result.Output 'cannot combine -Uninstall with -PrintEnv'
  }

  Case 'rejects a version with -Uninstall' {
    $result = Invoke-Hugo @('-Uninstall', '-Version', '0.152.2', '-Yes')
    Assert-ExitCode $result 1
    Assert-Contains $result.Output 'version arguments are not valid with -Uninstall'
  }

  if ($elevationUnavailable) {
    Case 'fails -System when UAC is unavailable' {
      $result = Invoke-Hugo @('-Version', '0.152.2', '-System', '-DryRun', '-NoMan', '-NoCompletions')
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
    $result = Invoke-Hugo @('-User', '-DryRun', '-NoMan', '-NoCompletions')
    Assert-ExitCode $result
    Assert-Contains $result.Output 'version=0.152.2'
    Assert-Contains $result.Output "asset=hugo_0.152.2_windows-$arch.zip"
  }

  Case 'resolves the standard edition' {
    $result = Invoke-Hugo @('-Version', '0.152.2', '-User', '-DryRun', '-NoMan', '-NoCompletions')
    Assert-ExitCode $result
    Assert-Contains $result.Output 'edition=standard'
    Assert-Contains $result.Output 'escalation=none'
  }

  Case 'resolves the extended edition' {
    $result = Invoke-Hugo @('-Version', '0.152.2', '-Extended', '-User', '-DryRun', '-NoMan', '-NoCompletions')
    Assert-ExitCode $result
    Assert-Contains $result.Output "asset=hugo_extended_0.152.2_windows-$arch.zip"
    Assert-Contains $result.Output 'edition=extended'
  }

  Case 'resolves the extended+withdeploy edition' {
    $result = Invoke-Hugo @('-Version', '0.152.2', '-Extended', '-WithDeploy', '-User', '-DryRun', '-NoMan', '-NoCompletions')
    Assert-ExitCode $result
    Assert-Contains $result.Output "asset=hugo_extended_withdeploy_0.152.2_windows-$arch.zip"
    Assert-Contains $result.Output 'edition=extended_withdeploy'
  }

  Case 'uses the separate withdeploy build from v0.170.0' {
    $result = Invoke-Hugo @('-Version', '0.170.0', '-Extended', '-WithDeploy', '-User', '-DryRun', '-NoMan', '-NoCompletions')
    Assert-ExitCode $result
    Assert-Contains $result.Output "asset=hugo_withdeploy_0.170.0_windows-$arch.zip"
    Assert-Contains $result.Output 'removed the Extended edition'
  }

  Case 'bumps v0.137.0 extended+withdeploy to v0.137.1' {
    $result = Invoke-Hugo @('-Version', '0.137.0', '-Extended', '-WithDeploy', '-User', '-DryRun', '-NoMan', '-NoCompletions')
    Assert-ExitCode $result
    Assert-Contains $result.Output 'version=0.137.1'
    Assert-Contains $result.Output "asset=hugo_extended_withdeploy_0.137.1_windows-$arch.zip"
  }

  Case 'resolves title-case assets for v0.102.3' {
    $result = Invoke-Hugo @('-Version', '0.102.3', '-User', '-DryRun', '-NoMan', '-NoCompletions')
    Assert-ExitCode $result
    Assert-Contains $result.Output 'asset=hugo_0.102.3_Windows-64bit.zip'
  }

  Case 'resolves the v0.16 asset naming' {
    $result = Invoke-Hugo @('-Version', '0.16', '-User', '-DryRun', '-NoMan', '-NoCompletions')
    Assert-ExitCode $result
    Assert-Contains $result.Output 'asset=hugo_0.16_windows-64bit.zip'
  }

  Case 'resolves the v0.8 raw binary' {
    $result = Invoke-Hugo @('-Version', '0.8', '-User', '-DryRun', '-NoMan', '-NoCompletions')
    Assert-ExitCode $result
    Assert-Contains $result.Output 'asset=hugo-windows-amd64'
    Assert-NotContains $result.Output '.zip'
  }

  Case 'warns that extended needs v0.43.0' {
    $result = Invoke-Hugo @('-Version', '0.40', '-Extended', '-User', '-DryRun', '-NoMan', '-NoCompletions')
    Assert-ExitCode $result
    Assert-Contains $result.Output 'Extended is only published for v0.43.0'
    Assert-Contains $result.Output 'edition=standard'
  }

  Case 'reports a missing release asset' {
    $result = Invoke-Hugo @('-Version', '0.148.0', '-User', '-DryRun', '-NoMan', '-NoCompletions')
    Assert-ExitCode $result 1
    Assert-Contains $result.Output 'no matching Hugo release asset'
  }

  Case 'reports a version that has no assets' {
    $result = Invoke-Hugo @('-Version', '0.149.0', '-User', '-DryRun', '-NoMan', '-NoCompletions')
    Assert-ExitCode $result 1
    Assert-Contains $result.Output 'does not exist'
  }

  Case 'dry-run prints the manpage and completion targets' {
    $result = Invoke-Hugo @('-Version', '0.152.2', '-User', '-DryRun', '-Completions', 'bash,powershell')
    Assert-ExitCode $result
    Assert-Contains $result.Output 'manpages='
    Assert-Contains $result.Output 'completion.bash='
    Assert-Contains $result.Output 'completion.powershell='
    Assert-NotContains $result.Output 'completion.zsh='
  }

  Case 'dry-run honors -Completions none' {
    $result = Invoke-Hugo @('-Version', '0.152.2', '-User', '-DryRun', '-Completions', 'none')
    Assert-ExitCode $result
    Assert-NotContains $result.Output 'completion.'
  }

  Case 'dry-run prints HUGO_VERSION, HUGO_BIN, and HUGO_DIR' {
    $result = Invoke-Hugo @('-Version', '0.152.2', '-User', '-DryRun', '-PrintEnv', '-NoMan', '-NoCompletions')
    Assert-ExitCode $result
    Assert-Match $result.StdOut '(?m)^HUGO_VERSION=0\.152\.2\r?$'
    Assert-Match $result.StdOut '(?m)^HUGO_BIN=.*hugo\.exe\r?$'
    Assert-Match $result.StdOut '(?m)^HUGO_DIR=.+\r?$'
    Assert-NotContains $result.StdOut 'version='
  }

  Case 'dry-run prints only the directory with -PrintPath' {
    $result = Invoke-Hugo @('-Version', '0.152.2', '-User', '-DryRun', '-PrintPath', '-NoMan', '-NoCompletions')
    Assert-ExitCode $result
    $lines = @($result.StdOut -split "`r?`n" | Where-Object { $_ })
    Assert-Equal $lines.Count 1 'line count'
    Assert-Match $lines[0] 'Programs\\Hugo$'
  }

  Case 'reads HUGO_VERSION from the environment' {
    $result = Invoke-Hugo @('-User', '-DryRun', '-NoMan', '-NoCompletions') @{ HUGO_VERSION = '0.102.3' }
    Assert-ExitCode $result
    Assert-Contains $result.Output 'version=0.102.3'
  }

  Case 'reads HUGO_INSTALL_DIR from the environment' {
    $target = Join-Path $work 'env-install-dir'
    $result = Invoke-Hugo @('-Version', '0.152.2', '-DryRun', '-NoMan', '-NoCompletions') @{ HUGO_INSTALL_DIR = $target }
    Assert-ExitCode $result
    Assert-Contains $result.Output "install_dir=$target"
  }

  # -------------------------------------------------------------------------
  # Install
  # -------------------------------------------------------------------------

  $mainDir = New-InstallDir 'install-main'
  Case 'installs the binary and verifies the checksum' {
    $result = Invoke-Hugo @('-Version', '0.152.2', '-InstallDir', $mainDir, '-Yes', '-Completions', 'bash,powershell')
    Assert-ExitCode $result
    Assert-FileExists (Join-Path $mainDir 'hugo.exe')
    Assert-Contains $result.Output 'checksum verification succeeded'
    Assert-Contains $result.Output 'smoke test passed'
    Assert-Contains $result.Output 'Hugo v0.152.2 installed at'
  }

  Case 'installs the manpages and completions under share' {
    Assert-FileExists (Join-Path $mainDir 'share\man\man1\hugo.1.gz')
    Assert-FileExists (Join-Path $mainDir 'share\man\man1\hugo-version.1.gz')
    Assert-FileExists (Join-Path $mainDir 'share\bash-completion\completions\hugo')
    Assert-FileExists (Join-Path $mainDir 'share\powershell\completions\hugo.ps1')
  }

  Case 'skips an already installed version' {
    $result = Invoke-Hugo @('-Version', '0.152.2', '-InstallDir', $mainDir, '-Yes', '-NoMan', '-NoCompletions')
    Assert-ExitCode $result
    Assert-Contains $result.Output 'already installed'
    Assert-NotContains $result.Output 'downloading'
  }

  Case 'reinstalls with -Force' {
    $result = Invoke-Hugo @('-Version', '0.152.2', '-InstallDir', $mainDir, '-Yes', '-Force', '-NoMan', '-NoCompletions')
    Assert-ExitCode $result
    Assert-Contains $result.Output 'downloading'
    Assert-Contains $result.Output 'smoke test passed'
  }

  Case 'requires -Yes to replace another version' {
    $result = Invoke-Hugo @('-Version', '0.150.0', '-InstallDir', $mainDir, '-NoMan', '-NoCompletions')
    Assert-ExitCode $result 1
    Assert-Contains $result.Output 'pass -Yes'
  }

  Case 'replaces another version with -Yes' {
    $result = Invoke-Hugo @('-Version', '0.150.0', '-InstallDir', $mainDir, '-Yes', '-NoMan', '-NoCompletions')
    Assert-ExitCode $result
    Assert-Contains $result.Output 'replacing Hugo v0.152.2'
    Assert-Contains $result.Output 'Hugo v0.150.0 installed at'
  }

  Case 'installs without manpages or completions' {
    $bare = New-InstallDir 'install-bare'
    $result = Invoke-Hugo @('-Version', '0.152.2', '-InstallDir', $bare, '-Yes', '-NoMan', '-NoCompletions')
    Assert-ExitCode $result
    Assert-FileExists (Join-Path $bare 'hugo.exe')
    Assert-FileMissing (Join-Path $bare 'share')
  }

  Case 'skips verification with -NoVerify' {
    $noVerify = New-InstallDir 'install-noverify'
    $result = Invoke-Hugo @('-Version', '0.152.2', '-InstallDir', $noVerify, '-Yes', '-NoVerify', '-NoMan', '-NoCompletions')
    Assert-ExitCode $result
    Assert-Contains $result.Output 'verification is disabled'
    Assert-FileExists (Join-Path $noVerify 'hugo.exe')
  }

  Case 'installs into a custom share directory' {
    $target = New-InstallDir 'install-custom-share'
    $share = Join-Path $work 'custom-share'
    if (Test-Path -LiteralPath $share) { Remove-Item -LiteralPath $share -Recurse -Force }
    $result = Invoke-Hugo @('-Version', '0.152.2', '-InstallDir', $target, '-ShareDir', $share, '-Yes', '-Completions', 'bash')
    Assert-ExitCode $result
    Assert-FileExists (Join-Path $share 'man\man1\hugo.1.gz')
    Assert-FileExists (Join-Path $share 'bash-completion\completions\hugo')
  }

  Case 'falls back to the GitHub digest when the checksum file is missing' {
    $digestDir = New-InstallDir 'install-digest'
    $result = Invoke-Hugo @('-Version', '0.150.0', '-InstallDir', $digestDir, '-Yes', '-NoMan', '-NoCompletions')
    Assert-ExitCode $result
    Assert-Contains $result.Output 'GitHub release asset digest'
    Assert-FileExists (Join-Path $digestDir 'hugo.exe')
  }

  Case 'installs when no checksum metadata exists' {
    $noMetaDir = New-InstallDir 'install-nometa'
    $result = Invoke-Hugo @('-Version', '0.150.3', '-InstallDir', $noMetaDir, '-Yes', '-NoMan', '-NoCompletions')
    Assert-ExitCode $result
    Assert-Contains $result.Output 'skipping verification'
    Assert-FileExists (Join-Path $noMetaDir 'hugo.exe')
  }

  Case 'aborts on a checksum mismatch' {
    $badDir = New-InstallDir 'install-bad-checksum'
    $result = Invoke-Hugo @('-Version', '0.150.1', '-InstallDir', $badDir, '-Yes', '-NoMan', '-NoCompletions')
    Assert-ExitCode $result 1
    Assert-Contains $result.Output 'checksum mismatch'
    Assert-FileMissing (Join-Path $badDir 'hugo.exe')
  }

  Case 'aborts on a digest mismatch' {
    $badDigestDir = New-InstallDir 'install-bad-digest'
    $result = Invoke-Hugo @('-Version', '0.150.2', '-InstallDir', $badDigestDir, '-Yes', '-NoMan', '-NoCompletions')
    Assert-ExitCode $result 1
    Assert-Contains $result.Output 'SHA-256 mismatch'
    Assert-FileMissing (Join-Path $badDigestDir 'hugo.exe')
  }

  Case 'refuses a zip-slip archive entry' {
    $slipDir = New-InstallDir 'install-zipslip'
    $result = Invoke-Hugo @('-Version', '0.151.0', '-InstallDir', $slipDir, '-Yes', '-NoMan', '-NoCompletions')
    Assert-ExitCode $result 1
    Assert-Contains $result.Output 'unsafe archive entry'
    Assert-FileMissing (Join-Path $slipDir 'hugo.exe')
  }

  Case 'retries a transient 500 response' {
    $retryDir = New-InstallDir 'install-retry'
    $flaky = @(
      '-RepoUrl', $server.BaseUrl,
      '-ApiBase', ($server.BaseUrl + '/api'),
      '-ReleaseBase', ($server.BaseUrl + '/flaky-zip/500/1/releases/download')
    )
    $result = Invoke-Hugo @('-Version', '0.150.4', '-InstallDir', $retryDir, '-Yes', '-NoMan', '-NoCompletions') @{} $flaky
    Assert-ExitCode $result
    Assert-Contains $result.Output 'download attempt 1 failed'
    Assert-FileExists (Join-Path $retryDir 'hugo.exe')
  }

  Case 'gives up after two failed download attempts' {
    $giveUpDir = New-InstallDir 'install-giveup'
    $flaky = @(
      '-RepoUrl', $server.BaseUrl,
      '-ApiBase', ($server.BaseUrl + '/api'),
      '-ReleaseBase', ($server.BaseUrl + '/flaky-zip/503/5/releases/download')
    )
    $result = Invoke-Hugo @('-Version', '0.150.5', '-InstallDir', $giveUpDir, '-Yes', '-NoMan', '-NoCompletions') @{} $flaky
    Assert-ExitCode $result 1
    Assert-Contains $result.Output 'failed to download'
    Assert-FileMissing (Join-Path $giveUpDir 'hugo.exe')
  }

  Case 'warns when a .zip download is not a zip archive' {
    $corruptDir = New-InstallDir 'install-corrupt'
    $result = Invoke-Hugo @('-Version', '0.150.6', '-InstallDir', $corruptDir, '-Yes', '-NoMan', '-NoCompletions')
    Assert-ExitCode $result 1
    Assert-Contains $result.Output 'does not look like a zip archive'
    Assert-Contains $result.Output 'failed to execute'
  }

  Case 'writes GITHUB_OUTPUT and GITHUB_PATH' {
    $ciDir = New-InstallDir 'install-ci'
    $outputFile = Join-Path $work 'github-output.txt'
    $pathFile = Join-Path $work 'github-path.txt'
    Remove-Item -LiteralPath $outputFile, $pathFile -Force -ErrorAction SilentlyContinue
    $result = Invoke-Hugo @('-Version', '0.152.2', '-InstallDir', $ciDir, '-Yes', '-NoMan', '-NoCompletions') @{
      HUGO_NO_PATH = '0'
      GITHUB_OUTPUT = $outputFile
      GITHUB_PATH = $pathFile
    }
    Assert-ExitCode $result
    Assert-FileExists $outputFile
    Assert-FileExists $pathFile
    $output = [IO.File]::ReadAllText($outputFile)
    Assert-Contains $output 'hugo-version=0.152.2'
    Assert-Contains $output 'hugo-path='
    $pathText = [IO.File]::ReadAllText($pathFile)
    Assert-Contains $pathText $ciDir
  }

  # -------------------------------------------------------------------------
  # PATH handling
  # -------------------------------------------------------------------------

  Case 'dry-run reports the PATH scope' {
    $dir = New-InstallDir 'install-path-scope'
    $result = Invoke-Hugo -Arguments @('-Version', '0.152.2', '-InstallDir', $dir, '-DryRun', '-PathScope', 'Process') -Environment @{ HUGO_NO_PATH = '0' }
    Assert-ExitCode $result
    Assert-Contains $result.Output 'path_scope=Process'
  }

  Case 'dry-run with -NoPath disables the PATH update' {
    $dir = New-InstallDir 'install-path-nopath'
    $result = Invoke-Hugo @('-Version', '0.152.2', '-InstallDir', $dir, '-DryRun', '-NoPath')
    Assert-ExitCode $result
    Assert-Contains $result.Output 'path_update=disabled'
  }

  Case '-NoPath suppresses GITHUB_PATH' {
    $dir = New-InstallDir 'install-path-gha-nopath'
    $pathFile = Join-Path $work 'github-path-nopath.txt'
    Remove-Item -LiteralPath $pathFile -Force -ErrorAction SilentlyContinue
    $result = Invoke-Hugo @('-Version', '0.152.2', '-InstallDir', $dir, '-Yes', '-NoMan', '-NoCompletions', '-NoPath') @{ GITHUB_PATH = $pathFile }
    Assert-ExitCode $result
    if (Test-Path -LiteralPath $pathFile) {
      Assert-NotContains ([IO.File]::ReadAllText($pathFile)) $dir
    }
  }

  Case 'install adds the PATH entry and uninstall removes it' {
    $dir = New-InstallDir 'install-path-entry'
    $install = Invoke-Hugo -Arguments @('-Version', '0.152.2', '-InstallDir', $dir, '-Yes', '-NoMan', '-NoCompletions', '-PathScope', 'Process') -Environment @{ HUGO_NO_PATH = '0' }
    Assert-ExitCode $install
    Assert-Contains $install.Output 'Process PATH'
    $remove = Invoke-Hugo -Arguments @('-Uninstall', '-InstallDir', $dir, '-Yes', '-NoCompletions', '-PathScope', 'Process') -Environment @{ HUGO_NO_PATH = '0' }
    Assert-ExitCode $remove
    Assert-FileMissing (Join-Path $dir 'hugo.exe')
  }

  # -------------------------------------------------------------------------
  # Uninstall
  # -------------------------------------------------------------------------

  Case 'uninstall dry-run lists the files' {
    $result = Invoke-Hugo @('-Uninstall', '-InstallDir', $mainDir, '-DryRun', '-Yes')
    Assert-ExitCode $result
    Assert-Contains $result.Output 'uninstall=1'
    Assert-Contains $result.Output "remove=$(Join-Path $mainDir 'hugo.exe')"
  }

  Case 'uninstall removes the binary and extras' {
    $result = Invoke-Hugo @('-Uninstall', '-InstallDir', $mainDir, '-Yes')
    Assert-ExitCode $result
    Assert-FileMissing (Join-Path $mainDir 'hugo.exe')
    Assert-FileMissing (Join-Path $mainDir 'share\man\man1\hugo.1.gz')
    Assert-FileMissing (Join-Path $mainDir 'share\bash-completion\completions\hugo')
    Assert-Contains $result.Output 'Hugo removed from'
  }

  Case 'uninstall is a no-op when nothing is installed' {
    $empty = New-InstallDir 'install-empty'
    $result = Invoke-Hugo @('-Uninstall', '-InstallDir', $empty, '-Yes')
    Assert-ExitCode $result
    Assert-Contains $result.Output 'nothing to remove'
  }

  Case 'uninstall honors a custom share directory' {
    $target = Join-Path $work 'install-custom-share'
    $share = Join-Path $work 'custom-share'
    $result = Invoke-Hugo @('-Uninstall', '-InstallDir', $target, '-ShareDir', $share, '-Yes')
    Assert-ExitCode $result
    Assert-FileMissing (Join-Path $target 'hugo.exe')
    Assert-FileMissing (Join-Path $share 'man\man1\hugo.1.gz')
    Assert-FileMissing (Join-Path $share 'bash-completion\completions\hugo')
  }

  Case 'uninstall with -NoCompletions keeps the completions' {
    $keepDir = New-InstallDir 'install-keep-completions'
    $install = Invoke-Hugo @('-Version', '0.152.2', '-InstallDir', $keepDir, '-Yes', '-NoMan', '-Completions', 'bash')
    Assert-ExitCode $install
    $completion = Join-Path $keepDir 'share\bash-completion\completions\hugo'
    Assert-FileExists $completion
    $remove = Invoke-Hugo @('-Uninstall', '-InstallDir', $keepDir, '-Yes', '-NoCompletions')
    Assert-ExitCode $remove
    Assert-FileMissing (Join-Path $keepDir 'hugo.exe')
    Assert-FileExists $completion
  }
} finally {
  Stop-FixtureServer $server
  if (-not $Keep) {
    Remove-TestWorkspace $work
  } else {
    Write-Host "kept workspace: $work"
  }
}

Exit-TestRun 'install-hugo.ps1'
