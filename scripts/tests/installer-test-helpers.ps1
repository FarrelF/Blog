<#
.SYNOPSIS
  Shared helpers for the PowerShell installer tests.

.DESCRIPTION
  Self-contained test harness: no Pester, administrator rights, or external
  services are required. Dot-source this file from a test script, call
  Test-Case with a script block, and finish with Exit-TestRun.
#>

$script:TestCount = 0
$script:TestFailures = 0
$script:TestSkips = 0

function Write-TestPass {
  param([string]$Name)
  Write-Host "PASS $Name" -ForegroundColor Green
}

function Write-TestFail {
  param([string]$Name, [string]$Message)
  Write-Host "FAIL $Name" -ForegroundColor Red
  if (-not [string]::IsNullOrEmpty($Message)) {
    Write-Host "     $Message" -ForegroundColor Red
  }
}

function Write-TestSkip {
  param([string]$Name, [string]$Reason)
  Write-Host "SKIP $Name ($Reason)" -ForegroundColor Yellow
}

function Test-Case {
  param([string]$Name, [scriptblock]$Body)
  $script:TestCount++
  try {
    & $Body
    Write-TestPass $Name
  } catch {
    $script:TestFailures++
    Write-TestFail $Name $_.Exception.Message
  }
}

function Skip-Case {
  param([string]$Name, [string]$Reason)
  $script:TestSkips++
  Write-TestSkip $Name $Reason
}

function Assert-True {
  param([bool]$Condition, [string]$Message = 'expected the condition to be true')
  if (-not $Condition) { throw $Message }
}

function Assert-False {
  param([bool]$Condition, [string]$Message = 'expected the condition to be false')
  if ($Condition) { throw $Message }
}

function Assert-Equal {
  param($Actual, $Expected, [string]$Label = 'value')
  if ("$Actual" -ne "$Expected") {
    throw "$Label mismatch: expected '$Expected', got '$Actual'"
  }
}

function Assert-Contains {
  param([string]$Text, [string]$Needle, [string]$Label = 'output')
  if ($null -eq $Text -or -not $Text.Contains($Needle)) {
    throw "$Label does not contain '$Needle'. Output:`n$Text"
  }
}

function Assert-NotContains {
  param([string]$Text, [string]$Needle, [string]$Label = 'output')
  if ($null -ne $Text -and $Text.Contains($Needle)) {
    throw "$Label unexpectedly contains '$Needle'. Output:`n$Text"
  }
}

function Assert-Match {
  param([string]$Text, [string]$Pattern, [string]$Label = 'output')
  if ($null -eq $Text -or $Text -notmatch $Pattern) {
    throw "$Label does not match '$Pattern'. Output:`n$Text"
  }
}

function Assert-FileExists {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) { throw "expected file to exist: $Path" }
}

function Assert-FileMissing {
  param([string]$Path)
  if (Test-Path -LiteralPath $Path) { throw "expected file to be absent: $Path" }
}

function New-TestWorkspace {
  param([string]$Label = 'installer')
  $path = Join-Path ([IO.Path]::GetTempPath()) ("$Label-tests-" + [Guid]::NewGuid().ToString('N'))
  New-Item -ItemType Directory -Path $path -Force | Out-Null
  return $path
}

function Remove-TestWorkspace {
  param([string]$Path)
  if (-not [string]::IsNullOrEmpty($Path) -and (Test-Path -LiteralPath $Path)) {
    Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction SilentlyContinue
  }
}

function Get-TestPowerShell {
  $path = ''
  try { $path = (Get-Process -Id $PID).Path } catch { }
  if (-not [string]::IsNullOrEmpty($path) -and (Test-Path -LiteralPath $path)) {
    return $path
  }
  if ($PSVersionTable.PSEdition -eq 'Core') {
    return (Join-Path $PSHOME 'pwsh.exe')
  }
  return (Join-Path $PSHOME 'powershell.exe')
}

function Quote-ProcessArgument {
  param([string]$Value)
  if ($null -eq $Value) { return '""' }
  if ($Value -notmatch '[\s"]') { return $Value }
  return '"' + ($Value -replace '"', '\"') + '"'
}

