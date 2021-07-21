###
# .bash_aliases
#
# 0.    Setup
# 1.    Convenience aliases
# 1.1.  Aliases affecting default program behaviour
# 2.    Emulate missing Gnu Coreutils
# 3.    Shell Builtin overrides 
# 4.    POSIX command overrides
# 5.    Typos
# 6.    Operating system consistency
# 10.   Functions
#
# By Ada Wright <ada@hpk.io>
# https://github.com/hipikat/dotfiles 
# Packaged under the BSD 2-Clause License
###


### 0. Setup
##########################################

# Colours
NC='\e[0m'          # No colour
GREY='\e[0;37m'

# Emoji
EMJ_SHELL='\U1F41A'
EMJ_SNAKE='\U1F40D'


# Command proxy - all shell commands should be passed in here; they will be
# printed and then only evaluabed if we weren't passed a --dry-run flag
SHELL__run_PREFIX="$EMJ_SHELL "
function _run() {
    printf "\n$GREY"
    printf $"$SHELL__run_PREFIX"
    echo "$@"
    printf "$NC"
    eval $@
}



### 1. Convenience alises
##########################################
alias src='_run source ~/.bashrc'

# Homebrew - br*
alias brc='_run brew cleanup'
alias brd='_run brew doctor'
alias bri='_run brew install'
alias brif='_run brew info'
alias brl='_run brew list'
alias brlg='_run "brew list | grep -i"'
alias bru='_run brew update && _run brew upgrade --dry-run'
alias bru!='_run brew upgrade'
alias brU!='_run brew unpin bash pyenv vim && _run brew upgrade && _run brew pin bash pyenv vim'
alias brun='_run brew uninstall'
alias brs='_run brew search'

alias cd..='cd ..'

alias clr='clear'

compress-pdf() {
    if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
        echo 'Usage: compresspdf INPUT_FILE OUTPUT_FILE [screen|ebook|printer|prepress]'
    else
        _run gs -sDEVICE=pdfwrite -dNOPAUSE -dQUIET -dBATCH -dPDFSETTINGS=/${3:-"screen"} -dCompatibilityLevel=1.4 -sOutputFile="$2" "$1"
    fi
}

# Colourise cat
alias cct='pygmentize -O style=monokai -f console256 -g'

alias cpr='cp -r'

# Cut-to-window (column width)
alias ctw='cut -c1-$(tput cols)'

function dif() {
    _run colordiff -w "$@" | less -R
}
alias dif3='_run dif -C3'

# Dispense from the UCC Coke machine
#  - http://wiki.ucc.asn.au/Dispense
alias dis='_run dispense'

alias dfh='_run df -h'

#alias dja='_django-admin'
alias dja='django-admin'


###
# Docker
alias dat='_run docker attach'
alias dbl='_run docker build'
function dbl.t() {
    _run docker build --tag "$1" ${1:.}
}
#alias dbl.t='_run docker build --target'
function dbl.tt() {
    local tag="$1"
    local target="${2:-$tag}"
    local path="${3:-.}"
    _run docker build --tag "$tag" --target "$target" $path
}
alias dcm='_run docker-compose'
alias dcmb='_run docker-compose build'
alias dcmx='_run docker-compose exec'
#function dcm.b() {
#    _run docker-compose exec $@ npm run watch:build
#}
#function dcm.bd() {
#    docker-compose exec $@ npm run watch:build:debug
#}
#function dcm.bp() {
#    docker-compose exec $@ npm run watch:build:prod
#}
alias dcmr='_run docker-compose run'
alias dcmr.p='_run docker-compose run --service-ports'
alias dcmr.pn='docker-compose run --service-ports --name'
alias dcmr.rm='_run docker-compose run --rm'
alias dcmr.rmn='docker-compose run --rm --name'
alias dcmr.prm='_run docker-compose run --service-ports --rm'
alias dcmr.prmn='docker-compose run --service-ports --rm --name'
alias dcmu='_run docker-compose up'
alias dcmu.b='_run docker-compose up --build'
alias dcmu.d='_run docker-compose up --detach'
alias dcmu.bd='_run docker-compose up --build --detach'
alias dcmd='_run docker-compose down'
function dcm-m() {
    _run docker-compose exec $@ pipenv run manage migrate
}
function dcm-mm() {
    _run docker-compose exec $@ pipenv run manage makemigrations
}
function dcm-mmm() {
    _run docker-compose exec $@ pipenv run manage makemigrations
    _run docker-compose exec $@ pipenv run manage migrate
}

