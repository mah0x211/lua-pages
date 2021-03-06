util = require('util');
local DOCROOT = './html';
local pages = require('pages').create({
    -- cache expiration seconds
    exprs = 6,
    -- number of insertion depth limit
    depth = 1,
    -- sandbox
    sandbox = require('pages.sandbox'),
    -- custom-commands
    cmds = require('cmds')
});
local uri = '/page.html';
local data = {
    x = {
        y = {
            z = 'external data'
        }
    }
};
local res, err = pages:publish( DOCROOT, uri, data );

if res then
    print( res );
end

if err then
    print( err );
end
