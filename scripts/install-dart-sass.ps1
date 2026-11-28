<#
.SYNOPSIS
  Install, update, or remove the Dart Sass CLI on Windows.

.DESCRIPTION
  Standalone PowerShell installer for the official Dart Sass release archives.
  It is the Windows counterpart of scripts/install-dart-sass.sh and needs no
  Git Bash, MSYS, Cygwin, 7-Zip, or repository checkout.

  The script targets Windows PowerShell 5.1 (the baseline) and PowerShell 7.x.
  It installs into %ProgramFiles%\Dart Sass when that directory is writable or
  can be reached through one UAC prompt, and otherwise into
  %LOCALAPPDATA%\Programs\Dart Sass. An explicit -InstallDir is never replaced
  silently.

  Downloads are verified against the SHA-256 digest that GitHub publishes for
  the release asset (Dart Sass 1.89.1 and newer). A mismatch aborts before
  extraction. The extracted sass.bat is smoke tested before success is
  reported.

.PARAMETER Version
  Dart Sass version, with or without the "v" prefix. Default: latest
  (or $env:DART_SASS_VERSION).

.PARAMETER InstallDir
  Directory that receives sass.bat, sass, and src\. Default: Program Files or
  %LOCALAPPDATA%. $env:DART_SASS_INSTALL_DIR is the environment equivalent.

.PARAMETER NoEscalate
  Never request UAC; install into a writable user directory instead.

.PARAMETER System
  Require a system-wide install. Fails when Program Files cannot be written
  and UAC is unavailable or declined.

.PARAMETER User
  Install into %LOCALAPPDATA%\Programs\Dart Sass and never request UAC.
  Cannot be combined with -System, -InstallDir, or -Escalate.

.PARAMETER Escalate
  Require a system-wide install through UAC and fail instead of falling back
  to the user directory (DART_SASS_ESCALATE=always).

.PARAMETER Libc
  Only "auto" is valid on Windows. The other POSIX values are rejected with an
  explanation.

.PARAMETER Verify
  Verify the SHA-256 digest (default).

.PARAMETER NoVerify
  Skip SHA-256 digest verification. The smoke test still runs.

.PARAMETER Force
  Reinstall even when the requested version is already installed.

.PARAMETER NoForce
  Disable a force request inherited from $env:DART_SASS_FORCE.

.PARAMETER Yes
  Replace an installed version or remove it without asking for confirmation.
  $env:DART_SASS_YES is the environment equivalent.

.PARAMETER Uninstall
  Remove the Dart Sass files installed by this script (sass, sass.bat, src\,
  .dart-sass, and the package-manager marker) and exit. Use -InstallDir or
  -User to select the location; -DryRun lists the files without removing them.

.PARAMETER DryRun
  Resolve and print what would be installed without downloading, writing, or
  requesting UAC. Version and asset resolution still uses read-only HTTP
  requests, matching the POSIX installer.

.PARAMETER PrintEnv
  Print DART_SASS_VERSION, DART_SASS_BIN, and DART_SASS_DIR.

.PARAMETER PrintPath
  Print only the install directory, for PATH.

.PARAMETER NoPath
  Do not add the install directory to PATH (persistent, or $env:GITHUB_PATH in
  GitHub Actions). A manual snippet is printed instead. $env:DART_SASS_NO_PATH
  is the environment equivalent.

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
  .\install-dart-sass.ps1

.EXAMPLE
  .\install-dart-sass.ps1 -Version 1.108.2 -User

.EXAMPLE
  .\install-dart-sass.ps1 -Uninstall -DryRun -User

.NOTES
  Exit status: 0 on success, 1 on error. A declined UAC prompt or a cancelled
  update exits 0 when a usable user directory remains.
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

  [string]$Libc = '',

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

$script:ToolName = 'dart-sass'
$script:DisplayName = 'Dart Sass'
$script:Repo = 'sass/dart-sass'
$script:RepoUrl = if ($RepoUrl) { $RepoUrl.TrimEnd('/') } else { 'https://github.com/sass/dart-sass' }
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
$script:CrossArch = $false
$script:StageDir = ''
$script:PrintEnvMode = $false
$script:PrintPathMode = $false
$script:NoPathMode = $false
$script:PathScopeOverride = ''
$script:DryRunMode = $false
$script:NoEscalateMode = $false
$script:InstallDirArg = ''
$script:EscalateMode = 'auto'
$script:LibcArg = 'auto'
$script:DownloaderName = 'auto'
$script:InstallDirExplicit = $false
$script:VersionExplicit = $false

