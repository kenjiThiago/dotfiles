# dotfiles

Configuração de Hyprland + Quickshell + Neovim, organizada em pacotes do
GNU Stow e com um sistema de temas que troca o desktop inteiro de uma vez.

```
dotfiles/
├── install.sh          instalação numa máquina nova
├── packages.txt        pacotes que a configuração precisa
├── packages-extra.txt  apps, toolchains e hardware (só com --extra)
├── packages/           os pacotes do stow (é o -d do stow)
├── profiles/           quais pacotes cada tipo de máquina linka
├── themes/             paletas + templates dos temas
├── zen-themes/         estilos do Zen Browser (CSS; as cores vêm de themes/)
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

### As duas listas de pacotes

`packages.txt` tem só o que algum arquivo do repositório chama de fato — config,
script de `packages/bin`, keybind do Hyprland, módulo do waybar ou tema. É o
suficiente para a configuração funcionar, e é o que o `install.sh` instala por
padrão.

`packages-extra.txt` é o resto do que está instalado na máquina de referência:
apps pessoais, toolchains, bancos e pacotes presos ao hardware (`intel-ucode`,
`nvidia-open-dkms`, `sbctl`). Só entra com `./install.sh --extra`, e vale
revisar antes de rodar em outro computador.

Dependências transitivas não aparecem em nenhuma das duas — o paru resolve. As
duas juntas também não são o `paru -Qeq` literal: o que caiu em desuso foi
tirado de propósito. Para comparar com o que está instalado hoje:

```sh
paru -Qeq    # pacotes explícitos
paru -Qmq    # os que vieram do AUR
```

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
dots link                     # linka tudo
dots link nvim waybar         # linka só alguns
dots link --except nvim       # linka tudo menos alguns
dots unlink waybar
dots relink nvim              # depois de renomear/mover arquivos
dots migrate                  # limpa symlinks quebrados que apontam para o repo
dots adopt btop               # importa para o repo o que já existe em ~
dots link --profile server    # linka a lista de outro perfil
dots link --dry               # simula
```

`--except` aceita lista separada por vírgula (`--except nvim,waybar`) e pode ser
repetido. Vale para `link`, `unlink` e `relink`, e não combina com uma lista de
pacotes — ou você diz quais quer, ou quais não quer. Os nomes são conferidos
contra o `dots list`, então errar a grafia dá erro em vez de linkar tudo
caladamente, e a comparação é de nome inteiro: excluir `nvim` não leva o
`nvim-plugins` junto.

O `install.sh` repassa a mesma flag, para pular configs já na instalação nova:

```sh
./install.sh --except nvim,waybar
```

`dots migrate` existe para quando o stow recusa com *"existing target is not
owned by stow"*: são links de um layout anterior, apontando para caminhos que
não existem mais. Ele só remove symlinks que apontam para dentro deste
repositório **e** já não resolvem — arquivo de verdade, diretório e link para
outro lugar ficam intactos. O `install.sh` roda isso antes de linkar.

`dots adopt` é o caminho inverso do `link`: em vez de instalar a versão do
repositório, ele traz para o repositório a que já está em `~`. Use quando a
config boa é a que está na máquina. Ele exige o repositório limpo e mostra o
diff no fim, porque o `--adopt` do stow **sobrescreve** os arquivos versionados
sem avisar. Se a versão boa é a do repositório, o caminho é o outro: apague o
arquivo de `~` e rode `dots link`.

`dots` sempre usa `--no-folding`. Isso é importante: sem ele o stow criaria
`~/.config/waybar` como um symlink para o repositório, e aí qualquer arquivo
gerado ali dentro sujaria o git. Com `--no-folding`, `~/.config/waybar` é um
diretório de verdade, com symlinks dos arquivos versionados **e** os arquivos
de cor gerados convivendo lado a lado.

## Perfis

O mesmo repositório serve duas máquinas bem diferentes. `desktop` é a de
referência: Arch, Hyprland, zsh, neovim com plugins. `server` é máquina sem
desktop nenhum: bash, tmux, neovim pelado.

```sh
./install.sh --profile server
```

