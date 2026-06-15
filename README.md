# Invoke-TrayIconCleanup.ps1

Interactive script to review and remove unresolved Windows tray icon registry entries from the user hive.

## Overview

The script checks `HKCU:\Control Panel\NotifyIconSettings` for tray icon entries whose executable path cannot be resolved, then prompts before making changes.

It will:

- Expand environment variables and known-folder GUID references
- Parse command-line style paths to extract executable paths
- Skip Microsoft Store packaged entries under `\WindowsApps\`
- Show a review table of unresolved entries
- Optionally create a `.reg` backup
- Remove selected entries only when explicitly confirmed
- Optionally restart Explorer to refresh tray icons

## Requirements

- PowerShell 5.1+
- User registry access to `HKCU:\Control Panel\NotifyIconSettings`

## Usage

```powershell
cd "C:\Users\noswi\Desktop\Scripts\Invoke-TrayIconCleanup"
.\Invoke-TrayIconCleanup.ps1
```

## Interactive flow

1. Detect unresolved entries.
2. Show a list with registry key, icon name, and resolved path.
3. Ask whether to create a registry backup.
4. Ask for explicit confirmation (`REMOVE`) before deleting entries.
5. Optionally restart Explorer.

## Backup

If enabled, the script exports the target registry key to your Desktop as:

- `NotifyIconSettings-backup-YYYYMMDD-HHMMSS.reg`

## Destructive action warning

This script removes registry keys. Do not run unattended unless you understand the impact and have a backup available. Use the review output and keep the `.reg` backup until you are happy with the result.
