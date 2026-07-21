
<div align="center">
  
<h1>:anchor: anchor.nvim :anchor:</h1>

[![Lua](https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua)](http://www.lua.org)
[![Neovim](https://img.shields.io/badge/Neovim%200.9+-green.svg?style=for-the-badge&logo=neovim)](https://neovim.io)

[Installation](#installation) •  [Usage](#usage) • [Configuration](#configuration) • [Commands](#commands)

<img width="1300" height="1000" alt="anchor-demo" src="https://github.com/user-attachments/assets/6a5fb249-85b4-45df-8c9f-2a5610cfe4c5" />

</div>

\
Harpoon for Directories! Anchor lets you bookmark directories instead of files, making it easy to jump between related repositories, notes, dotfiles, and git worktrees using your favorite fuzzy finder.
## Installation
> [!TIP]
> Run `:checkhealth anchor` after installation to ensure that the plugin has loaded correctly.
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
...
vim.keymap.set('n', '<leader>a5', function() anchor().open(5) end, { desc = 'Open fuzzy finder for anchor 5' })
```

If the selected picker supports grepping files, you can live grep the anchored directory with the below keymaps. (Currently supports `fzf-lua`, `telescope`, `mini.picks`, and `snacks.picker`)
```lua
vim.keymap.set('n', '<leader>ag1', function() anchor().grep(1) end, { desc = 'Open fuzzy finder with live grep for anchor 1' })
...
vim.keymap.set('n', '<leader>ag5', function() anchor().grep(5) end, { desc = 'Open fuzzy finder with live grep for anchor 5' })
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
    -- UI options for fuzzy finder (currently only supported by fzf-lua and telescope)
    picker_opts = {
        grep = {}, -- UI Options for live grep
        files = {} -- UI Options for file search
    },
    picker = 'auto',        -- 'fzf-lua', 'telescope', 'default' (netrw), 'oil', 'mini', 'snack' or 'auto'
    relative_paths = true, -- Display relative paths in the anchor list

    show_branches = true, -- Show branch names when viewing git worktrees

    excluded_dirs = { '.git', '.cache' }, -- Directories to exclude in fuzzy finder search
    extended_excluded_dirs = { },         -- User specific directories to exclude in fuzzy finder search
})
```

## Commands

| Command | Description |
|---------|-------------|
| `:Anchor add` | Add a directory to the anchor list. |
| `:Anchor delete` | Remove a directory from the anchor list. |
| `:Anchor list` | Open the anchor list in a floating buffer. |
| `:Anchor open 0` | Return to the working cwd. |
| `:Anchor open {1-9}` | Open the fuzzy finder to navigate anchored directories at slots 1–9. (e.g. :`Anchor open 3`) |
| `:Anchor grep {1-9}` | Open the fuzzy finder with live grep to search through anchored directories at slots 1–9. (e.g. :`Anchor grep 3`) Currently only supported by fzf-lua and telescope. |
| `:Anchor worktrees` | Open the git worktrees picker. |