Cada perfil é um arquivo em `profiles/` listando os pacotes do stow que aquela
máquina quer, um por linha. O `server` deixa de fora o Hyprland, o waybar, o
quickshell, o rofi, os emuladores de terminal, o zathura e o zsh.

O perfil escolhido fica em `~/.local/state/dotfiles/profile`, ao lado do
`current-theme`. É de lá que o `dots`, o `theme` e o neovim leem depois, cada
um por conta própria — a variável `DOTFILES_PROFILE` sobrepõe, o que é útil
para testar. Sem o arquivo, todos assumem `desktop`, então uma máquina que
nunca rodou o `install.sh` novo continua se comportando como antes.

O que muda de fato em cada perfil:

| | desktop | server |
|---|---|---|
| pacotes linkados | todos | `profiles/server` |
| pacotes do sistema | `packages.txt` via paru | na mão, com o gerenciador da distro |
| serviços do systemd | habilitados | pulados |
| shell padrão | trocado para zsh | fica como está |
| tpm e plugins do nvim | baixados | nada a baixar |
| templates de tema | os 15 | só os que não precisam de desktop |

**No neovim** o `lua/NeoVim/profile.lua` é a chave: no perfil servidor o
`init.lua` sai cedo, sem tocar em `vim.pack`, e quem assume é o
`lua/NeoVim/server/`. Lá está o que no desktop vem de plugin — LSP nativo de
pyright e ruff, netrw no lugar do oil, `nvim.undotree`, o wildmenu da cmdline
e os keymaps de marca, que fazem as vezes do harpoon. O núcleo (`set.lua`,
`remap.lua`, `autocmd.lua`, `custom/statusline.lua`) é o mesmo arquivo nos dois.

O wildmenu nativo é só do servidor de propósito: no desktop quem completa a
cmdline é o `blink.cmp`, e os dois brigariam pelas mesmas teclas. É por ele que
passa o `:Find` (`<leader>pf`), que faz as vezes do telescope: a lista de
arquivos vem do rg, com cache por cwd, e quem filtra e realça é o próprio nvim,
via `fuzzy` no `wildoptions` ligado só enquanto a cmdline é desse comando.

O neovim do servidor vem do gerenciador da distro, que costuma estar bem atrás
do Arch, então o `server/` testa antes de usar o que é recente. O piso é o
**0.11**, de onde saem o `vim.lsp.config` e o `winborder`; abaixo disso a
config sobe sem LSP. O autocompletar da cmdline (`wildtrigger()`, `pumborder`)
e o `nvim.undotree` são do **0.12** e ficam de fora sozinhos quando não
existem.

**Nos shells e no tmux** não há chave de perfil: cada ferramenta extra vem
atrás de um teste. O `.bashrc` e o `.zshrc` usam o starship se ele existir e
caem num prompt próprio se não, e o mesmo vale para eza, fzf, zoxide e nvm; o
`.tmux.conf` só define `wl-copy` como `copy-command`, só chama o tpm e só cria
o popup de cores se o que eles precisam estiver instalado. Para o que for de
uma máquina só, os três leem um arquivo não versionado no fim: `~/.bashrc.local`,
`~/.zshrc.local` e `~/.tmux.conf.local`.

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

Temas disponíveis: `rose-pine-moon` (padrão), `rose-pine`, `rose-pine-dawn`
(o único claro), `catppuccin-mocha`, `tokyonight-moon`.

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
| sintaxe | `syn_comment` `syn_string` `syn_escape` `syn_constant` `syn_keyword` `syn_operator` `syn_type` `syn_function` `syn_variable` `syn_parameter` `syn_tag` `syn_attribute` |

Mais os metadados: `variant` (dark/light), `nvim_colorscheme`, `zen_theme`,
`wallpaper`, `gtk_theme`, `cursor_theme`, e os estilos de sintaxe
`syn_comment_style`, `syn_keyword_style`, `syn_parameter_style` e
`syn_attribute_style` (valores: `bold`, `italic`, `underline` ou vazio).

O grupo de sintaxe é opcional e existe para o caso de o colorscheme do editor
discordar da paleta. Sem ele, cada `syn_*` cai num default derivado dos papéis
(`syn_keyword` vira `accent_alt`, `syn_string` vira `warning`, e assim por
diante), que é o que os temas de colorscheme externo usam.

