require("constants")
require("hoop")

function love.load()
    initHoop(constants['hoopResolution'], constants['hoopRadius'], constants['nailWidth'])
end

function love.update()
end

function love.draw()
    drawHoop(constants['nailWidth'])
end