alias dcn='_run docker container'
alias dcns='_run docker container ls'
alias dpl='_run docker pull'
alias dx='_run docker exec'
alias dx.it='_run docker exec -it'
function dxsh() {
  _run docker exec -it $@ /bin/bash
}
alias dxsh.="dxsh --user=$(whoami)"
alias dxsh-mount-src="dxsh. -v $(pwd)/src:/app/src"
alias dim='_run docker image'
alias dims='_run docker images'
alias dimi='_run docker image inspect'
alias dimrm='_run docker image rm'
function dim-rm-dangling() {
    _run docker rmi $(docker images --filter dangling=true -q)
}

alias dmac='_run docker-machine'
alias dmacc='_run docker-machine create'
alias dmacc.vb='_run docker-machine create -d virtualbox'
alias dmace='_run docker-machine env'

alias dntl='_run docker network ls'
alias dnti='_run docker network inspect'
alias dntrm='_run docker network rm'
alias dntc='_run docker network create'
alias dntco='_run docker network connect'

alias dps='_run docker ps'
alias drn='_run docker run'
alias drn.it='_run docker run -it'
alias drn.itrm='_run docker run -it --rm'
alias dsi='_run docker system info'
alias dsp='_run docker system prune'
alias dsp!='_run docker system prune --force'
alias dst='_run docker start'
function dstat() {
  _run docker start $@
  _run docker attach $@
}
function drnsh() {
  _run docker run -it $@ /bin/bash
}
alias drnsh.="drnsh --user=$(whoami)"
alias drnsh.mount-src="drnsh. -v $(pwd)/src:/app/src"
alias dvi="_run docker volume inspect"
alias dvl="_run docker volume ls"
alias dvrm="_run docker volume rm"


# Digital ocean api
function do-api() {
    curl -s \
      -X GET \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $(grep 'DIGITAL_OCEAN_ACCESS_TOKEN' ~/dev/hpk/secrets.conf | cut -f2 -d"=")" \
      "https://api.digitalocean.com/v2/$@" | jq -C | less -F
}
function dom.create() {
    docker-machine create --driver digitalocean \
        --digitalocean-access-token $(grep 'DIGITAL_OCEAN_ACCESS_TOKEN' ~/dev/hpk/secrets.conf | cut -f2 -d"=") \
        --digitalocean-backups=false \
        --digitalocean-image 72067660 \
        --digitalocean-region sgp1 \
        --digitalocean-size 1gb \
        --digitalocean-ssh-key-fingerprint "fa:fd:ae:da:0e:c7:79:f6:d6:bd:42:a3:24:d3:c7:c8" \
        --digitalocean-ssh-user "root" \
        --engine-install-url "https://releases.rancher.com/install-docker/19.03.9.sh" \
        `adjspecies`
}
alias dom.rm='docker-machine rm -y -f'

# Fake TTY
function fty() {
    script -qfec "$(printf "%q " "$@")"
}

# Re-execute the last command, but prefix it with 'sudo'
alias fuck='sudo $(history -p \!\!)'

# Grep shortcuts
function _grep() {
    # If grepping recursively, and just a search term is
    # given, defualt to searching the current directory.
    if [[ "$#" -eq "2" && $1 == *"r"* ]]; then
        grep --color=always "$@" ./
    else
        grep --color=always "$@"
    fi
}
function __grep() {
    # If grepping recursively, and just a search term is
    # given, defualt to searching the current directory.
    if [[ "$#" -eq "3" && $1 == *"r"* ]]; then
        _run grep --color=always "$@" ./
    else
        _run grep --color=always "$@"
    fi
}
alias g='_grep -I'          # I: ignores binary files
alias gn='_grep -In'        # n: print line numbers
alias gi='_grep -Ii'        # i: case insensitive
alias giv='_grep -Iiv'      # v: invert matching
alias gr='_grep -Ir'        # r: recursive
alias grn='_grep -Irn'
alias grnn='_grep -Ir --exclude-dir=node_modules'
alias grnnn='_grep -Irn --exclude-dir=node_modules'
alias gv='_grep -Iv'
alias gin='_grep -Iin'
alias grn='_grep -Irn'
alias gir='_grep -Iri'
alias girv='_grep -Iriv'
alias girn='__grep -Irin'
alias girnn='__grep -Iri --exclude-dir=node_modules'
alias girnnn='__grep -Irin --exclude-dir=node_modules'
alias glb='grep --line-buffered'    # Stream into pipes