Quem declara o grupo inteiro é o `rose-pine-moon` e o `rose-pine-dawn`, os dois
que rodam o `luar`. O `luar` não traz paleta: ele é uma distribuição de papéis
(poucas cores com função, identificador e operador sem tinta, tipo ao lado do
comentário) e lê estes valores pelo `lua/theme.lua` gerado. Então o bloco
`syn_*` não é uma cópia do colorscheme, é a fonte dele, e é o mesmo bloco que
faz o preview do yazi bater com o buffer ao lado. Os dois temas usam a mesma
distribuição, com o dawn trocando duas tintas por medida de contraste (ver os
comentários no `themes/rose-pine-dawn/theme.sh`).

`gtk_theme` e `cursor_theme` são nomes de diretório em `/usr/share/themes`,
`/usr/share/icons`, `~/.local/share/icons` e `~/.themes`. Vazios, o `theme` não
escreve a chave correspondente no gsettings. É o nome do diretório mesmo, e não
o `Name=` do `index.theme`: o do BreezeX tem acento (`BreezeX-RoséPine` contra
`BreezeX-RosePine-Linux`) e a busca do XCursor, que é por diretório, não acha.

Quem manda no cursor é o `XCURSOR_THEME`, por dois caminhos: o `theme set` gera
o `~/.config/uwsm/env-hyprland`, que o uwsm sourceia no login, e roda
`hyprctl setcursor` para a sessão que já está de pé. O
`sync_gsettings_theme = true` do Hyprland vai na direção contrária do que
parece: ele republica o `XCURSOR_THEME` no gsettings, sobrepondo a chave que o
próprio `theme` escreve ali. Por isso o valor precisa sair do tema nos dois
lugares; hardcodado no `uwsm/env` ele vencia o tema em toda troca.

O `color-scheme` do gsettings não depende de nenhum dos dois: sai sempre de
`variant`, porque é o que o `xdg-desktop-portal-gtk` republica como
`org.freedesktop.appearance`, e é daí que o Zen tira o esquema das páginas e os
apps GTK4 tiram o deles. Trocar de tema muda o esquema do Zen na hora, sem
reabrir. O que o Zen não segue sozinho é o esquema do *chrome*: ele tem uma
preferência própria, `browser.theme.toolbar-theme`, e enquanto ela estiver
fixada em claro ou escuro o `light-dark()` do CSS interno vai contra a paleta.
Deixe em Automático (Configurações → Aparência) para o navegador inteiro seguir
o tema.

Os apps GTK e Qt não seguem por gsettings sob Hyprland, que não tem daemon de
XSettings: seguem pelos arquivos, e por isso o `settings.ini` do GTK e o
`qt6ct.conf` são templates como qualquer outro (ver a tabela acima). O `theme`
deriva de `variant` o `gtk-application-prefer-dark-theme` e a base do tema de
ícones do qt6ct.

O `settings.ini` decide só claro contra escuro; a paleta em si vem do `gtk.css`
gerado em cada versão, que é a folha de estilo do usuário e é lida depois do
tema, sobrepondo as cores nomeadas que o Adwaita definiu. São dois arquivos
porque são vocabulários diferentes: o GTK3 usa `theme_bg_color` e companhia, e
o libadwaita usa `window_bg_color`, `view_bg_color`, `headerbar_bg_color`, que
desde a versão 1.6 são variáveis CSS com os `@define-color` de mesmo nome
sobrando como compatibilidade. O arquivo do GTK4 traz os três vocabulários, o
terceiro sendo os `theme_*` do Adwaita embutido, para o app GTK4 que não usa
libadwaita.

O alcance dos dois é muito diferente, e é por isso que o arquivo do GTK3 é
bem maior que a lista de `@define-color` sugere. Medindo os dois stylesheets
que vêm compilados nas bibliotecas:

| | literais de cor | `var(--)` e `@nomeada` | responde a override |
| --- | --- | --- | --- |
| Adwaita do GTK3 | 1247 | 39 | 3% |
| libadwaita 1.9 | 411 | 1130 | 73% |

