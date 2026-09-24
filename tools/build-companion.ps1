[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidatePattern('^[A-Za-z0-9_-]+_companion_radio_(usb|ble|wifi|serial)(_[A-Za-z0-9_-]+)?$')]
    [string]$Target = 'Xiao_S3_WIO_companion_radio_usb'
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$platformIo = Get-Command pio -ErrorAction SilentlyContinue
$platformIoArguments = @()
if (-not $platformIo) {
    $platformIo = Get-Command platformio -ErrorAction SilentlyContinue
}
if (-not $platformIo) {
    $platformIo = Get-Command py -ErrorAction SilentlyContinue
    $platformIoArguments = @('-m', 'platformio')
}

if (-not $platformIo) {
    throw 'PlatformIO wurde nicht gefunden. Installiere es mit "py -m pip install --user platformio" und starte dieses Skript erneut.'
}

Push-Location $projectRoot
try {
    $configFiles = @((Join-Path $projectRoot 'platformio.ini')) +
        @(Get-ChildItem -Path (Join-Path $projectRoot 'variants\*\platformio.ini') -File)
    if (-not (Select-String -Path $configFiles -SimpleMatch "[env:$Target]" -Quiet)) {
        throw "Unbekanntes PlatformIO-Ziel: $Target"
    }

    & $platformIo.Source @platformIoArguments run -e $Target -t mergebin
    if ($LASTEXITCODE -ne 0) {
        throw "PlatformIO-Build fehlgeschlagen (Exitcode $LASTEXITCODE)."
    }

    $buildDirectory = Join-Path $projectRoot ".pio\build\$Target"
    $outputDirectory = Join-Path $projectRoot 'out'
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null

    $artifacts = Get-ChildItem -LiteralPath $buildDirectory -Filter 'firmware*.bin' -File
    if (-not $artifacts) {
        throw "Keine Firmware-Datei in $buildDirectory gefunden."
    }

    foreach ($artifact in $artifacts) {
        $destinationName = "$Target-$($artifact.Name)"
        Copy-Item -LiteralPath $artifact.FullName -Destination (Join-Path $outputDirectory $destinationName) -Force
        Write-Host "Erstellt: out\$destinationName"
    }
}
finally {
    Pop-Location
}
