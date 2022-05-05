local nuklear = require "nuklear"
require "globals"
require "imageprocessing"
require "hoop"
require "util"

local ui
function love.load()
    love.window.setMode(1280, 720)
    love.window.setTitle("Vi's String Theory")
    love.graphics.setDefaultFilter("nearest")
    love.graphics.setBackgroundColor(love.math.colorFromBytes(131, 59, 142))
    ui = nuklear.newUI()
    initHoop(globals['hoopResolution'], globals['hoopRadius'], globals['nailWidth'], 0)

    -- image setup
    imdata = love.image.newImageData(globals['imageName'])
    print(imdata:getFormat())
    -- convert image to black and white if it isn't already.
    imdata = toGrayscale(imdata)
    -- print sample of image so we know things are working.
    for i = 1, imdata:getWidth(), imdata:getWidth() / 7 do
        local s = ""
        for j = 1, imdata:getHeight(), imdata:getHeight() / 7 do
            s = s .. string.format("[%.3f]", imdata:getPixel(i, j)) .. ' '
        end
        print(s)
    end
    imdata = scaleImageData(imdata, globals['evaluatorResolution'], globals['evaluatorResolution'])
    im = love.graphics.newImage(imdata)
end

function love.update(delta)
    ui:frameBegin()
    if ui:windowBegin('Settings', 0, 0, 180, love.graphics.getHeight(), 'border', 'movable', 'minimizable', 'title') then
        ui:layoutRow('dynamic', 35, 1)
        -- nail/hoop params
        ui:label("Nail Radius: " .. globals['nailWidth'])
        globals['nailWidth'] = ui:slider(0, globals['nailWidth'], 100, 1)
        ui:label("Hoop Radius: " .. globals['hoopRadius'])
        globals['hoopRadius'] = ui:slider(0, globals['hoopRadius'], love.graphics.getHeight() / 2, 1)
        globals['hoopResolution'] = ui:property('Nails', 2, globals['hoopResolution'], 128, 1, 1)
        -- isolated step
        globals['doIsolateStep'] = ui:checkbox("Isolate Step", globals['doIsolateStep'])
        if globals['doIsolateStep'] then
            globals['isolateStep'] = ui:property("Step", 1, globals['isolateStep'],
                math.floor(globals['hoopResolution'] / 2), 1, 1)
        end
        -- string counts/cycles
        local c = globals['hoopResolution']
        if globals['doIsolateStep'] then
            c = globals['isolateStep'] ~= #nails / 2 and #nails or #nails / 2
            if globals['nailWidth'] > 0 then
                c = c * 4
            end
            ui:label("Cycles: " .. gcd(#nails, globals['isolateStep']))
        else
            c = (globals['nailWidth'] > 0 and 4 or 1) * (c * (c - 1)) / 2
        end
        ui:label("Expected Strings: " .. c)
        ui:label("Actual Strings: " .. stringCount, 'wrap', stringCount == c and '#FFFFFF' or '#FF0000')
    end
    ui:windowEnd()
    ui:frameEnd()
    initHoop(globals['hoopResolution'], globals['hoopRadius'], globals['nailWidth'], 0)
end

function love.draw()
    drawHoop(globals['nailWidth'])
    ui:draw()
    love.graphics.setColor(1, 1, 1, 0.2)
    -- align/scale image so that it's the same size as the hoop.
    local imScaleFactor = 2 * globals['hoopRadius'] / im:getWidth()
    local imX = (love.graphics.getWidth() - imScaleFactor * im:getWidth()) / 2
    local imY = (love.graphics.getHeight() - imScaleFactor * im:getHeight()) / 2
    love.graphics.draw(im, imX, imY, 0, imScaleFactor, imScaleFactor)
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
