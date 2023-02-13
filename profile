#!/bin/sh

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
which pyenv > /dev/null 2>&1 && eval "$(pyenv init --path)"
which pyenv-virtualenv-init > /dev/null 2>&1 && eval "$(pyenv virtualenv-init -)"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
