local nuklear = require "nuklear"
require "constants"
require "hoop"

local ui
function love.load()
    love.window.setMode(1280, 720)
    ui = nuklear.newUI()
    initHoop(constants['hoopResolution'], constants['hoopRadius'], constants['nailWidth'])
end

angle = 0
function love.update(delta)
    ui:frameBegin()
    if ui:windowBegin('Settings', 0, 0, 180, love.graphics.getHeight(), 'border', 'movable', 'minimizable', 'title') then
        ui:layoutRow('dynamic', 35, 1)
        ui:label("Nail Radius: "..constants['nailWidth'])
        constants['nailWidth'] = ui:slider(0, constants['nailWidth'], 100, 1)

        ui:label("Hoop Radius: "..constants['hoopRadius'])
        constants['hoopRadius'] = ui:slider(0, constants['hoopRadius'], love.graphics.getHeight() / 2, 1)
        constants['hoopResolution'] = ui:property('Nails', 2, constants['hoopResolution'], 128, 1, 1)
        local c = constants['hoopResolution']
        c = (constants['nailWidth'] > 0 and 4 or 1) * (c * (c-1)) / 2
        ui:label("Expected Strings: ".. c)
        ui:label("Actual Strings: ".. strings, 'wrap', strings == c and '#FFFFFF' or '#FF0000')
    end
    ui:windowEnd()
    ui:frameEnd()
    angle = angle + ((1/60) * delta * math.pi)
    if angle > 2 * math.pi then angle = angle - 2 * math.pi end
    initHoop(constants['hoopResolution'], constants['hoopRadius'], constants['nailWidth'], angle)
end

function love.draw()
    drawHoop(constants['nailWidth'])
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