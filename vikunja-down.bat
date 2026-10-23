@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo Vikunja を停止しています...
docker compose down
if errorlevel 1 (
    echo.
    echo 停止に失敗しました。
    pause
    exit /b 1
)
echo.
echo 停止しました。データ（files と db）はそのまま残しています。
echo.
pause
