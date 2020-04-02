#!/bin/sh

BASEDIR=$(dirname "$0")
cd $BASEDIR

git pull

taskshell() {
    echo '
    ----------
    - Shell
    ----------
    '
    sudo apt update
    sudo apt -y full-upgrade
    sudo apt install -y `cat dependencies.txt`
}

taskpython(){
    echo '
    ----------
    - Python
    ----------
    '
    sudo -E pip install `cat dependencies-python.txt`
}

tasknodejs(){
    echo '
    ----------
    - NodeJS
    ----------
    '
    sudo -E npm install -g n
    # Install last nodejs
    sudo -E n stable
    sudo -E npm install -g npm
    sudo -E npm install -g `cat dependencies-nodejs.txt`
}

taskterminator(){
    echo '
    ----------
    - Terminator
    ----------
    '
    if [ ! -d ~/.config/terminator ]; then
        mkdir -p ~/.config/terminator
    fi
    ln -sf ~/git/star.ubuntu-setup/terminator_config ~/.config/terminator/config

    # Font
    if [ ! -d ~/.fonts/Hack ]; then
        mkdir -p .fonts/Hack && cd .fonts/Hack
        wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.0.0/Hack.zip
        unzip Hack.zip
    fi
}

taskvim(){
    echo '
    ----------
    - VIM
    ----------
    '
    mkdir -p ~/git
    cd ~/git
    if [ ! -d ~/git/starlone.vim ]; then
        git clone https://github.com/starlone/starlone.vim.git
        cd ~/
        rm -rf .vimrc
        ln -s ~/git/starlone.vim/vimrc .vimrc
        vim +PlugInstall +qall
    fi
    cd ~/git/starlone.vim
    git pull
    vim +PlugUpgrade +qall
    vim +PlugUpdate +qall
    cd ~/.vim/plugged/YouCompleteMe
    ./install.py --tern-completer --js-completer --java-completer
}

tasktmux(){
    echo '
    ----------
    - Tmux
    ----------
    '
    ln -sf ~/git/star.ubuntu-setup/tmux.conf ~/.tmux.conf
}

if [ $# -eq 0 ]; then
    taskshell
    taskterminator
    taskpython
    tasknodejs
    taskvim
fi

for PARAM in $*
do
    case $PARAM in

        'shell')
            taskshell
            ;;
        'python')
            taskpython
            ;;
        'nodejs')
            tasknodejs
            ;;
        'terminator')
            taskterminator
            ;;
        'vim')
            taskvim
            ;;
        'tmux')
            tasktmux
            ;;
        *)
            echo "Não existe esta opção! " $PARAM "\n"
            ;;
    esac
done
