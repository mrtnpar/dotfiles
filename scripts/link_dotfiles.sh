#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

link_file() {
  local src="$1"
  local dst="$2"
  mkdir -p "$(dirname "$dst")"
  ln -sf "$src" "$dst"
  echo "Linked $dst -> $src"
}

copy_template_if_needed() {
  local src="$1"
  local dst="$2"
  mkdir -p "$(dirname "$dst")"

  if [[ -L "$dst" ]]; then
    rm -f "$dst"
    cp "$src" "$dst"
    echo "Replaced symlink with local copy: $dst"
    return
  fi

  if [[ -f "$dst" ]]; then
    echo "Keeping existing local file: $dst"
    return
  fi

  cp "$src" "$dst"
  echo "Copied template $src -> $dst"
}

warn_placeholder_identity() {
  local gitcfg="$HOME/.gitconfig"
  if [[ ! -f "$gitcfg" ]]; then
    return
  fi

  if rg -q '^[[:space:]]*name[[:space:]]*=[[:space:]]*Your Name[[:space:]]*$' "$gitcfg" \
    || rg -q '^[[:space:]]*email[[:space:]]*=[[:space:]]*your-email@example.com[[:space:]]*$' "$gitcfg"; then
    echo "WARNING: ~/.gitconfig still has placeholder identity."
    echo "Run:"
    echo "  git config --global user.name \"Your Real Name\""
    echo "  git config --global user.email \"you@example.com\""
  fi
}

echo "-- Linking dotfiles"
link_file "$ROOT_DIR/vimrc" "$HOME/.vimrc"

echo "-- Copying local-editable templates"
copy_template_if_needed "$ROOT_DIR/gitignore_global" "$HOME/.gitignore_global"
copy_template_if_needed "$ROOT_DIR/gitconfig" "$HOME/.gitconfig"
copy_template_if_needed "$ROOT_DIR/jj/config.toml" "$HOME/.config/jj/config.toml"
warn_placeholder_identity

echo "-- Ensuring Oh My Zsh"
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "Oh My Zsh already installed"
fi

echo "-- Ensuring vim-plug"
if [[ ! -f "$HOME/.vim/autoload/plug.vim" ]]; then
  curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
else
  echo "vim-plug already installed"
fi
