
### Initialise Pure prompt
fpath+=("$HOME/.zsh/pure")
autoload -U promptinit; promptinit
prompt pure


### Shell options
setopt GLOB_DOTS                # Include hidden files in pathname expansion
setopt EXTENDED_GLOB            # Treat the ‘#’, ‘~’ and ‘^’ characters as part of patterns
setopt NO_CASE_GLOB             # Make globbing case-insensitive


## History settings
setopt APPEND_HISTORY           # Append to the history file instead of overwriting it
setopt HIST_IGNORE_DUPS         # Ignore duplicate commands in history
setopt HIST_IGNORE_ALL_DUPS     # Remove older duplicate commands from history
setopt SHARE_HISTORY            # Share history across all sessions
setopt HIST_REDUCE_BLANKS       # Remove unnecessary blanks from history
setopt HIST_EXPIRE_DUPS_FIRST   # Expire duplicates first when trimming history
setopt HIST_SAVE_NO_DUPS        # Do not save duplicates in history
setopt HIST_IGNORE_SPACE        # Ignore commands that start with a space
setopt HIST_FIND_NO_DUPS        # Do not display duplicates in history search

export HISTSIZE=16384           # Number of commands to remember in the session history
export SAVEHIST=16384           # Number of commands to save in the history file


### Set environment
export EDITOR='vim'
export COPYFILE_DISABLE=true    # Prevent mystery ._* files appearing in tarballs on MacOS
export LESS='-iRMXF'            # Ignore case, raw characters, detailed status, no
                                # alternate screen (keep content), quit if <1 screen

### Zsh Line Editor (ZLE) setup
bindkey -v
bindkey "^?" backward-delete-char


## Set PATH
paths=(
    ~/.bin
    ~/.local/bin
    ~/Dropbox/bin
    /usr/local/opt/coreutils/libexec/gnubin
    /usr/local/opt/gnu-sed/libexec/gnubin
    /usr/local/opt/gnu-tar/libexec/gnubin
    /usr/local/sbin
    /usr/local/bin
    /usr/local/mysql/bin
    ~/Library/Python/3.9/bin
    /usr/games
)

# Prepend existing directories to $PATH, iterating in reverse order
for (( i=${#paths[@]}-1 ; i>=0 ; i-- )); do
    dir="${paths[i]}"
    if [[ -d "$dir" && ":$PATH:" != *":$dir:"* ]]; then
        PATH="$dir:$PATH"
    fi
done

PATH="$PATH:.venv/bin:./node_modules/.bin"  # Add local Python venv & Node bin directories
export PATH


### Load user aliases, functions & constants
source "${0:a:h}/.dotfiles/shell_utils.sh"

