
--- @class AnchorConfig
--- @field picker? 'auto'|'fzf-lua'|'telescope'|'oil'|'mini'|'snacks'|'default' The active fuzzy-finder picker (default: 'auto').
--- @field relative_paths? boolean if enabled, the anchor list will only show the relative path in the buffer
--- @field excluded_dirs? string[] Paths permanently excluded from fuzzy search. (Ignored by 'oil'/'default').
--- @field extended_excluded_dirs? string[] Extra path exemptions to append onto default exclusions.
--- @field win_opts? { width?: number, height?: number, border?: string, title?: string, numbers?: 'absolute'|'relative'|'none' }

local M = {}

--- @type AnchorConfig
M.defaults = {
    -- UI for anchor list floating window
    win_opts = {
	width = 80,
	height = 15,
	border = 'rounded',
	title = 'Anchor',
	numbers = 'absolute', -- 'absolute', 'relative', 'none'
    },
    picker = 'auto', -- 'fzf-lua', 'telescope', 'default', 'oil', 'mini', 'snack' or 'auto' (default = netrw)
    relative_paths = true, -- Display relative paths in the anchor list

    -- excluded_dirs and extended_excluded_dirs are only used when picker is 'fzf-lua', 'telescope', 'mini', or 'snacks'
    -- They have no effect when using 'oil' or 'default' 
    excluded_dirs = { '.git', '.cache' }, -- Directories to exclude in fuzzy finder search
    extended_excluded_dirs = { }, -- User specific directories to exclude in fuzzy finder search
}

M.options = {}

--- Initialize configuration by merging default options with user overrides
--- @param opts? AnchorConfig Optional user configuration overrides
function M.setup(opts)
    M.options = vim.tbl_deep_extend('force', M.defaults, opts or {})
    vim.list_extend(M.options.excluded_dirs, M.options.extended_excluded_dirs)
end

return M
