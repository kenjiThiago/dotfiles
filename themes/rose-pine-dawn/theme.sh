#!/usr/bin/env bash
# Rosé Pine Dawn endurecido para projetor — https://rosepinetheme.com
# Cada tinta foi reancorada para ≥ 4.5:1 contra o `overlay`, e as camadas de fundo
# viraram uma escada descendente. Não é mais o Dawn oficial.

variant="light"

nvim_colorscheme="luar"
zen_theme="default"
wallpaper="samurai_bebop.png"
gtk_theme="Adwaita"
cursor_theme="BreezeX-RosePineDawn-Linux"

# Sem transparência: derrubaria o contraste medido.
opacity="1"

base="#faf4ed"    # base, o único valor herdado intacto do Dawn
surface="#f0e8e0" # 1.11:1 do base
overlay="#e6dbd1" # 1.25:1 do base
term_bg="#faf4ed" # base; o preto puro dos temas escuros não serve aqui

highlight_low="#f4eee8"  # linha do cursor
# Único ponto abaixo de 4.5:1: muted sobre a seleção (3.89). Clarear mais apagaria
# a seleção na parede.
highlight_med="#d5ccca"  # seleção; text 7.42:1, subtle 4.76, muted 3.89
highlight_high="#b9acb6" # bordas, 1.99:1 do base

text="#39354f"   # 10.71:1 sobre base, 8.58 sobre overlay
subtle="#555269" # 6.87 / 5.51
muted="#645f72"  # 5.62 / 4.51; é a cor dos comentários, e é o que mais sofria

# green sai do leaf e blue do pine: os do port oficial (pine e foam) colapsam aqui
# num par indistinguível.
black="#e6dbd1"   # overlay
red="#7f2d44"     # love
green="#205e3d"   # leaf
yellow="#795c0a"  # gold
blue="#174d77"    # pine
magenta="#634683" # iris
cyan="#286a72"    # foam
white="#39354f"   # text

bright_black="#645f72" # muted

# Os demais bright_* caem no normal: num tema claro, mais claro é menos legível.

accent="#7f2d44"     # love
accent_alt="#634683" # iris
success="#205e3d"    # leaf
warning="#795c0a"    # gold
error="#7f2d44"      # love
info="#174d77"       # pine

# O luar distribui as tintas por papel. Em relação ao moon, syn_type vai para o
# subtle e syn_string para o leaf, pelo contraste na projeção.
syn_comment="$bright_black" # muted, 4.51
syn_type="$subtle"          # subtle, 5.51
syn_string="$green"         # leaf, 5.65
syn_escape="$magenta"       # iris, 5.64
syn_constant="$magenta"     # iris
syn_keyword="$red"          # love, 6.53
syn_tag="$red"              # love
syn_function="$yellow"      # gold, 4.60; a tinta mais apertada, como no resto do tema
syn_attribute="$yellow"     # gold
syn_operator="$text"        # text, 8.58
syn_variable="$text"        # text
syn_parameter="$text"       # text

syn_keyword_style="bold"
syn_comment_style=""
syn_parameter_style=""
syn_attribute_style=""
