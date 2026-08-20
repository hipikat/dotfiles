# shellcheck disable=SC2034,SC2288   # Variables are consumed by shells sourcing this file
# cspell:disable
###
# .bash_aliases
#
# 0.    Setup
# 1.    Current commands and aliases
# 1.1.  Bat and colourised output
# 1.2.  Docker
# 1.3.  Firewalls
# 1.4.  General utilities
# 1.5.  Git
# 1.6.  Grep
# 1.7.  Homebrew
# 1.8.  History and shell sourcing
# 1.9.  JSON
# 1.10. Just
# 1.11. Listing and finding
# 1.12. Neovim
# 1.13. Node.js
# 1.14. Ownership
# 1.15. Python and Django
# 1.16. SSH
# 1.17. Sudo and system services
# 1.18. Terraform
# 1.19. Tmux
# 1.20. Tree
# 1.21. uv
# 1.22. Project Zomboid saves
# 2.    Command behaviour and compatibility
# 2.1.  Default program behaviour
# 2.2.  Emulate missing GNU Coreutils
# 2.3.  Operating system consistency
# 2.4.  POSIX command overrides
# 2.5.  Shell builtin overrides
# 3.    Typos usually typed in anger
# 4.    Suspected legacy commands
# 4.1.  DigitalOcean
# 4.2.  Docker Compose v1
# 4.3.  Docker Machine
# 4.4.  Fixed application and project shortcuts
# 4.5.  GNU Screen
# 4.6.  Kubernetes dashboard token
# 4.7.  Nodenv
# 4.8.  Old Homebrew ownership repair
# 4.9.  Older environment and Python workflows
# 4.10. PostgreSQL 12
# 4.11. Salt
# 4.12. Supervisor
# 4.13. Synergy
# 4.14. Vagrant

# By Ada Wright <ada@hpk.io>
# https://github.com/hipikat/dotfiles
# Packaged under the BSD 2-Clause License
###

### 0. Setup
##########################################

# Dotfiles I'm working on
# shellcheck disable=SC2088  # Keep literal ~ for Neovim's path display
VOLATILE_DOTFILES='~/.zshrc ~/.dotfiles/shell_utils.sh ~/.tmux.conf'

# Text Reset
Color_Off='\e[0m'       # Text Reset

# Regular Colors
Black='\e[0;30m'
Red='\e[0;31m'
Green='\e[0;32m'
Yellow='\e[0;33m'
Blue='\e[0;34m'
Purple='\e[0;35m'
Cyan='\e[0;36m'
White='\e[0;37m'

# Bold
BBlack='\e[1;30m'
BRed='\e[1;31m'
BGreen='\e[1;32m'
BYellow='\e[1;33m'
BBlue='\e[1;34m'
BPurple='\e[1;35m'
BCyan='\e[1;36m'
BWhite='\e[1;37m'

# Underline
UBlack='\e[4;30m'
URed='\e[4;31m'
UGreen='\e[4;32m'
UYellow='\e[4;33m'
UBlue='\e[4;34m'
UPurple='\e[4;35m'
UCyan='\e[4;36m'
UWhite='\e[4;37m'

# Background
On_Black='\e[40m'
On_Red='\e[41m'
On_Green='\e[42m'
On_Yellow='\e[43m'
On_Blue='\e[44m'
On_Purple='\e[45m'
On_Cyan='\e[46m'
On_White='\e[47m'

# High-intensity colors
IBlack='\e[0;90m'
IRed='\e[0;91m'
IGreen='\e[0;92m'
IYellow='\e[0;93m'
IBlue='\e[0;94m'
IPurple='\e[0;95m'
ICyan='\e[0;96m'
IWhite='\e[0;97m'

# Bold high-intensity
BIBlack='\e[1;90m'
BIRed='\e[1;91m'
BIGreen='\e[1;92m'
BIYellow='\e[1;93m'
BIBlue='\e[1;94m'
BIPurple='\e[1;95m'
BICyan='\e[1;96m'
BIWhite='\e[1;97m'

# High-intensity backgrounds
On_IBlack='\e[0;100m'
On_IRed='\e[0;101m'
On_IGreen='\e[0;102m'
On_IYellow='\e[0;103m'
On_IBlue='\e[0;104m'
On_IPurple='\e[0;105m'
On_ICyan='\e[0;106m'
On_IWhite='\e[0;107m'

# Additional styles
Blink='\e[5m'          # Blink
Dim='\e[2m'            # Dim
Inverse='\e[7m'        # Inverse/Reverse
Hidden='\e[8m'         # Hidden

# Emoji
SnakeEmoji='\U1F40D'
DoveEmoji='\U1F54A'
LizardEmoji='\U1F98E'
ShellEmoji='🐚'


# Command proxy - a constant reminder of what lies beneath the aliases
function _run() {
    printf '%b' "$White$ShellEmoji " 1>&2
    printf '%q ' "$@" 1>&2
    printf '%b\n' "$Color_Off" 1>&2
    "$@"
}

