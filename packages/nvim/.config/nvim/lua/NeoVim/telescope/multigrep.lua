local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local conf = require("telescope.config").values
local action_state = require("telescope.actions.state")

local M = {}

local live_multigrep = function()
    local include_ignored = false
    local function prompt_title()
        return "Multi Grep · ignorados: " .. (include_ignored and "sim" or "não") .. " · <C-i> alterna"
    end

    local opts = require("telescope.themes").get_ivy({
        cwd = vim.uv.cwd(),
    })

    local finder = finders.new_async_job({
        command_generator = function(prompt)
            if not prompt or prompt == "" then
                return nil
            end

            local pieces = vim.split(prompt, "  ")
            local args = { "rg" }

            if include_ignored then
                table.insert(args, "--no-ignore")
            end

            if pieces[1] then
                table.insert(args, "-e")
                table.insert(args, pieces[1])
            end

            if pieces[2] then
                table.insert(args, "-g")
                table.insert(args, pieces[2])
            end

            return vim.iter({
                args,
                {
                    "--color=never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column",
                    "--smart-case",
                    "--hidden",
                    "--glob",
                    "!.git",
                },
            })
                :flatten()
                :totable()
        end,
        entry_maker = make_entry.gen_from_vimgrep(opts),
        cwd = opts.cwd,
    })

    pickers
        .new(opts, {
            debounce = 100,
            prompt_title = prompt_title(),
            finder = finder,
            previewer = conf.grep_previewer(opts),
            sorter = require("telescope.sorters").empty(),
            attach_mappings = function(prompt_bufnr, map)
                local function toggle_ignored()
                    include_ignored = not include_ignored
                    local picker = action_state.get_current_picker(prompt_bufnr)
                    picker.prompt_title = prompt_title()
                    picker.layout.prompt.border:change_title(picker.prompt_title)
                    picker:refresh()
                end

                map("i", "<C-i>", toggle_ignored)
                map("n", "<C-i>", toggle_ignored)
                return true
            end,
        })
        :find()
end

M.setup = function()
    vim.keymap.set("n", "<leader>pm", live_multigrep)
end

return M
