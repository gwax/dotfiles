#!/bin/bash
# Extend path
EXTRA_PATHS=(
    "/usr/local/sbin"
    "/usr/local/opt/gettext/bin"
    "$HOME/opt/bin"
    "$HOME/.cargo/bin"
    "$HOME/.cabal/bin"
    "$HOME/.local/bin"
    "$HOME/.jenv/bin"
    "$HOME/bin"
    "/Library/Frameworks/Mono.framework/Versions/Current/bin"
    "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
)
for extra_path in "${EXTRA_PATHS[@]}"; do
    export PATH="${extra_path}:${PATH}"
done

export NVM_DIR="$HOME/.nvm"
export RBENV_ROOT="$HOME/.rbenv"
export RTV_BROWSER="w3m"

EXTRA_SOURCES=(
    "$HOME/.bash_aliases"
    "$HOME/.bash_secrets"
    "$HOME/.cargo/rustup.bash-completion"
    "$HOME/opt/google-cloud-sdk/completion.bash.inc"
    "$HOME/opt/google-cloud-sdk/path.bash.inc"
    "/etc/profile.d/bash-completion"
    "$NVM_DIR/nvm.sh"
    "$NVM_DIR/bash_completion"
    "/usr/share/git/git-prompt.sh"
    "$HOME/.travis/travis.sh"
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
which jenv > /dev/null 2>&1 && EXTRA_EVALS+=("$(jenv init -)")
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
    C0='\[\e[0m\]'
    C1='\[\e[38;2;215;175;255m\]'
    C2='\[\e[38;2;255;0;255m\]'
    C3='\[\e[38;2;135;95;255m\]'
    C4='\[\e[38;2;135;175;0m\]'
    C5='\[\e[38;2;135;255;0m\]'
    C6='\[\e[38;2;135;215;255m\]'
    C7='\[\e[38;2;255;0;0m\]'
    C8='\[\e[38;2;0;255;255m\]'
    C9='\[\e[38;2;255;255;135m\]'
    CA='\[\e[38;2;255;255;0m\]'
else
    C0='';C1='';C2='';C3='';C4='';C5='';C6='';C7='';C8='';C9='';CA=''
fi
PS1_GIT='$(__git_ps1)'
export PS1="${C1}╭─${C2}[${C3}\t ${C4}${ORG}${C2}] ${C5}\u${C6}@${C7}\h
${C1}│ ${C8}\w ${C9}$PS1_GIT
${C1}╰─${CA}$ ${C0}"
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
