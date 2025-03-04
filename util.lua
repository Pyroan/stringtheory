function gcd(a, b)
    while b ~= 0 do
        local t = b
        b = a % t
        a = t
    end
    return a
end

-- Converts HSL to RGB. (input and output range: 0 - 1)
function HSL(h, s, l, a)
    if s <= 0 then
        return l, l, l, a
    end
    h, s, l = h * 6, s, l
    local c = (1 - math.abs(2 * l - 1)) * s
    local x = (1 - math.abs(h % 2 - 1)) * c
    local m, r, g, b = (l - .5 * c), 0, 0, 0
    if h < 1 then
        r, g, b = c, x, 0
    elseif h < 2 then
        r, g, b = x, c, 0
    elseif h < 3 then
        r, g, b = 0, c, x
    elseif h < 4 then
        r, g, b = 0, x, c
    elseif h < 5 then
        r, g, b = x, 0, c
    else
        r, g, b = c, 0, x
    end
    return r + m, g + m, b + m, a
end

-- https://gist.github.com/Uradamus/10323382?permalink_comment_id=2754684#gistcomment-2754684
function shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

-- returns a string in the format HH:MM:SS for `time` seconds
function timestring(time)
    function timestring(time)
        local tcopy = time
        local str = ""
        local h, m, s
        h = math.floor(tcopy / 3600)
        tcopy = tcopy - (h * 3600)
        m = math.floor(tcopy / 60)
        tcopy = tcopy - (m * 60)
        s = tcopy
        if h > 0 then
            str = str .. h .. ":"
        end
        if m > 0 or h > 0 then
            if m < 10 then
                str = str .. "0"
            end
            str = str .. m .. ":"
        end
        if s < 10 then
            str = str .. '0'
        end
        str = str .. math.floor(s)
        if m <= 0 and h <= 0 then
            str = str .. 's'
        end
        return str
    end
end
