# start-cockpit.ps1 — myPKA Cockpit launcher (Windows). Generated locally from
# launcher/templates/windows.ps1.txt — review before use.
$ErrorActionPreference = "Stop"

# --- config -------------------------------------------------------------------
$Port = if ($env:PORT) { $env:PORT } else { "4317" }
# $env:MYPKA_ROOT = "C:\absolute\path\to\your\myPKA"   # only for a non-standard layout

# --- 1. resolve the cockpit dir and cd into it --------------------------------
$CockpitDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $CockpitDir

# Resolve the scaffold-root mypka.db the server will open (three levels up in the
# standard layout; honor MYPKA_ROOT for a non-standard one).
if ($env:MYPKA_ROOT) {
  $DbPath = Join-Path $env:MYPKA_ROOT "mypka.db"
} else {
  $DbPath = Join-Path (Resolve-Path (Join-Path $CockpitDir "..\..")).Path "mypka.db"
}

# --- helper: is Python 3 + PyYAML usable? ------------------------------------
function Test-Python {
  param([string]$Exe)
  try { & $Exe -c "import yaml" 2>$null; return ($LASTEXITCODE -eq 0) } catch { return $false }
}
$Python = $null
foreach ($cand in @("python", "py")) {
  if (Get-Command $cand -ErrorAction SilentlyContinue) {
    $probe = if ($cand -eq "py") { "py -3" } else { $cand }
    if (Test-Python $cand) { $Python = $probe; break }
  }
}

# --- helper: does mypka.db exist AND carry the core `journal` table? ----------
function Test-DbCore {
  param([string]$Path)
  if (-not (Test-Path $Path)) { return $false }
  if (-not $Python) { return $true }
  $probe = @"
import os, sqlite3, sys
p = sys.argv[1]
if not os.path.isfile(p): sys.exit(1)
try:
    c = sqlite3.connect('file:%s?mode=ro' % p, uri=True)
    sys.exit(0 if c.execute("SELECT 1 FROM sqlite_master WHERE type='table' AND name='journal'").fetchone() else 1)
except sqlite3.Error:
    sys.exit(1)
"@
  $tmp = [System.IO.Path]::GetTempFileName() + ".py"
  Set-Content -Path $tmp -Value $probe -Encoding ASCII
  try { & cmd /c "$Python `"$tmp`" `"$Path`"" ; return ($LASTEXITCODE -eq 0) }
  finally { Remove-Item $tmp -ErrorAction SilentlyContinue }
}

# --- 2. ensure mypka.db exists ------------------------------------------------
if (Test-DbCore $DbPath) {
  if ($Python) {
    Write-Host "Refreshing mypka.db from your markdown (non-destructive)..."
    try { $env:PYTHONIOENCODING = "utf-8"; $env:PYTHONUTF8 = "1"; & cmd /c "$Python `"scripts\regen-mypka-db.py`"" } catch { Write-Host "  (regen failed -- using existing mypka.db)" }
  } else {
    Write-Host "Python 3 + PyYAML not found -- skipping DB refresh (existing mypka.db will serve)."
    Write-Host "  To enable refreshes: install Python 3, then  pip install --user pyyaml"
  }
} else {
  Write-Host "No mypka.db yet -- creating it (core schema + all cockpit modules)..."
  if (-not $Python) {
    Write-Host ""
    Write-Host "  Cannot create mypka.db: Python 3 with the PyYAML package is required."
    Write-Host "  Install them, then re-run me:"
    Write-Host ""
    Write-Host "      * Python 3:  https://www.python.org/downloads/  (check 'Add to PATH')"
    Write-Host "      * PyYAML:    pip install --user pyyaml"
    Write-Host ""
    Read-Host "Press Enter to close"
    exit 1
  }
  $env:PYTHONIOENCODING = "utf-8"; $env:PYTHONUTF8 = "1"
  & cmd /c "$Python `"sqlite-extension\install-extensions.py`" `"$DbPath`" --all"
  if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "  Could not create mypka.db. Fix the issue above, then re-run me."
    Read-Host "Press Enter to close"
    exit 1
  }
}

# --- 3. first-run install + build (skipped on later launches) -----------------
if (-not (Test-Path "node_modules"))     { Write-Host "Installing server deps..."; npm install --no-audit --no-fund }
if (-not (Test-Path "web\node_modules")) { Write-Host "Installing web deps...";    npm --prefix web install --no-audit --no-fund }
if (-not (Test-Path "web\dist"))         { Write-Host "Building the web app...";   npm --prefix web run build }

# --- 4. free the port ---------------------------------------------------------
try {
  $owners = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction Stop |
            Select-Object -ExpandProperty OwningProcess -Unique
  foreach ($procId in $owners) {
    Write-Host "Port $Port busy -- stopping PID $procId..."
    Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue
  }
} catch {
  $lines = netstat -ano | Select-String ":$Port\s.*LISTENING"
  foreach ($line in $lines) {
    $procId = ($line -split "\s+")[-1]
    if ($procId -match '^\d+$') {
      Write-Host "Port $Port busy -- stopping PID $procId..."
      taskkill /PID $procId /F 2>$null | Out-Null
    }
  }
}
Start-Sleep -Seconds 1

# --- 5. open the browser ------------------------------------------------------
Start-Process "http://127.0.0.1:$Port/"

# --- 6. start the server, loopback-only ---------------------------------------
Write-Host "Starting the cockpit on http://127.0.0.1:$Port/  (close this window to stop it)"
$env:NODE_ENV = "production"
$env:PORT = $Port
$env:WORKBENCH_WRITE_ENABLED = "1"
$env:PLAN_WRITE_ENABLED = "1"
node server\server.js
