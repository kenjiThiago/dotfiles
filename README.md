# dotfiles

Configuração de Hyprland + Quickshell + Neovim, organizada em pacotes do
GNU Stow e com um sistema de temas que troca o desktop inteiro de uma vez.

```
dotfiles/
├── install.sh          instalação numa máquina nova
├── packages.txt        lista de pacotes do sistema
├── packages/           os pacotes do stow (é o -d do stow)
├── themes/             paletas + templates dos temas
├── zen-themes/         temas do Zen Browser (CSS, não gerado)
└── wallpapers/
```

## Instalação

```sh
git clone <repo> ~/dotfiles
cd ~/dotfiles
./install.sh              # ou ./install.sh --dry para só ver o que faria
```

O que ele faz, em ordem: instala os pacotes de `packages.txt` com o paru
(compilando o paru antes, se preciso), limpa symlinks de um layout antigo,
linka os pacotes em `~`, aplica o tema, habilita `NetworkManager` e
`power-profiles-daemon`, roda o `xdg-user-dirs-update`, troca seu shell para
zsh e baixa os plugins do tmux e do neovim.

Cada etapa é pulável — `--skip-packages`, `--skip-services`, `--skip-plugins`
— e tudo é idempotente: rodar de novo não quebra nada.

Sobra só o que não dá para automatizar: reiniciar a sessão do Hyprland e abrir
o Zen Browser uma vez (o perfil só existe depois disso) e rodar `theme set` de
novo para criar os symlinks de CSS dentro dele.

## Stow

Cada diretório dentro de `packages/` é um pacote independente, com a estrutura
que ele terá dentro de `~`:

```
packages/waybar/.config/waybar/style.css   ->   ~/.config/waybar/style.css
packages/zsh/.zshrc                        ->   ~/.zshrc
packages/bin/.local/bin/theme              ->   ~/.local/bin/theme
```

O wrapper `dots` cuida do stow:

```sh
dots list                # pacotes disponíveis
dots status              # o que está linkado
dots link                # linka tudo
dots link nvim waybar    # linka só alguns
dots unlink waybar
dots relink nvim         # depois de renomear/mover arquivos
dots migrate             # limpa symlinks quebrados que apontam para o repo
dots link --dry          # simula
```

`dots migrate` existe para quando o stow recusa com *"existing target is not
owned by stow"*: são links de um layout anterior, apontando para caminhos que
não existem mais. Ele só remove symlinks que apontam para dentro deste
repositório **e** já não resolvem — arquivo de verdade, diretório e link para
outro lugar ficam intactos. O `install.sh` roda isso antes de linkar.

`dots` sempre usa `--no-folding`. Isso é importante: sem ele o stow criaria
`~/.config/waybar` como um symlink para o repositório, e aí qualquer arquivo
gerado ali dentro sujaria o git. Com `--no-folding`, `~/.config/waybar` é um
diretório de verdade, com symlinks dos arquivos versionados **e** os arquivos
de cor gerados convivendo lado a lado.

## Temas

```sh
theme                    # seletor (rofi no Hyprland, fzf no terminal)
theme list
theme current
theme set rose-pine-moon
theme show               # imprime a paleta ativa com as cores no terminal
theme reload             # reaplica o tema atual (depois de editar templates)
```

Também está no menu do `rofi-script` em **Setup → Tema**.

Temas disponíveis: `rose-pine-moon` (padrão), `rose-pine`, `catppuccin-mocha`,
`tokyonight-moon`.

### Como funciona

```
themes/<tema>/theme.sh        a paleta, em nomes genéricos
        +
themes/templates/*.in         um template por programa
        =
~/.config/<programa>/colors   arquivos gerados, fora do git
```

O `theme set` lê a paleta, roda cada template do `themes/templates/manifest` e
escreve o resultado direto em `~`. Nada gerado entra no repositório.

### A paleta

Todo tema define as mesmas chaves, para que um template sirva para qualquer
tema. Os nomes são genéricos de propósito — o "yellow" do Rosé Pine é o gold, o
"cyan" é o rose:

| grupo | chaves |
| --- | --- |
| fundo | `base` `surface` `overlay` `term_bg` (só o alacritty; os outros usam `base`) |
| realces | `highlight_low` `highlight_med` `highlight_high` |
| texto | `text` `subtle` `muted` |
| ANSI | `black` `red` `green` `yellow` `blue` `magenta` `cyan` `white` (+ `bright_*`, que caem no normal se não forem definidos) |
| papéis | `accent` `accent_alt` `success` `warning` `error` `info` |

