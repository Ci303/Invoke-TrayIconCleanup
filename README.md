# Invoke-TrayIconCleanup.ps1

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?logo=powershell)
![Last Commit](https://img.shields.io/github/last-commit/Ci303/Invoke-TrayIconCleanup?label=last%20commit)
![License](https://img.shields.io/github/license/Ci303/Invoke-TrayIconCleanup)

## Purpose

`Invoke-TrayIconCleanup.ps1` is an interactive cleanup utility that removes unresolved tray-icon registry entries under the current user profile, after review and explicit confirmation.

## What it does

- Reads `HKCU:\Control Panel\NotifyIconSettings`
- Finds unresolved entries by resolving environment variables and known-folder GUIDs
- Skips packaged app entries in `\WindowsApps\`
- Shows a review table of candidate entries
- Optionally exports `HKCU\Control Panel\NotifyIconSettings` to a timestamped backup `.reg`
- Deletes only entries confirmed by the user
- Optionally restarts Explorer to refresh the tray UI

## Requirements

- Windows PowerShell 5.1+
- Registry access to `HKCU:\Control Panel\NotifyIconSettings`
- Optional: desktop access for backup file creation

## Usage

```powershell
cd "C:\Users\noswi\Desktop\Scripts\Invoke-TrayIconCleanup"
.\Invoke-TrayIconCleanup.ps1
```

## Interactive flow

1. Script scans and lists unresolved entries.
2. Prompts for backup creation.
3. Shows final removal list.
4. Requires typing `REMOVE` to proceed.
5. Optionally restarts Explorer.

## Backup and restore

If enabled, backup location is:

```text
%USERPROFILE%\Desktop\NotifyIconSettings-backup-YYYYMMDD-HHMMSS.reg
```

Restore manually if needed with:

```powershell
reg import "%USERPROFILE%\Desktop\NotifyIconSettings-backup-YYYYMMDD-HHMMDD.reg"
```

## Risk note

This is a destructive operation (registry deletion). Keep the backup until you confirm no adverse effects.

## Troubleshooting

- **No candidates listed:** no unresolved entries were detected.
- **Not removed:** type must be exactly `REMOVE` (uppercase) to continue.
- **No visible tray change:** Explorer may need sign-out/sign-in or manual restart.

