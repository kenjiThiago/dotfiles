autoload -Uz compinit && compinit

# Cria o diretorio do plugin manager
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Instala o plugin manager se ele não estiver instalado
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# Plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey -s '^[^F' "tmux-sessionizer\n"

# Aparência do Compition
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

#Alias
alias nv="nvim"
alias ls="ls --color"
alias c="clear"
alias l="ls -lA"

# Inicia fzf
source <(fzf --zsh)
# Inicia zoxide
eval "$(zoxide init --cmd cd zsh)"
# Inicia starship
eval "$(starship init zsh)"

# Historico de comandos
HISTSIZE=2000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

export TIMEFMT=$'%*E'

lazy_load_nvm() {
    unset -f npm node nvm

    #Inicia npm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
}

npm() {
    lazy_load_nvm
    npm $@
}

node() {
    lazy_load_nvm
    node $@
}

nvm() {
    lazy_load_nvm
    nvm $@
}