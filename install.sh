#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────
# cl-shell installer – Linux (Bash)
# Installs Oh My Posh, a Nerd Font, and configures ~/.bashrc
# Usage:  chmod +x install.sh && ./install.sh
# ─────────────────────────────────────────────────────────────────────────
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DEST="$HOME/.config/powershell"
FONT_DIR="$HOME/.local/share/fonts"

info()  { printf '\033[1;36m[%s]\033[0m %s\n' "$1" "$2"; }
ok()    { printf '\033[1;32m      %s\033[0m\n' "$1"; }
warn()  { printf '\033[1;33m      %s\033[0m\n' "$1"; }

# ── 1. Install Oh My Posh ──────────────────────────────────────────────
info "1/4" "Installing Oh My Posh ..."
if command -v oh-my-posh &> /dev/null; then
    warn "Oh My Posh already installed ($(oh-my-posh version))."
else
    curl -s https://ohmyposh.dev/install.sh | bash -s
    ok "Oh My Posh installed."
fi

# ── 2. Install Nerd Font (CaskaydiaCove / Cascadia Code) ───────────────
info "2/4" "Installing CaskaydiaCove Nerd Font ..."
mkdir -p "$FONT_DIR"
if ls "$FONT_DIR"/CaskaydiaCove* &> /dev/null 2>&1; then
    warn "CaskaydiaCove Nerd Font already present."
else
    TMP_DIR="$(mktemp -d)"
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip"
    curl -fsSL "$FONT_URL" -o "$TMP_DIR/CascadiaCode.zip"
    unzip -qo "$TMP_DIR/CascadiaCode.zip" -d "$FONT_DIR"
    rm -rf "$TMP_DIR"
    if command -v fc-cache &> /dev/null; then
        fc-cache -f "$FONT_DIR"
    fi
    ok "Nerd Font installed to $FONT_DIR."
fi

# ── 3. Copy config files ───────────────────────────────────────────────
info "3/4" "Copying config files to $CONFIG_DEST ..."
if [ "$REPO_DIR" != "$CONFIG_DEST" ]; then
    mkdir -p "$CONFIG_DEST/colorThemes"
    cp -f "$REPO_DIR/.cl-shell.omp.json"              "$CONFIG_DEST/"
    cp -f "$REPO_DIR/user_profile.ps1"                     "$CONFIG_DEST/"
    cp -f "$REPO_DIR/colorThemes/"*.psd1                   "$CONFIG_DEST/colorThemes/"
    ok "Files copied."
else
    warn "Already running from target directory, skipping copy."
fi

# ── 4. Configure ~/.bashrc ─────────────────────────────────────────────
info "4/4" "Configuring ~/.bashrc ..."
MARKER="# Oh My Posh prompt (added by cl-shell installer)"
if [ -f "$HOME/.bashrc" ] && grep -qF "cl-shell installer" "$HOME/.bashrc"; then
    warn "~/.bashrc already configured."
else
    cat >> "$HOME/.bashrc" << 'BASH_BLOCK'

# Oh My Posh prompt (added by cl-shell installer)
if command -v oh-my-posh &> /dev/null; then
    eval "$(oh-my-posh init bash --config ~/.config/powershell/.cl-shell.omp.json)"
fi
BASH_BLOCK
    ok "~/.bashrc updated."
fi

# ── Done ────────────────────────────────────────────────────────────────
printf '\n\033[1;32m--- Installation complete! ---\033[0m\n'
echo "  * Set your terminal font to 'CaskaydiaCove Nerd Font'."
echo "  * Run:  source ~/.bashrc   (or open a new terminal)"
echo ""