Mais os metadados: `variant` (dark/light), `nvim_colorscheme`, `zen_theme`,
`wallpaper`, `gtk_theme`, `cursor_theme`.

`gtk_theme` e `cursor_theme` vêm vazios: assim o `theme` não escreve no
gsettings e não sobrepõe o que você escolheu à mão. Preencha se quiser que a
troca de tema leve o GTK e o cursor junto — os nomes válidos são os diretórios
em `/usr/share/icons`, `~/.local/share/icons` e `~/.themes`. O Hyprland lê o
cursor do gsettings por causa do `sync_gsettings_theme = true`.

Nos templates, cada chave tem quatro formas:

| placeholder | resultado |
| --- | --- |
| `{{base}}` | `#232136` |
| `{{base:hex}}` | `232136` |
| `{{base:rgb}}` | `rgb(232136)` |
| `{{base:argb}}` | `0xff232136` |

### O que cada programa recebe

| programa | arquivo gerado | como consome |
| --- | --- | --- |
| hyprland | `~/.config/hypr/conf/colors.lua` | `require("conf.colors")` em `appearance.lua` |
| hyprlock | `~/.config/hypr/conf/colors.conf` | `source =` no topo do `hyprlock.conf` |
| hyprpaper | `~/.config/hypr/hyprpaper.conf` | arquivo inteiro (vem do `wallpaper=` do tema) |
| waybar | `~/.config/waybar/colors.css` | `@import` no `style.css` |
| rofi | `~/.config/rofi/themes/colors.rasi` | `@import` no `center.rasi` |
| quickshell | `~/.config/quickshell/modules/Theme.qml` | singleton `Theme` |
| alacritty | `~/.config/alacritty/colors.toml` | `general.import` |
| ghostty | `~/.config/ghostty/colors` | `config-file = colors` |
| zathura | `~/.config/zathura/colors` | `include "colors"` |
| starship | `~/.config/starship.toml` | arquivo inteiro (starship não tem include) |
| neovim | `~/.config/nvim/lua/theme.lua` | `require("theme")` em `plugins/colors.lua` |
| zen browser | — | symlinks para `zen-themes/<zen_theme>/` |

### Criando um tema novo

```sh
cp -r themes/rose-pine-moon themes/meu-tema
$EDITOR themes/meu-tema/theme.sh
theme set meu-tema
```

O `theme` valida na hora: reclama se faltar alguma cor ou se algum valor não
for um `#rrggbb`.

### Mexendo em um programa que ainda não é temático

1. Escreva `themes/templates/<programa>.in` usando os placeholders.
2. Adicione a linha correspondente no `themes/templates/manifest`.
3. Faça a config do programa incluir o arquivo gerado.
4. `theme reload`.

## Detalhes

- **Zen Browser**: os temas são CSS escrito à mão, não gerado. `theme set`
  aponta `~/.zen/<perfil>/chrome/{themes,userChrome.css,userContent.css}` para
  `zen-themes/<zen_theme>/`. Precisa reiniciar o navegador.
- **Neovim**: o tema escolhe o *colorscheme* (`nvim_colorscheme`), não as cores
  uma a uma. Se o plugin do colorscheme não estiver instalado, o nvim avisa e
  cai no `habamax`.
- **`~/plugins`**: o pacote `nvim-plugins` linka os plugins locais
  (`gruber-darker`, `present`) em `~/plugins`, que é onde o `colors.lua` os
  procura no `runtimepath`.
- **Tema atual**: fica em `~/.local/state/dotfiles/current-theme`.
- **Clipboard** (`SUPER+Y`, ou Setup → Clipboard): `Enter` copia, `alt+p` fixa
  ou solta, `alt+d` apaga a entrada, `alt+w` limpa o histórico. Os fixados vão
  para `~/.local/share/clipboard-pins`, um arquivo por entrada, e sobrevivem ao
  `alt+w` — o cliphist não tem pin, isso é do `rofi-script`.
- **Git**: o pacote `git` versiona `~/.config/git/config`. Sua identidade fica
  fora do repositório, em `~/.config/git/config.local` (o include é ignorado se
  o arquivo não existir). Atenção: o git lê `~/.gitconfig` **depois** do arquivo
  XDG, então um `~/.gitconfig` antigo sobrescreve o que está aqui — mova o que
  quiser manter para o `config.local` e apague o resto.
