require "globals"
require "imageprocessing"
require "hoop"
require "ui"
require "util"

function love.load()
    love.window.setMode(1280, 720)
    love.window.setTitle("Vi's String Theory")
    love.graphics.setDefaultFilter("nearest")
    love.graphics.setBackgroundColor(love.math.colorFromBytes(131, 59, 142))

    ui.load()

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

    -- string canvas setup
    -- the string canvas isn't actually drawn to the screen, but generated for the sake of our error evaluation.
    -- unfortunately this means that every string is drawn twice per frame.
    stringCanvas = love.graphics.newCanvas(globals['evaluatorResolution'], globals['evaluatorResolution'])
    canvasPPU = 1 --- TODO Figure out how to calculate this, babe.
end

function love.update(delta)
    ui.update(delta)
    initHoop(globals['hoopResolution'], globals['hoopRadius'], globals['nailWidth'], 0)
end

function love.draw()
    drawHoop(globals['nailWidth'])
    ui.draw()
    love.graphics.setColor(1, 1, 1, 0.2)
    -- align/scale image so that it's the same size as the hoop.
    local imScaleFactor = 2 * globals['hoopRadius'] / im:getWidth()
    local imX = (love.graphics.getWidth() - imScaleFactor * im:getWidth()) / 2
    local imY = (love.graphics.getHeight() - imScaleFactor * im:getHeight()) / 2
    love.graphics.draw(im, imX, imY, 0, imScaleFactor, imScaleFactor)

    love.graphics.setCanvas()
end