# Shell proxy for compound commands. Extra arguments become positional parameters.
function _runsh() {
    local command="$1"
    shift

    printf '%b' "$White$ShellEmoji " 1>&2
    if [ "$#" -eq 0 ]; then
        printf '%s' "$command" 1>&2
    else
        printf '(set --' 1>&2
        printf ' %q' "$@" 1>&2
        printf '; %s)' "$command" 1>&2
    fi
    printf '%b\n' "$Color_Off" 1>&2

    eval "$command"
}


### 1. Current commands and aliases
##########################################


### 1.1. Bat and colourised output
alias bat.l='bat -l'
alias bat.toml='bat -l toml'

# Pygments output helpers; fmp relies on csi.
alias cct='pygmentize -O style=monokai -f console256 -g'
alias csi='pygmentize -O style=monokai -f console256 -l'


### 1.2. Docker
alias dat='_run docker attach'
alias dbl='_run docker build'
function dbl.t() {
    _run docker build --tag "$1" "${1:.}"
}
function dbl.tt() {
    local tag="$1"
    local target="${2:-$tag}"
    local path="${3:-.}"
    _run docker build --tag "$tag" --target "$target" "$path"
}

alias dcn='_run docker container'
alias dcns='_run docker container ls'

alias dim='_run docker image'
function dim-rm-dangling() {
    while IFS= read -r image_id; do
        _run docker rmi "$image_id"
    done < <(docker images --filter dangling=true -q)
}
alias dimi='_run docker image inspect'
alias dimrm='_run docker image rm'
alias dims='_run docker images'

alias dntc='_run docker network create'
alias dntco='_run docker network connect'
alias dnti='_run docker network inspect'
alias dntl='_run docker network ls'
alias dntrm='_run docker network rm'

alias dpl='_run docker pull'
alias dps='_run docker ps'

alias drn='_run docker run'
alias drn.it='_run docker run -it'
alias drn.itrm='_run docker run -it --rm'
function drn.sh() {
  _run docker run -it "$@" /bin/bash
}
function drnsh.() {
    drn.sh --user="$(whoami)" "$@"
}
function drnsh.mount-src() {
    drnsh. -v "$(pwd)/src:/app/src" "$@"
}

alias dsi='_run docker system info'
alias dsp='_run docker system prune'
alias dsp!='_run docker system prune --force'
alias dst='_run docker start'
function dstat() {
  _run docker start "$@"
  _run docker attach "$@"
}

alias dv.c="_run docker volume create"
alias dv.i="_run docker volume inspect"
alias dv.ls="_run docker volume ls"
alias dv.pr="_run docker volume prune"
alias dv.rm="_run docker volume rm"

alias dx='_run docker exec'
alias dx.it='_run docker exec -it'
function dxsh() {
  _run docker exec -it "$@" /bin/bash
}
function dxsh.() {
    dxsh --user="$(whoami)" "$@"
}
function dxsh-mount-src() {
    dxsh. -v "$(pwd)/src:/app/src" "$@"
}


### 1.3. Firewalls
alias ipt='iptables'
alias iptd='iptables -D'
alias iptl='iptables -L --line-numbers'
alias ufwd='ufw delete'
alias ufws='ufw status'
alias ufwsn='ufw status numbered'
alias ufwsv='ufw status verbose'


### 1.4. General utilities
any_movie() {
    local movie
    if [ "$#" -ge 1 ]; then
        movie="$(find . -type f \( -iname \*.mp4 -o -iname \*.avi -o -iname \*.flv -o -iname \*.wmv \) | shuf | grep -i "$@" | tail -n 1)"
    else
        movie="$(find . -type f \( -iname \*.mp4 -o -iname \*.avi -o -iname \*.flv -o -iname \*.wmv \) | shuf | tail -n 1)"
    fi
    [ -n "$movie" ] && open "$movie"
}

alias cd..='cd ..'
alias clr='clear'
comeonnn() {
    command="$*"
    while ! eval "$command"; do
        echo "Failed to \"$command\". Retrying in 2 seconds..."
        sleep 2
    done
}
compress-pdf() {
    if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
        echo 'Usage: compresspdf INPUT_FILE OUTPUT_FILE [screen|ebook|printer|prepress]'
    else
        _run gs -sDEVICE=pdfwrite -dNOPAUSE -dQUIET -dBATCH "-dPDFSETTINGS=/${3:-screen}" -dCompatibilityLevel=1.4 -sOutputFile="$2" "$1"
    fi
}
alias cpr='cp -r'
alias ctw='cut -c1-$(tput cols)'
alias dfh='_run df -h'
function dif() {
    _runsh 'colordiff -w "$@" | less -R' "$@"
}
alias dif3='_run dif -C3'
echo_paths() {
    echo "$PATH" | tr ':' '\n'
}

# f == find ./ -iname ...
function f() {
    find . -iname "*${*}*"
}

