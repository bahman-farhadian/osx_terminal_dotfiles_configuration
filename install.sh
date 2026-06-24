#!/usr/bin/env bash
# install.sh — idempotent dotfiles installer (macOS only)
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ "$(uname -s)" = "Darwin" ] || { echo "macOS only." >&2; exit 1; }

_ok()   { printf '\033[32m✔ %s\033[0m\n' "$*"; }
_warn() { printf '\033[33m⚠ %s\033[0m\n' "$*"; }
_skip() { printf '\033[90m⊘ %s\033[0m\n' "$*"; }
_hdr()  { printf '\n%s\n' "$*"; }

cp_file() { mkdir -p "$(dirname "$2")"; cp "$1" "$2"; _ok "applied: $2"; }
sudo_cp() { sudo mkdir -p "$(dirname "$2")"; sudo cp "$1" "$2"; _ok "applied (root): $2"; }

# Use Homebrew bash (5.x) — required for bash-completion@2. Fall back to /bin/bash only if missing.
BREW_BASH=""
for _p in /opt/homebrew/bin/bash /usr/local/bin/bash; do
    [ -x "$_p" ] && { BREW_BASH="$_p"; break; }
done
if [ -z "$BREW_BASH" ]; then
    _warn "Homebrew bash not found — run: brew install bash"
    BREW_BASH=/bin/bash
fi

_bc="${HOMEBREW_PREFIX:-/opt/homebrew}/etc/profile.d/bash_completion.sh"
[ -r "$_bc" ] || _warn "bash-completion@2 not found — run: brew install bash-completion@2"
unset _bc

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
    sudo_cp "$REPO/bash/bash_profile" /var/root/.bash_profile
    sudo_cp "$REPO/bash/bashrc"       /var/root/.bashrc
    sudo_cp "$REPO/bash/bash_aliases" /var/root/.bash_aliases
fi

_hdr "tmux"
cp_file "$REPO/tmux/tmux.conf" "$HOME/.tmux.conf"
[ "$HAS_SUDO" = true ] && sudo_cp "$REPO/tmux/tmux.conf" /var/root/.tmux.conf || true

_hdr "ghostty"
cp_file "$REPO/ghostty/config" "$HOME/.config/ghostty/config"
_ok "restart Ghostty (Cmd+Q) for font changes to take effect"

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
    sudo mkdir -p /var/root/.ssh && sudo chmod 700 /var/root/.ssh
    _rtmp=$(mktemp)
    sudo cat /var/root/.ssh/config 2>/dev/null > "$_rtmp" || true
    chmod 600 "$_rtmp"
    if _upsert_ssh "$_rtmp"; then
        _ok "SSH already present in /var/root/.ssh/config"
    else
        sudo cp "$_rtmp" /var/root/.ssh/config
        sudo chmod 600 /var/root/.ssh/config
        _ok "SSH applied to /var/root/.ssh/config"
    fi
    rm -f "$_rtmp"
fi

_hdr "default shell → $BREW_BASH"
# Ensure brew bash is in /etc/shells so login managers accept it
grep -qF "$BREW_BASH" /etc/shells 2>/dev/null || echo "$BREW_BASH" | sudo tee -a /etc/shells > /dev/null
if sudo dscl . -create /Users/"$USER" UserShell "$BREW_BASH"; then
    _ok "$USER: shell → $BREW_BASH"
else
    _warn "$USER: could not set shell"
fi
if [ "$HAS_SUDO" = true ]; then
    sudo dscl . -create /Users/root UserShell "$BREW_BASH"
    _ok "root: shell → $BREW_BASH"
else
    _skip "root shell"
fi

_hdr "misc"
cp_file "$REPO/hushlogin" "$HOME/.hushlogin"

printf '\n\033[32m✔ Done.\033[0m Log out and back in for the shell change to take effect.\n'
printf '  Reload now: exec bash\n'
