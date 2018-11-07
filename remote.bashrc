alias gadd='git add'
alias glog='git log'
alias gac='git add --all;git commit'
alias gs='git status'
alias gdiff='git diff'
alias gb='git branch'
alias gco='git checkout'
alias gpull='git pull'
alias gpush='git push'
alias track='git branch --set-upstream-to origin/master'
alias files='git config core.fileMode false'
PS1='\[\033]0;$MSYSTEM:${PWD//[^[:ascii:]]/?}\007\]' # set window title
PS1="$PS1"'\n'                 # new line
PS1="$PS1"'\[\033[32m\]'       # change color
PS1="$PS1"'\u@\H '             # user@host<space>
PS1="$PS1"'\[\033[33m\]'       # change color
PS1="$PS1"'\w'                 # current working directory
PS1="$PS1"'\[\033[0m\]'        # change color
PS1="$PS1"'\n'                 # new line
PS1="$PS1"'$ '                 # prompt: always $
#set login cache
git config --global credential.helper "cache --timeout=3600"
# geen gedoe welke gepulled moet
git config --global push.default matching
# gewoon master instellen als default
git branch --set-upstream-to=origin/master master