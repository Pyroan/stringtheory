require "ztring"
require "util"

function initHoop(nailResolution, hoopRadius, nailRadius, angle)
    angle = angle or 0
    nails = initNails(nailResolution, hoopRadius, nailRadius, angle)
    strings = initStrings(nails)
end

function drawHoop(nailRadius)
    drawNails(nailRadius)
    drawStrings(nailRadius)
end

function initNails(resolution, hoopRadius, nailRadius, angle)
    angle = angle or 0
    local nails = {}
    for i = 1, resolution do
        local theta = i * 2 * math.pi / resolution + angle
        nails[i] = {
            id = i,
            x = (hoopRadius + nailRadius) * math.cos(theta) + love.graphics.getWidth() / 2,
            y = (hoopRadius + nailRadius) * math.sin(theta) + love.graphics.getHeight() / 2
        }
    end
    return nails
end

-- TODO draw this to canvas to save draw calls
function drawNails(nailRadius)
    for i = 1, #nails do
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.circle("fill", nails[i].x, nails[i].y, nailRadius)
        love.graphics.setColor(0, 0, 0, 1)
        -- love.graphics.print(i, nails[i].x, nails[i].y)
    end
end

stringCount = 0

function initStrings(nails)
    local strings = {}
    return strings
end

function drawStrings(nailRadius)
    stringCount = 0
    love.graphics.setColor(HSL(angle / (2 * math.pi), 1, 0.5, 1))
    if globals['doIsolateStep'] then
        drawStringStep(globals['isolateStep'], nailRadius)
    else
        for step = 0, #nails / 2 - 1 do
            drawStringStep(step, nailRadius)
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function drawStringStep(step, nailRadius)
    -- k has to be gcd actually
    local k = gcd(#nails, step + 1)
    for i = 1, k do
        local n = i
        local next = (n + step) % #nails + 1
        while next ~= i and not (n == #nails / 2 + i and k == #nails / 2) do
            next = (n + step) % #nails + 1
            for i = 1, (nailRadius == 0 and 1 or 4) do
                local s = String:new({}, nails[n], nails[next], i)
                s:draw(nailRadius)
            end
            n = next
        end
    end
end
