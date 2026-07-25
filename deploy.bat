@echo off
setlocal EnableDelayedExpansion

REM ═══════════════════════════════════════════
REM deploy.bat — Copies Survey Site files to root
REM              (version info is fetched live from GitHub API)
REM
REM SAFETY: every file is validated before it is copied. A file that
REM does not end with </html> is truncated/corrupt and is NOT deployed.
REM (A truncated dashboard.html once broke the live site: the inline
REM  <script> never closed, so the page hung on "Initializing database".)
REM ═══════════════════════════════════════════

cd /d "%~dp0"

set FILES=dashboard.html index.html account-detail.html
set FAILED=

echo.
echo   Validating source files...

for %%F in (%FILES%) do (
  if not exist "Survey Site\%%F" (
    echo     [SKIP] %%F  - not found in "Survey Site"
  ) else (
    powershell -NoProfile -Command "$t = Get-Content -Raw -LiteralPath 'Survey Site\%%F'; if ($t.TrimEnd().EndsWith('</html>')) { exit 0 } else { exit 1 }"
    if errorlevel 1 (
      echo     [FAIL] %%F  - does NOT end with ^</html^>  ^(truncated/corrupt^)
      set FAILED=1
    ) else (
      echo     [ OK ] %%F
    )
  )
)

if defined FAILED (
  echo.
  echo   ============================================================
  echo    DEPLOY ABORTED - nothing was copied.
  echo    A source file is truncated. Do not push it: the live site
  echo    will break. Restore the file first, e.g.:
  echo        git show HEAD:^<file^> ^> "Survey Site\^<file^>"
  echo   ============================================================
  echo.
  pause
  exit /b 1
)

for %%F in (%FILES%) do (
  if exist "Survey Site\%%F" copy /y "Survey Site\%%F" "%%F" >nul
)

echo.
echo   [OK] All files validated and copied to root
echo.
echo   Done! Now run:
echo     git add dashboard.html index.html account-detail.html
echo     git commit -m "your message"
echo     git push
echo.
pause
