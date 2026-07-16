@echo off
REM Diagnoses (and auto-fixes) the "claude is not recognized" PATH issue on
REM this laptop -- works on any of Jeff's Windows personal computers. Drops
REM a report into myPKA's Team Inbox so Hawkeye/Bastion can see what
REM happened. Just double-click this file -- no typing needed. Run it from
REM wherever Google Drive synced it (it finds Team Inbox relative to its
REM own location, works regardless of drive letter or Windows username on
REM this machine).
REM
REM GIT-TRACKED COPY NOTE: this copy lives INSIDE myPKA\Scripts\, so Team
REM Inbox is a parent-level sibling (myPKA\Team Inbox), not a myPKA\...
REM child of this script's own folder like the Drive-root original.

setlocal enabledelayedexpansion

set "SCRIPTDIR=%~dp0"
for %%I in ("%SCRIPTDIR%..") do set "MYPKAROOT=%%~fI"
set "OUTDIR=%MYPKAROOT%\Team Inbox"
set "PS1=%SCRIPTDIR%ai-stack-path-fix.ps1"

if not exist "%OUTDIR%" (
    echo ERROR: Could not find "%OUTDIR%"
    echo Make sure this .bat file is sitting inside the myPKA vault
    echo (myPKA\Scripts\), then try again.
    pause
    exit /b 1
)

if not exist "%PS1%" (
    echo ERROR: Could not find "%PS1%"
    echo That file should be sitting right next to this .bat file.
    pause
    exit /b 1
)

for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd_HHmmss"`) do set "TS=%%i"
set "OUTFILE=%OUTDIR%\%TS%-ai-stack-claude-path-diagnosis.txt"

echo ============================================================
echo  Diagnosing Claude Code PATH issue...
echo ============================================================
echo (This may fix it automatically. Full report is being written
echo  to Team Inbox as it runs.)
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -OutFile "%OUTFILE%"

echo.
echo ============================================================
echo  DONE. Report written to Team Inbox:
echo    %OUTFILE%
echo  It will sync back to Google Drive automatically. Let Hawkeye
echo  know it's there.
echo ============================================================
echo.
echo  If the report says PATH was fixed: close ALL terminal windows,
echo  press Win+R, type cmd, Enter, then just type: claude
echo.
pause
