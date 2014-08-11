--[[
  
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
  
  
  pages.lua
  lua-pages
  Created by Masatoshi Teruya on 14/05/05.
  
--]]

local tsukuyomi = require('tsukuyomi');
-- default
local DEFAULT = {
    -- cache expiration seconds
    EXPRS = -1,
    -- number of insertion depth limit
    DEPTH = 1,
    -- sandboxing
    SANDBOX = _G,
    -- custom-commands
    CMDS = {},
    -- fix newline character (replace CR/CRLF to LF)
    FIXNL = false
};


local function pathNormalize( ... )
    local argv = {...};
    local path = argv[1];
    local seg = nil;
    local res = {};
    
    if #argv > 1 then
        path = table.concat( argv, '/' );
    end
    
    -- remove double slash
    path = path:gsub( '/+', '/' );
    for seg in string.gmatch( path, '[^/]+' ) do
        if seg == '..' then
            table.remove( res );
        elseif seg ~= '.' then
            table.insert( res, seg );
        end
    end
    
    return '/' .. table.concat( res, '/' );
end


-- get context
local function getContext( self, docroot )
    local rev, caches = self.instance[docroot], self.caches[docroot];
    
    -- create tsukuyomi instance per documentroot
    if not rev then
        local tag, def;
        
        rev = tsukuyomi.new( true, self.cfg.SANDBOX );
        self.instance[docroot] = rev;
        -- append ctags
        for tag, def in pairs( self.cfg.CMDS ) do
            rev:setCommand( tag, def[1], def[2] );
        end
    end
    -- create cache-table
    if not caches then
        caches = {};
        self.caches[docroot] = caches;
    end

    return {
        rev = rev,
        caches = caches,
        epoch = os.time(),
        docroot = docroot,
        errs = {},
        cfg = self.cfg
    };
end


-- cache control
local function getCache( ctx, uri )
    local rc, cache = false, ctx.caches[uri];
    local uris;
    
    if cache then
        if cache.expr < 0 or cache.expr > ctx.epoch then
            rc = true;
            uris = cache.uris;
        -- remove cache
        else
            ctx.caches[uri] = nil;
            ctx.rev:unsetPage( uri );
        end
    end
    
    return rc, uris;
end


local function setCache( ctx, uri, uris )
    ctx.caches[uri] = {
        expr = ctx.cfg.EXPRS < 0 and ctx.cfg.EXPRS or ( ctx.epoch + ctx.cfg.EXPRS );
        uris = uris
    };
end


local function readFile( ctx, uri )
    local fh, err = io.open( ctx.docroot .. pathNormalize( uri ) );
    local src;
    
    if not err then
        src = fh:read('*a');
        fh:close();
        if not src then
            err = ('could not read %q'):format( uri );
        -- fix newline characters CR/CRLF to LF
        elseif ctx.cfg.FIXNL then
            src = src:gsub( '\r\n?', '\n' );
        end
    end
    
    return src, err;
end


local function review( ctx, uri, src )
    local uris, err = ctx.rev:setPage( uri, src );
    
    if not err then
        setCache( ctx, uri, uris );
    end
    
    return uris, err;
end


local function imprint( ctx, uri )
    local cached, uris = getCache( ctx, uri );
    local err;
    
    -- no cached
    if cached == false then
        local src;
        
        src, err = readFile( ctx, uri );
        if not err then
            uris, err = review( ctx, uri, src );
        end
    end
    
    return uris, err;
end


local function postflight( ctx, parentURI, uris, depth, errs )
    local uri, childURIs;
    
    for uri in pairs( uris ) do
        if depth < 1 then
            review( 
                ctx, uri, 
                ('<!-- could not insert: %q - %q : insertion-depth limit exceeded -->')
                :format( parentURI, uri )
            );
        else
            childURIs, err = imprint( ctx, uri );
            if err then
                table.insert( errs, err );
            else
                postflight( ctx, uri, childURIs, depth - 1, errs );
            end
        end
    end
end


local function preflight( self, ctx, uri )
    local uris, err = imprint( ctx, uri );
    local errs;
    
    if not err and uris then
        errs = {};
        postflight( ctx, uri, uris, self.cfg.DEPTH, errs );
        if #errs > 0 then
            errs = table.concat( errs, '\n' );
        else
            errs = nil;
        end
    end
    
    return err, errs;
end


local MT = {};

function MT:publish( docroot, uri, data, layout )
    local ok = false;
    local res, err;
    
    if type( docroot ) ~= 'string' then
        err = 'docroot must be type of string';
    elseif type( uri ) ~= 'string' then
        err = 'uri must be type of string';
    elseif layout ~= nil and type( layout ) ~= 'string' then
        err = 'layout must be type of string';
    else
        local ctx = getContext( self, docroot );
        local errs;
        
        -- check data type
        data = type( data ) == 'table' and data or {};
        
        -- preflight for request-uri
        err, errs = preflight( self, ctx, uri );
        if not err then
            -- run template
            res, ok = ctx.rev:render( uri, data, true );
        end
        
        -- check layout
        if not err and layout then
            -- preflight for layout
            err = preflight( self, ctx, layout )
            if err then
                return false, res, err;
            end
            
            -- set page response
            rawset( data, 'layoutContent', res );
            -- run template
            res, ok = ctx.rev:render( layout, data, true );
        end
    end
    
    return ok, res, err, errs;
end


-- create template object
local function create( cfg )
    local tbl = {};
    local k, v, t, ck, cv;
    
    if cfg ~= nil and type( cfg ) ~= 'table' then
        error( 'config table must be type of table' );
    end
    -- rewrite default configuraion
    for k, v in pairs( DEFAULT ) do
        ck = k:lower();
        cv = cfg[ck];
        -- check custom value
        if cv ~= nil then
            -- check value type
            t = type( v );
            if t ~= type( cv ) then
                error( ('%s must be type of %s'):format( ck, t ) );
            end
            v = cv;
        end
        
        tbl[k] = v;
    end
    
    -- check ctags format
    for k, v in pairs( tbl.CMDS ) do
        if type( v ) ~= 'table' then
            error( ('ctags.%s must be type of table'):format( k ) );
        elseif type( v[1] ) ~= 'function' then
            error( ('ctags.%s[1] must be type of function'):format( k ) );
        elseif v[2] ~= nil and type( v[2] ) ~= 'boolean' then
            error( ('ctags.%s[2] must be type of boolean'):format( k ) );
        end
    end
    
    return setmetatable({ 
        cfg = tbl,
        instance = {},
        caches = {}
    }, {
        __index = MT 
    });
end


return {
    create = create
};
