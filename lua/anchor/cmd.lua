
---@class AnchorSubcmd 
---@field impl fun(args:string[], opts: table) The command implementation
---@field complete? fun(subcmd_arg_lead: string): string[] (optional) Command completions callback, taking the lead of the subcmd's arguments

---@type table<string, AnchorSubcmd>
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
	    require('anchor').open(args[2])
        end,
    },
}

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

vim.api.nvim_create_user_command('Anchor', anchor_cmd, {
    nargs = '+',
    desc = 'Manage anchor directories',
    complete = function(arg_lead, cmdline, _)
	if cmdline:match("^['<,'>]*Anchor[!]*%s+%w*$") then
            -- Filter subcmds that match
            local subcmd_keys = vim.tbl_keys(subcmd_tbl)
            return vim.iter(subcmd_keys)
                :filter(function(key)
                    return key:find(arg_lead) ~= nil
                end)
                :totable()
        end
    end,
})
