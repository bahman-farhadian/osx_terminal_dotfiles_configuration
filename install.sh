#!/usr/bin/env bash
# install.sh — idempotent dotfiles installer (macOS only)
# Run from the repo root: ./install.sh

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$(uname -s)" != "Darwin" ]; then
    echo "This installer is macOS only." >&2; exit 1
fi

_ok()      { printf '\033[32m✔ %s\033[0m\n' "$*"; }
_warn()    { printf '\033[33m⚠ %s\033[0m\n' "$*"; }
_skip()    { printf '\033[90m⊘ skipped: %s\033[0m\n' "$*"; }
_section() { printf '\n\033[1m── %s ──\033[0m\n' "$*"; }

# Copy src → dst (creates parent dirs)
cp_file() {
    mkdir -p "$(dirname "$2")"
    cp "$1" "$2"
    _ok "applied: $2"
}

# Same but with sudo
sudo_cp() {
    sudo mkdir -p "$(dirname "$2")"
    sudo cp "$1" "$2"
    _ok "applied (root): $2"
}

# ── Sudo ──────────────────────────────────────────────────────────────────
printf '\nConfigure root user as well? [y/N]: '
read -r _ans
HAS_SUDO=false
if [[ "$_ans" =~ ^[Yy] ]]; then
    if sudo -v; then
        HAS_SUDO=true
        _ok "sudo granted — root will be configured"
    else
        _warn "sudo failed — root configuration skipped"
    fi
else
    _skip "root configuration"
fi

# ── bash ──────────────────────────────────────────────────────────────────
_section "bash"
cp_file "$REPO/bash/bash_profile" "$HOME/.bash_profile"
cp_file "$REPO/bash/bashrc"       "$HOME/.bashrc"
cp_file "$REPO/bash/bash_aliases" "$HOME/.bash_aliases"
if [ "$HAS_SUDO" = true ]; then
    sudo_cp "$REPO/bash/bash_profile" /var/root/.bash_profile
    sudo_cp "$REPO/bash/bashrc"       /var/root/.bashrc
    sudo_cp "$REPO/bash/bash_aliases" /var/root/.bash_aliases
fi

# ── tmux ──────────────────────────────────────────────────────────────────
_section "tmux"
cp_file "$REPO/tmux/tmux.conf" "$HOME/.tmux.conf"
[ "$HAS_SUDO" = true ] && sudo_cp "$REPO/tmux/tmux.conf" /var/root/.tmux.conf || true

# ── Ghostty ───────────────────────────────────────────────────────────────
_section "Ghostty"
cp_file "$REPO/ghostty/config" "$HOME/.config/ghostty/config"
_ok "restart Ghostty (Cmd+Q) for font/title-bar changes to take effect"

# ── Neovim ────────────────────────────────────────────────────────────────
_section "Neovim"
cp_file "$REPO/nvim/init.lua" "$HOME/.config/nvim/init.lua"
if [ "$HAS_SUDO" = true ]; then
    sudo_cp "$REPO/nvim/init.lua" /var/root/.config/nvim/init.lua
fi

# ── SSH — append our 6-line block if not already present ──────────────────
_section "SSH"
mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
touch "$HOME/.ssh/config"   && chmod 600 "$HOME/.ssh/config"
if grep -qF 'AddKeysToAgent 5m' "$HOME/.ssh/config" 2>/dev/null; then
    _ok "SSH settings already in ~/.ssh/config"
else
    printf '\n' >> "$HOME/.ssh/config"
    cat "$REPO/ssh/config" >> "$HOME/.ssh/config"
    _ok "SSH settings appended to ~/.ssh/config"
fi
if [ "$HAS_SUDO" = true ]; then
    sudo mkdir -p /var/root/.ssh && sudo chmod 700 /var/root/.ssh
    sudo touch /var/root/.ssh/config && sudo chmod 600 /var/root/.ssh/config
    if sudo grep -qF 'AddKeysToAgent 5m' /var/root/.ssh/config 2>/dev/null; then
        _ok "SSH settings already in /var/root/.ssh/config"
    else
        printf '\n' | sudo tee -a /var/root/.ssh/config > /dev/null
        sudo sh -c "cat '$REPO/ssh/config' >> /var/root/.ssh/config"
        _ok "SSH settings appended to /var/root/.ssh/config"
    fi
fi

# ── Default shell → bash (system-wide via dscl) ───────────────────────────
_section "Default shell"
if sudo dscl . -create /Users/"$USER" UserShell /bin/bash; then
    _ok "$USER: default shell → /bin/bash"
else
    _warn "$USER: could not set default shell"
fi
if [ "$HAS_SUDO" = true ]; then
    sudo dscl . -create /Users/root UserShell /bin/bash
    _ok "root: default shell → /bin/bash"
else
    _skip "root shell (no sudo)"
fi

# ── Misc ──────────────────────────────────────────────────────────────────
_section "Misc"
cp_file "$REPO/hushlogin" "$HOME/.hushlogin"

printf '\n\033[32m✔ Done.\033[0m Log out and back in for the shell change to take effect.\n'
printf '  Reload current session now:  exec bash\n'
