#!/usr/bin/env bash
# linux/install.sh — idempotent dotfiles installer (Linux only)
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ "$(uname -s)" = "Linux" ] || { echo "Linux only." >&2; exit 1; }

_ok()   { printf '\033[32m✔ %s\033[0m\n' "$*"; }
_warn() { printf '\033[33m⚠ %s\033[0m\n' "$*"; }
_skip() { printf '\033[90m⊘ %s\033[0m\n' "$*"; }
_hdr()  { printf '\n%s\n' "$*"; }

cp_file() { mkdir -p "$(dirname "$2")"; cp "$1" "$2"; _ok "applied: $2"; }
sudo_cp() { sudo mkdir -p "$(dirname "$2")"; sudo cp "$1" "$2"; _ok "applied (root): $2"; }

printf '\nConfigure root user as well? [y/N]: '
read -r _ans
HAS_SUDO=false
if [[ "$_ans" =~ ^[Yy] ]]; then
    if sudo -v; then HAS_SUDO=true; _ok "sudo granted"
    else _warn "sudo failed — root skipped"
    fi
else
    _skip "root configuration"
fi

_hdr "bash"
cp_file "$REPO/bash/bash_profile" "$HOME/.bash_profile"
cp_file "$REPO/bash/bashrc"       "$HOME/.bashrc"
cp_file "$REPO/bash/bash_aliases" "$HOME/.bash_aliases"
if [ "$HAS_SUDO" = true ]; then
    sudo_cp "$REPO/bash/bash_profile" /root/.bash_profile
    sudo_cp "$REPO/bash/bashrc"       /root/.bashrc
    sudo_cp "$REPO/bash/bash_aliases" /root/.bash_aliases
fi

_hdr "tmux"
cp_file "$REPO/tmux/tmux.conf" "$HOME/.tmux.conf"
[ "$HAS_SUDO" = true ] && sudo_cp "$REPO/tmux/tmux.conf" /root/.tmux.conf || true

_hdr "ssh"
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
    _ok "SSH already present in ~/.ssh/config"
else
    chmod 600 "$HOME/.ssh/config"
    _ok "SSH applied to ~/.ssh/config"
fi

if [ "$HAS_SUDO" = true ]; then
    sudo mkdir -p /root/.ssh && sudo chmod 700 /root/.ssh
    _rtmp=$(mktemp)
    sudo cat /root/.ssh/config 2>/dev/null > "$_rtmp" || true
    chmod 600 "$_rtmp"
    if _upsert_ssh "$_rtmp"; then
        _ok "SSH already present in /root/.ssh/config"
    else
        sudo cp "$_rtmp" /root/.ssh/config
        sudo chmod 600 /root/.ssh/config
        _ok "SSH applied to /root/.ssh/config"
    fi
    rm -f "$_rtmp"
fi

_hdr "misc"
cp_file "$REPO/hushlogin" "$HOME/.hushlogin"

_hdr "default shell → bash"
BASH_BIN="$(command -v bash)"
if [ -z "$BASH_BIN" ]; then
    _warn "bash not found in PATH — install it first"
else
    if chsh -s "$BASH_BIN" "$USER" 2>/dev/null; then
        _ok "$USER: shell → $BASH_BIN"
    elif command -v usermod &>/dev/null && [ "$HAS_SUDO" = true ]; then
        sudo usermod -s "$BASH_BIN" "$USER"
        _ok "$USER: shell → $BASH_BIN (via usermod)"
    else
        _warn "Could not set default shell — run manually: chsh -s $BASH_BIN"
    fi
    if [ "$HAS_SUDO" = true ]; then
        if chsh -s "$BASH_BIN" root 2>/dev/null || \
           { command -v usermod &>/dev/null && sudo usermod -s "$BASH_BIN" root; }; then
            _ok "root: shell → $BASH_BIN"
        else
            _warn "Could not set root shell"
        fi
    fi
fi

printf '\n\033[32m✔ Done.\033[0m Log out and back in for the shell change to take effect.\n'
printf '  Reload now: exec bash\n'
