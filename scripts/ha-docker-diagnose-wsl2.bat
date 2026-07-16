@echo off
REM Standalone READ-ONLY diagnostic, companion to the ha-docker-setup
REM bundle. Investigates why ha-docker-setup-02-docker-ha.ps1's WSL2
REM pre-check keeps reporting Microsoft-Windows-Subsystem-Linux /
REM VirtualMachinePlatform as not-enabled, even though
REM ha-docker-setup-01-power-wsl.ps1's DISM-backed install reported success
REM and required a reboot, and a genuine full restart was performed
REM afterward. Gathers raw DISM feature state, pending-reboot registry
REM indicators, Windows Update/hotfix history, the DISM servicing log
REM tail, wsl --status/--version, and system uptime into one report.
REM
REM This script makes NO changes to the system -- it does not install,
REM enable, or modify anything. It self-elevates (expect a UAC prompt)
REM because dism /online and some of the registry/log reads need admin to
REM read reliably, but nothing is changed once elevated.
REM Just double-click.
REM
REM Writes a timestamped report to myPKA's Team Inbox if this script is
REM sitting next to a synced myPKA folder (same drive-letter-independent
REM lookup as the other scripts in this folder). If myPKA is NOT synced
REM on this machine, the report is written next to this script instead
REM and this window tells you exactly where.
REM
REM GIT-TRACKED COPY NOTE: this copy lives INSIDE myPKA\Scripts\, so Team
REM Inbox is a parent-level sibling (myPKA\Team Inbox), not a myPKA\...
REM child of this script's own folder like the Drive-root original.

setlocal enabledelayedexpansion

set "SCRIPTDIR=%~dp0"
for %%I in ("%SCRIPTDIR%..") do set "MYPKAROOT=%%~fI"
set "TEAMINBOX=%MYPKAROOT%\Team Inbox"
set "PS1=%SCRIPTDIR%ha-docker-diagnose-wsl2.ps1"

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
set "OUTFILE=%OUTDIR%\%TS%-ha-docker-diagnose-wsl2.txt"

echo ============================================================
echo  WSL2 / VirtualMachinePlatform diagnostic (READ-ONLY)
echo  (A Windows UAC prompt will appear -- click Yes. Nothing is
echo   installed or changed -- this only reads and reports.)
echo ============================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -OutFile "%OUTFILE%"

echo.
if "%FALLBACK%"=="1" (
    echo ============================================================
    echo  DONE. NOTE: myPKA Team Inbox was not found next to this
    echo  script, so the report was written next to this script instead:
    echo    %OUTFILE%
    echo  If this machine later gets myPKA synced, you can move this
    echo  report into myPKA\Team Inbox yourself.
    echo ============================================================
) else (
    echo ============================================================
    echo  DONE. Report written to Team Inbox:
    echo    %OUTFILE%
    echo  It will sync back to Google Drive automatically.
    echo ============================================================
)
echo.
pause
