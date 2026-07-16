@echo off
REM Builds/refreshes a standalone LOCAL working folder (Local Bastion) so a
REM live Claude Code session running directly on THIS device can diagnose
REM and fix things interactively -- without ever opening the actual
REM Google-Drive-synced myPKA folder as its own workspace. Two live sessions
REM both treating the same Drive-synced folder as home base risk racing on
REM shared files (Drive sync has no real locking); this script gives Local
REM Bastion a COPY of just the context it needs, never the live vault, so
REM it physically cannot overwrite a shared file by accident. Re-pulls
REM fresh every time -- safe to re-run whenever you want the latest
REM contract/Guideline/Host-doc text.
REM
REM Works on ANY of Jeff's personal Windows devices -- not hardcoded to one
REM machine. Destination folder name is derived from this machine's own
REM identity at run time.
REM
REM Writes a small timestamped report to myPKA's Team Inbox describing what
REM was bundled and where (same drive-letter-independent lookup as the
REM other scripts in this folder). If myPKA is NOT synced on this machine,
REM the report is written next to this script instead and this window
REM tells you exactly where -- and the bundle itself cannot be built until
REM myPKA IS found synced, since it copies FROM that source.
REM Just double-click -- no typing needed.
REM
REM GIT-TRACKED COPY NOTE: this copy lives INSIDE myPKA\Scripts\, so Team
REM Inbox is a parent-level sibling (myPKA\Team Inbox), not a myPKA\...
REM child of this script's own folder like the Drive-root original. The
REM companion .ps1 has its own equivalent fix for locating the myPKA root
REM it bundles Bastion's contract/Guidelines/Host doc from.

setlocal enabledelayedexpansion

set "SCRIPTDIR=%~dp0"
for %%I in ("%SCRIPTDIR%..") do set "MYPKAROOT=%%~fI"
set "TEAMINBOX=%MYPKAROOT%\Team Inbox"
set "PS1=%SCRIPTDIR%local-bastion-bootstrap.ps1"

if not exist "%PS1%" (
    echo ERROR: Could not find "%PS1%"
    echo That file should be sitting right next to this .bat file.
    pause
    exit /b 1
)

set "OUTDIR=%TEAMINBOX%"
set "FALLBACK=0"
if not exist "%TEAMINBOX%" (
    set "OUTDIR=%SCRIPTDIR%"
    set "FALLBACK=1"
)

for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd_HHmmss"`) do set "TS=%%i"
set "OUTFILE=%OUTDIR%\%TS%-local-bastion-bootstrap.txt"

echo ============================================================
echo  Building/refreshing the Local Bastion working folder for
echo  this device...
echo ============================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -OutFile "%OUTFILE%"

echo.
if "%FALLBACK%"=="1" (
    echo ============================================================
    echo  NOTE: myPKA Team Inbox was not found next to this script, so
    echo  the report was written next to this script instead:
    echo    %OUTFILE%
    echo  If Google Drive/myPKA was NOT found synced at all, the bundle
    echo  itself could not be built either -- re-run this script once
    echo  myPKA is confirmed synced on this machine.
    echo ============================================================
) else (
    echo ============================================================
    echo  DONE. Report written to Team Inbox:
    echo    %OUTFILE%
    echo  It will sync back to Google Drive automatically.
    echo  The bundle itself is at: %%USERPROFILE%%\dev\^<device-slug^>-local-bastion\
    echo  -- see the report above for the exact path used this run.
    echo ============================================================
)
echo.
pause