# Fake TTY
function fty() {
    script -qfec "$(printf "%q " "$@")"
}
alias fuck='sudo $(history -p \!\!)'
flush-dns() {
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder
}
alias glw='glow -w 80 -p'
kill-vscode() {
    pgrep -f '\.vscode' | while IFS= read -r pid; do
        kill "$@" "$pid"
    done
}
alias k.vsc='kill-vscode'
alias k.vsc!='kill-vscode -9'
function les() {
  script -q /dev/null "$@" | less -R
}
function mkcd() {
    mkdir "$@"
    # shellcheck disable=SC2164  # `cd` is the function's final command, so its status is returned.
    cd "$@"
}
alias mkd='mkdir'
alias mp='multipass'
alias myip="curl -s icanhazip.com"
alias nodist='grep -v "\(\.css\|\.map\|.min\|.svg\)"'
ping-loop() {
  domain="$1"
  sleep_time="${2:-10}"

  if [ -z "$domain" ]; then
    echo "Usage: ping-loop <domain> [sleep_time]"
    return 1
  fi

  while true; do
    ping -c 1 "$domain" | awk '/PING/{getline; print}'
    sleep "$sleep_time"
  done
}
alias psa='ps aux'
alias psg='ps aux | grep -i'
alias pst='pstree -UpaunZ'
alias rmf='rm -f'
alias rmr='rm -R'
alias rmrf='rm -Rf'
alias sed-fail="sed -n -e '/\[\(CRITICAL\|WARNING\) *\]/,/\[\(DEBUG\|INFO\) *\]/ { /\[\(DEBUG\|INFO\) *\]/b; p }'"
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
alias tlf='tail -F'
function typ() {
    type -p "$@"
}
alias upd='updatedb'
alias upt='uptime'
alias wcc='wc -c'
alias wcl='wc -l'
alias wcw='wc -w'


### 1.5. Git
function _git_clone_github() {
    # TODO: If '/' not in $1, use "$1/$1"
    git clone "git@github.com:$1.git" "${@:2}"
}
function _git_clone_my_github() {
    git clone "git@github.com:${DEFAULT_USER:-$USER}/$1.git" "${@:2}"
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
    git diff --color=always "$target_commit^$commits_behind" "$target_commit"
}
function _git_log_author() {
    git log --color=always --author="$*"
}
function _git_log_author_stat() {
    git log --color=always --author="$*" --stat
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
    git branch "--set-upstream-to=$1/$branch" "$branch"
}
function git-get_remote_branches() {
    local remote=${1-origin}
    git remote set-branches "$remote" '*'
    git fetch -vvv
}
function gwta() {
    # Check out a git worktree in a sibling directory
    # Usage: gwta BRANCH [DIR_NAME]
    local branch=$1
    local dir="../${2:-$1}"

    local -a track=()
    if [[ "${branch%%/*}" == "remotes" ]]; then
        track=(--track -b "${branch##*/}")
    fi
    git worktree add "${track[@]}" "$dir" "$branch"
}

alias gbl='_run git blame'
alias gbr='_run git branch --color=always'
alias gbr.a='_run git branch --color=always -a'
alias gbr.av='_run git branch --color=always -av'
alias gbr.d='_run git branch --color=always -d'
alias gbr.D='_run git branch --color=always -D'
alias gbr.v='_run git branch --color=always -v'
alias gch='_run git checkout'
alias gch.b='_run git checkout -b'
alias gch.t='_run git checkout -t'
alias gcl='_run git clone'
alias gcl.d1='_run git clone --depth=1'
alias gcl-gh='_git_clone_github'
alias gcl-my='_git_clone_my_github'
alias gco='_run git commit'
alias gco.a='_run git commit -a'
alias gco.am='_run git commit -a -m'
alias gco.Am='git add -A; git commit -am'
alias gco.amp='_git_commit_n_push -am'
alias gco.Amp='git add -A; _git_commit_n_push -am'
alias gco.ap='_git_commit_n_push -a'
alias gco.m='_run git commit -m'
alias gco.mp='_git_commit_n_push -m'
alias gco.p='_git_commit_n_push'
alias gcp='git cherry-pick'
alias gcp.n='git cherry-pick -n'
alias gdi='git diff --color=always'
alias gdi.c='git diff --color=always --cached'
alias gdi.chk='git diff --color=always --check'
alias gdi.co='_git_diff_commit'
alias gdi.cs='git diff --color=always --cached --stat'
alias gdi.s='git diff --color=always --stat'
alias gfe='git fetch'
alias glo='git log'
alias glo.a='_git_log_author'
alias glo.as='_git_log_author_stat'
alias glo.s='git log --stat'
alias gmr='git merge'
alias gmv='git mv'
alias gpl='git pull'
alias gps='git push'
alias gps.u='git push --set-upstream'
alias gre='git remote'
alias gre.a='git remote add'
alias gre.r='git remote rename'
alias gre.rm='git remote remove'
alias gre.v='git remote -v'
alias grm='git rm'
alias grm.c='git rm --cached'
alias grm.f='git rm -f'
alias grs='git reset'
alias grs.HEAD='git reset --hard HEAD'
alias gsh='git show'
alias gst='git -c color.status=always status'
alias gst.s='git -c color.status=always status --short'
alias gsta='git stash'
alias gsta.a='git stash apply'
alias gsta.l='git stash list'
alias gsta.m='git stash -m'
alias gsta.p='git stash pop'
alias gsta.u='git stash -u'
alias gsta.um='git stash -u -m'
alias gta='git tag'
alias gwt='git worktree'
alias gwt.l='git worktree list'
alias gwt.rm='git worktree remove'

