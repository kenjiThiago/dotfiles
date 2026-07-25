#!/usr/bin/env bash
# Catppuccin Mocha — https://catppuccin.com

variant="dark"

# ── Metadados ─────────────────────────────────────────────────────────────────
# Não há plugin do catppuccin instalado no nvim; duskfox (nightfox) é o
# colorscheme disponível mais próximo. Troque aqui se instalar o catppuccin.
nvim_colorscheme="duskfox"
zen_theme="catppuccin-mocha"
wallpaper="neon.png"
gtk_theme="Adwaita-dark"
cursor_theme="Adwaita"

# ── Camadas de fundo ──────────────────────────────────────────────────────────
base="#1e1e2e"    # base
surface="#313244" # surface0
overlay="#45475a" # surface1
term_bg="#11111b" # crust

# ── Realces / bordas ──────────────────────────────────────────────────────────
highlight_low="#181825"  # mantle
highlight_med="#45475a"  # surface1
highlight_high="#585b70" # surface2

# ── Texto ─────────────────────────────────────────────────────────────────────
muted="#6c7086"  # overlay0
subtle="#a6adc8" # subtext0
text="#cdd6f4"   # text

# ── Cores ANSI (terminais) ────────────────────────────────────────────────────
black="#45475a"   # surface1
red="#f38ba8"     # red
green="#a6e3a1"   # green
yellow="#f9e2af"  # yellow
blue="#89b4fa"    # blue
magenta="#f5c2e7" # pink
cyan="#94e2d5"    # teal
white="#bac2de"   # subtext1

bright_black="#585b70" # surface2

# ── Papéis de interface ───────────────────────────────────────────────────────
accent="#cba6f7"     # mauve
accent_alt="#f5c2e7" # pink
success="#a6e3a1"    # green
warning="#fab387"    # peach
error="#f38ba8"      # red
info="#89dceb"       # sky
