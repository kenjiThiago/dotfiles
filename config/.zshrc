autoload -Uz compinit && compinit

# Cria o diretorio do plugin manager
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Instala o plugin manager se ele não estiver instalado
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# fastfetch

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
alias ls="eza --color=always --icons=auto"
alias c="clear"
alias l="eza -lA --color=always --icons=auto"
# alias cat="bat --paging=never"

# Inicia fzf
source <(fzf --zsh)
# Inicia zoxide
eval "$(zoxide init --cmd cd zsh)"
# Inicia starship
eval "$(starship init zsh)"

STARSHIP_ORIG_PROMPT=$PROMPT
STARSHIP_ORIG_RPROMPT=$RPROMPT

function set_transient_prompt() {
    PROMPT="${STARSHIP_ORIG_PROMPT// prompt / prompt --profile transient }"
    RPROMPT=""
    zle reset-prompt
}

zle -N set_transient_prompt
autoload -Uz add-zle-hook-widget
add-zle-hook-widget zle-line-finish set_transient_prompt

function restore_starship_prompt() {
    PROMPT=$STARSHIP_ORIG_PROMPT
    RPROMPT=$STARSHIP_ORIG_RPROMPT
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd restore_starship_prompt

TRAPINT() {
    zle && set_transient_prompt
    return $(( 128 + $1 ))
}

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey "^x^e" edit-command-line

clear_keep_buffer() {
    zle clear-screen
}

zle -N clear_keep_buffer
bindkey "^xl" clear_keep_buffer

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
export MANPAGER="nvim +Man!"
export LESS='-R --use-color -Dd+r$Du+b$'
export EDITOR="nvim"
export MANGOHUD=0
export PS2="$(starship prompt --continuation)"

function y() {
    export YAZI_START_DIR="$PWD"
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	command rm -f -- "$tmp"
}

if [[ -z $TMUX ]]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

    path+=("$HOME/go/bin")
    path+=("$HOME/.local/bin")
    path+=("$HOME/.local/share/nvim/mason/bin")
fi

export PATH

if [[ -z "$TMUX" && "$XDG_CURRENT_DESKTOP" == "Hyprland" ]]; then
    exec tmux new-session -A -s main
fi
