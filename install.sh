#!/bin/sh

BASEDIR=$(cd "$(dirname "$0")" && pwd)
cd "$BASEDIR"

OLD_HEAD=$(git rev-parse HEAD 2>/dev/null)
if git pull --ff-only >/dev/null 2>&1; then
    NEW_HEAD=$(git rev-parse HEAD 2>/dev/null)
    # sh le o script do disco conforme executa; se o pull atualizou o proprio
    # install.sh, continuar com o offset antigo corrompe a execucao. Re-executa.
    if [ "$OLD_HEAD" != "$NEW_HEAD" ] && [ -n "$(git diff --name-only "$OLD_HEAD" "$NEW_HEAD" -- install.sh 2>/dev/null)" ]; then
        echo "install.sh atualizado pelo git pull; re-executando a versao nova..."
        exec "$BASEDIR/install.sh" "$@"
    fi
else
    echo "Aviso: git pull falhou (offline ou mudancas locais); seguindo com a versao local."
fi

echo_title() {
    echo '
    ----------
    - ' $1 '
    ----------
    '
}

# Função auxiliar para criar links simbólicos de forma idempotente e segura
create_symlink() {
    SRC="$1"
    DEST="$2"
    if [ ! -e "$SRC" ]; then
        echo "ERRO: origem '$SRC' nao existe; link '$DEST' nao foi criado."
        return 1
    fi
    if [ -L "$DEST" ]; then
        # Se já é link e aponta para o destino correto, não faz nada
        if [ "$(readlink "$DEST")" = "$SRC" ]; then
            return
        fi
        rm -f "$DEST"
    elif [ -e "$DEST" ]; then
        # Se é arquivo normal, faz backup antes de remover
        mv "$DEST" "$DEST.bak.$(date +%s)"
    fi
    ln -sf "$SRC" "$DEST"
}

# Detecta o sistema operacional
detect_os() {
    case "$(uname)" in
        Darwin)
            echo "macos" ;;
        Linux)
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                case "$ID" in
                    opensuse*|sles|suse)
                        echo "suse" ;;
                    ubuntu|debian)
                        echo "debian" ;;
                    *)
                        echo "linux" ;;
                esac
            else
                echo "linux"
            fi
            ;;
        *)
            echo "unknown" ;;
    esac
}

OS_ID=$(detect_os)

taskshell() {
    echo_title 'Shell'
    case "$OS_ID" in
        macos)
            install_dependencies_brew
            ;;
        debian|linux)
            install_dependencies_apt
            ;;
        suse)
            install_dependencies_zypper
            ;;
        *)
            echo "Sistema operacional não suportado para instalação automática de dependências."
            ;;
    esac
}

# Instala dependências via Homebrew (macOS)
install_dependencies_brew() {
    if ! command -v brew >/dev/null 2>&1; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    # Torna o brew (possivelmente recem-instalado) disponivel nesta sessao
    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    echo "Instalando dependências do Homebrew..."
    brew update
    brew upgrade
    DEPFILE="dependencies-macos.txt"
    [ -f "$DEPFILE" ] && xargs brew install < "$DEPFILE"
    DEPFILE_CASKS="dependencies-macos-casks.txt"
    [ -f "$DEPFILE_CASKS" ] && xargs brew install --cask < "$DEPFILE_CASKS"
    install_node_lts
    sudo dseditgroup -o edit -a $USER -t user docker 2>/dev/null || true
}

