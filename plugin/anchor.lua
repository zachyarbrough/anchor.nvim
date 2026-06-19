if vim.g.loaded_anchor then return end
vim.g.loaded_anchor = true

local anchor = require('anchor')

if not anchor.config then
    anchor.setup({})
end
