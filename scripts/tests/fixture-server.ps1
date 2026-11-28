<#
.SYNOPSIS
  Minimal HTTP fixture server for the PowerShell installer tests.

.DESCRIPTION
  Serves release fixtures from a directory over a loopback TcpListener. It is
  deliberately dependency-free so the tests run on Windows PowerShell 5.1
  without administrator rights, Pester, Python, or Node.js.

  Routes:
    /releases/latest                             302 to the latest tag
    /releases/tag/<tag>                          200 (release page stub)
    /releases/download/<tag>/<asset>             file under assets/<tag>/
    /api/repos/<owner>/<repo>/releases/latest    200 JSON tag_name
    /api/repos/<owner>/<repo>/releases/tags/<tag> JSON under api/<tag>.json
    /flaky-zip/<status>/<times>/<path>           fail the first <times> .zip
                                                 requests under <path>, then
                                                 pass them through; other files
                                                 are always passed through
    /healthz                                     200 "ok"

  The chosen port is written to -PortFile as soon as the listener is ready.
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$Root,
  [Parameter(Mandatory = $true)][string]$PortFile,
  [string]$LatestTag = 'v0.152.2'
)

$ErrorActionPreference = 'Stop'

function Send-Response {
  param(
    [System.IO.Stream]$Stream,
    [int]$StatusCode,
    [string]$Reason,
    [string]$ContentType,
    [byte[]]$Body,
    [hashtable]$Headers,
    [bool]$HeadOnly
  )

  if ($null -eq $Body) { $Body = New-Object byte[] 0 }
  $builder = New-Object Text.StringBuilder
  [void]$builder.Append("HTTP/1.1 $StatusCode $Reason`r`n")
  [void]$builder.Append("Content-Type: $ContentType`r`n")
  [void]$builder.Append("Content-Length: $($Body.Length)`r`n")
  [void]$builder.Append("Connection: close`r`n")
  if ($Headers) {
    foreach ($key in $Headers.Keys) {
      [void]$builder.Append("$key`: $($Headers[$key])`r`n")
    }
  }
  [void]$builder.Append("`r`n")
  $headerBytes = [Text.Encoding]::ASCII.GetBytes($builder.ToString())
  $Stream.Write($headerBytes, 0, $headerBytes.Length)
  if (-not $HeadOnly -and $Body.Length -gt 0) {
    $Stream.Write($Body, 0, $Body.Length)
  }
  $Stream.Flush()
}

function Send-Text {
  param(
    [System.IO.Stream]$Stream,
    [int]$StatusCode,
    [string]$Reason,
    [string]$Text,
    [string]$ContentType = 'text/plain; charset=utf-8',
    [bool]$HeadOnly
  )
  $bytes = [Text.Encoding]::UTF8.GetBytes($Text)
  Send-Response -Stream $Stream -StatusCode $StatusCode -Reason $Reason -ContentType $ContentType -Body $bytes -HeadOnly $HeadOnly
}

function Send-File {
  param(
    [System.IO.Stream]$Stream,
    [string]$Path,
    [string]$ContentType,
    [bool]$HeadOnly
  )
  $bytes = [IO.File]::ReadAllBytes($Path)
  Send-Response -Stream $Stream -StatusCode 200 -Reason 'OK' -ContentType $ContentType -Body $bytes -HeadOnly $HeadOnly
}

function Get-ContentType {
  param([string]$Path)
  switch ([IO.Path]::GetExtension($Path).ToLowerInvariant()) {
    '.zip' { return 'application/zip' }
    '.gz' { return 'application/gzip' }
    '.tgz' { return 'application/gzip' }
    '.json' { return 'application/json' }
    '.txt' { return 'text/plain; charset=utf-8' }
  }
  return 'application/octet-stream'
}

if (-not (Test-Path -LiteralPath $Root)) {
  throw "fixture root does not exist: $Root"
}

$address = [Net.IPAddress]::Loopback
$listener = New-Object Net.Sockets.TcpListener -ArgumentList $address, 0
$listener.Start()
$port = ([Net.IPEndPoint]$listener.LocalEndpoint).Port
[IO.File]::WriteAllText($PortFile, $port.ToString(), [Text.UTF8Encoding]::new($false))

$flakyCounters = @{}
$statusReasons = @{
  429 = 'Too Many Requests'
  500 = 'Internal Server Error'
  502 = 'Bad Gateway'
  503 = 'Service Unavailable'
  504 = 'Gateway Timeout'
}