if type __git_complete &>/dev/null; then
    __git_complete gad _git_add
    __git_complete gbr _git_branch
    __git_complete gbr.a _git_branch
    __git_complete gbr.av _git_branch
    __git_complete gch _git_checkout
    __git_complete gcl _git_clone
    __git_complete gco _git_commit
    __git_complete gco.p _git_commit
    __git_complete gco.a _git_commit
    __git_complete gco.ap _git_commit
    __git_complete gco.m _git_commit
    __git_complete gco.mp _git_commit
    __git_complete gco.am _git_commit
    __git_complete gco.amp _git_commit
    __git_complete gco.Amp _git_commit
    __git_complete gdi _git_diff
    __git_complete gdi.c _git_diff
    __git_complete gfe _git_fetch
    __git_complete glo _git_log
    __git_complete gmr _git_merge
    __git_complete gpl _git_pull
    __git_complete gps _git_push
    __git_complete gre _git_remote
    __git_complete gre.v _git_remote
    __git_complete grm _git_rm
    __git_complete grm.c _git_rmc
    __git_complete gsh.w _git_show
    __git_complete gst _git_status
    __git_complete gst.sh _git_stash
    __git_complete gta _git_tag
fi


### 1.6. Grep
function _grep() {
    # If grepping recursively, and just a search term is
    # given, default to searching the current directory.
    if [[ "$#" -eq "2" && $1 == *"r"* ]]; then
        grep --color=always "$@" ./
    else
        grep --color=always "$@"
    fi
}
function __grep() {
    # If grepping recursively, and just a search term is
    # given, default to searching the current directory.
    if [[ "$#" -eq "3" && $1 == *"r"* ]]; then
        _run grep --color=always "$@" ./
    else
        _run grep --color=always "$@"
    fi
}

alias g='_grep -I'          # I: ignores binary files
alias gi='_grep -Ii'        # i: case insensitive
alias gin='_grep -Iin'
alias gir='_grep -Iri'
alias girn='__grep -Irin'
alias girnn='__grep -Iri --exclude-dir=node_modules'
alias girnnn='__grep -Irin --exclude-dir=node_modules'
alias girv='_grep -Iriv'
alias giv='_grep -Iiv'      # v: invert matching
alias glb='grep --line-buffered'    # Stream into pipes
alias gn='_grep -In'        # n: print line numbers
alias gr='_grep -Ir'        # r: recursive
alias grn='_grep -Irn'
alias grnn='_grep -Ir --exclude-dir=node_modules'
alias grnnn='_grep -Irn --exclude-dir=node_modules'
alias gv='_grep -Iv'


### 1.7. Homebrew
alias br.ar='_run brew autoremove'
alias br.c='_run brew cleanup'
alias br.c!='_run brew cleanup --prune=all'
alias br.d='_run brew doctor'
alias br.i='_run brew install'
alias br.ic='_run brew install --cask'
alias br.info='_run brew info'
alias br.l='_run brew list'
function br.lg() {
    _runsh 'brew list | grep -i "$@"' "$@"
}
alias br.s='_run brew search'
alias br.u='_run brew upgrade ; _run brew autoremove ; _run brew cleanup --prune=all ; _run brew doctor'
alias br.ud='_run brew upgrade --dry-run'
alias br.un='_run brew uninstall'
# Report leaf dependents, distinguishing top-level leaves from orphaned dependencies.
function br.uses() {
    [ "$#" -gt 0 ] || return 1

    local formula
    local dependents
    local rc
    local leaves
    local orphaned=0
    local multiple="$#"
    local uses

    leaves="$(brew leaves)" || return

    for formula; do
        uses="$(brew uses --installed --recursive --formula "$formula")" || return
        dependents="$(printf '%s\n' "$leaves" | grep -Fxf <(printf '%s\n' "$uses"))"
        rc=$?

        if [ "$rc" -gt 1 ]; then
            return "$rc"
        elif [ "$rc" -eq 1 ]; then
            if printf '%s\n' "$leaves" | grep -Fxq -- "$formula"; then
                printf '%s: [leaf]\n' "$formula"
            else
                printf '%s: [orphan]\n' "$formula"
                orphaned=1
            fi
        elif [ "$multiple" -gt 1 ]; then
            printf '%s:\n' "$formula"
            printf '%s\n' "$dependents" | sed 's/^/  /'
        else
            printf '%s\n' "$dependents"
        fi
    done

    return "$orphaned"
}