Ou seja, no GTK3 o `@define-color` sozinho não muda nada visível: o Adwaita
resolveu as cores para hex na hora de compilar. Por isso o `gtk3-colors.css.in`
traz, além dos `@define-color`, um bloco de regras reais para as superfícies que
dominam a tela: janela, barra de título, botão, campo, lista, popover, aba,
barra de rolagem e seleção. Como a folha do usuário tem prioridade maior que a
do tema, essas regras vencem os literais. O que elas não alcançarem continua no
cinza do Adwaita.

No libadwaita não é preciso nada disso para as superfícies: ele ignora o
`gtk-theme-name` e as variáveis são tudo que ele tem. As exceções são a dica de
contexto, fixada em preto 80% com texto branco, e o link, derivado do
`--accent-color`; as duas viram regra explícita nos dois arquivos, para
acompanharem o `ToolTipBase` e o `Link` do Qt.

Os papéis são os mesmos do `qt6ct-colors.conf.in`, para os dois toolkits caírem
na mesma cor: `surface` na janela, `base` no conteúdo, `overlay` no que precisa
se destacar da janela sem virar conteúdo.

### Ícones do Qt

Os ícones do Breeze são SVG de um traço só, com `fill:currentColor` e um bloco
`.ColorScheme-* { color: ... }` embutido. No Plasma quem reescreve esse bloco
conforme o esquema ativo é o `KIconThemes`; sob o qt6ct esse motor não existe,
então cada ícone sai na cor gravada no arquivo. Na prática: botão de diálogo
todo branco, e o que for de destaque no azul do KDE, seja qual for a paleta.

O `apply_icons` do `theme` gera então um tema em
`~/.local/share/icons/dotfiles/`, apontado pelo `icon_theme` do qt6ct, que
herda o Breeze da variante (`breeze-dark` ou `breeze`) e reescreve esse bloco.
Só a lista `ICON_RECOLOR` é recolorida, e não o tema inteiro: o Breeze tem
19844 SVG e 41M, e copiar tudo a cada `theme set` custaria caro para pintar
ícone que ninguém olha. O que ficar de fora resolve no tema herdado, com as
cores originais.

A substituição é por nome de classe, não por valor: o Breeze usa cinco azuis
diferentes de `Accent`, então casar pelo hex erraria. Nos ícones de `status`,
que são crachá de disco mais glifo vazado, o glifo também é trocado, por `base`:
branco sobre o dourado do `warning` ficaria ilegível.

Como o destino é um diretório de vários arquivos com os tamanhos descobertos em
tempo de execução, isso não cabe no `manifest`; fica no `theme`, como o
`apply_zen`.

Os ícones do GTK seguem fora disso, em `AdwaitaLegacy`: são um conjunto
próprio, já coerente entre si, e não saem da paleta.

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
| tmux | `~/.config/tmux/colors.conf` | `source-file -q` no fim do `.tmux.conf` |
| tmux (perfil server) | `~/.config/tmux/server-colors.conf` | `source-file -q` no fim do `server.conf` |
| neovim | `~/.config/nvim/lua/theme.lua` | `require("theme")` em `plugins/colors.lua` |
| btop | `~/.config/btop/themes/dotfiles.theme` | `color_theme = "dotfiles"` no `btop.conf` |
| lazygit | `~/.config/lazygit/colors.yml` | `LG_CONFIG_FILE` junta com o `config.yml` (não tem include) |
| yazi | `~/.config/yazi/theme.toml` | camada de override sobre o tema embutido |
| yazi (preview) | `~/.config/yazi/theme.tmTheme` | `[mgr] syntect_theme` no `theme.toml`, com caminho absoluto |
| zen browser | `<perfil>/chrome/colors.css` e `zen-logo.svg` | `@import` no `userChrome.css` do estilo |
| gtk | `~/.config/gtk-3.0/settings.ini` e `gtk-4.0/settings.ini` | arquivo inteiro (o GTK não tem include) |
| gtk3 (cores) | `~/.config/gtk-3.0/gtk.css` | folha do usuário, sobrepõe os `@define-color` do tema |
| gtk4 (cores) | `~/.config/gtk-4.0/gtk.css` | idem, no vocabulário do libadwaita |
| qt | `~/.config/qt6ct/qt6ct.conf` e `qt6ct/colors/dotfiles.conf` | `custom_palette` + `color_scheme_path` |
| cursor | `~/.config/uwsm/env-hyprland` | `XCURSOR_THEME` sourceado pelo uwsm no login |

