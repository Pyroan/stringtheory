require "ztring"
require "util"

--- Initialize the "hoop" - the polygon of nails and strings that we're drawing.
---@param nailResolution integer
---@param hoopRadius integer
---@param nailRadius integer
---@param angle number
function initHoop(nailResolution, hoopRadius, nailRadius, angle)
    angle = angle or 0
    nails = initNails(nailResolution, hoopRadius, nailRadius, angle)
    strings = initStrings()
end

--- Draw the hoop
---@param nailRadius integer
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

function initStrings()
    local strings = {}
    for i = 1, #nails do
        for j = i + 1, #nails do
            for k = 1, 4 do
                local s = String:new({}, nails[i], nails[j], k)
                strings[#strings + 1] = s
            end
        end
    end
    return strings
end

function drawStrings(nailRadius)
    stringCount = 0
    love.graphics.setColor(HSL(angle / (2 * math.pi), 1, 0.5, 1))
    for s = 1, #strings do
        if not globals['doIsolateStep'] or getStringStep(strings[s]) == globals['isolateStep'] then
            -- love.graphics.setColor(HSL(strings[s].type/5 -0.2, 1, 0.5, 1))
            if strings[s]:draw(nailRadius) then
                stringCount = stringCount + 1
            end
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
end

--- return the minimum number of nails needed to get from `string`s source node to its destination node
---@param string table
function getStringStep(string)
    local s = string.destNode.id - string.sourceNode.id
    if s > #nails / 2 then
        s = string.sourceNode.id + #nails - string.destNode.id
    end
    return s
end
