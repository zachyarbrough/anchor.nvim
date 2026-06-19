local M = {}

M.defaults = {
    picker = 'auto', -- 'fzf-lua', 'telescope', 'default', 'oil', 'mini', 'snack' or 'auto' (default = netrw)
    -- TODO: Make this a config option once more input options are added
    -- inputPicker = 'auto' -- Picker used when adding directories to the anchor list (default = vim.ui.input) 

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
