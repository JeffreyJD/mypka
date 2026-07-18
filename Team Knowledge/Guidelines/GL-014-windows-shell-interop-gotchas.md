# GL-014 - Windows Shell Interop Gotchas

> **Read this before any git commit, file edit, permission change, or toolchain invocation on a Windows machine where more than one shell (PowerShell, Git Bash/MSYS2, cmd.exe) is in play.** These are mechanical traps, not style preferences — get the fix wrong and the failure mode looks like something else entirely (a "broken" toolchain, a "corrupted" file, a "no-op" permission change), costing far more time diagnosing the wrong layer than the fix itself takes.

This Guideline exists because five separate shell-interop gotchas were independently discovered and separately journaled by different specialists on the same class of Windows dev machines. Consolidating them here means the next specialist who hits one of these `[[wikilink]]`s to the fix instead of rediscovering it from scratch.

## The five gotchas

### 1. PowerShell breaks heredoc / quoted multiline `git commit -m`

Quoted `-m` strings and heredoc syntax both fail in PowerShell for multiline commit messages — PowerShell's quoting rules don't preserve the string the way bash's do, and heredoc syntax isn't native to PowerShell at all.

**Fix:** use `git commit -F <tempfile>` instead. Write the message to a temp file, commit with `-F`, delete the temp file. Reliable across sessions. (Hit twice on the `davisglobe-vps-ash-1` workflow before this was documented — see [[Team/Pierce - Senior Developer/journal/2026-06-13-vps-and-git-patterns]].)

**When this does not apply:** bash sessions (heredocs work fine there), and single-line commit messages (quoted `-m` works for those in either shell).

### 2. `Get-Content` / `Set-Content` mojibake UTF-8 characters (em-dashes and other non-ASCII)

PowerShell's `Get-Content`/`Set-Content` cmdlets do not default to UTF-8 on every Windows/PowerShell version combination, so round-tripping a file containing an em-dash or other non-ASCII character through them can silently corrupt it into mojibake — the file looks fine in the terminal but the bytes are wrong.

**Fix:** avoid PowerShell cmdlets for editing files that already contain non-ASCII characters — prefer the harness's own file-read/file-write primitives, which handle encoding correctly. If a PowerShell cmdlet must be used, pin the encoding explicitly on both the read and the write (e.g. `-Encoding utf8` on `Get-Content`, and specifically `utf8NoBOM` on `Set-Content` if a BOM would break downstream parsing — a stray BOM is its own separate trap that silently breaks frontmatter parsing on any file it lands in). Never assume the cmdlet default matches what was written.

### 3. `chmod 600` silently no-ops on NTFS via Git Bash

Git Bash's `chmod` is a POSIX-emulation shim over NTFS ACLs. On NTFS, `chmod 600 <file>` frequently reports success but does not actually restrict the file's permissions the way it would on a real POSIX filesystem — the underlying ACL model is completely different, and Git Bash's translation layer doesn't reliably enforce it.

**Fix:** use `icacls` directly for any Windows-side permission restriction that actually matters (e.g. a credential file, a private key). Example: `icacls <file> /inheritance:r /grant:r "%USERNAME%":F` to strip inherited permissions and grant only the current user full control. Verify with `icacls <file>` afterward — don't trust `chmod`'s exit code as proof the restriction took effect on NTFS.

### 4. `MSYSTEM=MINGW64` inherited from Git Bash breaks ESP-IDF / PlatformIO builds — even via child PowerShell/cmd processes

ESP-IDF's own `idf_tools.py` explicitly detects and refuses to run under an MSYS/MinGW shell. If the parent process is Git Bash (which exports `MSYSTEM=MINGW64`), that environment variable is inherited by child PowerShell/cmd processes spawned from within it — confirmed via `powershell -Command '$env:MSYSTEM'` still showing `MINGW64` when launched from a Git Bash parent. Spawning a "clean" PowerShell child does not clear it.

