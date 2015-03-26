# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !


# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
    # Shell is non-interactive.  Be done now!
    return
fi

# Enable bash completions
if [[ -f $(brew --prefix)/etc/bash_completion ]]; then
    source $(brew --prefix)/etc/bash_completion
fi

# If boot2docker is installed and up, do shellinit
if [[ -f /usr/local/bin/boot2docker ]] && [ "$(boot2docker status)" = running ]; then
    eval "$(boot2docker shellinit 2> /dev/null)"
fi

# Enable ruby shims and autocompletion
export RBENV_ROOT="$HOME/.rbenv"
if which rbenv > /dev/null; then
    eval "$(rbenv init -)"
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

# git PS1 options
GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWSTASHSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWUPSTREAM="auto"
if [ "$color_prompt" = yes ]; then
    GIT_PS1_SHOWCOLORHINTS=true
fi

# Setup colored prompt
if [ "$color_prompt" = yes ]; then
    # for i in {0..255}; do echo -e "\e[38;05;${i}m\\\e[38;05;${i}m"; done | column -c 80 -s '  '; echo -e "\e[m"
    PS1_ISTART='\[\e[38;05;52m\]['
    PS1_TIME='\[\e[38;05;240m\]\t'
    PS1_COMPANY='\[\e[38;05;106m\]CloverHealth'
    PS1_IEND='\[\e[38;05;52m\]]'
    PS1_BLOCK_HEADER="$PS1_ISTART$PS1_TIME $PS1_COMPANY$PS1_IEND"
    PS1_USER='\[\e[38;05;118m\]\u'
    PS1_AT='\[\e[38;05;117m\]@'
    PS1_HOST='\[\e[38;05;196m\]\h'
    PS1_C='\[\e[38;05;208m\]:'
    PS1_BLOCK_USER="$PS1_USER$PS1_AT$PS1_HOST$PS1_C"
    PS1_PWD='\[\e[38;05;51m\]\w'
    PS1_GIT='\[\e[00m\]$(__git_ps1)'
    PS1_BLOCK_PWD="$PS1_PWD $PS1_GIT"
    PS1_SEP='\[\e[38;05;226m\]➭ '
    PS1_END='\[\e[00m\]'
else
    PS1_BLOCK_HEADER='[\t CloverHealth]'
    PS1_BLOCK_USER='\u@\h:'
    PS1_PWD='\w'
    PS1_GIT='$(__git_ps1)'
    PS1_BLOCK_PWD="$PS1_PWD $PS1_GIT"
    PS1_SEP='➭ '
    PS1_END=''
fi
PS1="\n$PS1_BLOCK_HEADER $PS1_BLOCK_USER\n$PS1_BLOCK_PWD\n$PS1_SEP$PS1_END"
unset color_prompt

# Forever history
HISTSIZE=
HISTFILESIZE=
shopt -s histappend
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

# Application color support (mostly ls)
export CLICOLOR=1
ls --color=auto &> /dev/null && alias ls='ls --color=auto'

# Add local binaries
if [[ -d ~/bin ]] ; then
    export PATH=~/bin:$PATH
fi

# Pull in aliases
if [[ -f ~/.bash_aliases ]] ; then
    source ~/.bash_aliases
fi
