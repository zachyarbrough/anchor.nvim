<div align="center">

<h1>Anchor</h1>

[![Lua](https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua)](http://www.lua.org)
[![Neovim](https://img.shields.io/badge/Neovim%200.9+-green.svg?style=for-the-badge&logo=neovim)](https://neovim.io)

[Installation](#installation) - [Usage](#usage) - [Commands](#commands)
</div>

> **Problem:** Do you constantly switch between directories while working? Need a familiar solution to quickly reference secondary directories like notes or related projects?
>
> **Solution:** Use Anchor to quickly pin project-specific directories and navigate them with your fuzzy finder of choice!

### Installation
-- TODO
### Usage

Recommended keymappings for quick start

| Key | Description |
|-----|-------------|
| `<leader>aa` | Add Directory |
| `<leader>ad` | Delete Open Directory |
| `<leader>a0` | Return to current working directory when navigating an anchor directory |
| `<leader>a(1-5)` | Quick select directories 1-5 for fuzzy search |

### Commands

| Command | Description |
|---------|-------------|
| `:AnchorAdd` | Add a directory to the anchor list |
| `:AnchorDel` | Remove a directory from the anchor list |
| `:AnchorList` | Open a temporary buffer to view your pinned directories|
| `:AnchorOpen <1-5>` | Open the fuzzy finder to navigate anchored
| `:AnchorOpenDir <dir>` | Open the fuzzy finder to in the opened directory 
