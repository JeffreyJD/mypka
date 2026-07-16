# Sweeps stranded provisioning-bundle report files out of Google Drive
# root and copies them into myPKA's Team Inbox, once Team Inbox is
# confirmed synced on this machine.
#
# Why this exists: ai-stack-install.bat/.ps1 (and any future script in
# this bundle that adopts the same graceful-fallback pattern) writes its
# timestamped report straight into myPKA's Team Inbox when myPKA is found
# synced next to it, but falls back to writing the report next to itself
# (Google Drive root) instead of hard-erroring when myPKA hasn't finished
# syncing on this machine yet. That keeps the install script from failing,
# but it can strand a report at Google Drive root instead of where Jeff
# actually looks for it. Run this script later, once Google Drive/myPKA
# IS confirmed synced, to sweep any such stranded reports into Team Inbox.
#
# Match pattern: files directly in this script's own folder (Google Drive
# root) whose name matches this bundle's own timestamped report naming
# convention -- "YYYY-MM-DD_HHMMSS-<slug>.txt" (e.g.
# "2026-07-15_180412-ai-stack-install.txt"), the exact format every script
# in this bundle produces via `Get-Date -Format yyyy-MM-dd_HHmmss` +
# "-<slug>.txt". Deliberately narrow -- this will NOT sweep up unrelated
# pre-existing personal .txt files at Google Drive root (e.g. "Jeff
# Notes.txt", "Florida Trip.txt", "Boat Buffing Notes.txt") since none of
# those carry the leading timestamp prefix.
#
# Copy, not move -- originals are left in place at Google Drive root so
# there is no data-loss risk if anything goes wrong. Skips a file if an
# identically-named copy already exists in Team Inbox (idempotent, safe
# to re-run).
#
# GIT-TRACKED COPY NOTE: the Drive-root original used $PSScriptRoot for
# TWO different jobs that happened to be the same folder by coincidence of
# where it lived: (1) the folder to scan for stranded .txt reports, and
# (2) the base from which to find myPKA\Team Inbox. This copy lives INSIDE
# myPKA\Scripts\, so those two jobs now resolve to different folders and
# are split out explicitly below: $scanRoot stays anchored to Google Drive
# root (two levels up -- Scripts\..\.. -- since that is where the OTHER
# scripts' graceful-fallback logic actually strands reports, not wherever
# this particular copy happens to sit), while $teamInbox resolves to the
# myPKA\Team Inbox that is now this copy's own parent-level sibling.

$ErrorActionPreference = 'Continue'

$scriptDir = $PSScriptRoot
$myPkaRoot = Split-Path -Parent $scriptDir
$scanRoot = Split-Path -Parent $myPkaRoot
$teamInbox = Join-Path $myPkaRoot 'Team Inbox'

Write-Host '============================================================'
Write-Host ' Sync Stranded Reports to Team Inbox'
Write-Host '============================================================'
Write-Host ''

if (-not (Test-Path $teamInbox)) {
    Write-Host 'myPKA Team Inbox not found relative to this script -- nothing to sync.'
    Write-Host "Expected to find: $teamInbox"
    Write-Host 'Re-run this script once myPKA has finished syncing on this machine.'
    exit 0
}

Write-Host "Team Inbox found: $teamInbox"
Write-Host "Scanning for stranded reports at Google Drive root: $scanRoot"
Write-Host ''

$pattern = '^\d{4}-\d{2}-\d{2}_\d{6}-.+\.txt$'
$candidates = Get-ChildItem -Path $scanRoot -File -Filter '*.txt' -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match $pattern }

if (-not $candidates -or @($candidates).Count -eq 0) {
    Write-Host 'No stranded report files found at Google Drive root matching this bundle''s'
    Write-Host 'timestamped report naming convention (YYYY-MM-DD_HHMMSS-<slug>.txt).'
    Write-Host 'Nothing to sync.'
    exit 0
}

$candidates = @($candidates)
Write-Host "Found $($candidates.Count) candidate report file(s) at Google Drive root:"
foreach ($c in $candidates) { Write-Host "  $($c.Name)" }
Write-Host ''

$copied = 0
$skipped = 0
foreach ($file in $candidates) {
    $dest = Join-Path $teamInbox $file.Name
    if (Test-Path $dest) {
        Write-Host "SKIPPED (already exists in Team Inbox): $($file.Name)"
        $skipped++
    } else {
        try {
            Copy-Item -Path $file.FullName -Destination $dest -ErrorAction Stop
            Write-Host "COPIED: $($file.Name) -> Team Inbox"
            $copied++
        } catch {
            Write-Host "FAILED to copy $($file.Name): $($_.Exception.Message)"
        }
    }
}

Write-Host ''
Write-Host '============================================================'
Write-Host " DONE. Copied: $copied   Skipped (already present): $skipped   Matched: $($candidates.Count)"
Write-Host ' Originals left in place at Google Drive root (copy, not move) --'
Write-Host ' delete them yourself once you confirm the copies landed OK.'
Write-Host '============================================================'