### 1.8. History and shell sourcing
alias hs='history'
hs.unique() {
    # Append session history to the file and reload it to ensure it's up-to-date
    history -a
    history -c
    history -r

    declare -A cmd_map  # Create an associative array to store the last instance of each command

    # Read through the output of the updated `history` command
    while IFS= read -r line; do
        # Extract the command part by cutting everything after the first three fields
        cmd=$(echo "$line" | cut -d' ' -f4-)
        # Store the command in the associative array with the whole line as the value
        cmd_map["$cmd"]="$line"
    done < ~/.bash_history

    # Now output the last instance of each command
    for line in "${cmd_map[@]}"; do
        echo "$line"
    done | sort -k2  # Optionally sort the results by the timestamp, which is the second field
}
alias hsg='fc -l 1 | grep -i'
alias hsn='history -n'          # Append new lines from the history file to history
alias s.bashrc='_run source ~/.bashrc'
alias s.venv='source .venv/bin/activate'
alias s.zshrc='_run source ~/.zshrc'


### 1.9. JSON
alias jq.='jq .'
alias jqc='jq -C'
alias jqc.='jq -C .'
alias j='jqc'
alias j.='jqc.'


### 1.10. Just
alias jst='just --color always --command-color cyan'
alias jst!='jst --no-deps'


### 1.11. Listing and finding
# Prefer eza when available; otherwise retain colourful native ls defaults.
if command -v eza >/dev/null 2>&1; then
    alias ls='eza'
elif [ "$TERM" != "dumb" ]; then
    if command -v dircolors >/dev/null 2>&1; then
        eval "$(dircolors -b)"
        alias ls='ls -Fh --color=auto'       # GNU ls
    else
        export CLICOLOR='TRUE'
        alias ls='ls -GhF'                   # BSD/macOS ls
    fi
fi

alias l='ls -l'
alias la='ls -al'
alias ll.d='ll -d'
alias la.d='la -d'
alias las='la | less'

# Use a function so arguments go to the listing command rather than less.
unalias ll 2>/dev/null
if command -v eza >/dev/null 2>&1; then
    function ll() {
        eza --colour=always -l "$@" | less -R
    }
else
    function ll() {
        # shellcheck disable=SC2012  # Output goes straight to less; filenames are never parsed.
        ls -l "$@" | less -R
    }
fi

function grepl() {
    if [ -n "${COLOR_ALWAYS:-}" ]; then
        grep "$COLOR_ALWAYS" "$@" | less
    else
        grep "$@" | less
    fi
}


### 1.12. Neovim
alias nv='nvim -p'        # Open files in tabs
# shellcheck disable=SC2139  # Expand the file list into separate alias words when defined
alias nv.dotfiles="nvim -n -p $VOLATILE_DOTFILES"
alias nv.n='nvim -n -p'   # Disable swap files


### 1.13. Node.js
alias npi='npm install -P'
alias npia='npm install -PD'
alias npid='npm install -D'
alias npig='npm install --global'
alias npl='npm list'
alias npl0='npm list --depth=0'
alias npl1='npm list --depth=1'
alias npo='npm outdated'
alias npr='npm run'
alias nps='npm show'
alias npu='npm update'
alias npua='npm update --dev'
alias npuad='npm --depth=9999 update --dev'
alias npud='npm --depth=9999 update'


### 1.14. Ownership
function _own() {
    local ch_name ch_owners
    local -a ch_ops ch_targets

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
    ch_ops=()
    if [[ $1 =~ .*r.* ]]; then
        ch_ops=(-R)
    fi

    # Set owning user/group ('b' is for 'both')
    if [[ $1 =~ .*b.* ]]; then
        ch_owners="$ch_name:$ch_name"
    else
        ch_owners="$ch_name"
    fi

    # Assume current directory if no files specified
    if [ "$#" -le "1" ]; then
        ch_targets=(./)
    else
        ch_targets=("${@:2}")
    fi

    # Change something ('g' is for 'group')
    if [[ $1 =~ .*g.* ]]; then
        chgrp "${ch_ops[@]}" "$ch_owners" "${ch_targets[@]}"
    else
        chown "${ch_ops[@]}" "$ch_owners" "${ch_targets[@]}"
    fi
}   # end _own()

alias own='_own b'              # Own both user and group on files
alias own.g='_own g'             # Own group flag on files
alias own.gr='_own gr'           # Own group flag on files, recursively
alias own.r='_own br'            # Own user and group on files, recursively
alias own.u='_own u'             # Own user flag on files
alias own.ur='_own ur'           # Own user flag on files, recursively


### 1.15. Python and Django
function cover() {
    # shellcheck disable=SC2086  # D is an optional command fragment and may be empty
    coverage run --source="$1" $D test "$1"
    coverage report --omit='*/_[a-z]*,*/tests/test_*';
}
alias dja='django-admin'

alias htb='hatch build'
alias htc='hatch clean'
alias htco='hatch config'
alias htd='hatch dep'
alias hte='hatch env'
alias htf='hatch format'
alias htp='hatch publish'
alias htpr='hatch project'
alias htpy='hatch python'
alias htr='hatch run'
alias hts='hatch status'
alias htsh='hatch shell'
alias htv='hatch version'

