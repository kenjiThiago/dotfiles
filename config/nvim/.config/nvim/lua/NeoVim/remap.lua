-- Old keymaps (o verdadeiro)
-- vim.keymap.set("", "j", "k")
-- vim.keymap.set("", "k", "j")

vim.g.mapleader = " "
--vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader>pv", "<CMD>Oil<CR>", { desc = "Open parent directory" })

vim.keymap.set("i", "jk", "<ESC>")

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

--ClipBorde
vim.keymap.set("x", "<leader>p", "\"_dP")

vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")

vim.keymap.set("n", "<leader>d", "\"_d")
vim.keymap.set("v", "<leader>d", "\"_d")

vim.keymap.set("n", "<M-j>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<M-k>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

--Indentação
-- vim.keymap.set("n", "<TAB>", ">>")
-- vim.keymap.set("n", "<S-TAB>", "<<")

--Tabs
vim.keymap.set("n", "<leader>to", ":tabnew<CR>")
vim.keymap.set("n", "<leader>tx", ":tabclose<CR>")
vim.keymap.set("n", "<leader>tn", ":tabn<CR>")
vim.keymap.set("n", "<leader>tp", ":tabp<CR>")
vim.keymap.set("n", "<leader>tt", ":tabnew | term<CR>")

--Undotree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

--Fugitive
vim.keymap.set("n", "<leader>gs", vim.cmd.Git)

--Highlight
vim.keymap.set("n", "<leader>nh", vim.cmd.nohlsearch)

--Formating
vim.keymap.set({ "n", "v" }, "<leader>f", vim.lsp.buf.format)

--ShowWhiteSpaces
local toggle_ws = false
vim.api.nvim_create_user_command("ShowWhiteSpaces", function()
    if not toggle_ws then
        vim.cmd("highlight ws ctermbg=magenta guibg=magenta | match ws /\\s\\+$/")
        toggle_ws = true
    else
        vim.cmd("match none")
        toggle_ws = false
    end
end, {})

--Plus
vim.api.nvim_create_user_command("Compile", function(opts)
    local result = vim.split(vim.api.nvim_buf_get_name(0), "/")

    local bufName = result[#result]

    local pieces = vim.split(bufName, ".", { plain = true })

    local command = "make "

    command = command .. pieces[1]
    if not (pieces[2] == 'c' or pieces[2] == 'cpp') then
        command = command .. "." .. pieces[2]
    end

    for _, arg in ipairs(opts.fargs) do
        if arg == "-l" then
            command = "l" .. command
        elseif arg.find(arg, "^-c") then
            local compiler = vim.split(arg, "-c=")[2]
            vim.cmd("compiler " .. compiler)
        else
            command = command .. " " .. arg
        end
    end

    vim.cmd(command)
end, { nargs = "*" })
