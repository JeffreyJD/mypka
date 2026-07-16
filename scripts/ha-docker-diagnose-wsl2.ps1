# Standalone READ-ONLY diagnostic for the pool-monitor HA sandbox bundle.
# Investigates why ha-docker-setup-02-docker-ha.ps1's WSL2 pre-check keeps
# reporting Microsoft-Windows-Subsystem-Linux / VirtualMachinePlatform as
# not-enabled, even though ha-docker-setup-01-power-wsl.ps1's DISM-backed
# "wsl --install --no-distribution" reported success and required a reboot,
# and a genuine full restart was performed afterward.
#
# This script changes NOTHING on the system. It does not install, enable,
# or modify anything -- registry, feature state, files -- it only reads and
# reports. Self-elevates (like step1.ps1/step2.ps1) because `dism /online`
# and some of the registry/log reads are unreliable or blocked without
# admin, but the body is strictly read-only once elevated.
#
# Gathers: raw DISM feature state (not just the PowerShell cmdlet, in case
# of a discrepancy), the three standard pending-reboot registry indicators,
# recent hotfix/Windows Update history, the tail of dism.log, wsl
# --status/--version, and system uptime -- everything needed to tell apart
# "the DISM change never actually finished across the reboot" from "a
# different pending operation (e.g. Windows Update) consumed that restart
# cycle before DISM's own change could finalize" from "something is
# actually still broken."
param(
    [Parameter(Mandatory = $true)]
    [string]$OutFile
)