alias mm='just dj makemigrations'
alias mmm='just dj makemigrations && just dj migrate'

function __pdm_venv_activate() {
    eval "$(pdm venv activate | sed 's/^source/source /; s/^.*$/&/')"
}
alias pd.r='pdm run'
alias pd.va=__pdm_venv_activate

alias pif='_run pip freeze'
alias pifl='_runsh "pip freeze | wc -l"'
alias pmn='python manage.py'
alias pmsh='python manage.py shell'

alias pye='pyenv'
alias pyei='pyenv install'
alias pyel='pyenv install -list | less'
alias pyev='pyenv version'
alias pyevs='pyenv versions'


### 1.16. SSH
alias scp.r='scp -r'
ssh-keygen-cloud() {
  comment="(ephemeral)-$(date +%F)"
  ssh-keygen -N "" -t ed25519 -f ~/.ssh/ephemeral-ed25519 -C "$comment"
}
ssh-keygen-default() {
  comment="$USER@$(hostname | cut -d '.' -f 1)-$(date +%F)"
  ssh-keygen -N "" -t ed25519 -C "$comment"
}
alias sshffs='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
unknow_host() {
  if [ -z "$1" ]; then
    echo "Please provide a pattern to match."
    return 1
  fi

  # Create a backup of the known_hosts file
  cp ~/.ssh/known_hosts ~/.ssh/known_hosts.bak

  # Remove lines that start with the pattern passed as the first argument
  sed -i.bak "/^$1/d" ~/.ssh/known_hosts

  echo "Removed entries from ~/.ssh/known_hosts matching pattern '^$1'"
}


