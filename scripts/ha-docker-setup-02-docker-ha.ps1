# Step 2 of the pool-monitor HA sandbox setup: Docker Desktop + Home
# Assistant. Idempotent (safe to re-run/resume), retries the Docker
# Desktop download, verifies the daemon actually comes up before trying
# docker compose, and confirms the HA onboarding page responds before
# declaring success. Writes a report to the -OutFile path.
param(
    [Parameter(Mandatory = $true)]
    [string]$OutFile
)

# --- Launch marker (written BEFORE the UAC prompt) ---
# This is the single most important line for diagnosing a "nothing
# happened" report after a RunOnce-triggered reboot: it proves the script
# actually fired, independent of whether the UAC consent prompt was seen,
# denied, or timed out on the secure desktop. Shared with step1.ps1 / the
# .bat launchers so one file has the full timeline.
$launchLogPath = Join-Path (Split-Path -Parent $OutFile) 'runonce-launch-log.txt'
function Add-LaunchLog {
    param([string]$Line)
    try { Add-Content -Path $launchLogPath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  [step2.ps1] $Line" -ErrorAction Stop }
    catch { } # never let logging failure break the actual setup
}

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
Add-LaunchLog "Invoked. PID=$PID User=$env:USERNAME Elevated=$isAdmin"

if (-not $isAdmin) {
    Add-LaunchLog 'Not elevated -- requesting UAC elevation now. A consent prompt should appear on the secure desktop; if nobody clicks Yes within a few minutes it times out and is treated as denied.'
    $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"", '-OutFile', "`"$OutFile`"")
    try {
        Start-Process powershell -ArgumentList $argList -Verb RunAs -Wait -ErrorAction Stop
        Add-LaunchLog 'Elevated child process returned normally (elevation was granted). Check the timestamped report in Team Inbox for the actual setup result.'
    } catch {
        Add-LaunchLog "ELEVATION FAILED -- $($_.Exception.Message). Nobody approved the UAC prompt in time (denied, cancelled, or it timed out on the secure desktop). Nothing else ran. Fix: double-click ha-docker-setup-02-docker-ha.bat again and click Yes promptly when the prompt appears."
    }
    exit
}

Add-LaunchLog 'Running elevated -- proceeding with setup.'

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

try {
    Add-Report '=== Pool Monitor HA Sandbox Setup Step 2: Docker Desktop + Home Assistant ==='
    Add-Report "Machine: $env:COMPUTERNAME"
    Add-Report "Captured: $(Get-Date)"
    Add-Report ''

    # --- Pre-check: WSL2 ready? ---
    Add-Report '--- Pre-check: WSL2 ---'
    # VirtualMachinePlatform is the DISM feature genuinely required for the WSL2
    # backend Docker Desktop uses. Microsoft-Windows-Subsystem-Linux (the legacy
    # DISM feature) is only required for WSL1 -- `wsl --status` says so explicitly
    # on builds where WSL2 already has its own separately-installed kernel
    # package. Gating on the legacy feature blocked a fully-functional WSL2
    # machine for an entire evening (2026-07-16, bridget-laptop): VMP was
    # Enabled and `wsl --status` reported a healthy WSL2 kernel, but the legacy
    # feature never finalized to Enabled. It is reported below for debugging
    # visibility ONLY -- it is not part of the readiness gate.
    $wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -ErrorAction SilentlyContinue
    $vmpFeature = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -ErrorAction SilentlyContinue
    $vmpEnabled = $vmpFeature -and $vmpFeature.State -eq 'Enabled'
    Add-Report "  Microsoft-Windows-Subsystem-Linux: $(if ($wslFeature) { $wslFeature.State } else { 'not found' }) (informational only -- required for WSL1, NOT for WSL2/Docker Desktop; not part of the gate below)"
    Add-Report "  VirtualMachinePlatform:            $(if ($vmpFeature) { $vmpFeature.State } else { 'not found' }) (required -- part of the gate below)"

    # Functional check: does `wsl --status` actually succeed? This is a more
    # accurate signal of "is WSL2 actually usable" than any DISM feature flag.
    $wslStatusOutput = wsl --status 2>&1 | Out-String
    $wslStatusOk = ($LASTEXITCODE -eq 0)
    Add-Report "  wsl --status exit code: $LASTEXITCODE (0 = healthy)"
    Add-Report (($wslStatusOutput.Trim() -split "`r?`n" | ForEach-Object { "    $_" }) -join "`n")

    $wslReady = $vmpEnabled -and $wslStatusOk
    Add-Report "  WSL2 ready (VirtualMachinePlatform Enabled AND 'wsl --status' succeeded): $wslReady"
    if (-not $wslReady) {
        Add-Report '  WSL2 is not ready yet. Run Step 1 first and reboot. Stopping here.'
        Write-ReportFile -Report $report -Path $OutFile
        Write-Host 'WSL2 not ready -- see report. Run Step 1 first.'
        exit 1
    }
    Add-Report ''

    # --- Docker Desktop: install if missing ---
    Add-Report '--- Docker Desktop ---'
    $dockerExe = "$env:ProgramFiles\Docker\Docker\Docker Desktop.exe"
    $dockerInstalled = Test-Path $dockerExe
    Add-Report "  Already installed: $dockerInstalled"

    if (-not $dockerInstalled) {
        Add-Report '  Downloading Docker Desktop installer...'
        $installerUrl = 'https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe'
        $installerPath = Join-Path $env:TEMP 'DockerDesktopInstaller.exe'
        $downloaded = $false
        for ($attempt = 1; $attempt -le 3; $attempt++) {
            try {
                Add-Report "  Attempt $attempt..."
                Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -UseBasicParsing -TimeoutSec 300
                $size = (Get-Item $installerPath).Length
                if ($size -gt 300MB) {
                    Add-Report "  Downloaded OK: $([math]::Round($size/1MB)) MB"
                    $downloaded = $true
                    break
                } else {
                    Add-Report "  Download looks truncated ($([math]::Round($size/1MB)) MB) -- retrying."
                }
            } catch {
                Add-Report "  Attempt $attempt failed: $($_.Exception.Message)"
                Start-Sleep -Seconds (5 * $attempt)
            }
        }

        if (-not $downloaded) {
            Add-Report '  FAILED to download Docker Desktop installer after 3 attempts. Stopping here.'
            Write-ReportFile -Report $report -Path $OutFile
            Write-Host 'Docker Desktop download failed -- see report.'
            exit 1
        }

        Add-Report '  Running silent install (this can take several minutes)...'
        $proc = Start-Process -FilePath $installerPath -ArgumentList 'install --quiet --accept-license --backend=wsl-2' -Wait -PassThru
        Add-Report "  Installer exit code: $($proc.ExitCode) (0 = success, 3010 = success, reboot suggested)"
        if ($proc.ExitCode -notin @(0, 3010)) {
            Add-Report '  Installer reported a non-success exit code. Stopping here for manual review.'
            Write-ReportFile -Report $report -Path $OutFile
            Write-Host 'Docker Desktop install may have failed -- see report.'
            exit 1
        }
    }
    Add-Report ''

    # --- Enable "start Docker Desktop at sign-in" (best-effort, schema varies by version) ---
    Add-Report '--- Docker Desktop: enable start-at-sign-in ---'
    $settingsCandidates = @(
        (Join-Path $env:APPDATA 'Docker\settings-store.json'),
        (Join-Path $env:APPDATA 'Docker\settings.json')
    )
    $patched = $false
    foreach ($settingsPath in $settingsCandidates) {
        if (Test-Path $settingsPath) {
            try {
                $backup = "$settingsPath.bak-$(Get-Date -Format yyyyMMdd-HHmmss)"
                Copy-Item $settingsPath $backup
                $json = Get-Content $settingsPath -Raw | ConvertFrom-Json
                $keyName = if ($json.PSObject.Properties.Name -contains 'AutoStart') { 'AutoStart' } elseif ($json.PSObject.Properties.Name -contains 'autoStart') { 'autoStart' } else { $null }
                if ($keyName) {
                    $json.$keyName = $true
                    $json | ConvertTo-Json -Depth 20 | Set-Content $settingsPath
                    Add-Report "  Patched '$keyName' = true in $settingsPath (backup: $backup)"
                    $patched = $true
                } else {
                    Add-Report "  Found $settingsPath but no known autostart key -- schema may have changed."
                }
            } catch {
                Add-Report "  Could not patch $settingsPath -- $($_.Exception.Message)"
            }
            break
        }
    }
    if (-not $patched) {
        Add-Report '  Could not confirm autostart via settings file -- set manually: Docker Desktop > Settings > General >'
        Add-Report '  "Start Docker Desktop when you sign in".'
    }
    Add-Report ''

    # --- Start Docker Desktop and wait for the daemon ---
    Add-Report '--- Waiting for Docker daemon to come up ---'
    Start-Process $dockerExe -ErrorAction SilentlyContinue
    $daemonReady = $false
    for ($i = 0; $i -lt 18; $i++) {
        docker info *> $null
        if ($LASTEXITCODE -eq 0) { $daemonReady = $true; break }
        Start-Sleep -Seconds 10
    }
    Add-Report "  Daemon ready after up to 3 minutes of waiting: $daemonReady"
    if (-not $daemonReady) {
        Add-Report '  Docker daemon did not come up in time. Open Docker Desktop manually, let it finish first-run'
        Add-Report '  setup/sign-in, then re-run this script -- it is safe to re-run.'
        Write-ReportFile -Report $report -Path $OutFile
        Write-Host 'Docker daemon not ready -- see report.'
        exit 1
    }
    $dv = docker --version 2>&1
    $cv = docker compose version 2>&1
    Add-Report "  $dv"
    Add-Report "  $cv"
    Add-Report ''

    # --- Home Assistant ---
    Add-Report '--- Home Assistant (docker compose) ---'
    $haDir = 'C:\HomeAssistant'
    $haConfigDir = Join-Path $haDir 'config'
    New-Item -ItemType Directory -Path $haConfigDir -Force | Out-Null
    Add-Report "  Config dir ready: $haConfigDir"

    $composeContent = @'
services:
  homeassistant:
    container_name: homeassistant
    image: ghcr.io/home-assistant/home-assistant:stable
    volumes:
      - C:\HomeAssistant\config:/config
    restart: unless-stopped
    environment:
      - TZ=America/New_York
    ports:
      - "8123:8123"
'@
    $composePath = Join-Path $haDir 'docker-compose.yml'
    $needsWrite = $true
    if (Test-Path $composePath) {
        $existing = Get-Content $composePath -Raw
        if ($existing.Trim() -eq $composeContent.Trim()) { $needsWrite = $false }
    }
    if ($needsWrite) {
        if (Test-Path $composePath) {
            Copy-Item $composePath "$composePath.bak-$(Get-Date -Format yyyyMMdd-HHmmss)"
            Add-Report '  Existing docker-compose.yml differed -- backed up before overwrite.'
        }
        Set-Content -Path $composePath -Value $composeContent
        Add-Report "  Wrote $composePath"
    } else {
        Add-Report "  $composePath already up to date."
    }

    Add-Report '  Starting container (docker compose up -d)...'
    Push-Location $haDir
    $composeUp = docker compose up -d 2>&1 | Out-String
    Pop-Location
    Add-Report $composeUp.Trim()
    Add-Report ''

    Add-Report '--- Verifying Home Assistant onboarding page ---'
    $haReady = $false
    for ($i = 0; $i -lt 18; $i++) {
        try {
            $resp = Invoke-WebRequest -Uri 'http://localhost:8123' -UseBasicParsing -TimeoutSec 5
            if ($resp.StatusCode -eq 200) { $haReady = $true; break }
        } catch {
            # HA returns a redirect during early boot too -- a web exception here just means "not up yet"
        }
        Start-Sleep -Seconds 10
    }
    Add-Report "  Reachable at http://localhost:8123 within 3 minutes: $haReady"
    Add-Report ''

    Add-Report '--- Result ---'
    if ($haReady) {
        Add-Report 'Docker Desktop + Home Assistant are both up and verified.'
        Add-Report 'Open http://localhost:8123 in a browser to complete HA onboarding (create the admin account, etc.) -- that part is interactive by design.'
    } else {
        Add-Report 'Container started but the onboarding page did not respond in time.'
        Add-Report 'Check manually: docker compose -f C:\HomeAssistant\docker-compose.yml logs -f homeassistant'
        Add-Report 'It may just need more time on first boot -- try http://localhost:8123 again in a few minutes.'
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
Write-Host 'Report written to Team Inbox. Press Enter to close this window...'
Read-Host | Out-Null
