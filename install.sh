#!/bin/sh

BASEDIR=$(dirname "$0")
cd $BASEDIR

git pull

echo_title() {
    echo '
    ----------
    - ' $1 '
    ----------
    '
}

taskshell() {
    echo_title 'Shell'

    sudo apt update
    sudo apt -y full-upgrade
    sudo apt install -y aptitude
    sudo aptitude install -y `cat dependencies.txt`

    sudo gpasswd -a $USER docker
}

tasksnap() {
    sudo snap refresh
    sudo snap install code --classic
}

taskterminator(){
    echo_title 'Terminator'

    if [ ! -d ~/.config/terminator ]; then
        mkdir -p ~/.config/terminator
    fi
    ln -sf $PWD/terminator_config ~/.config/terminator/config
}

tasktmux(){
    echo_title 'Tmux'

    ln -sf $BASEDIR/tmux.conf ~/.tmux.conf
}

taskzsh(){
    echo_title 'Zsh'

    if [ ! -d ~/.oh-my-zsh ]; then
        echo 'Instalando Oh My Zsh'
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
    if [ ! -d ~/.local/share/zinit/zinit.git  ]; then
        echo 'Instalando Zinit'
        sh -c "$(curl -fsSL https://git.io/zinit-install)"
    fi
    ln -sf $BASEDIR/zshrc ~/.zshrc
    ln -sf $BASEDIR/p10k.zsh ~/.p10k.zsh
}

taskfzf(){
    echo_title 'FZF'

    if [ ! -d ~/.fzf ]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    fi
    git -C ~/.fzf pull
    ~/.fzf/install --all
}

taskpyenv(){
    echo_title 'PyEnv'

    if [ ! -d ~/.pyenv ]; then
        echo 'Instalando PyEnv'
        git clone https://github.com/pyenv/pyenv.git ~/.pyenv
    fi
    cd ~/.pyenv
    git pull
    src/configure && make -C src
    cd -
}

taskpython(){
    echo_title 'Python'

    sudo -E pip3 install --upgrade -r dependencies-python.txt
}

tasknodejs(){
    echo_title 'NodeJS'

    if [ ! -d ~/.nvm ]; then
        echo 'Install NVM'
        wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
    fi

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

    nvm install --lts
    npm install -g npm
    npm install -g `cat dependencies-nodejs.txt`
}

taskvim(){
    echo_title 'VIM'

    rm -rf ~/.vimrc
    ln -s $BASEDIR/vimrc ~/.vimrc

    if [ ! -d ~/.vim ]; then
        vim +PlugInstall +qall
    fi

    vim +PlugUpgrade +qall
    vim +PlugUpdate +qall

    cd ~/.vim/plugged/YouCompleteMe
    ./install.py --ts-completer --java-completer
}

if [ $# -eq 0 ]; then
    taskshell
    tasksnap
    taskterminator
    tasktmux
    taskzsh
    taskfzf
    taskpyenv
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
        'snap')
            tasksnap
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
        'pyenv')
            taskpyenv
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
