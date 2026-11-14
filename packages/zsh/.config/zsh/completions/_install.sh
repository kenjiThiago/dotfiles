#compdef install.sh

_arguments \
    '(--dry --dry-run)'{--dry,--dry-run}'[Simula sem alterar arquivos]' \
    '--extra[Inclui packages-extra.txt]' \
    '*--except=[Exclui pacotes do Stow]:pacotes:_sequence _dotfiles packages' \
    '--profile=[Escolhe o perfil da máquina]:perfil:{_dotfiles profiles}' \
    '--theme[Escolhe o tema inicial]:tema:{_dotfiles themes}' \
    '--skip-packages[Pula a instalação de pacotes]' \
    '--skip-services[Pula a habilitação de serviços]' \
    '--skip-plugins[Pula o download de plugins do Neovim]' \
    '(-h --help)'{-h,--help}'[Mostra a ajuda]'
