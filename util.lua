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

function slowDecrease(temp, beta)
    return temp / (1 + beta * temp)
end
