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

taskterminator(){
    echo '
    ----------
    - Terminator
    ----------
    '
    if [ ! -d ~/.config/terminator ]; then
        mkdir -p ~/.config/terminator
    fi
    ln -sf ~/git/dotfiles/terminator_config ~/.config/terminator/config

    # Font
    if [ ! -d ~/.fonts/Hack ]; then
        mkdir -p .fonts/Hack && cd .fonts/Hack
        wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.0.0/Hack.zip
        unzip Hack.zip
    fi
}

tasktmux(){
    echo '
    ----------
    - Tmux
    ----------
    '
    ln -sf ~/git/dotfiles/tmux.conf ~/.tmux.conf
}

taskzsh(){
    echo '
    ----------
    - Zsh
    ----------
    '
    if [ ! -d ~/.oh-my-zsh ]; then
        echo 'Instalando Oh My Zsh'
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
    if [ ! -d ~/.zinit ]; then
        echo 'Instalando Zinit'
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"
    fi
    ln -sf ~/git/dotfiles/zshrc ~/.zshrc
}

taskfzf(){
    echo '
    ----------
    - FZF
    ----------
    '
    if [ ! -d ~/.fzf ]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    fi
    git -C ~/.fzf pull
    ~/.fzf/install --all
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
    if [ ! -d ~/.nvm ]; then
        echo 'Install NVM'
        wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
    fi

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

    nvm install node
    npm install -g npm
    npm install -g `cat dependencies-nodejs.txt`
}

taskvim(){
    echo '
    ----------
    - VIM
    ----------
    '
    if [ ! -d ~/.vim ]; then
        rm -rf ~/.vimrc
        ln -s ~/git/dotfiles/vimrc ~/.vimrc
        vim +PlugInstall +qall
    fi
    vim +PlugUpgrade +qall
    vim +PlugUpdate +qall
    cd ~/.vim/plugged/YouCompleteMe
    ./install.py --tern-completer --js-completer --java-completer
}

if [ $# -eq 0 ]; then
    taskshell
    taskterminator
    tasktmux
    taskzsh
    taskfzf
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
        'terminator')
            taskterminator
            ;;
        'tmux')
            tasktmux
            ;;
        'zsh')
            taskzsh
            ;;
        'fzf')
            taskfzf
            ;;
        'python')
            taskpython
            ;;
        'nodejs')
            tasknodejs
            ;;
        'vim')
            taskvim
            ;;
        *)
            echo "Não existe esta opção! " $PARAM "\n"
            ;;
    esac
done