if vim.g.loaded_anchor then return end
vim.g.loaded_anchor = true

local config = require('anchor.config')
local anchor = require('anchor')

if next(config.options) == nil then
    anchor.setup({})
end
