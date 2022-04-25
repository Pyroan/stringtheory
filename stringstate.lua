require "ztring"

---@field strings table
StringState = {
    nodes,
    strings}

--- Generates a new state with all strings' `active` set to true
---@param nodes table
---@return table
function StringState:new(o, nodes)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.strings = {}
    for i = 1, #nodes do
        for j = i+1, #nodes do
            for k = 1, 4 do
                local s = String:new({}, nodes[i], nodes[j], k, true)
                o.strings[#o.strings + 1] = s
            end
        end
    end
    o.nodes = nodes
    return o
end

--- Generates a state from a string representing the 
--- on/off values of each string.
--- no I do not know how that spec works yet 
---@param stringState string
---@return table
function StringState:newFromState(o, stringState)
end

--- return a pseudo-random neighbor of the given state,
--- whose distance is no greater than `maxDistance`
---@param maxDistance number
---@return table
function StringState:neighbor(maxDistance)
    maxDistance = maxDistance or 1
    -- make a copy of ourselves.
    -- local neighbor = StringState:newFromState(self:toString())
    local neighbor = StringState:new({}, self.nodes)
    for i = 1, #self.strings do
        neighbor.strings[i].active = self.strings[i].active
    end
    for i = 1, math.random(1, maxDistance) do
        local n = math.random(1, #self.strings)
        neighbor.strings[n].active = not neighbor.strings[n].active
    end
    return neighbor
end

--- draw all active strings in the state,
--- and return the number of strings drawn.
---@return integer
function StringState:draw(nailRadius)
    local stringCount = 0
    -- love.graphics.setColor(HSL(angle / (2 * math.pi), 1, 0.5, 1))
    love.graphics.setColor(0,0,0,0.4)
    for s = 1, #self.strings do
        if not globals['doIsolateStep'] or getStringStep(self.strings[s], #self.nodes) == globals['isolateStep'] then
            -- love.graphics.setColor(HSL(strings[s].type/5 -0.2, 1, 0.5, 1))
            if self.strings[s]:draw(nailRadius) then
                stringCount = stringCount + 1
            end
        end
    end
    love.graphics.setColor(0,0,0, 1)
    return stringCount
end

function StringState:toString()
    return ''
end

--- return the minimum distance (in nail ids) to get from `string`s source node to its destination node
---@param string table
function getStringStep(string, numberOfNodes)
    local s = string.destNode.id - string.sourceNode.id
    if s > numberOfNodes / 2 then
        s = string.sourceNode.id + numberOfNodes - string.destNode.id
    end
    return s
end