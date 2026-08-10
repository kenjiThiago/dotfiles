require("NeoVim.remap")
require("NeoVim.set")
require("NeoVim.autocmd")
require("NeoVim.custom.statusline")

-- Módulo privado do runtime, e instável: já se chamou `vim._extui`. Sem o
-- pcall, o erro aqui aborta o require inteiro e o desvio de perfil lá embaixo
-- nunca roda, deixando o servidor sem o `NeoVim.server`.
pcall(function()
    require("vim._core.ui2").enable({})
end)

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

-- Daqui para baixo é o que depende de plugin, e por isso é só do desktop.
-- No servidor quem assume é o NeoVim.server (ver NeoVim.profile).
if require("NeoVim.profile").server then
    require("NeoVim.server")
    return
end

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("NeoVim.custom.notas")

require("NeoVim.plugins.colors")
require("NeoVim.plugins.telescope")
require("NeoVim.plugins.harpoon")
require("NeoVim.plugins.conform")
-- require("NeoVim.plugins.git")
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
