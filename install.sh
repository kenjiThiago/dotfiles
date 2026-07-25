#!/usr/bin/env bash
# install.sh — instala esta configuração numa máquina nova (Arch Linux).
#
#   ./install.sh                 instalação completa
#   ./install.sh --dry           mostra o que faria, sem alterar nada
#   ./install.sh --skip-packages pula a instalação de pacotes
#   ./install.sh --theme <nome>  usa outro tema (padrão: rose-pine-moon)
#
# Etapas, nesta ordem:
#   1. checa dependências mínimas (git, stow, paru)
#   2. instala os pacotes de packages.txt
#   3. linka os pacotes do stow em ~ (dots link)
#   4. aplica o tema (theme set)
#   5. avisos finais (shell padrão, tpm, etc.)
#
# É idempotente: pode rodar de novo depois de mexer no repositório.

set -euo pipefail

DOTFILES=$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")" && pwd)
export DOTFILES

THEME_NAME="rose-pine-moon"
DRY=0
SKIP_PACKAGES=0

msg()  { printf '\n\033[1;34m::\033[0m \033[1m%s\033[0m\n' "$*"; }
ok()   { printf '\033[1;32m ✔\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m !!\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m ✗\033[0m %s\n' "$*" >&2; exit 1; }

run() {
    if [[ $DRY == 1 ]]; then
        printf '\033[2;37m[dry]\033[0m %s\n' "$*"
    else
        "$@"
    fi
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry|--dry-run) DRY=1 ;;
        --skip-packages) SKIP_PACKAGES=1 ;;
        --theme)         shift; THEME_NAME=${1:?--theme precisa de um nome} ;;
        -h|--help)       sed -n '2,18p' "$0" | sed 's/^# \?//'; exit 0 ;;
        *)               die "opção desconhecida: $1" ;;
    esac
    shift
done

# ── 1. Dependências mínimas ───────────────────────────────────────────────────
msg "Verificando dependências"

command -v git >/dev/null || die "git não está instalado"

if ! command -v stow >/dev/null; then
    warn "GNU Stow não encontrado"
    if command -v pacman >/dev/null; then
        run sudo pacman -S --needed --noconfirm stow
    else
        die "instale o GNU Stow e rode de novo"
    fi
fi
ok "git e stow presentes"

# ── 2. Pacotes ────────────────────────────────────────────────────────────────
if [[ $SKIP_PACKAGES == 0 ]]; then
    msg "Instalando pacotes de packages.txt"

    if ! command -v pacman >/dev/null; then
        warn "isto não parece ser um Arch; pulando a instalação de pacotes"
    else
        if ! command -v paru >/dev/null; then
            warn "paru não encontrado — instalando a partir do AUR"
            if [[ $DRY == 0 ]]; then
                tmp=$(mktemp -d)
                git clone --depth 1 https://aur.archlinux.org/paru.git "$tmp/paru"
                (cd "$tmp/paru" && makepkg -si --noconfirm)
                rm -rf "$tmp"
            else
                printf '\033[2;37m[dry]\033[0m clonaria e compilaria o paru\n'
            fi
        fi

        mapfile -t pkgs < <(sed -e 's/#.*//' -e '/^[[:space:]]*$/d' \
            -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' "$DOTFILES/packages.txt")
        printf '   %d pacotes na lista\n' "${#pkgs[@]}"
        run paru -S --needed "${pkgs[@]}"
    fi
else
    msg "Pulando instalação de pacotes (--skip-packages)"
fi

# ── 3. Symlinks ───────────────────────────────────────────────────────────────
msg "Linkando as configurações em ~"

dots_args=()
if [[ $DRY == 1 ]]; then dots_args+=(--dry); fi
"$DOTFILES/packages/bin/.local/bin/dots" link "${dots_args[@]}"

# ── 4. Tema ───────────────────────────────────────────────────────────────────
msg "Aplicando o tema '$THEME_NAME'"

theme_args=(--no-reload)
if [[ $DRY == 1 ]]; then theme_args+=(--dry); fi
"$DOTFILES/packages/bin/.local/bin/theme" set "$THEME_NAME" "${theme_args[@]}"

# ── 5. Extras ─────────────────────────────────────────────────────────────────
msg "Extras"

TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ ! -d $TPM_DIR ]]; then
    run git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
    ok "tpm instalado"
else
    ok "tpm já presente"
fi

# O zinit se instala sozinho no primeiro `zsh` (ver packages/zsh/.zshrc).

if [[ ${SHELL##*/} != zsh ]] && command -v zsh >/dev/null; then
    warn "seu shell padrão ainda é ${SHELL##*/}; troque com: chsh -s $(command -v zsh)"
fi

msg "Pronto"
cat <<EOF
  Próximos passos:
    - reinicie a sessão do Hyprland (ou rode: hyprctl reload)
    - abra o nvim uma vez para os plugins e o mason baixarem
    - abra o Zen Browser uma vez para criar o perfil, depois rode:
        theme set $THEME_NAME
      (é o que cria os symlinks de userChrome.css dentro do perfil)

  Comandos do dia a dia:
    dots status        o que está linkado
    dots relink <pkg>  refazer os links de um pacote
    theme list         temas disponíveis
    theme set <nome>   trocar de tema
EOF
