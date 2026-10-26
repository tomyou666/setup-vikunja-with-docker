@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo Starting Vikunja...
docker compose up -d
if errorlevel 1 (
    echo.
    echo Failed to start. Make sure Docker Desktop is running.
    pause
    exit /b 1
)
echo.
echo Started: http://localhost:3456
echo On first start, database setup may take tens of seconds.
start "" "http://localhost:3456"
echo.
pause