# --- Self-elevate if not already admin ---
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"", '-OutFile', "`"$OutFile`"")
    try {
        Start-Process powershell -ArgumentList $argList -Verb RunAs -Wait -ErrorAction Stop
    } catch {
        Write-Host ''
        Write-Host "ELEVATION FAILED -- $($_.Exception.Message)"
        Write-Host 'Nobody approved the UAC prompt in time (denied, cancelled, or it timed out on the secure'
        Write-Host 'desktop), so nothing was gathered and no report was written. Double-click'
        Write-Host 'ha-docker-diagnose-wsl2.bat again and click Yes promptly when the prompt appears.'
        Write-Host ''
        Read-Host 'Press Enter to close this window' | Out-Null
    }
    exit
}

$ErrorActionPreference = 'Continue'
$report = @()
function Add-Report { param([string]$Line) $script:report += $Line }

# Windows PowerShell 5.1's default Tee-Object/Out-File encoding is UTF-16LE
# (with BOM) -- fine for PowerShell/Notepad, but it opens as garbled
# spaced-out text in plenty of other tools (and is a different bug class
# from the wsl.exe decode issue above, though both show up as "spaced-out
# letters"). Write explicit UTF-8 with no BOM instead so reports open
# cleanly everywhere, while still echoing to the console like Tee-Object did.
function Write-ReportFile {
    param([string[]]$Report, [string]$Path)
    $Report | ForEach-Object { Write-Host $_ }
    [System.IO.File]::WriteAllLines($Path, $Report, (New-Object System.Text.UTF8Encoding($false)))
}

# Windows PowerShell 5.1 has a well-known decoding bug with wsl.exe: when
# wsl.exe's stdout is redirected (not a real console -- true here since we
# capture it through the pipeline), it emits UTF-16LE, but PowerShell 5.1's
# native-command output capture decodes it one byte at a time using the
# system's single-byte OEM codepage, producing a string with a literal NUL
# character embedded after every real character (renders as garbled
# spacing: "D e f a u l t"). Detect that signature (an embedded NUL is a
# reliable tell) and repair it by round-tripping through the encodings;
# leave anything without that signature untouched so this never corrupts
# already-correct output on a system where the bug doesn't reproduce.
function Repair-WslOutput {
    param([string]$Text)
    if ([string]::IsNullOrEmpty($Text)) { return $Text }
    if (-not $Text.Contains([char]0)) { return $Text.Trim() }
    try {
        $bytes = [System.Text.Encoding]::Default.GetBytes($Text)
        $decoded = [System.Text.Encoding]::Unicode.GetString($bytes)
        return ($decoded -replace '[^\x20-\x7E\r\n]', '').Trim()
    } catch {
        return $Text.Trim()
    }
}

try {
    Add-Report '=== WSL2 / VirtualMachinePlatform Diagnostic (READ-ONLY) ==='
    Add-Report "Machine: $env:COMPUTERNAME"
    Add-Report "User: $env:USERNAME"
    Add-Report "Captured: $(Get-Date)"
    Add-Report "Running elevated: $isAdmin"
    Add-Report ''
    Add-Report 'This script makes NO changes to the system. It only reads and reports.'
    Add-Report ''

    # --- 1. Raw DISM feature state (ground truth -- not just the PS cmdlet) ---
    Add-Report '--- 1. DISM feature state (dism /online /get-featureinfo) ---'
    foreach ($feature in @('Microsoft-Windows-Subsystem-Linux', 'VirtualMachinePlatform')) {
        Add-Report "  > dism /online /get-featureinfo /featurename:$feature"
        try {
            $dismOut = dism /online /get-featureinfo /featurename:$feature 2>&1 | Out-String
            Add-Report ($dismOut.Trim() -split "`r?`n" | ForEach-Object { "    $_" }) -join "`n"
        } catch {
            Add-Report "    DISM call threw: $($_.Exception.Message)"
        }
        Add-Report ''
    }

    # --- 1b. PowerShell cmdlet view, for cross-check against the raw DISM output above ---
    # Note: Get-WindowsOptionalFeature -Online can throw a full terminating
    # exception when unprivileged (not just a non-terminating error), so
    # -ErrorAction SilentlyContinue alone isn't enough -- wrap in try/catch
    # so a permissions hiccup here can't abort sections 2-6 below.
    Add-Report '--- 1b. Get-WindowsOptionalFeature cmdlet view (cross-check vs. raw DISM above) ---'
    try {
        $wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -ErrorAction Stop
        Add-Report "  Microsoft-Windows-Subsystem-Linux: $(if ($wslFeature) { $wslFeature.State } else { 'not found' })"
    } catch {
        Add-Report "  Microsoft-Windows-Subsystem-Linux: query failed -- $($_.Exception.Message)"
    }
    try {
        $vmpFeature = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -ErrorAction Stop
        Add-Report "  VirtualMachinePlatform:            $(if ($vmpFeature) { $vmpFeature.State } else { 'not found' })"
    } catch {
        Add-Report "  VirtualMachinePlatform:            query failed -- $($_.Exception.Message)"
    }
    Add-Report ''

    # --- 2. Pending-reboot indicators ---
    Add-Report '--- 2. Pending-reboot registry indicators ---'
    $cbsRebootPending = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
    Add-Report "  Component Based Servicing\RebootPending key exists: $cbsRebootPending"
    Add-Report '    (If True: a servicing/CBS operation still considers a reboot pending. This is the'
    Add-Report '    strongest single signal that the DISM change for WSL2/VMP may not have actually'
    Add-Report '    finalized across the restart that was performed.)'

    $wuRebootRequired = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
    Add-Report "  WindowsUpdate\Auto Update\RebootRequired key exists: $wuRebootRequired"
    Add-Report '    (If True: Windows Update itself has a separate pending reboot outstanding right now --'
    Add-Report '    relevant to the "a different servicing operation consumed the restart" hypothesis.)'

    $pfro = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name 'PendingFileRenameOperations' -ErrorAction SilentlyContinue).PendingFileRenameOperations
    if ($pfro -and $pfro.Count -gt 0) {
        Add-Report "  PendingFileRenameOperations: PRESENT ($($pfro.Count) entries)"
        Add-Report '    First few entries:'
        $pfro | Select-Object -First 10 | ForEach-Object { Add-Report "      $_" }
    } else {
        Add-Report '  PendingFileRenameOperations: not present / empty'
    }
    Add-Report ''

    # --- 3. Recent hotfix / Windows Update history ---
    Add-Report '--- 3. Recent hotfix / Windows Update history ---'
    try {
        $hotfixes = Get-HotFix -ErrorAction Stop | Sort-Object InstalledOn -Descending | Select-Object -First 10
        if ($hotfixes) {
            Add-Report ($hotfixes | Format-Table -AutoSize HotFixID, Description, InstalledBy, InstalledOn | Out-String).Trim()
        } else {
            Add-Report '  Get-HotFix returned no entries.'
        }
    } catch {
        Add-Report "  Get-HotFix failed/not accessible: $($_.Exception.Message)"
    }
    Add-Report ''
    Add-Report '  Setup event log (last 20 events, if accessible):'
    try {
        $setupEvents = Get-WinEvent -LogName Setup -MaxEvents 20 -ErrorAction Stop
        if ($setupEvents) {
            Add-Report ($setupEvents | Select-Object TimeCreated, Id, LevelDisplayName, @{N = 'Message'; E = { ($_.Message -replace "`r?`n", ' ') } } | Format-Table -AutoSize -Wrap | Out-String).Trim()
        } else {
            Add-Report '  No events returned.'
        }
    } catch {
        Add-Report "  Get-WinEvent -LogName Setup failed/not accessible: $($_.Exception.Message)"
    }
    Add-Report ''

    # --- 4. DISM servicing log tail ---
    Add-Report '--- 4. DISM servicing log tail (C:\Windows\Logs\DISM\dism.log, last ~100 lines) ---'
    $dismLogPath = 'C:\Windows\Logs\DISM\dism.log'
    try {
        if (Test-Path $dismLogPath) {
            $tail = Get-Content -Path $dismLogPath -Tail 100 -ErrorAction Stop
            Add-Report ($tail -join "`n")
        } else {
            Add-Report "  $dismLogPath not found."
        }
    } catch {
        Add-Report "  Could not read $dismLogPath -- $($_.Exception.Message)"
    }
    Add-Report ''

    # --- 5. wsl --status / wsl --version ---
    Add-Report '--- 5. wsl --status / wsl --version ---'
    try {
        $wslStatusRaw = wsl --status 2>&1 | Out-String
        $wslStatus = Repair-WslOutput $wslStatusRaw
        Add-Report '  wsl --status:'
        Add-Report ($wslStatus -split "`r?`n" | ForEach-Object { "    $_" }) -join "`n"
    } catch {
        Add-Report "  wsl --status threw: $($_.Exception.Message)"
    }
    Add-Report ''
    try {
        $wslVersionRaw = wsl --version 2>&1 | Out-String
        $wslVersion = Repair-WslOutput $wslVersionRaw
        Add-Report '  wsl --version:'
        Add-Report ($wslVersion -split "`r?`n" | ForEach-Object { "    $_" }) -join "`n"
    } catch {
        Add-Report "  wsl --version threw: $($_.Exception.Message)"
    }
    Add-Report ''

    # --- 6. System uptime (informational cross-check, not an accusation) ---
    Add-Report '--- 6. System uptime ---'
    try {
        $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
        $lastBoot = $os.LastBootUpTime
        $uptime = (Get-Date) - $lastBoot
        Add-Report "  Last boot time: $lastBoot"
        Add-Report "  Time since last boot: $($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m"
        Add-Report '  (Informational only -- shows how long this machine has been up since its last boot,'
        Add-Report '  for cross-checking timing against the restart. Not a verification of anything.)'
    } catch {
        Add-Report "  Could not read Win32_OperatingSystem: $($_.Exception.Message)"
    }
    Add-Report ''

    Add-Report '--- End of diagnostic. No changes were made to this system. ---'
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
