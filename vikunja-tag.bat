@echo off
chcp 65001 >nul
setlocal EnableExtensions
cd /d "%~dp0"

echo Current Vikunja image tag:
for /f "tokens=1,* delims==" %%A in ('findstr /b /c:"VIKUNJA_IMAGE_TAG=" .env') do echo %%B
echo.
set /p NEWTAG=Enter the new tag (e.g. v2.7.1 or latest): 
if "%NEWTAG%"=="" (
    echo.
    echo Tag is empty. Aborted.
    pause
    exit /b 1
)

:trim_leading
if "%NEWTAG:~0,1%"==" " (
    set "NEWTAG=%NEWTAG:~1%"
    goto trim_leading
)
:trim_trailing
if "%NEWTAG:~-1%"==" " (
    set "NEWTAG=%NEWTAG:~0,-1%"
    goto trim_trailing
)
if "%NEWTAG%"=="" (
    echo.
    echo Tag is empty. Aborted.
    pause
    exit /b 1
)

set "VIKUNJA_NEW_TAG=%NEWTAG%"
powershell -NoProfile -Command "if ($env:VIKUNJA_NEW_TAG -notmatch '^[A-Za-z0-9_][A-Za-z0-9._-]{0,127}$') { exit 1 }"
if errorlevel 1 (
    echo.
    echo Invalid characters. Use only letters, digits, periods, underscores, and hyphens.
    pause
    exit /b 1
)

echo.
echo Pulling vikunja/vikunja:%NEWTAG%...
docker pull vikunja/vikunja:%NEWTAG%
if errorlevel 1 (
    echo.
    echo Pull failed. Settings were not changed.
    pause
    exit /b 1
)

powershell -NoProfile -Command "$utf8 = New-Object System.Text.UTF8Encoding $false; $path = Join-Path (Get-Location) '.env'; $tag = $env:VIKUNJA_NEW_TAG; $lines = [System.IO.File]::ReadAllLines($path); $found = $false; $sb = New-Object System.Text.StringBuilder; foreach ($line in $lines) { if ($line -match '^VIKUNJA_IMAGE_TAG=') { $found = $true; [void]$sb.AppendLine(('VIKUNJA_IMAGE_TAG=' + $tag)) } else { [void]$sb.AppendLine($line) } }; if (-not $found) { [void]$sb.AppendLine(('VIKUNJA_IMAGE_TAG=' + $tag)) }; [System.IO.File]::WriteAllText($path, $sb.ToString(), $utf8)"
if errorlevel 1 (
    echo.
    echo Failed to update .env.
    pause
    exit /b 1
)

echo.
echo Switching containers to %NEWTAG%...
docker compose up -d
if errorlevel 1 (
    echo.
    echo Failed to start.
    pause
    exit /b 1
)

echo.
echo Tag changed to %NEWTAG%: http://localhost:3456
echo It may take tens of seconds to apply.
echo.
pause
endlocal
