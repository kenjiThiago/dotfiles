# Vale no desktop (shell secundário) e no servidor (principal): toda ferramenta
# extra fica atrás de `command -v`.

[[ $- != *i* ]] && return

HISTCONTROL=ignoreboth:erasedups
HISTSIZE=5000
HISTFILESIZE=5000
shopt -s histappend
shopt -s checkwinsize

# Grava e relê a cada prompt para os panes do tmux compartilharem o histórico.
PROMPT_COMMAND="history -a; history -n; ${PROMPT_COMMAND:-}"

export EDITOR=nvim

# O Debian só adiciona o ~/.local/bin pelo ~/.profile, que não roda em shell não-login.
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) PATH="$HOME/.local/bin:$PATH" ;;
esac
export PATH

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

if [[ -f ~/.config/lazygit/colors.yml ]]; then
    export LG_CONFIG_FILE="$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/colors.yml"
fi

if command -v eza >/dev/null; then
    alias ls="eza --color=always --icons=auto"
    alias ll="eza -lAF --color=always --icons=auto"
    alias l="eza -AF --color=always --icons=auto"
    alias la="eza -A --color=always --icons=auto"
else
    alias ls='ls --color=auto'
    alias ll='ls -alFh --color=auto'
    alias l='ls -CF --color=auto'
    alias la='ls -A --color=auto'
fi

alias grep='grep --color=auto'
alias c="clear"
alias nv="nvim"
alias gs="git status"
alias gf="git fetch --all --prune"
alias srv="source .venv/bin/activate"

set_custom_prompt() {
    local RESET="\[\e[0m\]" BOLD="\[\e[1m\]" RED="\[\e[31m\]"
    local GREEN="\[\e[32m\]" YELLOW="\[\e[33m\]" BLUE="\[\e[34m\]" CYAN="\[\e[36m\]"

    local venv_info=""
    if [ -n "$VIRTUAL_ENV" ]; then venv_info="(${YELLOW}$(basename "$VIRTUAL_ENV")${RESET}) "; fi

    local git_info="" branch color status_details ahead_behind ahead behind
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
        if [ -n "$branch" ]; then
            color=$GREEN
            status_details=""

            ahead_behind=$(git rev-list --left-right --count HEAD...@'{u}' 2>/dev/null)
            if [ -n "$ahead_behind" ]; then
                ahead=${ahead_behind%%[[:space:]]*}
                behind=${ahead_behind##*[[:space:]]}
                if [ "$ahead" -gt 0 ]; then status_details+=" ↑$ahead"; fi
                if [ "$behind" -gt 0 ]; then status_details+=" ↓$behind"; fi
            fi

            if ! git diff --quiet --cached; then status_details+=" +"; color=$YELLOW; fi
            if ! git diff --quiet; then status_details+=" *"; color=$YELLOW; fi
            if [ -n "$(git ls-files --others --exclude-standard)" ]; then status_details+=" ?"; color=$YELLOW; fi
            if git rev-parse --verify refs/stash >/dev/null 2>&1; then status_details+=" §"; fi
            if [ -n "$(git ls-files --unmerged)" ]; then status_details+=" !"; color=$RED; fi

            if [ -n "$status_details" ]; then
                git_info=" (${color}${branch}${RESET}${BOLD}[${status_details} ]${RESET})"
            else
                git_info=" (${GREEN}${branch}${RESET})"
            fi
        fi
    fi

    PS1="${venv_info}${CYAN}\u@\h${RESET}:${BLUE}\w${RESET}${git_info}\n${GREEN}❯${RESET} "
}

if command -v starship >/dev/null; then
    eval "$(starship init bash)"
else
    PROMPT_COMMAND="set_custom_prompt; ${PROMPT_COMMAND:-}"
fi

command -v fzf >/dev/null && eval "$(fzf --bash)"
command -v zoxide >/dev/null && eval "$(zoxide init --cmd cd bash)"

bind '"\e\C-f": "tmux-sessionizer\n"'

if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

[ -f ~/.bashrc.local ] && . ~/.bashrc.local
