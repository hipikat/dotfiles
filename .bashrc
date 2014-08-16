###
# .bashrc for Adam Wright <adam@hipikat.org>
###
# Do nothing if not running interactively
[ -z "$PS1" ] && return

### Aliases
##########################################




### Utility functions
##########################################
# Usage: `array_contains needle "${haystack[@]}"`
in_array() { 
    local hay needle=$1
    shift
    for hay; do
        [[ $hay == $needle ]] && return 0
    done
    return 1
}
export -f in_array

### Shell options - The Shopt Builtin
##########################################
# http://www.gnu.org/software/bash/manual/bashref.html#The-Shopt-Builtin
#
# checkwinsize   Check the window size after each command and update LINES and COLUMNS
# cdspell        Correct minor directory spelling mistakes for cd
# cmdhist        Save multi-line commands to the history as a single line
# dotglob        Includes hidden files in pathname expansion
# extglob        Enables [?*+@!](pattern|pattern|...) matching
# nocaseglob     Pathname expansion matches in a case-insensitive way 
# histappend     Append to the history file instead of overwriting it
# autocd         Change to a directory if a directory's given as a command
# extdebug       Enable behavior intended for debuggers (for trap 'pre_execute' DEBUG)

# Get an array of shell options supported by this version of bash
shopts=( $(shopt | cut -f1) )
# Enabled the following shell options - copy this block but use `shopt -u` to
# unset any of the shell options which are set by default.
for opt in "checkwinsize cdspell cmdhist dotglob extglob nocaseglob
            histappend autocd"; do
    if in_array $opt "${shopts[@]}"; then
        shopt -s $opt
    fi
done
if in_array 'extdebug' "${shopts[@]}"; then
    shopt -s extdebug > /dev/null 2>&1
fi