$script:Usage = @'
install-dart-sass.ps1 -- install the Dart Sass CLI on Windows.

Usage:
  .\install-dart-sass.ps1 [options] [version]

Options:
  -Version VERSION       Dart Sass version, with or without the "v" prefix.
                         Default: latest (or $env:DART_SASS_VERSION).
  -InstallDir DIR        Directory that receives sass.bat, sass, and src\.
                         Default: Program Files\Dart Sass when writable or
                         reachable through one UAC prompt, otherwise
                         %LOCALAPPDATA%\Programs\Dart Sass.
                         $env:DART_SASS_INSTALL_DIR is the environment
                         equivalent. An explicit directory is never silently
                         replaced when it cannot be written.
  -NoEscalate            Never request UAC; install into a writable user
                         directory instead.
  -System                Require a system-wide install; fail when Program Files
                         cannot be written and UAC is unavailable or declined.
  -User                  Install into %LOCALAPPDATA%\Programs\Dart Sass and
                         never request UAC. Cannot be combined with -System,
                         -InstallDir, or -Escalate.
  -Escalate              Require a system-wide install through UAC and fail
                         instead of falling back to the user directory.
  -Libc LIBC             Only "auto" is valid on Windows.
  -NoVerify              Skip SHA-256 digest verification. The smoke test
                         still runs.
  -Force                 Reinstall even when the version matches.
  -Yes                   Replace an installed version or remove it without
                         asking for confirmation. $env:DART_SASS_YES is the
                         environment equivalent.
  -Uninstall             Remove the files installed by this script and exit.
                         Use -InstallDir or -User to select the location;
                         -DryRun lists the files without removing them.
  -DryRun                Resolve and print what would be installed without
                         downloading, writing, or requesting UAC.
  -PrintEnv              Print DART_SASS_VERSION, DART_SASS_BIN, and
                         DART_SASS_DIR.
  -PrintPath             Print only the install directory (for PATH).
  -NoPath                Do not add the install directory to PATH (persistent,
                         or $env:GITHUB_PATH in GitHub Actions); print a manual
                         snippet instead. $env:DART_SASS_NO_PATH is the
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
  DART_SASS_ESCALATE (auto|never|always), DART_SASS_VERSION,
  DART_SASS_INSTALL_DIR, DART_SASS_LIBC, DART_SASS_VERIFY, DART_SASS_FORCE,
  DART_SASS_YES, DART_SASS_NO_PATH, GITHUB_TOKEN, DOWNLOADER, DOWNLOADER_ARGS.

