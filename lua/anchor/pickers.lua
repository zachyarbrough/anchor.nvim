
local M = {}

----------------------------------
-- Error Handling
-----------------------------------

--- Throw an error when the picker is not found
--- @param picker string: 'fzf', 'telescope', 'default', oil, mini, snacks, auto
local function picker_not_found(picker)
    vim.notify(
        'anchor: picker \'' .. picker .. '\' is not installed',
        vim.log.levels.ERROR
    )
end

--- Throw an error when the user's input is not a directory 
--- @param dir string: Directory input being searched 
local function dir_not_found(dir)
    vim.notify(
        'anchor: \'' .. dir .. '\' directory not found',
        vim.log.levels.ERROR
    )
end
-----------------------------------
--- Plugin Integrations
-----------------------------------

--- Integration for fzf-lua 
--- @param picker string: Selected picker option
--- @param dir? string: Directory to open
M.fzf = function(picker, dir)
    local has_fzf, fzf = pcall(require, 'fzf-lua')
    if has_fzf then
	-- Handle search functionality
	if dir ~= nil then
	    fzf.files({ cwd = dir })
	return
	else
	    -- TODO: Handle input functionality
	end
    elseif picker ~= 'auto' then
	picker_not_found('fzf-lua')
    end
end

--- Integration for telescope 
--- @param picker string: Selected picker option
--- @param dir? string: Directory to open
M.telescope = function(picker, dir)
    local has_telescope, telescope = pcall(require, "telescope.builtin")
    if has_telescope then
	if dir ~= nil then
	    -- Handle search functionality
	    telescope.find_files({ cwd = dir })
	    return
	else
	    -- TODO: Handle input functionality
	end
    elseif picker ~= 'auto' then
	picker_not_found('telescope')
    end
end

--- Integration for mini.pick
--- @param picker string: Selected picker option
--- @param dir? string: Directory to open
M.mini = function(picker, dir)
    local has_mini, mini = pcall(require, 'mini.pick')
    if has_mini then
	if dir ~= nil then
	    -- Handle search functionality
	    mini.builtin.files({ source = { cwd = dir } })
	    return
	else
	    -- TODO: Handle input functionality
	end
    elseif picker ~= 'auto' then
	picker_not_found('mini.pick')
    end
end

-- Integration for snacks.picker
--- @param picker string: Selected picker option
--- @param dir? string: Directory to open
M.snacks = function(picker, dir)
    local has_snacks, snacks = pcall(require, 'snacks')
    if has_snacks then
	if dir ~= nil then
	    -- Handle search functionality
	    snacks.picker.files({ cwd = dir })
	    return
	else
	    -- TODO: Handle input functionality 
	end
    elseif picker ~= 'auto' then
	picker_not_found('snacks.picker')
    end
end

--- Integration for oil.nvim
--- @param picker string: Selected picker option
--- @param dir string: Directory to open
M.oil = function(picker, dir)
    local has_oil, oil = pcall(require, 'oil')
    if has_oil and dir ~= nil then
	oil.open(dir)
	return
    elseif picker ~= 'auto' then
	picker_not_found('oil.nvim')
    end
end
-----------------------------------

--- Add a directory to the Anchor List 
--- @param picker string: The picker opt (fzf, telescope, default, mini, snacks, auto)
M.add = function(picker)
    local dir = nil

    if picker == 'fzf' or picker == 'auto' then dir = M.fzf(picker) end
    if picker == 'telescope' or picker == 'auto' then dir = M.telescope(picker) end
    if picker == 'mini' or picker == 'auto' then dir = M.mini(picker) end
    if picker == 'snacks' or picker == 'auto' then dir = M.snacks(picker) end

    local input_opts = {
	prompt = 'Enter Directory to Add: ',
	completion = 'dir'
    }

    vim.ui.input(input_opts, function(input)
	if input == nil then
	    return
	end

	local expanded_dir = vim.fn.expand(input)

	if vim.fn.isdirectory(expanded_dir) == 1 then
	    dir = input
	else
	    dir_not_found(expanded_dir)
	end
    end)

    return dir
end

--- Open a directory to search through
--- @param dir string: The path to the anchored directory
--- @param picker string: The picker opt (fzf, telescope, default, oil, mini, snacks, auto)
M.open = function(dir, picker)
    local expanded_dir = vim.fn.expand(dir)

    if picker == 'fzf' or picker == 'auto' then return M.fzf(picker, expanded_dir) end
    if picker == 'telescope' or picker == 'auto' then return M.telescope(picker, expanded_dir) end
    if picker == 'mini' or picker == 'auto' then return M.mini(picker, expanded_dir) end
    if picker == 'snacks' or picker == 'auto' then return M.snacks(picker, expanded_dir) end
    if picker == 'oil' or picker == 'auto' then return M.oil(picker, expanded_dir) end

    vim.cmd('Ex ' .. expanded_dir)
end

return M
