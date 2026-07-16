# Copies a curated, read-only context bundle out of the live myPKA vault
# into a standalone LOCAL working folder, so a live Claude Code session
# running directly on this personal device ("Local Bastion") can diagnose
# and fix things interactively without ever opening the actual
# Google-Drive-synced myPKA folder as its own workspace.
#
# WHY: two live Claude Code sessions both treating the same Drive-synced
# folder as home base risk racing on shared files (session logs, INDEX
# files, Environment/Hosts docs) -- Drive sync has no real locking. This is
# a deliberate, STRUCTURAL fix, not a "please don't write there" convention:
# Local Bastion gets a COPY, never the live vault, so it physically cannot
# overwrite a shared file by accident. Its only path back to the shared
# vault is a deliberate act -- dropping a report in Team Inbox, exactly
# like every other script in this provisioning bundle.
#
# Genericized -- works on ANY of Jeff's personal Windows devices, present or
# future. Not hardcoded to any one machine name.
#
# Re-pulls fresh EVERY time it's run -- not a one-time static seed. The
# bundled Team/Team Knowledge/PKM subfolders are deleted and recreated from
# the current state of the source files on every run; anything else already
# sitting in the local working folder (e.g. Local Bastion's own scratch
# output from a prior session) is left untouched.
#
# Bundles:
#   1. Bastion's own contract:
#      Team/Bastion - Endpoint & Systems Administrator/AGENTS.md
#   2. Every Guideline (GL-NNN) that contract's own "## Cross-references"
#      section wikilinks to -- resolved DYNAMICALLY by parsing the contract
#      text itself at copy time, so this script can never drift out of sync
#      with Bastion's actual contract.
#   3. This machine's own Host doc, PKM/Environment/Hosts/<slug>.md --
#      matched first by an exact slug guess (lowercased COMPUTERNAME), then
#      by a content search across all Host docs for this machine's
#      COMPUTERNAME (handles cases like jeff-laptop, where COMPUTERNAME is
#      "LAPTOP-K2I9PS34" but the slug/filename is "jeff-laptop" -- the
#      COMPUTERNAME still appears inside that file's dns_name field). If
#      nothing matches, that is NOT an error -- the machine just isn't
#      registered in the Environment registry yet, and the bundle says so
#      plainly instead of failing.
#   4. A freshly (re)generated local-bastion-operating-guide.md -- the ONE
#      rule for whoever/whatever operates as Local Bastion in the
#      standalone session: everything produced gets written to Team Inbox
#      as a timestamped report, never directly into any live-synced myPKA
#      path.
#
# Destination: %USERPROFILE%\dev\<device-slug>-local-bastion\
# <device-slug> is the resolved Host-doc filename (no extension) if a match
# was found, otherwise the lowercased COMPUTERNAME.
#
# Called by local-bastion-bootstrap.bat, which passes -OutFile pointing at
# the timestamped report path (Team Inbox if myPKA is synced next to this
# script, otherwise next to the script itself).
#
# GIT-TRACKED COPY NOTE: this copy lives INSIDE myPKA\Scripts\, so its own
# myPKA root is resolved as the PARENT of this script's folder below, not
# a myPKA\ child of it like the Drive-root original.
param(
    [Parameter(Mandatory = $true)]
    [string]$OutFile
)

$ErrorActionPreference = 'Continue'
$report = @()
function Add-Report { param([string]$Line) $script:report += $Line }

# Explicit UTF-8, no BOM -- Windows PowerShell 5.1's default Tee-Object/
# Out-File encoding is UTF-16LE, which opens as garbled spaced-out text in
# plenty of tools. Still echoes to the console like Tee-Object did.
function Write-ReportFile {
    param([string[]]$Report, [string]$Path)
    $Report | ForEach-Object { Write-Host $_ }
    [System.IO.File]::WriteAllLines($Path, $Report, (New-Object System.Text.UTF8Encoding($false)))
}

