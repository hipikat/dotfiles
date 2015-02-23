###
# .bash_aliases
#
# 1.    Emulate missing Gnu Coreutils
# 2.    Convenience aliases
# 2.1.  Aliases affecting default program behaviour
# 3.    Shell Builtin overrides 
# 4.    POSIX command overrides
# 5.    Typos
#
# Originally packaged under the BSD 2-Clause License at
# https://github.com/hipikat/dotfiles by Adam Wright <adam@hipikat.org>
###


### 1. Emulate missing Gnu Coreutils
##########################################

# Tacocat is a palindrome. Tac is cat, reversed.
if ! type tac >/dev/null 2>&1; then
    # Happens under Homebrew
    if type gtac >/dev/null 2>&1; then
        function tac() { gtac "$@"; }
    else
        function tac() { awk '{a[i++]=$0} END {for (j=i-1; j>=0;) print a[j--] }' -; }
    fi
    export -f tac
fi
    

### 2. Convenience alises
##########################################

# Re-execute the last command with 'sudo' appended
alias fuck='sudo $(history -p \!\!)'

# Common grep call shortcuts
function _grep() {
    # If recursive and just a search term is given, defualt to ./
    if [[ "$#" -eq "2" && $1 == *"r"* ]]; then
        grep --color=always "$@" ./
    else
        grep --color=always "$@"
    fi
}
alias g='_grep -I'          # -I ignores binary files
alias gi='_grep -Ii'
alias gr='_grep -Ir'
alias gir='_grep -Iri'

# Etcetera

alias gad='git add';            __git_complete gad _git_add
alias gbr='git branch';         __git_complete gbr _git_branch
alias gch='git checkout';       __git_complete gch _git_checkout
alias gcl='git clone';          __git_complete gcl _git_clone
alias gco='git commit';         __git_complete gco _git_commit
alias gdi='git diff';           __git_complete gdi _git_diff
alias gfe='git fetch';          __git_complete gfe _git_fetch
alias glo='git log';            __git_complete glo _git_log
alias gpl='git pull';           __git_complete gpu _git_pull
alias gps='git push';           __git_complete gpu _git_push
alias gre='git remote';         __git_complete gre _git_remote
alias gst='git status';         __git_complete gst _git_status



alias irssi2='irssi --config=~/.irssi/config2'

alias sush='sudo -E bash'


### 2.1. Aliases affecting default program behaviour

alias vim='vim -p'      # Open files in tabs

# Mostly, short 'hand-typed' alises just force colour, for piping to less
alias slt='salt --force-color'
alias sltssh='salt-ssh --force-color'


### 3. Shell Builtin overrides
##########################################

function cd() {
    # Usage: `cd ..3` will take you back 3 directories.
    # Otherwise, it's business as usual.
    # TODO: '..2/minion', for example, should work
    if [[ "$1" =~ ^..[0-9]+$ ]]; then
        dirs_rootward="${1#..}"
        back_string=
        for ((n=0; n<$dirs_rootward; n++)); do
            back_string="$back_string../"
        done
        builtin cd "$back_string"
        unset back_string
    else
        builtin cd "$@"
    fi
}


### 4. POSIX command overrides
##########################################

function tar() {
    extra_options=
    # Exclude localisation and Desktop Services Store files on Macs
    if [ "$BASIC_MACHINE_TYPE" = "Mac" ]; then
        extra_options+=" --exclude .DS_Store --exclude .localized "
    fi
    command -p tar $extra_options "$@"
}


### 5. Typos
##########################################
alias al='la'
alias vl='lv'
alias poing='ping'
alias tial='tail'
alias sssh='ssh'
alias pign='ping'
alias ivm='vim'
alias whomai='whoami'




##########################################
### unclean...

# Enable color support of ls and also add handy aliases
if [ "$TERM" != "dumb" ]; then
    if [ -f /usr/bin/dircolors ]; then
        eval "`dircolors -b`"
        alias ls='ls -F --color=auto'       # Traditional unix options
    else 
        export CLICOLOR_FORCE='TRUE'
        alias ls='ls -G -F'                 # Probably on a Mac
    fi
fi

# Some more ls aliases
alias lv='ls -l'            # List Visible, Vertical & Verbose
alias lvs='ls -l | less'    # (again, but piped through less)
alias la='ls -Al'           # List All, with details
alias las='ls -Al | less'   # (and again, also piped through less)
alias lad='ls -lad ./.[^.]*'
function lvl() { ls $COLOR_ALWAYS -l "$@" | less ;}
function lal() { ls $COLOR_ALWAYS -Al "$@" | less ;}
function grepl() { grep $COLOR_ALWAYS "$@" | less ;}

# supervisor
alias sv='sudo supervisorctl'

# l == ls -l ... (but filtering out junk files)
l() {
    if [ "$1" = "s-al" ]; then
        ls -al ${*:2}
    elif [ `uname` = "Darwin" ]; then
        ls -l "$@" | grep -v '\(\.swp\|\.pyc\)$';
    else
        ls -l --color=always "$@" | grep -v '\(\.swp\|\.pyc\)$';
    fi  
}
export -f l

ll() {
    l "$@" | less
}

# d == django-admin.py ...
function d() { django-admin.py "$@" ;}
export -f d

# f == find ./ -iname ...
function f() {
    if [ "$#" -eq 0 ] ; then
        find ./ -iname "*"
    else
        find ./ -iname "$@"
    fi
}
export -f f

# g == grep -Iris ... ./
# gh == grep -Iis ... ./ (grep here)
#function g() { grep -Iris "$@" ./ ;}
#export -f g
#function gh() { grep -Iis "$@" ./* ;}
#export -f gh

function venv-postactivate { source $VIRTUAL_ENV/bin/postactivate; }




# Shortcuts
alias pip-upgrade='pip freeze --local | cut -d = -f 1  | xargs pip install -U'

#alias cover='coverage run --source="." $D test $@; coverage report'
function cover() {
    coverage run --source="$1" $D test "$1";
    coverage report --omit='*/_[a-z]*,*/tests/test_*';
}
export -f cover








alias myip="curl -s icanhazip.com"


function sudoe() {
    if [[ $# -eq 0 ]]; then
        sudo -E bash
    else
        sudo -E "$@"
    fi
}
export -f sudoe

#
function sudoeu() {
    if [[ $# -eq 1 ]]; then
        sudo -Eu "$1" bash
    else
        sudo -Eu "$@"
    fi
}
export -f sudoeu

#
function dosass() {
    cd "src/styles"
    eval "bundle exec compass watch &"
    cd "../.."
}
function runsrv() {
    eval "django-admin.py runserver "$@" --traceback"
}



alias ssh-blind='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'

