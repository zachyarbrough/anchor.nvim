
local M = {}

local config = require('anchor.config')
local pickers = require('anchor.pickers')

-- Path to the JSON file that handles directory mappings
-- Stored in `~/.local/share/nvim/anchor.json'
local data_path = vim.fn.stdpath('data') .. '/anchor.json'

local win = nil
local buf = nil

M.origin = nil

--- Closes the floating window and buffer
local function close_buf()
    if win ~= nil and vim.api.nvim_win_is_valid(win) then
        local ok, err = pcall(vim.api.nvim_win_close, win, true)
	win = nil

	if not ok then
	    print(err)
	end
    end

    if buf ~= nil and vim.api.nvim_buf_is_valid(buf) then
	local ok, err = pcall(vim.api.nvim_buf_delete, buf, { force = true })
	buf = nil

	if not ok then
	    print(err)
	end

    end
end

--- Read and decode anchor.json
--- @return table: The decoded mapping of anchored directories
local function load()
    local ok, data = pcall(vim.fn.readfile, data_path)

    if not ok or not data then
	return {}
    end

    local decode_ok, decoded_data = pcall(vim.fn.json_decode, table.concat(data, '\n'))

    return decode_ok and decoded_data or {}
end

--- Encode and write the given table to anchor.json
--- @param data table The full table of anchored directories
local function save(data)
    local ok, encoded_data = pcall(vim.fn.json_encode, data)

    if not ok then
	return
    end

    vim.fn.writefile({ encoded_data }, data_path)
end

--- @param opts AnchorConfig Table of options for configuration
M.setup = function(opts)
    opts = opts or {}

    config.setup(opts)
end
--- Get the anchored directory associated with the cwd
--- @return string|nil The stored anchored directory path 
M.load = function()
    local data = load()

    return data[vim.uv.cwd()]
end

--- Define an anchored directory for the cwd
--- @param dir string Path to the anchored directory
M.add_dir = function(dir)
    local cur_dir = vim.uv.cwd()
    local data = load()

    -- Initialize the table for cur_dir if it doesn't exist yet
    if not data[cur_dir] then
	data[cur_dir] = {}
    end

    -- Add new directory to the current list
    table.insert(data[cur_dir], vim.fn.expand(dir))

    save(data)
end

--- Add directory based on user input
M.add = function()
    local dir = pickers.add(config.options.inputPicker)

    close_buf()
    if dir then M.add_dir(dir) end
end

--- Get the anchored directory associated with the cwd
--- @param dir string Path to the anchored directory
M.del_dir = function(dir)
    local data = load()
    local anchor_list = data[vim.uv.cwd()]

    for i = #anchor_list, 1, -1 do
	if anchor_list[i] == dir then
	    table.remove(anchor_list, i) -- Removes item and handles index shifting
	end
    end

    save(data)
end

M.delete = function()
    local cur_dir = vim.uv.cwd()
    local data = load()

    local dir = pickers.delete(data[cur_dir])

    if dir then M.del_dir(dir) end
end


M.toggle_buffer_overlay = function(data, editable)
    buf = vim.api.nvim_create_buf(false, true)

    vim.api.nvim_buf_set_name(buf, 'anchor://dirs')
    vim.api.nvim_set_option_value('buftype', 'acwrite', { buf = buf })
    -- Forces buffer to destroy itself to prevent duplicate buffers
    vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = buf })

    local wo = config.options.win_opts

    -- Selection Window configuration 
    local win_opts = {
	relative = 'editor',
	width = wo.width,
	height = wo.height,
	row = math.floor((vim.o.lines - wo.height) / 2),
	col = math.floor((vim.o.columns - wo.width) / 2),
	style = 'minimal',
	border = wo.border,
	title = wo.title,
	title_pos = 'center',
    }

    local buf_data = {}

    if editable then
    local cur_dir = vim.uv.cwd()
	buf_data = data[cur_dir] or {}
    else
	win_opts.title = 'Git Worktrees'
	buf_data = data
    end
    print(buf_data)

    -- Anchor list to display relative paths
    if config.options.relative_paths then
	for idx, abs_path in ipairs(buf_data) do
	    buf_data[idx] = vim.fn.fnamemodify(abs_path, ":~")
	end
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, buf_data)

    win = vim.api.nvim_open_win(buf, true, win_opts)

    vim.api.nvim_win_set_option(win, 'relativenumber', wo.numbers == 'relative')
    vim.api.nvim_win_set_option(win, 'number', wo.numbers == 'absolute')

    if editable then
	local cur_dir = vim.uv.cwd()

	vim.api.nvim_create_autocmd('BufWriteCmd', {
	    buffer = buf,
	    callback = function()
		local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

		local valid = {}
		local invalid = {}

		for _, line in ipairs(lines) do
		    if line ~= '' then
			local expanded = vim.fn.fnamemodify(vim.fn.expand(line), ":p")

			if vim.fn.isdirectory(expanded) == 1 then
			    table.insert(valid, expanded)
			else
			    table.insert(invalid, line)
			end
		    end
		end

		if #invalid > 0 then
		    vim.notify(
			'anchor.nvim: invalid directories removed:\n' .. table.concat(invalid, '\n'),
			vim.log.levels.WARN
		    )
		end

		data[cur_dir] = valid
		save(data)

		vim.api.nvim_set_option_value('modified', false, { buf = buf })
	    end,
	})
    end

    -- Open directory that the cursor is hovering over
    vim.keymap.set('n', '<CR>', function()
	local line = vim.api.nvim_get_current_line()
	local expanded_line = vim.fn.expand(line)
	if vim.fn.isdirectory(expanded_line) == 1 then
	    M.open_dir(expanded_line)
	end
    end, { buffer = buf })

    -- Close window with q or esc
    for _, key in ipairs({ 'q', '<esc>' }) do
	vim.keymap.set('n', key, function()
	    close_buf()
	end, { buffer = buf })
    end

end

--- Toggle the anchor list floating window
M.toggle_list = function()
    local data = load()

    M.toggle_buffer_overlay(data, true)
end

-- Toggle a list of worktrees
M.toggle_worktrees = function()
    vim.system({ "git", "worktree", "list", "--porcelain" }, { text = true }, function(out)
	if out.code ~= 0 then
	    vim.schedule(function()
		vim.notify("Not a git repository", vim.log.levels.WARN)
	    end)
	    return
	end

	local paths = {}

	for line in out.stdout:gmatch('[^\n]+') do
	    local path = line:match('^worktree (.+)$')
	    if path then
		table.insert(paths, path)
	    end
	end

	vim.schedule(function()
	    M.toggle_buffer_overlay(paths, false)
	end)
    end)
end


--- Return to the cwd after navigating anchored directories
--- Opens fuzzy finder of cwd if there is no active buffer
M.return_to_cwd = function()
    if not M.origin then
	return
    end

    vim.cmd.cd(vim.fn.fnameescape(M.origin.cwd))

    local filetype = vim.api.nvim_get_option_value("filetype", { buf = M.origin.buf })

    if vim.api.nvim_buf_is_valid(M.origin.buf) and filetype ~= '' then

	vim.api.nvim_set_current_buf(M.origin.buf)

	local ok = pcall(vim.api.nvim_win_set_cursor, 0, M.origin.cursor)
	if not ok then
	    M.open_dir(vim.uv.cwd())
	end
    else
	M.open_dir(vim.uv.cwd())
    end

    M.origin = nil
end

--- Open an anchored directory with the index of the stored list
--- @param dir_idx string The index of the anchored directory being opened
M.open = function(dir_idx)
    local idx = tonumber(dir_idx)

    --- Return to cwd
    if idx == 0 then
	M.return_to_cwd()
	return
    end

    local cur_dir = vim.uv.cwd()

    local data = load()

    if data[cur_dir][idx] ~= nil then
	M.open_dir(data[cur_dir][idx])
    end
end

--- Open an anchored directory
--- @param dir string The path of the anchored directory
M.open_dir = function(dir)
    close_buf()

    if M.origin == nil then
	local new_buf = vim.api.nvim_get_current_buf()
	local buf_name = vim.api.nvim_buf_get_name(new_buf)

	local cwd = vim.uv.cwd()

	if vim.startswith(buf_name, cwd) then
	    M.origin = {
		buf = new_buf,
		cursor = vim.api.nvim_win_get_cursor(0),
		cwd = cwd
	    }
	end
    end

    pickers.open(dir, config.options.picker)
end

require('anchor.cmd')

return M