function Invoke-InstallerScript {
  param(
    [string]$ScriptPath,
    [string[]]$Arguments = @(),
    [string]$WorkDirectory = '',
    [hashtable]$Environment = @{}
  )

  if ([string]::IsNullOrEmpty($WorkDirectory)) {
    $WorkDirectory = [IO.Path]::GetTempPath()
  }
  $id = [Guid]::NewGuid().ToString('N')
  $outFile = Join-Path $WorkDirectory "stdout-$id.txt"
  $errFile = Join-Path $WorkDirectory "stderr-$id.txt"

  $quoted = @()
  foreach ($argument in $Arguments) {
    $quoted += (Quote-ProcessArgument ([string]$argument))
  }
  $argumentLine = '-NoProfile -ExecutionPolicy Bypass -File ' + (Quote-ProcessArgument $ScriptPath)
  if ($quoted.Count -gt 0) {
    $argumentLine = $argumentLine + ' ' + ($quoted -join ' ')
  }

  # Keep the suites from touching the real persistent PATH. Tests that exercise
  # PATH handling override these or pass the hidden -PathScope Process hook.
  $overrides = @{}
  foreach ($name in @('HUGO_NO_PATH', 'DART_SASS_NO_PATH')) {
    if ([string]::IsNullOrEmpty([Environment]::GetEnvironmentVariable($name))) {
      $overrides[$name] = '1'
    }
  }
  # Never append to the real GitHub Actions files from a test.
  foreach ($name in @('GITHUB_PATH', 'GITHUB_OUTPUT')) {
    if ([string]::IsNullOrEmpty([Environment]::GetEnvironmentVariable($name))) {
      $overrides[$name] = ''
    }
  }
  foreach ($key in $Environment.Keys) { $overrides[$key] = [string]$Environment[$key] }
  $saved = @{}
  foreach ($key in $overrides.Keys) {
    $saved[$key] = [Environment]::GetEnvironmentVariable($key)
    [Environment]::SetEnvironmentVariable($key, $overrides[$key])
  }

  try {
    $process = Start-Process -FilePath (Get-TestPowerShell) -ArgumentList $argumentLine `
      -RedirectStandardOutput $outFile -RedirectStandardError $errFile `
      -NoNewWindow -Wait -PassThru
  } finally {
    foreach ($key in $saved.Keys) {
      [Environment]::SetEnvironmentVariable($key, $saved[$key])
    }
  }

  $stdout = ''
  $stderr = ''
  if (Test-Path -LiteralPath $outFile) { $stdout = [IO.File]::ReadAllText($outFile) }
  if (Test-Path -LiteralPath $errFile) { $stderr = [IO.File]::ReadAllText($errFile) }
  Remove-Item -LiteralPath $outFile -Force -ErrorAction SilentlyContinue
  Remove-Item -LiteralPath $errFile -Force -ErrorAction SilentlyContinue

  return @{
    ExitCode = $process.ExitCode
    StdOut = $stdout
    StdErr = $stderr
    Output = $stdout + $stderr
  }
}

function Get-Sha256Hex {
  param([string]$Path)
  return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Get-TestArch {
  $value = [Environment]::GetEnvironmentVariable('PROCESSOR_ARCHITEW6432')
  if ([string]::IsNullOrEmpty($value)) {
    $value = [Environment]::GetEnvironmentVariable('PROCESSOR_ARCHITECTURE')
  }
  switch ($value.ToUpperInvariant()) {
    'AMD64' { return 'amd64' }
    'ARM64' { return 'arm64' }
    'X86' { return '386' }
  }
  return 'amd64'
}

function New-FixtureZip {
  param([string]$SourceDirectory, [string]$ZipPath)
  Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue
  if (Test-Path -LiteralPath $ZipPath) { Remove-Item -LiteralPath $ZipPath -Force }
  [IO.Compression.ZipFile]::CreateFromDirectory($SourceDirectory, $ZipPath)
}

function New-ZipSlipFixture {
  param([string]$ZipPath, [string]$EntryName = '../evil.txt', [string]$Content = 'escaped')
  Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue
  if (Test-Path -LiteralPath $ZipPath) { Remove-Item -LiteralPath $ZipPath -Force }
  $archive = [IO.Compression.ZipFile]::Open($ZipPath, [IO.Compression.ZipArchiveMode]::Create)
  try {
    $entry = $archive.CreateEntry($EntryName)
    $writer = New-Object IO.StreamWriter -ArgumentList $entry.Open()
    try { $writer.Write($Content) } finally { $writer.Dispose() }
  } finally {
    $archive.Dispose()
  }
}

function New-FakeHugoExe {
  param([string]$Path, [string]$Version)

  $csc = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
  if (-not (Test-Path -LiteralPath $csc)) {
    $csc = Join-Path $env:WINDIR 'Microsoft.NET\Framework\v4.0.30319\csc.exe'
  }
  if (-not (Test-Path -LiteralPath $csc)) {
    throw 'csc.exe was not found; the fake Hugo binary cannot be compiled.'
  }

  $sourcePath = "$Path.cs"
  $code = @"
using System;
using System.IO;

class Program
{
    static int Main(string[] args)
    {
        if (args.Length > 0 && args[0] == "version")
        {
            Console.WriteLine("hugo v$Version windows/amd64");
            return 0;
        }
        if (args.Length > 0 && (args[0] == "-h" || args[0] == "--help"))
        {
            Console.WriteLine("usage: hugo");
            return 0;
        }
        if (args.Length > 2 && args[0] == "gen" && args[1] == "man")
        {
            string dir = null;
            for (int i = 2; i < args.Length - 1; i++)
            {
                if (args[i] == "--dir") { dir = args[i + 1]; }
            }
            if (dir != null)
            {
                Directory.CreateDirectory(dir);
                File.WriteAllText(Path.Combine(dir, "hugo.1"), ".TH HUGO 1\n");
                File.WriteAllText(Path.Combine(dir, "hugo-version.1"), ".TH HUGO 1\n");
            }
            return 0;
        }
        if (args.Length > 1 && args[0] == "completion")
        {
            Console.WriteLine("# completion for " + args[1]);
            return 0;
        }
        Console.WriteLine("hugo v$Version windows/amd64");
        return 0;
    }
}
"@
  [IO.File]::WriteAllText($sourcePath, $code, [Text.ASCIIEncoding]::new())
  try {
    $output = & $csc /nologo /target:exe "/out:$Path" $sourcePath 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) {
      throw "csc failed: $output"
    }
  } finally {
    Remove-Item -LiteralPath $sourcePath -Force -ErrorAction SilentlyContinue
  }
  if (-not (Test-Path -LiteralPath $Path)) {
    throw "csc did not produce $Path"
  }
}

