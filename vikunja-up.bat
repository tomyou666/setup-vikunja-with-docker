@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo Vikunja を起動しています...
docker compose up -d
if errorlevel 1 (
    echo.
    echo 起動に失敗しました。Docker Desktop が起動しているか確認してください。
    pause
    exit /b 1
)
echo.
echo 起動しました: http://localhost:3456
echo 初回はデータベースの準備に数十秒かかることがあります。
start "" "http://localhost:3456"
echo.
pause
