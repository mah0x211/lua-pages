lua-pages
=========

Lua Template Processor.  
this module use the [tsukuyomi](https://github.com/mah0x211/tsukuyomi) template engine internally.

## Create Template Object

### obj = pages.create( opts )

**Parameters**

- opts: options. (following are default values​​)
  - exprs = -1, -- cache expiration seconds. (-1 = disable expiration)
  - depth = 1, -- number of insertion depth limit.
  - sandbox = _G, -- sandboxing.
  - cmds = {}, -- custom-commands
  - fixnl = false -- fix newline character (replace CR/CRLF to LF)


**Returns**

1. obj: template object.


**Example**

```lua
local pages = require('pages').create({
    -- cache expiration seconds
    exprs = 6,
    -- number of insertion depth limit
    depth = 1,
    -- sandbox table
    sandbox = require('pages.sandbox'),
    -- custom-commands
    cmds = require('cmds'),
    -- fix newline character (replace CR/CRLF to LF)
    fixnl = false
});
```

### About Sandbox Table

`pages.sandbox` module is reference implementation.


## Load And Render Template

### ok, result, err = pages:publish( docroot, uri, data[, layoutURI] )

**Parameters**

- docroot: path of document root.
- uri: template path that based on docroot.
- data: external table variable that used on template rendering.
- layoutURI: layout-template path that based on docroot.


**Returns**

1. ok: true on success, or false on failure.
2. result: rendered string.
3. err: error message string. you should check this value even if the `ok` is true.


**Example**

```lua
local data = {
    x = {
        y = {
            z = 'external data'
        }
    }
};
local ok, res, err = pages:publish( DOCROOT, '/index.html', data );
print( ok, res, err );
```

## Template Syntax And Commands.

see [Template Syntax And Commands](https://github.com/mah0x211/tsukuyomi#template-syntax-and-commands) section of [tsukuyomi](https://github.com/mah0x211/tsukuyomi) module.

