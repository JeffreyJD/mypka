# OPTIONAL, standalone script -- NOT part of the 01/02 auto-chain.
# Enables Windows auto-login so Docker Desktop + Home Assistant come back
# up unattended after a reboot (Windows Update, power blip, etc.), on
# whichever laptop is hosting the pool-monitor HA sandbox.
#
# This stores your Windows password in the registry in PLAIN TEXT
# (HKLM\...\Winlogon\DefaultPassword). That is a real security tradeoff on
# a laptop -- this script will not do it without an explicit Y confirmation
# typed at the prompt below. If you skip this, a reboot will just require
# you to log in manually before the HA stack comes back up on its own.
param(
    [Parameter(Mandatory = $true)]
    [string]$OutFile
)

# Windows PowerShell 5.1's default Tee-Object/Out-File encoding is UTF-16LE
# (with BOM), which opens as garbled spaced-out text in plenty of tools.
# Write explicit UTF-8 with no BOM instead, while still echoing to the
# console like Tee-Object did.
function Write-ReportFile {
    param([string[]]$Report, [string]$Path)
    $Report | ForEach-Object { Write-Host $_ }
    [System.IO.File]::WriteAllLines($Path, $Report, (New-Object System.Text.UTF8Encoding($false)))
}

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"", '-OutFile', "`"$OutFile`"")
    Start-Process powershell -ArgumentList $argList -Verb RunAs -Wait
    exit
}

Write-Host ''
Write-Host '============================================================'
Write-Host ' Windows Auto-Login Setup'
Write-Host '============================================================'
Write-Host ''
Write-Host 'This stores your Windows account password in the registry in'
Write-Host 'PLAIN TEXT so Windows can log in automatically after a reboot,'
Write-Host 'without anyone physically at the keyboard.'
Write-Host ''
Write-Host 'If you say no: a reboot (Windows Update, power blip) will'
Write-Host 'require you to log in manually before Docker/HA come back up.'
Write-Host ''
$confirm = Read-Host 'Enable auto-login? Type Y to proceed, anything else to skip'

$report = @()
$report += '=== Pool Monitor HA Sandbox Optional: Windows Auto-Login ==='
$report += "Machine: $env:COMPUTERNAME"
$report += "Captured: $(Get-Date)"
$report += ''

if ($confirm -match '^[Yy]$') {
    $username = Read-Host "Windows username to auto-login as [$env:USERNAME]"
    if ([string]::IsNullOrWhiteSpace($username)) { $username = $env:USERNAME }

    Write-Host ''
    Write-Host 'IMPORTANT: enter your REAL Windows account password below --'
    Write-Host 'your Microsoft account online password, or your local account'
    Write-Host 'password. This is NOT the Windows Hello PIN you use to unlock'
    Write-Host 'this laptop day-to-day. The PIN is a separate, device-local'
    Write-Host "credential (tied to this machine's TPM) and will NOT work here."
    Write-Host 'If you enter your PIN by mistake, auto-login will silently fail'
    Write-Host 'after reboot -- Windows will just show the normal sign-in screen'
    Write-Host 'with no error explaining why.'
    Write-Host ''
    $securePassword = Read-Host 'Password for that account' -AsSecureString
    $plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword))

    if ($plainPassword.Length -ge 4 -and $plainPassword.Length -le 8 -and $plainPassword -match '^\d+$') {
        Write-Host ''
        Write-Host 'WARNING: the value you entered is short and all-digits --'
        Write-Host 'this looks like it might be a Windows Hello PIN, not your'
        Write-Host 'account password. Auto-login will fail silently if so.'
        Write-Host ''
        $pinConfirm = Read-Host 'Proceed anyway with this value? Type Y to proceed, anything else to abort'
        if ($pinConfirm -notmatch '^[Yy]$') {
            $report += 'DECISION: ABORTED -- entered value matched the PIN-like heuristic (short, all-digits) and user declined to confirm.'
            $report += '(Password value itself is deliberately NOT included in this report.)'
            $plainPassword = $null
            Write-ReportFile -Report $report -Path $OutFile
            Write-Host ''
            Write-Host 'Aborted -- no changes made.'
            exit
        }
        $report += 'NOTE: entered value matched the PIN-like heuristic (short, all-digits); user confirmed to proceed anyway.'
    }

    try {
        $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
        Set-ItemProperty -Path $regPath -Name 'AutoAdminLogon' -Value '1'
        Set-ItemProperty -Path $regPath -Name 'DefaultUsername' -Value $username
        Set-ItemProperty -Path $regPath -Name 'DefaultPassword' -Value $plainPassword
        Set-ItemProperty -Path $regPath -Name 'DefaultDomainName' -Value $env:COMPUTERNAME

        $report += "DECISION: ENABLED, for user '$username'."
        $report += '(Password value itself is deliberately NOT included in this report.)'
        Write-Host ''
        Write-Host 'Auto-login enabled.'
    } catch {
        $report += "FAILED to enable: $($_.Exception.Message)"
        Write-Host "Failed: $($_.Exception.Message)"
    } finally {
        $plainPassword = $null
    }
} else {
    $report += 'DECISION: SKIPPED, per user choice at the prompt.'
    $report += 'A reboot will require manual login before Docker/HA restart.'
    Write-Host ''
    Write-Host 'Skipped -- no changes made.'
}

Write-ReportFile -Report $report -Path $OutFile