# Git shortcuts
function git-get_remote_branches() {
    _REMOTE=${1-origin}
    git remote set-branches $_REMOTE '*'
    git fetch -vvv
}
function gad() {
    if [ "$#" -eq "0" ]; then
        git add .
    else
        git add "$@"
    fi
}
function gAd() {
    if [ "$#" -eq "0" ]; then
        git add -A .
    else
        git add -A "$@"
    fi
}
function _git_clone_github() {
    # TODO: If '/' not in $1, use "$1/$1"
    git clone git@github.com:$1.git ${@:2}
}
function _git_clone_my_github() {
    git clone git@github.com:${DEFAULT_USER:-$USER}/$1.git ${@:2}
}
function _git_commit_n_push() {
    if git commit "$@"; then
        git push
    fi
}
function _git_diff_commit() {
    # Diff a commit and the commit N behind it in the tree
    #
    # Usage: _git_diff_commit [commit] [commits_behind]
    # - commit defaults to HEAD
    # - commits_behind defaults to '1'
    target_commit=${1:-HEAD}
    commits_behind=${2:-1}
    git diff --color=always $target_commit^$commits_behind $target_commit
}
function _git_log_author() {
    git log --color=always --author="$@"
}
function _git_log_author_stat() {
    git log --color=always --author="$@" --stat
}
#alias git.resetlocks='git reset Pipfile.lock'
#alias gam='git commit --amend'
function gam() {
    if [ "$#" -eq "0" ]; then
      git commit --amend
    else
      git commit --amend -m "@"
    fi
}
function gbru() {
    branch=$(git symbolic-ref HEAD)
    branch=${branch##refs/heads/}
    git branch --set-upstream-to=$1/$branch $branch
}
alias gbl='_run git blame'
alias gbr='_run git branch --color=always'
alias gbra='_run git branch --color=always -a'
alias gbrav='_run git branch --color=always -av'
alias gbrd='_run git branch --color=always -d'
alias gbrD='_run git branch --color=always -D'
alias gbrv='_run git branch --color=always -v'
alias gch='_run git checkout'
alias gchb='_run git checkout -b'
alias gcht='_run git checkout -t'
alias gcl='_run git clone'
alias gclgh='_git_clone_github'
alias gclmy='_git_clone_my_github'
alias gco='_run git commit'
alias gcop='_git_commit_n_push'
alias gcoa='_run git commit -a'
alias gcoap='_git_commit_n_push -a'
alias gcom='_run git commit -m'
alias gcomp='_git_commit_n_push -m'
alias gcoam='_run git commit -am'
alias gcoAm='git add -A; git commit -am'
alias gcoamp='_git_commit_n_push -am'
alias gcoAmp='git add -A; _git_commit_n_push -am'
alias gcp='git cherry-pick'
alias gcpn='git cherry-pick -n'
alias gdi='git diff --color=always'
alias gdic='git diff --color=always --cached'
alias gdico='_git_diff_commit'
alias gfe='git fetch'
alias glo='git log'
alias gloa='_git_log_author'
alias gloas='_git_log_author_stat'
alias glos='git log --stat'
alias gmr='git merge'
alias gmv='git mv'
alias gpl='git pull'
alias gps='git push'
alias gpsu='git push --set-upstream'
alias grea='git remote add'
alias gre='git remote'
alias grev='git remote -v'
alias grer='git remote rename'
alias grerm='git remote remove'
alias grm='git rm'
alias grmc='git rm --cached'
alias grs='git reset'
alias gsh='git show'
alias gst='git -c color.status=always status'
alias gstsh='git stash'
alias gta='git tag'
alias gwt='git worktree'
alias gwtrm='git worktree remove'
alias gwtl='git worktree list'
function gwta() {
    # Check out a git worktree in a sibling directory
    # Usage: gwta BRANCH [DIR_NAME]
    local branch=$1
    local dir="../${2:-$1}"

    if [[ "${branch%%/*}" == "remotes" ]]; then
        local track="--track -b ${branch##*/}"
    fi
    git worktree add $track $dir $branch
}

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
    __git_complete gcoAmp _git_commit
    __git_complete gdi _git_diff
    __git_complete gdic _git_diff
    __git_complete gfe _git_fetch
    __git_complete glo _git_log
    __git_complete gmr _git_merge
    __git_complete gpl _git_pull
    __git_complete gps _git_push
    __git_complete gre _git_remote
    __git_complete grev _git_remote
    __git_complete grm _git_rm
    __git_complete grmc _git_rmc
    __git_complete gshw _git_show
    __git_complete gst _git_status
    __git_complete gstsh _git_stash
    __git_complete gta _git_tag
fi

# History
alias hs='history'
alias hsg='history | grep -i'
alias hsn='history -n'          # Append new lines from the history file to history


#function hsg() {
#    # Print reversed, filtered history to .hsging1
#    history | grep -i "$@" | tac > ~/.hsging1
#    cat ~/.hsging1 | sort -uk2 | sort -nk1 | cut -f2- > ~/.hsging2
#    tac ~/.hsging2 > ~/.hsging3
#    cat ~/.hsging
#    #rm ~/.hsging*
#}

#tac stuff.txt > stuff2.txt
#cat -n stuff2.txt | sort -uk2 | sort -nk1 | cut -f2- > stuff3.txt
#tac stuff3.txt > stuff4.txt
#cat stuff4.txt


# HTTPie - a CLI, cURL-like tool for humans
alias htp='http --pretty all'

# Iptables
alias ipt='iptables'
alias iptl='iptables -L --line-numbers'
alias iptd='iptables -D'

# My *other* IRC configuration
alias irssi2='irssi --config=~/.irssi/config2'

# Command-line JSON processor (with --colour-output)
alias jq.='jq .'
alias jqc='jq -C'
alias jqc.='jq -C .'
alias j='jqc'
alias j.='jqc.'
#function jl() {
#    j "$@" | less
#}
#fucntion jl.() {
#    j. "$@" | less
#}

# Repeat the last command, piped through less
#function les() {
#    $(history -p \!\!) | less
#}


function k8-create-dashboard-token() {
    kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | awk '/^deployment-controller-token-/{print $1}') | awk '$1=="token:"{print $2}'
}
alias k8='kubectl'


