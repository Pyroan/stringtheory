require("util")

function initHoop(nailResolution, hoopRadius, nailRadius)
    initNails(nailResolution, hoopRadius, nailRadius)
end

function drawHoop(nailRadius)
    drawNails(nailRadius)
    drawStrings()
end

nails = {}
function initNails(resolution, hoopRadius, nailRadius)
    for i = 1, resolution do
        local theta = i * 2 * math.pi / resolution
        nails[i] = {
            x = (hoopRadius + nailRadius) * math.cos(theta) + love.graphics.getWidth() / 2,
            y = (hoopRadius + nailRadius) * math.sin(theta) + love.graphics.getHeight() / 2
        }
    end
end

-- TODO draw this to canvas to save draw calls
function drawNails(nailRadius)
    for i = 1, #nails do
        love.graphics.circle("fill", nails[i].x, nails[i].y, nailRadius)
    end
end

function drawStrings()

    step = #nails / 4 
    -- for step = 0, #nails / 2 - 1 do
        local i = 1
        local n = 1
        local next = nil
        while next ~= 1 do
            -- just an example using the centers of nails and not tangents
            love.graphics.setColor(HSL(i/#nails, 1,0.5,1))
            next = (n + step) % #nails + 1
            love.graphics.line(nails[n].x, nails[n].y, nails[next].x, nails[next].y)
            i = i + 1
            n = next
        end
    -- end
    love.graphics.setColor(1, 1, 1, 1)
end
