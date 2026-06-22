# DotFiles

Minhas configurações e setup de ambiente para macOS, Ubuntu/Debian e SUSE.

## Instalação rápida

```sh
sh -c "$(wget https://raw.githubusercontent.com/starlone/dotfiles/master/bootstrap.sh -O -)"
```

Ou clonando o repositório:

```sh
git clone https://github.com/starlone/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

## O que é instalado

| Task | Ferramentas |
|---|---|
| `shell` | Pacotes base via brew / apt / zypper |
| `zsh` | Oh My Zsh, Zinit, Powerlevel10k |
| `tmux` | Configuração do tmux |
| `terminator` | Configuração do Terminator |
| `fzf` | Fuzzy finder |
| `pyenv` | Gerenciador de versões Python |
| `python` | Pacotes pip (dependencies-python.txt) |
| `nodejs` | NVM + Node.js LTS + pacotes npm |
| `vim` | Configuração + plugins via vim-plug |
| `vscode` | Extensões (dependencies-vscode.txt) |
| `sdkman` | SDKMAN! para SDKs Java/Kotlin/Scala |
| `gnome` | Tweaks e extensões GNOME (detectado automaticamente) |

## Uso seletivo

É possível rodar apenas uma task específica:

```sh
./install.sh zsh
./install.sh sdkman
./install.sh vscode
```

## Idempotente

O script pode ser executado múltiplas vezes com segurança. Ferramentas já instaladas serão atualizadas; links simbólicos existentes não são recriados desnecessariamente.

## Sistemas suportados

- macOS (Homebrew)
- Ubuntu / Debian (apt)
- SUSE / openSUSE (zypper)
