# Generic AI-toolchain installer for ANY of Jeff's Windows personal
# computers (jeff-laptop, bridget-laptop, or a future machine). No myPKA,
# Docker, or Home Assistant dependency -- this only touches the AI CLI
# tooling layer. Called by ai-stack-install.bat, which passes -OutFile
# pointing at the timestamped report path (Team Inbox if myPKA is synced
# next to this script, otherwise next to the script itself).
#
# Idempotent: safe to re-run. Verifies each step by actually checking the
# tool resolves afterward (not just trusting an installer's exit code).
# Does NOT self-elevate as a whole -- winget/msi installers prompt their
# own UAC if a specific package genuinely needs it; npm-global and
# native-installer steps do not need admin.
#
# Covers: Claude Code CLI, Node.js + npm (prereq for the two npm-based
# CLIs below), Codex CLI, Gemini CLI, Deno + yt-dlp (+ ffmpeg fallback)
# for the /watch plugin, the /watch plugin's Groq API key file, and
# registering the /watch plugin inside Claude Code itself.
param(
    [Parameter(Mandatory = $true)]
    [string]$OutFile
)

$ErrorActionPreference = 'Continue'
$report = @()
function Add-Report { param([string]$Line) $script:report += $Line }

# Windows PowerShell 5.1's default Tee-Object/Out-File encoding is UTF-16LE
# (with BOM), which opens as garbled spaced-out text in plenty of tools.
# Write explicit UTF-8 with no BOM instead, while still echoing to the
# console like Tee-Object did.
function Write-ReportFile {
    param([string[]]$Report, [string]$Path)
    $Report | ForEach-Object { Write-Host $_ }
    [System.IO.File]::WriteAllLines($Path, $Report, (New-Object System.Text.UTF8Encoding($false)))
}

# Merges the live Machine+User PATH from the registry into this process's
# $env:Path. Needed because a freshly-installed tool (winget/npm/native
# installer) updates the registry, but this already-running PowerShell
# process doesn't pick that up automatically -- Get-Command would
# otherwise report "not found" even right after a successful install.
function Update-SessionPath {
    $machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $user = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = @($machine, $user) -join ';'
}

function Install-WingetPackage {
    param([string]$Id)
    $out = winget install --id $Id -e --silent --accept-package-agreements --accept-source-agreements 2>&1 | Out-String
    return $out
}

$claudeReady = $false
$nodeReady = $false
$codexReady = $false
$geminiReady = $false
$denoReady = $false
$ytdlpReady = $false
$ffmpegReady = $false
$groqConfigured = $false
$watchPluginReady = $false

