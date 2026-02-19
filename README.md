# cl-shell

Custom shell prompt configuration using [Oh My Posh](https://ohmyposh.dev/) with Nerd Font icons, Terminal-Icons, and system info (CPU/RAM) in the prompt.

Works on **Windows** (PowerShell + Git Bash) and **Linux** (Bash).

## What you get

- Multi-line prompt with username, day/time, and git status
- Right-aligned CPU and RAM usage
- Full path display with folder icons
- Colorized file/folder icons via [Terminal-Icons](https://github.com/devblackops/Terminal-Icons)
- CaskaydiaCove Nerd Font for glyph rendering

## Quick install

Clone anywhere, run the installer, then delete the clone. The installer copies everything it needs to `~/.config/powershell/`.

### Windows (PowerShell, elevated)

```powershell
git clone https://github.com/<user>/CLI-Theme.git ~/CLI-Theme
cd ~/CLI-Theme
.\install.ps1
cd ~
Remove-Item ~/CLI-Theme -Recurse -Force
```

### Linux (Bash)

```bash
git clone https://github.com/<user>/CLI-Theme.git ~/CLI-Theme
cd ~/CLI-Theme
chmod +x install.sh && ./install.sh
cd ~ && rm -rf ~/CLI-Theme
```

## What the installer does

1. Installs Oh My Posh (via `winget` on Windows, curl on Linux)
2. Installs the CaskaydiaCove Nerd Font
3. Installs the Terminal-Icons PowerShell module (Windows only)
4. Copies config files to `~/.config/powershell/`
5. Wires up shell profiles (PowerShell `$PROFILE`, `~/.bashrc`, VS Code terminal font)

## Files

| File | Purpose |
|------|---------|
| `.cl-shell.omp.json` | Oh My Posh theme |
| `user_profile.ps1` | PowerShell profile (imports modules, sets aliases) |
| `colorThemes/` | Terminal-Icons color themes |
| `install.ps1` | Windows installer |
| `install.sh` | Linux installer |

## Post-install

- Set your terminal font to **CaskaydiaCove Nerd Font** (the installer handles VS Code and Windows Terminal automatically on Windows)
- Restart your terminal or run `source ~/.bashrc` / `. $PROFILE`