while ($true) {
  $client = $null
  try {
    $client = $listener.AcceptTcpClient()
    $stream = $client.GetStream()
    $reader = New-Object IO.StreamReader -ArgumentList $stream, ([Text.Encoding]::ASCII), $false, 1024, $true

    $requestLine = $reader.ReadLine()
    if ([string]::IsNullOrEmpty($requestLine)) { continue }
    $parts = $requestLine -split ' '
    if ($parts.Count -lt 3) { continue }
    $method = $parts[0].ToUpperInvariant()
    $target = $parts[1]
    $headOnly = ($method -eq 'HEAD')

    while ($true) {
      $line = $reader.ReadLine()
      if ($null -eq $line -or $line -eq '') { break }
    }

    $path = $target
    $queryIndex = $path.IndexOf('?')
    if ($queryIndex -ge 0) { $path = $path.Substring(0, $queryIndex) }
    $path = [Uri]::UnescapeDataString($path)

    if ($path -match '^/flaky-zip/(?<status>[1-5][0-9]{2})/(?<times>[0-9]+)/(?<rest>.+)$') {
      $status = [int]$Matches['status']
      $times = [int]$Matches['times']
      $rest = $Matches['rest']
      $isZip = $rest.EndsWith('.zip', [StringComparison]::OrdinalIgnoreCase)
      if ($isZip -and -not $headOnly) {
        $key = "$status/$times/$rest"
        if (-not $flakyCounters.ContainsKey($key)) { $flakyCounters[$key] = $times }
        if ($flakyCounters[$key] -gt 0) {
          $flakyCounters[$key] = $flakyCounters[$key] - 1
          $reason = 'Error'
          if ($statusReasons.ContainsKey($status)) { $reason = $statusReasons[$status] }
          Send-Text $stream $status $reason "injected $status" -HeadOnly $headOnly
          continue
        }
      }
      $path = '/' + $rest
    }

    if ($path -eq '/healthz') {
      Send-Text $stream 200 'OK' 'ok' -HeadOnly $headOnly
      continue
    }

    if ($path -eq '/releases/latest') {
      Send-Response -Stream $stream -StatusCode 302 -Reason 'Found' -ContentType 'text/plain' `
        -Body (New-Object byte[] 0) -Headers @{ Location = "/releases/tag/$LatestTag" } -HeadOnly $headOnly
      continue
    }

    if ($path -match '^/releases/tag/(?<tag>[^/]+)$') {
      $tag = $Matches['tag']
      $assetsDir = Join-Path (Join-Path $Root 'assets') $tag
      $apiFile = Join-Path (Join-Path $Root 'api') ($tag + '.json')
      if ((Test-Path -LiteralPath $assetsDir) -or (Test-Path -LiteralPath $apiFile)) {
        Send-Text $stream 200 'OK' "<html><title>$tag</title></html>" 'text/html; charset=utf-8' -HeadOnly $headOnly
      } else {
        Send-Text $stream 404 'Not Found' 'not found' -HeadOnly $headOnly
      }
      continue
    }

    if ($path -match '^/api/repos/[^/]+/[^/]+/releases/latest$') {
      $json = '{"tag_name":"' + $LatestTag + '"}'
      Send-Text $stream 200 'OK' $json 'application/json' -HeadOnly $headOnly
      continue
    }

    if ($path -match '^/api/repos/[^/]+/[^/]+/releases/tags/(?<tag>[^/]+)$') {
      $apiFile = Join-Path (Join-Path $Root 'api') ($Matches['tag'] + '.json')
      if (Test-Path -LiteralPath $apiFile) {
        Send-File $stream $apiFile 'application/json' $headOnly
      } else {
        Send-Text $stream 404 'Not Found' '{"message":"Not Found"}' 'application/json' -HeadOnly $headOnly
      }
      continue
    }

    if ($path -match '^/releases/download/(?<tag>[^/]+)/(?<asset>[^/]+)$') {
      $file = Join-Path (Join-Path (Join-Path $Root 'assets') $Matches['tag']) $Matches['asset']
      if (Test-Path -LiteralPath $file) {
        Send-File $stream $file (Get-ContentType $file) $headOnly
      } else {
        Send-Text $stream 404 'Not Found' 'not found' -HeadOnly $headOnly
      }
      continue
    }

    Send-Text $stream 404 'Not Found' 'not found' -HeadOnly $headOnly
  } catch {
    # A malformed or interrupted request must not stop the fixture server.
  } finally {
    if ($null -ne $client) { $client.Close() }
  }
}
