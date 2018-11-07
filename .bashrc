#! /bin/bash
# Note: ~/.ssh/environment should not be used, as it
#       already has a different purpose in SSH.
host=$(hostname | cut -d. -f1)
SSH_ENV="$HOME/.ssh/env"
function start_agent {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add;
}
#Arjan-PC for local.
if [ "$host" = "Arjan-PC" ] ; then
    if [ -f "${SSH_ENV}" ]; then
        . "${SSH_ENV}" > /dev/null
        #ps ${SSH_AGENT_PID} doesn't work under cywgin
        ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
            start_agent;
        }
    else
        start_agent;
    fi
fi

export CLICOLOR=1
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx
source ~/.git-completion.sh
PS1='\[\033[32m\]\u@\H \[\033[33m\]\w\[\033[0m\]$(__git_ps1 " (\[\033[35m\]%s\[\033[0m\])")\012\$ '
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM="auto"

#parse_git_branch() {
#     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
#}

function gitCommitAndPush() {
  git add --all;
  git commit -m "$1";
  git push;
}

alias gadd='git add'
alias glog='git log'
alias gac='git add --all;git commit'
alias gacp='gitCommitAndPush'
alias gs='git status'
alias gdiff='git diff'
alias gb='git branch'
alias gco='git checkout'
alias gpull='git pull'
alias gls='git log -5 --color --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'
alias glg='git log -5 --pretty=format:"%C(bold blue)%s%Creset by %Cgreen%cn%Creset %C(yellow)(%cr)%Creset" --decorate --numstat  --abbrev-commit'
alias gpush='git push'
alias gprune='git fetch origin --prune'
alias track='git branch --set-upstream-to origin/master'
alias gbdiff='git diff --name-status master..'
alias fixfiles='find . -type f -exec chmod 644 {} \;'
alias fixdirs='find . -type d -exec chmod 755 {} \;'
alias fixall='find . -type d -exec chmod 755 {} \; find . -type f -exec chmod 644 {} \;'
alias fixallrecent='find . -type d -mtime -1 -exec chmod 755 {} \; find . -type f -mtime -1 -exec chmod 644 {} \;'
alias optpng="find -name '*.png' -print0 | xargs -0 optipng -o7 -strip all"
alias optjpg="find -name '*.jpg' -print0 | xargs -0 jpegoptim --max=85 --strip-all --preserve --totals {} \;"
alias optall="optpng; optjpg"
alias folders="find . -maxdepth 1 -type d -print | xargs du -sk | sort -rn"
alias www="cd /d/www/"
alias lsl="ls -opAh --group-directories-first"
alias cd..="cd .."
alias sslsetup="source ~/sh/create-ssl.sh"
#PS1='\[\033]0;$MSYSTEM:${PWD//[^[:ascii:]]/?}\007\]' # set window title
#PS1="$PS1"'\n'                 # new line
#PS1="$PS1"'\[\033[32m\]'       # change color
#PS1="$PS1"'\u@\H '             # user@host<space>
#PS1="$PS1"'\[\033[33m\]'       # change color
#PS1="$PS1"'\w '                 # current working directory
#PS1="$PS1"'\[\e[34m'        # change color
#PS1="$PS1"'$(parse_git_branch)'        # change color
#PS1="$PS1"'\[\033[0m\]'        # change color
#PS1="$PS1"'\n'                 # new line
#PS1="$PS1"'$ '                 # prompt: always $
git config --global user.name "Arjan Jenny"
git config --global user.email "arjan@infamousrepublic.com"
git config --global credential.helper "cache --timeout=3600"
git config --global color.ui auto
git config --global core.whitespace trailing-space,space-before-tab
git config --global diff.mnemonicprefix true
git config --global advice.statusHints false
git config --global push.default tracking
git config --global merge.stat true

function staging() {
    for HOST in $(<./.staging)
    do
        ssh $HOST
    done
}
function live() {
    for HOST in $(<./.live)
    do
        ssh $HOST
    done
}
function checkurl() {
  wget $1 2>&1 | grep Location:
}

function do_optimize() {
    count=0
    total=`find . -type f -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' | wc -l`
    echo "Optimizing $total images" | xargs
    find . \( -name "*.png" -or -name "*.jpg" \) -print0 | while IFS= read -r -d $'\0' line; do
        # Get filesize before
        file_size_kb_before=`du -k "$line" | cut -f1`
        # Actual optimization line
        if [[ $line == *.png ]]; then
            optipng -o7 -strip all -q -clobber $line
        fi
        if [[ $line == *.jpg ]]; then
            jpegoptim --max=85 --strip-all --preserve --totals -q $line
        fi
        # Get filesize after
        file_size_kb_after=`du -k "$line" | cut -f1`
        #
        percent=$(awk "BEGIN { pc=100*${file_size_kb_after}/${file_size_kb_before}; i=int(pc); print (pc-i<0.5)?i:i+1 }")
        percentdecrease=$((100-${percent}))
        if [ $percent = "100" ]; then
           opt="Already optimized"
        else
           opt="Optimized: ${file_size_kb_after}kb = $percentdecrease%% decrease"
        fi
        count=$(( $count + 1 ))
        printf "$count/$(set -f; echo $total): $line --> $opt \r\n"
    done
    echo "$total image files processed" | xargs
}
function optimize() {
    total=`find . -type f -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' | wc -l`
    
    echo "Found $total image files to optimize (will take a while)" | xargs
    read -r -p "Are You Sure? [Y/n] " input
    case $input in
        [yY][eE][sS]|[yY])
            do_optimize
            ;;
        [nN][oO]|[nN])
            false
                ;;
        *)
        false
        ;;
    esac
}
extract () {
   if [ -f $1 ] ; then
       case $1 in
           *.tar.bz2)   tar xvjf $1    ;;
           *.tar.gz)    tar xvzf $1    ;;
           *.bz2)       bunzip2 $1     ;;
           *.rar)       unrar x $1     ;;
           *.gz)        gunzip $1      ;;
           *.tar)       tar xvf $1     ;;
           *.tbz2)      tar xvjf $1    ;;
           *.tgz)       tar xvzf $1    ;;
           *.zip)       unzip $1       ;;
           *.Z)         uncompress $1  ;;
           *.7z)        7z x $1        ;;
           *)           echo "don't know how to extract '$1'..." ;;
       esac
   else
       echo "'$1' is not a valid file!"
   fi
 }
function addhost() {
    VAR1=`cat <<-eof 
<VirtualHost $2:80>
    ServerName localhost
    ServerAlias $2
    DocumentRoot "D:/www/$1/domains/$2"
    ErrorLog "D:/www/$1/domains/$2/error_log"
</VirtualHost>`
    echo "$VAR1" >> /d/xampp/apache/conf/extra/httpd-vhosts.conf

    echo "127.0.0.1   $2" >> /c/Windows/System32/drivers/etc/hosts # add line to hosts
}