#!/bin/bash
python3 plumb_files.py --current-user --force
git clone https://github.com/VundleVim/Vundle.vim.git ../.vim/bundle/Vundle.vim
# fuck it
#vim -E -s -c VundleInstall -c qa
