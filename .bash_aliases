

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
function g() { grep -Iris "$@" ./ ;}
export -f g
function gh() { grep -Iis "$@" ./* ;}
export -f gh

function venv-postactivate { source $VIRTUAL_ENV/bin/postactivate; }

# Typos
alias al='la'
alias vl='lv'
alias poing='ping'
alias tial='tail'
alias sssh='ssh'
alias pign='ping'
alias whomai='whoami'


# Common command line options
alias grep='grep -I'                      # Ignore binaries, suppress errors

# Shortcuts
alias pip-upgrade='pip freeze --local | cut -d = -f 1  | xargs pip install -U'

#alias cover='coverage run --source="." $D test $@; coverage report'
function cover() {
    coverage run --source="$1" $D test "$1";
    coverage report --omit='*/_[a-z]*,*/tests/test_*';
}
export -f cover

#
alias pdt='TZ=America/Los_Angeles date'


alias such=git
alias very=git
alias wow='git status' 



alias irssi2='irssi --config=~/.irssi/config2'


alias sush='sudo -E bash'

alias gitad='git add'
alias gitbr='git branch'
alias gitch='git checkout'
alias gitcl='git clone'
alias gitco='git commit'
alias gitdi='git diff'
alias gitfe='git fetch'
alias gitlo='git log'
alias gitre='git remote'
alias gitst='git status'

alias grp='grep --color=always'

alias myip="curl -s icanhazip.com"

alias slt='salt --force-color'

alias scr='screen -D -R'    # Attach here and now
#alias sudoe='sudo -E'
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
function dosls() {
    salt "$1" state.sls "${@:2}"
}
function dosass() {
    cd "src/styles"
    eval "bundle exec compass watch &"
    cd "../.."
}
function runsrv() {
    eval "django-admin.py runserver "$@" --traceback"
}

alias fuck='sudo $(history -p \!\!)'


alias blind-ssh='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'

function hpk-burrow() {
    old_pwd=$PWD
    mkdir -p /tmp/hpk-burrow
    cd /tmp/hpk-burrow
    nohup ssh -fNR $HPK_SSH_PORT:localhost:22 hipikat@hpk.io
    cd $old_pwd
}
