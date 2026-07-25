#!/usr/bin/env bash
# install.sh — instala esta configuração numa máquina nova (Arch Linux).
#
#   ./install.sh                 instalação completa
#   ./install.sh --dry           mostra o que faria, sem alterar nada
#   ./install.sh --skip-packages pula a instalação de pacotes
#   ./install.sh --skip-services pula habilitar serviços do systemd
#   ./install.sh --skip-plugins  pula baixar plugins de nvim/tmux
#   ./install.sh --theme <nome>  usa outro tema (padrão: rose-pine-moon)
#
# Etapas, nesta ordem:
#   1. checa dependências mínimas (git, stow, paru)
#   2. instala os pacotes de packages.txt
#   3. limpa links do layout antigo e linka os pacotes em ~ (dots)
#   4. aplica o tema (theme set)
#   5. habilita os serviços do systemd
#   6. prepara o ambiente (shell, XDG, plugins de nvim e tmux)
#
# É idempotente: pode rodar de novo depois de mexer no repositório.

set -euo pipefail

DOTFILES=$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")" && pwd)
export DOTFILES

THEME_NAME="rose-pine-moon"
DRY=0
SKIP_PACKAGES=0
SKIP_SERVICES=0
SKIP_PLUGINS=0

# Serviços que as configs assumem ligados: o waybar tem um módulo de
# power-profiles-daemon e o rofi-script abre o nm-connection-editor.
SERVICES=(NetworkManager power-profiles-daemon)

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
        --skip-services) SKIP_SERVICES=1 ;;
        --skip-plugins)  SKIP_PLUGINS=1 ;;
        --theme)         shift; THEME_NAME=${1:?--theme precisa de um nome} ;;
        -h|--help)       sed -n '2,19p' "$0" | sed 's/^# \?//'; exit 0 ;;
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
dots_args=()
if [[ $DRY == 1 ]]; then dots_args+=(--dry); fi
DOTS="$DOTFILES/packages/bin/.local/bin/dots"

# Numa máquina que já teve o layout antigo, sobram symlinks apontando para
# <repo>/config/. O stow se recusa a sobrescrever, então limpa antes.
msg "Procurando symlinks do layout antigo"
"$DOTS" migrate "${dots_args[@]}"

msg "Linkando as configurações em ~"
"$DOTS" link "${dots_args[@]}"

# ── 4. Tema ───────────────────────────────────────────────────────────────────
msg "Aplicando o tema '$THEME_NAME'"

theme_args=(--no-reload)
if [[ $DRY == 1 ]]; then theme_args+=(--dry); fi
"$DOTFILES/packages/bin/.local/bin/theme" set "$THEME_NAME" "${theme_args[@]}"

# ── 5. Serviços ───────────────────────────────────────────────────────────────
enable_service() {
    local unit=$1
    if ! systemctl cat "$unit.service" >/dev/null 2>&1; then
        warn "$unit não está instalado, pulando"
        return 0
    fi
    if systemctl is-enabled --quiet "$unit.service" 2>/dev/null; then
        ok "$unit já habilitado"
        return 0
    fi
    run sudo systemctl enable --now "$unit.service"
}

if [[ $SKIP_SERVICES == 0 ]] && command -v systemctl >/dev/null; then
    msg "Habilitando serviços"
    for unit in "${SERVICES[@]}"; do
        enable_service "$unit"
    done
elif [[ $SKIP_SERVICES == 1 ]]; then
    msg "Pulando serviços (--skip-services)"
fi

# ── 6. Ambiente do usuário ────────────────────────────────────────────────────
msg "Preparando o ambiente"

# O rofi-script salva screenshots em $XDG_PICTURES_DIR, que só existe depois
# que o xdg-user-dirs roda pela primeira vez.
if command -v xdg-user-dirs-update >/dev/null; then
    run xdg-user-dirs-update
    ok "diretórios XDG atualizados"
fi

if ! command -v zsh >/dev/null; then
    warn "zsh não está instalado; shell padrão não foi trocado"
elif [[ ${SHELL##*/} == zsh ]]; then
    ok "shell padrão já é zsh"
else
    warn "trocando o shell padrão para zsh (o chsh vai pedir sua senha)"
    run chsh -s "$(command -v zsh)" || warn "chsh falhou; troque à mão depois"
fi

TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ ! -d $TPM_DIR ]]; then
    run git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
    ok "tpm instalado"
else
    ok "tpm já presente"
fi

if [[ $SKIP_PLUGINS == 0 ]]; then
    if [[ -x $TPM_DIR/bin/install_plugins ]]; then
        run "$TPM_DIR/bin/install_plugins" || warn "install_plugins falhou; rode prefix+I no tmux"
    fi

    # Baixa os plugins do vim.pack. O mason instala em background, então pode
    # ser que ainda falte um LSP na primeira sessão de verdade.
    if command -v nvim >/dev/null; then
        msg "Baixando plugins do neovim (pode demorar)"
        run timeout 600 nvim --headless "+qa" || warn "bootstrap do nvim falhou; abra o nvim à mão"
    fi
else
    msg "Pulando plugins (--skip-plugins)"
fi

# O zinit se instala sozinho no primeiro `zsh` (ver packages/zsh/.zshrc).

msg "Pronto"
cat <<EOF
  Ainda precisa da sua mão:
    - reinicie a sessão do Hyprland (ou rode: hyprctl reload)
    - abra o Zen Browser uma vez para criar o perfil, depois rode:
        theme set $THEME_NAME
      (é o que cria os symlinks de userChrome.css dentro do perfil)

  Comandos do dia a dia:
    dots status        o que está linkado
    dots relink <pkg>  refazer os links de um pacote
    theme list         temas disponíveis
    theme set <nome>   trocar de tema
EOF