function New-FakeSassZip {
  param([string]$ZipPath, [string]$Version)

  $source = Join-Path ([IO.Path]::GetTempPath()) ("fake-sass-" + [Guid]::NewGuid().ToString('N'))
  $root = Join-Path $source 'dart-sass'
  $src = Join-Path $root 'src'
  New-Item -ItemType Directory -Path $src -Force | Out-Null

  $bat = "@echo off`r`necho $Version`r`n"
  [IO.File]::WriteAllText((Join-Path $root 'sass.bat'), $bat, [Text.ASCIIEncoding]::new())
  [IO.File]::WriteAllText((Join-Path $src 'dart.exe'), '', [Text.ASCIIEncoding]::new())
  [IO.File]::WriteAllText((Join-Path $src 'sass.snapshot'), '', [Text.ASCIIEncoding]::new())

  New-FixtureZip $source $ZipPath
  Remove-Item -LiteralPath $source -Recurse -Force -ErrorAction SilentlyContinue
}

function Start-FixtureServer {
  param(
    [string]$Root,
    [string]$WorkDirectory,
    [string]$LatestTag = 'v0.152.2'
  )

  $serverScript = Join-Path $PSScriptRoot 'fixture-server.ps1'
  if (-not (Test-Path -LiteralPath $serverScript)) {
    throw "fixture server not found: $serverScript"
  }
  $portFile = Join-Path $WorkDirectory ('fixture-port-' + [Guid]::NewGuid().ToString('N') + '.txt')
  $argumentLine = '-NoProfile -ExecutionPolicy Bypass -File ' +
    (Quote-ProcessArgument $serverScript) + ' -Root ' + (Quote-ProcessArgument $Root) +
    ' -PortFile ' + (Quote-ProcessArgument $portFile) + ' -LatestTag ' + (Quote-ProcessArgument $LatestTag)

  $process = Start-Process -FilePath (Get-TestPowerShell) -ArgumentList $argumentLine `
    -WindowStyle Hidden -PassThru

  $deadline = (Get-Date).AddSeconds(15)
  while (-not (Test-Path -LiteralPath $portFile)) {
    if ((Get-Date) -gt $deadline) {
      try { Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue } catch { }
      throw 'the fixture server did not start in time.'
    }
    Start-Sleep -Milliseconds 100
  }

  $port = [int]([IO.File]::ReadAllText($portFile).Trim())
  return @{
    Process = $process
    Port = $port
    BaseUrl = "http://127.0.0.1:$port"
    PortFile = $portFile
  }
}

function Stop-FixtureServer {
  param($Server)
  if ($null -eq $Server) { return }
  try { Stop-Process -Id $Server.Process.Id -Force -ErrorAction SilentlyContinue } catch { }
  if (Test-Path -LiteralPath $Server.PortFile) {
    Remove-Item -LiteralPath $Server.PortFile -Force -ErrorAction SilentlyContinue
  }
}

function Exit-TestRun {
  param([string]$Name)
  Write-Host ''
  Write-Host "$Name : $script:TestCount test(s), $script:TestFailures failure(s), $script:TestSkips skipped"
  if ($script:TestFailures -gt 0) { exit 1 }
  exit 0
}
