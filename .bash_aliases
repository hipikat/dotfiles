export UNAME=`uname`

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

# supervisor
alias sv='sudo supervisorctl'

# l == ls -l ... (but filtering out junk files)
l() {
    if [ "$1" = "s-al" ]; then
        ls -al ${*:2}
    elif [ "$UNAME" = "Darwin" ]; then
        ls -l "$@" | grep -v '\(\.swp\|\.pyc\)$';
    else
        ls -l --color=always "$@" | grep -v '\(\.swp\|\.pyc\)$';
    fi  
}
export -f l

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
