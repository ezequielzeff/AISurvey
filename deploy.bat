@echo off

REM ═══════════════════════════════════════════
REM deploy.bat — Copies Survey Site files to root
REM              (version info is fetched live from GitHub API)
REM ═══════════════════════════════════════════

cd /d "%~dp0"

copy /y "Survey Site\dashboard.html" "dashboard.html" >nul
copy /y "Survey Site\index.html" "index.html" >nul 2>nul

echo.
echo   [OK] Files copied to root
echo.
echo   Done! Now run:
echo     git add dashboard.html index.html
echo     git commit -m "your message"
echo     git push
echo.
pause
