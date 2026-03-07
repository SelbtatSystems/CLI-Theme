#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────
# cl-shell installer – Linux (Zsh)
# Installs Zsh, Oh My Posh, fzf, tmux, a Nerd Font, and writes configs
# Usage:  chmod +x install.sh && ./install.sh
# ─────────────────────────────────────────────────────────────────────────
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DEST="$HOME/.config/cli"
FONT_DIR="$HOME/.local/share/fonts"
STEPS=9

info()  { printf '\033[1;36m[%s]\033[0m %s\n' "$1" "$2"; }
ok()    { printf '\033[1;32m      %s\033[0m\n' "$1"; }
warn()  { printf '\033[1;33m      %s\033[0m\n' "$1"; }

# ── 1. Install Zsh ──────────────────────────────────────────────────────
info "1/$STEPS" "Installing Zsh ..."
if command -v zsh &> /dev/null; then
    warn "Zsh already installed ($(zsh --version))."
else
    if command -v apt-get &> /dev/null; then
        sudo apt-get update -qq && sudo apt-get install -y -qq zsh
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y zsh
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm zsh
    else
        echo "ERROR: Could not detect package manager. Install zsh manually." >&2
        exit 1
    fi
    ok "Zsh installed."
fi

# ── 2. Install Oh My Posh ──────────────────────────────────────────────
info "2/$STEPS" "Installing Oh My Posh ..."
if command -v oh-my-posh &> /dev/null; then
    warn "Oh My Posh already installed ($(oh-my-posh version))."
else
    curl -s https://ohmyposh.dev/install.sh | bash -s
    ok "Oh My Posh installed."
fi

# ── 3. Install fzf ─────────────────────────────────────────────────────
info "3/$STEPS" "Installing fzf ..."
if command -v fzf &> /dev/null; then
    warn "fzf already installed ($(fzf --version | head -1))."
else
    if command -v apt-get &> /dev/null; then
        sudo apt-get install -y -qq fzf
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y fzf
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm fzf
    else
        echo "ERROR: Could not detect package manager. Install fzf manually." >&2
        exit 1
    fi
    ok "fzf installed."
fi

# ── 4. Install tmux ─────────────────────────────────────────────────────
info "4/$STEPS" "Installing tmux ..."
if command -v tmux &> /dev/null; then
    warn "tmux already installed ($(tmux -V))."
else
    if command -v apt-get &> /dev/null; then
        sudo apt-get install -y -qq tmux
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y tmux
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm tmux
    else
        echo "ERROR: Could not detect package manager. Install tmux manually." >&2
        exit 1
    fi
    ok "tmux installed."
fi

# ── 5. Install eza ────────────────────────────────────────────────────
info "5/$STEPS" "Installing eza ..."
if command -v eza &> /dev/null; then
    warn "eza already installed."
else
    if command -v apt-get &> /dev/null; then
        sudo apt-get install -y -qq eza 2>/dev/null || {
            sudo mkdir -p /etc/apt/keyrings
            wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
            echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null
            sudo apt-get update -qq && sudo apt-get install -y -qq eza
        }
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y eza
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm eza
    else
        warn "Could not install eza automatically. Install manually: https://github.com/eza-community/eza"
    fi
    command -v eza &> /dev/null && ok "eza installed."
fi

# ── 6. Install Nerd Font (CaskaydiaCove / Cascadia Code) ───────────────
info "6/$STEPS" "Installing CaskaydiaCove Nerd Font ..."
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

# ── 7. Copy config files ───────────────────────────────────────────────
info "7/$STEPS" "Copying config files to $CONFIG_DEST ..."
if [ "$REPO_DIR" != "$CONFIG_DEST" ]; then
    mkdir -p "$CONFIG_DEST/colorThemes"
    cp -f "$REPO_DIR/.cl-shell.omp.json"              "$CONFIG_DEST/"
    cp -f "$REPO_DIR/user_profile.ps1"                 "$CONFIG_DEST/"
    cp -f "$REPO_DIR/colorThemes/"*.psd1               "$CONFIG_DEST/colorThemes/"
    # tmux status script
    cat > "$CONFIG_DEST/tmux-status.sh" << 'STATUSSH'
#!/bin/sh
cpu=$(top -bn1 | awk '/^%Cpu/{printf "%.0f", 100-$8}')
awk -v cpu="$cpu" '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{printf "CPU:%s%%  RAM:%.0f/%.0fGB", cpu, (t-a)/1048576, t/1048576}' /proc/meminfo
STATUSSH
    chmod +x "$CONFIG_DEST/tmux-status.sh"
    ok "Files copied."
else
    warn "Already running from target directory, skipping copy."
fi

# ── 8. Write ~/.zshrc ──────────────────────────────────────────────────
info "8/$STEPS" "Writing ~/.zshrc ..."
mkdir -p "$HOME/.cache/zsh" "$HOME/.local/share/zsh"
cat > "$HOME/.zshrc" << 'ZSHRC'
# ── cl-shell config (added by cl-shell installer) ──

# PATH
export PATH="$HOME/.local/bin:$HOME/bin:$HOME/.npm-global/bin:$PATH"

# Set the directory to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Oh My Posh prompt
if command -v oh-my-posh &> /dev/null; then
    eval "$(oh-my-posh init zsh --config ~/.config/cli/.cl-shell.omp.json)"
fi

