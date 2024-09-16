#!/bin/bash

# Copy and/or link files into our home directory
python3 plumb_files.py --current-user --force

# Checkout git submodules
git submodule sync --recursive
git submodule update --init --recursive --force

# Install Vim plugins
if [ ! -d ../.vim/bundle/Vundle.vim ]; then
  git clone https://github.com/VundleVim/Vundle.vim.git ../.vim/bundle/Vundle.vim
fi
vim +VundleInstall '+qa!' >/dev/null

# Ensure the dotfiles 'origin' remote uses SSH
git remote remove origin
git remote add origin git@github.com:hipikat/dotfiles.git

