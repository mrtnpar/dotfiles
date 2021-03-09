#!/bin/bash
PWD="$PWD"
HOME="$HOME"
echo ${PWD}
echo ${HOME}

echo "-- Creating vim/nvim/tmux  directories"
mkdir -p ${HOME}/.vim/files/swap/
mkdir -p ${HOME}/.config/nvim

echo "-- Linking config files"
ln -sf ${PWD}/gitignore_global ${HOME}/.gitignore_global
ln -sf ${PWD}/gitconfig ${HOME}/.gitconfig
ln -sf ${PWD}/vimrc ${HOME}/.vimrc

echo "-- Installing Oh My ZSH!"
curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh

echo "-- Installing vim-plug for vim"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
