#!/usr/bin/env bash
# Rosé Pine Moon — https://rosepinetheme.com
# Tema padrão desta configuração.
#
# Os nomes à direita são os nomes originais da paleta Rosé Pine, mantidos
# como comentário para facilitar a tradução entre os dois vocabulários.

variant="dark"

# ── Metadados ─────────────────────────────────────────────────────────────────
nvim_colorscheme="gruber-darker" # gruber-darker local, já tingido com o Moon
zen_theme="default"
wallpaper="space.jpg"
gtk_theme="Adwaita-dark"
cursor_theme="BreezeX-RosePine-Linux"

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

# ── Papéis de sintaxe ─────────────────────────────────────────────────────────
# Aqui a paleta semântica acima não serve: o nvim deste tema roda o
# gruber-darker, que usa as mesmas tintas do Moon em papéis diferentes. Sem
# isto, o preview do yazi mostraria o mesmo código com cores trocadas em
# relação ao buffer ao lado. Os nomes à direita são os do gruber-darker, em
# packages/nvim-plugins/plugins/gruber-darker/lua/gruber-darker/palette.lua.
syn_comment="#817c9c"   # burgundy, a única que não existe na paleta acima
syn_type="#817c9c"      # burgundy
syn_string="$cyan"      # dusty_rose
syn_escape="$magenta"   # plum
syn_constant="$magenta" # plum
syn_keyword="$red"      # crimson
syn_tag="$red"          # crimson
syn_function="$yellow"  # terracotta
syn_attribute="$yellow" # terracotta
syn_operator="$text"    # fg
syn_variable="$text"    # fg
syn_parameter="$text"   # fg

syn_keyword_style="bold"
syn_comment_style=""
syn_parameter_style=""
syn_attribute_style=""
