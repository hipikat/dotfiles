#!/bin/bash

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

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

# Pre-install Neovim plugins/LSPs for headless/ephemeral boxes
if command -v nvim >/dev/null; then
  nvim --headless "+Lazy! sync" +qa
  # :MasonInstall itself is async and would race a bare +qa on a fresh
  # install, so block until the package install job actually closes.
  nvim --headless -c '
    lua local mr = require("mason-registry")
    mr.refresh(function()
      local pkg = mr.get_package("harper-ls")
      if pkg:is_installed() then
        vim.cmd("qa")
      else
        pkg:install():once("closed", function()
          vim.schedule(function() vim.cmd("qa") end)
        end)
      end
    end)
  '
fi

# Ensure the dotfiles 'origin' remote uses SSH
git remote remove origin 2>/dev/null || true
git remote add origin git@github.com:hipikat/dotfiles.git

# Ensure plain `git push` on main targets origin/main
git config branch.main.remote origin
git config branch.main.merge refs/heads/main
