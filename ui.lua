local nuklear = require "nuklear"
require("globals")

ui = {}
local nukeui

function ui.load()
    nukeui = nuklear.newUI()
end

function ui.update(delta)
    nukeui:frameBegin()
    if nukeui:windowBegin('Settings', 0, 0, 180, love.graphics.getHeight(), 'border', 'movable', 'minimizable', 'title') then
        nukeui:layoutRow('dynamic', 35, 1)
        -- nail/hoop params
        nukeui:label("Nail Radius: " .. globals['nailWidth'])
        globals['nailWidth'] = nukeui:slider(0, globals['nailWidth'], 100, 1)
        nukeui:label("Hoop Radius: " .. globals['hoopRadius'])
        globals['hoopRadius'] = nukeui:slider(0, globals['hoopRadius'], love.graphics.getHeight() / 2, 1)
        globals['hoopResolution'] = nukeui:property('Nails', 2, globals['hoopResolution'], 128, 1, 1)
        -- isolated step
        globals['doIsolateStep'] = nukeui:checkbox("Isolate Step", globals['doIsolateStep'])
        if globals['doIsolateStep'] then
            globals['isolateStep'] = nukeui:property("Step", 1, globals['isolateStep'],
                math.floor(globals['hoopResolution'] / 2), 1, 1)
        end
        -- string counts/cycles
        local c = globals['hoopResolution']
        if globals['doIsolateStep'] then
            c = globals['isolateStep'] ~= #nails / 2 and #nails or #nails / 2
            if globals['nailWidth'] > 0 then
                c = c * 4
            end
            nukeui:label("Cycles: " .. gcd(#nails, globals['isolateStep']))
        else
            c = (globals['nailWidth'] > 0 and 4 or 1) * (c * (c - 1)) / 2
        end
        nukeui:label("Expected Strings: " .. c)
        nukeui:label("Actual Strings: " .. stringCount, 'wrap', stringCount == c and '#FFFFFF' or '#FF0000')
        nukeui:label("FPS: " .. love.timer.getFPS())
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
    oh well.
]]

function love.keypressed(key, scancode, isrepeat)
    if ui:keypressed(key, scancode, isrepeat) then
        return -- event consumed
    end
end

function love.keyreleased(key, scancode)
    if nukeui:keyreleased(key, scancode) then
        return -- event consumed
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if nukeui:mousepressed(x, y, button, istouch, presses) then
        return -- event consumed
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    if nukeui:mousereleased(x, y, button, istouch, presses) then
        return -- event consumed
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    if nukeui:mousemoved(x, y, dx, dy, istouch) then
        return -- event consumed
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
end