**Fix:** explicitly strip the variable before invoking the build — `Remove-Item Env:\MSYSTEM` in the PowerShell child process before running `esphome compile` (or any other ESP-IDF/PlatformIO-backed command). Note: invoking `cmd.exe /c` directly from a Git-Bash-parented automated shell has been observed to silently no-op (returns only the cmd banner, no command execution, even for batch files) in this environment — PowerShell with the explicit `Remove-Item Env:\MSYSTEM` step is the reliable path, not cmd.exe. See [[Team/Relay - Smart Home & IoT Engineer/journal/2026-07-13-esphome-windows-msys-and-longpath-gotchas]] for the full incident, including a secondary corrupted-PlatformIO-package-cache failure this triggered.

**When this does not apply:** a human running `esphome` (or other ESP-IDF/PlatformIO) commands from a normal, directly-opened PowerShell or Command Prompt window — `MSYSTEM` is never set there, so this never triggers. It is purely an artifact of a Git-Bash-parented automated shell chain.

### 5. PowerShell here-string syntax (`@'...'@`) leaks literal `@` lines when pasted into bash

PowerShell's here-string delimiters (`@'` to open, `'@` to close, on their own lines) are frequently drafted or copy-pasted across a session that mixes PowerShell and bash. When that literal text is pasted into a bash context, bash does not recognize the `@'...'@` syntax at all — the `@'` and `'@` lines get interpreted as literal garbage or a syntax error, not as string delimiters, because there is no here-string construct in bash to receive them.

**Fix:** never draft a multiline string in PowerShell here-string syntax with the intent of pasting it into bash (or vice versa with bash heredoc syntax pasted into PowerShell). Pick the target shell's native multiline construct up front (bash heredoc `<<'EOF' ... EOF`, or PowerShell here-string `@'...'@`), and if the string needs to move between shells, write it to a temp file in one shell and read it from the other rather than pasting shell-specific syntax across the boundary.

## Why this Guideline exists (the shape of the underlying problem)

All five gotchas share one root cause: **Windows dev/ops work on this fleet routinely crosses shell boundaries** — PowerShell, Git Bash/MSYS2, and cmd.exe are all in play, sometimes within a single automated session, sometimes as parent/child processes. Each shell has its own quoting rules, encoding defaults, permission model, and environment-inheritance behavior, and none of them fail loudly when the assumption breaks — they fail by producing a *plausible-looking* wrong result (a mangled commit message, a mojibake string, a permission that "succeeded," a build tool that "doesn't support" a shell it never should have seen, a paste that "looks like a syntax error somewhere else"). That failure shape is exactly why these were each independently rediscovered rather than caught by a single obvious error message — and exactly why they belong in one shared Guideline instead of five separate journal entries nobody but the original discoverer reads.

## When in doubt

If a Windows-side operation involves more than one shell (directly, or via a parent/child process relationship), or touches file encoding, file permissions, or environment-variable inheritance — check this Guideline before assuming the first shell's semantics carry through unchanged.

## Updates to this Guideline

- 2026-07-18 — created (Bastion), consolidating five independently-journaled Windows/shell-interop gotchas per [[WS-004-team-retro-and-self-improvement-loop]] Tier 2 retro proposal 4 (approved by Jeff 2026-07-18). Source evidence: [[Team/Pierce - Senior Developer/journal/2026-06-13-vps-and-git-patterns]] (gotchas 1) and [[Team/Relay - Smart Home & IoT Engineer/journal/2026-07-13-esphome-windows-msys-and-longpath-gotchas]] (gotcha 4); gotchas 2, 3, and 5 consolidated from team-wide retro discussion of recurring session friction not yet individually journaled.

## References

- [[GL-001-file-naming-conventions]]
- [[GL-005-llm-agnostic-portable-core]] — this Guideline names shells (PowerShell, Git Bash, cmd.exe) as OS-level facts, not agent-harness brands; it stays portable-core-safe.
- [[Team/Pierce - Senior Developer/AGENTS]]
- [[Team/Relay - Smart Home & IoT Engineer/AGENTS]]
- [[Team/Bastion - Endpoint & Systems Administrator/AGENTS]]
