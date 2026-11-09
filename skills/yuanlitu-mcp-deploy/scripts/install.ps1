#requires -Version 5.1
[CmdletBinding()]
param(
    [ValidatePattern('^v?\d+\.\d+\.\d+$')]
    [string]$Version,
    [string]$InstallRoot = (Join-Path $env:LOCALAPPDATA 'YuanlituMCP'),
    [string]$CodexConfig,
    [switch]$ArtifactsOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$utf8 = [Text.UTF8Encoding]::new($false, $true)
$begin = '# BEGIN Yuanlitu MCP installer'
$end = '# END Yuanlitu MCP installer'
$releaseBase = 'https://github.com/lyq11/yuanlitu-mcp-service-public/releases'
$serverName = 'yuanlitu-mcp.exe'

function Test-AssetHash([string]$Path, [string]$Expected) {
    if (!(Test-Path -LiteralPath $Path -PathType Leaf)) { return $false }
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash -eq $Expected
}

function Get-CodexPlan([string]$Path, [string]$Server) {
    $exists = [IO.File]::Exists($Path)
    $original = if ($exists) { [IO.File]::ReadAllText($Path, $utf8) } else { '' }
    $newline = if ($original.Contains([string][char]13 + [char]10)) {
        [string][char]13 + [char]10
    } else {
        [string][char]10
    }
    $beginPattern = '(?m)^' + [regex]::Escape($begin) + '\r?$'
    $endPattern = '(?m)^' + [regex]::Escape($end) + '\r?$'
    $starts = [regex]::Matches($original, $beginPattern)
    $ends = [regex]::Matches($original, $endPattern)
    $command = 'command = ' + (ConvertTo-Json -InputObject $Server.Replace('\', '/') -Compress)
    $alias = '(?i)\byuanlitu_easyeda\b|\byuanlitu-mcp\.exe\b'
    # A marker in a multiline literal is not a configuration table.
    if ($original.Contains('"""') -or $original.Contains("'''")) {
        throw "Cannot safely edit a Codex config with multiline strings. Use -ArtifactsOnly. Config: $Path"
    }
    if ($starts.Count -eq 0 -and $ends.Count -eq 0) {
        $inline = '(?im)^[ \t]*(?:mcp_servers|"mcp_servers"|''mcp_servers'')[ \t]*='
        if ($original -match $alias -or $original -match $inline) {
            throw "A custom MCP entry or inline MCP table already exists. Use -ArtifactsOnly. Config: $Path"
        }
        $block = @($begin, '[mcp_servers.yuanlitu_easyeda]', $command, 'args = []',
            'startup_timeout_sec = 20', 'tool_timeout_sec = 120', $end, '') -join $newline
        $prefix = if (!$original.Length) { '' } elseif ($original.EndsWith($newline)) {
            $original + $newline
        } else { $original + $newline + $newline }
        return @{ Exists = $exists; Before = $original; After = $prefix + $block }
    }

    if ($starts.Count -ne 1 -or $ends.Count -ne 1 -or $starts[0].Index -ge $ends[0].Index) {
        throw "The managed MCP markers are incomplete or duplicated. Config: $Path"
    }
    $start = $starts[0].Index
    $finish = $ends[0].Index
    $before = $original.Substring(0, $start)
    $body = $original.Substring($start, $finish - $start)
    $after = $original.Substring($finish)
    $target = '[mcp_servers.yuanlitu_easyeda]'
    $expectedHeader = $begin + $newline + $target + $newline
    $commandLine = [regex]'(?m)^[ \t]*command[ \t]*=[ \t]*"[^"\r\n]*"[ \t]*(?=\r?$)'
    if (($before + $after) -match $alias -or !$body.StartsWith($expectedHeader) -or
        [regex]::Matches($body, '(?m)^[ \t]*\[').Count -ne 1 -or $commandLine.Matches($body).Count -ne 1) {
        throw "The managed MCP table was customized or duplicated. Use -ArtifactsOnly. Config: $Path"
    }
    $line = $commandLine.Match($body)
    $updated = $body.Substring(0, $line.Index) + $command + $body.Substring($line.Index + $line.Length)
    return @{ Exists = $exists; Before = $original; After = $before + $updated + $after }
}

function Save-CodexPlan([string]$Path, [hashtable]$Plan) {
    $parent = Split-Path -Parent $Path
    [IO.Directory]::CreateDirectory($parent) | Out-Null
    $suffix = [guid]::NewGuid().ToString('N')
    $temporary = Join-Path $parent ".yuanlitu-config-$suffix.tmp"
    try {
        [IO.File]::WriteAllText($temporary, $Plan.After, $utf8)
        if ($Plan.Exists) {
            if ([IO.File]::ReadAllText($Path, $utf8) -cne $Plan.Before) {
                throw 'Codex configuration changed during deployment. Run the installer again.'
            }
            $backup = "$Path.yuanlitu-$suffix.bak"
            [IO.File]::Replace($temporary, $Path, $backup)
            return $backup
        }
        [IO.File]::Move($temporary, $Path)
    } finally {
        if ([IO.File]::Exists($temporary)) { [IO.File]::Delete($temporary) }
    }
}

if ([Environment]::OSVersion.Platform -ne 'Win32NT' -or
    [Runtime.InteropServices.RuntimeInformation]::OSArchitecture -ne 'X64') {
    throw 'This installer requires Windows x64.'
}
if ($PSVersionTable.PSVersion.Major -lt 6) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
}
if (!$ArtifactsOnly -and !$CodexConfig) {
    $codexDirectory = if ($env:CODEX_HOME) { $env:CODEX_HOME } else {
        Join-Path ([Environment]::GetFolderPath('UserProfile')) '.codex'
    }
    $CodexConfig = Join-Path $codexDirectory 'config.toml'
}

$checksumUrl = if ($Version) {
    "$releaseBase/download/v$($Version.TrimStart('v'))/SHA256SUMS.txt"
} else {
    "$releaseBase/latest/download/SHA256SUMS.txt"
}
$rawChecksums = (Invoke-WebRequest -Uri $checksumUrl -UseBasicParsing -TimeoutSec 60).Content
$checksums = if ($rawChecksums -is [byte[]]) { $utf8.GetString($rawChecksums) } else { [string]$rawChecksums }
$hashes = @{}
foreach ($entry in [regex]::Matches($checksums, '(?m)^([a-fA-F0-9]{64})[ \t]+\*?([a-zA-Z0-9._-]+)\r?$')) {
    $name = $entry.Groups[2].Value
    if ($hashes.ContainsKey($name)) { throw "Duplicate checksum entry: $name" }
    $hashes[$name] = $entry.Groups[1].Value
}
$bundles = @($hashes.Keys | Where-Object { $_ -cmatch '^yuanlitu-mcp-v\d+\.\d+\.\d+-win-x64\.zip$' })
if ($bundles.Count -ne 1) { throw 'Expected one Windows x64 bundle in the release checksums.' }
$bundleName = $bundles[0]
$tag = $bundleName -replace '^yuanlitu-mcp-(v[\d.]+)-win-x64\.zip$', '$1'
if ($Version -and $tag -cne ('v' + $Version.TrimStart('v'))) { throw 'The checksum manifest belongs to another release.' }
$extensionName = "yuanlitu-mcp-service_$tag.eext"
foreach ($name in @($serverName, $extensionName)) {
    if (!$hashes.ContainsKey($name)) { throw "Release checksum missing for $name" }
}

$releases = Join-Path ([IO.Path]::GetFullPath($InstallRoot)) 'releases'
$destination = Join-Path $releases $tag
$server = Join-Path $destination $serverName
$extension = Join-Path $destination $extensionName
$plan = $null
if (!$ArtifactsOnly) {
    $CodexConfig = [IO.Path]::GetFullPath($CodexConfig)
    $plan = Get-CodexPlan -Path $CodexConfig -Server $server
}

if (![IO.Directory]::Exists($destination)) {
    $staging = Join-Path $releases ('.install-' + [guid]::NewGuid().ToString('N'))
    [IO.Directory]::CreateDirectory($staging) | Out-Null
    $zipPath = Join-Path $staging $bundleName
    try {
        Invoke-WebRequest -Uri "$releaseBase/download/$tag/$bundleName" -UseBasicParsing -TimeoutSec 180 -OutFile $zipPath
        if (!(Test-AssetHash -Path $zipPath -Expected $hashes[$bundleName])) { throw "Checksum mismatch: $bundleName" }
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $zip = [IO.Compression.ZipFile]::OpenRead($zipPath)
        try {
            foreach ($name in @($serverName, $extensionName)) {
                $zipEntries = @($zip.Entries | Where-Object { $_.FullName -ceq $name })
                if ($zipEntries.Count -ne 1) { throw "Invalid bundle entry: $name" }
                $file = Join-Path $staging $name
                [IO.Compression.ZipFileExtensions]::ExtractToFile($zipEntries[0], $file)
                if (!(Test-AssetHash -Path $file -Expected $hashes[$name])) { throw "Checksum mismatch: $name" }
            }
        } finally { $zip.Dispose() }
        [IO.File]::Delete($zipPath)
        try {
            [IO.Directory]::Move($staging, $destination)
        } catch [IO.IOException] {
            if (![IO.Directory]::Exists($destination)) { throw }
        }
    } finally {
        if ([IO.Directory]::Exists($staging)) {
            foreach ($name in @($bundleName, $serverName, $extensionName)) {
                [IO.File]::Delete((Join-Path $staging $name))
            }
            [IO.Directory]::Delete($staging)
        }
    }
}
foreach ($file in @($server, $extension)) {
    if (!(Test-AssetHash -Path $file -Expected $hashes[(Split-Path -Leaf $file)])) {
        throw "Installed file failed checksum verification: $file. Use a fresh -InstallRoot to reinstall."
    }
}
$reportedConfig = $null
$backup = $null
$changed = $false
if ($plan) {
    $reportedConfig = $CodexConfig
    $changed = $plan.Before -cne $plan.After
    if ($changed) {
        $savedBackup = Save-CodexPlan -Path $CodexConfig -Plan $plan
        if ($savedBackup) { $backup = $savedBackup }
    }
}
$result = [ordered]@{
    release = $tag
    server = $server
    extension = $extension
    codexConfig = $reportedConfig
    configChanged = $changed
    configBackup = $backup
}
# ASCII JSON survives Windows PowerShell output redirection on any code page.
[regex]::Replace(($result | ConvertTo-Json), '[^\u0000-\u007f]', {
    param($character)
    '\u' + ([int][char]$character.Value).ToString('x4')
})
