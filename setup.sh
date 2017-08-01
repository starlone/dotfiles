#!/bin/sh

sudo apt update
sudo apt -y full-upgrade

# ----------
# Shell
# ----------
dependencies=`cat dependencies.txt`
sudo apt install -y $dependencies

echo '
----------
- Python
----------
'
dep_python=`cat dependencies-python.txt`
sudo easy_install -U $dep_python

echo '
----------
- NodeJS
----------
'
sudo npm install -g npm n yarn
sudo n latest
dep_nodejs=`cat dependencies-nodejs.txt`
sudo npm install -g $dep_nodejs

echo '
----------
- Terminator
----------
'
rm ~/.config/terminator/config
ln -s ~/git/star.ubuntu-setup/terminator_config ~/.config/terminator/config

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
    cd ~/.vim/plugged/YouCompleteMe
    ./install.py --tern-completer
fi
cd ~/git/starlone.vim
git pull
vim +PlugUpgrade +qall
vim +PlugUpdate +qall

