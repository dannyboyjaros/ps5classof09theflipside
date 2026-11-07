param(
    [string]$Url = "http://127.0.0.1:19113/mcp",
    [string]$Out = "run-ps5.jpg",
    [int]$MaxWidth = 1920
)

$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$dir = Split-Path -Parent $here
$tmp = Join-Path $env:TEMP "c09fs-mcp"
New-Item -ItemType Directory $tmp -Force | Out-Null

$initBody = '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"opencode","version":"1.0"}}}'
$initFile = Join-Path $tmp "init.json"
$headersFile = Join-Path $tmp "headers.txt"
$initOut = Join-Path $tmp "init.txt"
[IO.File]::WriteAllText($initFile, $initBody)

& curl.exe -s -D $headersFile -o $initOut -X POST $Url `
  -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" `
  --data-binary "@$initFile" | Out-Null

$sid = (Select-String -Path $headersFile -Pattern 'Mcp-Session-Id:\s*(\S+)').Matches[0].Groups[1].Value.Trim()
if (-not $sid) { throw "MCP did not return a session id." }

$frameBody = '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"rp_frame","arguments":{"format":"jpeg","max_width":' + $MaxWidth + '}}}'
$frameFile = Join-Path $tmp "frame.json"
$frameOut = Join-Path $tmp "frame.txt"
[IO.File]::WriteAllText($frameFile, $frameBody)

& curl.exe -s -o $frameOut -X POST $Url `
  -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" `
  -H "Mcp-Session-Id: $sid" --data-binary "@$frameFile" | Out-Null

$text = Get-Content $frameOut -Raw
if ($text -match '(?s)data:\s*(\{.*\})') { $text = $Matches[1] }
$json = $text | ConvertFrom-Json
$img = $json.result.content | Where-Object { $_.type -eq "image" } | Select-Object -First 1
if (-not $img) {
    $text.Substring(0, [Math]::Min(800, $text.Length))
    throw "rp_frame returned no image. Start a stream with rp_start first."
}

$outPath = if ([IO.Path]::IsPathRooted($Out)) { $Out } else { Join-Path $dir $Out }
[IO.File]::WriteAllBytes($outPath, [Convert]::FromBase64String($img.data))
Write-Output "wrote $outPath ($((Get-Item $outPath).Length) bytes)"
