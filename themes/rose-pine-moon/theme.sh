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

# O love fica no error e na marca, fora do foco, que não deve ter a cor do perigo.
accent="#c4a7e7"     # iris
accent_alt="#ea9a97" # rose
success="#3e8fb0"    # pine
warning="#f6c177"    # gold
error="#eb6f92"      # love
info="#9ccfd8"       # foam
# Gold e não foam: o foam some no texto lavanda das listas.
match="#f6c177"      # gold
brand="#eb6f92"      # love
brand_alt="#c4a7e7"  # iris

# Fonte do colorscheme luar, lida pelo lua/theme.lua gerado.
syn_comment="#8b86a3"
syn_type="$subtle"
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
