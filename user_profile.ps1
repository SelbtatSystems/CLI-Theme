$env:POWERSHELL_UPDATECHECK = 'Off'

# Resolve paths dynamically based on this script's location
$configDir = $PSScriptRoot
if (-not $configDir) { $configDir = Join-Path $env:USERPROFILE '.config\powershell' }

# Terminal Icons (https://github.com/devblackops/Terminal-Icons)
Import-Module -Name Terminal-Icons
Get-ChildItem -Path (Join-Path $configDir 'colorThemes\devblackops.psd1') | Add-TerminalIconsColorTheme -Force

# Oh My Posh prompt
oh-my-posh init pwsh --config (Join-Path $configDir '.cl-shell.omp.json') | Invoke-Expression

# Aliases
Set-Alias ll ls
Set-Alias g git
Set-Alias grep findstr

# Clear startup noise (banner + profile load time)
Clear-Host