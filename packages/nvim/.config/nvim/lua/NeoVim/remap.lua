vim.g.mapleader = " "

if not require("NeoVim.profile").minimal then
	vim.keymap.set("n", "<leader>pv", "<CMD>Oil<CR>", { desc = "Open parent directory" })
	vim.keymap.set("n", "<leader>-", function()
		require("NeoVim.custom.yazi").open()
	end, { desc = "Abrir o yazi no diretório do arquivo" })
end

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<M-i>", "<C-^>")

-- Embutido a partir do 0.12; antes disso o packadd erra.
if pcall(vim.cmd.packadd, "nvim.undotree") then
	vim.keymap.set("n", "<leader>u", "<cmd>Undotree<CR>")
end

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

vim.keymap.set("x", "<leader>p", '"_dP')

vim.keymap.set("n", "<leader>y", '"+y')
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>Y", '"+y$')
-- Passa pelo "z para não ler o "+, que no OSC 52 do servidor trava esperando o terminal.
vim.keymap.set("x", "<leader>Y", function()
	vim.cmd('normal! "zy')
	vim.fn.setreg("+", (vim.fn.getreg("z"):gsub("\n$", "")), "v")
end)

vim.keymap.set("n", "<leader>d", '"_d')
vim.keymap.set("v", "<leader>d", '"_d')

vim.keymap.set("n", "<M-j>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<M-k>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lprev<CR>zz")

-- Entre listas da quickfix, não dentro de uma.
vim.keymap.set("n", "<leader>qo", "<cmd>colder<CR>")
vim.keymap.set("n", "<leader>qn", "<cmd>cnewer<CR>")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.keymap.set("n", "<leader>to", ":tabnew<CR>")
vim.keymap.set("n", "<leader>tx", ":tabclose<CR>")
vim.keymap.set("n", "<leader>tn", ":tabn<CR>")
vim.keymap.set("n", "<leader>tp", ":tabp<CR>")
vim.keymap.set("n", "<leader>tt", ":tabnew | term<CR>")

vim.keymap.set("n", "<leader>gs", "<cmd>silent !tmux-lazygit<CR>")

vim.keymap.set("n", "<leader>nh", vim.cmd.nohlsearch)

-- O <C-l>, que limpa os multicursores por padrão, ficou com o harpoon.
vim.keymap.set("n", "<Esc>", function()
	vim.api.nvim_buf_clear_namespace(0, vim.api.nvim_create_namespace("nvim.multicursor"), 0, -1)
end, { desc = "Limpar os multicursores" })

vim.keymap.set("n", "<leader>gc", ":Comp")

-- O :match e o matchadd valem por janela, então cada janela nova recebe o seu.
-- As flutuantes ficam de fora para não marcar o que se digita no telescope.
local mostrar_espacos = true

-- Só o luar define o grupo; nos outros temas o destaque ficaria invisível.
local function realce_padrao()
	vim.api.nvim_set_hl(0, "TrailingWhitespace", { link = "Error", default = true })
end

realce_padrao()
vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("EspacosNoFimRealce", { clear = true }),
	callback = realce_padrao,
})

local function destacar_espacos(win)
	if vim.api.nvim_win_get_config(win).relative ~= "" then
		return
	end

	local id = vim.w[win].espacos_no_fim
	if mostrar_espacos and not id then
		vim.w[win].espacos_no_fim = vim.fn.matchadd("TrailingWhitespace", [[\s\+$]], 10, -1, { window = win })
	elseif not mostrar_espacos and id then
		pcall(vim.fn.matchdelete, id, win)
		vim.w[win].espacos_no_fim = nil
	end
end

for _, win in ipairs(vim.api.nvim_list_wins()) do
	destacar_espacos(win)
end

vim.api.nvim_create_autocmd("WinNew", {
	group = vim.api.nvim_create_augroup("EspacosNoFim", { clear = true }),
	callback = function()
		destacar_espacos(vim.api.nvim_get_current_win())
	end,
})

vim.api.nvim_create_user_command("ShowWhiteSpaces", function()
	mostrar_espacos = not mostrar_espacos
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		destacar_espacos(win)
	end
end, {})

vim.keymap.set("n", "<leader>ns", ":ShowWhiteSpaces<CR>")
vim.keymap.set("n", "<leader>nl", "<cmd>set list!<CR>", { desc = "Mostrar espaços e tabs" })
vim.keymap.set("n", "<leader>n8", function()
	vim.o.colorcolumn = vim.o.colorcolumn == "" and "80" or ""
end, { desc = "Mostrar a coluna 80" })
vim.keymap.set("n", "<leader>zs", function()
	vim.o.laststatus = vim.o.laststatus == 0 and 2 or 0
    vim.o.cmdheight = vim.o.cmdheight == 0 and 1 or 0
end, { desc = "Alternar a statusline" })
vim.keymap.set("n", "<leader>nr", function()
	local save_cursor = vim.fn.getpos(".")
	vim.cmd([[%s/\s\+$//e]])
	vim.fn.setpos(".", save_cursor)
end)

vim.api.nvim_create_user_command("Compile", function(opts)
	local nome = vim.fn.expand("%:t")
	local extensao = vim.fn.expand("%:e")

	local command = "make "

	if extensao == "c" or extensao == "cpp" then
		command = command .. vim.fn.expand("%:t:r")
	else
		command = command .. nome
	end

	for _, arg in ipairs(opts.fargs) do
		if arg == "-l" then
			command = "l" .. command
		elseif arg:find("^-c") then
			local compiler = vim.split(arg, "-c=")[2]
			vim.cmd("compiler " .. compiler)
		else
			command = command .. " " .. arg
		end
	end

	vim.cmd(command)
end, { nargs = "*" })