try {
    Add-Report '=== Local Bastion Bootstrap ==='
    Add-Report "Machine: $env:COMPUTERNAME"
    Add-Report "User: $env:USERNAME"
    Add-Report "Captured: $(Get-Date)"
    Add-Report ''

    $scriptDir = $PSScriptRoot
    # This copy lives INSIDE myPKA\Scripts\, so myPKA root is this script's
    # PARENT folder -- not a myPKA\ child of it like the Drive-root original
    # (where this script sat beside the myPKA folder rather than inside it).
    $myPkaRoot = Split-Path -Parent $scriptDir

    if (-not (Test-Path $myPkaRoot)) {
        Add-Report "FAILED: myPKA root not found at the expected parent-folder location ($myPkaRoot)."
        Add-Report 'Nothing to bundle -- this script copies FROM the live synced vault, so Google Drive'
        Add-Report 'must be signed in and myPKA fully synced on this machine before this can run.'
        Add-Report 'Re-run this script once myPKA is confirmed synced.'
        Write-ReportFile -Report $report -Path $OutFile
        Write-Host ''
        Write-Host 'Bundle NOT created -- see report. Press Enter to close this window...'
        Read-Host | Out-Null
        exit 1
    }
    Add-Report "myPKA source found: $myPkaRoot"
    Add-Report ''

    # --- 1. Bastion's own contract ---
    $bastionRel = 'Team\Bastion - Endpoint & Systems Administrator\AGENTS.md'
    $bastionSrc = Join-Path $myPkaRoot $bastionRel
    if (-not (Test-Path $bastionSrc)) {
        Add-Report "FAILED: Bastion's contract not found at $bastionSrc -- cannot resolve its Guideline"
        Add-Report 'cross-references or build a meaningful bundle. Nothing was copied.'
        Write-ReportFile -Report $report -Path $OutFile
        Write-Host ''
        Write-Host 'Bundle NOT created -- see report. Press Enter to close this window...'
        Read-Host | Out-Null
        exit 1
    }
    $bastionContent = Get-Content -Path $bastionSrc -Raw
    Add-Report "Bastion contract found: $bastionSrc"

    # --- 2. Resolve Guidelines dynamically from Bastion's own Cross-references section ---
    Add-Report ''
    Add-Report '--- Resolving Guideline cross-references from Bastion''s own contract ---'
    $glNames = New-Object System.Collections.Generic.List[string]
    $crossRefSection = $bastionContent
    $sectionMatch = [regex]::Match($bastionContent, '(?ms)^##\s*Cross-references\s*$(.*?)(^##\s|\z)')
    if ($sectionMatch.Success) { $crossRefSection = $sectionMatch.Groups[1].Value }
    $glMatches = [regex]::Matches($crossRefSection, '\[\[(GL-\d{3}-[a-z0-9-]+)\]\]')
    foreach ($m in $glMatches) {
        $name = $m.Groups[1].Value
        if (-not $glNames.Contains($name)) { $glNames.Add($name) }
    }
    if ($glNames.Count -eq 0) {
        Add-Report '  No GL-NNN wikilinks found in the Cross-references section -- nothing to bundle here.'
    } else {
        Add-Report "  Found $($glNames.Count) Guideline reference(s): $($glNames -join ', ')"
    }

    # --- 3. Resolve this machine's Host doc ---
    Add-Report ''
    Add-Report '--- Resolving this machine''s Host doc ---'
    $hostsDir = Join-Path $myPkaRoot 'PKM\Environment\Hosts'
    $computerName = $env:COMPUTERNAME
    $slugGuess = $computerName.ToLower()
    $matchedHostFile = $null
    $matchMethod = $null

    $directMatch = Join-Path $hostsDir "$slugGuess.md"
    if (Test-Path $directMatch) {
        $matchedHostFile = $directMatch
        $matchMethod = "exact slug match on lowercased COMPUTERNAME ('$slugGuess.md')"
    } else {
        $candidates = Get-ChildItem -Path $hostsDir -Filter '*.md' -File -ErrorAction SilentlyContinue |
            Where-Object { (Select-String -Path $_.FullName -Pattern ([regex]::Escape($computerName)) -SimpleMatch -Quiet) }
        $candidates = @($candidates)
        if ($candidates.Count -eq 1) {
            $matchedHostFile = $candidates[0].FullName
            $matchMethod = "content match -- '$computerName' found inside $($candidates[0].Name)"
        } elseif ($candidates.Count -gt 1) {
            $matchedHostFile = $candidates[0].FullName
            $matchMethod = "AMBIGUOUS content match -- '$computerName' found in $($candidates.Count) Host docs ($(($candidates | ForEach-Object { $_.Name }) -join ', ')); used the first one. Verify by hand."
        }
    }

    $registered = $false
    $deviceSlug = $slugGuess
    if ($matchedHostFile) {
        $registered = $true
        $deviceSlug = [System.IO.Path]::GetFileNameWithoutExtension($matchedHostFile)
        Add-Report "  MATCHED: $matchedHostFile"
        Add-Report "  Method: $matchMethod"
    } else {
        Add-Report "  NOT REGISTERED: no Host doc found matching COMPUTERNAME '$computerName' (tried exact slug"
        Add-Report "  '$slugGuess.md' and a content search across all files in $hostsDir)."
        Add-Report '  This is expected for a brand-new machine -- not an error. Bastion should register this'
        Add-Report '  machine in PKM/Environment/Hosts/ from the live vault once its report comes back.'
    }
    Add-Report "  Device slug used for the local bundle folder: $deviceSlug"

    # --- 4. Build the destination bundle folder ---
    Add-Report ''
    Add-Report '--- Building local bundle folder ---'
    $bundleRoot = Join-Path $env:USERPROFILE "dev\$deviceSlug-local-bastion"
    Add-Report "  Destination: $bundleRoot"
    if (-not (Test-Path $bundleRoot)) {
        New-Item -ItemType Directory -Path $bundleRoot -Force | Out-Null
        Add-Report '  Created (first run on this machine).'
    } else {
        Add-Report '  Already exists -- refreshing bundled subfolders in place (re-pull, not a one-time seed).'
    }

    # Wipe only the bundled subfolders on every run so this is always a fresh
    # pull of current source state -- never touches anything else Local
    # Bastion may have left in this folder (its own scratch/working files).
    foreach ($sub in @('Team', 'Team Knowledge', 'PKM')) {
        $subPath = Join-Path $bundleRoot $sub
        if (Test-Path $subPath) { Remove-Item -Path $subPath -Recurse -Force -ErrorAction SilentlyContinue }
    }

    # Copy 1: Bastion's contract
    $bastionDest = Join-Path $bundleRoot $bastionRel
    New-Item -ItemType Directory -Path (Split-Path -Parent $bastionDest) -Force | Out-Null
    Copy-Item -Path $bastionSrc -Destination $bastionDest -Force
    Add-Report "  Copied: $bastionRel"

    # Copy 2: each resolved Guideline
    $glDestDir = Join-Path $bundleRoot 'Team Knowledge\Guidelines'
    if ($glNames.Count -gt 0) { New-Item -ItemType Directory -Path $glDestDir -Force | Out-Null }
    foreach ($name in $glNames) {
        $glSrc = Join-Path $myPkaRoot "Team Knowledge\Guidelines\$name.md"
        if (Test-Path $glSrc) {
            Copy-Item -Path $glSrc -Destination (Join-Path $glDestDir "$name.md") -Force
            Add-Report "  Copied: Team Knowledge\Guidelines\$name.md"
        } else {
            Add-Report "  WARNING: $name.md referenced by Bastion's contract but not found at $glSrc -- skipped."
        }
    }

    # Copy 3: this machine's Host doc, if matched
    if ($matchedHostFile) {
        $hostDestDir = Join-Path $bundleRoot 'PKM\Environment\Hosts'
        New-Item -ItemType Directory -Path $hostDestDir -Force | Out-Null
        $hostDestFile = Join-Path $hostDestDir ([System.IO.Path]::GetFileName($matchedHostFile))
        Copy-Item -Path $matchedHostFile -Destination $hostDestFile -Force
        Add-Report "  Copied: PKM\Environment\Hosts\$([System.IO.Path]::GetFileName($matchedHostFile))"
    }

    # --- 5. (Re)generate the operating guide ---
    Add-Report ''
    Add-Report '--- Generating local-bastion-operating-guide.md ---'
    $guidePath = Join-Path $bundleRoot 'local-bastion-operating-guide.md'

    $registeredLine = if ($registered) {
        "This machine IS registered in the Environment registry as $deviceSlug. Its Host doc is bundled at PKM\Environment\Hosts\$deviceSlug.md below -- read it before touching anything, per GL-008."
    } else {
        "This machine is NOT YET registered in the Environment registry (no Host doc matched COMPUTERNAME $computerName). No Host doc is bundled. Note this plainly in your report -- do not guess at or invent one; Bastion will register it from the live vault once the report comes back."
    }
    $bundledHostLine = if ($registered) {
        "- PKM\Environment\Hosts\$deviceSlug.md -- this machine's own registry entry, as of when this bundle was built. It may be stale by the time you read it if it changed on the live vault since -- treat it as a snapshot, not a live source."
    } else {
        '- (No Host doc bundled -- this machine is not yet registered. See above.)'
    }
    $teamInboxDisplayPath = Join-Path $myPkaRoot 'Team Inbox'
    $glListDisplay = if ($glNames.Count -gt 0) { ($glNames -join ', ') } else { '(none found)' }

    # Single-quoted here-string: no interpolation, so apostrophes/backticks/$
    # in the prose below are all literal -- no escaping needed anywhere in
    # this block. Dynamic values are substituted afterward via .Replace().
    $guideTemplate = @'
# Local Bastion -- Operating Guide

Generated: {{GENERATED}}
Device: {{COMPUTERNAME}}  (bundle slug: {{DEVICESLUG}})

## What this is

You are operating as **Local Bastion** -- a live, interactive session running directly
on this personal device, doing the endpoint-administration work that Bastion (myPKA's
Endpoint & Systems Administrator) owns, but running standalone rather than inside the
live myPKA vault. This folder is a read-only COPY of just the context you need -- never
the live vault itself.

## THE ONE RULE

> **Everything you produce in this session -- findings, diagnostics, fixes performed,**
> **proposed Host-doc updates, anything at all -- gets written to a single timestamped**
> **report and dropped in myPKA's Team Inbox. Never write directly to any path inside a**
> **live-synced myPKA folder, not even this machine's own Host doc, even when it feels**
> **obviously safe to touch directly. One integration path, no exceptions.**

Why: this device may have Google Drive syncing myPKA live in the background at the same
time a different Claude Code session has that same vault open elsewhere (e.g. on
jeff-laptop). Drive sync has no real file locking -- two live sessions both writing into
the same synced files (session logs, INDEX files, Environment/Hosts docs) can race and
corrupt each other. The fix is structural, not a promise: this session only ever has a
copy, so it cannot accidentally clobber a shared file. The ONLY sanctioned way anything
you find or do here reaches the shared vault is a human or a live-vault Claude Code
session reading your report afterward and filing it properly.

This applies even to changes that feel read-only-adjacent or "obviously fine" -- e.g.
updating this machine's own Host doc with a new driver version, or noting a patch was
applied. Write it in the report instead. Consistency is what keeps this guarantee simple
to reason about -- no judgment calls about which specific write might be safe enough.

## Report format

Filename: `YYYY-MM-DD_HHMMSS-<slug>.txt` (24-hour time, e.g.
`2026-07-15_223045-local-bastion-bridget-laptop-driver-fix.txt`) -- the exact convention
every script in this provisioning bundle already uses.

Where to write it:
- If Google Drive / myPKA is synced on this machine, write it directly into
  `<Google Drive root>\myPKA\Team Inbox\`. On this run, that resolved to:
  `{{TEAMINBOXPATH}}`
- If Team Inbox isn't there (Drive not signed in / not synced yet), write the report next
  to this bundle folder instead and say so clearly at the top of the report -- do not guess
  at a Team Inbox path that might not actually exist yet.

What to include: what you found, what you changed (and how, and any rollback info),
proposed updates to this machine's Host doc (OS version, installed software/driver
changes, patch status -- written as text for Bastion or Hawkeye to file, not as a direct
edit), any restore-test results if backups were touched, and anything you'd flag to Vex,
Pierce, Trapper, Sparky, or Relay per the scope boundaries in the bundled contract below.

{{REGISTEREDLINE}}

## What's bundled in this folder

- `Team\Bastion - Endpoint & Systems Administrator\AGENTS.md` -- Bastion's full contract.
  Follow its Method, Scope boundaries, and Task discipline sections exactly as written.
- `Team Knowledge\Guidelines\` -- every Guideline Bastion's contract itself cross-
  references ({{GLLIST}}). Read these before creating any new local state.
{{BUNDLEDHOSTLINE}}

## What Local Bastion must NOT do

- Never open, edit, or write to any path under the live Google-Drive-synced myPKA folder.
  This bundle folder is the only thing on disk you should be treating as "your" workspace.
- Never assume this bundle is current beyond the moment it was generated -- re-run
  `local-bastion-bootstrap.bat` (sitting next to this script's source at Google Drive
  root) to refresh it if you need the latest contract/Guideline/Host-doc text.
- Never invent a Host-doc filename or registry fact that isn't actually bundled here -- if
  something is missing (e.g. this machine isn't registered yet), say so in the report
  instead of guessing.

## Quick-start (paste this alongside your first message in a fresh session)

> You are operating as Local Bastion for this device. Read
> `local-bastion-operating-guide.md` in this folder first -- it has the one hard rule this
> session follows. Then read the bundled Bastion contract and Guidelines before doing
> anything. My task for you is: <describe the install/fix/diagnostic task here>.
'@

    $guideText = $guideTemplate.
        Replace('{{GENERATED}}', (Get-Date).ToString()).
        Replace('{{COMPUTERNAME}}', $computerName).
        Replace('{{DEVICESLUG}}', $deviceSlug).
        Replace('{{TEAMINBOXPATH}}', $teamInboxDisplayPath).
        Replace('{{REGISTEREDLINE}}', $registeredLine).
        Replace('{{GLLIST}}', $glListDisplay).
        Replace('{{BUNDLEDHOSTLINE}}', $bundledHostLine)

    # Explicit UTF-8, no BOM (see Write-ReportFile note above for why).
    [System.IO.File]::WriteAllText($guidePath, $guideText, (New-Object System.Text.UTF8Encoding($false)))
    Add-Report "  Wrote: local-bastion-operating-guide.md"

    Add-Report ''
    Add-Report '--- Result ---'
    Add-Report "Local Bastion bundle ready at: $bundleRoot"
    Add-Report 'Open a fresh Claude Code session with that folder as the working directory, paste the'
    Add-Report 'quick-start block from the bottom of local-bastion-operating-guide.md, and describe the task.'
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
