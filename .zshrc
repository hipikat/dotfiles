
### Initialise Pure prompt
if [[ -n "$SUDO_USER" && -d ~"$SUDO_USER"/.zsh/pure ]]; then
  sudo_user_home=$(eval echo ~$SUDO_USER)
  fpath=("$sudo_user_home/.zsh/pure" $fpath)
elif [[ -d "$HOME/.zsh/pure" ]]; then
  fpath=("$HOME/.zsh/pure" $fpath)
fi

# Pure prompt display options
zstyle :prompt:pure:git:dirty detailed yes              # More than just 'dirty'
zstyle :prompt:pure:environment:node_version show yes   # Show package.json node version
zstyle :prompt:pure:path:separator dim yes              # Dim path separators

# Don't asynchronously perform git fetches for the prompt if you're "agentic" in nature
if [[ -n "${AI_AGENT}${CLAUDECODE}${CURSOR_AGENT}${GEMINI_CLI}${OPENCODE}${CODEX}" ]]; then
    zstyle :prompt:pure:git show no
fi

# Initialise the Pure prompt - the wet dream of prompts for minimalists
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
export GOPATH="${GOPATH:-$HOME/go}"  # Default Go workspace for user-installed tools

### Zsh Line Editor (ZLE) setup
bindkey -v
bindkey "^?" backward-delete-char


### Completion setup
# Match completions case-insensitively, e.g. doc<Tab> matches Documents
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

autoload -Uz compinit
compinit


### Zsh plugin setup
# Use fzf-tab for interactive completion menus after the usual Tab expansion.
if [[ -r "$HOME/.zsh/fzf-tab/fzf-tab.plugin.zsh" ]]; then
    zstyle ':fzf-tab:*' fzf-flags --height=40% --layout=reverse --border
    source "$HOME/.zsh/fzf-tab/fzf-tab.plugin.zsh"
fi

# Load autosuggestions after completion widgets have been initialised.
if [[ -r "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi


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
    # User-managed bins
    ~/.bin
    ~/.local/bin
    ~/Dropbox/bin
    ~/go/bin

    # GNU tools from Homebrew; gnubin exposes unprefixed command names
    /opt/homebrew/opt/coreutils/libexec/gnubin
    /opt/homebrew/opt/findutils/libexec/gnubin
    /opt/homebrew/opt/grep/libexec/gnubin
    /opt/homebrew/opt/gnu-sed/libexec/gnubin
    /opt/homebrew/opt/gnu-tar/libexec/gnubin
    /opt/homebrew/opt/make/libexec/gnubin

    # Homebrew prefixes for Apple Silicon and Intel Macs
    /opt/homebrew/sbin
    /opt/homebrew/bin
    /usr/local/opt/coreutils/libexec/gnubin
    /usr/local/opt/findutils/libexec/gnubin
    /usr/local/opt/grep/libexec/gnubin
    /usr/local/opt/gnu-sed/libexec/gnubin
    /usr/local/opt/gnu-tar/libexec/gnubin
    /usr/local/opt/make/libexec/gnubin
    /usr/local/sbin
    /usr/local/bin

    # Other machine-specific paths
    /usr/games
)

# Prepend existing directories to $PATH, iterating in reverse order
for (( i=${#paths[@]} ; i>0 ; i-- )); do
    dir="${paths[i]}"
    if [[ -d "$dir" ]]; then
        path=("$dir" "${path[@]:#$dir}")
    fi
done

# Add project-local Python and Node bins at the end, without duplicates
path=("${path[@]:#.venv/bin}" ".venv/bin")
path=("${path[@]:#./node_modules/.bin}" "./node_modules/.bin")
export PATH

# Enable fnm-managed Node versions when fnm is installed
if command -v fnm >/dev/null 2>&1; then
    eval "$(fnm env --use-on-cd --shell zsh)"
fi

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
