" Prefixo de conventional commit no resumo, que a sintaxe nativa não separa do
" resto da linha. Espelha o que a query do tree-sitter faz com (prefix (type)),
" (prefix (scope)) e a pontuação, para o buffer sair igual nos dois perfis.
"
" O @NoSpell no tipo é o que tira o aviso de inicial maiúscula: sem ele o
" spellcapcheck trata "chore" como primeira palavra da frase e sublinha.

syn match gitcommitPrefixType  "\%^\w\+\ze\%((\w[^)]*)\)\=!\=:"
    \ contained containedin=gitcommitSummary contains=@NoSpell
    \ nextgroup=gitcommitPrefixPunct
syn match gitcommitPrefixPunct "\%((\w[^)]*)\)\=!\=:"
    \ contained contains=@NoSpell

hi def link gitcommitPrefixType  @keyword
hi def link gitcommitPrefixPunct @punctuation.delimiter
