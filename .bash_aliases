###
# .bash_aliases
#
# 1.    Emulate missing Gnu Coreutils
# 2.    Convenience aliases
# 2.1.  Aliases affecting default program behaviour
# 3.    Shell Builtin overrides 
# 4.    POSIX command overrides
# 5.    Typos
# 6.    Operating system consistency
# 10.   Commands
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

# Dispense at UCC - http://wiki.ucc.asn.au/Dispense
alias dis='dispense'

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

function gad() {
    if [ "$#" -eq "0" ]; then
        git add .
    else
        git add "$@"
    fi
}
function _git_commit_n_push() {
    # Regular `git commit ...` then `git push` if it succeeds.
    if git commit "$@"; then
        git push
    fi
}
alias gbr='git branch'
alias gbra='git branch -a'
alias gbrav='git branch -av'
alias gch='git checkout'
alias gcl='git clone'
alias gco='git commit'
alias gcop='_git_commit_n_push'
alias gcoa='git commit -a'
alias gcoap='_git_commit_n_push -a'
alias gcom='git commit -m'
alias gcomp='_git_commit_n_push -m'
alias gcoam='git commit -am'
alias gcoamp='_git_commit_n_push -am'
alias gdi='git diff'
alias gdic='git diff --cached'
alias gfe='git fetch'
alias glo='git log'
alias gpl='git pull'
alias gps='git push'
alias gre='git remote'
alias grev='git remote -v'
alias grm='git rm'
alias gshw='git show'
alias gst='git status'
alias gstsh='git stash'

if type __git_complete &>/dev/null; then
    __git_complete gad _git_add
    __git_complete gbr _git_branch
    __git_complete gbra _git_branch
    __git_complete gbrav _git_branch
    __git_complete gch _git_checkout
    __git_complete gcl _git_clone
    __git_complete gco _git_commit
    __git_complete gcop _git_commit
    __git_complete gcoa _git_commit
    __git_complete gcoap _git_commit
    __git_complete gcom _git_commit
    __git_complete gcomp _git_commit
    __git_complete gcoam _git_commit
    __git_complete gcoamp _git_commit
    __git_complete gdi _git_diff
    __git_complete gdic _git_diff
    __git_complete gfe _git_fetch
    __git_complete glo _git_log
    __git_complete gpl _git_pull
    __git_complete gps _git_push
    __git_complete gre _git_remote
    __git_complete grev _git_remote
    __git_complete grm _git_rm
    __git_complete gshw _git_show
    __git_complete gst _git_status
    __git_complete gstsh _git_stash
fi

alias hist='history'
alias histg='history | grep -i'

alias irssi2='irssi --config=~/.irssi/config2'

# Common chown/chgrp shortcuts
function _own() {

    # Change files to match a user account if we're sudoing from one
    if [ -n "$SUDO_USER" ]; then
        ch_name="$SUDO_USER"
    # Or hopefully we're a user who can make the impending changes
    elif [ -n "$USER" ]; then
        ch_name="$USER"
    # Or we've fallen through to the bottom and still need a user/group name
    else
        ch_name=`whoami`
    fi
   
    # Set options ('r' is for 'recursive')
    ch_ops=
    if [[ $1 =~ .*r.* ]]; then
        ch_ops+=" -R "
    fi

    # Set owning user/group ('b' is for 'both')
    if [[ $1 =~ .*b.* ]]; then
        ch_owners="$ch_name:$ch_name"
    else
        ch_owners="$ch_name"
    fi

    # Assume current directory if no files specified
    if [ "$#" -le "1" ]; then
        ch_targets="./"
    else
        ch_targets="${@:2}"
    fi

    # Change something ('g' is for 'group')
    if [[ $1 =~ .*g.* ]]; then
        chgrp $ch_ops "$ch_owners" "$ch_targets"
    else
        chown $ch_ops "$ch_owners" "$ch_targets"
    fi
}
alias own='_own b'              # Own both user and group on files
alias ownr='_own br'            # Own user and group on files, recursively
alias ownu='_own u'             # Own user flag on files
alias owng='_own g'             # Own group flag on files
alias ownur='_own ur'           # Own user flag on files, recursively
alias owngr='_own gr'           # Own group flag on files, recursively

alias scrl='screen -list'
alias scrx='screen -x'

alias sush='sudo -E bash'       # TODO: Use $SHELL if set

alias slt='salt --force-color'
alias sltssh='salt-ssh --force-color'
alias sltkey='salt-key --force-color'
function slt-cln() {
    # Clean out Salt caches before running a `salt` command
    salt-run cache.clear_all
    if [ "$#" -ge "1" ]; then
        salt "$1" saltutil.clear_cache
        if [ "$#" -gt "1" ]; then
            salt --force-color $@
        fi
    fi
}

alias sup='supervisorctl'


### 2.1. Aliases affecting default program behaviour

alias vim='vim -p'      # Open files in tabs



### 3. Shell Builtin overrides
##########################################

function cd() {
    # Usage: `cd ..3` will take you back 3 directories.
    # Otherwise, it's business as usual.
    # TODO: '..2/minion', for example, should work. With completion.
    if [[ "$1" =~ ^\.\.[0-9]+$ ]]; then
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
alias hsot='host'
alias hsto='host'
alias ivm='vim'
alias pign='ping'
alias piong='ping'
alias poing='ping'
alias tial='tail'
alias sssh='ssh'
alias vl='lv'
alias whomai='whoami'


### 6. Operating system consistence
##########################################
if [ "$BASIC_MACHINE_TYPE" = "Mac" ]; then
    alias updatedb="sudo /usr/libexec/locate.updatedb"
fi


### 10. Commands
##########################################

function 10shells() {
    screen -S "$1" -c ~/.screen/10shells
}





##########################################
### unclean... UNCLEANNNNNN...
### a.k.a. "I hadn't read the Advanced Bash Programming guide yet".

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
function l() {
    if [ "$1" = "s-al" ]; then
        ls -al ${*:2}
    elif [ `uname` = "Darwin" ]; then
        ls -l "$@" | grep -v '\(\.swp\|\.pyc\)$';
    else
        ls -l --color=always "$@" | grep -v '\(\.swp\|\.pyc\)$';
    fi  
}
export -f l

function ll() {
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

