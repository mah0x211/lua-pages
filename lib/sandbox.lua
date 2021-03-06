--[[
  
  lib/sandbox.lua
  
  Copyright (C) 2014 Masatoshi Teruya
 
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:
 
  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.
 
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.

  lib/sandbox.lua
  lua-pages
  Created by Masatoshi Teruya on 14/05/05.
  
--]]
local sandbox = {};

do
    for _, name in ipairs({
        --[[
        '_G',
        '_VERSION',
        'arg',
        'assert',
        --]]
        'bit',
        --[[
        'collectgarbage',
        'coroutine',
        'debug',
        'dofile',
        'error',
        'gcinfo',
        'getfenv',
        'getmetatable',
        'io',
        --]]
        'ipairs',
        --[[
        'jit',
        'load',
        'loadfile',
        'loadstring',
        --]]
        'math',
        --[[
        'module',
        'newproxy',
        'next',
        'os',
        'package',
        --]]
        'pairs',
        --[[
        'pcall',
        'print',
        'rawequal',
        'rawget',
        'rawset',
        'require',
        --]]
        'select',
        --[[
        'setfenv',
        'setmetatable',
        --]]
        'string',
        'table',
        'tonumber',
        'tostring',
        'type',
        'unpack',
        --[[
        'xpcall',
        --]]
    }) do
        sandbox[name] = _G[name];
    end
end

return sandbox;
