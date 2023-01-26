local autocmd = vim.api.nvim_create_autocmd
local augroup = function(name)
    return vim.api.nvim_create_augroup(name, { clear = true })
end
local M = {}

local options = {
    exclude = {},
    debug = false,
}

local function is_excluded(bufname, cwd)
    for _, val in pairs(options.exclude) do
        if string.sub(bufname, 1, string.len(val)) == val then
            return true
        end
    end
    return string.sub(bufname, 1, string.len(cwd)) == cwd
end

function M.setup(opts)
    options = vim.tbl_deep_extend('force', options, opts or {})
    local group = augroup('Gatekeeper.nvim')
    autocmd({ 'BufReadPost' }, {
        desc = 'Make files readonly when outside of current working dir',
        pattern = '*',
        group = group,
        callback = function()
            if not is_excluded(vim.api.nvim_buf_get_name(0), vim.fn.getcwd()) then
                if options.debug then
                    vim.notify(
                        'Buffer '
                            .. vim.api.nvim_buf_get_name(0)
                            .. ' is being blocked from being edited. \n CWD: '
                            .. vim.fn.getcwd()
                    )
                end
                vim.bo.readonly = true
                vim.bo.modifiable = false
            elseif options.debug then
                vim.notify(
                    'Buffer '
                        .. vim.api.nvim_buf_get_name(0)
                        .. ' is not being blocked from being edited. \n CWD: '
                        .. vim.fn.getcwd()
                )
            end
        end,
    })
    vim.api.nvim_create_user_command('GTForceWrite', function()
        vim.bo.readonly = false
        vim.bo.modifiable = true
    end, { desc = 'Sets current buffer to be writable and modifiable' })
end

return M
