if [ -f ~/.profile ]; then
    source ~/.profile
fi

case "$-" in
*i*)
    # interactive shell
    if [ -f ~/.bashrc ]; then
        source ~/.bashrc
    fi
esac
