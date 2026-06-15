<#
.SYNOPSIS
Interactively reviews and removes unresolved Windows notification-area / system-tray icon entries.

.DESCRIPTION
This script checks:

HKCU:\Control Panel\NotifyIconSettings

It finds tray-icon entries where the stored executable path cannot be resolved to
an existing file.

It:
- Resolves common Windows known-folder GUID paths.
- Expands environment variables.
- Extracts executable paths from command-line style entries.
- Skips Microsoft Store / WindowsApps packaged apps.
- Shows a review table before doing anything destructive.
- Prompts whether to create a registry backup.
- Prompts again before removal.
- Prompts whether to restart Explorer afterwards.
#>

$ErrorActionPreference = 'Stop'

$trayKey = 'HKCU:\Control Panel\NotifyIconSettings'
$trayRegExportPath = 'HKCU\Control Panel\NotifyIconSettings'

$knownFolders = @{
    '{6D809377-6AF0-444B-8957-A3773F02200E}' = $env:ProgramFiles
    '{7C5A40EF-A0FB-4BFC-874A-C0F2E0B9FA8E}' = ${env:ProgramFiles(x86)}
    '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}' = "$env:WINDIR\System32"
    '{F38BF404-1D43-42F2-9305-67DE0B28FC23}' = $env:WINDIR
    '{F1B32785-6FBA-4FCF-9D55-7B8E7F157091}' = $env:LOCALAPPDATA
    '{3EB685DB-65F9-4CF6-A03A-E3EF65729F3D}' = $env:APPDATA
}

function Resolve-TrayPath {
    param(
        [string]$Path
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $null
    }

    $resolved = [Environment]::ExpandEnvironmentVariables($Path.Trim())

    foreach ($folder in $knownFolders.GetEnumerator()) {
        if (
            $folder.Value -and
            $resolved.StartsWith($folder.Key, [System.StringComparison]::OrdinalIgnoreCase)
        ) {
            $resolved = $folder.Value + $resolved.Substring($folder.Key.Length)
            break
        }
    }

    if ($resolved -match '^"([^"]+\.exe)"') {
        return $matches[1]
    }

    if ($resolved -match '^([A-Za-z]:\\.+?\.exe)(?:\s|$)') {
        return $matches[1]
    }

    return $resolved
}

function Get-OptionalProperty {
    param(
        [object]$Object,
        [string[]]$Names
    )

    foreach ($name in $Names) {
        $property = $Object.PSObject.Properties[$name]
        if ($property -and -not [string]::IsNullOrWhiteSpace([string]$property.Value)) {
            return [string]$property.Value
        }
    }

    return $null
}

if (-not (Test-Path -LiteralPath $trayKey)) {
    Write-Host "Tray icon registry key not found:"
    Write-Host $trayKey
    exit 0
}

$candidates = Get-ChildItem -LiteralPath $trayKey | ForEach-Object {
    $item = Get-ItemProperty -LiteralPath $_.PSPath
    $rawPath = $item.ExecutablePath
    $resolvedPath = Resolve-TrayPath $rawPath

    $isUnresolved =
    $resolvedPath `
        -and $resolvedPath -match '^[A-Za-z]:\\' `
        -and $resolvedPath -notlike '*\WindowsApps\*' `
        -and -not (Test-Path -LiteralPath $resolvedPath)

    if ($isUnresolved) {
        [pscustomobject]@{
            Key          = $_.PSChildName
            Name         = Get-OptionalProperty -Object $item -Names @(
                'InitialTooltip',
                'Tooltip',
                'DisplayName',
                'ApplicationName'
            )
            ResolvedPath = $resolvedPath
            RawPath      = $rawPath
            RegistryPath = $_.PSPath
        }
    }
}

if (-not $candidates) {
    Write-Host ""
    Write-Host "No unresolved tray icon entries found."
    exit 0
}

Write-Host ""
Write-Host "Unresolved tray icon entries found:"
Write-Host ""

$candidates |
Select-Object Key, Name, ResolvedPath |
Format-Table -AutoSize

Write-Host ""
Write-Host "These entries point to executable paths that do not currently exist."
Write-Host "Microsoft Store / WindowsApps entries have been excluded."
Write-Host ""

$backupChoice = Read-Host "Create a registry backup before removal? [Y/n]"

$backupCreated = $false
$backupPath = $null

if ($backupChoice -notmatch '^(n|no)$') {
    $desktop = [Environment]::GetFolderPath('Desktop')
    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backupPath = Join-Path $desktop "NotifyIconSettings-backup-$timestamp.reg"

    reg export $trayRegExportPath $backupPath /y | Out-Null

    $backupCreated = $true

    Write-Host ""
    Write-Host "Backup created:"
    Write-Host $backupPath
}
else {
    Write-Host ""
    Write-Host "Backup skipped."
}

Write-Host ""
Write-Host "Entries selected for removal:"
Write-Host ""

$candidates |
Select-Object Key, Name, ResolvedPath |
Format-Table -AutoSize

Write-Host ""
$removeChoice = Read-Host "Remove these unresolved tray icon entries now? Type REMOVE to continue"

if ($removeChoice -ne 'REMOVE') {
    Write-Host ""
    Write-Host "Removal cancelled. No registry entries were deleted."
    exit 0
}

foreach ($candidate in $candidates) {
    Remove-Item -LiteralPath $candidate.RegistryPath -Recurse -Force
}

Write-Host ""
Write-Host "Removed $($candidates.Count) unresolved tray icon entr$(if ($candidates.Count -eq 1) { 'y' } else { 'ies' })."

if ($backupCreated) {
    Write-Host ""
    Write-Host "Backup location:"
    Write-Host $backupPath
}

Write-Host ""
$restartChoice = Read-Host "Restart Explorer now to refresh the system tray list? [y/N]"

if ($restartChoice -match '^(y|yes)$') {
    Stop-Process -Name explorer -Force
    Start-Process explorer

    Write-Host ""
    Write-Host "Explorer restarted."
}
else {
    Write-Host ""
    Write-Host "Explorer was not restarted. The list may not visually refresh until Explorer is restarted or the user signs out and back in."
}