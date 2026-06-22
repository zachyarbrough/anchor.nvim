
<div align="center">
  
<h1>:anchor: anchor.nvim :anchor:</h1>

[![Lua](https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua)](http://www.lua.org)
[![Neovim](https://img.shields.io/badge/Neovim%200.9+-green.svg?style=for-the-badge&logo=neovim)](https://neovim.io)

[Installation](#installation) •  [Usage](#usage) • [Configuration](#configuration) • [Commands](#commands)

<img width="1300" height="1000" alt="anchor-demo" src="https://github.com/user-attachments/assets/6a5fb249-85b4-45df-8c9f-2a5610cfe4c5" />

</div>

\
Pin project-specific directories and navigate them with your fuzzy finder. Perfect for jumping between notes, related repos, or git worktrees without losing context.

## Installation
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

## Usage
The following keymaps provide a good starting point. Feel free to customize them to fit your workflow.
```lua
local function anchor()
    return require('anchor')
end

vim.keymap.set('n', '<leader>aa', function() anchor().add() end, { desc = 'Add a directory to the anchor list' })
vim.keymap.set('n', '<leader>ad', function() anchor().delete() end, { desc = 'Delete a directory from the anchor list' })
vim.keymap.set('n', '<leader>al', function() anchor().toggle_list() end, { desc = 'Open anchor list in a floating buffer' })
vim.keymap.set('n', '<leader>a0', function() anchor().return_to_cwd() end, { desc = 'Return back to cwd' })

vim.keymap.set('n', '<leader>a1', function() anchor().open(1) end, { desc = 'Open fuzzy finder for anchor 1' })
vim.keymap.set('n', '<leader>a2', function() anchor().open(2) end, { desc = 'Open fuzzy finder for anchor 2' })
vim.keymap.set('n', '<leader>a3', function() anchor().open(3) end, { desc = 'Open fuzzy finder for anchor 3' })
vim.keymap.set('n', '<leader>a4', function() anchor().open(4) end, { desc = 'Open fuzzy finder for anchor 4' })
vim.keymap.set('n', '<leader>a5', function() anchor().open(5) end, { desc = 'Open fuzzy finder for anchor 5' })
```
If you use git worktrees, Anchor includes a dedicated worktree picker so you can quickly search other worktrees.
```lua
vim.keymap.set('n', '<leader>gw', function() anchor().toggle_worktrees() end, { desc = 'Open git worktrees in a floating buffer' })
```

## Configuration
>[!NOTE]
> `exclude_dirs` and `extended_excluded_dirs` only work for fuzzy finders, if `picker` is set to 'oil' or 'default' then these options will be ignored.
```lua
require('anchor').setup({
    -- UI options for anchor list buffer
    winopts = {
    	width = 80,
    	height = 15,
    	border = 'rounded',
    	title = 'Anchor',
	    numbers = 'absolute' -- 'absolute', 'relative', 'none'
    },
    picker = 'auto',        -- 'fzf-lua', 'telescope', 'default' (netrw), 'oil', 'mini', 'snack' or 'auto'
    relative_paths = true, -- Display relative paths in the anchor list

    excluded_dirs = { '.git', '.cache' }, -- Directories to exclude in fuzzy finder search
    extended_excluded_dirs = { },         -- User specific directories to exclude in fuzzy finder search
})
```

## Commands

| Command | Description |
|---------|-------------|
| `:Anchor add` | Add a directory to the anchor list |
| `:Anchor delete` | Remove a directory from the anchor list |
| `:Anchor list` | Open the anchor list in a floating buffer |
| `:Anchor open 0` | Return to the working cwd |
| `:Anchor open {1-9}` | Open the fuzzy finder to navigate anchored directories at slots 1–9 (e.g. :`Anchor open 3`) |
| `:Anchor worktrees` | Open the git worktrees picker |
