# HealthMate Flutter runner — is script se flutter PATH ki zaroorat nahi
$FlutterBin = Join-Path $PSScriptRoot ".flutter-sdk\bin"
if (-not (Test-Path (Join-Path $FlutterBin "flutter.bat"))) {
    Write-Error "Flutter SDK not found at $FlutterBin"
    Write-Host "Pehle clone karo: git clone https://github.com/flutter/flutter.git -b stable --depth 1 .flutter-sdk"
    exit 1
}

$env:Path = "$FlutterBin;" + $env:Path
Set-Location $PSScriptRoot

$device = if ($args.Count -gt 0) { $args[0] } else { "chrome" }
Write-Host "Running: flutter run -d $device --no-version-check"
flutter run -d $device --no-version-check
