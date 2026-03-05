#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NVM_MARKER_START="# DOTFILES_NVM_START"
NVM_MARKER_END="# DOTFILES_NVM_END"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

ensure_nvm_shell_block() {
  local shell_file="$1"
  local tmp
  tmp="$(mktemp)"

  touch "$shell_file"
  sed "/$NVM_MARKER_START/,/$NVM_MARKER_END/d" "$shell_file" > "$tmp"

  cat >> "$tmp" <<'BLOCK'
# DOTFILES_NVM_START
export NVM_DIR="$HOME/.nvm"
if [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
  . "/opt/homebrew/opt/nvm/nvm.sh"
elif [ -s "$NVM_DIR/nvm.sh" ]; then
  . "$NVM_DIR/nvm.sh"
fi
if [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ]; then
  . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
fi
# DOTFILES_NVM_END
BLOCK

  mv "$tmp" "$shell_file"
}

require_cmd brew

echo "-- Installing CLI tools via Homebrew"
brew install nvm git-town jj opencode

export NVM_DIR="$HOME/.nvm"
mkdir -p "$NVM_DIR"

NVM_SH="$(brew --prefix nvm)/nvm.sh"
if [[ ! -s "$NVM_SH" ]]; then
  NVM_SH="$(brew --prefix nvm)/libexec/nvm.sh"
fi

if [[ ! -s "$NVM_SH" ]]; then
  echo "Unable to locate nvm.sh after installing nvm" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$NVM_SH"

NODE_VERSION="$(cat "$ROOT_DIR/.nvmrc")"
echo "-- Installing Node with nvm: $NODE_VERSION"
nvm install "$NODE_VERSION"
nvm alias default "$NODE_VERSION"
nvm use "$NODE_VERSION"

echo "-- Installing Codex CLI with npm"
npm install -g @openai/codex

ensure_nvm_shell_block "$HOME/.zshrc"
ensure_nvm_shell_block "$HOME/.zprofile"

echo "-- Verifying toolchain"
node -v
npm -v
codex --version
git-town --version
jj --version
opencode --version