Windows notes:
  The archive is extracted into the install directory as-is (sass.bat and
  src\), and a POSIX "sass" wrapper is written beside it for Git Bash/MSYS.
  Hugo resolves sass.bat through PATHEXT. No 7-Zip is required.

  The install directory is appended to the persistent machine PATH for a
  system-wide install, or to the persistent user PATH otherwise (idempotent;
  no duplicates). -NoPath prints a manual snippet instead. In GitHub Actions
  the script appends to $env:GITHUB_PATH instead of the persistent PATH, and
  writes dart-sass-style step outputs to $env:GITHUB_OUTPUT.

  When Program Files is used, a single UAC prompt elevates only the file copy;
  downloading, verification, and extraction stay in the non-elevated parent.
  Declining UAC falls back to the user directory unless -System or -Escalate
  was requested.

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
  $script:Version = if ($Version) { $Version } else { Get-EnvValue 'DART_SASS_VERSION' 'latest' }
  $script:InstallDirArg = if ($InstallDir) { $InstallDir } else { Get-EnvValue 'DART_SASS_INSTALL_DIR' '' }
  $script:NoPathMode = $NoPath.IsPresent -or (Test-Truthy (Get-EnvValue 'DART_SASS_NO_PATH' '0'))
  $script:PathScopeOverride = $PathScope
  $script:EscalateMode = Get-EnvValue 'DART_SASS_ESCALATE' 'auto'
  $script:LibcArg = if ($Libc) { $Libc } else { Get-EnvValue 'DART_SASS_LIBC' 'auto' }
  $script:DownloaderName = if ($Downloader) { $Downloader } else { Get-EnvValue 'DOWNLOADER' 'auto' }
  $script:GitHubToken = if ($GitHubToken) { $GitHubToken } else { Get-EnvValue 'GITHUB_TOKEN' '' }
  $script:InstallDirExplicit = -not [string]::IsNullOrEmpty($script:InstallDirArg)

  if (@($script:DownloaderArgs).Count -eq 0) {
    $rawArgs = Get-EnvValue 'DOWNLOADER_ARGS' ''
    if (-not [string]::IsNullOrWhiteSpace($rawArgs)) {
      $script:DownloaderArgs = @($rawArgs -split '\s+' | Where-Object { $_ })
    }
  }

  if (-not [string]::IsNullOrEmpty((Get-EnvValue 'DART_SASS_PREFIX' ''))) {
    Write-Warn 'DART_SASS_PREFIX is no longer supported and will be ignored; set DART_SASS_INSTALL_DIR to the install directory instead.'
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
    $result.Path = Join-Path (Get-UserProgramsDir) 'Dart Sass'
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

  $system = Join-Path (Get-SystemProgramFiles $Arch) 'Dart Sass'
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

  $result.Path = Join-Path (Get-UserProgramsDir) 'Dart Sass'
  return $result
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
# Safe zip extraction and gzip
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
    $result = Get-Content -Raw -LiteralPath $resultPath | ConvertFrom-Json
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
    $manifest = Get-Content -Raw -LiteralPath $ManifestPath | ConvertFrom-Json
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
    Write-Note "$script:InstallDir is not writable; requesting one UAC prompt for the file copy."
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
  foreach ($name in @('sass', 'dart')) {
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
# Version and asset resolution
# ---------------------------------------------------------------------------

function Get-AssetArch {
  param([string]$Arch)
  switch ($Arch) {
    'amd64' { return 'x64' }
    '386' { return 'ia32' }
    default { return $Arch }
  }
}

function Get-DartSassAssetNames {
  param([string]$AssetVersion, [string]$Arch)
  $assetArch = Get-AssetArch $Arch
  $names = @("dart-sass-$AssetVersion-windows-$assetArch.zip")
  if ($assetArch -eq 'arm64') { $names += "dart-sass-$AssetVersion-windows-x64.zip" }
  return $names
}

function Resolve-DartSassAsset {
  param([string]$AssetVersion, [string]$Arch)
  $names = Get-DartSassAssetNames $AssetVersion $Arch
  foreach ($name in $names) {
    if (Test-UrlExists "$script:ReleaseBase/$AssetVersion/$name") {
      return $name
    }
  }
  if (-not (Test-UrlExists "$script:RepoUrl/releases/tag/$AssetVersion")) {
    throw "Dart Sass $AssetVersion does not exist. Check the version against $script:RepoUrl/releases."
  }
  if ($Arch -eq '386' -and (Test-VersionGe $AssetVersion '1.89.1')) {
    throw "Dart Sass stopped publishing 32-bit x86 builds in 1.89.1; request 1.89.0 or older, or use a 64-bit system."
  }
  throw "Dart Sass $AssetVersion publishes no Windows build for $(Get-AssetArch $Arch). Check the release assets at $script:RepoUrl/releases/tag/$AssetVersion."
}

function Get-InstalledSassVersion {
  param([string]$Directory)
  $bat = Join-Path $Directory 'sass.bat'
  if (-not (Test-Path -LiteralPath $bat)) { return '' }
  try {
    $output = & $bat --version 2>&1 | Out-String
    $match = [regex]::Match($output, '(?m)^(\d+\.\d+\.\d+)')
    if ($match.Success) { return $match.Groups[1].Value }
  } catch { }
  return ''
}

function Test-SassLayout {
  param([string]$Directory)
  return ((Test-Path -LiteralPath (Join-Path $Directory 'sass.bat')) -and
    (Test-Path -LiteralPath (Join-Path $Directory 'src\dart.exe')))
}

function Get-SassUninstallLayout {
  param([string]$Directory)
  if (Test-Path -LiteralPath (Join-Path $Directory '.dart-sass-package-manager')) { return 'package-manager' }
  if ((Test-Path -LiteralPath (Join-Path $Directory 'sass.bat')) -and
    (Test-Path -LiteralPath (Join-Path $Directory 'src\sass.snapshot'))) { return 'windows' }
  if ((Test-Path -LiteralPath (Join-Path $Directory '.dart-sass\sass')) -or
    ((Test-Path -LiteralPath (Join-Path $Directory 'src\sass.snapshot')) -and
      ((Test-Path -LiteralPath (Join-Path $Directory 'src\dart')) -or
        (Test-Path -LiteralPath (Join-Path $Directory 'src\dart.exe'))))) { return 'binary' }
  return ''
}

function Get-SassUninstallTargets {
  param([string]$Directory, [string]$Layout)
  $targets = @()
  switch ($Layout) {
    'package-manager' { $names = @('sass', 'dart-sass', '.dart-sass-package-manager') }
    'windows' { $names = @('sass', 'sass.bat') }
    'binary' { $names = @('sass', 'dart-sass', '.dart-sass') }
    default { return $targets }
  }
  foreach ($name in $names) {
    $path = Join-Path $Directory $name
    if (Test-Path -LiteralPath $path) { $targets += $path }
  }
  if ($Layout -eq 'windows' -or $Layout -eq 'binary') {
    $src = Join-Path $Directory 'src'
    if ((Test-Path -LiteralPath (Join-Path $src 'sass.snapshot')) -and
      ((Test-Path -LiteralPath (Join-Path $src 'dart')) -or (Test-Path -LiteralPath (Join-Path $src 'dart.exe')))) {
      $targets += $src
    }
  }
  return $targets
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
  $system = Join-Path (Get-SystemProgramFiles (Get-PlatformArch)) 'Dart Sass'
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

function Complete-SassInstall {
  param([string]$InstalledVersion)
  Write-PathGuidance $script:InstallDir
  $bin = Join-Path $script:InstallDir 'sass.bat'
  Write-GitHubOutput 'dart-sass-version' $InstalledVersion
  Write-GitHubOutput 'dart-sass-path' $bin
  Write-GitHubPath $script:InstallDir
  if ($script:PrintEnvMode) {
    [Console]::Out.WriteLine("DART_SASS_VERSION=$InstalledVersion")
    [Console]::Out.WriteLine("DART_SASS_BIN=$bin")
    [Console]::Out.WriteLine("DART_SASS_DIR=$script:InstallDir")
  }
  if ($script:PrintPathMode) {
    [Console]::Out.WriteLine($script:InstallDir)
  }
  Write-Note "Dart Sass $InstalledVersion installed at $bin"
  return 0
}

# ---------------------------------------------------------------------------
# Uninstall
# ---------------------------------------------------------------------------

function Invoke-SassUninstall {
  $layout = Get-SassUninstallLayout $script:InstallDir
  if ([string]::IsNullOrEmpty($layout)) {
    Write-Note "Dart Sass is not installed by this script in $script:InstallDir; nothing to remove."
    return 0
  }

  $targets = @(Get-SassUninstallTargets $script:InstallDir $layout)

  if ($script:DryRunMode) {
    Write-DryLine 'uninstall=1'
    Write-DryLine "method=$layout"
    Write-DryLine "install_dir=$script:InstallDir"
    foreach ($target in $targets) { Write-DryLine "remove=$target" }
    if (-not (Test-PathUpdateDisabled)) {
      Write-DryLine "path_scope=$(Get-PathScope $script:InstallDir)"
    } else {
      Write-DryLine 'path_update=disabled'
    }
    return 0
  }

  if (-not $script:AssumeYes) {
    if (-not (Test-IsInteractive)) {
      throw "Dart Sass is installed in $script:InstallDir; pass -Yes to remove it without confirmation."
    }
    if (-not (Read-Confirmation "Remove Dart Sass from $script:InstallDir?")) {
      Write-Note "uninstall cancelled; Dart Sass remains installed in $script:InstallDir."
      return 0
    }
  }

  $inUse = Test-InstallDirInUse $script:InstallDir
  if ($inUse) {
    throw "cannot remove Dart Sass while '$inUse' is running from $script:InstallDir; close it and retry."
  }

  $operations = @()
  foreach ($target in $targets) {
    if ($target -eq (Join-Path $script:InstallDir 'src')) {
      $operations += @{ op = 'removeTree'; path = $target }
    } elseif ($target -eq (Join-Path $script:InstallDir '.dart-sass')) {
      $operations += @{ op = 'removeTree'; path = $target }
    } else {
      $operations += @{ op = 'remove'; path = $target }
    }
  }
  if (-not (Test-PathUpdateDisabled)) {
    $operations += @{
      op = 'path-remove'
      scope = (Get-PathScope $script:InstallDir)
      value = $script:InstallDir
      anchor = (Join-Path $script:InstallDir 'sass.bat')
    }
  }

  $manifest = @{
    version = 1
    sourceRoot = ''
    roots = @($script:InstallDir)
    operations = $operations
  }

  Write-Note "removing Dart Sass from $script:InstallDir."
  $result = Invoke-WriteManifest $manifest
  if (-not $result.Success) {
    $detail = ''
    if ($result.Errors) { $detail = ' ' + ($result.Errors -join ' ') }
    throw "cannot remove Dart Sass from $script:InstallDir.$detail"
  }

  $left = @(Get-SassUninstallTargets $script:InstallDir $layout)
  if ($left.Count -gt 0) {
    throw "some Dart Sass files remain in $($script:InstallDir): $($left -join ', ')"
  }

  Write-Note "Dart Sass removed from $script:InstallDir."
  if ($layout -eq 'package-manager') {
    Write-Note "the 'sass' package installed globally by bun, pnpm, or npm was left in place; remove it with that package manager if it is no longer needed."
  }
  return 0
}

# ---------------------------------------------------------------------------
# Install
# ---------------------------------------------------------------------------

function Invoke-SassInstall {
  $arch = Get-PlatformArch

  if ([string]::IsNullOrEmpty($script:Version) -or $script:Version -eq 'latest') {
    Write-Note 'resolving the latest Dart Sass release'
    $script:Version = Resolve-LatestTag
  }

  $resolved = $script:Version.Trim()
  if ($resolved.StartsWith('v') -or $resolved.StartsWith('V')) { $resolved = $resolved.Substring(1) }
  if ([string]::IsNullOrEmpty($resolved) -or $resolved -notmatch '^[0-9A-Za-z][0-9A-Za-z.-]*$' -or $resolved.Contains('..') -or $resolved.StartsWith('-')) {
    throw "invalid Dart Sass version: '$resolved'"
  }
  $script:ResolvedVersion = $resolved

  $plan = Get-InstallDirPlan $arch
  $script:InstallDir = $plan.Path
  $script:NeedsElevation = [bool]$plan.NeedsElevation

  if ($script:DryRunMode) {
    $asset = $null
    $names = Get-DartSassAssetNames $script:ResolvedVersion $arch
    foreach ($name in $names) {
      if (Test-UrlExists "$script:ReleaseBase/$script:ResolvedVersion/$name") { $asset = $name; break }
    }
    if (-not $asset) {
      $asset = $names[0]
      Write-Warn "no published asset was found for $($script:ResolvedVersion)/$arch; the first candidate is shown."
    }
    Write-DryLine "version=$script:ResolvedVersion"
    Write-DryLine "asset=$asset"
    Write-DryLine "url=$script:ReleaseBase/$script:ResolvedVersion/$asset"
    Write-DryLine 'method=binary'
    Write-DryLine 'os=windows'
    Write-DryLine "arch=$(Get-AssetArch $arch)"
    Write-DryLine 'libc=native'
    Write-DryLine "install_dir=$script:InstallDir"
    Write-DryLine "escalation=$($plan.Label)"
    Write-DryLine "bin=$(Join-Path $script:InstallDir 'sass.bat')"
    if (Test-PathUpdateDisabled) {
      Write-DryLine 'path_update=disabled'
    } else {
      Write-DryLine "path_scope=$(Get-PathScope $script:InstallDir)"
    }
    if ($script:PrintEnvMode) {
      [Console]::Out.WriteLine("DART_SASS_VERSION=$script:ResolvedVersion")
      [Console]::Out.WriteLine("DART_SASS_BIN=$(Join-Path $script:InstallDir 'sass.bat')")
      [Console]::Out.WriteLine("DART_SASS_DIR=$script:InstallDir")
    }
    if ($script:PrintPathMode) { [Console]::Out.WriteLine($script:InstallDir) }
    return 0
  }

  $asset = Resolve-DartSassAsset $script:ResolvedVersion $arch
  $script:ResolvedAsset = $asset
  if ($arch -eq 'arm64' -and $asset -match '-x64\.zip$') {
    $script:CrossArch = $true
    Write-Warn "no ARM64 build exists for Dart Sass $($script:ResolvedVersion); installing the x64 build (runs through x64 emulation on Windows on ARM). Native Windows ARM64 builds exist from 1.89.1."
  }

  $sassBat = Join-Path $script:InstallDir 'sass.bat'

  if (-not $script:ForceInstall) {
    $current = Get-InstalledSassVersion $script:InstallDir
    if ($current) {
      if ($current -eq $script:ResolvedVersion) {
        if (Test-SassLayout $script:InstallDir) {
          Write-Note "Dart Sass $current is already installed in $script:InstallDir; nothing to do."
          return (Complete-SassInstall $current)
        }
        Write-Note "repairing the Dart Sass $current payload in $script:InstallDir."
      } else {
        if (-not $script:AssumeYes) {
          if (-not (Test-IsInteractive)) {
            throw "Dart Sass $current is already installed in $script:InstallDir; pass -Yes to replace it with $($script:ResolvedVersion) without confirmation."
          }
          if (-not (Read-Confirmation "Dart Sass $current is installed in $script:InstallDir. Replace it with $($script:ResolvedVersion)?")) {
            Write-Note "update cancelled; Dart Sass $current remains installed in $script:InstallDir."
            return 0
          }
        }
        Write-Note "replacing Dart Sass $current in $script:InstallDir with $($script:ResolvedVersion)."
      }
    }
  }

  $script:WorkDir = Join-Path ([IO.Path]::GetTempPath()) ("dart-sass-install-" + [Guid]::NewGuid().ToString('N'))
  New-Item -ItemType Directory -Path $script:WorkDir -Force | Out-Null
  $downloadPath = Join-Path $script:WorkDir $asset

  Write-Note "downloading $script:ReleaseBase/$($script:ResolvedVersion)/$asset"
  Get-RemoteFile "$script:ReleaseBase/$($script:ResolvedVersion)/$asset" $downloadPath

  if ($script:VerifyFile) {
    if (Test-VersionGe $script:ResolvedVersion '1.89.1') {
      $digest = $null
      $digestError = $null
      try {
        $digest = Get-ReleaseAssetDigest $script:ResolvedVersion $asset
      } catch {
        $digestError = $_.Exception.Message
      }
      if ($digestError) {
        Write-Warn "the GitHub API could not be queried for the SHA-256 digest of $asset (network or rate limiting); skipping verification. Pass -GitHubToken to avoid rate limits."
      } elseif (-not $digest) {
        Write-Warn "the GitHub release for Dart Sass $($script:ResolvedVersion) publishes no SHA-256 digest for $asset; skipping verification."
      } elseif (-not (Test-Sha256 $digest $downloadPath)) {
        throw "SHA-256 mismatch for $asset (the digest published in the GitHub release does not match the downloaded archive)."
      } else {
        Write-Note 'SHA-256 verification succeeded (GitHub release asset digest).'
      }
    } else {
      Write-Warn "Dart Sass $($script:ResolvedVersion) predates the first release with published SHA-256 asset digests (1.89.1); skipping verification."
    }
  } else {
    Write-Note 'file verification is disabled (-NoVerify).'
  }

  $extractDir = Join-Path $script:WorkDir 'extract'
  New-Item -ItemType Directory -Path $extractDir -Force | Out-Null
  Expand-ZipSafely $downloadPath $extractDir

  $extracted = Join-Path $extractDir 'dart-sass'
  if (-not (Test-Path -LiteralPath $extracted)) {
    throw "unexpected archive layout: $asset has no top-level 'dart-sass' directory."
  }
  if (-not (Test-Path -LiteralPath (Join-Path $extracted 'sass.bat'))) {
    throw "unexpected archive layout: $asset has no 'dart-sass/sass.bat'."
  }

  $script:StageDir = Join-Path $script:WorkDir 'stage-payload'
  New-Item -ItemType Directory -Path $script:StageDir -Force | Out-Null
  Copy-TreeSafe $extracted $script:StageDir
  Write-Utf8NoBom (Join-Path $script:StageDir 'sass') "#!/bin/sh`nexec `"`$(dirname `"`$0`")/sass.bat`" `"`$@`"`n"

  $operations = @()
  $oldSrc = Join-Path $script:InstallDir 'src'
  if (Test-Path -LiteralPath (Join-Path $oldSrc 'sass.snapshot')) {
    $operations += @{ op = 'removeTree'; path = $oldSrc }
  }
  $oldPayload = Join-Path $script:InstallDir '.dart-sass'
  if (Test-Path -LiteralPath $oldPayload) {
    $operations += @{ op = 'removeTree'; path = $oldPayload }
  }
  $operations += @{ op = 'copyTree'; source = $script:StageDir; destination = $script:InstallDir }
  if (-not (Test-PathUpdateDisabled)) {
    $operations += @{ op = 'path'; scope = (Get-PathScope $script:InstallDir); value = $script:InstallDir }
  }

  $manifest = @{
    version = 1
    sourceRoot = $script:StageDir
    roots = @($script:InstallDir)
    operations = $operations
  }

  $result = Invoke-WriteManifest $manifest
  if (-not $result.Success -and -not $script:InstallDirExplicit -and -not $script:SystemOnly -and $script:EscalateMode -ne 'always') {
    $reason = 'the privileged write failed'
    if ($result.Cancelled) { $reason = 'UAC was cancelled' }
    $script:InstallDir = Join-Path (Get-UserProgramsDir) 'Dart Sass'
    $script:NeedsElevation = $false
    Write-Warn "$reason; falling back to $script:InstallDir."

    $fallbackCurrent = Get-InstalledSassVersion $script:InstallDir
    if ($fallbackCurrent -and -not $script:ForceInstall -and -not $script:AssumeYes) {
      if (-not (Test-IsInteractive)) {
        throw "Dart Sass $fallbackCurrent is already installed in $script:InstallDir; pass -Yes to replace it with $($script:ResolvedVersion) without confirmation."
      }
      if (-not (Read-Confirmation "Dart Sass $fallbackCurrent is installed in $script:InstallDir. Replace it with $($script:ResolvedVersion)?")) {
        Write-Note "update cancelled; Dart Sass $fallbackCurrent remains installed in $script:InstallDir."
        return 0
      }
    }

    $fallbackOperations = @()
    $fallbackSrc = Join-Path $script:InstallDir 'src'
    if (Test-Path -LiteralPath (Join-Path $fallbackSrc 'sass.snapshot')) {
      $fallbackOperations += @{ op = 'removeTree'; path = $fallbackSrc }
    }
    $fallbackPayload = Join-Path $script:InstallDir '.dart-sass'
    if (Test-Path -LiteralPath $fallbackPayload) {
      $fallbackOperations += @{ op = 'removeTree'; path = $fallbackPayload }
    }
    $fallbackOperations += @{ op = 'copyTree'; source = $script:StageDir; destination = $script:InstallDir }
    if (-not (Test-PathUpdateDisabled)) {
      $fallbackOperations += @{ op = 'path'; scope = 'User'; value = $script:InstallDir }
    }

    $manifest = @{
      version = 1
      sourceRoot = $script:StageDir
      roots = @($script:InstallDir)
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

  if (-not (Test-SassLayout $script:InstallDir)) {
    throw "the write to $script:InstallDir reported success but did not produce sass.bat and src\dart.exe."
  }
  $installedBat = Join-Path $script:InstallDir 'sass.bat'
  if ((Get-Sha256 $installedBat) -ne (Get-Sha256 (Join-Path $script:StageDir 'sass.bat'))) {
    throw "the installed sass.bat in $script:InstallDir does not match the verified archive."
  }

  Write-Note "Dart Sass payload installed in $script:InstallDir."

  $smokeOutput = ''
  $smokeCode = 0
  try {
    $smokeOutput = (& $installedBat --version 2>&1 | Out-String).Trim()
    $smokeCode = $LASTEXITCODE
    if ($null -eq $smokeCode) { $smokeCode = 0 }
  } catch {
    $smokeCode = 1
    $smokeOutput = $_.Exception.Message
  }
  $installedVersion = ''
  if ($smokeCode -eq 0) {
    $match = [regex]::Match($smokeOutput, '(?m)^(\d+\.\d+\.\d+)')
    if ($match.Success) { $installedVersion = $match.Groups[1].Value }
  }

  if ($installedVersion -and $installedVersion -eq $script:ResolvedVersion) {
    Write-Note "smoke test passed: Dart Sass $installedVersion"
  } elseif ($script:CrossArch) {
    Write-Warn "the installed $arch build could not be executed on this machine (expected when a cross-architecture fallback is involved): 'sass --version' exited with code $smokeCode."
    Write-Warn 'install emulation support (Windows on ARM x64 emulation) or use a matching architecture.'
    $installedVersion = $script:ResolvedVersion
  } elseif ($smokeCode -ne 0) {
    throw "the installed Dart Sass binary failed to execute ('sass --version' exited with code $smokeCode)."
  } elseif (-not $installedVersion) {
    throw "could not read the installed Dart Sass version from: $smokeOutput"
  } else {
    throw "installed version $installedVersion does not match the requested $($script:ResolvedVersion)."
  }

  return (Complete-SassInstall $installedVersion)
}

# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

function Invoke-Main {
  $script:PrintEnvMode = $PrintEnv.IsPresent
  $script:PrintPathMode = $PrintPath.IsPresent
  $script:DryRunMode = $DryRun.IsPresent
  $script:NoEscalateMode = $NoEscalate.IsPresent

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
    throw "invalid DART_SASS_ESCALATE value: '$script:EscalateMode' (use auto, never, or always)"
  }

  if ($System.IsPresent) {
    if ($script:NoEscalateMode -or $script:EscalateMode -eq 'never') {
      throw 'cannot combine -System with -NoEscalate (or DART_SASS_ESCALATE=never).'
    }
    $script:EscalateMode = 'always'
  }
  if ($User.IsPresent) {
    if ($System.IsPresent) { throw 'cannot combine -User with -System.' }
    if ($script:InstallDirExplicit) { throw 'cannot combine -User with -InstallDir (or DART_SASS_INSTALL_DIR).' }
    if ($Escalate.IsPresent -or $script:EscalateMode -eq 'always') { throw 'cannot combine -User with -Escalate (or DART_SASS_ESCALATE=always).' }
    $script:EscalateMode = 'never'
  }
  if ($Escalate.IsPresent) { $script:EscalateMode = 'always' }
  if ($script:NoEscalateMode) { $script:EscalateMode = 'never' }

  if ($Uninstall.IsPresent) {
    if ($script:PrintEnvMode) { throw 'cannot combine -Uninstall with -PrintEnv.' }
    if ($script:PrintPathMode) { throw 'cannot combine -Uninstall with -PrintPath.' }
    if ($script:VersionExplicit) { throw 'version arguments are not valid with -Uninstall.' }
  }

  if (-not [string]::IsNullOrEmpty($script:LibcArg)) { $script:LibcArg = $script:LibcArg.ToLowerInvariant() }
  if ($script:LibcArg -ne 'auto' -and $script:LibcArg -ne '') {
    throw "invalid -Libc value: '$script:LibcArg'; Windows always uses the native build, so only 'auto' is supported."
  }

  $verifyEnv = Get-EnvValue 'DART_SASS_VERIFY' '1'
  if ($NoVerify.IsPresent) {
    $script:VerifyFile = $false
  } elseif ($Verify.IsPresent) {
    $script:VerifyFile = $true
  } else {
    $script:VerifyFile = Test-Truthy $verifyEnv
  }

  $forceEnv = Get-EnvValue 'DART_SASS_FORCE' '0'
  if ($NoForce.IsPresent) {
    $script:ForceInstall = $false
  } elseif ($Force.IsPresent) {
    $script:ForceInstall = $true
  } else {
    $script:ForceInstall = Test-Truthy $forceEnv
  }

  if (-not $script:AssumeYes) {
    $script:AssumeYes = Test-Truthy (Get-EnvValue 'DART_SASS_YES' '0')
  }

  if ([string]::IsNullOrEmpty($script:DownloaderName)) { $script:DownloaderName = 'auto' }

  $arch = Get-PlatformArch
  if ($Uninstall.IsPresent) {
    $plan = Get-InstallDirPlan $arch
    $script:InstallDir = $plan.Path
    $script:NeedsElevation = [bool]$plan.NeedsElevation

    if (-not $script:InstallDirExplicit -and -not $script:UserOnly -and -not $script:SystemOnly) {
      $userDir = Join-Path (Get-UserProgramsDir) 'Dart Sass'
      if ([string]::IsNullOrEmpty((Get-SassUninstallLayout $script:InstallDir)) `
          -and -not [string]::IsNullOrEmpty((Get-SassUninstallLayout $userDir))) {
        $script:InstallDir = $userDir
        $script:NeedsElevation = $false
      }
    }
    return (Invoke-SassUninstall)
  }

  return (Invoke-SassInstall)
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
