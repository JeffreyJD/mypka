@echo off
REM Sweeps stranded provisioning-bundle report files out of Google Drive
REM root and copies them into myPKA's Team Inbox once myPKA is confirmed
REM synced on this machine. Companion to ai-stack-install.bat's graceful
REM fallback (it writes its report next to itself instead of erroring out
REM when Team Inbox isn't found yet) -- run this later to sweep any such
REM stranded reports into Team Inbox where Jeff actually looks for them.
REM Read-only scan + copy only -- never deletes or moves the originals.
REM Safe to re-run (skips files already present in Team Inbox). If Team
REM Inbox isn't found yet, this exits cleanly with a plain "nothing to
REM sync" message -- that is an expected outcome, not an error. Just
REM double-click -- no typing needed.

setlocal enabledelayedexpansion

set "SCRIPTDIR=%~dp0"
set "PS1=%SCRIPTDIR%sync-stranded-reports-to-team-inbox.ps1"

if not exist "%PS1%" (
    echo ERROR: Could not find "%PS1%"
    echo That file should be sitting right next to this .bat file.
    pause
    exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%"

echo.
pause