alias les='less --quit-if-one-screen'

# Make a directory and change into it
function mkcd() {
    mkdir "$@"
    cd "$@"
}
alias mkd='mkdir'

alias ne.l='nodenv local'
alias ne.s='nodenv shell'
alias ne.g='nodenv global'
alias nei='nodenv install'
alias neil='nodenv install --list'
alias ner='nodenv rehash'
alias nev='nodenv version'
alias nevs='nodenv versions'
alias newi='nodenv which'
alias newe='nodenv whence'
function neilg() {
  nodenv install --list | grep "$@"
}

alias nodist='grep -v "\(\.css\|\.map\|.min\|.svg\)"'

alias npi='npm install -P'
alias npid='npm install -D'
alias npia='npm install -PD'
alias npig='npm install --global'
alias npl='npm list'
alias npl0='npm list --depth=0'
alias npl1='npm list --depth=1'
alias npu='npm update'
alias npua='npm update --dev'
alias npud='npm --depth=9999 update'
alias npuad='npm --depth=9999 update --dev'
alias npo='npm outdated'
alias npr='npm run'
alias nps='npm show'

# Common chown/chgrp shortcuts
function _own() {

    # Change files to match a user account if we're sudoing from one
    if [ -n "$SUDO_USER" ]; then
        ch_name="$SUDO_USER"
    # Or hopefully we're a user who can make the impending changes
    elif [ -n "$USER" ]; then
        ch_name="$USER"
    # Or we've gotten this far *somehow* and still need a user/group name
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
        eval chgrp $ch_ops "$ch_owners" "$ch_targets"
    else
        eval chown $ch_ops "$ch_owners" "$ch_targets"
    fi
}   # end _own()
alias own='_own b'              # Own both user and group on files
alias ownr='_own br'            # Own user and group on files, recursively
alias ownu='_own u'             # Own user flag on files
alias owng='_own g'             # Own group flag on files
alias ownur='_own ur'           # Own user flag on files, recursively
alias owngr='_own gr'           # Own group flag on files, recursively

