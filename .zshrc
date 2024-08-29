
### Initialise Pure prompt
fpath+=("$HOME/.zsh/pure")
autoload -U promptinit; promptinit
prompt pure


### Load user aliases, functions & constants
source ~/.dotfiles/shell_utils.sh


### Shell options
setopt GLOB_DOTS        # Include hidden files in pathname expansion
setopt EXTENDED_GLOB    # Treat the ‘#’, ‘~’ and ‘^’ characters as part of patterns
setopt NO_CASE_GLOB     # Make globbing case-insensitive
setopt APPEND_HISTORY   # Append to the history file instead of overwriting it


### Zsh Line Editor (ZLE) setup
bindkey -v
bindkey "^H" backward-delete-char
bindkey "^?" backward-delete-char
bindkey '\e[1;9C' forward-word     # For moving forward by word
bindkey '\e[1;9D' backward-word    # For moving backward by word
bindkey '\e[3;9~' delete-word      # For deleting a word forward
bindkey '\e\b' backward-kill-word  # For deleting a word backward



### Set environment
export EDITOR='vim'
export LESS='-iRMXF'    # Ignore case, raw characters, detailed status, no
                        # alternate screen (keep content), quit if <1 screen

## History settings
# Ignore duplicate history entries
export HISTCONTROL='ignoredups:erasedups'
# Maximum number of lines contained in the history file
export HISTFILESIZE=8200
# Maximum number of commands to remember in the command history
export HISTSIZE=4096
# Time specifier, between line number and command, in the `history` command
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S  "


## Set PATH
# Define an array of paths to potentially add to $PATH
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

# Add paths for local Python venv and Node bin directories
PATH="$PATH:.venv/bin:./node_modules/.bin"

# Export the updated Path
export PATH


## Miscellaneous environment settings
# Prevent problems with '._*' files on MacOS
export COPYFILE_DISABLE=true
