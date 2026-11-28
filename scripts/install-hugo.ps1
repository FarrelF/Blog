<#
.SYNOPSIS
  Install, update, or remove the Hugo CLI on Windows.

.DESCRIPTION
  Standalone PowerShell installer for the official Hugo release archives. It is
  the Windows counterpart of scripts/install-hugo.sh and needs no Git Bash,
  MSYS, Cygwin, 7-Zip, or repository checkout.

  The script targets Windows PowerShell 5.1 (the baseline) and PowerShell 7.x.
  It installs into %ProgramFiles%\Hugo when that directory is writable or can be
  reached through one UAC prompt, and otherwise into %LOCALAPPDATA%\Programs\Hugo.
  An explicit -InstallDir is never replaced silently.

  Downloads are verified against the checksum file published with the release
  and, for v0.147.7 and newer, against the SHA-256 digest that GitHub publishes
  for the release asset. A mismatch aborts before extraction. The extracted
  hugo.exe is smoke tested before success is reported.

  The Extended and Deploy editions follow the same rules as the POSIX
  installer: Extended exists from v0.43.0 and was folded into the standard
  build in v0.170.0; the Deploy build exists from v0.137.0 and became a
  separate "withdeploy" archive in v0.170.0.

.PARAMETER Version
  Hugo version, with or without the "v" prefix. Default: latest
  (or $env:HUGO_VERSION).

.PARAMETER InstallDir
  Directory that receives hugo.exe. Default: %ProgramFiles%\Hugo or
  %LOCALAPPDATA%\Programs\Hugo. $env:HUGO_INSTALL_DIR is the environment
  equivalent.

.PARAMETER NoEscalate
  Never request UAC; install into a writable user directory instead.

.PARAMETER System
  Require a system-wide install. Fails when Program Files cannot be written
  and UAC is unavailable or declined.

.PARAMETER User
  Install into %LOCALAPPDATA%\Programs\Hugo and never request UAC. Cannot be
  combined with -System, -InstallDir, or -Escalate.

.PARAMETER Escalate
  Require a system-wide install through UAC and fail instead of falling back
  to the user directory (HUGO_ESCALATE=always).

.PARAMETER Extended
  Request the Extended edition (v0.43.0-v0.169.x). It is ignored with a note
  from v0.170.0, where the standard build includes those features.

.PARAMETER NoExtended
  Request the standard edition even when $env:HUGO_EXTENDED is truthy.

.PARAMETER WithDeploy
  Request the Deploy build. From v0.170.0 this selects the separate
  "withdeploy" archive; from v0.137.0 it is included in the Extended build.

.PARAMETER NoWithDeploy
  Disable a Deploy request inherited from $env:HUGO_WITHDEPLOY.

.PARAMETER Method
  Only "auto" and "binary" are valid on Windows. "pkg" (Termux) and "deb"
  (Debian) are rejected with an explanation.

.PARAMETER Verify
  Verify the download (default). The release checksum file is preferred and
  the GitHub asset digest is the fallback for v0.147.7 and newer.

.PARAMETER NoVerify
  Skip checksum verification. The smoke test still runs.

.PARAMETER Force
  Reinstall even when the requested version is already installed.

.PARAMETER NoForce
  Disable a force request inherited from $env:HUGO_FORCE.

.PARAMETER Yes
  Replace an installed version or remove it without asking for confirmation.
  $env:HUGO_YES is the environment equivalent.

.PARAMETER Uninstall
  Remove hugo.exe and the manpages and completions installed by this script,
  then exit. Use -InstallDir or -User to select the binary location and
  -ShareDir when the extras do not live under <InstallDir>\share. -DryRun lists
  the files without removing them.

.PARAMETER DryRun
  Resolve and print what would be installed without downloading, writing, or
  requesting UAC. Version and asset resolution still uses read-only HTTP
  requests, matching the POSIX installer.

.PARAMETER PrintEnv
  Print HUGO_VERSION, HUGO_BIN, and HUGO_DIR.

.PARAMETER PrintPath
  Print only the install directory, for PATH.

.PARAMETER NoPath
  Do not add the install directory to PATH (persistent, or $env:GITHUB_PATH in
  GitHub Actions). A manual snippet is printed instead. $env:HUGO_NO_PATH is
  the environment equivalent.

.PARAMETER Man
  Generate and install the manpages under <ShareDir>\man\man1 (default).

.PARAMETER NoMan
  Do not generate or install manpages.

.PARAMETER Completions
  Comma- or space-separated shells: bash, fish, zsh, powershell, all, or none.
  Default: auto (the supported shells installed on this system).

.PARAMETER NoCompletions
  Do not generate or install shell completions.

.PARAMETER ShareDir
  Directory that receives the manpages and completions. Default:
  <InstallDir>\share. $env:HUGO_SHARE_DIR is the environment equivalent.

.PARAMETER Quiet
  Suppress progress notes. Warnings still print.

.PARAMETER Downloader
  auto (default), httpclient, curl, aria2, wget, axel, or mwget. The native
  HttpClient downloader is used unless another one is requested and available.

.PARAMETER DownloaderArgs
  Extra arguments for an external downloader. Prefer an array:
  -DownloaderArgs '-x','16'. $env:DOWNLOADER_ARGS is split on whitespace.

.PARAMETER GitHubToken
  GitHub API token for latest/digest lookups. $env:GITHUB_TOKEN is used when
  this parameter is omitted. The token is never written to logs or passed to an
  elevated child process.

.PARAMETER Help
  Show the full usage text.

.EXAMPLE
  .\install-hugo.ps1

.EXAMPLE
  .\install-hugo.ps1 -Version 0.152.2 -Extended -User

.EXAMPLE
  .\install-hugo.ps1 -Uninstall -DryRun -User

.NOTES
  Exit status: 0 on success, 1 on error. A declined UAC prompt or a cancelled
  update exits 0 when a usable user directory remains.

  Windows 7 is best effort: Windows PowerShell 5.1 runs, but Hugo releases
  after v0.118.2 and current Dart Sass builds generally require Windows 10 or
  newer. The script warns instead of refusing so an old, working release can
  still be installed.
#>
[CmdletBinding()]
param(
  [Parameter(Position = 0)]
  [string]$Version = '',

  [string]$InstallDir = '',

  [switch]$NoEscalate,
  [switch]$System,
  [switch]$User,
  [switch]$Escalate,

  [switch]$Extended,
  [switch]$NoExtended,
  [switch]$WithDeploy,
  [switch]$NoWithDeploy,

  [string]$Method = '',

  [switch]$Verify,
  [switch]$NoVerify,
  [switch]$Force,
  [switch]$NoForce,
  [switch]$Yes,
  [switch]$Uninstall,
  [switch]$DryRun,
  [switch]$PrintEnv,
  [switch]$PrintPath,
  [switch]$NoPath,

  [switch]$Man,
  [switch]$NoMan,
  [string]$Completions = '',
  [switch]$NoCompletions,
  [string]$ShareDir = '',

  [switch]$Quiet,

  [string]$Downloader = '',
  [string[]]$DownloaderArgs = @(),
  [string]$GitHubToken = '',

  [switch]$Help,

  # Internal hooks used by the elevated write helper and the test harness.
  [Parameter(DontShow = $true)][string]$ElevatedManifest = '',
  [Parameter(DontShow = $true)][string]$ElevatedResult = '',
  [Parameter(DontShow = $true)][string]$PromptResponse = '',
  [Parameter(DontShow = $true)][string]$PathScope = '',
  [Parameter(DontShow = $true)][string]$RepoUrl = '',
  [Parameter(DontShow = $true)][string]$ApiBase = '',
  [Parameter(DontShow = $true)][string]$ReleaseBase = ''
)

$ErrorActionPreference = 'Stop'

$script:ToolName = 'hugo'
$script:DisplayName = 'Hugo'
$script:Repo = 'gohugoio/hugo'
$script:RepoUrl = if ($RepoUrl) { $RepoUrl.TrimEnd('/') } else { 'https://github.com/gohugoio/hugo' }
$script:ApiBase = if ($ApiBase) { $ApiBase.TrimEnd('/') } else { 'https://api.github.com' }
$script:ReleaseBase = if ($ReleaseBase) { $ReleaseBase.TrimEnd('/') } else { "$script:RepoUrl/releases/download" }

# Environment-derived options are resolved by Initialize-Options, which runs
# from Invoke-Main after the helper functions below have been defined.
$script:VerifyFile = $true
$script:ForceInstall = $false
$script:AssumeYes = $Yes.IsPresent
$script:DownloaderArgs = @($DownloaderArgs)
$script:QuietMode = $Quiet.IsPresent
$script:WorkDir = ''
$script:SystemOnly = $System.IsPresent
$script:UserOnly = $User.IsPresent
$script:NeedsElevation = $false
$script:ResolvedVersion = ''
$script:ResolvedAsset = ''
$script:AssetEdition = 'standard'
$script:RequestedEdition = 'standard'
$script:CrossArch = $false
$script:StageDir = ''
$script:PrintEnvMode = $false
$script:PrintPathMode = $false
$script:NoPathMode = $false
$script:PathScopeOverride = ''
$script:DryRunMode = $false
$script:NoEscalateMode = $false
$script:InstallDirArg = ''
$script:ShareDirArg = ''
$script:EscalateMode = 'auto'
$script:MethodArg = 'auto'
$script:DownloaderName = 'auto'
$script:InstallDirExplicit = $false
$script:ShareDirExplicit = $false
$script:VersionExplicit = $false
$script:ExtendedArg = $false
$script:WithDeployArg = $false
$script:ManpagesArg = $true
$script:ManpagesSet = $false
$script:CompletionsArg = 'auto'
$script:CompletionsSet = $false
$script:CompletionsOff = $false
$script:ExtrasPlan = $null
$script:ExtrasInstalled = @()
$script:LegacyWindows = $false
$script:EscalationLabel = 'none'

$script:Usage = @'
 install-hugo.ps1 -- install the Hugo CLI on Windows.

Usage:
  .\install-hugo.ps1 [options] [version]

Options:
  -Version VERSION       Hugo version, with or without the "v" prefix.
                         Default: latest (or $env:HUGO_VERSION).
  -InstallDir DIR        Directory that receives hugo.exe. Default:
                         Program Files\Hugo when writable or reachable through
                         one UAC prompt, otherwise %LOCALAPPDATA%\Programs\Hugo.
                         $env:HUGO_INSTALL_DIR is the environment equivalent.
                         An explicit directory is never silently replaced when
                         it cannot be written.
  -NoEscalate            Never request UAC; install into a writable user
                         directory instead.
  -System                Require a system-wide install; fail when Program Files
                         cannot be written and UAC is unavailable or declined.
  -User                  Install into %LOCALAPPDATA%\Programs\Hugo and never
                         request UAC. Cannot be combined with -System,
                         -InstallDir, or -Escalate.
  -Escalate              Require a system-wide install through UAC and fail
                         instead of falling back to the user directory.
  -Extended              Request the Extended edition (v0.43.0-v0.169.x).
  -NoExtended            Request the standard edition.
  -WithDeploy            Request the Deploy build ("withdeploy" from
                         v0.170.0, included in Extended from v0.137.0).
  -NoWithDeploy          Disable a Deploy request inherited from the
                         environment.
  -Method METHOD         Only "auto" and "binary" are valid on Windows.
  -NoVerify              Skip checksum verification. The smoke test still
                         runs.
  -Force                 Reinstall even when the version matches.
  -Yes                   Replace an installed version or remove it without
                         asking for confirmation. $env:HUGO_YES is the
                         environment equivalent.
  -Uninstall             Remove hugo.exe and the manpages and completions
                         installed by this script and exit. Use -InstallDir or
                         -User to select the binary location and -ShareDir when
                         the extras do not live under <InstallDir>\share.
                         -DryRun lists the files without removing them.
  -DryRun                Resolve and print what would be installed without
                         downloading, writing, or requesting UAC.
  -PrintEnv              Print HUGO_VERSION, HUGO_BIN, and HUGO_DIR.
  -PrintPath             Print only the install directory (for PATH).
  -NoPath                Do not add the install directory to PATH (persistent,
                         or $env:GITHUB_PATH in GitHub Actions); print a manual
                         snippet instead. $env:HUGO_NO_PATH is the environment
                         equivalent.
  -Man                   Generate and install manpages (default).
  -NoMan                 Do not generate or install manpages.
  -Completions SHELLS    bash, fish, zsh, powershell, all, or none. Default:
                         auto (the supported shells installed on this system).
  -NoCompletions         Do not generate or install shell completions.
  -ShareDir DIR          Directory for manpages and completions. Default:
                         <InstallDir>\share. $env:HUGO_SHARE_DIR is the
                         environment equivalent.
  -Quiet                 Suppress progress notes (warnings still print).
  -Downloader NAME       auto, httpclient, curl, aria2, wget, axel, or mwget.
  -DownloaderArgs ARGS   Extra arguments for an external downloader. Prefer an
                         array; $env:DOWNLOADER_ARGS is split on whitespace.
  -GitHubToken TOKEN     GitHub API token for latest/digest lookups. Prefer
                         $env:GITHUB_TOKEN so the token is not in the command
                         line.
  -Help                  Show this help.

Environment:
  HUGO_ESCALATE (auto|never|always), HUGO_VERSION, HUGO_INSTALL_DIR,
  HUGO_EXTENDED, HUGO_WITHDEPLOY, HUGO_VERIFY, HUGO_FORCE, HUGO_YES,
  HUGO_MANPAGES, HUGO_COMPLETIONS, HUGO_SHARE_DIR, HUGO_NO_PATH, GITHUB_TOKEN,
  DOWNLOADER, DOWNLOADER_ARGS.

