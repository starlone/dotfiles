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
    dependencies=`cat dependencies.txt`
    sudo apt install -y $dependencies
}

taskpython(){
    echo '
    ----------
    - Python
    ----------
    '
    dep_python=`cat dependencies-python.txt`
    sudo pip install $dep_python
}

tasknodejs(){
    echo '
    ----------
    - NodeJS
    ----------
    '
    sudo npm install -g n
    # Install last nodejs
    sudo n stable
    sudo npm install -g npm
    dep_nodejs=`cat dependencies-nodejs.txt`
    sudo npm install -g $dep_nodejs
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
        *)
            echo "Não existe esta opção! " $PARAM "\n"
            ;;
    esac
done