alias pct.='pipenv run picata'
alias peg='pipenv graph'
alias pei='pipenv install'
alias pei.='pipenv install --python `pyenv which python`'
alias peid='pipenv install --dev'
alias peid.='pipenv install --dev --python `pyenv which python`'
alias pel='pipenv lock -d; pipenv lock --requirements > requirements.txt'
alias per='pipenv run'
alias perd='pipenv run django'
alias perf='pipenv run pip freeze'
alias perfl='_run "pipenv run pip freeze | wc -l"'
alias perm='pipenv run manage'
alias pe.rm='pipenv --rm'
alias perp='pipenv run python'
alias pers='pipenv run server'
alias persh='pipenv run shell'
alias pesh='pipenv shell'


alias pye='pyenv'
alias pyei='pyenv install'
alias pyev='pyenv version'
alias pyevs='pyenv versions'
alias pyel='pyenv install -list | less'
alias depe='deactivate ; exit'

alias pg_ctl-mac='sudo -u postgres /Library/PostgreSQL/12/bin/pg_ctl'
alias pg_ctl-mac-stop='sudo -u postgres /Library/PostgreSQL/12/bin/pg_ctl -U postgres stop -D /Library/PostgreSQL/12/data'
alias pg_ctl-mac-start='sudo -u postgres /Library/PostgreSQL/12/bin/pg_ctl -U postgres start -D /Library/PostgreSQL/12/data'

alias pif='_run pip freeze'
alias pifl='_run pip freeze | wc -l'

alias pmn='python manage.py'
alias pmsh='python manage.py shell'

alias psa='ps aux'
alias psg='ps aux | grep -i'

alias pst='pstree -UpaunZ | less --quit-if-one-screen'

alias rmr='rm -R'
alias rmf='rm -f'
alias rmrf='rm -Rf'

function run() {
    for file in $(ls .); do
        if [[ -f "$file" && -x "$file" && "$file" =~ ^run ]]; then
            ./"$file" ${@:1}
            return $?
        fi
    done
    echo 'No run command found!'
    return 1
}

alias scpr='scp -r'

# Screen shortcuts
# `scr` is at https://github.com/hipikat/dotfiles/blob/master/.bin/scr
# It is very handy.
alias scrl='screen -list'
alias scrx='screen -x'

# Useful Sed filters
alias sed-fail="sed -n -e '/\[\(CRITICAL\|WARNING\) *\]/,/\[\(DEBUG\|INFO\) *\]/ { /\[\(DEBUG\|INFO\) *\]/b; p }'"



# Show a command
function shw() {
    _TYPE=$(type $1 &> /dev/null)
    if [ $? -eq 1 ]; then
        echo $1 not found.
        return 1
    else
        _TYPE=$(type $1 | head -n 1)
    fi

    # Type describes aliases and functions by default
    if [[ "$_TYPE" =~ aliased\ to|a\ function ]]; then
        type $1
    elif [[ "$_TYPE" =~ $1\ is\ / ]]; then
        type $1
        _FILE=$(file $1)
        if [[ "$_FILE" =~ ASCII ]]; then
            cat $(type -p $1)
        else
            echo "$_FILE"
        fi
    # Not sure what this is. Could be a binary. Just use the default.
    else
        type $1
    fi
}

alias slt='salt --force-color'
function slt.() {
    salt --force-color "${HOSTNAME:-`hostname`}" "${@:1}"
}
function slt..() {
    salt --force-color \* "${@:1}"
}
function slt.apply() {
    slt. state.apply "$@"
}
function slt..apply() {
    slt.. state.apply "$@"
}
function slt.ping() {
    slt. test.ping
}
function slt..ping() {
    slt.. test.ping
}
function slt.doc() {
    slt. sys.doc "$@" | less
}
function slt.high() {
    if [ "$#" -ge "1" ]; then
        salt --force-color "${@}" state.highstate
    else
        salt --force-color "${HOSTNAME:-`hostname`}" state.highstate
    fi
}
#function slt.pil() {
#    if [ "$#" -ge "1" ]; then
#        salt --force-color "${HOSTNAME} pillar.get
#}
alias slt.refresh_pillar='slt. saltutil.refresh_pillar'
alias slt..refresh_pillar='slt.. saltutil.refresh_pillar'
alias slt..high='slt.. \* state.highstate'


