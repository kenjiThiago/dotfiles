#!/usr/bin/env bash
# Rosé Pine Moon — https://rosepinetheme.com (tema padrão)

variant="dark"

nvim_colorscheme="luar" # colorscheme local, já tingido com o Moon
zen_theme="default"
wallpaper="space.jpg"
gtk_theme="Adwaita-dark"
cursor_theme="BreezeX-RosePine-Linux"

base="#232136"    # base
surface="#2a273f" # surface
overlay="#393552" # overlay
term_bg="#010101" # só o alacritty: preto puro, para usar com opacity 0.8

highlight_low="#2a283e"
highlight_med="#44415a"
highlight_high="#56526e"

muted="#6e6a86"  # muted
subtle="#908caa" # subtle
text="#e0def4"   # text

black="#393552"   # overlay
red="#eb6f92"     # love
green="#3e8fb0"   # pine
yellow="#f6c177"  # gold
blue="#9ccfd8"    # foam
magenta="#c4a7e7" # iris
cyan="#ea9a97"    # rose
white="#e0def4"   # text

bright_black="#6e6a86" # muted

accent="#eb6f92"     # love
accent_alt="#c4a7e7" # iris
success="#3e8fb0"    # pine
warning="#f6c177"    # gold
error="#eb6f92"      # love
info="#9ccfd8"       # foam

# Fonte do colorscheme luar, lida pelo lua/theme.lua gerado.
syn_comment="#817c9c"   # a única tinta que não existe na paleta acima
syn_type="#817c9c"      # tipo divide a tinta do comentário, é a des-ênfase pretendida
syn_string="$cyan"      # rose
syn_escape="$magenta"   # iris
syn_constant="$magenta" # iris
syn_keyword="$red"      # love
syn_tag="$red"          # love
syn_function="$yellow"  # gold
syn_attribute="$yellow" # gold
syn_operator="$text"    # text
syn_variable="$text"    # text
syn_parameter="$text"   # text

syn_keyword_style="bold"
syn_comment_style=""
syn_parameter_style=""
syn_attribute_style=""
