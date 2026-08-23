#!/usr/bin/env bash
# Rosé Pine Dawn (endurecido) — https://rosepinetheme.com
#
# Variante clara da paleta, retrabalhada para projetor. Único tema com
# variant="light": é o que faz o nvim ligar o `background=light`, o `theme`
# pedir `prefer-light` ao gsettings e o Zen escolher o esquema claro.
#
# As tintas do Dawn original não sobrevivem a uma projeção: o gold fica em
# 2.05:1 sobre o base, o rose em 2.60 e o muted, que é a cor dos comentários,
# em 2.73. Projetor comprime a faixa dinâmica e lava justamente a ponta clara,
# então tudo abaixo de 4.5:1 desaparece na parede. Aqui cada tinta foi
# reancorada por medida, não por gosto:
#
#   - texto, subtle e muted têm alvo contra o `overlay`, o fundo mais escuro em
#     que texto pousa, de modo que passam em qualquer camada;
#   - os acentos também miram o overlay, com saturação fixada em vez de
#     herdada: escurecer uma cor pouco saturada dá cinza, e projetor dessatura
#     mais ainda;
#   - as camadas de fundo viraram uma escada descendente (base > surface >
#     overlay). No Dawn original o surface é mais claro que o base e o overlay
#     fica a 1.10:1 dele, ou seja, as três são a mesma cor na parede.
#
# O custo é que isto não é mais o Dawn oficial: os acentos são bem mais
# profundos, e o gold vira âmbar escuro em vez de amarelo.
#
# Os nomes à direita são os nomes originais da paleta Rosé Pine.

variant="light"

# ── Metadados ─────────────────────────────────────────────────────────────────
nvim_colorscheme="rose-pine-dawn"
zen_theme="default"
wallpaper="samurai_bebop.png"
gtk_theme="Adwaita"
cursor_theme="BreezeX-RosePineDawn-Linux"

# Sem transparência: ela mistura o fundo do terminal com o que estiver atrás e
# derruba o contraste medido aqui, que é o ponto do tema.
opacity="1"

# ── Camadas de fundo ──────────────────────────────────────────────────────────
base="#faf4ed"    # base, o único valor herdado intacto do Dawn
surface="#f0e8e0" # 1.11:1 do base
overlay="#e6dbd1" # 1.25:1 do base
term_bg="#faf4ed" # base; o preto puro dos temas escuros não serve aqui

# ── Realces / bordas ──────────────────────────────────────────────────────────
highlight_low="#f4eee8"  # linha do cursor
# A seleção é o único ponto que não fecha 4.5:1: o `muted` sobre ela dá 3.89,
# ou seja, um comentário dentro de um trecho selecionado. Clarear o
# highlight_med até resolver isso o aproxima do base a ponto de a seleção
# deixar de se ver na parede, que é o problema pior dos dois.
highlight_med="#d5ccca"  # seleção; text 7.42:1, subtle 4.76, muted 3.89
highlight_high="#b9acb6" # bordas, 1.99:1 do base

# ── Texto ─────────────────────────────────────────────────────────────────────
text="#39354f"   # 10.71:1 sobre base, 8.58 sobre overlay
subtle="#555269" # 6.87 / 5.51
muted="#645f72"  # 5.62 / 4.51; é a cor dos comentários, e é o que mais sofria

# ── Cores ANSI (terminais) ────────────────────────────────────────────────────
# O slot do black fica com o overlay e o do white com o text, como nos outros
# Rosé Pine: é a convenção dos ports oficiais, e inverter aqui deixaria texto
# claro sobre fundo claro em quem imprime ANSI cru.
#
# Duas trocas em relação aos ports, e são de propósito. O Rosé Pine não tem
# verde: o port manda `green` para o pine, que é azul-petróleo, e `blue` para o
# foam, que é o mesmo azul-petróleo mais claro. Nos temas escuros a diferença de
# luminosidade entre os dois basta; aqui, com os dois puxados para o mesmo alvo
# de contraste, eles colapsam num par indistinguível (ΔE 14), e ler um `git
# diff` ou um `ls` projetado vira adivinhação. Então `green` passa a sair do
# leaf, que é o verde que a paleta tem e que os ports não usam, e `blue` do
# pine, que é o mais profundo dos dois azuis. Todo par de acentos fica em ΔE 26
# ou mais.
black="#e6dbd1"   # overlay
red="#7f2d44"     # love
green="#205e3d"   # leaf
yellow="#795c0a"  # gold
blue="#174d77"    # pine
magenta="#634683" # iris
cyan="#286a72"    # foam
white="#39354f"   # text

bright_black="#645f72" # muted

# Os demais bright_* caem no normal, e é o que se quer: num tema claro "bright"
# significaria mais claro, isto é, menos legível.

# ── Papéis de interface ───────────────────────────────────────────────────────
accent="#7f2d44"     # love
accent_alt="#634683" # iris
success="#205e3d"    # leaf
warning="#795c0a"    # gold
error="#7f2d44"      # love
info="#174d77"       # pine