alias sltapi='salt-api --force-color'
alias sltcld='salt-cloud --force-color'
alias sltcll='salt-call --force-color'
alias sltcp='salt-cp --force-color'
alias sltkey='salt-key --force-color'
alias sltrun='salt-run --force-color'
alias sltssh='salt-ssh --force-color'
function slt-cln() {
    # Clean out Salt caches before running a `salt` command
    salt-run cache.clear_all
    if [ "$#" -ge "1" ]; then
        salt "$1" saltutil.clear_cache
        if [ "$#" -gt "1" ]; then
            salt --force-color "${@}"
        fi
    fi
}
function slt-run() {
    salt-run --force-color "${@}"
}

alias sshffs='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'

alias sush='sudo -E bash'       # TODO: Use $SHELL if set

alias sup='supervisorctl'
alias supt='supervisorctl tail'
alias suptf='supervisorctl tail -F'

#alias syu='synergy-up-home'
alias syu='synergy-up'

function tdy() {
    # Use default options, don't let attribute/values wrap, reduce
    # double-new-lines (from HTML Tidy, for 'readability') to single new lines.
    #
    # My original .htmltidy, used more for non-destructively formatting
    # single-page-in-a-line documents than for doing any actual 'tidying':
    #
    # indent: auto
    # indent-spaces: 4
    # tab-size: 4
    # show-body-only: true
    # wrap: 128
    # clean: yes
    # quiet: yes
    # quote-marks: yes
    # drop-empty-paras: no
    # fix-bad-comments: no
    # join-classes: yes
    # merge-divs: no
    # merge-spans: no
    # indent-attributes: yes
    # break-before-br: yes
    # vertical-space: yes
    tidy -config ~/.htmltidy "$@" | sed ':a;N;$!ba;s/=\n\s*/=/g;s/\n\n/\n/ig'
}
# As in `tdy`, but modify the file in-place
# Todo: Make this work when 'extra options' consitute the first words of $@
function tdym() {
    tidy -m -config ~/.htmltidy "$@"
    sed -i ':a;N;$!ba;s/=\n\s*/=/g;s/\n\n/\n/ig' "$@"
}

function tre() {
    tree -C "$@" | grep -v '\.pyc$' | less
}
export -f tre
alias tre2='tre -L 2'
alias tre3='tre -L 3'
alias tre4='tre -L 4'
alias tre5='tre -L 5'
alias tren='tre -I node_modules'
alias tren2='tre -L 2 -I node_modules'
alias tren3='tre -L 3 -I node_modules'
alias tren4='tre -L 4 -I node_modules'
alias tren5='tre -L 5 -I node_modules'


alias tlf='tail -F'

alias trf='_run terraform'
alias trfi='_run terraform init'
alias trfp='_run terraform plan'
alias trfP='_run terraform plan -out'
alias trfa='_run terraform apply'

function typ() {
    #type_p_out=$(type -p "$@")
    #if [ "$?" -eq "0" ] && [ -z "$type_p_out" ]; then
    #    if type "$@" | grep 'is aliased to'; then
    #fi

    type -p "$@"
}
export -f typ

alias ufwd='ufw delete'
alias ufws='ufw status'
alias ufwsn='ufw status numbered'
alias ufwsv='ufw status verbose'

alias upd='updatedb'
alias upt='uptime'

alias wcc='wc -c'
alias wcl='wc -l'
alias wcw='wc -w'

### 1.1. Aliases affecting default program behaviour

alias vim='vim -p'      # Open files in tabs


### 2. Emulate missing Gnu Coreutils
##########################################

