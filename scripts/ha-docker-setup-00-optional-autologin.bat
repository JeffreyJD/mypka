@echo off
REM OPTIONAL -- run this only if you want this laptop to log itself back in
REM after a reboot so Docker/HA restart unattended. NOT part of the 01/02
REM chain and never runs automatically. Self-elevates (UAC prompt). You
REM will need to type Y/N and, if you say yes, your username/password --
REM unavoidable since it's a secret, but everything else in this bundle
REM stays typing-free.

REM GIT-TRACKED COPY NOTE: this copy lives INSIDE myPKA\Scripts\, so Team
REM Inbox is a parent-level sibling (myPKA\Team Inbox), not a myPKA\...
REM child of this script's own folder like the Drive-root original.

setlocal enabledelayedexpansion

set "SCRIPTDIR=%~dp0"
for %%I in ("%SCRIPTDIR%..") do set "MYPKAROOT=%%~fI"
set "OUTDIR=%MYPKAROOT%\Team Inbox"
set "PS1=%SCRIPTDIR%ha-docker-setup-00-optional-autologin.ps1"

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
set "OUTFILE=%OUTDIR%\%TS%-ha-docker-setup-00-optional-autologin.txt"

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -OutFile "%OUTFILE%"

echo.
echo Report written to Team Inbox:
echo   %OUTFILE%
pause
