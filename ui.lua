local state = require "appstate"
local nuklear = require "nuklear"
require("globals")

ui = {}
local nukeui

function ui.load()
    nukeui = nuklear.newUI()
end

function ui.update(delta)
    nukeui:frameBegin()
    if nukeui:windowBegin('Settings', 0, 0, 180, love.graphics.getHeight(), 'border', 'minimizable', 'title') then
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
        --- TODO Save/Load/Generate random StringState
        -- set string density (% of strings to make active), add a "generate" button, etc
        nukeui:layoutRow('dynamic', 25, 1)
        nukeui:label(string.format("Active Density: %d%%", math.floor(globals['activeDensity'] * 100)))
        globals['activeDensity'] = nukeui:slider(0, globals['activeDensity'], 1, 0.01)
        if nukeui:button("Generate Random State") then
            hoop.load(globals['activeDensity'])
        end
        -- TODO evaluator configuration
        nukeui:layoutRow('dynamic', 25, 1)
        nukeui:layoutRow('dynamic', 25, 1)
        nukeui:label("Volatility: " .. globals['volatility'])
        globals['volatility'] = nukeui:slider(0, globals['volatility'], 10, 1)
        nukeui:layoutRow('dynamic', 25, 1)
        --- set initial temp, iterations per temp, temp decease function, etc.
        -- nail/hoop params
        nukeui:layoutRow('dynamic', 25, 1)
        nukeui:label("Nail Radius: " .. hoop.nailRadius)
        hoop.nailRadius = nukeui:slider(0, hoop.nailRadius, 100, 1)
        nukeui:label("Hoop Radius: " .. hoop.radius)
        hoop.radius = nukeui:slider(0, hoop.radius, love.graphics.getHeight() / 2, 1)
        hoop.resolution = nukeui:property('Nails', 2, hoop.resolution, 128, 1, 1)
        -- isolated step
        globals['doIsolateStep'] = nukeui:checkbox("Isolate Step", globals['doIsolateStep'])
        if globals['doIsolateStep'] then
            globals['isolateStep'] = nukeui:property("Step", 1, globals['isolateStep'], math.floor(hoop.resolution / 2),
                1, 1)
        end

        nukeui:label("Image transparency: " .. math.floor(globals['imageTransparency'] * 100) .. "%")
        globals['imageTransparency'] = nukeui:slider(0, globals['imageTransparency'], 1, 0.01)

    end
    nukeui:windowEnd()

    if nukeui:windowBegin('Evaluator Preview', love.graphics.getWidth() - 300, 0, 300, love.graphics.getHeight(),
        'border', 'minimizable', 'title') then
        local winX, winY, winW, winH = nukeui:windowGetBounds()
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
        -- target image
        nukeui:image(scaledIm, winX, winY + 155, winW, winW)
        -- stringCanvas image
        nukeui:image(love.graphics.newImage(evaluator.currentImageData), winX, winY + winW + 155, winW, winW) -- this is gonna be icky and slow.
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