Do hyprland ao zathura, e mais o gtk, o qt e o cursor, tudo é marcado como
`desktop` na terceira coluna do `manifest` e não é gerado no perfil servidor. O
`server-colors.conf` é o inverso: só sai no perfil servidor. O neovim
consome o `theme.lua` por dois caminhos: `plugins/colors.lua` no desktop e
`lua/NeoVim/server/init.lua` no servidor, que aplica o colorscheme sem plugin.

O Zen é o único que não passa pelo `manifest`: o diretório do perfil tem nome
sorteado, então quem escolhe o destino é o `apply_zen` do `theme`.

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
2. Adicione a linha correspondente no `themes/templates/manifest`. A terceira
   coluna é opcional: liste os perfis em que ela vale (`desktop`), ou deixe
   vazia para valer em todos.
3. Faça a config do programa incluir o arquivo gerado.
4. `theme reload`.

## Detalhes

- **Zen Browser**: `zen_theme` escolhe só o *estilo* (`default` ou `nebula`), que
  é CSS escrito à mão; as cores saem do `theme.sh` como em qualquer outro
  programa. `theme set` aponta `~/.zen/<perfil>/chrome/{themes,userChrome.css,
  userContent.css}` para `zen-themes/<zen_theme>/` e escreve `colors.css` e
  `zen-logo.svg` no mesmo diretório. O perfil vem do `Default=` da seção
  `[Install...]` do `profiles.ini`, que é o que o navegador abre de fato.
  Precisa reiniciar o navegador.
- **quickshell e o systray**: os ícones da barra são glifos de Nerd Font e
  trocam de cor na recarga, como o resto. Os do systray e os das notificações
  não: são imagens resolvidas pelo tema de ícones do Qt, que o Qt fixa uma vez,
  quando a `QGuiApplication` nasce. Nem o hot reload do quickshell nem o
  observador de arquivo do qt6ct refazem essa resolução. O nome do tema não
  muda mais entre temas, mas o conteúdo dele sim, porque os ícones passaram a
  ser recoloridos pela paleta, então o `theme set` avisa em toda troca.
- **Neovim**: o tema escolhe o *colorscheme* (`nvim_colorscheme`), não as cores
  uma a uma. Se o plugin do colorscheme não estiver instalado, o nvim avisa e
  cai no `habamax`.
- **`~/plugins`**: o pacote `nvim-plugins` linka os plugins locais
  (`luar`, `present`) em `~/plugins`, que é onde o `colors.lua` os
  procura no `runtimepath`.
- **Tema atual**: fica em `~/.local/state/dotfiles/current-theme`, e o perfil
  da máquina em `~/.local/state/dotfiles/profile`, ao lado.
- **Wallpaper**: cada tema declara o seu, e o `rofi-script wallpaper` troca só
  a imagem, sem trocar de tema. A primeira entrada da lista é "Sem wallpaper",
  que encerra o hyprpaper e deixa à mostra o `misc:background_color` do
  Hyprland, no `base` do tema. É assim porque o hyprpaper 0.8 perdeu o IPC de
  `unload`: não há como pedir que ele apague o fundo sem sair. A escolha fica
  em `~/.local/state/dotfiles/no-wallpaper`, o marcador que faz o
  `autostart.lua` não subir o hyprpaper e o `theme set` gerar o path vazio, no
  hyprpaper.conf e no `$wallpaper` que o hyprlock usa. Escolher uma imagem
  apaga o marcador e sobe o hyprpaper de volta. Transição animada na troca não
  existe: o hyprpaper não tem nada disso, e quem tem é o `swww`.
- **tmux-sessionizer**: a lista vem do zoxide (tudo que você já visitou, por
  frecência) mais as raízes de `~/.config/tmux-sessionizer/paths`. Projeto
  clonado fora das raízes aparece depois do primeiro `cd`. Os diretórios de
  `~/.config` que vêm de um pacote são excluídos automaticamente — lá são só
  symlinks, e uma sessão ali não fica dentro do repositório; o alvo certo é
  `~/dotfiles/packages/<pkg>`. O que não é do repositório continua aparecendo.
  Linha começando com `-` no arquivo de paths exclui à mão.
