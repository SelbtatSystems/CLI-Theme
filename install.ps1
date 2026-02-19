#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Installs Oh My Posh, Nerd Fonts, Terminal-Icons and wires up
    PowerShell + Git Bash on Windows.
.USAGE
    Run from an elevated PowerShell prompt:
        .\install.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoDir = $PSScriptRoot
$configDest = Join-Path $env:USERPROFILE '.config\powershell'

# ── 1. Install Oh My Posh ──────────────────────────────────────────────
Write-Host "`n[1/5] Installing Oh My Posh ..." -ForegroundColor Cyan
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    Write-Host "      Oh My Posh already installed, upgrading ..." -ForegroundColor Yellow
    winget upgrade JanDeDobbeleer.OhMyPosh -s winget --accept-source-agreements --accept-package-agreements
} else {
    winget install JanDeDobbeleer.OhMyPosh -s winget --accept-source-agreements --accept-package-agreements
}
# Refresh PATH so oh-my-posh is available in this session
$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
            [System.Environment]::GetEnvironmentVariable('Path', 'User')

# ── 2. Install a Nerd Font (CaskaydiaCove / Cascadia Code NF) ──────────
Write-Host "`n[2/5] Installing Nerd Font (CaskaydiaCove) ..." -ForegroundColor Cyan
oh-my-posh font install CascadiaCode

# ── 3. Install Terminal-Icons PowerShell module ─────────────────────────
Write-Host "`n[3/5] Installing Terminal-Icons module ..." -ForegroundColor Cyan
if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) {
    Install-Module -Name Terminal-Icons -Repository PSGallery -Scope CurrentUser -Force
} else {
    Write-Host "      Terminal-Icons already installed." -ForegroundColor Yellow
}

# ── 4. Copy config files ───────────────────────────────────────────────
Write-Host "`n[4/5] Copying config files to $configDest ..." -ForegroundColor Cyan
if ($repoDir -ne $configDest) {
    New-Item -ItemType Directory -Path $configDest -Force | Out-Null
    Copy-Item -Path (Join-Path $repoDir '.cl-shell.omp.json') -Destination $configDest -Force
    Copy-Item -Path (Join-Path $repoDir 'user_profile.ps1')       -Destination $configDest -Force
    Copy-Item -Path (Join-Path $repoDir 'colorThemes')            -Destination $configDest -Recurse -Force
    Write-Host "      Files copied." -ForegroundColor Green
} else {
    Write-Host "      Already running from target directory, skipping copy." -ForegroundColor Yellow
}

# ── 5. Wire up shell profiles ──────────────────────────────────────────
Write-Host "`n[5/5] Configuring shell profiles ..." -ForegroundColor Cyan

# ── PowerShell profile ──
$psProfileDir  = Split-Path $PROFILE -Parent
$psProfileFile = $PROFILE
New-Item -ItemType Directory -Path $psProfileDir -Force | Out-Null

$sourceLine = '. "$env:USERPROFILE\.config\powershell\user_profile.ps1"'
if (Test-Path $psProfileFile) {
    $content = Get-Content $psProfileFile -Raw
    if ($content -notmatch [regex]::Escape($sourceLine)) {
        Add-Content -Path $psProfileFile -Value "`n$sourceLine"
        Write-Host "      PowerShell profile updated: $psProfileFile" -ForegroundColor Green
    } else {
        Write-Host "      PowerShell profile already configured." -ForegroundColor Yellow
    }
} else {
    Set-Content -Path $psProfileFile -Value $sourceLine
    Write-Host "      PowerShell profile created: $psProfileFile" -ForegroundColor Green
}

# ── Git Bash profile ──
$bashrc = Join-Path $env:USERPROFILE '.bashrc'
$ompThemePath = '~/.config/powershell/.cl-shell.omp.json'
$bashBlock = @"

# Oh My Posh prompt (added by cl-shell installer)
if command -v oh-my-posh &> /dev/null; then
    eval "`$(oh-my-posh init bash --config '$ompThemePath')"
fi
"@

if (Test-Path $bashrc) {
    $existing = Get-Content $bashrc -Raw
    if ($existing -notmatch 'cl-shell installer') {
        Add-Content -Path $bashrc -Value $bashBlock
        Write-Host "      Git Bash .bashrc updated." -ForegroundColor Green
    } else {
        Write-Host "      Git Bash .bashrc already configured." -ForegroundColor Yellow
    }
} else {
    Set-Content -Path $bashrc -Value $bashBlock
    Write-Host "      Git Bash .bashrc created." -ForegroundColor Green
}

# ── VS Code terminal font ──
$vscodeSettings = Join-Path $env:APPDATA 'Code\User\settings.json'
if (Test-Path $vscodeSettings) {
    $json = Get-Content $vscodeSettings -Raw
    if ($json -notmatch 'terminal\.integrated\.fontFamily') {
        $json = $json.TrimEnd() -replace '\}\s*$', ",`n    `"terminal.integrated.fontFamily`": `"CaskaydiaCove Nerd Font`"`n}"
        Set-Content -Path $vscodeSettings -Value $json -NoNewline
        Write-Host "      VS Code terminal font configured." -ForegroundColor Green
    } else {
        Write-Host "      VS Code terminal font already set." -ForegroundColor Yellow
    }
} else {
    Write-Host "      VS Code settings not found, skipping." -ForegroundColor Yellow
}

# ── Windows Terminal -NoLogo ──
$wtSettings = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
if (Test-Path $wtSettings) {
    $wtJson = Get-Content $wtSettings -Raw
    if ($wtJson -match 'powershell\.exe"' -and $wtJson -notmatch 'powershell\.exe -NoLogo') {
        $wtJson = $wtJson -replace 'powershell\.exe"', 'powershell.exe -NoLogo"'
        Set-Content -Path $wtSettings -Value $wtJson -NoNewline
        Write-Host "      Windows Terminal -NoLogo added." -ForegroundColor Green
    } else {
        Write-Host "      Windows Terminal already configured." -ForegroundColor Yellow
    }
}

# ── Done ────────────────────────────────────────────────────────────────
Write-Host "`n--- Installation complete! ---" -ForegroundColor Green
Write-Host "  * Restart your terminals to see the new prompt."
Write-Host ""
