# cl-shell

Custom shell prompt configuration using [Oh My Posh](https://ohmyposh.dev/) with Nerd Font icons, Terminal-Icons, and system info (CPU/RAM) in the prompt.

Works on **Windows** (PowerShell + Git Bash) and **Linux** (Zsh).

## What you get

- Minimal two-line prompt with path, git status, and docker context
- Clean path display (cyan) with git (orange) and docker (orange) indicators
- Colorized file/folder icons via [Terminal-Icons](https://github.com/devblackops/Terminal-Icons)
- CaskaydiaCove Nerd Font for glyph rendering
- **zsh-autosuggestions** for command autocompletion as you type (Linux)

## Quick install

Clone anywhere, run the installer, then delete the clone. The installer copies everything it needs to `~/.config/cli/`.

### Windows (PowerShell, elevated)

```powershell
git clone https://github.com/<user>/CLI-Theme.git ~/CLI-Theme
cd ~/CLI-Theme
.\install.ps1
cd ~
Remove-Item ~/CLI-Theme -Recurse -Force
```

### Linux (Zsh)

```bash
git clone https://github.com/<user>/CLI-Theme.git ~/CLI-Theme
cd ~/CLI-Theme
chmod +x install.sh && ./install.sh
cd ~ && rm -rf ~/CLI-Theme
```

## What the installer does (Linux)

1. Installs Zsh (if not present)
2. Installs Oh My Posh (via curl)
3. Installs the CaskaydiaCove Nerd Font
4. Installs zsh-autosuggestions plugin
5. Copies config files to `~/.config/cli/`
6. Configures `~/.zshrc` with Oh My Posh theme + autosuggestions
7. Sets Zsh as default shell

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
- Log out and back in (or run `zsh`) to start using the new shell
