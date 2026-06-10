local function setup_statusline_colors()
    local function get_hl(name)
        local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
        if hl.reverse then return { fg = hl.bg, bg = hl.fg } end
        return { fg = hl.fg, bg = hl.bg }
    end

    local normal = get_hl('Normal')
    local sl = get_hl('StatusLine')
    local func = get_hl('Function')
    local str = get_hl('String')
    local warn = get_hl('DiagnosticWarn')
    local err = get_hl('DiagnosticError')
    local info = get_hl('DiagnosticInfo')
    local hint = get_hl('DiagnosticHint')

    local bg_base = sl.bg or normal.bg
    local fg_base = sl.fg or normal.fg

    local bg_info = sl.bg or normal.bg
    local fg_info = sl.fg or normal.fg

    local fg_mode = normal.bg or bg_base or 0x191724

    vim.api.nvim_set_hl(0, 'StatusLineModeN', { bg = func.fg or 0xebbcba, fg = fg_mode, bold = true })
    vim.api.nvim_set_hl(0, 'StatusLineModeI', { bg = str.fg or 0x9ccfd8, fg = fg_mode, bold = true })
    vim.api.nvim_set_hl(0, 'StatusLineModeV', { bg = warn.fg or 0xf6c177, fg = fg_mode, bold = true })
    vim.api.nvim_set_hl(0, 'StatusLineModeR', { bg = err.fg or 0xeb6f92, fg = fg_mode, bold = true })
    vim.api.nvim_set_hl(0, 'StatusLineModeC', { bg = info.fg or 0x31748f, fg = fg_mode, bold = true })
    vim.api.nvim_set_hl(0, 'StatusLineMode',  { bg = func.fg or 0xebbcba, fg = fg_mode, bold = true })

    vim.api.nvim_set_hl(0, 'StatusLineInfo', { bg = bg_info, fg = fg_info })
    vim.api.nvim_set_hl(0, 'StatusLineBody', { bg = bg_base, fg = fg_base })

    vim.api.nvim_set_hl(0, 'StatusLineErr', { bg = bg_base, fg = err.fg or 0xeb6f92 })
    vim.api.nvim_set_hl(0, 'StatusLineWarn', { bg = bg_base, fg = warn.fg or 0xf6c177 })
    vim.api.nvim_set_hl(0, 'StatusLineInf', { bg = bg_base, fg = info.fg or 0x31748f })
    vim.api.nvim_set_hl(0, 'StatusLineHnt', { bg = bg_base, fg = hint.fg or 0x9ccfd8 })
end

vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = setup_statusline_colors,
})
setup_statusline_colors()

local mode_map = {
    ['n']   = ' NORMAL ',
    ['i']   = ' INSERT ',
    ['v']   = ' VISUAL ',
    ['V']   = ' V-LINE ',
    ['\22'] = ' V-BLOCK ',
    ['R']   = ' REPLACE ',
    ['c']   = ' COMMAND ',
    ['t']   = ' TERMINAL ',
}

local mode_hl_map = {
    ['n']   = '%#StatusLineModeN#',
    ['i']   = '%#StatusLineModeI#',
    ['v']   = '%#StatusLineModeV#',
    ['V']   = '%#StatusLineModeV#',
    ['\22'] = '%#StatusLineModeV#',
    ['R']   = '%#StatusLineModeR#',
    ['c']   = '%#StatusLineModeC#',
    ['t']   = '%#StatusLineModeC#',
}

local function get_lsp_diagnostics()
    local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)
    local errors = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.ERROR })
    local warnings = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.WARN })
    local infos = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.INFO })
    local hints = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.HINT })

    local diag_str = ""
    if errors > 0 then diag_str = diag_str .. "%#StatusLineErr#  " .. errors .. " " end
    if warnings > 0 then diag_str = diag_str .. "%#StatusLineWarn#  " .. warnings .. " " end
    if infos > 0 then diag_str = diag_str .. "%#StatusLineInf#  " .. infos .. " " end
    if hints > 0 then diag_str = diag_str .. "%#StatusLineHnt# 󰌵 " .. hints .. " " end

    return diag_str
end

_G.BuildStatusLine = function()
    local current_mode = vim.api.nvim_get_mode().mode
    local mode_name = mode_map[current_mode] or ' ' .. current_mode .. ' '
    local mode_hl = mode_hl_map[current_mode] or '%#StatusLineMode#'

    local section_a = mode_hl .. mode_name
    local section_b = "%#StatusLineInfo# %f %m %r "

    local align_right = "%="

    local diagnostics = get_lsp_diagnostics()
    local section_x = "%#StatusLineBody# %y "
    local section_y = "%#StatusLineInfo# %p%% "
    local section_z = mode_hl .. " %l:%c "

    return string.format(
        "%s%s%s%s%s%s%s",
        section_a, section_b, align_right, diagnostics, section_x, section_y, section_z
    )
end

vim.opt.statusline = "%!v:lua.BuildStatusLine()"
