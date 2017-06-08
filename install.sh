#!/bin/bash
PWD="$PWD"
HOME="$HOME"
echo ${PWD}
echo ${HOME}

echo "-- Checking dependencies"
command -v zsh  >/dev/null 2>&1 || { echo >&2 "Zsh, it's not installed. Aborting.";  exit 1; }
command -v git  >/dev/null 2>&1 || { echo >&2 "Git, it's not installed. Aborting.";  exit 1; }
command -v curl >/dev/null 2>&1 || { echo >&2 "Curl, it's not installed. Aborting."; exit 1; }
command -v vim  >/dev/null 2>&1 || { echo >&2 "Vim, it's not installed. Aborting.";  exit 1; }
command -v tmux >/dev/null 2>&1 || { echo >&2 "TMUX, it's not installed. Aborting."; exit 1; }

echo "-- Creating vim/nvim/tmux  directories"
mkdir -p ${HOME}/.vim/files/swap/
mkdir -p ${HOME}/.config/nvim

echo "-- Linking config files"
mkdir -p ${HOME}/.config/nvim
ln -sf ${PWD}/gitignore_global ${HOME}/.gitignore_global
ln -sf ${PWD}/gitconfig ${HOME}/.gitconfig
ln -sf ${PWD}/tmux.conf ${HOME}/.tmux.conf
ln -sf ${PWD}/vimrc ${HOME}/.vimrc
ln -sf ${PWD}/vimrc ${HOME}/.config/nvim/init.vim

echo "-- Installing Oh My ZSH!"
curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh

echo "-- Installing vim-plug in vim"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "-- Installing tmux plugins"
rm -rf ${HOME}/.tmux/plugins/tpm
git clone https://github.com/tmux-plugins/tpm ${HOME}/.tmux/plugins/tpm
