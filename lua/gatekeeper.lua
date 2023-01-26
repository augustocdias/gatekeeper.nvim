local autocmd = vim.api.nvim_create_autocmd
local augroup = function(name)
    return vim.api.nvim_create_augroup(name, { clear = true })
end
local M = {}

local options = {
    exclude = {},
    exclude_regex = {},
    debug = false,
}

local function is_excluded(bufname, cwd, should_log)
    local should_log = should_log or false
    for _, val in pairs(options.exclude) do
        local will_exclude = string.sub(bufname, 1, string.len(val)) == val
        if should_log then
            print('Checking ' .. bufname .. ' against ' .. val .. ': ' .. (will_exclude and 'yes' or 'no'))
        end
        if will_exclude then
            return true
        end
    end
    for _, val in pairs(options.exclude_regex) do
        local will_exclude = string.match(bufname, val)
        if should_log then
            print('Checking regex ' .. bufname .. ' against ' .. val .. ': ' .. (will_exclude and 'yes' or 'no'))
        end
        if will_exclude then
            return true
        end
    end
    local is_subfolder = string.sub(bufname, 1, string.len(cwd)) == cwd
    if should_log then
        print('Is ' .. bufname .. ' subfolder of ' .. cwd .. '? ' .. (is_subfolder and 'yes' or 'no'))
    end
    return is_subfolder
end

function M.explain()
    is_excluded(vim.api.nvim_buf_get_name(0), vim.fn.getcwd(), true)
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
    vim.api.nvim_create_user_command('GTExplain', M.explain, { desc = 'Explain the checks on the current buffer' })
end

return M
