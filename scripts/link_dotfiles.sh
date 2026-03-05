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

echo "-- Linking dotfiles"
link_file "$ROOT_DIR/gitignore_global" "$HOME/.gitignore_global"
link_file "$ROOT_DIR/gitconfig" "$HOME/.gitconfig"
link_file "$ROOT_DIR/vimrc" "$HOME/.vimrc"
link_file "$ROOT_DIR/jj/config.toml" "$HOME/.config/jj/config.toml"

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
