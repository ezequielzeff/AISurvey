@echo off
setlocal enabledelayedexpansion

REM ═══════════════════════════════════════════
REM deploy.bat — Injects git version into dashboard.html
REM              and copies Survey Site files to root
REM ═══════════════════════════════════════════

cd /d "%~dp0"

REM Get git info
for /f %%i in ('git rev-parse --short HEAD') do set HASH=%%i
for /f "tokens=*" %%i in ('git log -1 --format^=%%aI') do set GDATE=%%i
for /f "tokens=*" %%i in ('git log -1 --format^=%%s') do set MSG=%%i

echo.
echo   Build Info:
echo     Hash:    %HASH%
echo     Date:    %GDATE%
echo     Message: %MSG%
echo.

REM Inject BUILD_VERSION into Survey Site/dashboard.html using PowerShell
REM Sanitize message: escape single quotes for PowerShell string
set "SAFE_MSG=%MSG:'=''%"

powershell -Command ^
  "$f = Get-Content 'Survey Site\dashboard.html' -Raw -Encoding UTF8;" ^
  "$pattern = 'const BUILD_VERSION = \{[^}]+\};';" ^
  "$replacement = 'const BUILD_VERSION = { hash: ''%HASH%'', date: ''%GDATE%'', message: ''%SAFE_MSG:~0,80%'' };';" ^
  "$f = $f -replace $pattern, $replacement;" ^
  "[System.IO.File]::WriteAllText('Survey Site\dashboard.html', $f)"

echo   [OK] Version injected into Survey Site\dashboard.html

REM Copy files to root
copy /y "Survey Site\dashboard.html" "dashboard.html" >nul
copy /y "Survey Site\index.html" "index.html" >nul 2>nul

echo   [OK] Files copied to root
echo.
echo   Done! Now run:
echo     git add dashboard.html index.html
echo     git commit --amend --no-edit
echo     git push
echo.
pause
