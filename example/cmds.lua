local function put( str )
    return str .. ' : custom put command';
end

-- custom commands
return {
    put = { put, true }
};
