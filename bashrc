#!/bin/bash
# Extend path
EXTRA_PATHS=(
    "/usr/local/sbin"
    "/usr/local/opt/gettext/bin"
    "$HOME/opt/bin"
    "$HOME/.cargo/bin"
    "$HOME/.cabal/bin"
    "$HOME/.local/bin"
    "$HOME/bin"
    "/Library/Frameworks/Mono.framework/Versions/Current/bin"
    "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
)
for extra_path in "${EXTRA_PATHS[@]}"; do
    export PATH="${extra_path}:${PATH}"
done

export NVM_DIR="$HOME/.nvm"
export RBENV_ROOT="$HOME/.rbenv"

EXTRA_SOURCES=(
    "$HOME/.bash_aliases"
    "$HOME/.bash_secrets"
    "$HOME/.cargo/rustup.bash-completion"
    "$HOME/opt/google-cloud-sdk/completion.bash.inc"
    "$HOME/opt/google-cloud-sdk/path.bash.inc"
    "/etc/profile.d/bash-completion"
    "/usr/local/opt/nvm/nvm.sh"
    "/usr/share/git/git-prompt.sh"
)
if which brew > /dev/null 2>&1; then
    EXTRA_SOURCES+=(
        "$(brew --prefix)/etc/bash_completion"
    )
fi
for extra_source in "${EXTRA_SOURCES[@]}"; do
    if [[ -f "$extra_source" ]]; then
        source "$extra_source"
    fi
done

EXTRA_EVALS=()
which pyenv > /dev/null 2>&1 && EXTRA_EVALS+=("$(pyenv init -)")
which pyenv-virtualenv-init > /dev/null 2>&1 && EXTRA_EVALS+=("$(pyenv virtualenv-init -)")
which rbenv > /dev/null 2>&1 && EXTRA_EVALS+=("$(rbenv init -)")
for extra_eval in "${EXTRA_EVALS[@]}"; do
    eval "$extra_eval"
done

# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
    # Shell is non-interactive.  Be done now!
    return
fi

# Change the window title of X terminals
case ${TERM} in
    xterm*|rxvt*|Eterm|aterm|kterm|gnome)
        PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\007"'
        ;;
    screen)
        PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\033\\"'
        ;;
esac

# Check for colored prompt support
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    color_prompt=yes
else
    color_prompt=
fi

GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWSTASHSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWUPSTREAM="auto"
if [ "$color_prompt" = yes ]; then
    GIT_PS1_SHOWCOLORHINTS=true
fi

# Setup colored prompt
ORG="gwax"
if [ "$color_prompt" = yes ]; then
    # for i in {0..255}; do echo -e "\e[38;05;${i}m\\\e[38;05;${i}m"; done | column -c 80 -s '  '; echo -e "\e[m"
    PS1_ISTART='\[\e[38;05;201m\]['
    PS1_TIME='\[\e[38;05;99m\]\t'
    PS1_COMPANY="\[\e[38;05;106m\]${ORG}"
    PS1_IEND='\[\e[38;05;201m\]]'
    PS1_BLOCK_HEADER="$PS1_ISTART$PS1_TIME $PS1_COMPANY$PS1_IEND"
    PS1_USER='\[\e[38;05;118m\]\u'
    PS1_AT='\[\e[38;05;117m\]@'
    PS1_HOST='\[\e[38;05;196m\]\h'
    PS1_C='\[\e[38;05;208m\]:'
    PS1_BLOCK_USER="$PS1_USER$PS1_AT$PS1_HOST$PS1_C"
    PS1_PWD='\[\e[38;05;51m\]\w'
    PS1_GIT='\[\e[38;05;228m\]$(__git_ps1)\[\e[00m\]'
    PS1_BLOCK_PWD="$PS1_PWD $PS1_GIT"
    PS1_SEP='\[\e[38;05;226m\]➭ '
    PS1_END='\[\e[00m\]'
else
    PS1_BLOCK_HEADER="[\t ${ORG}]"
    PS1_BLOCK_USER='\u@\h:'
    PS1_PWD='\w'
    PS1_GIT='$(__git_ps1)'
    PS1_BLOCK_PWD="$PS1_PWD $PS1_GIT"
    PS1_SEP='➭ '
    PS1_END=''
fi
export PS1="\n$PS1_BLOCK_HEADER $PS1_BLOCK_USER\n$PS1_BLOCK_PWD\n$PS1_SEP$PS1_END"
unset color_prompt

# History management
export HISTIGNORE='@( )*:&:cd:clear:ls:exit:history*'
export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=100000
export HISTFILESIZE=100000
shopt -s extglob
shopt -s histappend
export PROMPT_COMMAND="history -n; history -w; history -c; history -r; $PROMPT_COMMAND"
function histfix() {
    # Clean up existing history file
    history \
        | sort -k2 -k1,1nr \
        | uniq -f1 \
        | sort -n \
        | awk '{$1=""; print}' \
        | cut -d " " -f2- \
        > ~/.tmp$$
    history -c
    history -r ~/.tmp$$
    history -w
    rm ~/.tmp$$
}

# Increase ulimits
ulimit -n 8192

# Application color support (mostly ls)
export CLICOLOR=1
ls --color=auto &> /dev/null && alias ls='ls --color=auto'

# Setup airflow environment
export AIRFLOW_HOME=~/airflow
