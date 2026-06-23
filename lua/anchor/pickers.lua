
local M = {}

local config = require('anchor.config')

--- Throw an error when the picker is not found
--- @param picker string The user configured picker, used to determine if error should be thrown on missing plugin
local function picker_not_found(picker)
    vim.notify(
        'anchor: picker \'' .. picker .. '\' is not installed',
        vim.log.levels.ERROR
    )
end

--- Throw an error when the user's input is not a directory 
--- @param dir string Directory input being searched 
local function dir_not_found(dir)
    vim.notify(
        'anchor: \'' .. dir .. '\' directory not found',
        vim.log.levels.ERROR
    )
end

--- Builds a shell command for finding files that excludes directories defined in config
--- @return string: shell command for finding files
local function build_find_cmd()
    local has_fd = vim.fn.executable('fd') == 1

    local cmd = ''
    if has_fd then
        cmd = "fd --type f"
        for _, excluded_dir in ipairs(config.options.excluded_dirs) do
            cmd = cmd .. " --exclude " .. excluded_dir
        end
    else
        cmd = "find . -type f"
        for _, excluded_dir in ipairs(config.options.excluded_dirs) do
            cmd = cmd .. " -not -path '*/" .. excluded_dir .. "/*'"
        end
	-- Removes leading . from file paths
        cmd = cmd .. " | sed 's|^./||'"
    end

    return cmd
end

--- Integration for fzf-lua 
--- @param picker string Selected picker option
--- @param dir? string Directory to open
--- @param grep? boolean Grep directory if true
M.fzf = function(picker, dir, grep)
    local has_fzf, fzf = pcall(require, 'fzf-lua')
    if has_fzf then
	-- Handle search functionality
	if dir ~= nil then
	    if grep ~= nil then
		fzf.live_grep(vim.tbl_extend('force', config.options.picker_opts.grep, {
		    cwd = dir,
		}))
		return
	    end
	    fzf.live_grep(vim.tbl_extend('force', config.options.picker_opts.files, {
		cwd = dir,
		cmd = build_find_cmd(),
	    }))
	    return
	end
    elseif picker ~= 'auto' then
	picker_not_found('fzf-lua')
    end
end

--- Integration for telescope 
--- @param picker string Selected picker option
--- @param dir? string Directory to open
--- @param grep? boolean Grep directory if true
M.telescope = function(picker, dir, grep)
    local has_telescope, telescope = pcall(require, 'telescope.builtin')
    if has_telescope then
	-- Handle search functionality
	if dir ~= nil then
	    -- becomes: { '.git/', 'node_modules/' }
	    local patterns = {}
	    for _, excluded_dir in ipairs(config.options.excluded_dirs) do
		table.insert(patterns, excluded_dir .. '/')
	    end
	    if grep ~= nil then
		telescope.live_grep(vim.tbl_extend('force', config.options.picker_opts.grep, {
		    cwd = dir,
		}))
		return
	    end
	    telescope.find_files(vim.tbl_extend('force', config.options.picker_opts.files, {
		    cwd = dir,
		    file_ignore_patterns = patterns
		}))
	    return
	end
    elseif picker ~= 'auto' then
	picker_not_found('telescope')
    end
end

--- Integration for mini.pick
--- @param picker string Selected picker option
--- @param dir? string Directory to open
M.mini = function(picker, dir)
    local has_mini, mini = pcall(require, 'mini.pick')
    if has_mini then
	-- Handle search functionality
	if dir ~= nil then
	    mini.builtin.cli(
		{ command = { 'sh', '-c', build_find_cmd() } },
		{ source = { cwd = dir } }
	    )
	    return
	end
    elseif picker ~= 'auto' then
	picker_not_found('mini.pick')
    end
end

-- Integration for snacks.picker
--- @param picker string Selected picker option
--- @param dir? string Directory to open
M.snacks = function(picker, dir)
    local has_snacks, snacks = pcall(require, 'snacks')
    if has_snacks then
	-- Handle search functionality
	if dir ~= nil then
	    snacks.picker.files({ cwd = dir, exclude = config.options.excluded_dirs })
	    return
	end
    elseif picker ~= 'auto' then
	picker_not_found('snacks.picker')
    end
end

--- Integration for oil.nvim
--- @param picker string Selected picker option
--- @param dir string Directory to open
M.oil = function(picker, dir)
    local has_oil, oil = pcall(require, 'oil')
    if has_oil and dir ~= nil then
	oil.open(dir)
	return
    elseif picker ~= 'auto' then
	picker_not_found('oil.nvim')
    end
end

--- Add a directory to the Anchor List 
--- @param picker string The picker opt (fzf-lua, telescope, default, mini, snacks, auto)
--- @return string|nil: directory that was added
M.add = function(picker)
    local dir = nil

    if picker == 'fzf' or picker == 'auto' then dir = M.fzf(picker) end
    if picker == 'telescope' or picker == 'auto' then dir = M.telescope(picker) end
    if picker == 'mini' or picker == 'auto' then dir = M.mini(picker) end
    if picker == 'snacks' or picker == 'auto' then dir = M.snacks(picker) end

    local input_opts = {
	prompt = 'Add Anchor: ',
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


--- Delete a directory in the Anchor List 
--- @param anchor_list table a table of anchor directories for auto completion
M.delete = function(anchor_list)
    local dir = nil

    -- Generate completion for current anchor list
    _G.anchor_list_completion = function(arg_lead, _, _)
	-- Filter items based on what the user has already typed (arg_lead)
	local matches = {}
	for _, item in ipairs(anchor_list) do
	    if item:find("^" .. arg_lead) then
		table.insert(matches, item)
	    end
	end
	return matches
    end

    local input_opts = {
	prompt = 'Delete Anchor: ',
	completion = 'customlist,v:lua.anchor_list_completion'
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
--- @param dir string The path to the anchored directory
--- @param picker string The picker opt (fzf, telescope, default, oil, mini, snacks, auto)
--- @param grep? boolean Enable fuzzy grep if applicable
M.open = function(dir, picker, grep)
    local expanded_dir = vim.fn.expand(dir)

    if picker == 'fzf' or picker == 'auto' then return M.fzf(picker, expanded_dir, grep) end
    if picker == 'telescope' or picker == 'auto' then return M.telescope(picker, expanded_dir) end
    if picker == 'mini' or picker == 'auto' then return M.mini(picker, expanded_dir) end
    if picker == 'snacks' or picker == 'auto' then return M.snacks(picker, expanded_dir) end
    if picker == 'oil' or picker == 'auto' then return M.oil(picker, expanded_dir) end

    vim.cmd('Ex ' .. expanded_dir)
end

--- Open a directory to search through
--- @param dir string The path to the anchored directory
--- @param picker string The picker opt (fzf, telescope, default, oil, mini, snacks, auto)
M.grep = function(dir, picker)
    local expanded_dir = vim.fn.expand(dir)

    if picker == 'fzf' or picker == 'auto' then return M.fzf(picker, expanded_dir, true) end
    if picker == 'telescope' or picker == 'auto' then return M.telescope(picker, expanded_dir) end
    if picker == 'mini' or picker == 'auto' then return M.mini(picker, expanded_dir) end
    if picker == 'snacks' or picker == 'auto' then return M.snacks(picker, expanded_dir) end
    if picker == 'oil' or picker == 'auto' then return M.oil(picker, expanded_dir) end

    vim.cmd('Ex ' .. expanded_dir)
end



return M
