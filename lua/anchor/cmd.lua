
--- @class AnchorSubcmd 
--- @field impl fun(args?:string[], opts?: table) The command implementation
--- @field complete? fun(subcmd_arg_lead: string): string[] (optional) Command completions callback, taking the lead of the subcmd's arguments

--- @class AnchorCmdOpts
--- @field fargs table: A list of command arguments. `fargs[1] must be the subcommand name

--- @type table<string, AnchorSubcmd>
local subcmd_tbl = {
    add = {
        impl = function()
	    require('anchor').add()
        end,
    },
    delete = {
        impl = function()
	    require('anchor').delete()
        end,
    },
    list = {
        impl = function()
	    require('anchor').toggle_list()
        end,
    },
    open = {
        impl = function(args)
	    require('anchor').open(args[1])
        end,
    },
    grep = {
        impl = function(args)
	    require('anchor').grep(args[1])
        end,
    },
    worktrees = {
        impl = function()
	    require('anchor').toggle_worktrees()
        end,
    },

}

--- Dispatches an anchor subcommand based on user input
--- @param opts AnchorCmdOpts The context table returned by the Anchor user command
local function anchor_cmd(opts)
    local fargs = opts.fargs
    local subcmd_key = fargs[1]

    local args = #fargs > 1 and vim.list_slice(fargs, 2, #fargs) or {}
    local subcmd = subcmd_tbl[subcmd_key]

    if not subcmd then
	vim.notify('anchor: unknown command: ' .. subcmd_key, vim.log.levels.ERROR)
	return
    end

    subcmd.impl(args, opts)
end

--- Generate command-line auto-completion suggestions for Anchor subcommands
--- @param arg_lead string The leading text of the current argument
--- @param cmdline string The entire command line text
--- @param _ number The cursor position byte offset (unused)
--- @return string[]: A list of matching subcommand keys the command line can display to the user 
local function anchor_complete(arg_lead, cmdline, _)
    if cmdline:match("^['<,'>]*Anchor[!]*%s+%w*$") then
	-- Filter subcmds that match
	local subcmd_keys = vim.tbl_keys(subcmd_tbl)
	return vim.iter(subcmd_keys)
	:filter(function(key)
	    return key:find(arg_lead) ~= nil
	end)
	:totable()
    end

    return {}
end

--- Registers the Anchor command and can be called with `:Anchor`
vim.api.nvim_create_user_command('Anchor', anchor_cmd, {
    nargs = '+',
    desc = 'Manage anchor directories',
    complete = anchor_complete
})
