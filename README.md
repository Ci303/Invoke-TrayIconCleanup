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
- Excludes Microsoft Store app entries (`\\WindowsApps\\`) from cleanup.
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

## What happens during a run

1. Scan unresolved entries.
2. Prompt for backup creation.
3. Show candidate entries with registry key/name/path.
4. Require explicit deletion confirmation.
5. Optionally restart Explorer.

## Backup

By default, backup is written to your desktop as:

```text
NotifyIconSettings-backup-YYYYMMDD-HHMMSS.reg
```

Restore with:

```powershell
reg import "$env:USERPROFILE\\Desktop\\NotifyIconSettings-backup-YYYYMMDD-HHMMSS.reg"
```

## Notes

Use on non-critical systems first. Keep the `.reg` backup until cleanup is confirmed.

## Troubleshooting

- No candidates shown: no unresolved entries were detected.
- Deletion is skipped unless you type exactly `REMOVE`.
- If tray icons do not refresh, sign out/in or restart Explorer manually.

## Support and contribution

- Issues and feature requests: [GitHub Issues](https://github.com/Ci303/Invoke-TrayIconCleanup/issues)
- Security concerns: [SECURITY.md](./SECURITY.md)
- Contribution guidelines: [CONTRIBUTING.md](./CONTRIBUTING.md)
