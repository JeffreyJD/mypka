@echo off
REM STEP 2 of 2 -- Docker Desktop + Home Assistant. Self-elevates (expect a
REM UAC prompt), idempotent (safe to re-run/resume), reports to Team
REM Inbox. Runs automatically after Step 1's reboot if that step scheduled
REM it, or you can double-click it yourself any time WSL2 is already set
REM up. No typing needed.

REM GIT-TRACKED COPY NOTE: this copy lives INSIDE myPKA\Scripts\, so Team
REM Inbox is a parent-level sibling (myPKA\Team Inbox), not a myPKA\...
REM child of this script's own folder like the Drive-root original.

setlocal enabledelayedexpansion

set "SCRIPTDIR=%~dp0"
for %%I in ("%SCRIPTDIR%..") do set "MYPKAROOT=%%~fI"
set "OUTDIR=%MYPKAROOT%\Team Inbox"
set "PS1=%SCRIPTDIR%ha-docker-setup-02-docker-ha.ps1"
set "LOGFILE=%OUTDIR%\runonce-launch-log.txt"

REM --- Pre-flight launch marker ---------------------------------------
REM Written BEFORE anything else (including the OUTDIR/PS1 existence
REM checks) so there is on-disk evidence this .bat actually ran -- e.g.
REM when RunOnce fires it after an autologin reboot and nobody is
REM watching the screen closely enough to see a window appear/disappear.
if not exist "%OUTDIR%" mkdir "%OUTDIR%" >nul 2>&1
>>"%LOGFILE%" echo %date% %time%  [step2.bat] Launched. User=%USERNAME% ComputerName=%COMPUTERNAME% Args=%*

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
set "OUTFILE=%OUTDIR%\%TS%-ha-docker-setup-02-docker-ha.txt"

echo ============================================================
echo  STEP 2: Docker Desktop + Home Assistant
echo  (A Windows UAC prompt will appear -- click Yes. This step
echo   can take several minutes, mostly the Docker Desktop download.)
echo ============================================================
echo.

REM When this .bat is fired by RunOnce right after an autologin, give the
REM desktop/shell a few seconds to finish initializing before requesting
REM UAC elevation -- reduces the chance the consent prompt renders behind
REM other startup windows or onto a desktop that isn't fully attached yet.
echo Waiting a few seconds for the desktop to finish initializing after login...
timeout /t 5 /nobreak >nul

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -OutFile "%OUTFILE%"

>>"%LOGFILE%" echo %date% %time%  [step2.bat] powershell.exe returned. errorlevel=%errorlevel%

echo.
echo ============================================================
echo  Report written to Team Inbox:
echo    %OUTFILE%
echo  If it says HA is reachable, open http://localhost:8123 in a
echo  browser to finish onboarding (create the admin account).
echo ============================================================
pause
