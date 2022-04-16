local StringState = {
    strings
}

--- Generates a new state with all strings' `active` set to true
---@param nodes table
---@return table
function StringState:new(o, nodes)

end

--- Generates a state from a string representing the 
--- on/off values of each string.
--- no I do not know how that spec works yet 
---@param stringState string
---@return table
function StringState:newFromState(o, stringState)
end
function initGraph(nodes)
end


--- return a pseudo-random neighbor of the given state,
--- whose distance is no greater than `maxDistance`
---@param maxDistance number
---@return table
function StringState:neighbor(maxDistance)
end