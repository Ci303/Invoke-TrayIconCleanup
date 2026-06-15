# Invoke-TrayIconCleanup.ps1

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?logo=powershell)
![Last Commit](https://img.shields.io/github/last-commit/Ci303/Invoke-TrayIconCleanup?label=last%20commit)
![License](https://img.shields.io/github/license/Ci303/Invoke-TrayIconCleanup)
![Issues](https://img.shields.io/github/issues/Ci303/Invoke-TrayIconCleanup?label=open%20issues)

## Purpose

Interactively review and remove unresolved tray-icon entries from the current user notification-area registry settings.

## What it does

- Reads `HKCU:\Control Panel\NotifyIconSettings`.
- Resolves environment variables and known-folder GUID prefixes.
- Excludes `\WindowsApps\` entries from cleanup.
- Shows unresolved entries for user review before deletion.
- Optionally exports a registry backup to desktop.
- Requires explicit confirmation (`REMOVE`) before deleting entries.
- Optionally restarts Explorer to refresh the tray.

## Requirements

- Windows PowerShell 5.1+.
- Write access to `HKCU:\Control Panel\NotifyIconSettings`.

## Usage

```powershell
cd "C:\Users\noswi\Desktop\Scripts\Invoke-TrayIconCleanup"
.\Invoke-TrayIconCleanup.ps1
```

## Output

- Candidate list with `Key`, `Name`, and `ResolvedPath` before deletion.
- Backup file path when backup is enabled.

## Troubleshooting

- No candidates shown: no unresolved entries were detected.
- Deletion is skipped unless you type exactly `REMOVE`.
- If tray icons do not refresh, sign out/in or restart Explorer manually.

## Safety

This operation is destructive. Keep the `.reg` backup until you verify results.

## Support and contribution

- Issues and feature requests: [GitHub Issues](https://github.com/Ci303/Invoke-TrayIconCleanup/issues)
- Security concerns: [SECURITY.md](./SECURITY.md)
- Contribution guidelines: [CONTRIBUTING.md](./CONTRIBUTING.md)
## Repository policy

- Submit changes via a pull request from a feature branch to `master`.
- Do not edit files directly on the default branch in normal workflow.
- This keeps review, traceability and rollback procedures explicit.
