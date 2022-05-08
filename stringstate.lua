-- flux = require "ext.flux"
require "wire"

---@field strings table
StringState = {nodes, strings}

--- Generates a new state with all strings' `active` set to true
---@param nodes table
---@return table
function StringState:new(o, nodes)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.strings = {}
    for i = 1, #nodes do
        for j = i + 1, #nodes do
            for k = 1, 4 do
                local s = String:new({}, nodes[i], nodes[j], k, true)
                o.strings[#o.strings + 1] = s
            end
        end
    end
    o.nodes = nodes
    return o
end

function StringState:newRandom(activeDensity, nodes)
    local newState = StringState:new({}, nodes)
    --- generate a sequence of (activeDensity * #strings) unique indexes we'll toggle.
    local ids = {}
    for i = 1, #newState.strings do
        ids[i] = i -- god this is my new least favorite way to generate a range.
    end
    ids = shuffle(ids)
    for i = 1, math.floor(#ids * (1 - activeDensity)) do
        newState.strings[ids[i]].active = false;
    end
    return newState
end

--- Generates a state from a string representing the 
--- on/off values of each string.
--- no I do not know how that spec works yet 
---@param stringState string
---@return table
function StringState:newFromState(o, stringState)
end

function StringState:clone()
    local clone = StringState:new({}, self.nodes)
    for i = 1, #self.strings do
        clone.strings[i].active = self.strings[i].active
    end
    return clone
end

--- return a pseudo-random neighbor of the given state,
--- whose distance is no greater than `maxDistance`
---@param maxDistance number
---@return table
function StringState:neighbor(maxDistance)
    maxDistance = maxDistance or 1
    -- make a copy of ourselves.
    local neighbor = self:clone()
    -- randomly toggle some strings
    for i = 1, math.random(1, maxDistance) do
        local n = math.random(1, #self.strings)
        neighbor.strings[n].active = not neighbor.strings[n].active
        if neighbor.strings[n].active then
            neighbor.strings[n].color = {
                r = 1,
                g = 1,
                b = 1,
                a = 1
            }
            -- flux.to(neighbor.strings[n].color, 1, {
            --     r = 0,
            --     g = 0,
            --     b = 0,
            --     a = 1
            -- })
        end
    end
    return neighbor
end

--- draw all active strings in the state,
--- and return the number of strings drawn.
---@return integer
function StringState:draw(x, y, nailRadius, ppu, canvas)
    local stringCount = 0
    for s = 1, #self.strings do
        if not globals['doIsolateStep'] or getStringStep(self.strings[s], #self.nodes) == globals['isolateStep'] then
            if self.strings[s]:draw(x, y, nailRadius, ppu, canvas) then
                stringCount = stringCount + 1
            end
        end
    end
    love.graphics.setColor(0, 0, 0, 1)
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
