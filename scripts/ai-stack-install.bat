@echo off
REM Generic AI-toolchain installer -- runs on ANY of Jeff's Windows
REM personal computers, no myPKA/Docker/Home-Assistant dependency baked
REM in. Installs/verifies: Claude Code CLI, Node.js + npm, Codex CLI,
REM Gemini CLI, Deno + yt-dlp (+ ffmpeg fallback) for the /watch plugin,
REM the /watch plugin's Groq API key file, and registers the /watch
REM plugin inside Claude Code itself. Idempotent -- safe to re-run.
REM Just double-click -- no typing needed except a single optional paste
REM of your Groq API key if it isn't already configured on this machine.
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
set "PS1=%SCRIPTDIR%ai-stack-install.ps1"

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
set "OUTFILE=%OUTDIR%\%TS%-ai-stack-install.txt"

echo ============================================================
echo  Installing/verifying the AI toolchain on this computer...
echo  (Claude Code, Node.js, Codex CLI, Gemini CLI, Deno, yt-dlp,
echo   ffmpeg, and the /watch plugin + its Groq key)
echo ============================================================
echo  You may see one or more Windows UAC prompts for individual
echo  package installs -- click Yes on those.
echo  You will be asked once whether to paste a Groq API key -- that
echo  is the only typing this script asks for.
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
