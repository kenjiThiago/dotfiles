#!/usr/bin/env bash
# Rosé Pine Moon — https://rosepinetheme.com
# Tema padrão desta configuração.
#
# Os nomes à direita são os nomes originais da paleta Rosé Pine, mantidos
# como comentário para facilitar a tradução entre os dois vocabulários.

variant="dark"

# ── Metadados ─────────────────────────────────────────────────────────────────
nvim_colorscheme="gruber-darker" # gruber-darker local, já tingido com o Moon
zen_theme="rose-pine"
wallpaper="space.jpg"
# Vazio = o `theme` não escreve no gsettings (ver README).
gtk_theme=""
cursor_theme=""

# ── Camadas de fundo ──────────────────────────────────────────────────────────
base="#232136"    # base
surface="#2a273f" # surface
overlay="#393552" # overlay
term_bg="#010101" # só o alacritty: preto puro, para usar com opacity 0.8

# ── Realces / bordas ──────────────────────────────────────────────────────────
highlight_low="#2a283e"
highlight_med="#44415a"
highlight_high="#56526e"

# ── Texto ─────────────────────────────────────────────────────────────────────
muted="#6e6a86"  # muted
subtle="#908caa" # subtle
text="#e0def4"   # text

# ── Cores ANSI (terminais) ────────────────────────────────────────────────────
black="#393552"   # overlay
red="#eb6f92"     # love
green="#3e8fb0"   # pine
yellow="#f6c177"  # gold
blue="#9ccfd8"    # foam
magenta="#c4a7e7" # iris
cyan="#ea9a97"    # rose
white="#e0def4"   # text

bright_black="#6e6a86" # muted

# ── Papéis de interface ───────────────────────────────────────────────────────
accent="#eb6f92"     # love
accent_alt="#c4a7e7" # iris
success="#3e8fb0"    # pine
warning="#f6c177"    # gold
error="#eb6f92"      # love
info="#9ccfd8"       # foam
