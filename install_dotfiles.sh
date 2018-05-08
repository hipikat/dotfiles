#!/bin/bash
python3 plumb_files.py --current-user --force
git clone https://github.com/VundleVim/Vundle.vim.git ../.vim/bundle/Vundle.vim
vim - -nes -c ':VundleInstall' -c ':qa!'
