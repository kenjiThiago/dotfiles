require("NeoVim.remap")
require("NeoVim.set")
require("NeoVim.autocmd")
require("NeoVim.custom.statusline")
require("NeoVim.custom.notas")

require("vim._core.ui2").enable({})

_G.icons = {
    kinds = {
        Array         = " ",
        Boolean       = "󰨙 ",
        Class         = " ",
        Codeium       = "󰘦 ",
        Color         = " ",
        Control       = " ",
        Collapsed     = " ",
        Constant      = "󰏿 ",
        Constructor   = " ",
        Copilot       = " ",
        Enum          = " ",
        EnumMember    = " ",
        Event         = " ",
        Field         = " ",
        File          = " ",
        Folder        = " ",
        Function      = "󰊕 ",
        Interface     = " ",
        Key           = " ",
        Keyword       = " ",
        Method        = "󰊕 ",
        Module        = " ",
        Namespace     = "󰦮 ",
        Null          = " ",
        Number        = "󰎠 ",
        Object        = " ",
        Operator      = " ",
        Package       = " ",
        Property      = " ",
        Reference     = " ",
        Snippet       = " ",
        String        = " ",
        Struct        = "󰆼 ",
        TabNine       = "󰏚 ",
        Text          = " ",
        TypeParameter = " ",
        Unit          = " ",
        Value         = " ",
        Variable      = "󰀫 ",
    },
}

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Plugins require

require("NeoVim.plugins.colors")
require("NeoVim.plugins.telescope")
require("NeoVim.plugins.harpoon")
require("NeoVim.plugins.conform")
require("NeoVim.plugins.git")
require("NeoVim.plugins.undotree")
require("NeoVim.plugins.cmp")
require("NeoVim.plugins.lsp")
require("NeoVim.plugins.trouble")
require("NeoVim.plugins.mini")
require("NeoVim.plugins.markdown")
require("NeoVim.plugins.oil")
require("NeoVim.plugins.extras")
require("NeoVim.plugins.present")
require("NeoVim.plugins.treesitter")
