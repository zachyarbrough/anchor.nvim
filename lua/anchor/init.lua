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

    vim.api.nvim_create_user_command('AnchorSetDir', function(cmd_opts)
	M.set_dir(cmd_opts.args)
    end, {
	nargs= 1,
	desc = 'Set the anchored directory for the current project'
    })

    vim.api.nvim_create_user_command('AnchorGetDir', function()
	M.get_dir()
    end, {
	desc = 'Get the anchored directory for the current working directory'
    })

end

--- Get the anchored directory associated with the current working directory
--- @return string|nil: The stored anchored directory path 
M.load = function()
    local data = load()

    return data[vim.fn.getcwd()]
end

--- Define an anchored directory for the current working directory
--- @param dir string: Path to the anchored directory
M.set_dir = function(dir)
    local data = load()

    data[vim.fn.getcwd()] = vim.fn.expand(dir)

    save(data)
end

--- Get the anchored directory associated with the current working directory
M.get_dir = function()
    local data = load()

    local dir = data[vim.fn.getcwd()]

    print(dir) -- Temporary until there is a better way of displaying

    return dir
end

return M
