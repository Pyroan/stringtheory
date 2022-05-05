require "stringstate"
require "util"
require "wire"

hoop = {
    stringCount = 0,
    nails = {}
}
--- Initialize the "hoop" - the polygon of nails and strings that we're drawing.
---@param nailResolution integer
---@param hoopRadius integer
---@param nailRadius integer
---@param angle number
function hoop.load(nailResolution, hoopRadius, nailRadius, angle)
    angle = angle or 0
    hoop.nails = hoop.loadNails(nailResolution, hoopRadius, nailRadius, angle)
    if hoop.stringState == nil then
        hoop.stringState = StringState:new({}, hoop.nails)
    else
        hoop.stringState = hoop.stringState:neighbor()
    end
end

function hoop.update(delta)
end

function hoop.onHoopRadiusChanged()
end

function hoop.onNailResolutionChanged()
end

function hoop.onNailRadiusChanged()
end

--- Draw the hoop
--- will draw to a canvas, if it's provided.
---@param nailRadius integer
---@param canvas love.graphics.Canvas
function hoop.draw(x, y, nailRadius, ppu, canvas)
    if canvas then
        love.graphics.setCanvas(canvas)
    end
    hoop.drawNails(x, y, nailRadius, ppu, canvas)
    hoop.stringCount = hoop.stringState:draw(x, y, nailRadius, ppu, canvas)
    love.graphics.setCanvas()
end

--- TODO `nails` should reallly be just part of stringState if i'm being honest 
function hoop.loadNails(resolution, hoopRadius, nailRadius, angle)
    angle = angle or 0
    local nails = hoop.stringState and hoop.stringState.nodes or {}
    for i = 1, resolution do
        local theta = i * 2 * math.pi / resolution + angle
        nails[i] = {
            id = i,
            x = (hoopRadius + nailRadius) * math.cos(theta),
            y = (hoopRadius + nailRadius) * math.sin(theta)
        }
    end
    return nails
end

function hoop.drawNails(x, y, nailRadius, ppu, canvas)
    for i = 1, #hoop.nails do
        love.graphics.setColor(0, 0, 0, 1)
        local x1, y1 = worldToScreenSpace(hoop.nails[i].x, hoop.nails[i].y, ppu, canvas)
        love.graphics.circle("fill", x1 + x, y1 + y, nailRadius / ppu)
        love.graphics.setColor(1, 1, 1, 1)
        -- love.graphics.print(i, nails[i].x, nails[i].y)
    end
end

