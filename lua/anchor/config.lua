local M = {}

M.defaults = {
    -- UI for anchor list floating window
    win_opts = {
	width = 80,
	height = 15,
	border = 'rounded',
	title = 'Anchor',
	numbers = 'absolute' -- 'absolute', 'relative', 'none'
    },
    picker = 'auto', -- 'fzf-lua', 'telescope', 'default', 'oil', 'mini', 'snack' or 'auto' (default = netrw)

    -- excluded_dirs and extended_excluded_dirs are only used when picker is 'fzf-lua', 'telescope', 'mini', or 'snacks'
    -- They have no effect when using 'oil' or 'default' 
    excluded_dirs = { '.git', '.cache' }, -- Directories to exclude in fuzzy finder search
    extended_excluded_dirs = { }, -- User specific directories to exclude in fuzzy finder search
}

M.options = {}

function M.setup(opts)
    M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
    vim.list_extend(M.options.excluded_dirs, M.options.extended_excluded_dirs)
end

return M
