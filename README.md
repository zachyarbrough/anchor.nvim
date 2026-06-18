
<div align="center">
  
<h1>anchor.nvim</h1>

[![Lua](https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua)](http://www.lua.org)
[![Neovim](https://img.shields.io/badge/Neovim%200.9+-green.svg?style=for-the-badge&logo=neovim)](https://neovim.io)

[Installation](#installation) •  [Usage](#usage) • [Commands](#commands)
</div>

**Problem:** Do you constantly switch between directories while working? Need a familiar solution to quickly reference secondary directories like notes or related projects?

**Solution:** Use Anchor to quickly 'anchor' project-specific directories and navigate them with your fuzzy finder of choice!

### Installation
<details>
  <summary>vim.pack (Neovim 0.12+)</summary>
  
  ```lua
  vim.pack.add({ src = 'https://github.com/zachyarbrough/anchor.nvim' })
  ```
</details>

<details>
  <summary>lazy.nvim</summary>
  
  ```lua
  require('lazy').setup({
    {
        'zachyarbrough/anchor.nvim',
        opts = {},
    }
  })
  ```
</details>

<details>
  <summary>packer</summary>
  
  ```lua
  require('packer').startup(function()
    use({
      'zachyarbrough/anchor.nvim',
      config = function()
        require('anchor').setup()
      end,
    })
  end)
  ```
</details>

<details>
  <summary>paq</summary>
  
  ```lua
  require('paq')({
    { 'zachyarbrough/anchor.nvim' },
  })
  ```
</details>

<details>
  <summary>vim-plug</summary>
  
  ```lua
  Plug 'zachyarbrough/anchor.nvim'
  ```
</details>

### Usage

Recommended keymappings for quick start
```lua
local function anchor()
    return require('anchor')
end

vim.keymap.set('n', '<leader>al', function() anchor().toggle_list() end, { desc = 'Open anchor list in a floating window buffer' })
vim.keymap.set('n', '<leader>a0', function() anchor().return_to_cwd() end, { desc = 'Return back to cwd' })

vim.keymap.set('n', '<leader>a1', function() anchor().open(1) end, { desc = 'Open fuzzy finder for anchor 1' })
vim.keymap.set('n', '<leader>a2', function() anchor().open(2) end, { desc = 'Open fuzzy finder for anchor 2' })
vim.keymap.set('n', '<leader>a3', function() anchor().open(3) end, { desc = 'Open fuzzy finder for anchor 3' })
vim.keymap.set('n', '<leader>a4', function() anchor().open(4) end, { desc = 'Open fuzzy finder for anchor 4' })
vim.keymap.set('n', '<leader>a5', function() anchor().open(5) end, { desc = 'Open fuzzy finder for anchor 5' })
```

### Commands

| Command | Description |
|---------|-------------|
| `:AnchorAdd` | Add a directory to the anchor list |
| `:AnchorDel` | Remove a directory from the anchor list |
| `:AnchorList` | Open a temporary buffer to view your pinned directories|
| `:AnchorOpen <1-9>` | Open the fuzzy finder to navigate anchored directories at slots 1–9 (e.g. :`AnchorOpen 3`)|
| `:AnchorOpenDir <dir>` | Open the fuzzy finder to in the opened directory (e.g. `:AnchorOpenDir path/to/directory`|