### 1.17. Sudo and system services
_sujctl-fu() {
    args=()
    for service in "$@"; do
        args+=("-u" "$service")
    done
    sudo journalctl -f "${args[@]}"
}
function sudoe() {
    if [[ $# -eq 0 ]]; then
        sudo -E bash
    else
        sudo -E "$@"
    fi
}
function sudoeu() {
    if [[ $# -eq 1 ]]; then
        sudo -Eu "$1" bash
    else
        sudo -Eu "$@"
    fi
}
alias sujctl='sudo journalctl'
alias sujctl.f='sudo journalctl -f'
alias sujctl.fu='_sujctl-fu'
alias sujctl.u='sudo journalctl -u'
alias susctl='sudo systemctl'
alias susctl.dre='sudo systemctl daemon-reload'
alias susctl.rel='sudo systemctl reload'
alias susctl.res='sudo systemctl restart'
alias susctl.sta='sudo systemctl start'
alias susctl.stat='sudo systemctl status'
alias susctl.sto='sudo systemctl stop'
sush() {
    local target_user="${1:-root}"
    local config_home="${SUSH_CONFIG_HOME:-${ZDOTDIR:-$HOME}}"
    sudo -H -E -u "$target_user" SUSH_CONFIG_HOME="$config_home" ZDOTDIR="$config_home" "$SHELL"
}


### 1.18. Terraform
alias trf='_run terraform'
alias trfa='_run terraform apply'
alias trfi='_run terraform init'
alias trfP='_run terraform plan -out'
alias trfp='_run terraform plan'


### 1.19. Tmux
_tmux__safe_kill_session() {
  session_name=$(tmux display-message -p '#S')
  session_count=$(tmux list-sessions | wc -l)

  if [ "$session_count" -gt 1 ]; then
    tmux kill-session -t "$session_name"
  else
    echo "Warning: Only one session left; kill aborted."
  fi
}
tx() {
  # If an argument is given, treat it as the session name
  if [ -n "$1" ]; then
    if [ -n "$2" ]; then
      # If a second argument is provided, link the new session to the existing one and detach it from the current client
      tmux new-session -d -s "$2" -t "$1"

      # Get the number of windows in the original session (home)
      window_count=$(tmux list-windows -t "$1" | wc -l)

      # Create a new window in the new session
      tmux new-window -t "$2"

      # Calculate the new window index (window_count + 1)
      new_window_index=$((window_count + 1))

      # Attach to the new session, starting in the newly created window
      tmux select-window -t "$2:$new_window_index"
      tmux attach-session -t "$2"
    else
      # Attach to the session if it exists, otherwise create a new one
      tmux attach-session -t "$1" 2>/dev/null || tmux new-session -s "$1"
    fi
  else
    # Count the number of active sessions
    session_count=$(tmux list-sessions 2>/dev/null | wc -l)

    if [ "$session_count" -eq 0 ]; then
      # No sessions exist, create a new one called 'default'
      tmux new-session -s default
    elif [ "$session_count" -eq 1 ]; then
      # Only one session exists, attach to it
      tmux attach-session
    else
      # Multiple sessions exist, list them
      tmux list-sessions
    fi
  fi
}
alias tx.ls='tmux ls'


### 1.20. Tree
function tre() {
    tree -C "$@" | grep -v '\.pyc$' | less
}
alias tre2='tre -L 2'
alias tre3='tre -L 3'
alias tre4='tre -L 4'
alias tre5='tre -L 5'
alias tren='tre -I node_modules'
alias tren2='tre -L 2 -I node_modules'
alias tren3='tre -L 3 -I node_modules'
alias tren4='tre -L 4 -I node_modules'
alias tren5='tre -L 5 -I node_modules'


### 1.21. uv
alias uva='uv add'
alias uva.d='uv add --dev'
alias uvr='uv run'
alias uvre='uv remove'


### 1.22. Project Zomboid saves
alias bak.zomboid='rsync -t -r --checksum --delete --info=progress2 ~/Zomboid/Saves/Sandbox/KelleyCarson ~/Local/Zomboid/Saves'
alias res.zomboid='rsync -t -r --checksum --delete --info=progress2 ~/Local/Zomboid/Saves/KelleyCarson ~/Zomboid/Saves/Sandbox'


### 2. Command behaviour and compatibility
##########################################


### 2.1. Default program behaviour
alias vim='vim -p'      # Open files in tabs


### 2.2. Emulate missing GNU Coreutils
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
fi


### 2.3. Operating system consistency
if [ "$BASIC_MACHINE_TYPE" = "Mac" ] && ! type updatedb &>/dev/null; then
    # NB: If your PATH is defaulting commands to Homebrew's set of Gnu
    # Coreutils, locate.updatedb will just throw errors; you need something
    # like: `export PATH=/usr/bin:/bin:$PATH`
    alias updatedb="sudo -E /usr/libexec/locate.updatedb"
fi


### 2.4. POSIX command overrides
function tar() {
    local -a extra_options=()
    # Exclude localisation and Desktop Services Store files on Macs
    if [ "$BASIC_MACHINE_TYPE" = "Mac" ]; then
        extra_options=(--exclude .DS_Store --exclude .localized)
    fi
    command -p tar "${extra_options[@]}" "$@"
}


### 2.5. Shell builtin overrides
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
        # shellcheck disable=SC2164  # `cd` is the function's final command, so its status is returned.
        builtin cd "$back_string"
    else
        # shellcheck disable=SC2164  # `cd` is the function's final command, so its status is returned.
        builtin cd "$@"
    fi

}


### 3. Typos usually typed in anger
##########################################
# NB: Do not add until you've seen it multiple times in the wild.
alias :q="echo I think you\'re already out of it, dude."
alias :qa="echo '(╯°□°）╯︵ ┻━┻'"
alias :w="echo \"/bin/bash\" 523L, 12398C written \(j/k\)"
alias al='la'
alias burp='brup'       # `brew up` alias
alias chwon='chown'
alias gid.c='gdi.c'
alias grpe='grep'
alias hsot='host'
alias hsto='host'
alias im='vim'
alias ir='gir'
alias ivm='vim'
alias pign='ping'
alias piong='ping'
alias poing='ping'
alias poip='pip'
alias rew='brew'
alias screne='screen'
alias sssh='ssh'
alias tial='tail'
alias vin='vim'
alias vl='lv'           # ls (visible, vertical & verbose)
alias whomai='whoami'
alias wpd='pwd'


### 4. Suspected legacy commands
##########################################
# Review candidates only: every declaration remains enabled and unchanged.


### 4.1. DigitalOcean
function do-api() {
    curl -s \
      -X GET \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $(grep 'DIGITAL_OCEAN_ACCESS_TOKEN' ~/dev/hpk/secrets.conf | cut -f2 -d"=")" \
      "https://api.digitalocean.com/v2/$1" | jq -C | less -F
}
alias do.region="_run doctl compute region list"
do.size() {
    [ -n "$1" ] && doctl compute size list | grep "$1" && return
    _run doctl compute size list
}


### 4.2. Docker Compose v1
alias dcm='_run docker-compose'
function dcm-m() {
    _run docker-compose exec "$@" pipenv run manage migrate
}
function dcm-mm() {
    _run docker-compose exec "$@" pipenv run manage makemigrations
}
function dcm-mmm() {
    _run docker-compose exec "$@" pipenv run manage makemigrations
    _run docker-compose exec "$@" pipenv run manage migrate
}
alias dcmb='_run docker-compose build'
alias dcmd='_run docker-compose down'
alias dcmr='_run docker-compose run'
alias dcmr.p='_run docker-compose run --service-ports'
alias dcmr.pn='docker-compose run --service-ports --name'
alias dcmr.prm='_run docker-compose run --service-ports --rm'
alias dcmr.prmn='docker-compose run --service-ports --rm --name'
alias dcmr.rm='_run docker-compose run --rm'
alias dcmr.rmn='docker-compose run --rm --name'
alias dcmu='_run docker-compose up'
alias dcmu.b='_run docker-compose up --build'
alias dcmu.bd='_run docker-compose up --build --detach'
alias dcmu.d='_run docker-compose up --detach'
alias dcmx='_run docker-compose exec'


### 4.3. Docker Machine
alias dmac='_run docker-machine'
alias dmacc='_run docker-machine create'
alias dmacc.vb='_run docker-machine create -d virtualbox'
alias dmace='_run docker-machine env'
alias dom.rm='docker-machine rm -y -f'


### 4.4. Fixed application and project shortcuts
# Dispense from the UCC Coke machine
#  - http://wiki.ucc.asn.au/Dispense
alias dis='_run dispense'
alias irssi2='irssi --config=~/.irssi/config2'
alias mame='/Applications/mame0236-x86/mame'
function _nv_hpk() {
    mvim -p ~/Local\ Store/hpk.io/hpk-scratch.txt ~/Local\ Store/hpk.io/hpk-stream.txt &
    sleep 2
    mvim ~/Local\ Store/hpk.io/hpk-code.py &
    sleep 1
}
alias nv.hpk="_nv_hpk"


### 4.5. GNU Screen
# `scr` is at https://github.com/hipikat/dotfiles/blob/master/.bin/scr
function 10shells() {
    screen -S "$1" -c ~/.screen/10shells
}
alias scr.l='screen -list'
alias scr.x='screen -x'
set_WINDOW() {
    WINDOW="$(screen -Q number)" || return
    export WINDOW
}


### 4.6. Kubernetes dashboard token
alias k8='kubectl'
function k8-create-dashboard-token() {
    kubectl -n kube-system get secret |
        awk '/^deployment-controller-token-/{print $1}' |
        while IFS= read -r secret_name; do
            kubectl -n kube-system describe secret "$secret_name"
        done |
        awk '$1=="token:"{print $2}'
}


### 4.7. Nodenv
alias ne.g='nodenv global'
alias ne.l='nodenv local'
alias ne.s='nodenv shell'
alias nei='nodenv install'
alias neil='nodenv install --list'
function neilg() {
  nodenv install --list | grep "$@"
}
alias ner='nodenv rehash'
alias nev='nodenv version'
alias nevs='nodenv versions'
alias newe='nodenv whence'
alias newi='nodenv which'


### 4.8. Old Homebrew ownership repair
alias fix-own-brews='sudo chown -R $(whoami) $(brew --prefix)/*'


### 4.9. Older environment and Python workflows
alias dve='source deactivate'
exp-env() {
    local files=("${@:-/etc/environment}")
    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            grep -v '^#' "$file" | grep -v '^\s*$' | sed 's/^/export /' | while read -r line; do
                eval "$line"
            done
        else
            echo "File not found: $file" >&2
        fi
    done
}
alias pe.rm='pipenv --rm'
alias peg='pipenv graph'
alias pei='pipenv install'
alias pei.='pipenv install --python `pyenv which python`'
alias peid='pipenv install --dev'
alias peid.='pipenv install --dev --python `pyenv which python`'
alias pel='pipenv lock -d; pipenv lock --requirements > requirements.txt'
alias per='pipenv run'
alias perd='pipenv run django'
alias perf='pipenv run pip freeze'
alias perfl='_runsh "pipenv run pip freeze | wc -l"'
alias perm='pipenv run manage'
alias perp='pipenv run python'
alias pers='pipenv run server'
alias persh='pipenv run shell'
alias pesh='pipenv shell'
alias pct.='pipenv run picata'
alias pip-upgrade='pip freeze --local | cut -d = -f 1  | xargs pip install -U'
# shellcheck disable=SC1091  # Virtualenv hook path is resolved only at runtime
function venv-postactivate { source "${VIRTUAL_ENV}/bin/postactivate"; }


### 4.10. PostgreSQL 12
alias pg_ctl-mac='sudo -u postgres /Library/PostgreSQL/12/bin/pg_ctl'
alias pg_ctl-mac-start='sudo -u postgres /Library/PostgreSQL/12/bin/pg_ctl -U postgres start -D /Library/PostgreSQL/12/data'
alias pg_ctl-mac-stop='sudo -u postgres /Library/PostgreSQL/12/bin/pg_ctl -U postgres stop -D /Library/PostgreSQL/12/data'


### 4.11. Salt
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
alias slt..high='slt.. \* state.highstate'
function slt.ping() {
    slt. test.ping
}
function slt..ping() {
    slt.. test.ping
}
alias slt.refresh_pillar='slt. saltutil.refresh_pillar'
alias slt..refresh_pillar='slt.. saltutil.refresh_pillar'
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


### 4.12. Supervisor
alias sup='supervisorctl'
alias supt='supervisorctl tail'
alias suptf='supervisorctl tail -F'
alias sv='sudo supervisorctl'


### 4.13. Synergy
alias syu='synergy-up'


### 4.14. Vagrant
alias vg='vagrant'
alias vgc='vagrant config'
alias vgd='vagrant destroy'
alias vgd.f='vagrant destroy -f'
alias vgh='vagrant halt'
alias vgi='vagrant ssh-config'
alias vgp='vagrant provision'
alias vgr='vagrant reload'
alias vgs='vagrant status'
alias vgsh='vagrant ssh'
alias vgu='vagrant up'
