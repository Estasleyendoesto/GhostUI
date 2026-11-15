@echo off
setlocal
set "ADDON_ROOT=%~dp0.."
more +7 "%~f0" | powershell -NoProfile -ExecutionPolicy Bypass -Command -
echo.
pause
goto :eof
& {
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$root = (Resolve-Path $env:ADDON_ROOT).Path
$tocPath = Join-Path $root "GhostUI.toc"
if (-not (Test-Path $tocPath)) {
    Write-Error "No se encontro GhostUI.toc en $root"
    exit 1
}

$tocLines = Get-Content $tocPath
$verLine = $tocLines | Where-Object { $_ -match '^\s*##\s*Version:\s*(.+)$' } | Select-Object -First 1
if (-not $verLine -or $verLine -notmatch '^\s*##\s*Version:\s*(.+)$') {
    Write-Error "No se encontro '## Version:' en GhostUI.toc"
    exit 1
}
$version = $matches[1].Trim()

$releasesDir = Join-Path $root ".releases"
if (-not (Test-Path $releasesDir)) { New-Item -ItemType Directory -Path $releasesDir | Out-Null }

$zipPath = Join-Path $releasesDir ("GhostUI-{0}.zip" -f $version)
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }

$zip = [System.IO.Compression.ZipFile]::Open($zipPath, [System.IO.Compression.ZipArchiveMode]::Create)
$files = Get-ChildItem -Path $root -Recurse -File | Where-Object {
    $rel = $_.FullName.Substring($root.Length + 1).Replace('\', '/')
    $rel -notmatch '^(\.git|\.assets|\.releases|libs\.retail|libs/AceLocale-3\.0)(/|$)' -and
    $rel -ne '.gitignore' -and
    $rel -notmatch '\.bat$'
}

foreach ($f in $files) {
    $rel = $f.FullName.Substring($root.Length + 1).Replace('\', '/')
    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
        $zip, $f.FullName, "GhostUI/$rel", [System.IO.Compression.CompressionLevel]::Optimal
    ) | Out-Null
}
$zip.Dispose()

$check = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
$missing = @()
foreach ($line in $tocLines) {
    $t = $line.Trim()
    if ($t -and -not $t.StartsWith('#')) {
        $entryPath = "GhostUI/" + $t.Replace('\', '/')
        if (-not ($check.Entries | Where-Object { $_.FullName -ieq $entryPath })) {
            $missing += $entryPath
        }
    }
}
$count = $check.Entries.Count
$check.Dispose()

$sizeKB = [Math]::Round((Get-Item $zipPath).Length / 1024, 1)
Write-Host ("Release creada: {0} ({1} KB, {2} archivos)" -f $zipPath, $sizeKB, $count) -ForegroundColor Green
if ($missing.Count -gt 0) {
    Write-Warning ("Faltan archivos del .toc en el zip: {0}" -f ($missing -join ', '))
} else {
    Write-Host "Verificacion OK: todos los archivos de GhostUI.toc incluidos bajo GhostUI/" -ForegroundColor Cyan
}
}

