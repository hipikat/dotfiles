
### Initialise Pure prompt
if [[ -n "$SUDO_USER" && -d ~"$SUDO_USER"/.zsh/pure ]]; then
  sudo_user_home=$(eval echo ~$SUDO_USER)
  fpath=("$sudo_user_home/.zsh/pure" $fpath)
elif [[ -d "$HOME/.zsh/pure" ]]; then
  fpath=("$HOME/.zsh/pure" $fpath)
fi

autoload -U promptinit
promptinit
prompt pure


### Shell options
setopt GLOB_DOTS                # Include hidden files in pathname expansion
setopt EXTENDED_GLOB            # Treat the ‘#’, ‘~’ and ‘^’ characters as part of patterns
setopt NO_CASE_GLOB             # Make globbing case-insensitive


## History settings
unsetopt APPEND_HISTORY         # Append to the history file instead of overwriting it
setopt HIST_IGNORE_DUPS         # Ignore duplicate commands in history
unsetopt HIST_IGNORE_ALL_DUPS   # Remove older duplicate commands from history
setopt SHARE_HISTORY            # Share history across all sessions
setopt EXTENDED_HISTORY         # Save timestamps with history
setopt HIST_REDUCE_BLANKS       # Remove unnecessary blanks from history
setopt HIST_EXPIRE_DUPS_FIRST   # Expire duplicates first when trimming history
setopt HIST_SAVE_NO_DUPS        # Do not save duplicates in history
setopt HIST_IGNORE_SPACE        # Ignore commands that start with a space
unsetopt HIST_FIND_NO_DUPS      # Do not display duplicates in history search

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


### Set screen title for terminal multiplexers

# Function to set the screen title
set_screen_title() {
    if [[ "$TERM" == screen* || "$TERM" =~ tmux ]]; then
        echo -ne "\033k$1\033\\"
    fi
}

# Hook to set title before displaying the prompt
precmd() {
    # Contract home directory to ~
    local screen_title="${PWD/#$HOME/~}"
    set_screen_title "$screen_title"
}

# Hook to set title before executing a command
preexec() {
    # Contract home directory to ~
    local screen_title="${PWD/#$HOME/~}"
    screen_title+=`echo -ne " \xC2\xA7 "`
    screen_title+=" $$1"
    set_screen_title "$screen_title"
}


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

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/hipikat/.gcloud-sdk/path.zsh.inc' ]; then . '/Users/hipikat/.gcloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/hipikat/.gcloud-sdk/completion.zsh.inc' ]; then . '/Users/hipikat/.gcloud-sdk/completion.zsh.inc'; fi


### Load user aliases, functions & constants
if [ -r "${HOME}/.dotfiles/shell_utils.sh" ]; then
    source "${HOME}/.dotfiles/shell_utils.sh"
elif [ -r "/home/ada/.dotfiles/shell_utils.sh" ]; then
    source "/home/ada/.dotfiles/shell_utils.sh"
elif [ -r "/home/hipikat/.dotfiles/shell_utils.sh" ]; then
    source "/home/hipikat/.dotfiles/shell_utils.sh"
fi

