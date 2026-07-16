@echo off
REM STEP 1 of 2 -- power settings + WSL2 install. Self-elevates (expect a
REM UAC prompt), idempotent (safe to re-run), reports to Team Inbox, and
REM schedules Step 2 to auto-launch at your next login if a reboot is
REM needed. Just double-click -- no typing needed except an optional Y/N
REM at the very end if a reboot is required.

REM GIT-TRACKED COPY NOTE: this copy lives INSIDE myPKA\Scripts\, so Team
REM Inbox is a parent-level sibling (myPKA\Team Inbox), not a myPKA\...
REM child of this script's own folder like the Drive-root original.
REM STEP2BAT still resolves as a same-folder sibling of this .bat -- both
REM step1 and step2 are copied into Scripts\ together, so that reference
REM is unaffected by the relocation.

setlocal enabledelayedexpansion

set "SCRIPTDIR=%~dp0"
for %%I in ("%SCRIPTDIR%..") do set "MYPKAROOT=%%~fI"
set "OUTDIR=%MYPKAROOT%\Team Inbox"
set "PS1=%SCRIPTDIR%ha-docker-setup-01-power-wsl.ps1"
set "STEP2BAT=%SCRIPTDIR%ha-docker-setup-02-docker-ha.bat"
set "LOGFILE=%OUTDIR%\runonce-launch-log.txt"

REM Pre-flight launch marker -- see ha-docker-setup-02-docker-ha.bat for
REM why this exists (shared timeline log across the reboot/RunOnce chain).
if not exist "%OUTDIR%" mkdir "%OUTDIR%" >nul 2>&1
>>"%LOGFILE%" echo %date% %time%  [step1.bat] Launched. User=%USERNAME% ComputerName=%COMPUTERNAME%

if not exist "%OUTDIR%" (
    echo ERROR: Could not find "%OUTDIR%"
    echo Make sure this .bat file is sitting inside the myPKA vault
    echo (myPKA\Scripts\), then try again.
    pause
    exit /b 1
)
if not exist "%PS1%" (
    echo ERROR: Could not find "%PS1%" next to this .bat file.
    pause
    exit /b 1
)

for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd_HHmmss"`) do set "TS=%%i"
set "OUTFILE=%OUTDIR%\%TS%-ha-docker-setup-01-power-wsl.txt"

echo ============================================================
echo  STEP 1: Power settings + WSL2
echo  (A Windows UAC prompt will appear -- click Yes.)
echo ============================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -OutFile "%OUTFILE%" -Step2BatPath "%STEP2BAT%"

>>"%LOGFILE%" echo %date% %time%  [step1.bat] powershell.exe returned. errorlevel=%errorlevel%

echo.
echo ============================================================
echo  Report written to Team Inbox:
echo    %OUTFILE%
echo ============================================================
pause
