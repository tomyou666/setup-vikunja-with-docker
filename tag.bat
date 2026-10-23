@echo off
chcp 65001 >nul
setlocal EnableExtensions
cd /d "%~dp0"

echo 現在の Vikunja イメージタグ:
for /f "tokens=1,* delims==" %%A in ('findstr /b /c:"VIKUNJA_IMAGE_TAG=" .env') do echo %%B
echo.
set /p NEWTAG=変更するタグを入力してください (例: v2.7.1 または latest): 
if "%NEWTAG%"=="" (
    echo.
    echo タグが空のため中止しました。
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
    echo タグが空のため中止しました。
    pause
    exit /b 1
)

set "VIKUNJA_NEW_TAG=%NEWTAG%"
powershell -NoProfile -Command "if ($env:VIKUNJA_NEW_TAG -notmatch '^[A-Za-z0-9_][A-Za-z0-9._-]{0,127}$') { exit 1 }"
if errorlevel 1 (
    echo.
    echo 使えない文字が含まれています。英数字、ピリオド、アンダースコア、ハイフンのみ使えます。
    pause
    exit /b 1
)

echo.
echo vikunja/vikunja:%NEWTAG% を取得しています...
docker pull vikunja/vikunja:%NEWTAG%
if errorlevel 1 (
    echo.
    echo 取得に失敗しました。設定は変更していません。
    pause
    exit /b 1
)

powershell -NoProfile -Command "$utf8 = New-Object System.Text.UTF8Encoding $false; $path = Join-Path (Get-Location) '.env'; $tag = $env:VIKUNJA_NEW_TAG; $lines = [System.IO.File]::ReadAllLines($path); $found = $false; $sb = New-Object System.Text.StringBuilder; foreach ($line in $lines) { if ($line -match '^VIKUNJA_IMAGE_TAG=') { $found = $true; [void]$sb.AppendLine(('VIKUNJA_IMAGE_TAG=' + $tag)) } else { [void]$sb.AppendLine($line) } }; if (-not $found) { [void]$sb.AppendLine(('VIKUNJA_IMAGE_TAG=' + $tag)) }; [System.IO.File]::WriteAllText($path, $sb.ToString(), $utf8)"
if errorlevel 1 (
    echo.
    echo .env の更新に失敗しました。
    pause
    exit /b 1
)

echo.
echo コンテナを %NEWTAG% に切り替えています...
docker compose up -d
if errorlevel 1 (
    echo.
    echo 起動に失敗しました。
    pause
    exit /b 1
)

echo.
echo タグを %NEWTAG% に変更しました: http://localhost:3456
echo 反映まで数十秒かかることがあります。
echo.
pause
endlocal
