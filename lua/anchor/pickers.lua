
local M = {}

----------------------------------
-- Error Handling
-----------------------------------
--- Throws an error when the picker is not found
--- @param picker string: 'fzf-lua', 'telescope', 'netrw'
local function picker_not_found(picker)
    vim.notify(
        'anchor.nvim: picker "' .. picker .. '" is not installed',
        vim.log.levels.ERROR
    )
end
-----------------------------------

--- Open a directory to search through
--- @param dir string: The path to the anchored directory
--- @param picker string: The picker opt (fzf-lua, telescope, netrw, oil, mini, snacks, auto)
M.open = function(dir, picker)
    local expanded_dir = vim.fn.expand(dir)

    -- Check if user has fzf-lua installed
    local has_fzf, fzf = pcall(require, 'fzf-lua')
    if (picker == 'fzf-lua' or picker == 'auto') and has_fzf then
	fzf.files({ cwd = expanded_dir })
	return
    elseif not has_fzf then
	picker_not_found(picker)
    end

    -- Check if user has telescope installed
    local has_telescope, telescope = pcall(require, "telescope.builtin")
    if (picker == 'telescope' or picker == 'auto') and has_telescope then
        telescope.find_files({ cwd = expanded_dir })
        return
    elseif not has_telescope then
	picker_not_found(picker)
    end

    -- Check if user has snacks.picker installed
    local has_snacks, snacks = pcall(require, 'snacks')
    if (picker == 'snacks' or picker == 'auto') and has_snacks then
	snacks.picker.files({ cwd = expanded_dir })
	return
    end

    -- Check if user has mini.pick installed
    local has_mini, mini = pcall(require, 'mini.pick')
    if (picker == 'mini.pick' or picker == 'auto') and has_mini then
	mini.builtin.files({ source = { cwd = expanded_dir } })
	return
    end

    -- Check if user has oil.nvim installed
    local has_oil, oil = pcall(require, 'oil')
    if (picker == 'oil' or picker == 'auto') and has_oil then
	oil.open(expanded_dir)
	return
    end

    vim.cmd('Ex ' .. expanded_dir)
end

return M