try {
    Add-Report '=== AI Stack Install ==='
    Add-Report "Machine: $env:COMPUTERNAME"
    Add-Report "User: $env:USERNAME"
    Add-Report "Captured: $(Get-Date)"
    Add-Report ''

    $wingetAvailable = [bool](Get-Command winget -ErrorAction SilentlyContinue)
    if (-not $wingetAvailable) {
        Add-Report 'NOTE: winget is not available on this machine -- Node.js, Deno, and yt-dlp'
        Add-Report 'steps below will be skipped. Install App Installer from the Microsoft Store'
        Add-Report 'to get winget, then re-run this script.'
        Add-Report ''
    }

    # --- Claude Code CLI ---
    Add-Report '--- Claude Code CLI ---'
    $claudeBin = Join-Path $env:USERPROFILE '.local\bin'
    $claudeExe = Join-Path $claudeBin 'claude.exe'
    $claudeAlready = Test-Path $claudeExe
    Add-Report "  Detected before this run: $claudeAlready"
    try {
        $installOutput = powershell -NoProfile -Command "irm https://claude.ai/install.ps1 | iex" 2>&1 | Out-String
        Add-Report $installOutput.Trim()
    } catch {
        Add-Report "  Install command threw: $($_.Exception.Message)"
    }
    Update-SessionPath
    if (Test-Path $claudeExe) {
        $ver = & $claudeExe --version 2>&1
        Add-Report "  VERIFIED: $claudeExe --version => $ver"
        $claudeReady = $true
    } else {
        Add-Report "  FAILED: $claudeExe not found after the install attempt. See installer output above."
    }
    Add-Report ''

    # --- Node.js + npm (prerequisite for Codex CLI and Gemini CLI) ---
    Add-Report '--- Node.js + npm (prerequisite for Codex CLI and Gemini CLI) ---'
    Update-SessionPath
    $nodeCmd = Get-Command node -ErrorAction SilentlyContinue
    $npmCmd = Get-Command npm -ErrorAction SilentlyContinue
    if ($nodeCmd -and $npmCmd) {
        Add-Report "  Already installed: node $(node --version 2>&1), npm $(npm --version 2>&1)"
        $nodeReady = $true
    } elseif (-not $wingetAvailable) {
        Add-Report '  SKIPPED: winget unavailable. Install Node.js LTS manually from https://nodejs.org and re-run this script.'
    } else {
        Add-Report '  Not found -- installing via winget (OpenJS.NodeJS.LTS)...'
        $nodeOut = Install-WingetPackage -Id 'OpenJS.NodeJS.LTS'
        Add-Report $nodeOut.Trim()
        Update-SessionPath
        $nodeCmd = Get-Command node -ErrorAction SilentlyContinue
        $npmCmd = Get-Command npm -ErrorAction SilentlyContinue
        if ($nodeCmd -and $npmCmd) {
            Add-Report "  VERIFIED: node $(node --version 2>&1), npm $(npm --version 2>&1)"
            $nodeReady = $true
        } else {
            Add-Report '  NOT VERIFIED: node/npm still not detected on PATH. A terminal restart may be needed --'
            Add-Report '  re-run this script after opening a brand-new terminal. Codex CLI and Gemini CLI steps'
            Add-Report '  below will be skipped until this resolves.'
        }
    }
    Add-Report ''

    # --- Codex CLI ---
    Add-Report '--- Codex CLI (@openai/codex via npm) ---'
    if (-not $nodeReady) {
        Add-Report '  SKIPPED: Node.js/npm not available (see section above).'
    } else {
        $npmOut = npm install -g '@openai/codex' 2>&1 | Out-String
        Add-Report $npmOut.Trim()
        Update-SessionPath
        $codexCmd = Get-Command codex -ErrorAction SilentlyContinue
        if ($codexCmd) {
            Add-Report "  VERIFIED: codex $(codex --version 2>&1)"
            $codexReady = $true
        } else {
            Add-Report '  FAILED: codex not found on PATH after npm install. See npm output above.'
        }
    }
    Add-Report ''

    # --- Gemini CLI ---
    Add-Report '--- Gemini CLI (@google/gemini-cli via npm) ---'
    if (-not $nodeReady) {
        Add-Report '  SKIPPED: Node.js/npm not available (see section above).'
    } else {
        Add-Report '  NOTE: this package was NOT previously verified on jeff-laptop -- attempting install and'
        Add-Report '  reporting the real result below rather than assuming success.'
        $npmOut2 = npm install -g '@google/gemini-cli' 2>&1 | Out-String
        Add-Report $npmOut2.Trim()
        Update-SessionPath
        $geminiCmd = Get-Command gemini -ErrorAction SilentlyContinue
        if ($geminiCmd) {
            Add-Report "  VERIFIED: gemini is on PATH ($($geminiCmd.Source))"
            $geminiReady = $true
        } else {
            Add-Report '  NOT VERIFIED: gemini not found on PATH after npm install. See npm output above for the actual error.'
        }
    }
    Add-Report ''

    # --- Deno (required by /watch for YouTube's JS signature challenge) ---
    Add-Report '--- Deno (winget, required by /watch for YouTube downloads) ---'
    $denoCmd = Get-Command deno -ErrorAction SilentlyContinue
    if ($denoCmd) {
        Add-Report "  Already on PATH: $(deno --version 2>&1 | Select-Object -First 1)"
        $denoReady = $true
    } elseif (-not $wingetAvailable) {
        Add-Report '  SKIPPED: winget unavailable.'
    } else {
        $denoOut = Install-WingetPackage -Id 'DenoLand.Deno'
        Add-Report $denoOut.Trim()
        Update-SessionPath
        $denoCmd = Get-Command deno -ErrorAction SilentlyContinue
        if ($denoCmd) {
            Add-Report '  VERIFIED on PATH: deno'
            $denoReady = $true
        } else {
            Add-Report '  WARNING: deno still not detected on PATH. If winget reported success above, a terminal'
            Add-Report '  restart is likely all that is needed -- re-run this script after opening a new terminal.'
            Add-Report '  Per prior /watch setup notes: yt-dlp silently fails YouTube downloads without Deno on PATH.'
        }
    }
    Add-Report ''

    # --- yt-dlp (pulls its own ffmpeg dependency) + ffmpeg fallback ---
    Add-Report '--- yt-dlp + ffmpeg (winget; yt-dlp package pulls ffmpeg automatically) ---'
    $ytdlpCmd = Get-Command yt-dlp -ErrorAction SilentlyContinue
    if ($ytdlpCmd) {
        Add-Report "  Already on PATH: $(yt-dlp --version 2>&1)"
        $ytdlpReady = $true
    } elseif (-not $wingetAvailable) {
        Add-Report '  SKIPPED: winget unavailable.'
    } else {
        $ytdlpOut = Install-WingetPackage -Id 'yt-dlp.yt-dlp'
        Add-Report $ytdlpOut.Trim()
        Update-SessionPath
        $ytdlpCmd = Get-Command yt-dlp -ErrorAction SilentlyContinue
        if ($ytdlpCmd) {
            Add-Report '  VERIFIED on PATH: yt-dlp'
            $ytdlpReady = $true
        } else {
            Add-Report '  WARNING: yt-dlp not detected on PATH after install attempt.'
        }
    }

    $ffmpegCmd = Get-Command ffmpeg -ErrorAction SilentlyContinue
    if ($ffmpegCmd) {
        Add-Report "  ffmpeg present: $($ffmpegCmd.Source)"
        $ffmpegReady = $true
    } elseif (-not $wingetAvailable) {
        Add-Report '  ffmpeg not detected, and winget is unavailable to install a fallback.'
    } else {
        Add-Report '  ffmpeg not detected (expected to come bundled with yt-dlp.yt-dlp) -- falling back to an'
        Add-Report '  explicit install (Gyan.FFmpeg)...'
        $ffmpegOut = Install-WingetPackage -Id 'Gyan.FFmpeg'
        Add-Report $ffmpegOut.Trim()
        Update-SessionPath
        $ffmpegCmd = Get-Command ffmpeg -ErrorAction SilentlyContinue
        if ($ffmpegCmd) {
            Add-Report '  VERIFIED on PATH: ffmpeg (via Gyan.FFmpeg fallback)'
            $ffmpegReady = $true
        } else {
            Add-Report '  WARNING: ffmpeg still not detected on PATH after fallback install.'
        }
    }
    Add-Report ''

    # --- /watch plugin: Groq API key ---
    Add-Report '--- /watch plugin: Groq API key ---'
    $watchConfigDir = Join-Path $env:USERPROFILE '.config\watch'
    $watchEnvFile = Join-Path $watchConfigDir '.env'
    $hasKey = $false
    if (Test-Path $watchEnvFile) {
        $content = Get-Content $watchEnvFile -Raw -ErrorAction SilentlyContinue
        if ($content -match 'GROQ_API_KEY=\S+') { $hasKey = $true }
    }
    if ($hasKey) {
        Add-Report "  Already configured: $watchEnvFile has a GROQ_API_KEY entry (value not shown)."
        $groqConfigured = $true
    } else {
        Write-Host ''
        Write-Host 'The /watch Claude Code plugin needs a Groq API key.'
        $secureKey = Read-Host 'Paste your Groq API key now, or press Enter to skip and add it later' -AsSecureString
        $plainKey = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureKey))
        if (-not [string]::IsNullOrWhiteSpace($plainKey)) {
            if (-not (Test-Path $watchConfigDir)) { New-Item -ItemType Directory -Path $watchConfigDir -Force | Out-Null }
            Set-Content -Path $watchEnvFile -Value "GROQ_API_KEY=$plainKey"
            Add-Report "  WROTE $watchEnvFile with a GROQ_API_KEY entry (value not shown in this report)."
            $groqConfigured = $true
        } else {
            Add-Report "  SKIPPED -- no key entered. Add it later: create $watchEnvFile with a line"
            Add-Report "  'GROQ_API_KEY=<your key>'. See PKM/Environment/Accounts/groq.md in the vault for where to find it."
        }
        $plainKey = $null
    }
    Add-Report ''

    # --- /watch plugin registration inside Claude Code itself ---
    Add-Report '--- /watch plugin registration in Claude Code ---'
    if (-not $claudeReady) {
        Add-Report '  SKIPPED: Claude Code CLI is not verified working (see Claude Code CLI section above).'
    } else {
        # Always invoke via the full path, not bare "claude" -- if Claude Code
        # was JUST installed earlier in this same run, this process's PATH
        # does not yet include .local\bin (registry PATH updates don't
        # retroactively affect an already-running process).
        $marketplaceOut = & $claudeExe plugin marketplace add 'https://github.com/taeloautomates/claude-video.git' 2>&1 | Out-String
        Add-Report '  claude plugin marketplace add https://github.com/taeloautomates/claude-video.git'
        Add-Report $marketplaceOut.Trim()
        $installOut = & $claudeExe plugin install 'watch@claude-video' 2>&1 | Out-String
        Add-Report '  claude plugin install watch@claude-video'
        Add-Report $installOut.Trim()

        $listOut = & $claudeExe plugin list 2>&1 | Out-String
        Add-Report '  Verification (claude plugin list):'
        Add-Report $listOut.Trim()
        $watchPluginReady = $listOut -match 'watch'
        if ($watchPluginReady) {
            Add-Report '  VERIFIED: watch plugin appears in the plugin list.'
        } else {
            Add-Report '  NOT VERIFIED: watch plugin did not appear in the plugin list -- check the command output above.'
        }
    }
    Add-Report ''

    # --- Result summary ---
    Add-Report '--- Result summary ---'
    Add-Report "  Claude Code CLI:        $(if ($claudeReady) { 'OK' } else { 'FAILED' })"
    Add-Report "  Node.js + npm:          $(if ($nodeReady) { 'OK' } else { 'FAILED/SKIPPED' })"
    Add-Report "  Codex CLI:              $(if ($codexReady) { 'OK' } else { 'FAILED/SKIPPED' })"
    Add-Report "  Gemini CLI:             $(if ($geminiReady) { 'OK' } else { 'NOT VERIFIED/SKIPPED' })"
    Add-Report "  Deno:                   $(if ($denoReady) { 'OK' } else { 'FAILED/SKIPPED' })"
    Add-Report "  yt-dlp:                 $(if ($ytdlpReady) { 'OK' } else { 'FAILED/SKIPPED' })"
    Add-Report "  ffmpeg:                 $(if ($ffmpegReady) { 'OK' } else { 'FAILED/SKIPPED' })"
    Add-Report "  Groq API key file:      $(if ($groqConfigured) { 'CONFIGURED' } else { 'SKIPPED -- add later' })"
    Add-Report "  /watch plugin in Claude Code: $(if ($watchPluginReady) { 'OK' } else { 'NOT VERIFIED/SKIPPED' })"
    Add-Report ''
    if (-not ($claudeReady -and $nodeReady -and $codexReady -and $denoReady -and $ytdlpReady -and $ffmpegReady)) {
        Add-Report 'One or more core steps did not verify cleanly above (Gemini CLI being unverified alone is'
        Add-Report 'expected/OK, since it was never confirmed working on jeff-laptop before this script existed).'
        Add-Report 'If PATH-related items show FAILED, close ALL terminal windows, open a brand-new one, and'
        Add-Report 're-run this script -- most failures here are stale-PATH, not a real install problem.'
    } else {
        Add-Report 'All core steps verified OK.'
    }
} catch {
    Add-Report ''
    Add-Report '--- SCRIPT ERROR (partial report above is still valid) ---'
    Add-Report $_.Exception.Message
    Add-Report $_.ScriptStackTrace
} finally {
    Write-ReportFile -Report $report -Path $OutFile
}

Write-Host ''
Write-Host 'Report written. Press Enter to close this window...'
Read-Host | Out-Null
