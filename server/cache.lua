Cache = {}
local data = {}

function Cache.Get(key)
    local entry = data[key]
    if not entry then return nil end
    
    if os.time() > entry.expiry then
        data[key] = nil
        return nil
    end
    
    return entry.value
end

function Cache.Set(key, value, ttl)
    data[key] = {
        value = value,
        expiry = os.time() + (ttl or Config.CacheTTL)
    }
end

function Cache.Bust(keyPattern)
    if not keyPattern then
        data = {}
        return
    end

    for key, _ in pairs(data) do
        if key:match(keyPattern) then
            data[key] = nil
        end
    end
end
