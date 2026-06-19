local M = {}

M.check = function()
    vim.health.start('anchor')
    -- Check config is initialized
    local anchor = require('anchor')
    if anchor.config then
	vim.health.ok('Plugin initialized')
    else
	vim.health.warn('Plugin not initialized - call require(\'anchor\').setup({})')
    end

    -- Check data file is readable/writeable
    local data_path = vim.fn.stdpath('data') .. '/anchor.json'
    if vim.fn.filereadable(data_path) == 1 then
	vim.health.ok('anchor.json found at ' .. data_path)
    else
	vim.health.info('anchor.json not yet created (will be created on first use)')
    end

    -- Check picker
    local picker = anchor.config and anchor.config.picker or 'not set'
    vim.health.info('Picker: ' .. picker)

    -- Check that the selected picker is actually available
    if picker == 'telescope' then
        local ok = pcall(require, 'telescope')
        if ok then vim.health.ok('telescope found') else vim.health.error('telescope not found') end
    elseif picker == 'fzf-lua' then
        local ok = pcall(require, 'fzf-lua')
        if ok then vim.health.ok('fzf-lua found') else vim.health.error('fzf-lua not found') end
    elseif picker == 'mini' then
	local ok = pcall(require, 'mini.pick')
	if ok then vim.health.ok('mini.pick found') else vim.health.error('mini.pick not found') end
    elseif picker == 'snack' then
	local ok = pcall(require, 'snack.picker')
	if ok then vim.health.ok('snack.picker found') else vim.health.error('snack.picker not found') end
    elseif picker == 'oil' then
	local ok = pcall(require, 'oil.nvim')
	if ok then vim.health.ok('oil.nvim found') else vim.health.error('oil.nvim not found') end
    end
end

return M

