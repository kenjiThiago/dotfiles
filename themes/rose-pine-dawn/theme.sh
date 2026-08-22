#!/usr/bin/env bash
# Rosé Pine Dawn — https://rosepinetheme.com
# Variante clara da paleta. Único tema com variant="light": é o que faz o nvim
# ligar o `background=light` e o `theme` pedir `prefer-light` ao gsettings.

variant="light"

# ── Metadados ─────────────────────────────────────────────────────────────────
nvim_colorscheme="rose-pine-dawn"
zen_theme="default"
wallpaper="samurai_bebop.png"
# Vazio = o `theme` não escreve no gsettings (ver README).
gtk_theme=""
cursor_theme=""

# ── Camadas de fundo ──────────────────────────────────────────────────────────
base="#faf4ed"    # base
surface="#fffaf3" # surface
overlay="#f2e9e1" # overlay
term_bg="#faf4ed" # base; o preto puro dos temas escuros não serve aqui

# ── Realces / bordas ──────────────────────────────────────────────────────────
highlight_low="#f4ede8"
highlight_med="#dfdad9"
highlight_high="#cecacd"

# ── Texto ─────────────────────────────────────────────────────────────────────
muted="#9893a5"  # muted
subtle="#797593" # subtle
text="#575279"   # text

# ── Cores ANSI (terminais) ────────────────────────────────────────────────────
# O slot do black fica com o overlay e o do white com o text, como nos outros
# dois Rosé Pine: é a convenção dos ports oficiais, e inverter aqui deixaria
# texto claro sobre fundo claro em quem imprime ANSI cru.
black="#f2e9e1"   # overlay
red="#b4637a"     # love
green="#286983"   # pine
yellow="#ea9d34"  # gold
blue="#56949f"    # foam
magenta="#907aa9" # iris
cyan="#d7827e"    # rose
white="#575279"   # text

bright_black="#9893a5" # muted

# ── Papéis de interface ───────────────────────────────────────────────────────
accent="#b4637a"     # love
accent_alt="#907aa9" # iris
success="#286983"    # pine
warning="#ea9d34"    # gold
error="#b4637a"      # love
info="#56949f"       # foam
