#!/bin/bash

sudo apt update
sudo apt full-upgrade -y
sudo apt install -y git

if [ ! -d ~/git ]; then
    mkdir -p ~/git
fi

cd ~/git

if [ ! -d star.ubuntu-setup ]; then
    git clone https://github.com/starlone/star.ubuntu-setup.git
fi

cd star.ubuntu-setup
git pull
./setup.sh