# Add syntax-highlighting
zinit light zsh-users/zsh-syntax-highlighting
# add auto-completion
zinit light zsh-users/zsh-completions
# Load completions
autoload -U compinit && compinit -d ~/.cache/zsh/zcompdump
# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --icons --group-directories-first --color=always $realpath 2>/dev/null || ls --color $realpath'
# Completion menu
zinit light Aloxaf/fzf-tab
# Add auto-suggestions
zinit light zsh-users/zsh-autosuggestions

# Keybindings
bindkey -e
bindkey '^z' history-search-backward
bindkey '^x' history-search-forward

# history settings
HISTFILE=~/.local/share/zsh/history
HISTSIZE=10000
SAVEHIST=10000
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# eza colors (Nord palette: cyan=#88C0D0 orange=#D08770 green=#A3BE8C purple=#B48EAD)
export EZA_COLORS="\
di=38;2;136;192;208:\
ln=38;2;180;142;173:\
ex=38;2;163;190;140:\
fi=38;2;216;222;233:\
*.md=38;2;208;135;112:\
*.json=38;2;208;135;112:\
*.yml=38;2;208;135;112:\
*.yaml=38;2;208;135;112:\
*.toml=38;2;208;135;112:\
*.conf=38;2;208;135;112:\
*.js=38;2;235;203;139:\
*.ts=38;2;136;192;208:\
*.py=38;2;163;190;140:\
*.sh=38;2;163;190;140:\
*.go=38;2;136;192;208:\
*.rs=38;2;208;135;112:\
*.css=38;2;180;142;173:\
*.html=38;2;208;135;112:\
*.jpg=38;2;180;142;173:\
*.png=38;2;180;142;173:\
*.svg=38;2;180;142;173:\
*.git=38;2;102;102;102:\
*.gitignore=38;2;102;102;102"

# Aliases
if command -v eza &> /dev/null; then
    alias ls='eza --icons --group-directories-first -a'
    alias ll='eza --icons --group-directories-first -la'
    alias lt='eza --icons --group-directories-first --tree --level=2'
else
    alias ls='ls --color'
    alias ll='ls -al'
fi

# shell integrations
if command -v fzf &> /dev/null; then
    eval "$(fzf --zsh)"
fi
ZSHRC
ok "~/.zshrc written."

# ── 9. Write ~/.config/tmux/tmux.conf ───────────────────────────────────
info "9/$STEPS" "Writing ~/.config/tmux/tmux.conf ..."
mkdir -p "$HOME/.config/tmux"
cat > "$HOME/.config/tmux/tmux.conf" << 'TMUXCONF'
# TMUX KEY BINDINGS
unbind r
bind r source-file ~/.config/tmux/tmux.conf

# Action button from ^b to ^a
unbind C-b
set -g prefix C-a
bind-key C-a send-prefix

# Split windows
unbind %
unbind '"'
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
bind v split-window -h -c "#{pane_current_path}"
bind s split-window -v -c "#{pane_current_path}"

# Vim-Style pane navigation
#bind h select-pane -L
#bind j select-pane -D
#bind k select-pane -U
#bund l select-pane -R

# Start numbering at 1
set -g base-index 1
set -g pane-base-index 1
set-window-option -g pane-base-index 1
set-option -g renumber-windows on

# shift+arrow to switch windows
bind -n S-Left previous-window
bind -n S-Right next-window

# TMUX SETTINGS
set -g mouse on
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",*:RGB"
set -g set-clipboard on
set -g default-shell /usr/bin/zsh

# Color
gray_light="#D8DEE9"
gray_medium="#ABB2BF"
gray_dark="#1e2125"
green_soft="#A3BE8C"
blue_muted="#81A1C1"
cyan_soft="#88C0D0"

# Status bar styling
set-option -g status-position top
set -g status-left-length 100
set -g status-left "#[fill=${gray_dark},fg=${gray_dark},bg=default]#[fg=${green_soft},bg=${gray_dark},bold]  #S #[fg=${gray_light},bg=${gray_dark},nobold]"
set -g status-style "bg=default,fg=${gray_light}"
set -g status-right-length 60
set -g status-right "#[fg=${gray_light},bg=${gray_dark}] #(~/.config/cli/tmux-status.sh) #[fg=${gray_dark},bg=default] "
set -g window-status-current-format "#[fg=${cyan_soft},bg=${gray_dark},bold]  #[underscore]#I:#W"
set -g window-status-format "#[bg=${gray_dark}]#I:#W"
set -g pane-border-style "fg=${gray_dark}"
set -g pane-active-border-style "fg=${gray_medium}"
TMUXCONF
ok "~/.tmux.conf written."

# ── Suppress MOTD ──────────────────────────────────────────────────────
touch "$HOME/.hushlogin"

# ── Set Zsh as default shell ────────────────────────────────────────────
CURRENT_SHELL="$(basename "$SHELL")"
if [ "$CURRENT_SHELL" != "zsh" ]; then
    ZSH_PATH="$(command -v zsh)"
    info "..." "Setting zsh as default shell ..."
    chsh -s "$ZSH_PATH"
    ok "Default shell changed to zsh."
else
    warn "Zsh is already the default shell."
fi

# ── Done ────────────────────────────────────────────────────────────────
printf '\n\033[1;32m--- Installation complete! ---\033[0m\n'
echo "  * Set your terminal font to 'CaskaydiaCove Nerd Font'."
echo "  * Log out and back in (or run: zsh) to start using zsh."
echo ""
