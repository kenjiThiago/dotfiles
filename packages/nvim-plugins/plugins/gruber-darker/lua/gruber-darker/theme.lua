-- lua/gruber-darker/theme.lua
local palette = require("gruber-darker.palette").colors

local M = {}

function M.setup()
    vim.cmd("hi clear")
    if vim.fn.exists("syntax_on") then
        vim.cmd("syntax reset")
    end
    vim.o.termguicolors = true
    vim.g.colors_name = "gruber-rose-moon"

    local groups = {
        -- ==========================================
        -- UI do Editor
        -- ==========================================
        Normal = { fg = palette.fg, bg = palette.bg },
        NormalFloat = { fg = palette.fg, bg = palette["bg+1"] },
        NormalNC = { fg = palette.fg, bg = palette.bg },
        ColorColumn = { bg = palette["bg+1"] },
        Conceal = { fg = palette.burgundy },
        Cursor = { fg = palette.black, bg = palette.crimson },
        CursorLine = { bg = palette["bg+1"] },
        CursorColumn = { bg = palette["bg+1"] },
        CursorLineNr = { fg = palette.crimson, bold = true },
        LineNr = { fg = palette["bg+4"] },
        SignColumn = { bg = palette.bg },
        Directory = { fg = palette.terracotta, bold = true },
        ErrorMsg = { fg = palette.red_error, bold = true },
        WarningMsg = { fg = palette.yellow_warn, bold = true },
        MoreMsg = { fg = palette.terracotta, bold = true },
        ModeMsg = { fg = palette.crimson, bold = true },
        MatchParen = { fg = palette.crimson, bg = palette["bg+2"], bold = true },
        NonText = { fg = palette["bg+2"] },
        Whitespace = { fg = palette["bg+2"] },
        SpecialKey = { fg = palette.green_ok },
        WildMenu = { fg = palette.black, bg = palette.crimson },
        Search = { fg = palette.bg, bg = palette.dusty_rose },
        IncSearch = { fg = palette.bg, bg = palette.crimson },
        Question = { fg = palette.green_ok },
        Title = { fg = palette.terracotta, bold = true },
        VertSplit = { fg = palette["bg+2"] },
        WinSeparator = { fg = palette["bg+2"] },
        Visual = { bg = palette["bg+3"] },
        Folded = { fg = palette.burgundy, bg = palette["bg+1"] },
        FoldColumn = { fg = palette.burgundy, bg = palette.bg },
        StatusLine = { fg = palette.fg, bg = palette["bg+2"] },
        StatusLineNC = { fg = palette.burgundy, bg = palette["bg+1"] },
        TabLine = { fg = palette.burgundy, bg = palette["bg+1"] },
        TabLineFill = { bg = palette["bg-1"] },
        TabLineSel = { fg = palette.crimson, bg = palette.bg, bold = true },
        FloatBorder = { fg = palette["bg+3"], bg = palette["bg+1"] },
        FloatTitle = { fg = palette.crimson, bg = palette["bg+1"], bold = true },

        -- Spell Checking Nativo
        SpellBad = { sp = palette.red_error, undercurl = true },
        SpellCap = { sp = palette.yellow_warn, undercurl = true },
        SpellLocal = { sp = palette.terracotta, undercurl = true },
        SpellRare = { sp = palette.plum, undercurl = true },

        -- Diff Nativo
        DiffAdd = { fg = palette.green_ok, bg = palette["bg+2"] },
        DiffChange = { fg = palette.yellow_warn, bg = palette["bg+2"] },
        DiffDelete = { fg = palette.red_error, bg = palette["bg+2"] },
        DiffText = { fg = palette.terracotta, bg = palette["bg+3"] },

        TrailingWhitespace = { bg = palette.crimson },

        -- ==========================================
        -- Sintaxe Nativa (Prioridade)
        -- ==========================================
        Comment = { fg = palette.burgundy },
        String = { fg = palette.dusty_rose },
        Character = { fg = palette.dusty_rose },
        Number = { fg = palette.plum },
        Boolean = { fg = palette.crimson, bold = true },
        Float = { fg = palette.plum },
        Identifier = { fg = palette.fg },
        Function = { fg = palette.terracotta },
        Statement = { fg = palette.crimson, bold = true },
        Conditional = { fg = palette.crimson, bold = true },
        Repeat = { fg = palette.crimson, bold = true },
        Label = { fg = palette.plum },
        Operator = { fg = palette.fg },
        Keyword = { fg = palette.crimson, bold = true },
        Exception = { fg = palette.red_error, bold = true },
        PreProc = { fg = palette.burgundy },
        Include = { fg = palette.crimson, bold = true },
        Define = { fg = palette.crimson, bold = true },
        Macro = { fg = palette.terracotta },
        Type = { fg = palette.burgundy },
        StorageClass = { fg = palette.crimson },
        Structure = { fg = palette.crimson },
        Typedef = { fg = palette.burgundy },
        Special = { fg = palette.fg },
        Underlined = { underline = true },
        Error = { fg = palette.red_error, bold = true },
        Todo = { fg = palette.bg, bg = palette.crimson, bold = true },

        -- Sintaxe Nativa Específica: HTML
        htmlTag = { fg = palette.plum },
        htmlEndTag = { fg = palette.plum },
        htmlTagName = { fg = palette.crimson },
        htmlArg = { fg = palette.terracotta },

        -- Sintaxe Nativa Específica: YAML
        yamlKey = { fg = palette.plum, bold = true },
        yamlBlockMappingKey = { fg = palette.plum, bold = true },
        yamlString = { link = "String" },
        yamlNumber = { link = "Number" },
        yamlConstant = { link = "Constant" },
        yamlIndicator = { fg = palette.terracotta },
        yamlNodeTag = { fg = palette.crimson },
        yamlAlias = { fg = palette.green_ok },
        yamlDocumentStart = { fg = palette.burgundy, bold = true },
        yamlDocumentEnd = { fg = palette.burgundy, bold = true },

        -- Sintaxe Nativa Específica: OWL / XML (Web Ontology Language / RDF)
        xmlTag = { fg = palette.plum },
        xmlEndTag = { fg = palette.plum },
        xmlTagName = { fg = palette.crimson },
        xmlAttrib = { fg = palette.terracotta },
        xmlString = { link = "String" },
        xmlEqual = { fg = palette.fg },
        owlOntology = { fg = palette.burgundy, bold = true },
        owlClass = { fg = palette.plum },
        owlProperty = { fg = palette.terracotta },
        owlRestriction = { fg = palette.crimson },

        -- Sintaxe Nativa Específica: CSV / Rainbow
        csvCol0 = { fg = palette.fg },
        csvCol1 = { fg = palette.crimson },
        csvCol2 = { fg = palette.terracotta },
        csvCol3 = { fg = palette.green_ok },
        csvCol4 = { fg = palette.plum },
        csvCol5 = { fg = palette.dusty_rose },
        csvCol6 = { fg = palette.burgundy },
        csvCol7 = { fg = palette.green_ok },
        csvCol8 = { fg = palette.plum },

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
        ["@variable"] = { fg = palette.fg },
        ["@variable.builtin"] = { fg = palette.fg },
        ["@variable.parameter"] = { fg = palette.fg },
        ["@variable.member"] = { fg = palette.fg },
        ["@property"] = { fg = palette.fg },
        ["@constant"] = { fg = palette.fg },
        ["@constant.builtin"] = { fg = palette.plum },
        ["@constant.macro"] = { link = "Macro" },
        ["@module"] = { fg = palette.fg },
        ["@label"] = { link = "Label" },
        ["@string"] = { link = "String" },
        ["@string.regexp"] = { fg = palette.dusty_rose },
        ["@string.escape"] = { fg = palette.plum },
        ["@character"] = { link = "Character" },
        ["@boolean"] = { link = "Boolean" },
        ["@number"] = { link = "Number" },
        ["@float"] = { link = "Float" },
        ["@type"] = { link = "Type" },
        ["@type.builtin"] = { link = "Type" },
        ["@attribute"] = { fg = palette.fg },
        ["@function"] = { link = "Function" },
        ["@function.builtin"] = { fg = palette.terracotta },
        ["@function.macro"] = { fg = palette.terracotta },
        ["@function.call"] = { fg = palette.terracotta },
        ["@function.method"] = { link = "Function" },
        ["@function.method.call"] = { fg = palette.terracotta },
        ["@constructor"] = { fg = palette.burgundy },
        ["@operator"] = { fg = palette.fg },
        ["@keyword"] = { link = "Keyword" },
        ["@keyword.operator"] = { fg = palette.crimson, bold = true },
        ["@keyword.import"] = { link = "Include" },
        ["@keyword.return"] = { fg = palette.crimson, bold = true },
        ["@keyword.function"] = { fg = palette.crimson, bold = true },
        ["@punctuation.delimiter"] = { fg = palette.fg },
        ["@punctuation.bracket"] = { fg = palette.fg },
        ["@punctuation.special"] = { fg = palette.fg },
        ["@comment"] = { link = "Comment" },
        ["@comment.documentation"] = { link = "Comment" },
        ["@comment.todo"] = { link = "Todo" },
        ["@property.yaml"] = { link = "@property" },

        -- Tree-Sitter: Tags (Usado por XML, HTML, e formatos OWL baseados em RDF)
        ["@tag"] = { fg = palette.crimson },
        ["@tag.builtin"] = { fg = palette.crimson },
        ["@tag.attribute"] = { fg = palette.terracotta },
        ["@tag.delimiter"] = { fg = palette.plum },

        ["@markup.heading.1"] = { fg = palette.crimson, bold = true },
        ["@markup.heading.2"] = { fg = palette.terracotta, bold = true },
        ["@markup.heading.3"] = { fg = palette.plum, bold = true },
        ["@markup.heading.4"] = { fg = palette.dusty_rose, bold = true },
        ["@markup.heading.5"] = { fg = palette.green_ok, bold = true },
        ["@markup.heading.6"] = { fg = palette.burgundy, bold = true },

        ["@markup.heading.1.marker"] = { fg = palette.crimson, bold = true },
        ["@markup.heading.2.marker"] = { fg = palette.terracotta, bold = true },
        ["@markup.heading.3.marker"] = { fg = palette.plum, bold = true },
        ["@markup.heading.4.marker"] = { fg = palette.dusty_rose, bold = true },
        ["@markup.heading.5.marker"] = { fg = palette.green_ok, bold = true },
        ["@markup.heading.6.marker"] = { fg = palette.burgundy, bold = true },

        -- ==========================================
        -- Plugins
        -- ==========================================
        -- Markdown Plugins
        RenderMarkdownH1bg = { fg = palette.crimson, bg = palette.none, bold = true },
        RenderMarkdownH2bg = { fg = palette.terracotta, bg = palette.none, bold = true },
        RenderMarkdownH3bg = { fg = palette.plum, bg = palette.none, bold = true },
        RenderMarkdownH4bg = { fg = palette.dusty_rose, bg = palette.none, bold = true },
        RenderMarkdownH5bg = { fg = palette.green_ok, bg = palette.none, bold = true },
        RenderMarkdownH6bg = { fg = palette.burgundy, bg = palette.none, bold = true },
        RenderMarkdownCode = { bg = palette["bg+1"] },
        Dash = { fg = palette.burgundy, bold = true },

        Headline1 = { fg = palette.crimson, bg = palette.none, bold = true },
        Headline2 = { fg = palette.terracotta, bg = palette.none, bold = true },
        Headline3 = { fg = palette.plum, bg = palette.none, bold = true },
        Headline4 = { fg = palette.dusty_rose, bg = palette.none, bold = true },
        Headline5 = { fg = palette.green_ok, bg = palette.none, bold = true },
        Headline6 = { fg = palette.burgundy, bg = palette.none, bold = true },

        -- LSP & Diagnostics
        DiagnosticError = { fg = palette.red_error },
        DiagnosticWarn = { fg = palette.yellow_warn },
        DiagnosticInfo = { fg = palette.terracotta },
        DiagnosticHint = { fg = palette.plum },
        DiagnosticUnderlineError = { sp = palette.red_error, undercurl = true },
        DiagnosticUnderlineWarn = { sp = palette.yellow_warn, undercurl = true },
        DiagnosticUnderlineInfo = { sp = palette.terracotta, undercurl = true },
        DiagnosticUnderlineHint = { sp = palette.plum, undercurl = true },
        DiagnosticVirtualTextError = { fg = palette.red_error, bg = palette["bg+1"] },
        DiagnosticVirtualTextWarn = { fg = palette.yellow_warn, bg = palette["bg+1"] },
        DiagnosticVirtualTextInfo = { fg = palette.terracotta, bg = palette["bg+1"] },
        DiagnosticVirtualTextHint = { fg = palette.plum, bg = palette["bg+1"] },

        -- Git Commit
        gitcommitSummary = { fg = palette.terracotta, bold = true },
        gitcommitOverflow = { fg = palette.bg, bg = palette.red_error },
        gitcommitBlank = { fg = palette.bg },
        gitcommitHeader = { fg = palette.burgundy, italic = true },
        gitcommitBranch = { fg = palette.plum, bold = true },
        gitcommitSelectedType = { fg = palette.green_ok },
        gitcommitSelectedFile = { fg = palette.green_ok, bold = true },
        gitcommitDiscardedType = { fg = palette.yellow_warn },
        gitcommitDiscardedFile = { fg = palette.yellow_warn, bold = true },
        gitcommitUntrackedFile = { fg = palette.dusty_rose },

        GitSignsAdd = { fg = palette.green_ok },
        GitSignsChange = { fg = palette.yellow_warn },
        GitSignsDelete = { fg = palette.red_error },

        -- Telescope
        TelescopeNormal = { fg = palette.fg, bg = palette.bg },
        TelescopePromptNormal = { fg = palette.fg, bg = palette.bg },
        TelescopeBorder = { fg = palette["bg+3"], bg = palette.bg },
        TelescopePromptBorder = { fg = palette.crimson, bg = palette.bg },
        TelescopeResultsBorder = { fg = palette["bg+3"], bg = palette.bg },
        TelescopePreviewBorder = { fg = palette["bg+3"], bg = palette.bg },
        TelescopePromptTitle = { fg = palette.bg, bg = palette.crimson, bold = true },
        TelescopeResultsTitle = { fg = palette.bg, bg = palette.burgundy, bold = true },
        TelescopePreviewTitle = { fg = palette.bg, bg = palette.burgundy, bold = true },
        TelescopePromptPrefix = { fg = palette.crimson, bold = true },
        TelescopeSelection = { fg = palette.crimson, bg = palette["bg+1"], bold = true },
        TelescopeSelectionCaret = { fg = palette.crimson, bg = palette["bg+1"] },
        TelescopeMatching = { fg = palette.terracotta, bold = true },

        -- NvimTree
        NvimTreeFolderIcon = { fg = palette.terracotta },
        NvimTreeFolderName = { fg = palette.terracotta },
        NvimTreeRootFolder = { fg = palette.crimson, bold = true },
        NvimTreeGitDirty = { fg = palette.yellow_warn },
        NvimTreeGitNew = { fg = palette.green_ok },
        NvimTreeGitDeleted = { fg = palette.red_error },
        NvimTreeIndentMarker = { fg = palette["bg+2"] },
        NvimTreeNormal = { fg = palette.fg, bg = palette["bg-1"] },
        NvimTreeWinSeparator = { fg = palette["bg-1"], bg = palette["bg-1"] },

        -- Pmenu & Autocompletar Base (Cmp)
        Pmenu = { fg = palette.fg, bg = palette["bg+1"] },
        PmenuSel = { fg = palette.crimson, bg = palette["bg+2"], bold = true },
        PmenuSbar = { bg = palette["bg+1"] },
        PmenuThumb = { bg = palette["bg+3"] },
        CmpItemAbbr = { fg = palette.fg },
        CmpItemAbbrDeprecated = { fg = palette.burgundy, strikethrough = true },
        CmpItemAbbrMatch = { fg = palette.terracotta, bold = true },
        CmpItemAbbrMatchFuzzy = { fg = palette.terracotta, bold = true },
        CmpItemMenu = { fg = palette.burgundy, italic = true },
        CmpItemKindText = { fg = palette.fg },
        CmpItemKindMethod = { fg = palette.terracotta },
        CmpItemKindFunction = { fg = palette.terracotta },
        CmpItemKindConstructor = { fg = palette.plum },
        CmpItemKindField = { fg = palette.terracotta },
        CmpItemKindVariable = { fg = palette.fg },
        CmpItemKindClass = { fg = palette.plum },
        CmpItemKindInterface = { fg = palette.plum },
        CmpItemKindModule = { fg = palette.fg },
        CmpItemKindProperty = { fg = palette.terracotta },
        CmpItemKindUnit = { fg = palette.fg },
        CmpItemKindValue = { fg = palette.dusty_rose },
        CmpItemKindEnum = { fg = palette.terracotta },
        CmpItemKindKeyword = { fg = palette.crimson },
        CmpItemKindSnippet = { fg = palette.dusty_rose },
        CmpItemKindColor = { fg = palette.red_error },
        CmpItemKindFile = { fg = palette.fg },
        CmpItemKindReference = { fg = palette.terracotta },
        CmpItemKindFolder = { fg = palette.fg },
        CmpItemKindEnumMember = { fg = palette.terracotta },
        CmpItemKindConstant = { fg = palette.plum },
        CmpItemKindStruct = { fg = palette.plum },
        CmpItemKindEvent = { fg = palette.terracotta },
        CmpItemKindOperator = { fg = palette.fg },

        -- Blink.cmp
        BlinkCmpMenu = { link = "Pmenu" },
        BlinkCmpMenuSelection = { bg = palette["bg+2"], bold = true },
        BlinkCmpLabel = { fg = palette.fg },
        BlinkCmpLabelDeprecated = { fg = palette.burgundy, strikethrough = true },
        BlinkCmpLabelMatch = { fg = palette.terracotta, bold = true },
        BlinkCmpLabelDetail = { fg = palette.burgundy, italic = true },
        BlinkCmpLabelDescription = { fg = palette.burgundy },
        BlinkCmpGhostText = { fg = palette.burgundy, italic = true },
        BlinkCmpSource = { fg = palette["bg+4"] },
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
    vim.g.terminal_color_1 = palette.red_error
    vim.g.terminal_color_2 = palette.green_ok
    vim.g.terminal_color_3 = palette.yellow_warn
    vim.g.terminal_color_4 = palette.terracotta
    vim.g.terminal_color_5 = palette.plum
    vim.g.terminal_color_6 = palette.burgundy
    vim.g.terminal_color_7 = palette.fg
    vim.g.terminal_color_8 = palette["bg+3"]
    vim.g.terminal_color_9 = palette.crimson
    vim.g.terminal_color_10 = palette.green_ok
    vim.g.terminal_color_11 = palette.yellow_warn
    vim.g.terminal_color_12 = palette.terracotta
    vim.g.terminal_color_13 = palette.plum
    vim.g.terminal_color_14 = palette.burgundy
    vim.g.terminal_color_15 = palette.fg
end

return M
