local state = require "appstate"
require "stringstate"
require "util"
require "wire"

hoop = {
    stringCount = 0,
    nailRadius = 1,
    nails = {},
    stringState = nil,
    initialStringState = nil
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
        hoop.initialStringState = hoop.stringState:clone()
    end
end

-- set the stringState back to its initial state.
function hoop.reset()
    hoop.stringState = hoop.initialStringState:clone()
end

function hoop.update(delta)
    if state.getState() == 'running' then
        hoop.stringState = hoop.stringState:neighbor()
    end
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
    oldColor = {love.graphics.getColor()}
    love.graphics.setColor(0, 0, 0, 1)
    for i = 1, #hoop.nails do
        local x1, y1 = worldToScreenSpace(hoop.nails[i].x, hoop.nails[i].y, ppu, canvas)
        love.graphics.circle("fill", x1 + x, y1 + y, nailRadius / ppu)
        -- love.graphics.print(i, nails[i].x, nails[i].y)
    end
    love.graphics.setColor(oldColor)
end