# Node LTS como runtime "ambiente": processos fora do zsh (launchd, GUI, #!/bin/sh)
# nao veem o node do nvm, que existe so via PATH de shell interativo. Resolve o
# major LTS vigente no indice oficial do Node em vez de travar versao no deps file.
install_node_lts() {
    command -v brew >/dev/null 2>&1 || return 0
    LTS_MAJOR=$(curl -fsSL https://nodejs.org/dist/index.json 2>/dev/null | python3 -c 'import json,sys; print(next(x["version"].split(".")[0].lstrip("v") for x in json.load(sys.stdin) if x["lts"]))' 2>/dev/null)
    if [ -n "$LTS_MAJOR" ]; then
        echo "Instalando Node LTS ambiente (major $LTS_MAJOR)..."
        brew install "node@$LTS_MAJOR"
        brew link --force --overwrite "node@$LTS_MAJOR" 2>/dev/null || true
    else
        echo "Aviso: nao consegui descobrir o major LTS do Node; instalando o node corrente."
        brew install node
    fi
}

# Instala dependências via apt/aptitude (Debian/Ubuntu)
install_dependencies_apt() {
    sudo apt update
    sudo apt -y full-upgrade
    sudo apt install -y aptitude
    DEPFILE="dependencies-ubuntu.txt"
    [ -f "$DEPFILE" ] && sudo aptitude install -y $(cat "$DEPFILE")
    sudo gpasswd -a "$USER" docker 2>/dev/null || echo "Aviso: falha ao adicionar $USER ao grupo docker (grupo existe?)"
}

# Instala dependências via zypper (SUSE)
install_dependencies_zypper() {
    sudo zypper refresh
    sudo zypper update -y
    DEPFILE="dependencies-suse.txt"
    [ -f "$DEPFILE" ] && sudo zypper install -y $(cat "$DEPFILE")
    sudo usermod -aG docker "$USER" 2>/dev/null || echo "Aviso: falha ao adicionar $USER ao grupo docker (grupo existe?)"
}
taskterminator(){
    echo_title 'Terminator'

    mkdir -p ~/.config/terminator
    create_symlink "$BASEDIR/terminator_config" "$HOME/.config/terminator/config"
}

taskherdr(){
    echo_title 'Herdr'

    mkdir -p ~/.config/herdr
    create_symlink "$BASEDIR/herdr_config" "$HOME/.config/herdr/config.toml"
}

tasktmux(){
    echo_title 'Tmux'

    create_symlink "$BASEDIR/tmux.conf" "$HOME/.tmux.conf"
}

taskzsh(){
    echo_title 'Zsh'

    if [ ! -d ~/.oh-my-zsh ]; then
        echo 'Instalando Oh My Zsh'
        RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    else
        echo 'Atualizando Oh My Zsh'
        zsh -c 'source ~/.oh-my-zsh/lib/cli.zsh && omz update'
    fi

    if [ ! -d ~/.local/share/zinit/zinit.git ]; then
        echo 'Instalando Zinit'
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
    else
        echo 'Atualizando Zinit'
        zsh -c "source $HOME/.local/share/zinit/zinit.git/zinit.zsh && zinit update --all"
    fi

    create_symlink "$BASEDIR/zshrc" "$HOME/.zshrc"
    create_symlink "$BASEDIR/p10k.zsh" "$HOME/.p10k.zsh"
}

taskfzf(){
    echo_title 'FZF'

    if [ ! -d ~/.fzf ]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    else
        git -C ~/.fzf pull
    fi
    ~/.fzf/install --all
}

taskpyenv(){
    echo_title 'PyEnv'

    if [ "$OS_ID" = "macos" ]; then
        echo 'PyEnv gerenciado via Homebrew (taskshell), nada a fazer aqui.'
        return
    fi

    if [ ! -d ~/.pyenv ]; then
        echo 'Instalando PyEnv'
        git clone https://github.com/pyenv/pyenv.git ~/.pyenv
    fi
    ( cd ~/.pyenv && git pull && src/configure && make -C src )
}

taskpython(){
    echo_title 'Python'

    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"

    if [ "$(pyenv global 2>/dev/null)" = "system" ]; then
        LATEST=$(pyenv install --list | grep -E '^\s+3\.[0-9]+\.[0-9]+$' | tail -1 | tr -d ' ')
        echo "Instalando Python $LATEST via pyenv..."
        pyenv install --skip-existing "$LATEST"
        pyenv global "$LATEST"
    fi

    pip3 install --upgrade -r dependencies-python.txt
}

tasknodejs(){
    echo_title 'NodeJS'

    # PROFILE=/dev/null impede o instalador do nvm de anexar o carregamento ao zshrc
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | PROFILE=/dev/null bash

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

    nvm install --lts
    npm install -g npm
    npm install -g $(cat dependencies-nodejs.txt)
}

taskvim(){
    echo_title 'VIM'

    create_symlink "$BASEDIR/vimrc" "$HOME/.vimrc"

    if [ ! -d ~/.vim ]; then
        vim +PlugInstall +qall
    fi

    vim +PlugUpgrade +qall
    vim +PlugUpdate +qall

    if [ -d ~/.vim/plugged/YouCompleteMe ]; then
        ( cd ~/.vim/plugged/YouCompleteMe && ./install.py --ts-completer --java-completer )
    fi
}

taskvscode() {
    echo_title 'VSCode'

    if ! command -v code >/dev/null 2>&1; then
        echo "Aviso: comando 'code' nao encontrado (abra o VS Code e rode 'Shell Command: Install code in PATH'); pulando."
        return 1
    fi

    for extension in $(cat dependencies-vscode.txt)
    do
        code --install-extension $extension
    done
}

is_gnome() {
    echo "${XDG_CURRENT_DESKTOP:-}" | grep -qi gnome && return 0
    command -v gnome-shell >/dev/null 2>&1 && return 0
    return 1
}

taskgnome(){
    echo_title 'GNOME'

    if ! is_gnome; then
        echo "GNOME não detectado, pulando."
        return
    fi

    DEPFILE="dependencies-gnome.txt"
    case "$OS_ID" in
        suse)
            [ -f "$DEPFILE" ] && sudo zypper install -y $(cat "$DEPFILE")
            ;;
        *)
            [ -f "$DEPFILE" ] && sudo apt install -y $(cat "$DEPFILE")
            ;;
    esac
}

tasksdkman(){
    echo_title 'SDKMAN!'
    export SDKMAN_DIR="$HOME/.sdkman"
    if [ ! -d "$SDKMAN_DIR" ]; then
        echo "Instalando SDKMAN!..."
        curl -fsSL "https://get.sdkman.io" | bash
        [ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ] && . "$SDKMAN_DIR/bin/sdkman-init.sh"
    else
        echo "Atualizando SDKMAN!..."
        [ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ] && . "$SDKMAN_DIR/bin/sdkman-init.sh"
        sdk selfupdate
    fi
}

if [ $# -eq 0 ]; then
    taskshell
    taskterminator
    taskherdr
    tasktmux
    taskzsh
    taskfzf
    taskpyenv
    taskpython
    tasknodejs
    taskvim
    taskvscode
    tasksdkman
    taskgnome
fi

EXIT_CODE=0
for PARAM in "$@"
do
    case $PARAM in
        'shell')
            taskshell
            ;;
        'terminator')
            taskterminator
            ;;
        'herdr')
            taskherdr
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
        'vscode')
            taskvscode
            ;;
        'sdkman')
            tasksdkman
            ;;
        'gnome')
            taskgnome
            ;;
        *)
            printf "Não existe esta opção: %s\n" "$PARAM"
            EXIT_CODE=1
            ;;
    esac
done
exit "$EXIT_CODE"
