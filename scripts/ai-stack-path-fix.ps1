# Diagnoses (and auto-fixes) the "claude is not recognized" PATH issue.
# Works on any of Jeff's Windows personal computers. Called by
# ai-stack-path-fix.bat, which passes -OutFile pointing at the timestamped
# report path in Team Inbox.
#
# Hardened to cover: duplicate/shadowing PATH entries, Machine vs User
# PATH precedence, stale-Explorer-cache (via WM_SETTINGCHANGE broadcast
# so a fresh terminal picks up the fix without logoff), alternate install
# locations (npm-global, in case a prior attempt used a different method),
# PATH length limits, and non-PATH failure modes (blocked/quarantined exe).
param(
    [Parameter(Mandatory = $true)]
    [string]$OutFile
)

$ErrorActionPreference = 'Continue'
$report = @()

function Add-Report {
    param([string]$Line)
    $script:report += $Line
}

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
    $bin = Join-Path $env:USERPROFILE '.local\bin'
    $npmGlobal = Join-Path $env:APPDATA 'npm'

    Add-Report '=== Claude Code PATH Diagnosis ==='
    Add-Report "Machine: $env:COMPUTERNAME"
    Add-Report "User: $env:USERNAME"
    Add-Report "Captured: $(Get-Date)"
    Add-Report ''

    # --- Step 1: install folder contents ---
    Add-Report '--- Step 1: Does the install folder exist, and what is in it? ---'
    Add-Report "Expected folder: $bin"
    $binExists = Test-Path $bin
    if ($binExists) {
        $files = Get-ChildItem $bin -File -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
        if ($files) {
            Add-Report ($files | ForEach-Object { "  found: $_" } | Out-String).TrimEnd()
        } else {
            Add-Report '  (folder exists but is EMPTY)'
        }
    } else {
        Add-Report '  FOLDER DOES NOT EXIST -- install did not complete. Re-run ai-stack-install.bat.'
    }
    # Alternate location check, in case an earlier attempt used npm instead
    # of the native installer -- this would create a SECOND claude shim that
    # can shadow or conflict with the native one depending on PATH order.
    if (Test-Path (Join-Path $npmGlobal 'claude.cmd')) {
        Add-Report "  NOTE: an npm-global claude.cmd also exists at $npmGlobal -- two installs can conflict."
    }
    Add-Report ''

    # --- Step 2: current session PATH ---
    Add-Report '--- Step 2: Is the folder in THIS session PATH? ---'
    $sessionEntries = $env:Path -split ';' | Where-Object { $_ }
    $sessionHit = $sessionEntries | Where-Object { $_.TrimEnd('\') -ieq $bin.TrimEnd('\') }
    if ($sessionHit) {
        Add-Report "  YES: $sessionHit"
    } else {
        Add-Report '  NOT in this session PATH'
    }
    Add-Report ''

    # --- Step 3: persisted User + Machine PATH, with dedupe and shadow check ---
    Add-Report '--- Step 3: Is the folder in the persisted PATH (registry), and is anything shadowing it? ---'
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $userEntries = @($userPath -split ';' | Where-Object { $_ })
    $machineEntries = @($machinePath -split ';' | Where-Object { $_ })

    $userHit = $userEntries | Where-Object { $_.TrimEnd('\') -ieq $bin.TrimEnd('\') }
    $machineHit = $machineEntries | Where-Object { $_.TrimEnd('\') -ieq $bin.TrimEnd('\') }

    if ($userHit) { Add-Report "  User PATH:    YES ($($userHit.Count) match(es))" } else { Add-Report '  User PATH:    NOT PRESENT' }
    if ($machineHit) { Add-Report "  Machine PATH: YES ($($machineHit.Count) match(es))" } else { Add-Report '  Machine PATH: not present (expected -- native installer uses User scope)' }

    # Duplicate-entry check (harmless but worth flagging/cleaning)
    $dupCount = ($userEntries | Where-Object { $_.TrimEnd('\') -ieq $bin.TrimEnd('\') } | Measure-Object).Count
    if ($dupCount -gt 1) {
        Add-Report "  NOTE: $dupCount duplicate entries for this folder in User PATH -- will dedupe during fix."
    }

    # Shadow check: does something EARLIER in the effective PATH (Machine
    # entries come first on Windows, then User) also provide a claude.exe /
    # claude.cmd that would win the name resolution instead of ours?
    $effectiveOrder = @($machineEntries) + @($userEntries)
    $ourIndex = -1
    for ($i = 0; $i -lt $effectiveOrder.Count; $i++) {
        if ($effectiveOrder[$i].TrimEnd('\') -ieq $bin.TrimEnd('\')) { $ourIndex = $i; break }
    }
    $shadow = $null
    if ($ourIndex -gt 0) {
        for ($i = 0; $i -lt $ourIndex; $i++) {
            $candidate = $effectiveOrder[$i]
            foreach ($name in @('claude.exe', 'claude.cmd', 'claude')) {
                $p = Join-Path $candidate $name
                if (Test-Path $p -ErrorAction SilentlyContinue) { $shadow = $p; break }
            }
            if ($shadow) { break }
        }
    }
    if ($shadow) {
        Add-Report "  WARNING: '$shadow' appears EARLIER in PATH and will shadow the real install."
    }

    # PATH length sanity check (registry practical limit is ~2047 chars)
    $totalLen = ("$machinePath;$userPath").Length
    if ($totalLen -gt 1800) {
        Add-Report "  WARNING: effective PATH is $totalLen chars, approaching the ~2047 char practical limit."
    }
    Add-Report ''

    # --- Auto-fix ---
    $fixed = $false
    $needsFix = (-not $userHit) -or ($dupCount -gt 1)
    if ($needsFix -and $binExists) {
        Add-Report '--- Auto-fix: rebuilding User PATH (add missing entry, drop duplicates) ---'
        $cleaned = @()
        foreach ($e in $userEntries) {
            if ($e.TrimEnd('\') -ieq $bin.TrimEnd('\')) { continue }  # drop existing copies, re-add once below
            $cleaned += $e
        }
        $cleaned += $bin
        $newPath = ($cleaned -join ';')
        [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')

        Add-Report "  Set User PATH to $($cleaned.Count) entries (added/deduped: $bin)"
        $verify = [Environment]::GetEnvironmentVariable('Path', 'User')
        $verifyHit = ($verify -split ';') | Where-Object { $_.TrimEnd('\') -ieq $bin.TrimEnd('\') }
        if ($verifyHit) {
            Add-Report '  CONFIRMED written to registry.'
            $fixed = $true
        } else {
            Add-Report '  FAILED to verify write -- manual fix needed (Edit environment variables for your account).'
        }

        # Broadcast WM_SETTINGCHANGE so Explorer refreshes its cached user
        # environment block immediately -- without this, a "new" terminal
        # launched from Explorer (Win+R, taskbar, Start menu) can still
        # inherit the OLD environment until logoff/logon, because Explorer
        # itself never re-reads the registry unless told to.
        try {
            Add-Type -Namespace Win32 -Name NativeMethods -MemberDefinition @'
[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam, uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
'@ -ErrorAction Stop
            $HWND_BROADCAST = [IntPtr]0xffff
            $WM_SETTINGCHANGE = 0x1a
            $result = [UIntPtr]::Zero
            [Win32.NativeMethods]::SendMessageTimeout($HWND_BROADCAST, $WM_SETTINGCHANGE, [UIntPtr]::Zero, 'Environment', 2, 5000, [ref]$result) | Out-Null
            Add-Report '  Broadcast WM_SETTINGCHANGE -- Explorer should now see the update without logoff.'
        } catch {
            Add-Report "  (Broadcast step skipped: $($_.Exception.Message) -- fresh terminal should still pick it up.)"
        }
    } elseif ($userHit -and $binExists) {
        Add-Report '--- Auto-fix: not needed, registry already correct ---'
        Add-Report '  If claude still fails, this is a stale-terminal or shadowing problem (see Step 3 warnings above).'
    } else {
        Add-Report '--- Auto-fix: skipped, install folder does not exist ---'
    }
    Add-Report ''

    # --- Step 4: sanity-check by invoking the binary directly ---
    Add-Report '--- Step 4: Sanity-check by invoking the binary directly (bypasses PATH entirely) ---'
    $exe = Join-Path $bin 'claude.exe'
    $cmdShim = Join-Path $bin 'claude.cmd'
    $target = if (Test-Path $exe) { $exe } elseif (Test-Path $cmdShim) { $cmdShim } else { $null }
    if ($target) {
        try {
            $ver = & $target --version 2>&1
            $exitCode = $LASTEXITCODE
            Add-Report "  $target --version => $ver (exit code $exitCode)"
            if ($exitCode -ne 0) {
                Add-Report '  Binary exists but did NOT run cleanly -- may be blocked by antivirus/SmartScreen rather than a PATH problem.'
                Add-Report '  Check: right-click the exe > Properties > if there is an "Unblock" checkbox near the bottom, check it and Apply.'
            }
        } catch {
            Add-Report "  Invocation THREW an error: $($_.Exception.Message)"
            Add-Report '  This points to a blocked/quarantined file, not a PATH issue -- check Windows Defender/antivirus history.'
        }
    } else {
        Add-Report '  No claude.exe or claude.cmd found to test -- see Step 1 file listing above.'
    }
    Add-Report ''

    # --- Result ---
    Add-Report '--- Result ---'
    if ($fixed) {
        Add-Report 'PATH was missing the entry (or had duplicates) -- it has been rebuilt and verified.'
        Add-Report 'NEXT STEP: close ALL open terminal/PowerShell windows, then press Win+R,'
        Add-Report 'type cmd, Enter. In that brand-new window, type: claude'
        Add-Report '(The environment-change broadcast above means you likely do NOT need to log off.)'
    } elseif ($shadow) {
        Add-Report 'PATH has the right entry, but another claude executable earlier in PATH is shadowing it (see WARNING above).'
        Add-Report 'NEXT STEP: either remove/rename the shadowing file, or move this entry earlier in PATH via'
        Add-Report '"Edit environment variables for your account".'
    } elseif ($userHit -and $binExists) {
        Add-Report 'PATH already had the entry -- the problem (if any) is a stale terminal session.'
        Add-Report 'NEXT STEP: close ALL open terminal/PowerShell windows, then press Win+R,'
        Add-Report 'type cmd, Enter. In that brand-new window, type: claude'
    } else {
        Add-Report 'Install folder is missing or empty -- PATH is not the problem.'
        Add-Report 'NEXT STEP: re-run ai-stack-install.bat and'
        Add-Report 'watch for errors during the install step itself.'
    }
} catch {
    Add-Report ''
    Add-Report '--- SCRIPT ERROR (partial report above is still valid) ---'
    Add-Report $_.Exception.Message
    Add-Report $_.ScriptStackTrace
} finally {
    Write-ReportFile -Report $report -Path $OutFile
}
