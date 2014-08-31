###
# .bashrc for Adam Wright <adam@hipikat.org>
###
# Do nothing if not running interactively
[ -z "$PS1" ] && return

### Constants
##########################################
# Shell colours

# Reset
Color_Off='\e[0m'       # Text Reset

# Regular Colors
Black='\[\e[0;30m\]'        # Black
Red='\[\e[0;31m\]'          # Red
Green='\[\e[0;32m\]'        # Green
Yellow='\[\e[0;33m\]'       # Yellow
Blue='\[\e[0;34m\]'         # Blue
Purple='\[\e[0;35m\]'       # Purple
Cyan='\[\e[0;36m\]'         # Cyan
White='\[\e[0;37m\]'        # White

# Bold
BBlack='\[\e[1;30m\]'       # Black
BRed='\[\e[1;31m\]'         # Red
BGreen='\[\e[1;32m\]'       # Green
BYellow='\[\e[1;33m\]'      # Yellow
BBlue='\[\e[1;34m\]'        # Blue
BPurple='\[\e[1;35m\]'      # Purple
BCyan='\[\e[1;36m\]'        # Cyan
BWhite='\[\e[1;37m\]'       # White

# Underline
UBlack='\[\e[4;30m\]'       # Black
URed='\[\e[4;31m\]'         # Red
UGreen='\[\e[4;32m\]'       # Green
UYellow='\[\e[4;33m\]'      # Yellow
UBlue='\[\e[4;34m\]'        # Blue
UPurple='\[\e[4;35m\]'      # Purple
UCyan='\[\e[4;36m\]'        # Cyan
UWhite='\[\e[4;37m\]'       # White

# Background
On_Black='\[\e[40m\]'       # Black
On_Red='\[\e[41m\]'         # Red
On_Green='\[\e[42m\]'       # Green
On_Yellow='\[\e[43m\]'      # Yellow
On_Blue='\[\e[44m\]'        # Blue
On_Purple='\[\e[45m\]'      # Purple
On_Cyan='\[\e[46m\]'        # Cyan
On_White='\[\e[47m\]'       # White

# High Intensity
IBlack='\[\e[0;90m\]'       # Black
IRed='\[\e[0;91m\]'         # Red
IGreen='\[\e[0;92m\]'       # Green
IYellow='\[\e[0;93m\]'      # Yellow
IBlue='\[\e[0;94m\]'        # Blue
IPurple='\[\e[0;95m\]'      # Purple
ICyan='\[\e[0;96m\]'        # Cyan
IWhite='\[\e[0;97m\]'       # White

# Bold High Intensity
BIBlack='\[\e[1;90m\]'      # Black
BIRed='\[\e[1;91m\]'        # Red
BIGreen='\[\e[1;92m\]'      # Green
BIYellow='\[\e[1;93m\]'     # Yellow
BIBlue='\[\e[1;94m\]'       # Blue
BIPurple='\[\e[1;95m\]'     # Purple
BICyan='\[\e[1;96m\]'       # Cyan
BIWhite='\[\e[1;97m\]'      # White

# High Intensity backgrounds
On_IBlack='\[\e[0;100m\]'   # Black
On_IRed='\[\e[0;101m\]'     # Red
On_IGreen='\[\e[0;102m\]'   # Green
On_IYellow='\[\e[0;103m\]'  # Yellow
On_IBlue='\[\e[0;104m\]'    # Blue
On_IPurple='\[\e[0;105m\]'  # Purple
On_ICyan='\[\e[0;106m\]'    # Cyan
On_IWhite='\[\e[0;107m\]'   # White


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

set_xterm_title () {
    echo -ne "\033]0;$1\007"
}

set_screen_title () {
    if [[ $TERM == screen ]]; then
        echo -ne "\033k$1\033\\"
    fi
}

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
# extdebug       Enable behavior intended for debuggers (for trap 'prepare_execute' DEBUG)

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


### Environment
##########################################
export PAGER='less'
export EDITOR='vim'
export VISUAL="${EDITOR}"
export FCEDIT="${EDITOR}"
export CVSEDITOR="${EDITOR}"

export COPYFILE_DISABLE=true        # Stop problems with ghost ._ files on OS X
export LESS="-iR"                   # Ignore case when pattern is all lowercase & print raw control characters
export HISTCONTROL=ignoredups       # Ignore duplicate history entries
export TAR_OPTIONS="--exclude *.DS_Store*"

### I don't even
##########################################

# Lesspipe is an input filter to less for compressed files and highlighting etc.
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








########## unclean.........



