@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo Stopping Vikunja...
docker compose down
if errorlevel 1 (
    echo.
    echo Failed to stop.
    pause
    exit /b 1
)
echo.
echo Stopped. Data in files and db was left in place.
echo.
pause
