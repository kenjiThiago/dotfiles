autoload -Uz compinit && compinit

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [ ! -d "$ZINIT_HOME" ] && command -v git >/dev/null; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

if [[ -r "${ZINIT_HOME}/zinit.zsh" ]]; then
    source "${ZINIT_HOME}/zinit.zsh"

    zinit light zsh-users/zsh-syntax-highlighting
    zinit light zsh-users/zsh-completions
    zinit light zsh-users/zsh-autosuggestions
fi

bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey -s '^[^F' "tmux-sessionizer\n"

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

alias nv="nvim"
alias c="clear"

if command -v eza >/dev/null; then
    alias ls="eza --color=always --icons=auto"
    alias ll="eza -lAF --color=always --icons=auto"
    alias l="eza -AF --color=always --icons=auto"
else
    alias ls="ls --color=auto"
    alias ll="ls -alFh --color=auto"
    alias l="ls -CF --color=auto"
fi

command -v fzf >/dev/null && source <(fzf --zsh)
command -v zoxide >/dev/null && eval "$(zoxide init --cmd cd zsh)"

if command -v starship >/dev/null; then
    eval "$(starship init zsh)"

    RPROMPT=""  # sem right_format, o RPROMPT só forkava o starship a cada redraw

    STARSHIP_ORIG_PROMPT=$PROMPT
    STARSHIP_TRANSIENT_PROMPT="${PROMPT/ prompt / prompt --profile transient }"

    function set_transient_prompt() {
        PROMPT=$STARSHIP_TRANSIENT_PROMPT
        zle reset-prompt
    }

    zle -N set_transient_prompt
    autoload -Uz add-zle-hook-widget
    add-zle-hook-widget zle-line-finish set_transient_prompt

    # Cancelar o "do you wish to see all N possibilities" volta para a mesma linha
    # sem passar pelo precmd, que é quem desfaz o transiente.
    function restore_prompt_if_transient() {
        [[ $PROMPT == "$STARSHIP_TRANSIENT_PROMPT" ]] || return 0
        PROMPT=$STARSHIP_ORIG_PROMPT
        zle reset-prompt
    }

    zle -N restore_prompt_if_transient
    add-zle-hook-widget zle-line-pre-redraw restore_prompt_if_transient

    function restore_starship_prompt() {
        PROMPT=$STARSHIP_ORIG_PROMPT
    }

    autoload -Uz add-zsh-hook
    add-zsh-hook precmd restore_starship_prompt

    TRAPINT() {
        zle && set_transient_prompt
        return $(( 128 + $1 ))
    }
else
    PROMPT='%F{cyan}%n@%m%f:%F{blue}%~%f
%F{green}❯%f '
fi

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey "^x^e" edit-command-line

clear_keep_buffer() {
    zle clear-screen
}

zle -N clear_keep_buffer
bindkey "^xl" clear_keep_buffer

HISTSIZE=10000
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

# O tmux-lazygit repete isto: a sessão do popup não herda este ambiente.
if [[ -f ~/.config/lazygit/colors.yml ]]; then
    export LG_CONFIG_FILE="$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/colors.yml"
fi

function y() {
    export YAZI_START_DIR="$PWD"
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	command rm -f -- "$tmp"
}

if [[ -z $TMUX ]]; then
    path+=("$HOME/go/bin")
    path+=("$HOME/.local/bin")
    path+=("$HOME/.local/share/nvim/mason/bin")
fi

[[ -f /usr/share/nvm/init-nvm.sh ]] && source /usr/share/nvm/init-nvm.sh

export PATH

# Vem antes do exec: depois dele nada mais roda.
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

if [[ -z "$TMUX" && "$XDG_CURRENT_DESKTOP" == "Hyprland" ]]; then
    exec tmux new-session -A -s main
fi
