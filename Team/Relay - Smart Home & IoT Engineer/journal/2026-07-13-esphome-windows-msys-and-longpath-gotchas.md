---
agent_id: relay
type: journal-entry
created: 2026-07-13T20:50:00Z
updated: 2026-07-13T20:50:00Z
topic: esphome-windows-toolchain
tags: [esphome, windows, platformio, esp-idf, toolchain]
linked_session_logs: []
linked_tasks: []
related_journal_entries: []
status: durable
---

# ESPHome compiles fail on Windows when invoked from a Git-Bash/MSYS shell — use PowerShell or cmd instead.

## Context
First ESPHome toolchain install + compile test for [[pool-monitor-automation]] on jeff-laptop (Windows 11). `esphome compile` failed twice with `ERROR: MSys/Mingw is not supported` before succeeding on the third attempt.

## What I learned
ESP-IDF's own `idf_tools.py` explicitly detects and refuses to run under an MSYS/MinGW shell. Claude Code's Bash tool runs Git Bash, which exports `MSYSTEM=MINGW64` — and that variable is inherited even by child PowerShell/cmd processes spawned from within it (confirmed: `powershell -Command '$env:MSYSTEM'` still showed `MINGW64` when launched from Git Bash). The fix is to explicitly strip it before invoking esphome: a PowerShell script that runs `Remove-Item Env:\MSYSTEM` before `& esphome.exe compile ...` works cleanly. `cmd.exe /c` invoked directly from this Bash tool did NOT work at all in this environment — it silently returned only the cmd banner with no command execution (batch files included); PowerShell was the reliable path.

Separately: a first compile attempt run from a deeply-nested path (Claude's own scratch temp directory, ~260 chars deep) failed installing the `libsodium` dependency with `WinError 206` (filename too long) / `WinError 3` (path not found) — Windows `LongPathsEnabled` is `0` on this machine. That failure also silently corrupted the global PlatformIO package cache (`~/.platformio/packages/tool-cmake` and `tool-ninja` were left with only metadata files, no actual binaries) which then caused a *second*, different-looking failure (`FileNotFoundError` trying to invoke `cmake`) on retry — the real cause was upstream corruption, not the CMake step itself. Fix: delete the corrupted package folders under `~/.platformio/packages/` and let PlatformIO redownload cleanly.

## When this applies
- Running `esphome compile` / `esphome run` / `esphome flash` (or any PlatformIO/ESP-IDF-backed build) on Windows from an automated tool whose shell is Git Bash/MSYS2 (e.g. Claude Code's Bash tool).
- Diagnosing a PlatformIO build failure that seems to point at a missing/broken tool (cmake, ninja, etc.) right after a prior run failed partway through a package install — check for corrupted `~/.platformio/packages/<tool>` first (often just metadata files, no binary) before assuming a real toolchain bug.
- Any Windows-side ESPHome work being run/tested from a deeply nested path (temp directories, long usernames, deeply nested project folders) — verify path length against 260 chars for the deepest dependency subpath (libsodium's `crypto_sign_edwards25519sha512batch.h` and similar files are among the longest observed) before trusting a "path too long" failure means the *project's own* location is unsafe.

## When this does NOT apply
- Jeff (or any human) running `esphome` commands from a normal PowerShell or Command Prompt window directly — `MSYSTEM` is never set there, so the MSYS block never triggers. This is purely an artifact of automated/Bash-tool-driven runs, not normal interactive use.
- Linux/Mac hosts — the MSYS check and Windows `MAX_PATH` limit are Windows-only concerns.
- Once `LongPathsEnabled` is turned on machine-wide (registry, needs admin) — the path-length half of this stops being a live risk, though it's still good practice to keep build paths short.

## Evidence
- [[esphome-cli]] — full detail on both gotchas and the working fix, plus the successful build result (RAM 14.6%, Flash 21.0%) that confirmed the workaround.
- [[pool-monitor-automation]] — 2026-07-13 status update.
