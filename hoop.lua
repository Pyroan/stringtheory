local state = require "appstate"
require "stringstate"
require "util"
require "wire"

hoop = {
    radius = 350, -- inner radius of the circle defined by the nails, in world units
    resolution = 128, -- number of nails
    stringCount = 0,
    nailRadius = 5, -- radius of a nail body, in world units
    nails = {},
    stringState = nil,
    initialStringState = nil
}
--- Initialize the "hoop" - the polygon of nails and strings that we're drawing.
---@param nailRadius integer
---@param activeDensity number "percentage of strings to active for a random stringState"
---@param angle number
function hoop.load(activeDensity, angle)
    angle = angle or 0
    activeDensity = activeDensity or 1
    hoop.nails = hoop.loadNails(angle)
    hoop.stringState = StringState:newRandom(activeDensity, hoop.nails)
    hoop.initialStringState = hoop.stringState:clone()
end

-- set the stringState back to its initial state.
function hoop.reset()
    hoop.stringState = hoop.initialStringState:clone()
end

function hoop.update(delta)
end

function hoop.onRadiusChanged(newValue)
    hoop.radius = newValue
    -- this SHOULDN'T require us to reload our stringstate necessarily.
    -- but right now it does because strings currently store the location of their nails
    -- and not just their id, like they should.
    hoop.stringState.nodes = {}
    hoop.nails = hoop.loadNails()
    hoop.stringState = StringState:newRandom(0, hoop.nails)
    hoop.initialStringState = hoop.stringState:clone()
end

function hoop.onNailResolutionChanged(newValue)
    hoop.resolution = newValue
    -- this WILL require us to reload our stringstate, since it's
    -- useless if it doesn't have the same number of nodes.
    hoop.stringState.nodes = {}
    hoop.nails = hoop.loadNails()
    hoop.stringState = StringState:newRandom(0, hoop.nails)
    hoop.initialStringState = hoop.stringState:clone()
end

function hoop.onNailRadiusChanged(newValue)
    hoop.nailRadius = newValue
end

--- Draw the hoop
--- will draw to a canvas, if it's provided.
---@param canvas love.graphics.Canvas
function hoop.draw(x, y, canvas)
    if canvas then
        love.graphics.setCanvas(canvas)
    end
    hoop.drawNails(x, y, canvas)
    hoop.stringCount = hoop.stringState:draw(x, y, hoop.nailRadius, canvas)
    love.graphics.setCanvas()
end

--- TODO `nails` should reallly be just part of stringState if i'm being honest 
function hoop.loadNails(angle)
    angle = angle or 0
    local nails = hoop.stringState and hoop.stringState.nodes or {}
    for i = 1, hoop.resolution do
        local theta = i * 2 * math.pi / hoop.resolution + angle
        nails[i] = {
            id = i,
            x = (hoop.radius + hoop.nailRadius) * math.cos(theta),
            y = (hoop.radius + hoop.nailRadius) * math.sin(theta)
        }
    end
    return nails
end

function hoop.drawNails(x, y, canvas)
    oldColor = {love.graphics.getColor()}
    love.graphics.setColor(0, 0, 0, 1)
    for i = 1, #hoop.nails do
        local x1, y1 = love.graphics.transformPoint(hoop.nails[i].x, hoop.nails[i].y)
        --- For some reason the nails' radius isn't getting scaled properly and
        --- I can't figure out why so i'm just scaling it manually here.
        love.graphics.circle("fill", x1 + x, y1 + y, hoop.nailRadius * globals.scale_factor)
        -- love.graphics.print(i, nails[i].x, nails[i].y)
    end
    love.graphics.setColor(oldColor)
end

--- Convert to a JSON string so we can save/load
function hoop.serialize()
    error("Not yet implemented!")
end
