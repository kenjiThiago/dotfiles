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
cmdline é o `blink.cmp`, e os dois brigariam pelas mesmas teclas.

**No bash e no tmux** não há chave de perfil: cada ferramenta extra vem atrás
de um teste. O `.bashrc` usa o starship se ele existir e cai num `PS1` próprio
se não; o `.tmux.conf` só define `wl-copy` como `copy-command`, só chama o tpm
e só cria o popup de cores se o que eles precisam estiver instalado. Para o
que for de uma máquina só, os dois leem um arquivo não versionado no fim:
`~/.bashrc.local` e `~/.tmux.conf.local`.

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
| sintaxe | `syn_comment` `syn_string` `syn_escape` `syn_constant` `syn_keyword` `syn_operator` `syn_type` `syn_function` `syn_variable` `syn_parameter` `syn_tag` `syn_attribute` |

Mais os metadados: `variant` (dark/light), `nvim_colorscheme`, `zen_theme`,
`wallpaper`, `gtk_theme`, `cursor_theme`, e os estilos de sintaxe
`syn_comment_style`, `syn_keyword_style`, `syn_parameter_style` e
`syn_attribute_style` (valores: `bold`, `italic`, `underline` ou vazio).

O grupo de sintaxe é opcional e existe para o caso de o colorscheme do editor
discordar da paleta. Sem ele, cada `syn_*` cai num default derivado dos papéis
(`syn_keyword` vira `accent_alt`, `syn_string` vira `warning`, e assim por
diante), que é o que três dos quatro temas usam. O `rose-pine-moon` declara o
grupo inteiro porque roda o `gruber-darker` no nvim, que usa as mesmas tintas
do Moon em papéis diferentes: sem isso, o preview do yazi mostraria o mesmo
código com cores trocadas em relação ao buffer ao lado.

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
| tmux | `~/.config/tmux/colors.conf` | `source-file -q` no fim do `.tmux.conf` |
| neovim | `~/.config/nvim/lua/theme.lua` | `require("theme")` em `plugins/colors.lua` |
| btop | `~/.config/btop/themes/dotfiles.theme` | `color_theme = "dotfiles"` no `btop.conf` |
| lazygit | `~/.config/lazygit/colors.yml` | `LG_CONFIG_FILE` junta com o `config.yml` (não tem include) |
| yazi | `~/.config/yazi/theme.toml` | camada de override sobre o tema embutido |
| yazi (preview) | `~/.config/yazi/theme.tmTheme` | `[mgr] syntect_theme` no `theme.toml`, com caminho absoluto |
| zen browser | `<perfil>/chrome/colors.css` e `zen-logo.svg` | `@import` no `userChrome.css` do estilo |

Do hyprland ao zathura, tudo até o starship é marcado como `desktop` na
terceira coluna do `manifest` e não é gerado no perfil servidor. O neovim
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
- **Neovim**: o tema escolhe o *colorscheme* (`nvim_colorscheme`), não as cores
  uma a uma. Se o plugin do colorscheme não estiver instalado, o nvim avisa e
  cai no `habamax`.
- **`~/plugins`**: o pacote `nvim-plugins` linka os plugins locais
  (`gruber-darker`, `present`) em `~/plugins`, que é onde o `colors.lua` os
  procura no `runtimepath`.
- **Tema atual**: fica em `~/.local/state/dotfiles/current-theme`, e o perfil
  da máquina em `~/.local/state/dotfiles/profile`, ao lado.
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
