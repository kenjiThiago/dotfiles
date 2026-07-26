#!/usr/bin/env bash
# Tokyo Night Moon — https://github.com/folke/tokyonight.nvim

variant="dark"

# ── Metadados ─────────────────────────────────────────────────────────────────
# Requer o plugin tokyonight instalado no nvim; sem ele o `theme` avisa e o
# nvim cai no colorscheme padrão.
nvim_colorscheme="tokyonight-moon"
zen_theme="nebula"
wallpaper="nice-blue-background.png"
# Vazio = o `theme` não escreve no gsettings (ver README).
gtk_theme=""
cursor_theme=""

# ── Camadas de fundo ──────────────────────────────────────────────────────────
base="#222436"    # bg
surface="#1e2030" # bg_dark / bg_float
overlay="#2f334d" # bg_highlight
term_bg="#1b1d2b"

# ── Realces / bordas ──────────────────────────────────────────────────────────
highlight_low="#1e2030"
highlight_med="#2d3f76" # bg_visual
highlight_high="#444a73" # terminal_black

# ── Texto ─────────────────────────────────────────────────────────────────────
muted="#636da6"  # comment
subtle="#828bb8" # fg_dark
text="#c8d3f5"   # fg

# ── Cores ANSI (terminais) ────────────────────────────────────────────────────
black="#444a73"   # terminal_black
red="#ff757f"     # red
green="#c3e88d"   # green
yellow="#ffc777"  # yellow
blue="#82aaff"    # blue
magenta="#c099ff" # magenta
cyan="#86e1fc"    # cyan
white="#c8d3f5"   # fg

bright_black="#636da6" # comment

# ── Papéis de interface ───────────────────────────────────────────────────────
accent="#82aaff"     # blue
accent_alt="#c099ff" # magenta
success="#c3e88d"    # green
warning="#ffc777"    # yellow
error="#ff757f"      # red
info="#4fd6be"       # teal
