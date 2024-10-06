local state = require "appstate"
local nuklear = require "nuklear"
require("globals")

ui = {}
local nukeui
local failedToLoadFile = false
local outputFile = {
    value = "output.json"
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
        nukeui:layoutRow('dynamic', 35, 2)
        local runSelected = state.getState() == 'running'
        local stopSelected = state.getState() == 'idle'
        if nukeui:button('Compute') then
            state.setState("running")
        end
        if nukeui:button('Reset') then
            state.setState("idle")
            hoop.reset()
            evaluator.reset()
            globals['totalEvaluationTime'] = 0
        end
        nukeui:layoutRow('dynamic', 150, 1)
        if nukeui:groupBegin("Hoop Settings", 'title', 'border') then
            nukeui:layoutRow('dynamic', 25, 1)
            -- nail/hoop params
            local t = {
                value = hoop.resolution
            }
            local changed = nukeui:property('Nails', 2, t, globals['maxNails'], 1, 1)
            if changed then
                hoop.onNailResolutionChanged(t.value)
            end

            t = {
                value = hoop.nailRadius
            }
            if nukeui:property('Nail Radius', 0, t, globals['maxNailRadius'], 1, 1) then
                hoop.onNailRadiusChanged(t.value)
            end

            t = {
                value = hoop.radius
            }
            if nukeui:property('Hoop Radius', 0, t, globals['maxHoopRadius'], 1, 1) then
                hoop.onRadiusChanged(t.value)
            end
            nukeui:groupEnd()
        end
        nukeui:layoutRow('dynamic', 200, 1)
        if nukeui:groupBegin("Eval Settings (Advanced)", 'title', 'border') then
            nukeui:layoutRow('dynamic', 25, 1)
            local t = {
                value = globals['errorThreshold']
            }
            if nukeui:property('Err Threshold', 0, t, 1, 0.01, 0.01) then
                evaluator.onThresholdChanged(t.value)
            end
            -- nukeui:layoutRow('dynamic', 25, 1)
            -- nukeui:label("Evaluator Resolution: " .. globals['evaluatorResolution'])
            -- nukeui:layoutRow('dynamic', 25, {0.70, 0.30})
            -- ui:slider(globals['evaluatorResolution'], 8, math.min(im:getDimensions()), 1, function(v)
            --     globals['evaluatorResolution'] = v
            --     initImage()

            -- end)
            -- if nukeui:button("reset") then
            --     globals['evaluatorResolution'] = 500
            --     initImage()
            -- end
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
            nukeui:label("Image opacity: " .. math.floor(globals['imageTransparency'] * 100) .. "%")
            globals['imageTransparency'] = nukeui:slider(0, globals['imageTransparency'], 1, 0.01)
        end
        nukeui:groupEnd()

    end
    nukeui:windowEnd()

    if nukeui:windowBegin('Evaluator Preview', love.graphics.getWidth() - 300, 0, 300, love.graphics.getHeight(),
        'border', 'minimizable', 'title') then
        nukeui:layoutRow('dynamic', 15, 1)
        nukeui:label(string.format("Current Error: %.4f%%", evaluator.currentError * 100))
        -- nukeui:label(string.format("Temperature: %.4f", evaluator.temperature))
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
            nukeui:image(gradient)
            -- nukeui:image(love.graphics.newImage(evaluator.currentImageData))
            nukeui:groupEnd()
        end
        -- error image

        -- error graph

    end
    nukeui:windowEnd()
    nukeui:frameEnd()
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
