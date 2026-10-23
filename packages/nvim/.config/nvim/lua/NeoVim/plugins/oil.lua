local gh = function(x)
	return "https://github.com/" .. x
end

-- vim.pack.add({ gh("stevearc/oil.nvim") })
vim.pack.add({ { src = gh("kenjiThiago/oil.nvim"), version = "fix/recursive-fs-open-dir-limit" } })

local function destacar_permissoes(texto)
	local trechos = {}
	for i = 1, #texto do
		local grupo = texto:sub(i, i) == "-" and "LineNr" or "Comment"
		table.insert(trechos, { grupo, i - 1, i })
	end
	return trechos
end

local EXECUCAO = tonumber("111", 8)

-- Sem colunas de detalhe o oil não faz stat, então a entrada pode vir sem ele.
local function eh_executavel(entry, bufnr)
	if entry.type ~= "file" then
		return false
	end
	local stat = entry.meta and entry.meta.stat
	if not stat then
		local dir = require("oil").get_current_dir(bufnr)
		stat = dir and vim.uv.fs_stat(dir .. entry.name)
	end
	return stat ~= nil and bit.band(stat.mode, EXECUCAO) ~= 0
end

local colunas_completas = {
	{
		"type",
		icons = { directory = "d", file = "-", link = "l", socket = "s" },
		highlight = destacar_permissoes,
	},
	{ "permissions", highlight = destacar_permissoes },
	{ "size", highlight = "LineNr" },
	{ "mtime", highlight = "LineNr" },
	{ "icon" },
}

-- Com uma pasta o imv ordena por nome; com arquivos explícitos, mantém a ordem do oil.
local function abrir_no_imv()
	local oil = require("oil")
	local dir, atual = oil.get_current_dir(), oil.get_cursor_entry()
	if not dir or not atual then
		return
	end
	local arquivos = {}
	for lnum = 1, vim.api.nvim_buf_line_count(0) do
		local entry = oil.get_entry_on_line(0, lnum)
		if entry and entry.type == "file" then
			table.insert(arquivos, dir .. entry.name)
		end
	end
	vim.system({ "imv", "-n", dir .. atual.name, unpack(arquivos) }, { detach = true })
end

function _G.OilWinbar()
	local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
	local dir = require("oil").get_current_dir(bufnr) or vim.api.nvim_buf_get_name(bufnr)
	local caminho = vim.fn.fnamemodify(dir, ":~"):gsub("%%", "%%%%")
	local pai, atual = caminho:match("^(.-)([^/]+/)$")
	if not atual then
		pai, atual = "", caminho
	end
	return " %#LineNr#" .. pai .. "%#Directory#" .. atual
end

require("oil").setup({
	win_options = {
		winbar = "%!v:lua.OilWinbar()",
	},
	keymaps = {
		["<C-h>"] = false,
		["<C-b>"] = { "actions.select", opts = { horizontal = true }, desc = "Open the entry in a horizontal split" },
		["<C-l>"] = false,
		["<C-s>"] = "actions.refresh",
		["<leader>i"] = {
			desc = "Toggle detail view",
			callback = function()
				local oil = require("oil")
				local config = require("oil.config")

				if #config.columns == 1 then
					oil.set_columns(colunas_completas)
				else
					oil.set_columns({
						{ "icon" },
					})
				end
			end,
		},
		["gi"] = {
			callback = abrir_no_imv,
			desc = "Abrir as imagens no imv na ordem do oil",
		},
		["gh"] = {
			callback = function()
				require("oil").open("~/")
			end,
			desc = "Ir para o diretório Home (~/)",
		},
		["gd"] = {
			callback = function()
				require("oil").open("~/Downloads")
			end,
			desc = "Ir para o diretório Downloads (~/Downloads)",
		},
	},
	view_options = {
		show_hidden = true,
		highlight_filename = function(entry, is_hidden, _, _, bufnr)
			if not is_hidden and eh_executavel(entry, bufnr) then
				return "DiagnosticOk"
			end
		end,
	},
	columns = colunas_completas,
	skip_confirm_for_simple_edits = true,
	watch_for_changes = true,
	-- O oil abre o destino real de um symlink; sem os buffers antigos o <C-o> não volta para a pasta do link.
	cleanup_delay_ms = false,
})