Windows notes:
  The archive is extracted into the install directory as-is (hugo.exe), and
  manpages and completions go under <InstallDir>\share. No 7-Zip is required.

  The install directory is appended to the persistent machine PATH for a
  system-wide install, or to the persistent user PATH otherwise (idempotent;
  no duplicates). -NoPath prints a manual snippet instead. In GitHub Actions
  the script appends to $env:GITHUB_PATH instead of the persistent PATH, and
  writes hugo-style step outputs to $env:GITHUB_OUTPUT.

  When Program Files is used, a single UAC prompt elevates only the file copy;
  downloading, verification, and extraction stay in the non-elevated parent.
  Declining UAC falls back to the user directory unless -System or -Escalate
  was requested.

  Windows 7 is best effort: Hugo releases after v0.118.2 generally require
  Windows 10 or newer. The script warns instead of refusing.

Exit status: 0 on success, 1 on error.
'@

# ---------------------------------------------------------------------------
# Logging and small helpers
# ---------------------------------------------------------------------------

function Get-EnvValue {
  param([string]$Name, [string]$Default)
  $value = [Environment]::GetEnvironmentVariable($Name)
  if ([string]::IsNullOrEmpty($value)) { return $Default }
  return $value
}

function Initialize-Options {
  $script:VersionExplicit = -not [string]::IsNullOrEmpty($Version)
  $script:Version = if ($Version) { $Version } else { Get-EnvValue 'HUGO_VERSION' 'latest' }
  $script:NoPathMode = $NoPath.IsPresent -or (Test-Truthy (Get-EnvValue 'HUGO_NO_PATH' '0'))
  $script:PathScopeOverride = $PathScope
  $script:InstallDirArg = if ($InstallDir) { $InstallDir } else { Get-EnvValue 'HUGO_INSTALL_DIR' '' }
  $script:ShareDirArg = if ($ShareDir) { $ShareDir } else { Get-EnvValue 'HUGO_SHARE_DIR' '' }
  $script:EscalateMode = Get-EnvValue 'HUGO_ESCALATE' 'auto'
  $script:MethodArg = if ($Method) { $Method } else { Get-EnvValue 'HUGO_METHOD' 'auto' }
  $script:DownloaderName = if ($Downloader) { $Downloader } else { Get-EnvValue 'DOWNLOADER' 'auto' }
  $script:GitHubToken = if ($GitHubToken) { $GitHubToken } else { Get-EnvValue 'GITHUB_TOKEN' '' }
  $script:InstallDirExplicit = -not [string]::IsNullOrEmpty($script:InstallDirArg)
  $script:ShareDirExplicit = -not [string]::IsNullOrEmpty($script:ShareDirArg)

  if (@($script:DownloaderArgs).Count -eq 0) {
    $rawArgs = Get-EnvValue 'DOWNLOADER_ARGS' ''
    if (-not [string]::IsNullOrWhiteSpace($rawArgs)) {
      $script:DownloaderArgs = @($rawArgs -split '\s+' | Where-Object { $_ })
    }
  }

  $extendedEnv = Get-EnvValue 'HUGO_EXTENDED' 'false'
  $deployEnv = Get-EnvValue 'HUGO_WITHDEPLOY' 'false'
  if ($NoExtended.IsPresent) {
    $script:ExtendedArg = $false
  } elseif ($Extended.IsPresent) {
    $script:ExtendedArg = $true
  } else {
    $script:ExtendedArg = Test-Truthy $extendedEnv
  }
  if ($NoWithDeploy.IsPresent) {
    $script:WithDeployArg = $false
  } elseif ($WithDeploy.IsPresent) {
    $script:WithDeployArg = $true
  } else {
    $script:WithDeployArg = Test-Truthy $deployEnv
  }

  $manEnv = Get-EnvValue 'HUGO_MANPAGES' '1'
  if ($NoMan.IsPresent) {
    $script:ManpagesArg = $false
    $script:ManpagesSet = $true
  } elseif ($Man.IsPresent) {
    $script:ManpagesArg = $true
    $script:ManpagesSet = $true
  } else {
    $script:ManpagesArg = (Test-Truthy $manEnv) -or ($manEnv.ToLowerInvariant() -eq 'auto')
  }

  if ($NoCompletions.IsPresent) {
    $script:CompletionsArg = ''
    $script:CompletionsSet = $true
    $script:CompletionsOff = $true
  } elseif (-not [string]::IsNullOrEmpty($Completions)) {
    $script:CompletionsArg = $Completions
    $script:CompletionsSet = $true
  } else {
    $script:CompletionsArg = Get-EnvValue 'HUGO_COMPLETIONS' 'auto'
  }

  if (-not [string]::IsNullOrEmpty((Get-EnvValue 'HUGO_PREFIX' ''))) {
    Write-Warn 'HUGO_PREFIX is not supported on Windows and will be ignored; set HUGO_INSTALL_DIR to the install directory instead.'
  }
}

function Write-Note {
  param([string]$Message)
  if ($script:QuietMode) { return }
  [Console]::Error.WriteLine("==> $Message")
}

function Write-Warn {
  param([string]$Message)
  [Console]::Error.WriteLine("warning: $Message")
}

function Write-DryLine {
  param([string]$Message)
  if ($script:PrintEnvMode -or $script:PrintPathMode) {
    [Console]::Error.WriteLine($Message)
  } else {
    [Console]::Out.WriteLine($Message)
  }
}

function Test-Truthy {
  param([string]$Value)
  if ($null -eq $Value) { return $false }
  return @('1', 'true', 'yes', 'on') -contains $Value.ToLowerInvariant()
}

function Get-VersionParts {
  param([string]$Value)
  $clean = $Value.Trim()
  if ($clean.StartsWith('v') -or $clean.StartsWith('V')) { $clean = $clean.Substring(1) }
  $parts = $clean -split '\.'
  $numbers = @()
  for ($i = 0; $i -lt 3; $i++) {
    $part = '0'
    if ($i -lt $parts.Count) { $part = $parts[$i] }
    $part = $part -replace '-.*$', ''
    if ($part -notmatch '^\d+$') { $part = '0' }
    $numbers += [int]$part
  }
  return $numbers
}

function Test-VersionGe {
  param([string]$Left, [string]$Right)
  $a = Get-VersionParts $Left
  $b = Get-VersionParts $Right
  for ($i = 0; $i -lt 3; $i++) {
    if ($a[$i] -gt $b[$i]) { return $true }
    if ($a[$i] -lt $b[$i]) { return $false }
  }
  return $true
}

function Test-LegacyWindows {
  try {
    return ([Environment]::OSVersion.Version.Major -lt 10)
  } catch {
    return $false
  }
}

function Get-PlatformArch {
  $runner = [Environment]::GetEnvironmentVariable('RUNNER_ARCH')
  if ($runner) {
    switch ($runner.ToUpperInvariant()) {
      'X64' { return 'amd64' }
      'X86' { return '386' }
      'ARM64' { return 'arm64' }
      'ARM' { return 'arm' }
    }
  }

  $native = [Environment]::GetEnvironmentVariable('PROCESSOR_ARCHITEW6432')
  if ([string]::IsNullOrEmpty($native)) {
    $native = [Environment]::GetEnvironmentVariable('PROCESSOR_ARCHITECTURE')
  }
  switch ($native) {
    'AMD64' { return 'amd64' }
    'ARM64' { return 'arm64' }
    'x86' { return '386' }
    'ARM' { return 'arm' }
  }
  throw "unsupported Windows architecture: '$native'"
}

