require "stringstate"
require "util"
require "wire"

stringCount = 0
--- Initialize the "hoop" - the polygon of nails and strings that we're drawing.
---@param nailResolution integer
---@param hoopRadius integer
---@param nailRadius integer
---@param angle number
function initHoop(nailResolution, hoopRadius, nailRadius, angle)
    angle = angle or 0
    nails = initNails(nailResolution, hoopRadius, nailRadius, angle)
    if stringState == nil then
        stringState = StringState:new({}, nails)
    else
        stringState = stringState:neighbor()
    end
end

--- Draw the hoop
---@param nailRadius integer
function drawHoop(nailRadius)
    drawNails(nailRadius)
    stringCount = stringState:draw(nailRadius)
end

--- TODO `nails` should reallly be just part of stringState if i'm being honest 
function initNails(resolution, hoopRadius, nailRadius, angle)
    angle = angle or 0
    local nails = stringState and stringState.nodes or {}
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
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.circle("fill", nails[i].x, nails[i].y, nailRadius)
        love.graphics.setColor(1, 1, 1, 1)
        -- love.graphics.print(i, nails[i].x, nails[i].y)
    end
end

