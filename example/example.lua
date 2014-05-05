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
local data = {
    x = {
        y = {
            z = 'external data'
        }
    }
};
local ok, res, err = pages:publish( DOCROOT, '/index.html', data );

if res then
    print( res );
end

if err then
    print( err );
end