function Test-IsAdmin {
  $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = New-Object Security.Principal.WindowsPrincipal -ArgumentList $identity
  return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-IsCi {
  foreach ($name in @('CI', 'GITHUB_ACTIONS', 'GITLAB_CI', 'NETLIFY', 'CF_PAGES', 'BUILD_ID', 'TRAVIS', 'CIRCLECI')) {
    if (-not [string]::IsNullOrEmpty([Environment]::GetEnvironmentVariable($name))) { return $true }
  }
  return $false
}

function Test-IsInteractive {
  if (-not [Environment]::UserInteractive) { return $false }
  if ([Console]::IsInputRedirected) { return $false }
  if (Test-IsCi) { return $false }
  return $true
}

function Read-Confirmation {
  param([string]$Message)
  if (-not [string]::IsNullOrEmpty($PromptResponse)) {
    return ($PromptResponse -match '^(?i:y|yes)$')
  }
  if (-not (Test-IsInteractive)) { return $false }
  [Console]::Error.Write("$Message [y/N] ")
  $answer = [Console]::ReadLine()
  if ($null -eq $answer) { return $false }
  return ($answer -match '^(?i:y|yes)$')
}

function Resolve-UserPath {
  param([string]$PathValue)
  if ([string]::IsNullOrWhiteSpace($PathValue)) { throw 'an empty path was provided.' }
  $value = $PathValue.Trim()
  if ($value -eq '~') {
    $value = $HOME
  } elseif ($value.StartsWith('~/') -or $value.StartsWith('~\')) {
    $value = Join-Path $HOME $value.Substring(2)
  }
  $value = [Environment]::ExpandEnvironmentVariables($value)
  if (-not [IO.Path]::IsPathRooted($value)) {
    $value = Join-Path (Get-Location).Path $value
  }
  return [IO.Path]::GetFullPath($value)
}

function Test-CanWriteTo {
  param([string]$Directory)
  try {
    if (-not (Test-Path -LiteralPath $Directory)) {
      New-Item -ItemType Directory -Path $Directory -Force | Out-Null
    }
    $probe = Join-Path $Directory ('.install-dir-test.' + [Guid]::NewGuid().ToString('N'))
    [IO.File]::WriteAllText($probe, '')
    Remove-Item -LiteralPath $probe -Force
    return $true
  } catch {
    return $false
  }
}

function Get-SystemProgramFiles {
  param([string]$Arch)
  if ($Arch -eq '386') {
    $x86 = [Environment]::GetEnvironmentVariable('ProgramFiles(x86)')
    if (-not [string]::IsNullOrEmpty($x86)) { return $x86 }
    return [Environment]::GetEnvironmentVariable('ProgramFiles')
  }
  $native = [Environment]::GetEnvironmentVariable('ProgramW6432')
  if (-not [string]::IsNullOrEmpty($native)) { return $native }
  return [Environment]::GetEnvironmentVariable('ProgramFiles')
}

function Get-UserProgramsDir {
  $local = [Environment]::GetFolderPath([Environment+SpecialFolder]::LocalApplicationData)
  if ([string]::IsNullOrEmpty($local)) {
    $local = [Environment]::GetEnvironmentVariable('LOCALAPPDATA')
  }
  if ([string]::IsNullOrEmpty($local)) { throw 'LOCALAPPDATA is not set; use -InstallDir.' }
  return (Join-Path $local 'Programs')
}

function Test-CanElevate {
  if ($script:NoEscalateMode) { return $false }
  if ($script:EscalateMode -eq 'never') { return $false }
  if (Test-IsAdmin) { return $true }
  if (Test-IsCi) { return $false }
  if (-not [Environment]::UserInteractive) { return $false }
  if ([Console]::IsInputRedirected) { return $false }
  return $true
}

function Get-InstallDirPlan {
  param([string]$Arch)
  $result = @{ Path = ''; NeedsElevation = $false; Label = 'none' }

  if ($script:UserOnly) {
    $result.Path = Join-Path (Get-UserProgramsDir) 'Hugo'
    return $result
  }

  if ($script:InstallDirExplicit) {
    $explicit = Resolve-UserPath $script:InstallDirArg
    $result.Path = $explicit
    if (Test-CanWriteTo $explicit) { return $result }
    if ($script:DryRunMode) {
      if (Test-CanElevate) { $result.NeedsElevation = $true; $result.Label = 'uac' }
      return $result
    }
    if (Test-CanElevate) {
      $result.NeedsElevation = $true
      $result.Label = 'uac'
      return $result
    }
    throw "cannot write to $explicit (explicit -InstallDir); choose a writable directory or run from an elevated PowerShell."
  }

  $system = Join-Path (Get-SystemProgramFiles $Arch) 'Hugo'
  if (Test-CanWriteTo $system) {
    $result.Path = $system
    return $result
  }

  if ($script:SystemOnly -or $script:EscalateMode -eq 'always') {
    if ($script:DryRunMode) {
      $result.Path = $system
      if (Test-CanElevate) {
        $result.NeedsElevation = $true
        $result.Label = 'uac'
        return $result
      }
      throw "cannot install into $system for -System; run from an elevated PowerShell, allow the UAC prompt, or pass -InstallDir."
    }
    if (Test-CanElevate) {
      $result.Path = $system
      $result.NeedsElevation = $true
      $result.Label = 'uac'
      return $result
    }
    throw "cannot install into $system for -System; run from an elevated PowerShell, allow the UAC prompt, or pass -InstallDir."
  }

  if (Test-CanElevate) {
    $result.Path = $system
    $result.NeedsElevation = $true
    $result.Label = 'uac'
    return $result
  }

  $result.Path = Join-Path (Get-UserProgramsDir) 'Hugo'
  return $result
}

function Get-ShareDir {
  param([string]$InstallDirectory)
  if ($script:ShareDirExplicit) {
    return (Resolve-UserPath $script:ShareDirArg)
  }
  return (Join-Path $InstallDirectory 'share')
}
# ---------------------------------------------------------------------------
# HTTP and hashing
# ---------------------------------------------------------------------------

function Initialize-HttpAssemblies {
  try { Add-Type -AssemblyName System.Net.Http -ErrorAction Stop } catch { }
  try { Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction Stop } catch { }
  try { Add-Type -AssemblyName System.IO.Compression -ErrorAction Stop } catch { }
}

function New-HttpClient {
  param([bool]$WithToken)
  Initialize-HttpAssemblies
  $handler = New-Object System.Net.Http.HttpClientHandler
  $handler.AllowAutoRedirect = $true
  $client = New-Object System.Net.Http.HttpClient -ArgumentList $handler
  $client.Timeout = [TimeSpan]::FromSeconds(60)
  $client.DefaultRequestHeaders.UserAgent.ParseAdd('farrelf-blog-installer/1.0')
  if ($WithToken -and -not [string]::IsNullOrEmpty($script:GitHubToken)) {
    $client.DefaultRequestHeaders.Authorization =
      New-Object System.Net.Http.Headers.AuthenticationHeaderValue -ArgumentList 'Bearer', $script:GitHubToken
  }
  return $client
}

function Invoke-HttpText {
  param([string]$Url, [bool]$WithToken = $false)
  $client = New-HttpClient $WithToken
  try {
    $response = $client.GetAsync($Url).GetAwaiter().GetResult()
    if (-not $response.IsSuccessStatusCode) {
      throw "HTTP $([int]$response.StatusCode) for $Url"
    }
    return $response.Content.ReadAsStringAsync().GetAwaiter().GetResult()
  } finally {
    $client.Dispose()
  }
}

function Test-UrlExists {
  param([string]$Url)
  $client = New-HttpClient $false
  try {
    $request = New-Object System.Net.Http.HttpRequestMessage -ArgumentList ([System.Net.Http.HttpMethod]::Head), $Url
    $response = $client.SendAsync($request).GetAwaiter().GetResult()
    $code = [int]$response.StatusCode
    if ($code -ge 200 -and $code -lt 400) { return $true }
    if ($code -eq 405 -or $code -eq 501) {
      $request2 = New-Object System.Net.Http.HttpRequestMessage -ArgumentList ([System.Net.Http.HttpMethod]::Get), $Url
      $request2.Headers.Range = New-Object System.Net.Http.Headers.RangeHeaderValue -ArgumentList 0, 0
      $response2 = $client.SendAsync($request2).GetAwaiter().GetResult()
      $code2 = [int]$response2.StatusCode
      return ($code2 -ge 200 -and $code2 -lt 400)
    }
    return $false
  } catch {
    return $false
  } finally {
    $client.Dispose()
  }
}

function Resolve-LatestTag {
  $redirectUrl = "$script:RepoUrl/releases/latest"
  try {
    $client = New-HttpClient $false
    try {
      $response = $client.GetAsync($redirectUrl, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).GetAwaiter().GetResult()
      $final = $response.RequestMessage.RequestUri.AbsoluteUri
      $match = [regex]::Match($final, '/tag/([^/?#]+)')
      if ($match.Success) { return $match.Groups[1].Value }
    } finally {
      $client.Dispose()
    }
  } catch { }
  Write-Warn "could not resolve 'latest' through the releases redirect; falling back to the GitHub API"
  $json = Invoke-HttpText "$script:ApiBase/repos/$script:Repo/releases/latest" $true
  $release = $json | ConvertFrom-Json
  if ([string]::IsNullOrEmpty($release.tag_name)) { throw 'the GitHub API returned no tag_name for the latest release.' }
  return $release.tag_name
}

function Get-ReleaseAssetDigest {
  param([string]$Tag, [string]$AssetName)
  $url = "$script:ApiBase/repos/$script:Repo/releases/tags/$Tag"
  $json = Invoke-HttpText $url $true
  $release = $json | ConvertFrom-Json
  foreach ($asset in @($release.assets)) {
    if ($asset.name -eq $AssetName) {
      if ([string]::IsNullOrEmpty($asset.digest)) { return $null }
      if ($asset.digest -match '^sha256:(?<hex>[0-9a-fA-F]{64})$') { return $Matches['hex'].ToLowerInvariant() }
      return $null
    }
  }
  return $null
}

function Get-Sha256 {
  param([string]$File)
  $sha = [Security.Cryptography.SHA256]::Create()
  $stream = [IO.File]::OpenRead($File)
  try {
    $bytes = $sha.ComputeHash($stream)
  } finally {
    $stream.Dispose()
    $sha.Dispose()
  }
  return (([BitConverter]::ToString($bytes)) -replace '-', '').ToLowerInvariant()
}

function Test-Sha256 {
  param([string]$Expected, [string]$File)
  $actual = Get-Sha256 $File
  [Console]::Error.WriteLine("Expected SHA256: $Expected")
  [Console]::Error.WriteLine("Actual SHA256:   $actual")
  return ($Expected.ToLowerInvariant() -eq $actual)
}

function Resolve-Downloader {
  $name = $script:DownloaderName
  if ([string]::IsNullOrEmpty($name) -or $name -eq 'auto') { $name = 'httpclient' }
  switch ($name.ToLowerInvariant()) {
    'httpclient' { return 'httpclient' }
    'aria2' { $name = 'aria2c' }
    '2c' { $name = 'aria2c' }
  }
  $command = Get-Command $name -ErrorAction SilentlyContinue
  if ($null -eq $command) {
    if ($name -eq 'aria2c') {
      Write-Warn "'aria2c' is not installed; falling back to the native HttpClient downloader."
      return 'httpclient'
    }
    throw "downloader '$name' is not installed."
  }
  return $name
}

function Get-DefaultDownloaderArgs {
  param([string]$Name)
  switch ($Name) {
    'aria2c' { return @('-c', '-x16', '-s16', '-j16', '-U', 'Mozilla/5.0') }
    'curl' { return @('-L', '-f', '-sS', '--retry', '2', '--connect-timeout', '15', '-A', 'Mozilla/5.0') }
    'wget' { return @('-c', '-U', 'Mozilla/5.0') }
    'axel' { return @('-a', '-n', '16', '-U', 'Mozilla/5.0') }
    'mwget' { return @('-n', '16', '-c', '-U', 'Mozilla/5.0') }
  }
  return @()
}

function Get-RemoteFile {
  param([string]$Url, [string]$Destination, [bool]$WithToken = $false)

  if ((Test-Path -LiteralPath $Destination) -and ((Get-Item -LiteralPath $Destination).Length -gt 0)) {
    return
  }

  $downloader = Resolve-Downloader
  $extra = @($script:DownloaderArgs)
  if ($extra.Count -eq 0) { $extra = Get-DefaultDownloaderArgs $downloader }

  $attempt = 1
  while ($attempt -le 2) {
    try {
      if ($downloader -eq 'httpclient') {
        $client = New-HttpClient $WithToken
        try {
          $response = $client.GetAsync($Url, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).GetAwaiter().GetResult()
          if (-not $response.IsSuccessStatusCode) {
            throw "HTTP $([int]$response.StatusCode)"
          }
          $inputStream = $response.Content.ReadAsStreamAsync().GetAwaiter().GetResult()
          $outputStream = [IO.File]::Create($Destination)
          try { $inputStream.CopyTo($outputStream) } finally { $outputStream.Dispose(); $inputStream.Dispose() }
        } finally {
          $client.Dispose()
        }
      } else {
        $arguments = @()
        if ($downloader -eq 'curl') {
          $arguments = @($extra) + @('-o', $Destination, $Url)
        } elseif ($downloader -eq 'wget') {
          $arguments = @($extra) + @('-O', $Destination, $Url)
        } elseif ($downloader -eq 'aria2c') {
          $arguments = @($extra) + @('-d', [IO.Path]::GetDirectoryName($Destination), '-o', [IO.Path]::GetFileName($Destination), $Url)
        } else {
          $arguments = @($extra) + @('-o', $Destination, $Url)
        }
        & $downloader @arguments
        if ($LASTEXITCODE -ne 0) { throw "downloader exited with code $LASTEXITCODE" }
      }

      if ((Test-Path -LiteralPath $Destination) -and ((Get-Item -LiteralPath $Destination).Length -gt 0)) {
        return
      }
      throw 'the downloaded file is empty.'
    } catch {
      Write-Warn "download attempt $attempt failed for $([IO.Path]::GetFileName($Destination)): $($_.Exception.Message)"
      if (Test-Path -LiteralPath $Destination) { Remove-Item -LiteralPath $Destination -Force -ErrorAction SilentlyContinue }
      $attempt++
    }
  }
  throw "failed to download $Url."
}

# ---------------------------------------------------------------------------
# Safe archive extraction and gzip
# ---------------------------------------------------------------------------

function Expand-ZipSafely {
  param([string]$ZipPath, [string]$Destination)

  Initialize-HttpAssemblies
  if (-not (Test-Path -LiteralPath $Destination)) {
    New-Item -ItemType Directory -Path $Destination -Force | Out-Null
  }
  $root = [IO.Path]::GetFullPath($Destination).TrimEnd('\', '/')
  $archive = [IO.Compression.ZipFile]::OpenRead($ZipPath)
  try {
    foreach ($entry in $archive.Entries) {
      $name = $entry.FullName -replace '\\', '/'
      if ([string]::IsNullOrEmpty($name)) { continue }
      if ($name.StartsWith('/') -or $name -match '^[A-Za-z]:' -or $name -match '(^|/)\.\.(/|$)') {
        throw "refusing to extract an unsafe archive entry: $name"
      }
      $target = [IO.Path]::GetFullPath((Join-Path $root ($name -replace '/', [IO.Path]::DirectorySeparatorChar)))
      if (-not ($target.Equals($root, [StringComparison]::OrdinalIgnoreCase) -or
        $target.StartsWith($root + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase))) {
        throw "refusing to extract an archive entry outside the destination: $name"
      }
      if ([string]::IsNullOrEmpty($entry.Name)) {
        if (-not (Test-Path -LiteralPath $target)) { New-Item -ItemType Directory -Path $target -Force | Out-Null }
        continue
      }
      $parent = [IO.Path]::GetDirectoryName($target)
      if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
      [IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $target, $true)
    }
  } finally {
    $archive.Dispose()
  }
}

function Compress-GzipFile {
  param([string]$Source, [string]$Destination)
  $inputStream = [IO.File]::OpenRead($Source)
  $outputStream = [IO.File]::Create($Destination)
  $gzip = New-Object IO.Compression.GZipStream -ArgumentList $outputStream, ([IO.Compression.CompressionMode]::Compress)
  try {
    $inputStream.CopyTo($gzip)
  } finally {
    $gzip.Dispose()
    $outputStream.Dispose()
    $inputStream.Dispose()
  }
}

function Test-ZipFile {
  param([string]$Path)
  try {
    $stream = [IO.File]::OpenRead($Path)
    try {
      $bytes = New-Object byte[] 4
      $count = $stream.Read($bytes, 0, 4)
      if ($count -lt 4) { return $false }
      return ($bytes[0] -eq 0x50 -and $bytes[1] -eq 0x4b)
    } finally {
      $stream.Dispose()
    }
  } catch {
    return $false
  }
}

# ---------------------------------------------------------------------------
# Manifest execution (direct or elevated)
# ---------------------------------------------------------------------------

function Test-SafeRoot {
  param([string]$Root)
  $value = [IO.Path]::GetFullPath($Root).TrimEnd('\', '/')
  if ($value -match '^[A-Za-z]:$') { return $false }
  $forbidden = @(
    [Environment]::GetEnvironmentVariable('SystemRoot'),
    [Environment]::GetEnvironmentVariable('ProgramFiles'),
    [Environment]::GetEnvironmentVariable('ProgramFiles(x86)'),
    [Environment]::GetEnvironmentVariable('ProgramW6432')
  )
  foreach ($item in $forbidden) {
    if ([string]::IsNullOrEmpty($item)) { continue }
    if ($value.Equals([IO.Path]::GetFullPath($item).TrimEnd('\', '/'), [StringComparison]::OrdinalIgnoreCase)) {
      return $false
    }
  }
  return $true
}

function Test-PathUnder {
  param([string]$PathValue, [string]$Root)
  $path = [IO.Path]::GetFullPath($PathValue).TrimEnd('\', '/')
  $base = [IO.Path]::GetFullPath($Root).TrimEnd('\', '/')
  if ($path.Equals($base, [StringComparison]::OrdinalIgnoreCase)) { return $true }
  return $path.StartsWith($base + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)
}

function Copy-FileAtomic {
  param([string]$Source, [string]$Destination)
  $parent = [IO.Path]::GetDirectoryName($Destination)
  if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
  $temporary = "$Destination.tmp.$PID"
  $attempt = 1
  while ($attempt -le 3) {
    try {
      [IO.File]::Copy($Source, $temporary, $true)
      if (Test-Path -LiteralPath $Destination) {
        $backup = "$Destination.bak.$PID"
        [IO.File]::Replace($temporary, $Destination, $backup, $true)
        if (Test-Path -LiteralPath $backup) { Remove-Item -LiteralPath $backup -Force -ErrorAction SilentlyContinue }
      } else {
        [IO.File]::Move($temporary, $Destination)
      }
      return
    } catch {
      if (Test-Path -LiteralPath $temporary) { Remove-Item -LiteralPath $temporary -Force -ErrorAction SilentlyContinue }
      if ($attempt -ge 3) { throw "cannot write ${Destination}: $($_.Exception.Message)" }
      Start-Sleep -Milliseconds 200
      $attempt++
    }
  }
}

function Copy-TreeSafe {
  param([string]$Source, [string]$Destination)
  $sourceRoot = [IO.Path]::GetFullPath($Source).TrimEnd('\', '/')
  $files = Get-ChildItem -LiteralPath $sourceRoot -Recurse -Force -File
  foreach ($file in $files) {
    $relative = $file.FullName.Substring($sourceRoot.Length).TrimStart('\', '/')
    if ($relative -match '(^|[\\/])\.\.([\\/]|$)') { throw "refusing to copy an unsafe relative path: $relative" }
    $target = Join-Path $Destination $relative
    Copy-FileAtomic $file.FullName $target
  }
}

function Invoke-ManifestOperations {
  param($Manifest, [bool]$Elevated)

  $roots = @()
  foreach ($root in @($Manifest.roots)) {
    $resolved = [IO.Path]::GetFullPath([string]$root).TrimEnd('\', '/')
    if (-not (Test-SafeRoot $resolved)) { throw "refusing to use an unsafe root: $resolved" }
    $roots += $resolved
  }
  if ($roots.Count -eq 0) { throw 'the manifest declares no destination root.' }

  $sourceRoot = ''
  if ($Manifest.sourceRoot) {
    $sourceRoot = [IO.Path]::GetFullPath([string]$Manifest.sourceRoot).TrimEnd('\', '/')
    if (-not (Test-SafeRoot $sourceRoot)) { throw "refusing to use an unsafe source root: $sourceRoot" }
  }

  foreach ($operation in @($Manifest.operations)) {
    $op = [string]$operation.op
    if ($op -eq 'copy' -or $op -eq 'copyTree') {
      $source = [IO.Path]::GetFullPath([string]$operation.source)
      $destination = [IO.Path]::GetFullPath([string]$operation.destination)
      if ([string]::IsNullOrEmpty($sourceRoot) -or -not (Test-PathUnder $source $sourceRoot)) {
        throw "refusing to copy from outside the staging directory: $source"
      }
      $allowed = $false
      foreach ($root in $roots) { if (Test-PathUnder $destination $root) { $allowed = $true; break } }
      if (-not $allowed) { throw "refusing to write outside the declared roots: $destination" }
      if ($op -eq 'copy') {
        Copy-FileAtomic $source $destination
      } else {
        Copy-TreeSafe $source $destination
      }
      continue
    }
    if ($op -eq 'remove' -or $op -eq 'removeTree') {
      $target = [IO.Path]::GetFullPath([string]$operation.path).TrimEnd('\', '/')
      $allowed = $false
      foreach ($root in $roots) {
        if ($target.Equals($root, [StringComparison]::OrdinalIgnoreCase)) {
          throw "refusing to remove a declared root: $target"
        }
        if (Test-PathUnder $target $root) { $allowed = $true; break }
      }
      if (-not $allowed) { throw "refusing to remove outside the declared roots: $target" }
      if (Test-Path -LiteralPath $target) {
        if ($op -eq 'removeTree') {
          Remove-Item -LiteralPath $target -Recurse -Force
        } else {
          Remove-Item -LiteralPath $target -Force
        }
      }
      continue
    }
    if ($op -eq 'path') {
      $scope = [string]$operation.scope
      if (@('Machine', 'User', 'Process') -notcontains $scope) { throw "unknown PATH scope: $scope" }
      $value = [IO.Path]::GetFullPath([string]$operation.value).TrimEnd('\', '/')
      try { [void](Add-PathEntry $value $scope) } catch { }
      continue
    }
    if ($op -eq 'path-remove') {
      $scope = [string]$operation.scope
      if (@('Machine', 'User', 'Process') -notcontains $scope) { throw "unknown PATH scope: $scope" }
      $value = [IO.Path]::GetFullPath([string]$operation.value).TrimEnd('\', '/')
      $anchor = [string]$operation.anchor
      if (-not [string]::IsNullOrEmpty($anchor) -and (Test-Path -LiteralPath $anchor)) { continue }
      try { [void](Remove-PathEntry $value $scope) } catch { }
      continue
    }
    throw "unknown manifest operation: $op"
  }
}

function Write-Utf8NoBom {
  param([string]$Path, [string]$Text)
  [IO.File]::WriteAllText($Path, $Text, [Text.UTF8Encoding]::new($false))
}

function Invoke-ElevatedManifest {
  param($Manifest)

  $id = [Guid]::NewGuid().ToString('N')
  $tempRoot = [IO.Path]::GetTempPath()
  $manifestPath = Join-Path $tempRoot "$script:ToolName-manifest-$id.json"
  $resultPath = Join-Path $tempRoot "$script:ToolName-result-$id.json"
  Write-Utf8NoBom $manifestPath (($Manifest | ConvertTo-Json -Depth 8))

  try {
    $executable = ''
    try { $executable = (Get-Process -Id $PID).Path } catch { }
    if ([string]::IsNullOrEmpty($executable)) {
      $name = 'powershell.exe'
      if ($PSVersionTable.PSEdition -eq 'Core') { $name = 'pwsh.exe' }
      $executable = Join-Path $PSHOME $name
    }

    $arguments = '-NoProfile -ExecutionPolicy Bypass -File "{0}" -ElevatedManifest "{1}" -ElevatedResult "{2}"' -f `
      $PSCommandPath, $manifestPath, $resultPath

    $startInfo = New-Object Diagnostics.ProcessStartInfo
    $startInfo.FileName = $executable
    $startInfo.Arguments = $arguments
    $startInfo.UseShellExecute = $true
    $startInfo.Verb = 'runas'
    $startInfo.WindowStyle = 'Normal'

    try {
      $process = [Diagnostics.Process]::Start($startInfo)
      $process.WaitForExit()
    } catch [System.ComponentModel.Win32Exception] {
      if ($_.Exception.NativeErrorCode -eq 1223) {
        return @{ Success = $false; Cancelled = $true; Errors = @('elevation was cancelled') }
      }
      throw
    }

    if (-not (Test-Path -LiteralPath $resultPath)) {
      return @{ Success = $false; Cancelled = $false; Errors = @('the elevated helper did not write a result file') }
    }
    $result = [IO.File]::ReadAllText($resultPath, [Text.UTF8Encoding]::new($false)) | ConvertFrom-Json
    return @{
      Success = [bool]$result.success
      Cancelled = $false
      Errors = @($result.errors | Where-Object { -not [string]::IsNullOrEmpty($_) })
    }
  } finally {
    if (Test-Path -LiteralPath $manifestPath) { Remove-Item -LiteralPath $manifestPath -Force -ErrorAction SilentlyContinue }
    if (Test-Path -LiteralPath $resultPath) { Remove-Item -LiteralPath $resultPath -Force -ErrorAction SilentlyContinue }
  }
}

function Invoke-ElevatedChild {
  param([string]$ManifestPath, [string]$ResultPath)
  $result = @{ success = $false; errors = @() }
  try {
    $manifest = [IO.File]::ReadAllText($ManifestPath, [Text.UTF8Encoding]::new($false)) | ConvertFrom-Json
    Invoke-ManifestOperations $manifest $true
    $result.success = $true
  } catch {
    $result.errors = @($_.Exception.Message)
  } finally {
    Write-Utf8NoBom $ResultPath (($result | ConvertTo-Json -Depth 5))
  }
  if ($result.success) { return 0 }
  return 1
}

function Invoke-WriteManifest {
  param($Manifest)
  if ($script:NeedsElevation) {
    $root = ''
    if (@($Manifest.roots).Count -gt 0) { $root = [string]@($Manifest.roots)[0] }
    Write-Note "$root is not writable; requesting one UAC prompt for the file operation."
    $result = Invoke-ElevatedManifest $Manifest
    if ($result.Success) { return @{ Success = $true; Cancelled = $false } }
    return $result
  }
  Invoke-ManifestOperations $Manifest $false
  return @{ Success = $true; Cancelled = $false }
}

# ---------------------------------------------------------------------------
# Process locks
# ---------------------------------------------------------------------------

function Test-InstallDirInUse {
  param([string]$Directory)
  $prefix = [IO.Path]::GetFullPath($Directory).TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
  foreach ($name in @('hugo')) {
    foreach ($process in @(Get-Process -Name $name -ErrorAction SilentlyContinue)) {
      try {
        $path = $process.Path
        if ($path -and $path.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) {
          return $process.ProcessName
        }
      } catch { }
    }
  }
  return $null
}
# ---------------------------------------------------------------------------
# Asset candidate rules
#
# Hugo has changed its Windows asset naming several times. The candidates below
# are probed in order with HEAD requests and the first hit wins. They mirror
# scripts/install-hugo.sh so both installers resolve the same asset.
# ---------------------------------------------------------------------------

function Get-EditionSuffix {
  param([string]$Edition)
  switch ($Edition) {
    'extended' { return '_extended' }
    'extended_withdeploy' { return '_extended_withdeploy' }
    'withdeploy' { return '_withdeploy' }
    default { return '' }
  }
}

function Get-HugoWindowsAssetNames {
  param([string]$Suffix, [string]$AssetVersion, [string]$Arch)
  $names = @()

  # v0.103.0+ uses lowercase GOOS-GOARCH names (no title-case alias).
  if (Test-VersionGe $AssetVersion '0.103.0') {
    switch ($Arch) {
      'amd64' { $names += "hugo${Suffix}_${AssetVersion}_windows-amd64.zip" }
      'arm64' { $names += "hugo${Suffix}_${AssetVersion}_windows-arm64.zip" }
    }
  }

  # v0.17-v0.102.3 uses title-case names; v0.20.3 alone published
  # v-prefixed asset names.
  if ((Test-VersionGe $AssetVersion '0.17') -and (Test-VersionGe '0.102.3' $AssetVersion)) {
    $prefix = "hugo${Suffix}_${AssetVersion}"
    if ($AssetVersion -eq '0.20.3') { $prefix = "hugo${Suffix}_v${AssetVersion}" }
    switch ($Arch) {
      'amd64' { $names += "${prefix}_Windows-64bit.zip" }
      'arm64' { $names += "${prefix}_Windows-ARM64.zip" }
      '386' { $names += "${prefix}_Windows-32bit.zip" }
    }
  }

  # v0.16
  if ($AssetVersion -eq '0.16') {
    switch ($Arch) {
      'amd64' { $names += "hugo${Suffix}_0.16_windows-64bit.zip" }
      '386' { $names += "hugo${Suffix}_0.16_windows-32bit.zip" }
    }
  }

  # v0.9-v0.15
  if ((Test-VersionGe $AssetVersion '0.9') -and (Test-VersionGe '0.15' $AssetVersion)) {
    switch ($Arch) {
      'amd64' { $names += "hugo${Suffix}_${AssetVersion}_windows_amd64.zip" }
      '386' {
        if ($AssetVersion -eq '0.15') {
          $names += "hugo${Suffix}_0.15_windows_386_32-bit-only.zip"
        } else {
          $names += "hugo${Suffix}_${AssetVersion}_windows_386.zip"
        }
      }
    }
  }

  # v0.8 and v0.7 published raw binaries without archives.
  if ($AssetVersion -eq '0.8') {
    switch ($Arch) {
      'amd64' { $names += 'hugo-windows-amd64' }
      '386' { $names += 'hugo-windows-386' }
    }
  }
  if ($AssetVersion -eq '0.7') {
    switch ($Arch) {
      'amd64' { $names += 'hugo-0.7-windows-x64' }
      '386' { $names += 'hugo-0.7-windows-386' }
    }
  }

  # Windows ARM64 exists from v0.89.0 (standard builds only); fall back to
  # AMD64, which runs through x64 emulation on Windows on ARM.
  if ($Arch -eq 'arm64') {
    $names += @(Get-HugoWindowsAssetNames $Suffix $AssetVersion 'amd64')
  }

  return $names
}

function Get-HugoAssetNames {
  param([string]$Suffix, [string]$AssetVersion, [string]$Arch)
  return @(Get-HugoWindowsAssetNames $Suffix $AssetVersion $Arch)
}

function Get-HugoVersionCandidates {
  param([string]$Value)
  $candidates = @($Value)
  if ($Value -match '^\d+\.\d+\.\d+$') {
    $patch = $Value.Split('.')[-1]
    if ($patch -eq '0') {
      $candidates += $Value.Substring(0, $Value.LastIndexOf('.'))
    }
  } elseif ($Value -match '^\d+\.\d+$') {
    $candidates += "$Value.0"
  }
  return $candidates
}

function Get-HugoEditionChain {
  param([string]$RequestedVersion)

  $script:RequestedEdition = 'standard'
  $chain = @('standard')

  if (Test-VersionGe $RequestedVersion '0.170.0') {
    if ($script:ExtendedArg) {
      Write-Note "Hugo v$RequestedVersion removed the Extended edition (v0.170.0); installing the equivalent standard build."
      if ($script:WithDeployArg) {
        Write-Note "The Deploy feature is provided by the 'withdeploy' build from v0.170.0; the 'extended' input has no additional effect."
      }
    }
    if ($script:WithDeployArg) {
      $script:RequestedEdition = 'withdeploy'
      $chain = @('withdeploy', 'standard')
    }
    return $chain
  }

  if ($script:ExtendedArg) {
    if (Test-VersionGe $RequestedVersion '0.43') {
      $script:RequestedEdition = 'extended'
      $chain = @('extended', 'standard')
      if ($script:WithDeployArg -and (Test-VersionGe $RequestedVersion '0.137.0')) {
        $script:RequestedEdition = 'extended_withdeploy'
        $chain = @('extended_withdeploy', 'extended', 'standard')
      }
    } else {
      Write-Warn "Hugo Extended is only published for v0.43.0 and later; installing the standard build for v$RequestedVersion."
      $chain = @('standard')
    }
    return $chain
  }

  if ($script:WithDeployArg -and (Test-VersionGe $RequestedVersion '0.159.2')) {
    $script:RequestedEdition = 'withdeploy'
    $chain = @('withdeploy', 'standard')
  }
  return $chain
}

function Resolve-HugoAsset {
  param([string]$RequestedVersion, [string]$Arch)

  $candidates = @(Get-HugoVersionCandidates $RequestedVersion)

  # Hugo v0.137.0 accidentally shipped without the Windows
  # "extended_withdeploy" archives; v0.137.1 restored them. Bump the request
  # transparently so Deploy is actually installed.
  $bumpedFrom = ''
  if ($script:ExtendedArg -and $script:WithDeployArg) {
    $newCandidates = @()
    foreach ($candidate in $candidates) {
      if ($candidate -eq '0.137.0') {
        $newCandidates += '0.137.1'
        $bumpedFrom = '0.137.0'
      } else {
        $newCandidates += $candidate
      }
    }
    $candidates = $newCandidates
  }

  $chain = @(Get-HugoEditionChain $RequestedVersion)

  foreach ($candidate in $candidates) {
    foreach ($edition in $chain) {
      $suffix = Get-EditionSuffix $edition
      foreach ($name in @(Get-HugoAssetNames $suffix $candidate $Arch)) {
        if (Test-UrlExists "$script:ReleaseBase/v$candidate/$name") {
          return @{ Version = $candidate; Asset = $name; BumpedFrom = $bumpedFrom }
        }
      }
    }
  }

  $first = $candidates[0]
  if (-not (Test-UrlExists "$script:RepoUrl/releases/tag/v$first")) {
    throw "Hugo v$first does not exist. Check the version against $script:RepoUrl/releases."
  }
  if ($script:RequestedEdition -ne 'standard') {
    throw "Hugo publishes no '$($script:RequestedEdition)' build for v$first on windows/$Arch; retry without -Extended or -WithDeploy to install the standard build."
  }
  if ($Arch -eq '386') {
    throw "Hugo v$first publishes no Windows 32-bit build (32-bit archives stop at v0.102.3); use a 64-bit system or request v0.102.3 or older."
  }
  throw "no matching Hugo release asset was found for v$first on windows/$Arch (tried editions: $($chain -join ', ')). Note that some releases publish no assets at all (for example, v0.139.5)."
}

function Get-AssetEdition {
  param([string]$AssetName)
  if ($AssetName -match 'extended_withdeploy') { return 'extended_withdeploy' }
  if ($AssetName -match 'extended') { return 'extended' }
  if ($AssetName -match 'withdeploy') { return 'withdeploy' }
  return 'standard'
}

# ---------------------------------------------------------------------------
# Completion shells
# ---------------------------------------------------------------------------

function Test-CompletionShellAvailable {
  param([string]$Shell)
  if ($Shell -eq 'powershell') { return $true }
  return ($null -ne (Get-Command $Shell -ErrorAction SilentlyContinue))
}

function Get-DetectedCompletionShells {
  $list = @()
  foreach ($shell in @('bash', 'fish', 'zsh', 'powershell')) {
    if (Test-CompletionShellAvailable $shell) { $list += $shell }
  }
  return $list
}

function Get-RequestedCompletionShells {
  if ($script:CompletionsOff) { return @() }
  $value = $script:CompletionsArg
  if ([string]::IsNullOrEmpty($value) -or $value -eq 'auto') {
    return @(Get-DetectedCompletionShells)
  }
  if (@('none', 'off', 'false', '0') -contains $value.ToLowerInvariant()) {
    return @()
  }
  return @(Normalize-Completions $value)
}

function Normalize-Completions {
  param([string]$Value)
  $list = @()
  foreach ($item in ($Value -split '[,\s]+')) {
    if ([string]::IsNullOrEmpty($item)) { continue }
    switch ($item.ToLowerInvariant()) {
      'all' { foreach ($shell in @('bash', 'fish', 'zsh', 'powershell')) { if ($list -notcontains $shell) { $list += $shell } } }
      'bash' { if ($list -notcontains 'bash') { $list += 'bash' } }
      'fish' { if ($list -notcontains 'fish') { $list += 'fish' } }
      'zsh' { if ($list -notcontains 'zsh') { $list += 'zsh' } }
      'powershell' { if ($list -notcontains 'powershell') { $list += 'powershell' } }
      default {
        throw "unknown completion shell: '$item' (supported: bash, fish, zsh, powershell)"
      }
    }
  }
  return $list
}

function Get-CompletionTarget {
  param([string]$Shell, [string]$ShareDirectory)
  switch ($Shell) {
    'bash' { return (Join-Path $ShareDirectory 'bash-completion\completions\hugo') }
    'zsh' { return (Join-Path $ShareDirectory 'zsh\site-functions\_hugo') }
    'fish' { return (Join-Path $ShareDirectory 'fish\vendor_completions.d\hugo.fish') }
    'powershell' { return (Join-Path $ShareDirectory 'powershell\completions\hugo.ps1') }
  }
  return ''
}

# ---------------------------------------------------------------------------
# Extras: manpages and shell completions
# ---------------------------------------------------------------------------

function New-HugoExtrasPlan {
  param([string]$HugoBinary, [string]$TempRoot = '')

  $plan = @{
    ManPages = @()
    Completions = @{}
    TempDir = ''
    Shells = @()
  }

  if (-not $script:ManpagesArg -and [string]::IsNullOrEmpty($script:CompletionsArg)) {
    return $plan
  }

  if ([string]::IsNullOrEmpty($TempRoot)) { $TempRoot = [IO.Path]::GetTempPath() }
  $tempDir = Join-Path $TempRoot ("hugo-extras-" + [Guid]::NewGuid().ToString('N'))
  New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
  $plan.TempDir = $tempDir

  if ($script:ManpagesArg) {
    $manDir = Join-Path $tempDir 'man'
    New-Item -ItemType Directory -Path $manDir -Force | Out-Null
    $genLog = Join-Path $tempDir 'man.log'
    $manOk = $false
    try {
      $null = & $HugoBinary gen man --dir $manDir 2> $genLog | Out-String -Width 4096
      if ($null -eq $LASTEXITCODE -or $LASTEXITCODE -eq 0) { $manOk = $true }
    } catch {
      $manOk = $false
      Write-Utf8NoBom $genLog $_.Exception.Message
    }
    if (-not $manOk) {
      $detail = ''
      try {
        if (Test-Path -LiteralPath $genLog) {
          $lines = [IO.File]::ReadAllLines($genLog, [Text.UTF8Encoding]::new($false))
          if ($lines.Count -gt 0 -and -not [string]::IsNullOrEmpty($lines[0])) { $detail = " $($lines[0])" }
        }
      } catch { }
      Write-Warn "Hugo v$($script:ResolvedVersion) could not generate manpages ('hugo gen man' failed); skipping.$detail"
    } else {
      $pages = @(Get-ChildItem -LiteralPath $manDir -Filter '*.1' -File -ErrorAction SilentlyContinue)
      if ($pages.Count -eq 0) {
        Write-Warn 'Hugo produced no manpage files; nothing was installed.'
      } else {
        foreach ($page in $pages) {
          $gzipPath = "$($page.FullName).gz"
          try {
            Compress-GzipFile $page.FullName $gzipPath
            Remove-Item -LiteralPath $page.FullName -Force -ErrorAction SilentlyContinue
            $plan.ManPages += $gzipPath
          } catch {
            Write-Warn "could not gzip $($page.FullName); skipping manpages."
            $plan.ManPages = @()
            break
          }
        }
      }
    }
  }

  $requestedShells = @(Get-RequestedCompletionShells)
  if ($requestedShells.Count -gt 0) {
    $compDir = Join-Path $tempDir 'completions'
    New-Item -ItemType Directory -Path $compDir -Force | Out-Null
    foreach ($shell in $requestedShells) {
      $target = Join-Path $compDir $shell
      $logPath = "$target.log"
      try {
        $output = & $HugoBinary completion $shell 2> $logPath | Out-String -Width 4096
        $code = $LASTEXITCODE
        if ($null -eq $code) { $code = 0 }
        if ($code -ne 0) {
          Write-Warn "Hugo v$($script:ResolvedVersion) could not generate $shell completions; skipping."
          continue
        }
        if ([string]::IsNullOrWhiteSpace($output)) {
          Write-Warn "Hugo produced an empty $shell completion; skipping."
          continue
        }
        Write-Utf8NoBom $target $output
        $plan.Completions[$shell] = $target
        $plan.Shells += $shell
      } catch {
        Write-Warn "Hugo v$($script:ResolvedVersion) could not generate $shell completions; skipping."
      }
    }
  }

  return $plan
}

function Get-HugoExtrasOperations {
  param($Plan, [string]$ShareDirectory)
  $operations = @()
  if ($null -eq $Plan) { return $operations }

  foreach ($manPage in @($Plan.ManPages)) {
    $operations += @{
      op = 'copy'
      source = $manPage
      destination = (Join-Path $ShareDirectory ('man\man1\' + [IO.Path]::GetFileName($manPage)))
    }
  }
  foreach ($shell in @($Plan.Shells)) {
    $target = Get-CompletionTarget $shell $ShareDirectory
    if (-not [string]::IsNullOrEmpty($target)) {
      $operations += @{ op = 'copy'; source = $Plan.Completions[$shell]; destination = $target }
    }
  }
  return $operations
}

function Test-HugoExtrasRequested {
  return ($script:ManpagesArg -or -not [string]::IsNullOrEmpty($script:CompletionsArg))
}

function Write-HugoExtrasSummary {
  param($Plan, [string]$ShareDirectory)
  if ($null -eq $Plan) { return }
  $manCount = @($Plan.ManPages).Count
  if ($manCount -gt 0) {
    Write-Note "installed $manCount manpage(s) in $(Join-Path $ShareDirectory 'man\man1')."
  }
  foreach ($shell in @($Plan.Shells)) {
    Write-Note "installed $shell completions in $(Get-CompletionTarget $shell $ShareDirectory)."
  }
  if (@($Plan.Shells) -contains 'powershell') {
    Write-Note 'for PowerShell, add this line to $PROFILE:'
    Write-Note "  . $(Get-CompletionTarget 'powershell' $ShareDirectory)"
  }
}

function Install-HugoExtras {
  param([string]$HugoBinary, [bool]$ForceElevation = $false)

  if (-not (Test-HugoExtrasRequested)) { return }

  $shareDir = Get-ShareDir $script:InstallDir
  if ($script:DryRunMode) { return }

  $writable = Test-CanWriteTo $shareDir
  $elevate = $false
  if (-not $writable) {
    if ($ForceElevation -or (Test-CanElevate)) {
      $elevate = $true
    } else {
      Write-Warn "cannot write to $shareDir; skipping manpages and completions."
      return
    }
  }

  $plan = New-HugoExtrasPlan $HugoBinary
  $operations = @(Get-HugoExtrasOperations $plan $shareDir)
  if ($operations.Count -eq 0) {
    if (-not [string]::IsNullOrEmpty($plan.TempDir) -and (Test-Path -LiteralPath $plan.TempDir)) {
      Remove-Item -LiteralPath $plan.TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    return
  }

  $manifest = @{
    version = 1
    sourceRoot = $plan.TempDir
    roots = @($shareDir)
    operations = $operations
  }

  $savedElevation = $script:NeedsElevation
  $script:NeedsElevation = $elevate
  try {
    $result = Invoke-WriteManifest $manifest
  } finally {
    $script:NeedsElevation = $savedElevation
  }

  if (-not $result.Success) {
    Write-Warn "could not write the manpages and completions to $shareDir; skipping."
    if (-not [string]::IsNullOrEmpty($plan.TempDir) -and (Test-Path -LiteralPath $plan.TempDir)) {
      Remove-Item -LiteralPath $plan.TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    return
  }

  Write-HugoExtrasSummary $plan $shareDir

  if (-not [string]::IsNullOrEmpty($plan.TempDir) -and (Test-Path -LiteralPath $plan.TempDir)) {
    Remove-Item -LiteralPath $plan.TempDir -Recurse -Force -ErrorAction SilentlyContinue
  }
}

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

function Write-GitHubOutput {
  param([string]$Key, [string]$Value)
  $path = [Environment]::GetEnvironmentVariable('GITHUB_OUTPUT')
  if ([string]::IsNullOrEmpty($path)) { return }
  [IO.File]::AppendAllText($path, "$Key=$Value`n", [Text.UTF8Encoding]::new($false))
}

function Write-GitHubPath {
  param([string]$Directory)
  if ($script:NoPathMode) { return }
  $path = [Environment]::GetEnvironmentVariable('GITHUB_PATH')
  if ([string]::IsNullOrEmpty($path)) { return }
  $current = [Environment]::GetEnvironmentVariable('PATH')
  $entries = @()
  if ($current) { $entries = $current -split ';' }
  foreach ($entry in $entries) {
    if ($entry.TrimEnd('\', '/').Equals($Directory.TrimEnd('\', '/'), [StringComparison]::OrdinalIgnoreCase)) { return }
  }
  [IO.File]::AppendAllText($path, "$Directory`n", [Text.UTF8Encoding]::new($false))
}

function Get-PathRegistryView {
  if (-not [Environment]::Is64BitProcess -and [Environment]::Is64BitOperatingSystem) {
    return [Microsoft.Win32.RegistryView]::Registry64
  }
  return [Microsoft.Win32.RegistryView]::Default
}

function Get-MachinePathKey {
  param([switch]$Writable)
  $base = [Microsoft.Win32.RegistryKey]::OpenBaseKey(
    [Microsoft.Win32.RegistryHive]::LocalMachine, (Get-PathRegistryView))
  $sub = 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
  if ($Writable) { return $base.OpenSubKey($sub, $true) }
  return $base.OpenSubKey($sub)
}

function Get-PathEntries {
  param([string]$Scope)
  if ($Scope -eq 'Machine') {
    $value = ''
    $key = Get-MachinePathKey
    if ($null -ne $key) {
      try {
        $value = [string]$key.GetValue(
          'Path', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
      } finally {
        $key.Dispose()
      }
    }
  } else {
    $value = [Environment]::GetEnvironmentVariable('Path', $Scope)
  }
  if ([string]::IsNullOrEmpty($value)) { return @() }
  return @($value -split ';' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function Set-PathEntries {
  param([string[]]$Entries, [string]$Scope)
  $text = ($Entries -join ';')
  if ($Scope -eq 'Machine') {
    $key = Get-MachinePathKey -Writable
    if ($null -eq $key) { throw 'cannot open the machine PATH registry key' }
    try {
      $kind = [Microsoft.Win32.RegistryValueKind]::ExpandString
      try {
        if ($key.GetValueKind('Path') -eq [Microsoft.Win32.RegistryValueKind]::String) {
          $kind = [Microsoft.Win32.RegistryValueKind]::String
        }
      } catch { }
      $key.SetValue('Path', $text, $kind)
    } finally {
      $key.Dispose()
    }
    return
  }
  [Environment]::SetEnvironmentVariable('Path', $text, $Scope)
}

function Test-PathEntry {
  param([string]$Directory, [string]$Scope)
  $normalized = $Directory.TrimEnd('\', '/')
  foreach ($entry in @(Get-PathEntries $Scope)) {
    if ($entry.TrimEnd('\', '/').Equals($normalized, [StringComparison]::OrdinalIgnoreCase)) { return $true }
  }
  return $false
}

function Add-PathEntry {
  param([string]$Directory, [string]$Scope)
  if (Test-PathEntry $Directory $Scope) { return $false }
  $entries = @(Get-PathEntries $Scope)
  $entries += $Directory.TrimEnd('\', '/')
  Set-PathEntries $entries $Scope
  if ($Scope -ne 'Process') { Send-EnvironmentChange }
  return $true
}

function Remove-PathEntry {
  param([string]$Directory, [string]$Scope)
  $normalized = $Directory.TrimEnd('\', '/')
  $entries = @(Get-PathEntries $Scope)
  $kept = @($entries | Where-Object {
    -not $_.TrimEnd('\', '/').Equals($normalized, [StringComparison]::OrdinalIgnoreCase)
  })
  if ($kept.Count -eq $entries.Count) { return $false }
  Set-PathEntries $kept $Scope
  if ($Scope -ne 'Process') { Send-EnvironmentChange }
  return $true
}

function Send-EnvironmentChange {
  try {
    if (-not ('InstallerEnvironmentBroadcast' -as [type])) {
      Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

public static class InstallerEnvironmentBroadcast
{
    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern IntPtr SendMessageTimeout(
        IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam,
        uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
}
'@
    }
    $result = [UIntPtr]::Zero
    [void][InstallerEnvironmentBroadcast]::SendMessageTimeout(
      [IntPtr]0xffff, 0x001A, [UIntPtr]::Zero, 'Environment', 2, 5000, [ref]$result)
  } catch { }
}

function Get-PathScope {
  param([string]$Directory)
  if (-not [string]::IsNullOrEmpty($script:PathScopeOverride)) { return $script:PathScopeOverride }
  $system = Join-Path (Get-SystemProgramFiles (Get-PlatformArch)) 'Hugo'
  if (Test-PathUnder $Directory $system) { return 'Machine' }
  if ($script:NeedsElevation) {
    $homeRoot = [Environment]::GetEnvironmentVariable('USERPROFILE')
    if ([string]::IsNullOrEmpty($homeRoot)) { $homeRoot = $HOME }
    if (-not [string]::IsNullOrEmpty($homeRoot) -and -not (Test-PathUnder $Directory $homeRoot)) { return 'Machine' }
  }
  return 'User'
}

function Test-PathUpdateDisabled {
  if ($script:NoPathMode) { return $true }
  if ($script:PrintEnvMode -or $script:PrintPathMode) { return $true }
  if (-not [string]::IsNullOrEmpty($script:PathScopeOverride)) { return $false }
  if (-not [string]::IsNullOrEmpty($env:GITHUB_PATH)) { return $true }
  if (Test-IsCi) { return $true }
  return $false
}

function Sync-ProcessPath {
  param([string]$Directory)
  try { [void](Add-PathEntry $Directory 'Process') } catch { }
}

function Write-ManualPathGuidance {
  param([string]$Directory)
  Write-Note "$Directory is not on PATH; add it to your PowerShell profile:"
  Write-Note "  `$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')"
  Write-Note "  if ((`$userPath -split ';') -notcontains '$Directory') { [Environment]::SetEnvironmentVariable('Path', `$userPath + ';$Directory', 'User') }"
}

function Write-PathGuidance {
  param([string]$Directory)
  if ($script:PrintEnvMode -or $script:PrintPathMode) { return }
  if ($script:NoPathMode) {
    if (-not (Test-PathEntry $Directory 'Process')) { Write-ManualPathGuidance $Directory }
    return
  }
  if ([string]::IsNullOrEmpty($script:PathScopeOverride)) {
    if (-not [string]::IsNullOrEmpty($env:GITHUB_PATH)) {
      Write-Note 'GITHUB_PATH is set; the workflow PATH was updated instead of the persistent PATH.'
      return
    }
    if (Test-IsCi) {
      Write-Note "$Directory is not on PATH; add it to PATH for this job:"
      Write-Note "  `$env:PATH = '$Directory;' + `$env:PATH"
      return
    }
  }

  $scope = Get-PathScope $Directory
  $added = $false
  try {
    $added = Add-PathEntry $Directory $scope
  } catch {
    if ($scope -ne 'User') {
      try { $added = Add-PathEntry $Directory 'User'; $scope = 'User' } catch { }
    }
  }

  if (Test-PathEntry $Directory $scope) {
    if ($added) {
      Write-Note "added $Directory to the $scope PATH; open a new terminal to use it."
    } else {
      Write-Note "$Directory is already on the $scope PATH."
    }
  } else {
    Write-Warn "could not add $Directory to the PATH."
    Write-ManualPathGuidance $Directory
  }
  Sync-ProcessPath $Directory
}

function Complete-HugoInstall {
  param([string]$InstalledVersion, [bool]$SkipExtras = $false)
  if (-not $SkipExtras) {
    $bin = Join-Path $script:InstallDir 'hugo.exe'
    if (Test-Path -LiteralPath $bin) {
      Install-HugoExtras $bin
    }
  }
  Write-PathGuidance $script:InstallDir
  $binPath = Join-Path $script:InstallDir 'hugo.exe'
  Write-GitHubOutput 'hugo-version' $InstalledVersion
  Write-GitHubOutput 'hugo-path' $binPath
  Write-GitHubPath $script:InstallDir
  if ($script:PrintEnvMode) {
    [Console]::Out.WriteLine("HUGO_VERSION=$InstalledVersion")
    [Console]::Out.WriteLine("HUGO_BIN=$binPath")
    [Console]::Out.WriteLine("HUGO_DIR=$script:InstallDir")
  }
  if ($script:PrintPathMode) {
    [Console]::Out.WriteLine($script:InstallDir)
  }
  Write-Note "Hugo v$InstalledVersion installed at $binPath"
  return 0
}
# ---------------------------------------------------------------------------
# Installed copy
# ---------------------------------------------------------------------------

function Get-InstalledHugoVersion {
  param([string]$Directory)
  $bin = Join-Path $Directory 'hugo.exe'
  if (-not (Test-Path -LiteralPath $bin)) { return '' }
  try {
    $output = & $bin version 2>&1 | Out-String -Width 4096
    $match = [regex]::Match($output, 'v([0-9][0-9.]*)')
    if ($match.Success) { return $match.Groups[1].Value.TrimEnd('.') }
  } catch { }
  return ''
}

function Test-HugoLayout {
  param([string]$Directory)
  return (Test-Path -LiteralPath (Join-Path $Directory 'hugo.exe'))
}

function Invoke-HugoSmokeTest {
  param([string]$Binary)

  $output = ''
  $code = 0
  try {
    $output = (& $Binary version 2>&1 | Out-String -Width 4096).Trim()
    $code = $LASTEXITCODE
    if ($null -eq $code) { $code = 0 }
  } catch {
    $code = 1
    $output = $_.Exception.Message
  }

  if ($code -eq 0 -and $output -match '(?i)hugo') {
    $match = [regex]::Match($output, 'v([0-9][0-9.]*)')
    $version = ''
    if ($match.Success) { $version = $match.Groups[1].Value.TrimEnd('.') }
    return @{ Success = $true; Output = ($output -split "`r?`n")[0]; Version = $version; Detail = '' }
  }

  $detail = "'hugo version' exited with code $code"
  if (-not [string]::IsNullOrEmpty($output)) {
    $detail = "$detail and printed: $(($output -split "`r?`n")[0])"
  }

  try {
    $help = (& $Binary -h 2>&1 | Out-String -Width 4096)
    if ($help -match '(?i)usage: hugo') {
      return @{
        Success = $true
        Output = "hugo (this release has no 'version' subcommand)"
        Version = ''
        Detail = ''
      }
    }
  } catch { }
  return @{ Success = $false; Output = ''; Version = ''; Detail = "$detail; 'hugo -h' did not print 'usage: hugo'" }
}

# ---------------------------------------------------------------------------
# Checksums
# ---------------------------------------------------------------------------

function Get-HugoChecksumCandidates {
  param([string]$AssetVersion, [string]$AssetName)
  $candidates = @()
  if (Test-VersionGe $AssetVersion '0.27') {
    if ($AssetName -like 'hugo_extended_*') {
      if (Test-VersionGe '0.55.6' $AssetVersion) {
        $candidates += "hugo_extended_${AssetVersion}_checksums.txt"
      }
    }
    $candidates += "hugo_${AssetVersion}_checksums.txt"
  } elseif (Test-VersionGe $AssetVersion '0.20.3') {
    $candidates += 'hugo_checksums.txt'
  }
  return $candidates
}

function Get-ChecksumFromFile {
  param([string]$Path, [string]$AssetName)
  foreach ($line in [IO.File]::ReadAllLines($Path)) {
    $fields = @($line.Trim() -split '\s+' | Where-Object { $_ })
    if ($fields.Count -lt 2) { continue }
    $file = $fields[$fields.Count - 1]
    if ($file -eq $AssetName) {
      $hash = $fields[0]
      if ($hash -match '^[0-9a-fA-F]{64}$') { return $hash.ToLowerInvariant() }
    }
  }
  return $null
}

function Test-HugoDownload {
  param([string]$DownloadPath, [string]$AssetVersion, [string]$AssetName)

  $hashCandidates = @(Get-HugoChecksumCandidates $AssetVersion $AssetName)
  $verified = $false
  $checksumWarn = ''

  if ($hashCandidates.Count -gt 0) {
    $hashFile = ''
    foreach ($candidate in $hashCandidates) {
      if (Test-UrlExists "$script:ReleaseBase/v$AssetVersion/$candidate") {
        $hashFile = $candidate
        break
      }
    }

    if (-not [string]::IsNullOrEmpty($hashFile)) {
      $hashPath = Join-Path ([IO.Path]::GetDirectoryName($DownloadPath)) $hashFile
      $downloaded = $false
      try {
        Get-RemoteFile "$script:ReleaseBase/v$AssetVersion/$hashFile" $hashPath
        $downloaded = $true
      } catch {
        $checksumWarn = "could not download $hashFile"
      }
      if ($downloaded) {
        $expected = Get-ChecksumFromFile $hashPath $AssetName
        if ($expected) {
          if (-not (Test-Sha256 $expected $DownloadPath)) {
            throw "checksum mismatch for $AssetName."
          }
          Write-Note "checksum verification succeeded ($hashFile)."
          $verified = $true
        } else {
          $checksumWarn = "no checksum entry for $AssetName in $hashFile"
        }
      }
    } else {
      $checksumWarn = "no checksum file found for v$AssetVersion (tried: $($hashCandidates -join ' '))"
    }
  }

  if ($verified) { return }

  if (Test-VersionGe $AssetVersion '0.147.7') {
    if (-not [string]::IsNullOrEmpty($checksumWarn)) {
      Write-Warn "$checksumWarn; falling back to the SHA-256 digest published in the GitHub release."
    }
    $digest = $null
    $digestError = $null
    try {
      $digest = Get-ReleaseAssetDigest "v$AssetVersion" $AssetName
    } catch {
      $digestError = $_.Exception.Message
    }
    if ($digestError) {
      Write-Warn "the GitHub API could not be queried for the SHA-256 digest of $AssetName (network or rate limiting); skipping verification. Pass -GitHubToken to avoid rate limits."
    } elseif (-not $digest) {
      Write-Warn "the GitHub release for v$AssetVersion publishes no SHA-256 digest for $AssetName; skipping verification."
    } elseif (-not (Test-Sha256 $digest $DownloadPath)) {
      throw "SHA-256 mismatch for $AssetName (the digest published in the GitHub release does not match the downloaded file)."
    } else {
      Write-Note 'SHA-256 verification succeeded (GitHub release asset digest).'
    }
    return
  }

  if ($hashCandidates.Count -eq 0) {
    Write-Warn "Hugo v$AssetVersion publishes no checksum files (v0.20.2 and earlier) and predates the first release with published SHA-256 asset digests (v0.147.7); skipping verification."
  } else {
    Write-Warn "$checksumWarn; v$AssetVersion predates the first release with published SHA-256 asset digests (v0.147.7), so verification is skipped."
  }
}

# ---------------------------------------------------------------------------
# Uninstall
# ---------------------------------------------------------------------------

function Get-UninstallShells {
  if ($script:CompletionsOff) { return @() }
  if ([string]::IsNullOrEmpty($script:CompletionsArg) -or $script:CompletionsArg -eq 'auto') {
    return @('bash', 'fish', 'zsh', 'powershell')
  }
  if (@('none', 'off', 'false', '0') -contains $script:CompletionsArg.ToLowerInvariant()) {
    return @()
  }
  return @(Normalize-Completions $script:CompletionsArg)
}

function Get-HugoUninstallTargets {
  param([string]$InstallDirectory, [string]$ShareDirectory)

  $targets = @()
  $bin = Join-Path $InstallDirectory 'hugo.exe'
  if (Test-Path -LiteralPath $bin) { $targets += $bin }

  if ($script:ManpagesArg -and (Test-Path -LiteralPath $ShareDirectory)) {
    $manDir = Join-Path $ShareDirectory 'man\man1'
    if (Test-Path -LiteralPath $manDir) {
      foreach ($file in @(Get-ChildItem -LiteralPath $manDir -Filter 'hugo*.1.gz' -File -ErrorAction SilentlyContinue)) {
        $targets += $file.FullName
      }
    }
  }

  foreach ($shell in @(Get-UninstallShells)) {
    $target = Get-CompletionTarget $shell $ShareDirectory
    if (-not [string]::IsNullOrEmpty($target) -and (Test-Path -LiteralPath $target)) {
      $targets += $target
    }
  }

  return $targets
}

function Invoke-HugoUninstall {
  $shareDir = Get-ShareDir $script:InstallDir
  $targets = @(Get-HugoUninstallTargets $script:InstallDir $shareDir)

  if ($script:DryRunMode) {
    Write-DryLine 'uninstall=1'
    Write-DryLine 'method=binary'
    Write-DryLine "install_dir=$script:InstallDir"
    Write-DryLine "share_dir=$shareDir"
    Write-DryLine "escalation=$script:EscalationLabel"
    foreach ($target in $targets) { Write-DryLine "remove=$target" }
    if (-not (Test-PathUpdateDisabled)) {
      Write-DryLine "path_scope=$(Get-PathScope $script:InstallDir)"
    } else {
      Write-DryLine 'path_update=disabled'
    }
    return 0
  }

  if ($targets.Count -eq 0) {
    Write-Note "Hugo is not installed by this script in $script:InstallDir; nothing to remove."
    return 0
  }

  if (-not $script:AssumeYes) {
    if (-not (Test-IsInteractive)) {
      throw "Hugo is installed in $script:InstallDir; pass -Yes to remove it without confirmation."
    }
    if (-not (Read-Confirmation "Remove Hugo from $script:InstallDir?")) {
      Write-Note "uninstall cancelled; Hugo remains installed in $script:InstallDir."
      return 0
    }
  }

  $inUse = Test-InstallDirInUse $script:InstallDir
  if ($inUse) {
    throw "cannot remove Hugo while '$inUse' is running from $script:InstallDir; close it and retry."
  }

  $operations = @()
  foreach ($target in $targets) {
    $operations += @{ op = 'remove'; path = $target }
  }
  if (-not (Test-PathUpdateDisabled)) {
    $operations += @{
      op = 'path-remove'
      scope = (Get-PathScope $script:InstallDir)
      value = $script:InstallDir
      anchor = (Join-Path $script:InstallDir 'hugo.exe')
    }
  }

  $manifest = @{
    version = 1
    sourceRoot = ''
    roots = @($script:InstallDir, $shareDir)
    operations = $operations
  }

  Write-Note "removing Hugo from $script:InstallDir."
  $result = Invoke-WriteManifest $manifest
  if (-not $result.Success) {
    $detail = ''
    if ($result.Errors) {
      $messages = @($result.Errors | Where-Object { -not [string]::IsNullOrEmpty($_) })
      if ($messages.Count -gt 0) { $detail = ' ' + ($messages -join ' ') }
    }
    throw "cannot remove Hugo from $script:InstallDir.$detail"
  }

  $left = @(Get-HugoUninstallTargets $script:InstallDir $shareDir)
  if ($left.Count -gt 0) {
    throw "some Hugo files remain: $($left -join ', ')"
  }

  Write-Note "Hugo removed from $script:InstallDir."
  Write-Note "the manpages and completions under $shareDir were removed when present."
  return 0
}

# ---------------------------------------------------------------------------
# Install
# ---------------------------------------------------------------------------

function Resolve-HugoInstallDir {
  param([string]$Arch)
  $plan = Get-InstallDirPlan $Arch
  $script:InstallDir = $plan.Path
  $script:NeedsElevation = [bool]$plan.NeedsElevation
  $script:EscalationLabel = [string]$plan.Label
  return $plan
}

function Invoke-HugoInstall {
  $arch = Get-PlatformArch

  if ([string]::IsNullOrEmpty($script:Version) -or $script:Version -eq 'latest') {
    Write-Note 'no Hugo version specified; resolving the latest release'
    $script:Version = Resolve-LatestTag
  }

  $requested = $script:Version.Trim()
  if ($requested.StartsWith('v') -or $requested.StartsWith('V')) { $requested = $requested.Substring(1) }
  if ([string]::IsNullOrEmpty($requested) -or $requested -notmatch '^[0-9.]+$' -or $requested.StartsWith('.')) {
    throw "invalid Hugo version: '$requested'"
  }
  $script:Version = $requested

  if ($script:LegacyWindows -and (Test-VersionGe $requested '0.118.3')) {
    Write-Warn "Windows 7 detected: Hugo v$requested is built with a Go release that generally requires Windows 10 or newer; the binary may not run. Windows 7 is best effort only."
  }

  $plan = Resolve-HugoInstallDir $arch
  $shareDir = Get-ShareDir $script:InstallDir

  if ($script:DryRunMode) {
    $resolution = Resolve-HugoAsset $requested $arch
    $script:ResolvedVersion = $resolution.Version
    $script:ResolvedAsset = $resolution.Asset
    $script:AssetEdition = Get-AssetEdition $resolution.Asset

    Write-DryLine "version=$script:ResolvedVersion"
    Write-DryLine "asset=$script:ResolvedAsset"
    Write-DryLine "url=$script:ReleaseBase/v$($script:ResolvedVersion)/$script:ResolvedAsset"
    Write-DryLine 'method=binary'
    Write-DryLine 'os=windows'
    Write-DryLine "arch=$arch"
    Write-DryLine "edition=$script:AssetEdition"
    Write-DryLine "install_dir=$script:InstallDir"
    Write-DryLine "escalation=$($plan.Label)"
    Write-DryLine "bin=$(Join-Path $script:InstallDir 'hugo.exe')"
    if (Test-PathUpdateDisabled) {
      Write-DryLine 'path_update=disabled'
    } else {
      Write-DryLine "path_scope=$(Get-PathScope $script:InstallDir)"
    }
    if ($script:ManpagesArg) {
      Write-DryLine "manpages=$(Join-Path $shareDir 'man\man1')"
    }
    foreach ($shell in @(Get-RequestedCompletionShells)) {
      if (-not [string]::IsNullOrEmpty($shell)) {
        Write-DryLine "completion.$shell=$(Get-CompletionTarget $shell $shareDir)"
      }
    }
    if ($script:PrintEnvMode) {
      [Console]::Out.WriteLine("HUGO_VERSION=$script:ResolvedVersion")
      [Console]::Out.WriteLine("HUGO_BIN=$(Join-Path $script:InstallDir 'hugo.exe')")
      [Console]::Out.WriteLine("HUGO_DIR=$script:InstallDir")
    }
    if ($script:PrintPathMode) { [Console]::Out.WriteLine($script:InstallDir) }
    return 0
  }

  $resolution = Resolve-HugoAsset $requested $arch
  $script:ResolvedVersion = $resolution.Version
  $script:ResolvedAsset = $resolution.Asset
  $script:AssetEdition = Get-AssetEdition $script:ResolvedAsset

  if (-not [string]::IsNullOrEmpty($resolution.BumpedFrom)) {
    Write-Note "Hugo v$($resolution.BumpedFrom) is missing the Windows Extended+Deploy archives (upstream bug, fixed in v0.137.1); installing v0.137.1 instead."
  } elseif ($script:ResolvedVersion -ne $requested) {
    Write-Note "Tag v$requested does not exist; using v$($script:ResolvedVersion) instead."
  }

  if ($arch -eq 'arm64' -and $script:ResolvedAsset -notmatch '(?i)arm64') {
    $script:CrossArch = $true
    Write-Warn "no ARM64 build of the requested Hugo edition exists for v$($script:ResolvedVersion); installing the AMD64 build (runs through x64 emulation on Windows on ARM)."
    Write-Note 'native Windows ARM64 builds exist from v0.89.0, for the standard edition only.'
  }

  if ($script:AssetEdition -ne $script:RequestedEdition) {
    if ($script:RequestedEdition -eq 'extended_withdeploy' -and $script:AssetEdition -eq 'extended') {
      Write-Warn "no Extended+Deploy build found for v$($script:ResolvedVersion) on this platform; installing the extended build without Deploy."
    } elseif ($script:AssetEdition -eq 'standard') {
      if ($script:RequestedEdition -eq 'withdeploy') {
        Write-Warn "no Deploy ('withdeploy') build was found for v$($script:ResolvedVersion) on this platform; installing the standard build without Deploy."
      } else {
        Write-Warn "no '$($script:RequestedEdition)' build found for v$($script:ResolvedVersion) on this platform; installing the standard build instead."
      }
    } else {
      Write-Warn "no '$($script:RequestedEdition)' build found for v$($script:ResolvedVersion) on this platform; installing '$($script:AssetEdition)' instead."
    }
  }

  if ($script:ExtendedArg -and $script:WithDeployArg `
      -and (Test-VersionGe $script:ResolvedVersion '0.56.0') `
      -and (Test-VersionGe '0.136.5' $script:ResolvedVersion)) {
    Write-Note "Hugo v$($script:ResolvedVersion) extended builds include 'hugo deploy' already, so 'with-deploy' had no additional effect."
  }

  if (-not $script:ExtendedArg -and $script:WithDeployArg) {
    if (Test-VersionGe $script:ResolvedVersion '0.159.2') {
      # The standard build includes Deploy.
    } elseif (Test-VersionGe $script:ResolvedVersion '0.137.0') {
      Write-Note "standard Hugo includes 'hugo deploy' only from v0.159.2; set -Extended to get Deploy for v0.137.0-v0.159.1."
    } else {
      Write-Note "Hugo v$($script:ResolvedVersion) does not include 'hugo deploy'; installing the standard build."
    }
  }

  Write-Note "resolved Hugo v$($script:ResolvedVersion): $($script:ResolvedAsset)"

  $binPath = Join-Path $script:InstallDir 'hugo.exe'

  if (-not $script:ForceInstall) {
    $current = Get-InstalledHugoVersion $script:InstallDir
    if ($current) {
      if ($current -eq $script:ResolvedVersion) {
        if (Test-HugoLayout $script:InstallDir) {
          Write-Note "Hugo v$current is already installed in $script:InstallDir; nothing to do."
          return (Complete-HugoInstall $current)
        }
        Write-Note "repairing the Hugo v$current payload in $script:InstallDir."
      } else {
        if (-not $script:AssumeYes) {
          if (-not (Test-IsInteractive)) {
            throw "Hugo v$current is already installed in $script:InstallDir; pass -Yes to replace it with v$($script:ResolvedVersion) without confirmation."
          }
          if (-not (Read-Confirmation "Hugo v$current is installed in $script:InstallDir. Replace it with v$($script:ResolvedVersion)?")) {
            Write-Note "update cancelled; Hugo v$current remains installed in $script:InstallDir."
            return 0
          }
        }
        Write-Note "replacing Hugo v$current in $script:InstallDir with v$($script:ResolvedVersion)."
      }
    }
  }

  $script:WorkDir = Join-Path ([IO.Path]::GetTempPath()) ("hugo-install-" + [Guid]::NewGuid().ToString('N'))
  New-Item -ItemType Directory -Path $script:WorkDir -Force | Out-Null
  $downloadPath = Join-Path $script:WorkDir $script:ResolvedAsset

  Write-Note "downloading $script:ReleaseBase/v$($script:ResolvedVersion)/$($script:ResolvedAsset)"
  Get-RemoteFile "$script:ReleaseBase/v$($script:ResolvedVersion)/$($script:ResolvedAsset)" $downloadPath

  $isZip = Test-ZipFile $downloadPath
  if (-not $isZip -and $script:ResolvedAsset -like '*.zip') {
    Write-Warn "the downloaded file does not look like a zip archive; continuing."
  }

  if ($script:VerifyFile) {
    Test-HugoDownload $downloadPath $script:ResolvedVersion $script:ResolvedAsset
  } else {
    Write-Note 'file verification is disabled (-NoVerify).'
  }

  $script:StageDir = Join-Path $script:WorkDir 'stage'
  New-Item -ItemType Directory -Path $script:StageDir -Force | Out-Null

  if ($isZip) {
    $extractDir = Join-Path $script:WorkDir 'extract'
    New-Item -ItemType Directory -Path $extractDir -Force | Out-Null
    Expand-ZipSafely $downloadPath $extractDir
    $binSource = ''
    $found = @(Get-ChildItem -LiteralPath $extractDir -Recurse -Force -File -Filter 'hugo.exe' -ErrorAction SilentlyContinue)
    if ($found.Count -gt 0) {
      $binSource = $found[0].FullName
    } else {
      $fallback = @(Get-ChildItem -LiteralPath $extractDir -Recurse -Force -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -like 'hugo*' -and $_.Extension -notin @('.md', '.txt') })
      if ($fallback.Count -gt 0) { $binSource = $fallback[0].FullName }
    }
    if ([string]::IsNullOrEmpty($binSource)) {
      throw "could not locate the hugo binary inside $($script:ResolvedAsset)."
    }
    Copy-FileAtomic $binSource (Join-Path $script:StageDir 'hugo.exe')
  } else {
    Copy-FileAtomic $downloadPath (Join-Path $script:StageDir 'hugo.exe')
  }

  $stagedBin = Join-Path $script:StageDir 'hugo.exe'
  Write-Note "Hugo payload staged in $script:StageDir."

  $extrasPlan = $null
  if (Test-HugoExtrasRequested) {
    $extrasPlan = New-HugoExtrasPlan $stagedBin $script:WorkDir
  }

  $shareWritable = $false
  $includeExtras = $false
  if ($null -ne $extrasPlan) {
    $shareWritable = Test-CanWriteTo $shareDir
    if ($shareWritable) {
      $includeExtras = $true
    } elseif ($plan.NeedsElevation -or (Test-CanElevate)) {
      $includeExtras = $true
      $script:NeedsElevation = $true
    } else {
      Write-Warn "cannot write to $shareDir; skipping manpages and completions."
    }
  }

  $operations = @()
  $roots = @($script:InstallDir)
  $operations += @{ op = 'copy'; source = $stagedBin; destination = $binPath }
  $installedExtras = $false
  $installedShareDir = $shareDir
  if ($includeExtras) {
    $operations += @(Get-HugoExtrasOperations $extrasPlan $shareDir)
    if ($roots -notcontains $shareDir) { $roots += $shareDir }
    $installedExtras = $true
  }
  if (-not (Test-PathUpdateDisabled)) {
    $operations += @{ op = 'path'; scope = (Get-PathScope $script:InstallDir); value = $script:InstallDir }
  }

  $manifest = @{
    version = 1
    sourceRoot = $script:WorkDir
    roots = $roots
    operations = $operations
  }

  $result = Invoke-WriteManifest $manifest
  if (-not $result.Success -and -not $script:InstallDirExplicit -and -not $script:SystemOnly -and $script:EscalateMode -ne 'always') {
    $reason = 'the privileged write failed'
    if ($result.Cancelled) { $reason = 'UAC was cancelled' }
    $script:InstallDir = Join-Path (Get-UserProgramsDir) 'Hugo'
    $script:NeedsElevation = $false
    $script:EscalationLabel = 'none'
    $shareDir = Get-ShareDir $script:InstallDir
    Write-Warn "$reason; falling back to $script:InstallDir."

    $fallbackCurrent = Get-InstalledHugoVersion $script:InstallDir
    if ($fallbackCurrent -and -not $script:ForceInstall -and -not $script:AssumeYes) {
      if (-not (Test-IsInteractive)) {
        throw "Hugo v$fallbackCurrent is already installed in $script:InstallDir; pass -Yes to replace it with v$($script:ResolvedVersion) without confirmation."
      }
      if (-not (Read-Confirmation "Hugo v$fallbackCurrent is installed in $script:InstallDir. Replace it with v$($script:ResolvedVersion)?")) {
        Write-Note "update cancelled; Hugo v$fallbackCurrent remains installed in $script:InstallDir."
        return 0
      }
    }

    $fallbackOperations = @()
    $fallbackRoots = @($script:InstallDir)
    $fallbackOperations += @{ op = 'copy'; source = $stagedBin; destination = (Join-Path $script:InstallDir 'hugo.exe') }
    $fallbackIncludeExtras = $false
    $installedExtras = $false
    $installedShareDir = $shareDir
    if ($null -ne $extrasPlan) {
      if (Test-CanWriteTo $shareDir) {
        $fallbackIncludeExtras = $true
      } else {
        Write-Warn "cannot write to $shareDir; skipping manpages and completions."
      }
    }
    if ($fallbackIncludeExtras) {
      $fallbackOperations += @(Get-HugoExtrasOperations $extrasPlan $shareDir)
      if ($fallbackRoots -notcontains $shareDir) { $fallbackRoots += $shareDir }
      $installedExtras = $true
    }
    if (-not (Test-PathUpdateDisabled)) {
      $fallbackOperations += @{ op = 'path'; scope = 'User'; value = $script:InstallDir }
    }

    $manifest = @{
      version = 1
      sourceRoot = $script:WorkDir
      roots = $fallbackRoots
      operations = $fallbackOperations
    }
    $result = Invoke-WriteManifest $manifest
  }
  if (-not $result.Success) {
    $detail = ''
    if ($result.Errors) {
      $messages = @($result.Errors | Where-Object { -not [string]::IsNullOrEmpty($_) })
      if ($messages.Count -gt 0) { $detail = ' ' + ($messages -join ' ') }
    }
    throw "cannot write to $script:InstallDir; choose a writable directory or run from an elevated PowerShell.$detail"
  }

  $binPath = Join-Path $script:InstallDir 'hugo.exe'
  if (-not (Test-HugoLayout $script:InstallDir)) {
    throw "the write to $script:InstallDir reported success but did not produce hugo.exe."
  }
  if ((Get-Sha256 $binPath) -ne (Get-Sha256 $stagedBin)) {
    throw "the installed hugo.exe in $script:InstallDir does not match the verified archive."
  }

  Write-Note "Hugo binary installed in $script:InstallDir."
  if ($installedExtras) {
    Write-HugoExtrasSummary $extrasPlan $installedShareDir
  }

  $smoke = Invoke-HugoSmokeTest $binPath
  if ($smoke.Success) {
    Write-Note "smoke test passed: $($smoke.Output)"
  } elseif ($script:CrossArch) {
    Write-Warn "the installed $arch build could not be executed on this machine (expected when a cross-architecture fallback is involved): $($smoke.Detail)"
    Write-Warn 'install emulation support (Windows on ARM x64 emulation) or use a matching architecture.'
  } else {
    throw "the installed hugo binary failed to execute ($($smoke.Detail))."
  }

  $installedVersion = $smoke.Version
  if ([string]::IsNullOrEmpty($installedVersion)) {
    $installedVersion = $script:ResolvedVersion
  }

  return (Complete-HugoInstall $installedVersion $true)
}

# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

function Invoke-Main {
  $script:PrintEnvMode = $PrintEnv.IsPresent
  $script:PrintPathMode = $PrintPath.IsPresent
  $script:DryRunMode = $DryRun.IsPresent
  $script:NoEscalateMode = $NoEscalate.IsPresent
  $script:LegacyWindows = Test-LegacyWindows

  if ($Help) {
    [Console]::Out.WriteLine($script:Usage)
    return 0
  }

  if (-not [string]::IsNullOrEmpty($ElevatedManifest)) {
    if ([string]::IsNullOrEmpty($ElevatedResult)) {
      throw '-ElevatedResult is required with -ElevatedManifest.'
    }
    return (Invoke-ElevatedChild $ElevatedManifest $ElevatedResult)
  }

  try {
    [Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
  } catch { }
  $ProgressPreference = 'SilentlyContinue'

  try {
    [Net.ServicePointManager]::SecurityProtocol =
      [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
  } catch { }

  Initialize-Options

  if (-not [string]::IsNullOrEmpty($script:PathScopeOverride) -and
    @('Machine', 'User', 'Process') -notcontains $script:PathScopeOverride) {
    throw "invalid -PathScope value: '$script:PathScopeOverride' (use Machine, User, or Process)"
  }

  if ($script:EscalateMode) { $script:EscalateMode = $script:EscalateMode.ToLowerInvariant() }
  if (@('auto', 'never', 'always') -notcontains $script:EscalateMode) {
    throw "invalid HUGO_ESCALATE value: '$script:EscalateMode' (use auto, never, or always)"
  }

  if ($System.IsPresent) {
    if ($script:NoEscalateMode -or $script:EscalateMode -eq 'never') {
      throw 'cannot combine -System with -NoEscalate (or HUGO_ESCALATE=never).'
    }
    $script:EscalateMode = 'always'
  }
  if ($User.IsPresent) {
    if ($System.IsPresent) { throw 'cannot combine -User with -System.' }
    if ($script:InstallDirExplicit) { throw 'cannot combine -User with -InstallDir (or HUGO_INSTALL_DIR).' }
    if ($Escalate.IsPresent -or $script:EscalateMode -eq 'always') { throw 'cannot combine -User with -Escalate (or HUGO_ESCALATE=always).' }
    $script:EscalateMode = 'never'
  }
  if ($Escalate.IsPresent) { $script:EscalateMode = 'always' }
  if ($script:NoEscalateMode) { $script:EscalateMode = 'never' }

  if ($Uninstall.IsPresent) {
    if ($script:PrintEnvMode) { throw 'cannot combine -Uninstall with -PrintEnv.' }
    if ($script:PrintPathMode) { throw 'cannot combine -Uninstall with -PrintPath.' }
    if ($script:VersionExplicit) { throw 'version arguments are not valid with -Uninstall.' }
  }

  if ([string]::IsNullOrEmpty($script:MethodArg)) { $script:MethodArg = 'auto' }
  $script:MethodArg = $script:MethodArg.ToLowerInvariant()
  if ($script:MethodArg -eq 'dpkg') { $script:MethodArg = 'deb' }
  if (@('auto', 'binary', 'pkg', 'deb') -notcontains $script:MethodArg) {
    throw "invalid method '$script:MethodArg' (use auto or binary on Windows)"
  }
  if ($script:MethodArg -eq 'pkg' -or $script:MethodArg -eq 'deb') {
    throw "-Method $($script:MethodArg) is not available on Windows: 'pkg' is the Termux package method and 'deb' is the Debian package method. Use -Method binary."
  }

  $verifyEnv = Get-EnvValue 'HUGO_VERIFY' '1'
  if ($NoVerify.IsPresent) {
    $script:VerifyFile = $false
  } elseif ($Verify.IsPresent) {
    $script:VerifyFile = $true
  } else {
    $script:VerifyFile = Test-Truthy $verifyEnv
  }

  $forceEnv = Get-EnvValue 'HUGO_FORCE' '0'
  if ($NoForce.IsPresent) {
    $script:ForceInstall = $false
  } elseif ($Force.IsPresent) {
    $script:ForceInstall = $true
  } else {
    $script:ForceInstall = Test-Truthy $forceEnv
  }

  if (-not $script:AssumeYes) {
    $script:AssumeYes = Test-Truthy (Get-EnvValue 'HUGO_YES' '0')
  }

  if ([string]::IsNullOrEmpty($script:DownloaderName)) { $script:DownloaderName = 'auto' }

  if (-not [string]::IsNullOrEmpty($script:CompletionsArg)) {
    $completionValue = $script:CompletionsArg.ToLowerInvariant()
    if (@('none', 'off', 'false', '0') -contains $completionValue) {
      $script:CompletionsArg = ''
      $script:CompletionsOff = $true
    } elseif ($completionValue -ne 'auto') {
      $normalized = @(Normalize-Completions $script:CompletionsArg)
      $script:CompletionsArg = ($normalized -join ' ')
    }
  }

  $arch = Get-PlatformArch
  if ($Uninstall.IsPresent) {
    if ([string]::IsNullOrEmpty($script:CompletionsArg) -or $script:CompletionsArg -eq 'auto') {
      $script:CompletionsArg = 'all'
    }
    $plan = Resolve-HugoInstallDir $arch

    if (-not $script:InstallDirExplicit -and -not $script:UserOnly -and -not $script:SystemOnly) {
      $userDir = Join-Path (Get-UserProgramsDir) 'Hugo'
      $plannedBin = Join-Path $script:InstallDir 'hugo.exe'
      $userBin = Join-Path $userDir 'hugo.exe'
      if (-not (Test-Path -LiteralPath $plannedBin) -and (Test-Path -LiteralPath $userBin)) {
        $script:InstallDir = $userDir
        $script:NeedsElevation = $false
        $script:EscalationLabel = 'none'
      }
    }
    return (Invoke-HugoUninstall)
  }

  return (Invoke-HugoInstall)
}

if ($MyInvocation.InvocationName -ne '.') {
  $exitCode = 0
  try {
    $exitCode = Invoke-Main
  } catch {
    [Console]::Error.WriteLine("error: $($_.Exception.Message)")
    $exitCode = 1
  } finally {
    if (-not [string]::IsNullOrEmpty($script:WorkDir) -and (Test-Path -LiteralPath $script:WorkDir)) {
      Remove-Item -LiteralPath $script:WorkDir -Recurse -Force -ErrorAction SilentlyContinue
    }
  }
  exit $exitCode
}
