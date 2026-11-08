#!/bin/bash
#
# Install these dotfiles into $HOME.
#
# Nothing in $HOME is ever deleted. Anything already in the way (a real file,
# a real directory, or a symlink pointing somewhere else) is listed first and
# only moved aside, to NAME.plumb-backup-TIMESTAMP, once you confirm.

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: install_dotfiles.sh [-n|--dry-run] [-y|--yes]

  -n, --dry-run  Show what would be linked or moved aside; change nothing
  -y, --yes      Move conflicting items aside without asking (headless boxes)
  -h, --help     Show this help
USAGE
}

die() {
  printf 'install_dotfiles: %s\n' "$*" >&2
  exit 1
}

dry_run=0
assume_yes=0
while [ $# -gt 0 ]; do
  case $1 in
    -n|--dry-run) dry_run=1 ;;
    -y|--yes) assume_yes=1 ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
  shift
done

repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
cd "$repo_dir"

# Sanity checks before touching anything
[ -z "${SUDO_USER:-}" ] || die "don't run under sudo; it would plumb into the wrong HOME as root"
[ -n "${HOME:-}" ] && [ -d "$HOME" ] || die "HOME is unset or not a directory"
home_dir=$(cd "$HOME" && pwd -P)
[ "$home_dir" != / ] || die "refusing to install into /"
[ "$home_dir" != "$repo_dir" ] || die "the repository is HOME itself"
[ "$(git rev-parse --show-toplevel 2>/dev/null)" = "$repo_dir" ] \
  || die "$repo_dir is not the top of a Git checkout"
dirty=$(git submodule foreach --quiet --recursive \
  'if [ -n "$(git status --porcelain)" ]; then echo "  $displaypath"; fi')
[ -z "$dirty" ] || die "submodules have local changes; commit or stash them first:
$dirty"

plumb() {
  python3 plumb_files.py --current-user "$@"
}

# Copy and/or link files into our home directory
conflicts=$(plumb --list-conflicts)
if [ -n "$conflicts" ]; then
  printf 'These existing items are in the way and would be moved aside (not deleted):\n' >&2
  printf '%s\n' "$conflicts" | sed 's/^/  /' >&2
fi

if [ "$dry_run" -eq 1 ]; then
  plumb --dry-run --force
  echo "Dry run: nothing was changed, and the Git, Vim and Neovim steps were skipped." >&2
  exit 0
fi

force=
if [ -n "$conflicts" ]; then
  if [ "$assume_yes" -eq 1 ]; then
    force=--force
  elif [ -t 0 ]; then
    printf 'Move them aside and continue? [y/N] ' >&2
    read -r reply
    case $reply in
      [yY]|[yY][eE][sS]) force=--force ;;
      *) die "aborted; nothing was changed" ;;
    esac
  else
    die "stdin is not a terminal; re-run with --yes to move them aside"
  fi
fi
plumb ${force:+"$force"}

# Check out git submodules (local changes were refused above)
git submodule sync --recursive
git submodule update --init --recursive

# Install Vim plugins
if [ ! -d "$HOME/.vim/bundle/Vundle.vim" ]; then
  git clone https://github.com/VundleVim/Vundle.vim.git "$HOME/.vim/bundle/Vundle.vim"
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
origin_url=git@github.com:hipikat/dotfiles.git
if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "$origin_url"
else
  git remote add origin "$origin_url"
fi

# Ensure plain `git push` on main targets origin/main
git config branch.main.remote origin
git config branch.main.merge refs/heads/main
