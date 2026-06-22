#!/bin/sh

# Instala git conforme o SO
case "$(uname)" in
    Darwin)
        if ! command -v brew >/dev/null 2>&1; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        brew install git
        ;;
    Linux)
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            case "$ID" in
                opensuse*|sles|suse)
                    sudo zypper refresh
                    sudo zypper install -y git
                    ;;
                *)
                    sudo apt update
                    sudo apt install -y git
                    ;;
            esac
        fi
        ;;
esac

if [ ! -d ~/dotfiles ]; then
    git clone https://github.com/starlone/dotfiles.git ~/dotfiles
fi

~/dotfiles/install.sh
