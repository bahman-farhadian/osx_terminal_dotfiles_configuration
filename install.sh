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

# ── Prerequisites hint ────────────────────────────────────────────────────
bc_path="${HOMEBREW_PREFIX:-/opt/homebrew}/etc/profile.d/bash_completion.sh"
if ! [ -r "$bc_path" ]; then
    _warn "bash-completion@2 not found — kubectl/docker tab-completion will not work"
    printf '  Fix: brew install bash-completion@2\n'
fi
unset bc_path

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

# ── SSH — upsert our 6-line block (replaces stale previous versions) ──────
_section "SSH"

# Remove any stale Host * stanza then append fresh block.
# Returns 0 if already up-to-date, 1 if a change was made.
_upsert_ssh() {
    local config="$1"
    grep -qF 'AddKeysToAgent 5m' "$config" 2>/dev/null && return 0
    if grep -qF 'StrictHostKeyChecking no' "$config" 2>/dev/null; then
        local py
        py=$(mktemp)
        cat > "$py" << 'PYEOF'
import sys, re
path = sys.argv[1]
try: text = open(path).read()
except FileNotFoundError: text = ''
text = re.sub(r'\nHost \*\n(?:[ \t][^\n]*\n?)*', '', '\n' + text).strip()
open(path, 'w').write(text + '\n' if text else '')
PYEOF
        python3 "$py" "$config"
        rm -f "$py"
    fi
    printf '\n' >> "$config"
    cat "$REPO/ssh/config" >> "$config"
    return 1
}

mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
touch "$HOME/.ssh/config" && chmod 600 "$HOME/.ssh/config"
if _upsert_ssh "$HOME/.ssh/config"; then
    _ok "SSH settings already present in ~/.ssh/config"
else
    chmod 600 "$HOME/.ssh/config"
    _ok "SSH settings applied to ~/.ssh/config"
fi

if [ "$HAS_SUDO" = true ]; then
    sudo mkdir -p /var/root/.ssh && sudo chmod 700 /var/root/.ssh
    _rtmp=$(mktemp)
    sudo cat /var/root/.ssh/config 2>/dev/null > "$_rtmp" || true
    chmod 600 "$_rtmp"
    if _upsert_ssh "$_rtmp"; then
        _ok "SSH settings already present in /var/root/.ssh/config"
    else
        sudo cp "$_rtmp" /var/root/.ssh/config
        sudo chmod 600 /var/root/.ssh/config
        _ok "SSH settings applied to /var/root/.ssh/config"
    fi
    rm -f "$_rtmp"
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
