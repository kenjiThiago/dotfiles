autoload -Uz compinit && compinit

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [ ! -d "$ZINIT_HOME" ] && command -v git >/dev/null; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# fastfetch

# Plugins
if [[ -r "${ZINIT_HOME}/zinit.zsh" ]]; then
    source "${ZINIT_HOME}/zinit.zsh"

    zinit light zsh-users/zsh-syntax-highlighting
    zinit light zsh-users/zsh-completions
    zinit light zsh-users/zsh-autosuggestions
fi

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey -s '^[^F' "tmux-sessionizer\n"

# Aparência da completação
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Aliases
alias nv="nvim"
alias c="clear"
# alias cat="bat --paging=never"

# Como no .bashrc: sem eza não se perde a cor, se perde o `ls`.
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

# O prompt transiente inteiro é do starship: o transiente é o mesmo comando com
# --profile transient. Sem ele sobra o prompt de duas linhas abaixo, sem estado
# do git, que no .bashrc vem do set_custom_prompt.
if command -v starship >/dev/null; then
    eval "$(starship init zsh)"

    # Sem right_format no template, o RPROMPT do init só forkava o starship a
    # cada redraw para devolver string vazia. Se um dia entrar um, é esta linha
    # que sai.
    RPROMPT=""

    # O PROMPT do starship não muda depois do init, então a substituição é feita
    # uma vez só.
    STARSHIP_ORIG_PROMPT=$PROMPT
    STARSHIP_TRANSIENT_PROMPT="${PROMPT/ prompt / prompt --profile transient }"

    function set_transient_prompt() {
        PROMPT=$STARSHIP_TRANSIENT_PROMPT
        zle reset-prompt
    }

    zle -N set_transient_prompt
    autoload -Uz add-zle-hook-widget
    add-zle-hook-widget zle-line-finish set_transient_prompt

    # Nem todo Ctrl-C encerra a linha: cancelar a pergunta "do you wish to see
    # all N possibilities" devolve o controle para a mesma linha, e aí o precmd
    # nunca roda para desfazer o transiente que o TRAPINT aplicou.
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

# O lazygit não tem include: o config.yml versionado traz o comportamento e o
# colors.yml vem do `theme set`. O tmux-lazygit repete isto por conta própria,
# porque a sessão do popup não herda o ambiente deste shell.
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

# Caminho do pacote nvm do Arch. É a coisa menos essencial daqui, e sem o teste
# bastaria desinstalar o nvm para todo shell novo abrir com erro.
[[ -f /usr/share/nvm/init-nvm.sh ]] && source /usr/share/nvm/init-nvm.sh

export PATH

# Ajustes de uma máquina só, como no .bashrc. Não é versionado, e vem antes do
# exec: depois dele nada mais nesta config roda.
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

if [[ -z "$TMUX" && "$XDG_CURRENT_DESKTOP" == "Hyprland" ]]; then
    exec tmux new-session -A -s main
fi
