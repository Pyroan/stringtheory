require("constants")
require("hoop")

function love.load()
    initHoop(constants['hoopResolution'], constants['hoopRadius'], constants['nailWidth'])
end

angle = 0
function love.update(delta)
    angle = angle + (0.25 * delta * math.pi)
    if angle > 2 * math.pi then angle = angle - 2 * math.pi end
    initHoop(constants['hoopResolution'], constants['hoopRadius'], constants['nailWidth'], angle)
end

function love.draw()
    drawHoop(constants['nailWidth'])
end
