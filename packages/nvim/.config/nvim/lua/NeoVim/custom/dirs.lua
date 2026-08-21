-- Picker de diretórios: leva a janela atual para qualquer diretório abaixo do
-- home, inclusive os que o zoxide nunca viu. O <leader>pf e o <leader>ps são
-- ancorados na cwd, e o tmux-sessionizer troca de sessão em vez de mover a
-- janela, então nenhum dos dois cobre este caso.

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local themes = require("telescope.themes")

-- O --hidden é o que traz ~/.config, ~/.local/bin e ~/.local/share/fonts, que
-- são destino frequente. As exclusões são o que ele arrasta junto: cache de
-- navegador, de toolchain e de jogo, que levam a lista de 65 mil para menos de
-- 5 mil. Por isso são caminhos e não nomes soltos: cortar ~/.local/share
-- inteiro derrubaria fonts, applications e icons junto com o Steam. O que é
-- lixo de uma máquina só não entra aqui, e sim em ~/.config/fd/ignore, que o
-- fd já lê.
--
-- Sem --follow: symlink para diretório repetiria na lista uma árvore que já
-- está lá pelo caminho real.
local EXCLUSOES = {
    ".git", ".cache", "node_modules", ".venv",
    ".zen", ".mozilla", ".rustup", ".cargo", ".wine",
    "go/pkg", ".local/share/Steam", ".local/share/nvim*",
}

local function comando()
    local cmd = { "fd", "--type", "d", "--hidden", "--color", "never" }

    for _, padrao in ipairs(EXCLUSOES) do
        vim.list_extend(cmd, { "--exclude", padrao })
    end

    return cmd
end

-- O fd roda com cwd na raiz, então a linha vem relativa: é ela que vai para o
-- ordinal, para o sorter não pontuar o prefixo comum a todos os candidatos. A
-- barra final é do fd, e o vim.fs.basename devolve "" com ela.
local function entrada(raiz)
    return function(linha)
        linha = (linha:gsub("/$", ""))
        local caminho = vim.fs.joinpath(raiz, linha)

        return {
            value = caminho,
            display = vim.fn.fnamemodify(caminho, ":~"),
            ordinal = linha,
        }
    end
end

-- O lcd é promovido para a tab assim que o buffer do oil for deixado, pelo
-- OilRelPathFix do autocmd.lua.
local function ir(bufnr, split)
    local escolhido = action_state.get_selected_entry()
    if not escolhido then
        return
    end

    actions.close(bufnr)

    if split then
        vim.cmd(split)
    end

    vim.cmd.lcd(vim.fn.fnameescape(escolhido.value))
    require("oil").open(escolhido.value)
end

local M = {}

function M.abrir(opts)
    opts = opts or {}

    local raiz = vim.fs.normalize(vim.fn.expand(opts.raiz or "~"))

    pickers.new(themes.get_dropdown({}), {
        prompt_title = "Diretórios em " .. vim.fn.fnamemodify(raiz, ":~"),
        finder = finders.new_oneshot_job(comando(), {
            cwd = raiz,
            entry_maker = entrada(raiz),
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(bufnr, map)
            actions.select_default:replace(function() ir(bufnr) end)
            actions.select_horizontal:replace(function() ir(bufnr, "split") end)
            actions.select_vertical:replace(function() ir(bufnr, "vsplit") end)
            actions.select_tab:replace(function() ir(bufnr, "tabnew") end)

            map({ "i", "n" }, "<M-r>", function()
                local escolhido = action_state.get_selected_entry()
                if not escolhido then
                    return
                end

                actions.close(bufnr)
                M.abrir({ raiz = escolhido.value })
            end)

            return true
        end,
    }):find()
end

vim.keymap.set("n", "<leader>pd", function()
    M.abrir()
end, { desc = "Ir para um diretório (<M-r> reancora a busca no selecionado)" })

return M
