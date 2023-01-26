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
-- default values
    exclude = {},
    exclude_regex = {},
    debug = false, -- will call vim.notify with info when it is being evaluated
})
```

## Options

### exclude

Specifies fully qualified folders or files to be excluded and being editable.
It won't expand `~` to your home so you have to concatenate `vim.fn.expand('~')`
to your desired folder, if that's the case. Example:

```lua
require('gatekeeper').setup({
    exclude = {
        vim.fn.expand('~/.config/nvim')
    }
})
```

### exclude_regex

Specifies regex patterns to evaluate files to be excluded and being editable.
If the buffer name matches the regex it won't be blocked from being edited. Example:

```lua
require('gatekeeper').setup({
    exclude_regex = {
        '.*\.config/nvim/.*' -- any file that contains ".config/nvim" in its full path
    }
})
```

### debug

Will notify if a file is being blocked or not when it is evaluated.

## Commands

You can call `:GTForceWrite` on any buffer to revert and force it to be writable
and modifiable.
