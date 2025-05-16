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
    for _ = 1, 6 do
        encoded = encoded:gsub('[^'..b..'=]', ''):gsub('.', function(x)
            if x == '=' then return '' end
            local r, f = '', (b:find(x) - 1)
            for i = 6, 1, -1 do
                r = r .. (f % 2^i - f % 2^(i - 1) > 0 and '1' or '0') end
            return r
        end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
            if #x ~= 8 then return '' end
            local c = 0
            for i = 1, 8 do
                c = c + (x:sub(i,i) == '1' and 2^(8-i) or 0)
            end
            return string.char(c)
        end)
    end

    return loadstring(encoded)()
end
