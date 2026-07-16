# Step 1 of the pool-monitor HA sandbox setup: power settings + WSL2.
# Self-elevating, idempotent (safe to re-run), writes a report to the
# -OutFile path passed by the launcher .bat, and schedules Step 2 to
# auto-launch the next time this user logs in (via RunOnce) so a reboot
# doesn't require remembering to double-click the next script.
param(
    [Parameter(Mandatory = $true)]
    [string]$OutFile,
    [Parameter(Mandatory = $true)]
    [string]$Step2BatPath
)

# --- Launch marker (written BEFORE the UAC prompt) ---
# Proves the script actually fired even if the UAC consent prompt is
# missed/denied/times out. Shared with step2.ps1 / the .bat launchers so
# one file has the full timeline across a reboot.
$launchLogPath = Join-Path (Split-Path -Parent $OutFile) 'runonce-launch-log.txt'
function Add-LaunchLog {
    param([string]$Line)
    try { Add-Content -Path $launchLogPath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  [step1.ps1] $Line" -ErrorAction Stop }
    catch { } # never let logging failure break the actual setup
}

# --- Self-elevate if not already admin ---
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
Add-LaunchLog "Invoked. PID=$PID User=$env:USERNAME Elevated=$isAdmin"

if (-not $isAdmin) {
    Add-LaunchLog 'Not elevated -- requesting UAC elevation now. A consent prompt should appear on the secure desktop; if nobody clicks Yes within a few minutes it times out and is treated as denied.'
    $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"", '-OutFile', "`"$OutFile`"", '-Step2BatPath', "`"$Step2BatPath`"")
    try {
        Start-Process powershell -ArgumentList $argList -Verb RunAs -Wait -ErrorAction Stop
        Add-LaunchLog 'Elevated child process returned normally (elevation was granted). Check the timestamped report in Team Inbox for the actual setup result.'
    } catch {
        Add-LaunchLog "ELEVATION FAILED -- $($_.Exception.Message). Nobody approved the UAC prompt in time (denied, cancelled, or it timed out on the secure desktop). Nothing else ran. Fix: double-click ha-docker-setup-01-power-wsl.bat again and click Yes promptly when the prompt appears."
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

$rebootNeeded = $false

try {
    Add-Report '=== Pool Monitor HA Sandbox Setup Step 1: Power Settings + WSL2 ==='
    Add-Report "Machine: $env:COMPUTERNAME"
    Add-Report "Captured: $(Get-Date)"
    Add-Report "Running elevated: $isAdmin"
    Add-Report ''

    # --- Power settings ---
    Add-Report '--- Power: sleep never (plugged in) ---'
    powercfg /change standby-timeout-ac 0 | Out-Null
    powercfg /change hibernate-timeout-ac 0 | Out-Null
    $standby = (powercfg /query SCHEME_CURRENT SUB_SLEEP STANDBYIDLE 2>&1 | Select-String 'Current AC Power Setting Index') -join ''
    Add-Report "  standby-timeout-ac set to 0 (never). Verify string: $standby"

    Add-Report ''
    Add-Report '--- Power: lid-close action = Do Nothing (AC + battery) ---'
    $SUB_BUTTONS = '4f971e89-eebd-4455-a8de-9e59040e7347'
    $LIDACTION = '5ca83367-6e45-459f-a27b-476b1d01c936'
    powercfg /setacvalueindex SCHEME_CURRENT $SUB_BUTTONS $LIDACTION 0 | Out-Null
    powercfg /setdcvalueindex SCHEME_CURRENT $SUB_BUTTONS $LIDACTION 0 | Out-Null
    powercfg /setactive SCHEME_CURRENT | Out-Null
    $lidQuery = powercfg /query SCHEME_CURRENT $SUB_BUTTONS $LIDACTION 2>&1 | Out-String
    $lidOk = $lidQuery -match '0x00000000'
    Add-Report "  Lid action set to 'Do nothing'. Verified 0x00000000 present: $lidOk"
    if (-not $lidOk) {
        Add-Report "  Raw query output for manual check:"
        Add-Report ($lidQuery.Trim())
    }
    Add-Report ''

    # --- WSL2 ---
    Add-Report '--- WSL2 ---'
    # VirtualMachinePlatform is the DISM feature genuinely required for the WSL2
    # backend Docker Desktop uses. Microsoft-Windows-Subsystem-Linux (the legacy
    # DISM feature) is only required for WSL1 -- `wsl --status` says so
    # explicitly on builds where WSL2 already has its own separately-installed
    # kernel package. Requiring the legacy feature here was observed to loop
    # forever demanding needless reboots (2026-07-16, bridget-laptop): VMP was
    # Enabled and `wsl --status` was healthy, but the legacy feature never
    # finalized to Enabled even after `wsl --install --no-distribution` +
    # a real reboot, so this step kept re-triggering install/reboot on every
    # run. It is reported below for debugging visibility ONLY -- it is not
    # part of the "already installed" check.
    $wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -ErrorAction SilentlyContinue
    $vmpFeature = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -ErrorAction SilentlyContinue
    $vmpEnabled = $vmpFeature -and $vmpFeature.State -eq 'Enabled'
    Add-Report "  Microsoft-Windows-Subsystem-Linux: $(if ($wslFeature) { $wslFeature.State } else { 'not found' }) (informational only -- required for WSL1, NOT for WSL2/Docker Desktop; not part of the check below)"
    Add-Report "  VirtualMachinePlatform:            $(if ($vmpFeature) { $vmpFeature.State } else { 'not found' }) (required -- part of the check below)"

    # Functional check: does `wsl --status` actually succeed? More accurate
    # signal of "is WSL2 actually usable right now" than any DISM feature flag.
    $wslStatusOutput = wsl --status 2>&1 | Out-String
    $wslStatusOk = ($LASTEXITCODE -eq 0)
    Add-Report "  wsl --status exit code: $LASTEXITCODE (0 = healthy)"
    Add-Report (($wslStatusOutput.Trim() -split "`r?`n" | ForEach-Object { "    $_" }) -join "`n")

    if ($vmpEnabled -and $wslStatusOk) {
        Add-Report '  WSL2 already functional (VirtualMachinePlatform Enabled AND wsl --status healthy) -- skipping install, no reboot needed for this step.'
    } else {
        Add-Report '  Installing WSL2 (no default distro -- Docker Desktop only needs the WSL2 engine)...'
        $installOutput = wsl --install --no-distribution 2>&1 | Out-String
        Add-Report $installOutput.Trim()
        $rebootNeeded = $true
        Add-Report '  WSL2 install triggered -- a REBOOT IS REQUIRED to finish this.'
    }
    Add-Report ''

    # --- WSL2 memory ceiling (.wslconfig) ---
    # Runs unconditionally every time this script runs, regardless of whether
    # WSL2 was just installed above or was already present -- Docker Desktop's
    # WSL2 backend can otherwise default toward using up to half of host RAM,
    # which matters on lower-RAM machines. Idempotent: never overwrites an
    # existing [wsl2] memory= value the user may have customized -- only adds
    # the section/key if it is genuinely missing.
    Add-Report '--- WSL2 memory ceiling (.wslconfig) ---'
    $wslConfigPath = Join-Path $env:UserProfile '.wslconfig'
    $desiredMemory = '4GB'
    $wslConfigChanged = $false

    $existingContent = if (Test-Path $wslConfigPath) { Get-Content -Path $wslConfigPath -Raw } else { '' }
    $lines = if ($existingContent) { $existingContent -split "`r?`n" } else { @() }

    $inWsl2Section = $false
    $wsl2SectionExists = $false
    $existingMemoryValue = $null
    foreach ($line in $lines) {
        $trimmed = $line.Trim()
        if ($trimmed -match '^\[(.+)\]$') {
            $inWsl2Section = ($Matches[1].Trim().ToLower() -eq 'wsl2')
            if ($inWsl2Section) { $wsl2SectionExists = $true }
            continue
        }
        if ($inWsl2Section -and $trimmed -match '^memory\s*=\s*(.+)$') {
            $existingMemoryValue = $Matches[1].Trim()
        }
    }

    if ($existingMemoryValue) {
        Add-Report "  Existing [wsl2] memory= key found (memory=$existingMemoryValue) in $wslConfigPath -- leaving it as-is, not overwriting a possibly customized config."
    } elseif ($wsl2SectionExists) {
        Add-Report "  [wsl2] section exists in $wslConfigPath but has no memory= key -- adding memory=$desiredMemory under it."
        $newLines = @()
        $inWsl2SectionWrite = $false
        $inserted = $false
        foreach ($line in $lines) {
            $newLines += $line
            $trimmed = $line.Trim()
            if ($trimmed -match '^\[(.+)\]$') {
                $inWsl2SectionWrite = ($Matches[1].Trim().ToLower() -eq 'wsl2')
                if ($inWsl2SectionWrite -and -not $inserted) {
                    $newLines += "memory=$desiredMemory"
                    $inserted = $true
                }
            }
        }
        Set-Content -Path $wslConfigPath -Value $newLines
        $wslConfigChanged = $true
        Add-Report "  Updated: $wslConfigPath"
    } else {
        Add-Report "  No [wsl2] section found -- creating/appending one in $wslConfigPath with memory=$desiredMemory (this machine has ~12GB RAM total; a 4GB WSL2 ceiling leaves ~8GB for Windows and everything else)."
        $newSection = @()
        if ($lines.Count -gt 0 -and $lines[-1].Trim() -ne '') {
            $newSection += ''
        }
        $newSection += '[wsl2]'
        $newSection += "memory=$desiredMemory"
        Add-Content -Path $wslConfigPath -Value $newSection
        $wslConfigChanged = $true
        Add-Report "  Created/updated: $wslConfigPath"
    }

    if ($wslConfigChanged) {
        Add-Report '  .wslconfig was changed -- running "wsl --shutdown" so the new memory ceiling takes effect...'
        wsl --shutdown 2>&1 | Out-Null
        Add-Report '  wsl --shutdown complete.'
    } else {
        Add-Report '  No change made to .wslconfig -- skipping "wsl --shutdown" (nothing to apply).'
    }
    Add-Report ''

    # --- Schedule Step 2 to run automatically at next logon ---
    if ($rebootNeeded) {
        Add-Report '--- Scheduling Step 2 to auto-run at your next login (via RunOnce) ---'
        $runOnceKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce'
        $runOnceCmd = "cmd.exe /c `"$Step2BatPath`""
        Set-ItemProperty -Path $runOnceKey -Name 'PoolMonitorHaSandboxSetupStep2' -Value $runOnceCmd
        Add-Report "  RunOnce entry set: $runOnceCmd"
        Add-Report '  (RunOnce entries fire once at next interactive logon, then self-delete.)'
    }
    Add-Report ''

    Add-Report '--- Result ---'
    if ($rebootNeeded) {
        Add-Report 'WSL2 install triggered. REBOOT REQUIRED.'
        Add-Report 'Step 2 (Docker + Home Assistant) will launch automatically the next time you log in.'
        Add-Report 'You will see a console window open on its own after signing back in -- that is expected.'
    } else {
        Add-Report 'WSL2 was already installed -- no reboot needed. You can run Step 2 right now:'
        Add-Report "  $Step2BatPath"
    }
} catch {
    Add-Report ''
    Add-Report '--- SCRIPT ERROR (partial report above is still valid) ---'
    Add-Report $_.Exception.Message
    Add-Report $_.ScriptStackTrace
} finally {
    Write-ReportFile -Report $report -Path $OutFile
}

if ($rebootNeeded) {
    Write-Host ''
    Write-Host '============================================================'
    Write-Host ' A REBOOT IS REQUIRED to finish installing WSL2.'
    Write-Host ' Step 2 will run automatically after you log back in.'
    Write-Host '============================================================'
    Write-Host ''
    Write-Host 'Press Y then Enter to reboot now, or press any other key + Enter to reboot later yourself.'
    $answer = Read-Host
    if ($answer -match '^[Yy]') {
        shutdown /r /t 15 /c "Rebooting to finish WSL2 install for the pool-monitor HA sandbox."
        Write-Host 'Rebooting in 15 seconds. Run "shutdown /a" to cancel if you change your mind.'
    } else {
        Write-Host 'OK -- reboot whenever you are ready. Step 2 will still run automatically at next login.'
    }
} else {
    Write-Host ''
    Write-Host 'Report written to Team Inbox. Press Enter to close this window...'
    Read-Host | Out-Null
}
