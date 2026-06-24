#!/usr/bin/env bash
# install.sh — idempotent dotfiles installer (macOS only)
# Run from the repo root: ./install.sh
# Re-running is safe: existing files are backed up, SSH config is merged via
# Include so existing entries are never destroyed.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$(uname -s)" != "Darwin" ]; then
    echo "This installer is macOS only." >&2
    exit 1
fi

_ok()      { printf '\033[32m✔ %s\033[0m\n' "$*"; }
_warn()    { printf '\033[33m⚠ %s\033[0m\n' "$*"; }
_section() { printf '\n\033[1m── %s ──\033[0m\n' "$*"; }

link_file() {
    local src="$1" dst="$2"
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        _ok "already linked: $dst"; return
    fi
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        _warn "backing up $dst → ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi
    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    _ok "linked: $dst"
}

# ── bash ──────────────────────────────────────────────────────────────────
_section "bash"
link_file "$REPO/bash/bash_profile" "$HOME/.bash_profile"
link_file "$REPO/bash/bashrc"       "$HOME/.bashrc"
link_file "$REPO/bash/bash_aliases" "$HOME/.bash_aliases"

# ── tmux ──────────────────────────────────────────────────────────────────
_section "tmux"
link_file "$REPO/tmux/tmux.conf" "$HOME/.tmux.conf"

# ── Ghostty ───────────────────────────────────────────────────────────────
_section "Ghostty"
link_file "$REPO/ghostty/config" "$HOME/.config/ghostty/config"
_ok "restart Ghostty (Cmd+Q) to apply font/opacity changes"

# ── Neovim ────────────────────────────────────────────────────────────────
_section "Neovim"
link_file "$REPO/nvim/init.lua" "$HOME/.config/nvim/init.lua"

# ── SSH — merged via Include, never overwrites existing config ─────────────
_section "SSH"
mkdir -p "$HOME/.ssh/config.d"
chmod 700 "$HOME/.ssh" "$HOME/.ssh/config.d"
cp "$REPO/ssh/config" "$HOME/.ssh/config.d/dotfiles"
chmod 600 "$HOME/.ssh/config.d/dotfiles"
_ok "written: ~/.ssh/config.d/dotfiles"
INCLUDE_LINE="Include ~/.ssh/config.d/*"
if [ ! -f "$HOME/.ssh/config" ]; then
    printf '%s\n\n' "$INCLUDE_LINE" > "$HOME/.ssh/config"
    chmod 600 "$HOME/.ssh/config"
    _ok "created ~/.ssh/config with Include directive"
elif ! grep -qF "$INCLUDE_LINE" "$HOME/.ssh/config"; then
    tmp="$(mktemp)"
    printf '%s\n\n' "$INCLUDE_LINE" | cat - "$HOME/.ssh/config" > "$tmp"
    mv "$tmp" "$HOME/.ssh/config" && chmod 600 "$HOME/.ssh/config"
    _ok "prepended Include directive to existing ~/.ssh/config"
else
    _ok "Include directive already present in ~/.ssh/config"
fi

# ── Misc ──────────────────────────────────────────────────────────────────
_section "Misc"
link_file "$REPO/hushlogin" "$HOME/.hushlogin"

printf '\n\033[32m✔ Done — reload shell: exec bash\033[0m\n'