# Tacocat is a palindrome. Tac is cat, reversed.
if ! type tac >/dev/null 2>&1; then
    # Homebrew installs Gnu Coreutils with a 'g' prefix by default
    if type gtac >/dev/null 2>&1; then
        function tac() { gtac "$@"; }
    else
        function tac() {
            awk '{a[i++]=$0} END {for (j=i-1; j>=0;) print a[j--] }' -;
        }   
    fi  
    export -f tac 
fi


### 3. Shell Builtin overrides
##########################################

function cd() {
    # Usage: `cd ..3` will take you back 3 directories.
    # Otherwise, it's business as usual.
    # TODO: '..2/minion', for example, should work. With completion.
    # TODO: ignore second 'cd' if `cd cd foo` :P
    # TODO: `cd ....` should be equivalent to `cd ..4`
    if [[ "$1" =~ ^\.\.[0-9]+$ ]]; then
        dirs_rootward="${1#..}"
        back_string=
        for ((n=0; n<$dirs_rootward; n++)); do
            back_string="$back_string../"
        done
        builtin cd "$back_string"
    else
        builtin cd "$@"
    fi

    # Look for autoenv scripts *after* we've successfully changed directories
    #if [[ "$(type autoenv_init 2>/dev/null | head -n 1)" == "autoenv_init is a function" ]]; then
    #    autoenv_init
    #fi

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


### 5. Typos - usually typed in anger
##########################################

# NB: Do not add until you've seen it multiple times in the wild.
alias :q="echo I think you\'re already out of it, dude."
alias :qa="echo '(╯°□°）╯︵ ┻━┻'"
alias :w="echo \"/bin/bash\" 523L, 12398C written \(j/k\)"
alias al='la'
alias burp='brup'       # `brew up` alias
alias chwon='chown'
alias hsot='host'
alias hsto='host'
alias grpe='grep'
alias im='vim'
alias ir='gir'
alias ivm='vim'
alias pign='ping'
alias piong='ping'
alias poing='ping'
alias poip='pip'
alias rew='brew'
alias tial='tail'
alias screne='screen'
alias sssh='ssh'
alias vin='vim'
alias vl='lv'           # ls (visible, vertical & verbose)
alias whomai='whoami'
alias wpd='pwd'


### 6. Operating system consistency
##########################################

if [ "$BASIC_MACHINE_TYPE" = "Mac" ] && ! type updatedb &>/dev/null; then
    # NB: If your PATH is defaulting commands to Homebrew's set of Gnu
    # Coreutils, locate.updatedb will just throw errors; you need something
    # like: `export PATH=/usr/bin:/bin:$PATH`
    alias updatedb="sudo -E /usr/libexec/locate.updatedb"
fi


### 10. Functions
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
        alias ls='ls -Fh --color=auto'       # Traditional unix options
    else 
        export CLICOLOR_FORCE='TRUE'
        alias ls='ls -Gh -F'                 # Probably on a Mac
    fi
fi

# Some more ls aliases
#alias lv='l -l'            # ls (visible, vertical & verbose)
#alias les='l | less'        # List piped through less
alias la='l -a'             # List all
alias las='l -a | less'     # List all piped through less
#function lvl() { ls $COLOR_ALWAYS -l "$@" | less ;}
#function lal() { ls $COLOR_ALWAYS -Al "$@" | less ;}
function grepl() { grep $COLOR_ALWAYS "$@" | less ;}

# supervisor
alias sv='sudo supervisorctl'

# l == ls -l ... (but filtering out junk files)
function l() {
    if [ "$1" = "s-al" ]; then
        ls -al ${*:2}
    elif [ `uname` = "Darwin" ]; then
        ls -l --color=always "$@" | grep -v '\(\.swp\|\.pyc\)$';
    else
        ls -l --color=always "$@" | grep -v '\(\.swp\|\.pyc\)$';
    fi  
}
export -f l

function ll() {
    l "$@" | less
}

# d == django-admin.py ...
#function d() { django-admin.py "$@" ;}
#export -f d

# f == find ./ -iname ...
function f() {
    find . -iname "*$@*"
    #if [ "$#" -eq 0 ] ; then
    #    find ./ -iname "*"
    #else
    #    find ./ -iname "*$@*"
    #fi
}
export -f f
#alias f='eval $(find ./ -iname "*$@*")'


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
#function runsrv() {
#    eval "django-admin.py runserver "$@" --traceback"
#}



