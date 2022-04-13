require("util")

function initHoop(nailResolution, hoopRadius, nailRadius, angle)
    angle = angle or 0
    initNails(nailResolution, hoopRadius, nailRadius, angle)
end

function drawHoop(nailRadius)
    drawNails(nailRadius)
    drawStrings(nailRadius)
end

nails = {}
function initNails(resolution, hoopRadius, nailRadius, angle)
    angle = angle or 0
    nails = {}
    for i = 1, resolution do
        local theta = i * 2 * math.pi / resolution + angle
        nails[i] = {
            x = (hoopRadius + nailRadius) * math.cos(theta) + love.graphics.getWidth() / 2,
            y = (hoopRadius + nailRadius) * math.sin(theta) + love.graphics.getHeight() / 2
        }
    end
end

-- TODO draw this to canvas to save draw calls
function drawNails(nailRadius)
    for i = 1, #nails do
        love.graphics.setColor(1,1,1,1)
        love.graphics.circle("fill", nails[i].x, nails[i].y, nailRadius)
        love.graphics.setColor(0,0,0,1)
        love.graphics.print(i, nails[i].x, nails[i].y)
    end
end

function drawStrings(nailRadius)
    love.graphics.setColor(1, 0, 0, 1)
    local n = 1
    local next = 2
    -- "right" outer tangent...?
    local phi = math.atan2(nails[n].y - nails[next].y, nails[n].x - nails[next].x)
    local theta = phi + (math.pi / 2)
    local x1 = nails[n].x + math.cos(theta) * nailRadius
    local x2 = nails[next].x + math.cos(theta) * nailRadius
    local y1 = nails[n].y + math.sin(theta) * nailRadius
    local y2 = nails[next].y + math.sin(theta) * nailRadius
    love.graphics.line(x1, y1, x2, y2)
    -- "left" outer tangent...
    love.graphics.setColor(0,0,1,1)
    x1 = nails[n].x - math.cos(theta) * nailRadius
    x2 = nails[next].x - math.cos(theta) * nailRadius
    y1 = nails[n].y - math.sin(theta) * nailRadius
    y2 = nails[next].y - math.sin(theta) * nailRadius
    love.graphics.line(x1,y1,x2,y2)

    love.graphics.setColor(1, 1, 1, 1)
end