### The shell PATH
##########################################
declare -a paths
# Added to the front of $PATH, if not already included, in order
paths+=( ~/.bin ~/bin ~/Dropbox/bin )
paths+=( /usr/local/sbin /usr/local/bin )
paths+=( /usr/local/mysql/bin )
paths+=( /usr/games /foo/bar /bar/foo )
paths+=( ~/.rvm/bin )
paths+=( /Applications/Xcode.app/Contents/Developer/usr/bin )
paths+=( /Developer/Tools )
add_missing_paths () {
    PATH=":$PATH:"
    new_paths=""
    for next_path; do
        # If next path isn't in $PATH and it exists, append to $new_paths
        if [[ ! $PATH =~ ":${next_path}:" && -d $next_path ]]; then
            new_paths="$new_paths:$next_path"
        fi
    done
    PATH="$new_paths$PATH"
    PATH=${PATH#":"}
    PATH=${PATH%":"}
}
add_missing_paths ${paths[@]}

# Echo each element of $PATH to a new line
echo_paths () {
    paths=(${PATH//:/ })
    for path_i in "${!paths[@]}"; do
        echo "${paths[path_i]}"
    done
}
export -f echo_paths

### Install pyenv shims
##########################################
eval "$(pyenv init - 2>/dev/null)"

### Local configuration
##########################################
if [ -f ~/.bash_local ]; then
    source ~/.bash_local
fi






########## unclean.........

#export PYTHONPATH="$HOME/lib/python:."

# ALIASES (AND FUNCTIONS ACTING AS ALIASES)
alias lv='ls -l'            # List visible, vertical & verbose
alias la='ls -Al'           # List all, with details
alias scr='screen -D -R'    # Attach here and now
alias myip="curl -s icanhazip.com"

sassy()
{
    cd "src/styles"
    eval "bundle exec compass watch &"
    cd "../.."
}
runs() {
    eval "django-admin.py runserver "$@" --traceback"
}
runp() {
    eval "django-admin.py runserver "$@" --traceback"
}

function lvl() { ls $COLOR_ALWAYS -l "$@" | less ;}
function lal() { ls $COLOR_ALWAYS -Al "$@" | less ;}
function grepl() { grep $COLOR_ALWAYS "$@" | less ;}

# .bash_aliases
if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

# Common typos
alias al='la'
alias vl='lv'
alias tial='tail'
alias poing='ping'
alias pign='ping'

# Common servers
alias dewclaw='ssh hipikat.org'

# ENVIRONMENT VARIABLES
export PAGER='less'
export EDITOR='vim'
export VISUAL="${EDITOR}"
export FCEDIT="${EDITOR}"
export CVSEDITOR="${EDITOR}"

export COPYFILE_DISABLE=true        # Stop problems with ghost ._ files on OS X
export LESS="-iR"                   # Ignore case when pattern is all lowercase & print raw control characters
export HISTCONTROL=ignoredups       # Ignore duplicate history entries
export TAR_OPTIONS="--exclude *.DS_Store*"

#export DYLD_LIBRARY_PATH=/usr/lib/instantclient_10_2


# PROGRAMMABLE COMPLETION
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    source /etc/bash_completion
fi


# COMMAND OPTIONS
# Make less more friendly for various files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Enable color support in various commands
if [ "$TERM" != "dumb" ]; then
    if [ -x /usr/bin/dircolors ]; then
        test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
        for cmd in ls dir vdir grep fgrep egrep
        do
            alias $cmd="$cmd --color=auto"
        done
        export COLOR_ALWAYS="--color=always"
    else
        export CLICOLOR_FORCE='TRUE'        # Probably on a Mac
        alias ls='ls -G -F'
    fi
fi


# UTILITY FUNCTIONS
function set_xterm_title () {
    echo -ne "\033]0;$1\007"
}

function set_screen_title () {
    if [[ $TERM == screen ]]; then
        echo -ne "\033k$1\033\\"
    fi
}

function set_env_variables() {
    # Replace home directories in $PWD with a ~
    local pwd_short=`echo -n $PWD | sed -e "s:\(^$HOME\):~:" | sed -e "s:\(^/home/\):~:" | sed -e "s:\(^/Users/\):~:"`
    # Truncate all but first and last three directories
    pwd_short=`echo -n $pwd_short | sed -e "s|^\(\~\?/[^/]*/[^/]*/[^/]*/\)[^/]*/.*\(/[^/]*/[^/]*/[^/]*/\?\)$|\1···\2|"`
    # Truncate any directories longer than 18 character down to 15
    pwd_short=`echo -n $pwd_short | sed -e "s|/\([^/]\{15\}\)\([^/]\{3\}\)[^/]\+|/\1···|g"`
    PWD_SHORT=$pwd_short
    unset pwd_short

    if [[ $EUID -ne 0 ]]; then
        PROMPT_COLOUR=`echo -ne "1;37m"`  # White
    else
        PROMPT_COLOUR=`echo -ne "1;31m"`  # Red
    fi

    if [[ -n $WINDOW ]]; then
        WINDOW_NUMBER="$WINDOW) "
    else
        WINDOW_NUMBER=""
    fi

    VCS_BRANCH=`git branch --no-color 2> /dev/null | grep -e '\* ' | sed 's/^..\(.*\)/ \*\1/'`
}


# PROMPTS AND WINDOW TITLES
PS1='\[\033[1;32m\]${WINDOW_NUMBER}\[\033[0;32m\]\u@${HOST_ALIAS:-\h}\[\033[0m\]:\[\033[0;34m\]$PWD_SHORT\[\033[0;36m\]$VCS_BRANCH \[\033[${PROMPT_COLOUR}\]# \[\033[m\]'
PS2='\[\033[01;32m\] >\[\033[0;37m\] '
bash_interactive_mode=""

function pre_prompt() {
    set_env_variables
    set_xterm_title "$USER@$HOST_ALIAS"
    set_screen_title "$HOST_ALIAS $PWD_SHORT #"

    bash_interactive_mode="yes"
}
PROMPT_COMMAND=pre_prompt       # Installs pre_prompt to run before the prompt is displayed

# Executed before each command; returns early if not being run interactively
function pre_execute() {
    if [[ -n "$COMP_LINE" ]]; then
        # We're inside a completer so we can't be running interactively
        return
    fi
    if [[ -z "$bash_interactive_mode" ]]; then
        # Doing something related to displaying the prompt; let the prompt set the tile
        return
    else
        if [[ 0 -eq "$BASH_SUBSHELL" ]]; then
            # If in a subshell, the prompt won't be re-displayed to put us back in interactive mode
            bash_interactive_mode=""
        fi
    fi
    if [[ "$BASH_COMMAND" == "pre_prompt" ]]; then
        # Consecutive prompts; switch out of interactive and don't trace commands in pre_prompt
        bash_interactive_mode=""
        return
    fi

    # If we get this far, the command should be interactive
    # We use history instead of BASH_COMMAND so we can get a full command including pipes
    set_env_variables
    local this_command=`history 1 | sed -e "s/^[ ]*[0-9]*[ ]*//g"`;

    set_screen_title "$HOST_ALIAS $PWD_SHORT \$ $this_command"

    # Return the terminal to its default colour; the prompt may have changed it
    echo -en "\033[00m"
}
trap 'pre_execute' DEBUG

# Django bash completion
if [ -f ~/.django_bash_completion.sh ]; then
    source ~/.django_bash_completion.sh
fi



#PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
[[ -r $rvm_path/scripts/completion ]] && . $rvm_path/scripts/completion


# Activate Virtualenvwrapper

. /usr/local/bin/set_chippery_env.sh 2>/dev/null

if ! pyenv virtualenvwrapper 2>/dev/null
    then . /usr/local/bin/virtualenvwrapper.sh
fi
#. /usr/local/bin/virtualenvwrapper.sh
