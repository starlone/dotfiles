#!/bin/bash

sudo apt update
sudo apt full-upgrade -y
sudo apt install -y git

if [ ! -d ~/git/dotfiles ]; then
    mkdir -p ~/git
    git clone https://github.com/starlone/dotfiles.git ~/git/dotfiles
fi

~/git/dotfiles/install.sh
