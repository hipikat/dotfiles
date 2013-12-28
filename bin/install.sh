#!/bin/bash

set -eu

# Colors 
BLD=$(tput bold)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YLW=$(tput setaf 3)
BLUE=$(tput setaf 4)
PURPLE=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
CRESET=$(tput sgr0)

this_dir="$(dirname "$(readlink -f "$0")")"
base_dir="$this_dir/.."

# Should define arrays: cfg_ignore cfg_first_child and cfg_dest_dir
. "$base_dir/CONFIG"


echo_usage() {
    echo "usage: $(basename "$0") [-h|--help] [-d|--dry-run] [-f|--force]"
    echo
    echo "    Create the symlinks to these dotfiles according to the configuration"
    echo "    (present in '../CONFIG'). Using --force will overwrite existing files."
}

DEBUG=0
FORCE=0
while [[ $# > 0 ]]; do
    key="$1"
    shift
    case $key in
        -h|--help)
            echo_usage
            exit 0
	        ;;
        --dry-run)
            DEBUG=1 ;;
        --force)
            FORCE=1 ;;
        *)
            echo_usage
            exit 1 ;;
    esac
done

element_in() {
    local i
    for i in "${@:2}"; do
        # No quotes on $1 ==> $1 can be a glob
        if [[ "$1" == $i ]]; then
            return 0
        fi
    done
    return 1
}

# Create a symlink in $1 that points to $2
# Optionally prepend target with $3 if using relative paths
do_symlink() {
    local target="$1"
    local dest="$2"
    local prepend_target="${3:-}"
    if [[ -L $dest ]]; then
        if [[ $FORCE == 0 ]]; then
            echo "${YLW}Warning${CRESET}: '$dest' is already a link. Skipping." 1>&2
            return 0
        else
            echo "${YLW}Warning${CRESET}: '$dest' is already a link. Overwriting." 1>&2
            rm -Rf "$dest"
        fi
    fi
    if [[ -e $dest ]]; then
        if [[ $FORCE == 0 ]]; then
            echo "${RED}Warning${CRESET}: '$dest' is a file. Skipping." 1>&2
            return 0
        else
            echo "${RED}Warning${CRESET}: '$dest' is a file. Overwriting." 1>&2
            rm -Rf "$dest"
        fi
    fi
    
    # Use absolute or relative depending on cfg_dotfiles_relative_path
    if [[ -z $cfg_dotfiles_relative_path ]]; then
        target="$(readlink -f "$target")"
    else
        target="${prepend_target}$cfg_dotfiles_relative_path/$target"
    fi
    if [[ $DEBUG == 1 ]]; then
        echo "${GREEN}Info${CRESET}: (dry run) would create '$dest' -> '$target'"
    else
        echo "${GREEN}Info${CRESET}: creating '$dest' -> '$target'"
        ln -s "$target" "$dest"
    fi
}


doit() {
    local i j
    for i in * .[^.]*; do

        if element_in "$i" "${cfg_ignore[@]}"; then
            continue
        fi

        if element_in "$i" "${cfg_first_child[@]}"; then
            for j in "$i"/*; do
                mkdir -p "$cfg_dest_dir/${j#$i}"
                do_symlink "$j" "$cfg_dest_dir/$j" ../
            done
            continue
        fi
        do_symlink "$i" "$cfg_dest_dir/$i"
    done
}

( cd "$base_dir" && doit )

# vim: et ts=4 sw=4
