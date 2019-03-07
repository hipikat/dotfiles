#!/bin/bash
python3 plumb_files.py --current-user --force
if [ ! -d ../.vim/bundle/Vundle.vim ]; then
  echo "go on..."
  git clone https://github.com/VundleVim/Vundle.vim.git ../.vim/bundle/Vundle.vim
fi

# Having just a BIT of trouble getting this to process with Salt...
vim +VundleInstall +qa >/dev/null
