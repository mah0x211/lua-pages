util = require('util');
local DOCROOT = './html';
local pages = require('pages').create({
    -- cache expiration seconds
    exprs = 6,
    -- number of insertion depth limit
    depth = 1,
    -- sandbox
    sandbox = require('pages.sandbox'),
    -- custom-tags
    ctags = require('ctags')
});
local uri = '/page.html';
local layout = '/layout.html';
local data = {
    uri = uri,
    x = {
        y = {
            z = 'external data'
        }
    }
};
local ok, res, err = pages:publish( DOCROOT, uri, data, layout );

if res then
    print( res );
end

if err then
    print( err );
end
