#!/usr/bin/env bash
# install.sh — idempotent dotfiles installer (macOS + Linux/Debian)
# Run from the repo root: ./install.sh
# Re-running is safe: nothing is overwritten without backup, SSH config is
# merged via Include so existing entries are never destroyed.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"

_info()    { printf '\033[34m➤ %s\033[0m\n' "$*"; }
_ok()      { printf '\033[32m✔ %s\033[0m\n' "$*"; }
_warn()    { printf '\033[33m⚠ %s\033[0m\n' "$*"; }
_section() { printf '\n\033[1m── %s ──\033[0m\n' "$*"; }

# ── Helpers ───────────────────────────────────────────────────────────────

# link_file SRC DST
# Creates a symlink DST → SRC. If DST already exists and is NOT already the
# correct symlink, backs it up as DST.bak before replacing.
link_file() {
    local src="$1" dst="$2"
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        _ok "already linked: $dst"
        return
    fi
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        _warn "backing up existing $dst → ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi
    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    _ok "linked: $dst → $src"
}

# ── Shell configs ─────────────────────────────────────────────────────────
_section "Shell"
link_file "$REPO/zsh/zshrc"       "$HOME/.zshrc"
link_file "$REPO/zsh/zsh_aliases" "$HOME/.zsh_aliases"
link_file "$REPO/bash/bash_profile" "$HOME/.bash_profile"
link_file "$REPO/bash/bashrc"     "$HOME/.bashrc"
link_file "$REPO/bash/bash_aliases" "$HOME/.bash_aliases"

# ── tmux ─────────────────────────────────────────────────────────────────
_section "tmux"
link_file "$REPO/tmux/tmux.conf" "$HOME/.tmux.conf"
_ok "reload with: tmux source-file ~/.tmux.conf"

# ── Ghostty ───────────────────────────────────────────────────────────────
if [ "$OS" = "Darwin" ]; then
    _section "Ghostty (macOS)"
    mkdir -p "$HOME/.config/ghostty"
    link_file "$REPO/ghostty/config" "$HOME/.config/ghostty/config"
    _ok "restart Ghostty (Cmd+Q) to apply font/opacity changes"
fi

# ── Neovim ────────────────────────────────────────────────────────────────
_section "Neovim"
mkdir -p "$HOME/.config/nvim"
link_file "$REPO/nvim/init.lua" "$HOME/.config/nvim/init.lua"

# ── hushlogin ─────────────────────────────────────────────────────────────
_section "Misc"
link_file "$REPO/hushlogin" "$HOME/.hushlogin"

# ── SSH config — safe merge via Include ───────────────────────────────────
# We do NOT overwrite ~/.ssh/config. Instead we:
#   1. Copy our settings to ~/.ssh/config.d/dotfiles
#   2. Prepend an Include directive to ~/.ssh/config so our file is loaded
#      first. The Include is only added if it isn't already present.
_section "SSH"
mkdir -p "$HOME/.ssh/config.d"
chmod 700 "$HOME/.ssh" "$HOME/.ssh/config.d"

DOTFILES_SSH="$HOME/.ssh/config.d/dotfiles"
INCLUDE_LINE="Include ~/.ssh/config.d/*"

cp "$REPO/ssh/config" "$DOTFILES_SSH"
chmod 600 "$DOTFILES_SSH"
_ok "written: $DOTFILES_SSH"

SSH_CONFIG="$HOME/.ssh/config"
if [ ! -f "$SSH_CONFIG" ]; then
    printf '%s\n\n' "$INCLUDE_LINE" > "$SSH_CONFIG"
    chmod 600 "$SSH_CONFIG"
    _ok "created $SSH_CONFIG with Include directive"
elif ! grep -qF "$INCLUDE_LINE" "$SSH_CONFIG"; then
    # Prepend Include so it takes effect before any existing Host blocks
    tmp="$(mktemp)"
    printf '%s\n\n' "$INCLUDE_LINE" | cat - "$SSH_CONFIG" > "$tmp"
    mv "$tmp" "$SSH_CONFIG"
    chmod 600 "$SSH_CONFIG"
    _ok "prepended Include directive to existing $SSH_CONFIG"
else
    _ok "Include directive already present in $SSH_CONFIG"
fi

# ── Done ──────────────────────────────────────────────────────────────────
printf '\n\033[32m✔ Installation complete.\033[0m\n'
if [ "$OS" = "Darwin" ]; then
    printf '  Reload shell:  exec zsh   (or exec bash)\n'
else
    printf '  Reload shell:  exec bash\n'
fi
