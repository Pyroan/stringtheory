local state = require "appstate"
local nuklear = require "nuklear"
require("globals")

ui = {}
local nukeui
local failedToLoadFile = false
local outputFile = {
    value = "output.json"
}
local itersPerTemp = {
    value = nil
}
local initialTemp = {
    value = nil
}
local decreaseFunc = {
    value = 3
}

function ui.load()
    nukeui = nuklear.newUI()
end

function ui.update(delta)
    nukeui:frameBegin()
    if nukeui:windowBegin('Settings', 0, 0, 200, love.graphics.getHeight(), 'border', 'minimizable', 'title',
        'scrollbar') then
        -- Save state
        nukeui:layoutRow('dynamic', 30, 1)
        local s = nukeui:edit('field', outputFile)
        if s == 'deactivated' then
            -- add file extension if it's not there
            -- also should prob sanitize input. won't tho.
            if outputFile.value:sub(#outputFile.value - 4) ~= ".json" then
                outputFile.value = outputFile.value .. ".json"
            end
            failedToLoadFile = false
            print("Output file set to " .. outputFile.value)
        end
        nukeui:layoutRow('dynamic', 20, 2)
        if nukeui:button(globals["justSaved"] and "Saved!" or "Save") then

            local f = io.open(outputFile.value, "w")
            f:write(hoop.stringState:serialize())
            f:close()
            print("Logged state to ./" .. outputFile.value)
        end
        if nukeui:button("Load") then
            --- TODO don't load image without asking first, if we haven't saved yet.
            local f = io.open(outputFile.value, "r")
            if not f then
                failedToLoadFile = true
            else
                local json = f:read('*all')
                hoop.stringState = StringState:newFromJSON(json)
                hoop.initialStringState = hoop.stringState
            end
        end
        nukeui:layoutRow('dynamic', 20, 1)
        if failedToLoadFile then
            nukeui:label("File not found!", 'wrap', "#ff0000")
        end
        -- play controls
        nukeui:layoutRow('dynamic', 35, 3)
        local runSelected = state.getState() == 'running'
        local pauseSelected = state.getState() == 'paused'
        local stopSelected = state.getState() == 'idle'
        runSelected = nukeui:selectable('Run', nil, 'centered', runSelected)
        pauseSelected = nukeui:selectable('Pause', nil, 'centered', pauseSelected)
        stopSelected = nukeui:selectable('Reset', nil, 'centered', stopSelected)
        if runSelected and state.getState() ~= 'running' then
            state.setState("running")
        elseif pauseSelected and state.getState() ~= 'paused' then
            state.setState("paused")
        elseif stopSelected and state.getState() ~= 'idle' then
            state.setState("idle")
            hoop.reset()
            evaluator.reset()
            globals['totalEvaluationTime'] = 0
        end
        nukeui:layoutRow('dynamic', 270, 1)
        if nukeui:groupBegin("Hoop Settings", 'title', 'border') then
            -- set string density (% of strings to make active), add a "generate" button, etc
            nukeui:layoutRow('dynamic', 25, 1)
            -- nail/hoop params

            local t = {
                value = hoop.resolution
            }
            local changed = nukeui:property('Nails', 2, t, 128, 1, 1)
            if changed then
                hoop.onNailResolutionChanged(t.value)
            end
            nukeui:label("Nail Radius: " .. hoop.nailRadius)
            hoop.nailRadius = nukeui:slider(0, hoop.nailRadius, 100, 1)
            nukeui:label("Hoop Radius: " .. hoop.radius)
            ui:slider(hoop.radius, 0, love.graphics.getHeight() / 2, 1, hoop.onRadiusChanged)
            nukeui:layoutRow('dynamic', 25, 1)
            nukeui:label(string.format("Active Density: %d%%", math.floor(globals['activeDensity'] * 100)))
            globals['activeDensity'] = nukeui:slider(0, globals['activeDensity'], 1, 0.01)
            if nukeui:button("Generate Random State") then
                hoop.load(globals['activeDensity'])
            end

            nukeui:groupEnd()
        end
        nukeui:layoutRow('dynamic', 200, 1)
        if nukeui:groupBegin("Eval Settings (Advanced)", 'title', 'border', 'scrollbar') then
            nukeui:layoutRow('dynamic', 25, 2)
            nukeui:label("iters/temp")
            nukeui:label("initial temp")

            itersPerTemp.value = itersPerTemp.value or globals['iterationsPerTemp']
            local s, _ = nukeui:edit('field', itersPerTemp)
            if s == 'deactivated' then
                local n = tonumber(itersPerTemp.value)
                if n then
                    globals['iterationsPerTemp'] = math.floor(n)
                    itersPerTemp.value = nil
                    evaluator.reset()
                end
            end
            initialTemp.value = initialTemp.value or globals['initialTemp']
            s, _ = nukeui:edit('field', initialTemp)
            if s == 'deactivated' then
                local n = tonumber(initialTemp.value)
                if n then
                    globals['initialTemp'] = n
                    initialTemp.value = nil
                    evaluator.reset()
                end
            end
            nukeui:layoutRow('dynamic', 25, 1)
            nukeui:label("Volatility: " .. globals['volatility'])
            globals['volatility'] = nukeui:slider(0, globals['volatility'], 10, 1)

            nukeui:layoutRow('dynamic', 25, 1)
            nukeui:label("Evaluator Resolution: " .. globals['evaluatorResolution'])
            nukeui:layoutRow('dynamic', 25, {0.70, 0.30})
            ui:slider(globals['evaluatorResolution'], 8, math.min(im:getDimensions()), 1, function(v)
                globals['evaluatorResolution'] = v
                initImage()

            end)
            if nukeui:button("reset") then
                globals['evaluatorResolution'] = 500
                initImage()
            end

            nukeui:layoutRow('dynamic', 25, 1)
            nukeui:label('Shade Detail: ' .. math.floor(globals['shadeDetail'] * 100 + 0.5) .. "%")
            ui:slider(globals['shadeDetail'], 0, 0.99, 0.01, function(v)
                globals['shadeDetail'] = v
            end)

            nukeui:label('Temperature Decrease:', 'wrap')
            local changed = nukeui:combobox(decreaseFunc, {'linear (fast)', 'multiplicative', 'slow (quality)'})
            if changed then
                local func
                if decreaseFunc.value == 1 then
                    func = linearDecrease
                elseif decreaseFunc.value == 2 then
                    func = multiplicativeDecrease
                elseif decreaseFunc.value == 3 then
                    func = slowDecrease
                else
                    error("Somehow we tried to set an invalid temperature decrease function")
                end
                evaluator.tempDecreaseFunc = func
            end

            nukeui:groupEnd()
        end
        nukeui:layoutRow('dynamic', 200, 1)
        -- preview settings
        local open = nukeui:groupBegin("Preview Settings", 'title', 'border')
        if open then
            nukeui:layoutRow('dynamic', 25, 1)
            -- isolated step
            globals['doIsolateStep'] = nukeui:checkbox("Isolate Step", globals['doIsolateStep'])
            if globals['doIsolateStep'] then
                globals['isolateStep'] = nukeui:property("Step", 1, globals['isolateStep'],
                    math.floor(hoop.resolution / 2), 1, 1)
            end
            nukeui:layoutRow('dynamic', 25, 1)
            nukeui:label("Image transparency: " .. math.floor(globals['imageTransparency'] * 100) .. "%")
            globals['imageTransparency'] = nukeui:slider(0, globals['imageTransparency'], 1, 0.01)
            nukeui:groupEnd()
        end

    end
    nukeui:windowEnd()

    if nukeui:windowBegin('Evaluator Preview', love.graphics.getWidth() - 300, 0, 300, love.graphics.getHeight(),
        'border', 'minimizable', 'title', 'scrollbar') then
        nukeui:layoutRow('dynamic', 15, 1)
        nukeui:label(string.format("Current Error: %.4f%%", evaluator.currentError * 100))
        nukeui:label(string.format("Temperature: %.4f", evaluator.temperature))
        -- debug info
        -- string counts/cycles
        local c = hoop.resolution
        if globals['doIsolateStep'] then
            c = globals['isolateStep'] ~= #hoop.nails / 2 and #hoop.nails or #hoop.nails / 2
            if hoop.nailRadius > 0 then
                c = c * 4
            end
            nukeui:label("Cycles: " .. gcd(#hoop.nails, globals['isolateStep']))
        else
            c = (hoop.nailRadius > 0 and 4 or 1) * (c * (c - 1)) / 2
        end
        nukeui:layoutRow('dynamic', 35, 1)
        -- nukeui:label("Max Strings: " .. c)
        -- nukeui:label("Active Strings: " .. hoop.stringCount, 'wrap' --[[,hoop.stringCount == c and '#FFFFFF' or '#FF0000']] )
        nukeui:label(string.format("Active Strings:\n%d/%d (%.2f%%)", hoop.stringCount, c, hoop.stringCount / c * 100),
            'wrap')
        nukeui:layoutRow('dynamic', 35, 1)

        nukeui:label(string.format("Total Render Time: %s\nFPS: %s", timestring(globals.totalEvaluationTime),
            love.timer.getFPS()))
        local _, _, ww, _ = nukeui:windowGetBounds()
        -- target image
        nukeui:layoutRow('dynamic', ww * 2, 1)
        if nukeui:groupBegin('Evaluator Images') then
            nukeui:layoutRow('dynamic', 1, 1) -- dummy row so we can get bounds.
            local _, _, w, _ = nukeui:widgetBounds()
            nukeui:layoutRow('dynamic', w, 1)
            nukeui:image(scaledIm)
            nukeui:layoutRow('dynamic', w, 1)
            nukeui:image(love.graphics.newImage(evaluator.currentImageData))
            nukeui:groupEnd()
        end
        -- error image

        -- error graph

    end
    nukeui:windowEnd()
    nukeui:frameEnd()
end

-- wack.
-- param is what we're changing, min and max are the range of possible values, and callback
-- is a function to call once the change has been made
-- personally i think it's weird that nuklear doesn't handle things like this by default but
function ui:slider(param, min, max, step, callback)
    local v = {
        value = param
    }
    local changed = nukeui:slider(min, v, max, step)
    if changed then
        callback(v.value)
    end
end

function ui.draw()
    nukeui:draw()
end

--[[
    strictly speaking these shouldn't live here, since they're
    LOVE callbacks and i think those should always live in `main.lua`.
    i didn't want to write a wrapper for a wrapper, so here we are.
]]

function love.keypressed(key, scancode, isrepeat)
    if nukeui:keypressed(key, scancode, isrepeat) then
        return -- event consumed
    end
end

function love.keyreleased(key, scancode)
    if nukeui:keyreleased(key, scancode) then
        return -- event consumed
    end
end

local mouseHeld = false

function love.mousepressed(x, y, button, istouch, presses)
    if nukeui:mousepressed(x, y, button, istouch, presses) then
        return -- event consumed
    end
    if button == 1 then
        mouseHeld = true
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    if nukeui:mousereleased(x, y, button, istouch, presses) then
        return -- event consumed
    end
    mouseHeld = false
end

function love.mousemoved(x, y, dx, dy, istouch)
    if nukeui:mousemoved(x, y, dx, dy, istouch) then
        return -- event consumed
    end
    if mouseHeld then
        globals['xOffset'] = globals['xOffset'] + dx
        globals['yOffset'] = globals['yOffset'] + dy
    end
end

function love.textinput(text)
    if nukeui:textinput(text) then
        return -- event consumed
    end
end

function love.wheelmoved(x, y)
    if nukeui:wheelmoved(x, y) then
        return -- event consumed
    end
    -- zoom in/out on preview.
    local dz = -globals['ppu'] / y * 0.1
    globals['ppu'] = globals['ppu'] + dz
    if globals['ppu'] < 0.01 then
        globals['ppu'] = 0.01
    end
    print(globals['ppu'])
    -- TODO realign offset to keep the area under the mouse the same...

end
