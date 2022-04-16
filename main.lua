local nuklear = require "nuklear"
require "globals"
require "hoop"
require "util"

local ui
function love.load()
    love.window.setMode(1280, 720)
    love.window.setTitle("Vi's String Theory")
    ui = nuklear.newUI()
    initHoop(globals['hoopResolution'], globals['hoopRadius'], globals['nailWidth'])
end

angle = 0
function love.update(delta)
    ui:frameBegin()
    if ui:windowBegin('Settings', 0, 0, 180, love.graphics.getHeight(), 'border', 'movable', 'minimizable', 'title') then
        ui:layoutRow('dynamic', 35, 1)
        ui:label("Nail Radius: " .. globals['nailWidth'])
        globals['nailWidth'] = ui:slider(0, globals['nailWidth'], 100, 1)

        ui:label("Hoop Radius: " .. globals['hoopRadius'])
        globals['hoopRadius'] = ui:slider(0, globals['hoopRadius'], love.graphics.getHeight() / 2, 1)
        globals['hoopResolution'] = ui:property('Nails', 2, globals['hoopResolution'], 128, 1, 1)
        globals['doIsolateStep'] = ui:checkbox("Isolate Step", globals['doIsolateStep'])
        if globals['doIsolateStep'] then
            globals['isolateStep'] = ui:property("Step", 1, globals['isolateStep'],
                math.floor(globals['hoopResolution'] / 2), 1, 1)
        end
        local c = globals['hoopResolution']
        if globals['doIsolateStep'] then
            c = globals['isolateStep'] ~= #nails / 2 and #nails or #nails / 2
            if globals['nailWidth'] > 0 then
                c = c * 4
            end
            ui:label("Cycles: " .. gcd(#nails, globals['isolateStep'] + 1))
        else
            c = (globals['nailWidth'] > 0 and 4 or 1) * (c * (c - 1)) / 2
        end
        ui:label("Expected Strings: " .. c)
        ui:label("Actual Strings: " .. stringCount, 'wrap', stringCount == c and '#FFFFFF' or '#FF0000')
    end
    ui:windowEnd()
    ui:frameEnd()
    angle = angle + ((1 / 60) * delta * math.pi)
    if angle > 2 * math.pi then
        angle = angle - 2 * math.pi
    end
    initHoop(globals['hoopResolution'], globals['hoopRadius'], globals['nailWidth'], angle)
end

function love.draw()
    drawHoop(globals['nailWidth'])
    ui:draw()
end

function love.keypressed(key, scancode, isrepeat)
    if ui:keypressed(key, scancode, isrepeat) then
        return -- event consumed
    end
end

function love.keyreleased(key, scancode)
    if ui:keyreleased(key, scancode) then
        return -- event consumed
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if ui:mousepressed(x, y, button, istouch, presses) then
        return -- event consumed
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    if ui:mousereleased(x, y, button, istouch, presses) then
        return -- event consumed
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    if ui:mousemoved(x, y, dx, dy, istouch) then
        return -- event consumed
    end
end

function love.textinput(text)
    if ui:textinput(text) then
        return -- event consumed
    end
end

function love.wheelmoved(x, y)
    if ui:wheelmoved(x, y) then
        return -- event consumed
    end
end
