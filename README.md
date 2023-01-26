# Gatekeeper.nvim

This plugin intends to make buffers with from files outside of the current
working directory read only and non modifiable. To do that it sets an auto
command for every time a buffer gets loaded.

The purpose for the existence of this plugin is basically allowing to set
white lists for folders or files.

## Usage

Install with your favorite package manager and call

```lua
require('gatekeeper').setup({
    exclude = {},
    debug = false, -- will call vim.notify with info when it is being evaluated
})
```

By default the exclude is an empty list. You can add folders or files to it.
It won't expand `~` to your home so you have to concatenate `vim.fn.expand('~')`
to your desired folder, if that's the case. Example:

```lua
require('gatekeeper').setup({
    exclude = {
        vim.fn.expand('~/.config/nvim')
    }
})
```

You can call `:GTForceWrite` on any buffer to revert and force it to be writable
and modifiable.
