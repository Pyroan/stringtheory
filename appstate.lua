if appstate ~= nil then
    return appstate
end
appstate = {}

local validStates = {'paused', 'running', 'idle'}
local currentState = 'idle'

function appstate.getState()
    return currentState
end

function appstate.setState(state)
    for s = 1, #validStates do
        if validStates[s] == state then
            currentState = state
            print("app state set to '" .. state .. "'")
            return
        end
    end
    error("Tried to set invalid state: '" .. state .. "'")
end

return appstate