- **tmux — cores**: mesma divisão do lazygit. O `.tmux.conf` versionado tem só
  comportamento, e as cores vêm de `~/.config/tmux/colors.conf`, gerado pelo
  `theme set`. Aqui o tmux tem include de verdade, então basta o
  `source-file -q` no fim do arquivo; o `-q` é o que deixa o tmux subir antes
  do primeiro `theme set`, quando o arquivo ainda não existe, só com as cores
  padrão. Sessão já aberta não pega o tema novo sozinha: `prefix + r`.
- **lazygit — cores**: o `config.yml` versionado tem só comportamento; o tema
  sai do `theme set` em `~/.config/lazygit/colors.yml`. Como o lazygit não tem
  include, quem junta os dois é o `LG_CONFIG_FILE`, definido em três lugares: no
  `.zshrc`, para quando você roda `lazygit` na mão, e no `tmux-lazygit`, porque
  a sessão do popup não herda o ambiente do seu shell. Sem a variável o lazygit
  ainda sobe — só sem tema. Antes do primeiro `theme set` o `colors.yml` não
  existe, e os dois lugares checam isso antes de montar a lista (arquivo
  faltando na lista impede o lazygit de iniciar).
- **lazygit — onde ele roda**: sempre no popup do tmux, sobre a sessão
  `scratch-lg`, por `prefix+g` no terminal ou `<leader>gs` de dentro do nvim.
  Os dois chamam o mesmo `tmux-lazygit`. A sessão é o ponto: ela sobrevive ao
  fechar do popup, então o lazygit volta com o mesmo scroll e o mesmo estado.
  Em troca, só a primeira abertura define o diretório; depois disso o popup
  apenas reata, mesmo que você tenha trocado de projeto.
- **lazygit — editar**: `os.editPreset: nvim` no `config.yml`. O arquivo abre
  dentro do próprio popup, tomando a tela do lazygit (`editInTerminal: true`
  vem junto do preset), e devolve para ele ao fechar o nvim. Sem RPC, sem
  socket, sem escapar para outro pane.
- **yazi** (`<leader>pf`): mesma ideia, float nativo com `--chooser-file`. O
  `<C-v>`, `<C-x>` e `<C-t>` escolhem split, split horizontal ou aba. O
  `--chooser-file` desliga os openers do yazi, então imagem e PDF voltariam como
  binário para um buffer; o float checa o mime antes e manda imagem, vídeo,
  áudio, PDF e epub para o `xdg-open`. O `gx` faz o mesmo por tecla, sem fechar
  o yazi, igual ao `gx` do oil. Preview de
  imagem não funciona dentro do float, e isso não tem conserto pela config: o
  terminal embutido do nvim é libvterm puro, sem kitty nem sixel, então o yazi
  não tem como desenhar. Preview de texto funciona normal. Para imagem, use o
  `y()` no shell, que roda no ghostty e mostra em resolução real.
- **btop**: ele reescreve o `btop.conf` ao sair quando você muda alguma opção,
  e como o arquivo é um symlink, isso suja o repositório. Rode `git status`
  depois de mexer nas configurações dele.
- **Clipboard** (`SUPER+Y`, ou Setup → Clipboard): `Enter` copia, `alt+p` fixa
  ou solta, `alt+d` apaga a entrada, `alt+w` limpa o histórico. Os fixados vão
  para `~/.local/share/clipboard-pins`, um arquivo por entrada, e sobrevivem ao
  `alt+w` — o cliphist não tem pin, isso é do `rofi-script`. Fixar e apagar
  reabrem o menu, para você encadear várias ações; só copiar ou cancelar fecham.
- **Git**: o pacote `git` versiona `~/.config/git/config`. Sua identidade fica
  fora do repositório, em `~/.config/git/config.local` (o include é ignorado se
  o arquivo não existir). Atenção: o git lê `~/.gitconfig` **depois** do arquivo
  XDG, então um `~/.gitconfig` antigo sobrescreve o que está aqui — mova o que
  quiser manter para o `config.local` e apague o resto.
