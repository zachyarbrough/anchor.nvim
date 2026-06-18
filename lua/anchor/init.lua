
local M = {}

-- Path to the JSON file that handles directory mappings
-- Stored in `~/.local/share/nvim/anchor.json'
local data_path = vim.fn.stdpath('data') .. '/anchorejson'

local pickers = require('anchor.pickers')

local win = nil
local buf = nil

--- Closes the floating window and buffer
local function close_buf()
    if win ~= nil then
        local ok, err = pcall(vim.api.nvim_win_close, win, true)
	win = nil

	if not ok then
	    print(err)
	end
    end

    if buf ~= nil then
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
--- @param data table: The full table of anchored directories
local function save(data)
    local ok, encoded_data = pcall(vim.fn.json_encode, data)

    if not ok then
	return
    end

    vim.fn.writefile({ encoded_data }, data_path)
end

--- @param opts table: Table of options for configuration
M.setup = function(opts)
    opts = opts or {}

    M.config = {
	picker = opts.picker or 'auto', -- "fzf-lua", "telescope", "default", "oil", "mini", "snack" or "auto" default is netrw
	inputPicker = opts.inputPicker or 'default' -- Picker for input fields default is vim.ui.input()
    }

    vim.api.nvim_create_user_command('AnchorAdd', function()
	M.add()
    end, {
    desc = 'Attach an anchored directory to the cwd'
})

vim.api.nvim_create_user_command('AnchorDel', function(cmd_opts)
    M.del_dir(cmd_opts.args)
end, {
nargs= 1,
desc = 'Delete the anchored directory attached to the cwd'
    })

    vim.api.nvim_create_user_command('AnchorList', function()
	M.toggle_list()
    end, {
    desc = 'View a list of the anchored directories attached to the cwd'
})

vim.api.nvim_create_user_command('AnchorOpen', function(cmd_opts)
    M.open(cmd_opts.args)
end, {
nargs= 1,
desc = 'Open the selected anchored directory'
    })
end

--- Get the anchored directory associated with the cwd
--- @return string|nil: The stored anchored directory path 
M.load = function()
    local data = load()

    return data[vim.uv.cwd()]
end

--- Define an anchored directory for the cwd
--- @param dir string: Path to the anchored directory
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

    print(data[cur_dir])
end

--- Add directory based on user input
M.add = function()
    local dir = pickers.add(M.config.inputPicker)

    close_buf()
    if dir then M.add_dir(dir) end
end

--- Get the anchored directory associated with the cwd
M.del_dir = function(dir_idx)
    local data = load()

    local removed_dir = table.remove(data[vim.uv.cwd()], dir_idx)

    save(data)

    print("Removed directory: " .. removed_dir) -- Temporary print for testing until buffer is created 
end

M.toggle_list = function()
    local cur_dir = vim.uv.cwd()
    local data = load()

    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, "anchor://dirs")
    vim.api.nvim_set_option_value("buftype", "acwrite", { buf = buf })

    local width = 80
    local height = 15

    -- Selection Window configuration
    local win_opts = {
	relative = 'editor',
	width = width,
	height = height,
	row = math.floor((vim.o.lines - height) / 2),
	col = math.floor((vim.o.columns - width) / 2),
	style = 'minimal',
	border = 'rounded',
	title = 'Anchor',
	title_pos = 'center'
    }

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, data[cur_dir])

    win = vim.api.nvim_open_win(buf, true, win_opts)

    vim.api.nvim_create_autocmd("BufWriteCmd", {
	buffer = buf,
	callback = function()
	    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

	    local valid = {}
	    local invalid = {}

	    for _, line in ipairs(lines) do
		if line ~= "" then
		    local expanded = vim.fn.expand(line)
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

	    vim.api.nvim_set_option_value("modified", false, { buf = buf })
	end,
    })

    -- Close window with q or esc
    for _, key in ipairs({ "q", "<esc>" }) do
	vim.keymap.set("n", key, function()
	    close_buf()	end, { buffer = buf })
	end
    end

    --- Open an anchored directory with the index of the stored list
    --- @param idx_str string: The index of the anchored directory being opened
    M.open = function(idx_str)
	local cur_dir = vim.uv.cwd()
	local idx = tonumber(idx_str)

	local data = load()

	if data[cur_dir][idx] ~= nil then
	    M.open_dir(data[cur_dir][idx])
	end
    end


    --- Open an anchored directory
    --- @param dir string: The path of the anchored directory
    M.open_dir = function(dir)
	close_buf()
	pickers.open(dir, M.config.picker)
    end

    return M
