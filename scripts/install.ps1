[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$TargetProject = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

$packageRoot = Split-Path -Parent $PSScriptRoot
$sourceSkill = [System.IO.Path]::GetFullPath(
    (Join-Path $packageRoot ".agents/skills/note-taker-skill")
)

if (-not (Test-Path -LiteralPath (Join-Path $sourceSkill "SKILL.md") -PathType Leaf)) {
    throw "Canonical skill not found at $sourceSkill"
}

$targetRoot = [System.IO.Path]::GetFullPath($TargetProject)
[System.IO.Directory]::CreateDirectory($targetRoot) | Out-Null

function Install-SkillCopy {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Destination
    )

    $destinationPath = [System.IO.Path]::GetFullPath($Destination)

    if ($sourceSkill -eq $destinationPath) {
        Write-Host "Using canonical skill at $destinationPath"
        return
    }

    if (Test-Path -LiteralPath $destinationPath) {
        Remove-Item -LiteralPath $destinationPath -Recurse -Force
    }
    [System.IO.Directory]::CreateDirectory($destinationPath) | Out-Null
    Get-ChildItem -LiteralPath $sourceSkill -Force |
        Copy-Item -Destination $destinationPath -Recurse -Force
    Write-Host "Installed skill at $destinationPath"
}

# Cursor and Codex both discover the open-standard .agents location.
Install-SkillCopy -Destination (
    Join-Path $targetRoot ".agents/skills/note-taker-skill"
)

# Claude uses its native project skill location.
Install-SkillCopy -Destination (
    Join-Path $targetRoot ".claude/skills/note-taker-skill"
)

Write-Host "note-taker-skill installation complete."
