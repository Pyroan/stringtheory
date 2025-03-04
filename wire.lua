Wire = {id, type, sourceNode, destNode, active, color}

function Wire:new(o, sourceNode, destNode, type, active)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    o.type = type or 1
    o.sourceNode = sourceNode
    o.destNode = destNode
    o.active = active or true
    o.color = {
        r = 0,
        g = 0,
        b = 0,
        a = 1
    }
    return o
end

--- draws a tangent line between sourceNode and destNode with radius `nailRadius`.
--- the specific line is based on `self.type`
---@param nailRadius integer "the radius of the nail (in pixels)"
---@return boolean "`true` if the string was actually drawn, `false` otherwise"
function Wire:draw(x, y, nailRadius, canvas)
    if (nailRadius <= 0 and self.type ~= 1) or not self.active then
        return false
    end
    local x1, y1, x2, y2 = self:getEndpoints(x, y, nailRadius, canvas)
    love.graphics.line(x1, y1, x2, y2)
    return true
end

function Wire:getEndpoints(x, y, nailRadius, canvas)
    local source = self.sourceNode
    local dest = self.destNode
    local x1, x2, y1, y2
    if self.type == 1 or self.type == 2 then
        local phi = math.atan2(source.y - dest.y, source.x - dest.x)
        local theta = phi + (math.pi / 2)
        if self.type == 1 then
            -- "right" outer tangent
            x1 = source.x + math.cos(theta) * nailRadius
            x2 = dest.x + math.cos(theta) * nailRadius
            y1 = source.y + math.sin(theta) * nailRadius
            y2 = dest.y + math.sin(theta) * nailRadius
        elseif self.type == 2 then
            -- "left" outer tangent
            x1 = source.x - math.cos(theta) * nailRadius
            x2 = dest.x - math.cos(theta) * nailRadius
            y1 = source.y - math.sin(theta) * nailRadius
            y2 = dest.y - math.sin(theta) * nailRadius
        end
    elseif self.type == 3 or self.type == 4 then
        local xDelta = dest.x - source.x
        local yDelta = dest.y - source.y
        local distanceSquared = xDelta * xDelta + yDelta * yDelta
        local meh = math.sqrt(distanceSquared - (nailRadius * nailRadius)) * (nailRadius / distanceSquared) -- it's called meh because i don't know what it does.
        local xOffset
        local yOffset
        -- "right" inner tangent
        xOffset = (xDelta * (nailRadius * nailRadius) / distanceSquared) - (meh * -yDelta)
        yOffset = (yDelta * (nailRadius * nailRadius) / distanceSquared) - (meh * xDelta)
        if self.type == 4 then
            -- "left" inner tangent.
            xOffset = xOffset + (meh * -yDelta * 2)
            yOffset = yOffset + (meh * xDelta * 2)
        end
        x1 = xOffset + source.x
        x2 = xDelta - xOffset + source.x
        y1 = yOffset + source.y
        y2 = yDelta - yOffset + source.y
    end

    x1 = x1 + x
    y1 = y1 + y
    x2 = x2 + x
    y2 = y2 + y
    return x1, y1, x2, y2
end
