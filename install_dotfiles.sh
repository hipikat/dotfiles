#!/bin/bash
python3 plumb_files.py --current-user --force
git clone https://github.com/VundleVim/Vundle.vim.git ../.vim/bundle/Vundle.vim

# Having just a BIT of trouble getting this to process with Salt...
#vim - -nes -c ':VundleInstall' -c ':qa!'
