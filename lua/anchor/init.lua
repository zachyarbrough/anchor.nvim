local M = {}

-- Path to the JSON file that handles directory mappings
-- Stored in `~/.local/share/nvim/anchor.json'
local data_path = vim.fn.stdpath('data') .. '/anchorejson'

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

    vim.api.nvim_create_user_command('AnchorAddDir', function(cmd_opts)
	M.add_dir(cmd_opts.args)
    end, {
	nargs= 1,
	desc = 'Attach an anchored directory to the cwd'
    })

    vim.api.nvim_create_user_command('AnchorDelDir', function(cmd_opts)
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

    local buf = vim.api.nvim_create_buf(false, true)

    local width = 60
    local height = 15

    local win_opts = {
	relative = 'editor',
	width = width,
	height = height,
	row = math.floor((vim.o.lines - height) / 2),
	col = math.floor((vim.o.columns - width) / 2),
	style = 'minimal',
	border = 'rounded',
    }

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, data[cur_dir])

    local win = vim.api.nvim_open_win(buf, true, win_opts)

    -- Close window with q or esc
    for _, key in ipairs({ "q", "<esc>" }) do
    vim.keymap.set("n", key, function()
        vim.api.nvim_win_close(win, true)
    end, { buffer = buf })
end
end

return M
