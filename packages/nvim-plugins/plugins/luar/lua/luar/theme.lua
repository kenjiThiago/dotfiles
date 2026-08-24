-- lua/luar/theme.lua
--
-- Colorscheme próprio. A distribuição de papéis vem do gruber-darker: poucas
-- cores com função, Identifier e Operator sem tinta, Type ao lado do
-- comentário. As tintas vêm do tema ativo, pelo lua/theme.lua, então isto
-- funciona sobre qualquer paleta que declare os papéis `syn_*`. Não é derivado
-- de nenhum dos dois, e não há upstream de onde atualizar.
local luar = require("luar.palette")
local palette = luar.colors

local M = {}

function M.setup()
    vim.cmd("hi clear")
    if vim.fn.exists("syntax_on") then
        vim.cmd("syntax reset")
    end
    vim.o.termguicolors = true
    vim.g.colors_name = "luar"

    -- Os papéis que o theme.sh pode estilizar (bold/italic) vêm de lá; os
    -- demais grupos trazem o atributo escrito.
    local function styled(color, role)
        local hl = luar.style(role)
        hl.fg = color
        return hl
    end

    local groups = {
        -- ==========================================
        -- UI do Editor
        -- ==========================================
        Normal = { fg = palette.text, bg = palette.base },
        NormalFloat = { fg = palette.text, bg = palette.surface },
        NormalNC = { fg = palette.text, bg = palette.base },
        ColorColumn = { bg = palette.surface },
        Conceal = { fg = palette.comment },
        Cursor = { fg = palette.black, bg = palette.keyword },
        CursorLine = { bg = palette.surface },
        CursorColumn = { bg = palette.surface },
        CursorLineNr = { fg = palette.keyword, bold = true },
        LineNr = { fg = palette.highlight_high },
        SignColumn = { bg = palette.base },
        Directory = { fg = palette.func, bold = true },
        ErrorMsg = { fg = palette.error, bold = true },
        WarningMsg = { fg = palette.warning, bold = true },
        MoreMsg = { fg = palette.func, bold = true },
        OkMsg = { fg = palette.success },
        ModeMsg = { fg = palette.keyword, bold = true },
        MatchParen = { fg = palette.keyword, bg = palette.overlay, bold = true },
        NonText = { fg = palette.overlay },
        Whitespace = { fg = palette.overlay },
        SpecialKey = { fg = palette.success },
        WildMenu = { fg = palette.black, bg = palette.keyword },
        Search = { fg = palette.base, bg = palette.string },
        IncSearch = { fg = palette.base, bg = palette.keyword },
        CurSearch = { link = "IncSearch" },
        Substitute = { link = "IncSearch" },
        Question = { fg = palette.success },
        Title = { fg = palette.func, bold = true },
        VertSplit = { fg = palette.overlay },
        WinSeparator = { fg = palette.overlay },
        Visual = { bg = palette.highlight_med },
        Folded = { fg = palette.comment, bg = palette.surface },
        FoldColumn = { fg = palette.comment, bg = palette.base },
        StatusLine = { fg = palette.text, bg = palette.overlay },
        StatusLineNC = { fg = palette.comment, bg = palette.surface },
        WinBar = { fg = palette.text, bg = palette.surface, bold = true },
        WinBarNC = { fg = palette.comment, bg = palette.surface },
        QuickFixLine = { bg = palette.overlay },
        TabLine = { fg = palette.comment, bg = palette.surface },
        TabLineFill = { bg = palette.base },
        TabLineSel = { fg = palette.keyword, bg = palette.base, bold = true },
        FloatBorder = { fg = palette.highlight_med, bg = palette.surface },
        FloatTitle = { fg = palette.keyword, bg = palette.surface, bold = true },
        YankHighlight = { fg = palette.base, bg = palette.keyword },

        -- Spell Checking Nativo
        SpellBad = { sp = palette.error, undercurl = true },
        SpellCap = { sp = palette.warning, undercurl = true },
        SpellLocal = { sp = palette.func, undercurl = true },
        SpellRare = { sp = palette.constant, undercurl = true },

        -- Diff Nativo
        DiffAdd = { fg = palette.success, bg = palette.overlay },
        DiffChange = { fg = palette.warning, bg = palette.overlay },
        DiffDelete = { fg = palette.error, bg = palette.overlay },
        DiffText = { fg = palette.func, bg = palette.highlight_med },
        -- Trecho acrescentado dentro de uma linha alterada, sem correspondente
        -- do outro lado. O padrão liga ao DiffText e os dois somem um no outro;
        -- a cor vem do DiffAdd, porque o papel é o mesmo em escala de trecho.
        -- Passou a aparecer sozinho: o 'diffopt' do 0.12 já traz inline:char.
        DiffTextAdd = { fg = palette.success, bg = palette.highlight_med },

        -- O syntax/diff.vim liga diffAdded, diffChanged e diffRemoved a estes
        -- três, e é ele que pinta buffers de patch e o commit --verbose. Sem
        -- defini-los sobra o padrão do nvim, em pasteis fora da paleta.
        Added = { fg = palette.success },
        Changed = { fg = palette.warning },
        Removed = { fg = palette.error },

        TrailingWhitespace = { bg = palette.keyword },

        -- ==========================================
        -- Sintaxe Nativa (Prioridade)
        -- ==========================================
        Comment = styled(palette.comment, "comment"),
        -- Ponto de queda de meia sintaxe legada (gitcommitFile, diffOnly,
        -- gitconfigDelim...). Sem tree-sitter é ele que responde, então não
        -- pode ficar no padrão do nvim.
        Constant = { fg = palette.constant },
        String = { fg = palette.string },
        Character = { fg = palette.string },
        Number = { fg = palette.constant },
        Boolean = styled(palette.keyword, "keyword"),
        Float = { fg = palette.constant },
        Identifier = { fg = palette.variable },
        Function = { fg = palette.func },
        Statement = styled(palette.keyword, "keyword"),
        Conditional = styled(palette.keyword, "keyword"),
        Repeat = styled(palette.keyword, "keyword"),
        Label = { fg = palette.constant },
        Operator = { fg = palette.operator },
        Keyword = styled(palette.keyword, "keyword"),
        Exception = { fg = palette.error, bold = true },
        PreProc = { fg = palette.type },
        Include = styled(palette.keyword, "keyword"),
        Define = styled(palette.keyword, "keyword"),
        Macro = { fg = palette.func },
        Type = { fg = palette.type },
        StorageClass = { fg = palette.keyword },
        Structure = { fg = palette.keyword },
        Typedef = { fg = palette.type },
        Special = { fg = palette.text },
        SpecialChar = { fg = palette.constant },
        SpecialComment = styled(palette.comment, "comment"),
        Delimiter = { fg = palette.text },
        Underlined = { underline = true },
        Error = { fg = palette.error, bold = true },
        Todo = { fg = palette.base, bg = palette.keyword, bold = true },

        -- Sintaxe Nativa Específica: HTML
        htmlTag = { fg = palette.constant },
        htmlEndTag = { fg = palette.constant },
        htmlTagName = { fg = palette.keyword },
        htmlArg = { fg = palette.func },

        -- O markdown legado liga markdownH1..H6 aqui, e o padrão manda os seis
        -- para Title, o que achata a hierarquia. Mesmas cores do @markup.heading.
        htmlH1 = { fg = palette.keyword, bold = true },
        htmlH2 = { fg = palette.func, bold = true },
        htmlH3 = { fg = palette.constant, bold = true },
        htmlH4 = { fg = palette.string, bold = true },
        htmlH5 = { fg = palette.success, bold = true },
        htmlH6 = { fg = palette.comment, bold = true },

        -- Sintaxe Nativa Específica: Markdown
        markdownHeadingDelimiter = { fg = palette.comment },
        markdownRule = { fg = palette.comment, bold = true },
        markdownCode = { fg = palette.string },
        markdownCodeBlock = { fg = palette.string },
        markdownCodeDelimiter = { fg = palette.comment },
        markdownLinkText = { fg = palette.func, underline = true },

        -- Sintaxe Nativa Específica: YAML
        yamlKey = { fg = palette.constant, bold = true },
        yamlBlockMappingKey = { fg = palette.constant, bold = true },
        yamlString = { link = "String" },
        yamlNumber = { link = "Number" },
        yamlConstant = { link = "Constant" },
        yamlIndicator = { fg = palette.func },
        yamlNodeTag = { fg = palette.keyword },
        yamlAlias = { fg = palette.success },
        yamlDocumentStart = { fg = palette.comment, bold = true },
        yamlDocumentEnd = { fg = palette.comment, bold = true },

        -- Sintaxe Nativa Específica: OWL / XML (Web Ontology Language / RDF)
        xmlTag = { fg = palette.constant },
        xmlEndTag = { fg = palette.constant },
        xmlTagName = { fg = palette.keyword },
        xmlAttrib = { fg = palette.func },
        xmlString = { link = "String" },
        xmlEqual = { fg = palette.text },
        owlOntology = { fg = palette.comment, bold = true },
        owlClass = { fg = palette.constant },
        owlProperty = { fg = palette.func },
        owlRestriction = { fg = palette.keyword },

        -- Sintaxe Nativa Específica: CSV / Rainbow
        csvCol0 = { fg = palette.text },
        csvCol1 = { fg = palette.keyword },
        csvCol2 = { fg = palette.func },
        csvCol3 = { fg = palette.success },
        csvCol4 = { fg = palette.constant },
        csvCol5 = { fg = palette.string },
        csvCol6 = { fg = palette.comment },
        csvCol7 = { fg = palette.success },
        csvCol8 = { fg = palette.constant },

        RainbowCol1 = { link = "csvCol1" },
        RainbowCol2 = { link = "csvCol2" },
        RainbowCol3 = { link = "csvCol3" },
        RainbowCol4 = { link = "csvCol4" },
        RainbowCol5 = { link = "csvCol5" },
        RainbowCol6 = { link = "csvCol6" },
        RainbowCol7 = { link = "csvCol7" },
        RainbowCol8 = { link = "csvCol8" },
        RainbowCol9 = { link = "csvCol9" },

        rainbow1 = { link = "csvCol1" },
        rainbow2 = { link = "csvCol2" },
        rainbow3 = { link = "csvCol3" },
        rainbow4 = { link = "csvCol4" },
        rainbow5 = { link = "csvCol5" },
        rainbow6 = { link = "csvCol6" },
        rainbow7 = { link = "csvCol7" },
        rainbow8 = { link = "csvCol8" },
        rainbow9 = { link = "csvCol9" },

        -- ==========================================
        -- Tree-Sitter
        -- ==========================================
        ["@variable"] = { fg = palette.variable },
        ["@variable.builtin"] = { fg = palette.variable },
        ["@variable.parameter"] = styled(palette.parameter, "parameter"),
        ["@variable.member"] = { fg = palette.variable },
        ["@property"] = { fg = palette.variable },
        ["@constant"] = { fg = palette.text },
        ["@constant.builtin"] = { fg = palette.constant },
        ["@constant.macro"] = { link = "Macro" },
        ["@module"] = { fg = palette.text },
        ["@label"] = { link = "Label" },
        ["@string"] = { link = "String" },
        ["@string.regexp"] = { fg = palette.string },
        ["@string.escape"] = { fg = palette.constant },
        ["@character"] = { link = "Character" },
        ["@boolean"] = { link = "Boolean" },
        ["@number"] = { link = "Number" },
        ["@float"] = { link = "Float" },
        ["@type"] = { link = "Type" },
        ["@type.builtin"] = { link = "Type" },
        ["@attribute"] = styled(palette.attribute, "attribute"),
        ["@function"] = { link = "Function" },
        ["@function.builtin"] = { fg = palette.func },
        ["@function.macro"] = { fg = palette.func },
        ["@function.call"] = { fg = palette.func },
        ["@function.method"] = { link = "Function" },
        ["@function.method.call"] = { fg = palette.func },
        ["@constructor"] = { fg = palette.type },
        ["@operator"] = { fg = palette.operator },
        ["@keyword"] = { link = "Keyword" },
        ["@keyword.operator"] = styled(palette.keyword, "keyword"),
        ["@keyword.import"] = { link = "Include" },
        ["@keyword.return"] = styled(palette.keyword, "keyword"),
        ["@keyword.function"] = styled(palette.keyword, "keyword"),
        ["@punctuation.delimiter"] = { fg = palette.text },
        ["@punctuation.bracket"] = { fg = palette.text },
        ["@punctuation.special"] = { fg = palette.text },
        ["@comment"] = { link = "Comment" },
        ["@comment.documentation"] = { link = "Comment" },
        ["@comment.todo"] = { link = "Todo" },
        ["@property.yaml"] = { link = "@property" },

        -- Tree-Sitter: Tags (Usado por XML, HTML, e formatos OWL baseados em RDF)
        ["@tag"] = { fg = palette.tag },
        ["@tag.builtin"] = { fg = palette.tag },
        ["@tag.attribute"] = styled(palette.attribute, "attribute"),
        ["@tag.delimiter"] = { fg = palette.constant },

        ["@markup.heading.1"] = { fg = palette.keyword, bold = true },
        ["@markup.heading.2"] = { fg = palette.func, bold = true },
        ["@markup.heading.3"] = { fg = palette.constant, bold = true },
        ["@markup.heading.4"] = { fg = palette.string, bold = true },
        ["@markup.heading.5"] = { fg = palette.success, bold = true },
        ["@markup.heading.6"] = { fg = palette.comment, bold = true },

        ["@markup.heading.1.marker"] = { fg = palette.keyword, bold = true },
        ["@markup.heading.2.marker"] = { fg = palette.func, bold = true },
        ["@markup.heading.3.marker"] = { fg = palette.constant, bold = true },
        ["@markup.heading.4.marker"] = { fg = palette.string, bold = true },
        ["@markup.heading.5.marker"] = { fg = palette.success, bold = true },
        ["@markup.heading.6.marker"] = { fg = palette.comment, bold = true },

        -- Fora dos títulos o padrão do @markup é só atributo, sem cor, então o
        -- mesmo markdown sai mais chapado com tree-sitter do que sem. Este
        -- bloco é o espelho do markdown da sintaxe nativa, acima.
        ["@markup.raw"] = { fg = palette.string },
        ["@markup.raw.block"] = { fg = palette.string },
        ["@markup.quote"] = { fg = palette.comment },
        ["@markup.list"] = { fg = palette.keyword },
        ["@markup.link"] = { fg = palette.func, underline = true },
        ["@markup.link.label"] = { fg = palette.func, underline = true },
        ["@markup.link.url"] = { fg = palette.constant, underline = true },
        ["@string.special.url"] = { fg = palette.constant, underline = true },

        -- ==========================================
        -- Plugins
        -- ==========================================
        -- Markdown Plugins
        RenderMarkdownH1bg = { fg = palette.keyword, bg = palette.none, bold = true },
        RenderMarkdownH2bg = { fg = palette.func, bg = palette.none, bold = true },
        RenderMarkdownH3bg = { fg = palette.constant, bg = palette.none, bold = true },
        RenderMarkdownH4bg = { fg = palette.string, bg = palette.none, bold = true },
        RenderMarkdownH5bg = { fg = palette.success, bg = palette.none, bold = true },
        RenderMarkdownH6bg = { fg = palette.comment, bg = palette.none, bold = true },
        RenderMarkdownCode = { bg = palette.surface },
        Dash = { fg = palette.comment, bold = true },

        Headline1 = { fg = palette.keyword, bg = palette.none, bold = true },
        Headline2 = { fg = palette.func, bg = palette.none, bold = true },
        Headline3 = { fg = palette.constant, bg = palette.none, bold = true },
        Headline4 = { fg = palette.string, bg = palette.none, bold = true },
        Headline5 = { fg = palette.success, bg = palette.none, bold = true },
        Headline6 = { fg = palette.comment, bg = palette.none, bold = true },

        -- LSP & Diagnostics
        DiagnosticError = { fg = palette.error },
        DiagnosticWarn = { fg = palette.warning },
        DiagnosticInfo = { fg = palette.func },
        DiagnosticHint = { fg = palette.constant },
        DiagnosticOk = { fg = palette.success },
        DiagnosticUnderlineError = { sp = palette.error, undercurl = true },
        DiagnosticUnderlineWarn = { sp = palette.warning, undercurl = true },
        DiagnosticUnderlineInfo = { sp = palette.func, undercurl = true },
        DiagnosticUnderlineHint = { sp = palette.constant, undercurl = true },
        DiagnosticVirtualTextError = { fg = palette.error, bg = palette.surface },
        DiagnosticVirtualTextWarn = { fg = palette.warning, bg = palette.surface },
        DiagnosticVirtualTextInfo = { fg = palette.func, bg = palette.surface },
        DiagnosticVirtualTextHint = { fg = palette.constant, bg = palette.surface },

        -- Git Commit
        --
        -- Espelho da queries/gitcommit/highlights.scm do nvim-treesitter, para
        -- o mesmo buffer sair igual com e sem parser. Os links são de propósito:
        -- deixam o pareamento com a captura explícito, e mudar a captura move
        -- os dois lados juntos. O prefixo de conventional commit, que a
        -- sintaxe nativa não separa do resumo, vem do after/syntax do pacote
        -- nvim, porque exige um syn match e não só cor.
        gitcommitSummary = { link = "@markup.heading" },
        gitcommitHeader = { link = "@markup.heading" },
        gitcommitBranch = { link = "@markup.link" },
        gitcommitSelectedType = { link = "@keyword" },
        gitcommitDiscardedType = { link = "@keyword" },
        gitcommitUnmergedType = { link = "@keyword" },
        gitcommitFile = { link = "@string.special.path" },
        gitcommitSelectedFile = { link = "@string.special.path" },
        gitcommitDiscardedFile = { link = "@string.special.path" },
        gitcommitUntrackedFile = { link = "@string.special.path" },
        gitcommitUnmergedFile = { link = "@string.special.path" },
        gitcommitArrow = { link = "@punctuation.delimiter" },
        -- Os dois sem contraparte na query: o tree-sitter não marca estouro da
        -- coluna 50 nem texto na linha 2, que o git espera vazia. O fg = bg que
        -- havia no Blank fazia o texto sumir.
        gitcommitOverflow = { fg = palette.base, bg = palette.error },
        gitcommitBlank = { fg = palette.error },

        GitSignsAdd = { fg = palette.success },
        GitSignsChange = { fg = palette.warning },
        GitSignsDelete = { fg = palette.error },

        -- Telescope
        TelescopeNormal = { fg = palette.text, bg = palette.base },
        TelescopePromptNormal = { fg = palette.text, bg = palette.base },
        TelescopeBorder = { fg = palette.highlight_med, bg = palette.base },
        TelescopePromptBorder = { fg = palette.keyword, bg = palette.base },
        TelescopeResultsBorder = { fg = palette.highlight_med, bg = palette.base },
        TelescopePreviewBorder = { fg = palette.highlight_med, bg = palette.base },
        TelescopePromptTitle = { fg = palette.base, bg = palette.keyword, bold = true },
        TelescopeResultsTitle = { fg = palette.base, bg = palette.comment, bold = true },
        TelescopePreviewTitle = { fg = palette.base, bg = palette.comment, bold = true },
        TelescopePromptPrefix = { fg = palette.keyword, bold = true },
        -- Sem fg: um fg aqui vale para a linha inteira e apaga o
        -- TelescopeMatching logo abaixo, além de tingir o caminho de vermelho.
        -- Como o realce passa a sair só do fundo, ele sobe de bg+1 para bg+2.
        TelescopeSelection = { bg = palette.overlay },
        TelescopeSelectionCaret = { fg = palette.keyword, bg = palette.overlay },
        TelescopeMatching = { fg = palette.func, bold = true },

        -- NvimTree
        NvimTreeFolderIcon = { fg = palette.func },
        NvimTreeFolderName = { fg = palette.func },
        NvimTreeRootFolder = { fg = palette.keyword, bold = true },
        NvimTreeGitDirty = { fg = palette.warning },
        NvimTreeGitNew = { fg = palette.success },
        NvimTreeGitDeleted = { fg = palette.error },
        NvimTreeIndentMarker = { fg = palette.overlay },
        NvimTreeNormal = { fg = palette.text, bg = palette.base },
        NvimTreeWinSeparator = { fg = palette.base, bg = palette.base },

        -- Pmenu & Autocompletar Base (Cmp)
        Pmenu = { fg = palette.text, bg = palette.surface },
        PmenuSel = { fg = palette.keyword, bg = palette.overlay, bold = true },
        PmenuSbar = { bg = palette.surface },
        PmenuThumb = { bg = palette.highlight_med },
        -- Borda do pum, do 'pumborder' que o perfil servidor liga. O padrão
        -- herda o Pmenu e desenha a borda na cor do texto, fora do tom de todas
        -- as outras bordas do tema, que saem do FloatBorder.
        PmenuBorder = { fg = palette.highlight_med, bg = palette.surface },
        -- Pum e wildmenu nativos, que é o que sobra no perfil servidor: mesmo
        -- destaque de trecho casado que o blink e o cmp recebem abaixo.
        PmenuMatch = { fg = palette.func, bg = palette.surface, bold = true },
        PmenuMatchSel = { fg = palette.func, bg = palette.overlay, bold = true },
        CmpItemAbbr = { fg = palette.text },
        CmpItemAbbrDeprecated = { fg = palette.comment, strikethrough = true },
        CmpItemAbbrMatch = { fg = palette.func, bold = true },
        CmpItemAbbrMatchFuzzy = { fg = palette.func, bold = true },
        CmpItemMenu = { fg = palette.comment, italic = true },
        CmpItemKindText = { fg = palette.text },
        CmpItemKindMethod = { fg = palette.func },
        CmpItemKindFunction = { fg = palette.func },
        CmpItemKindConstructor = { fg = palette.constant },
        CmpItemKindField = { fg = palette.func },
        CmpItemKindVariable = { fg = palette.text },
        CmpItemKindClass = { fg = palette.constant },
        CmpItemKindInterface = { fg = palette.constant },
        CmpItemKindModule = { fg = palette.text },
        CmpItemKindProperty = { fg = palette.func },
        CmpItemKindUnit = { fg = palette.text },
        CmpItemKindValue = { fg = palette.string },
        CmpItemKindEnum = { fg = palette.func },
        CmpItemKindKeyword = { fg = palette.keyword },
        CmpItemKindSnippet = { fg = palette.string },
        CmpItemKindColor = { fg = palette.error },
        CmpItemKindFile = { fg = palette.text },
        CmpItemKindReference = { fg = palette.func },
        CmpItemKindFolder = { fg = palette.text },
        CmpItemKindEnumMember = { fg = palette.func },
        CmpItemKindConstant = { fg = palette.constant },
        CmpItemKindStruct = { fg = palette.constant },
        CmpItemKindEvent = { fg = palette.func },
        CmpItemKindOperator = { fg = palette.operator },

        -- Blink.cmp
        BlinkCmpMenu = { link = "Pmenu" },
        BlinkCmpMenuSelection = { bg = palette.overlay, bold = true },
        BlinkCmpLabel = { fg = palette.text },
        BlinkCmpLabelDeprecated = { fg = palette.comment, strikethrough = true },
        BlinkCmpLabelMatch = { fg = palette.func, bold = true },
        BlinkCmpLabelDetail = { fg = palette.comment, italic = true },
        BlinkCmpLabelDescription = { fg = palette.comment },
        BlinkCmpGhostText = { fg = palette.comment, italic = true },
        BlinkCmpSource = { fg = palette.highlight_high },
    }

    -- ==========================================
    -- Aplicação dos Highlights via API do Neovim
    -- ==========================================
    for group, highlight in pairs(groups) do
        vim.api.nvim_set_hl(0, group, highlight)
    end

    -- ==========================================
    -- Cores do Terminal Integrado (Terminals)
    -- ==========================================
    vim.g.terminal_color_0 = palette.black
    vim.g.terminal_color_1 = palette.error
    vim.g.terminal_color_2 = palette.success
    vim.g.terminal_color_3 = palette.warning
    vim.g.terminal_color_4 = palette.func
    vim.g.terminal_color_5 = palette.constant
    vim.g.terminal_color_6 = palette.comment
    vim.g.terminal_color_7 = palette.text
    vim.g.terminal_color_8 = palette.highlight_med
    vim.g.terminal_color_9 = palette.keyword
    vim.g.terminal_color_10 = palette.success
    vim.g.terminal_color_11 = palette.warning
    vim.g.terminal_color_12 = palette.func
    vim.g.terminal_color_13 = palette.constant
    vim.g.terminal_color_14 = palette.comment
    vim.g.terminal_color_15 = palette.text
end

return M