function set_env_variables() {
    # Replace home directories in $PWD with a ~
    #local pwd_short=`echo -n $PWD | sed -e "s:\(^$HOME\):~:" | sed -e "s:\(^/home/\):~:" | sed -e "s:\(^/Users/\):~:"`
    # Truncate all but first and last three directories
    #pwd_short=`echo -n $pwd_short | sed -e "s|^\(\~\?/[^/]*/[^/]*/[^/]*/\)[^/]*/.*\(/[^/]*/[^/]*/[^/]*/\?\)$|\1···\2|"`
    # Truncate any directories longer than 18 character down to 15
    #pwd_short=`echo -n $pwd_short | sed -e "s|/\([^/]\{15\}\)\([^/]\{3\}\)[^/]\+|/\1···|g"`
    #PWD_SHORT=$pwd_short
    #unset pwd_short

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






    # Go to green and print window number
    if [[ -n $WINDOW ]]; then
        PS1_SCREEN="$WINDOW"
        PS1_SCREEN+=`echo -e "\xE2\x8E\xAC "`
    else
        PS1_SCREEN=""
    fi

    # Print exit status of last command if it failed
    if [[ $Last_Command != 0 ]]; then
        PS1_EXIT_STATUS="$Last_Command "
    else
        PS1_EXIT_STATUS=" "
    fi

    # If not root, print username and an '@' symbol
    if [[ $EUID != 0 ]]; then
        PS1_USERNAME="$USER@"
    else
        PS1_USERNAME=""
    fi

    # Print hostname
    if [[ -n $HOST_ALIAS ]]; then
        PS1_HOST=$HOST_ALIAS 
    else
        PS1_HOST=$HOSTNAME
    fi
    #PS1_HOST="${HOST_ALIAS:$HOSTNAME}:"

    # Print the working directory and prompt marker in blue, and reset
    # the text color to the default.
    PS1_CWD="$Blue\\w"

    # Print CVS branch
    PS1_BRANCH=`git branch --no-color 2> /dev/null | grep -e '\* ' | sed 's/^..\(.*\)/ \xE2\x98\x86 \1/'`

    # Print a red (if root) or white (otherwise) hash for a prompt
    if [[ $EUID == 0 ]]; then
        PS1_PROMPT="$Red #$Reset "
    else
        PS1_PROMPT="$White #$Reset "
    fi





}


# PROMPTS AND WINDOW TITLES

# 'N) '             GNU Screen window number
#PS1="$Green$WINDOW_NUMBER"
#PS1+=
#PS1+='$WINDOW_NUMBER\[\033[0;32m\]\u@${HOST_ALIAS:-\h}\[\033[0m\]:\[\033[0;34m\]$PWD_SHORT\[\033[0;36m\]$VCS_BRANCH \[\033[${PROMPT_COLOUR}\]# \[\033[m\]'

#$PS1+="$Color_Off"

#PS1="$PS1_SCREEN$PS1_EXIT_STATUS$PS1_USERNAME$PS1_HOST$PS1_CWD$PS1_BRANCH$PS1_PROMPT"

#PS1="$Green\$PS1_SCREEN$Red\$PS1_EXIT_STATUS$Green\$PS1_USERNAME\$PS1_HOST"
PS1="$Green\$PS1_SCREEN$Green\$PS1_USERNAME\$PS1_HOST"
PS1+="$White:$Blue\w$Cyan\$PS1_BRANCH"
PS1+="$White\$(if [[ $EUID == 0 ]]; then echo \"$Red\"; fi) #$Color_Off "

PS2='\[\033[01;32m\] >\[\033[0;37m\] '

bash_interactive_mode=""

function prepare_prompt() {
    Last_Command=$? # Must come first!



    set_env_variables

    set_xterm_title "$USER@$HOST_ALIAS"
    set_screen_title "$HOST_ALIAS $PWD #"

    bash_interactive_mode="yes"


}
PROMPT_COMMAND=prepare_prompt       # Installs prepare_prompt to run before the prompt is displayed




# Executed before each command; returns early if not being run interactively
function prepare_execute() {

    export just_another_prompt=""

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
    if [[ "$BASH_COMMAND" == "prepare_prompt" ]]; then
        # Consecutive prompts; switch out of interactive and don't trace commands in prepare_prompt
        just_another_prompt="true"
        bash_interactive_mode=""
        return
    else
        just_another_prompt=""
    fi

    # If we get this far, the command should be interactive
    # We use history instead of BASH_COMMAND so we can get a full command including pipes
    set_env_variables
    local this_command=`history 1 | sed -e "s/^[ ]*[0-9]*[ ]*//g"`;

    set_screen_title "$HOST_ALIAS $PWD \$ $this_command"

    # Return the terminal to its default colour; the prompt may have changed it
    echo -en "\033[00m"
}
trap 'prepare_execute' DEBUG

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











############ clean tail.........


### Command-line aliases
##########################################
if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

### Command-line auto-completers
##########################################
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    source /etc/bash_completion
fi


