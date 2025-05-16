return function(fullInput)
    local marker = "%-%- decode"
    local _, endPos = fullInput:find(marker)

    if not endPos then
        warn("Decode marker '-- decode' not found.")
        return
    end

    -- Extract lines after "-- decode"
    local encoded = fullInput:sub(endPos + 1):gsub("^%s*", "")

    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

    -- Base64 validation function
    local function is_base64(str)
        if #str % 4 ~= 0 then return false end
        return not str:find("[^" .. b .. "=]")
    end

    -- Base64 decode function
    local function base64_decode(data)
        data = data:gsub('[^'..b..'=]', '')
        return (data:gsub('.', function(x)
            if x == '=' then return '' end
            local r, f = '', (b:find(x) - 1)
            for i = 6, 1, -1 do
                r = r .. (f % 2^i - f % 2^(i - 1) > 0 and '1' or '0')
            end
            return r
        end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
            if #x ~= 8 then return '' end
            local c = 0
            for i = 1, 8 do
                c = c + (x:sub(i,i) == '1' and 2^(8 - i) or 0)
            end
            return string.char(c)
        end))
    end

    -- Auto detect decode layers
    local layers_decoded = 0
    local decoded = encoded
    while is_base64(decoded) do
        local success, result = pcall(base64_decode, decoded)
        if not success or not result or #result == 0 then break end
        decoded = result
        layers_decoded = layers_decoded + 1
    end

    -- print("Decoded layers: ", layers_decoded) -- debug if you want

    return loadstring(decoded)()
end
