local state = require "appstate"
require "evaluator"
require "globals"
require "hoop"
require "imageprocessing"
require "ui"
require "util"

function love.load()
    love.window.setMode(1600, 900, {
        resizable = true
    })
    love.window.setTitle("Vi's String Theory")
    love.graphics.setDefaultFilter("nearest")
    love.graphics.setBackgroundColor(love.math.colorFromBytes(131, 59, 142))

    ui.load()
    hoop.load(globals['hoopResolution'], globals['hoopRadius'], globals['nailWidth'], 0)

    -- image setup
    imdata = love.image.newImageData(globals['imageName'])
    im = love.graphics.newImage(imdata)
    print("Image format: " .. imdata:getFormat())
    -- convert image to black and white if it isn't already.
    imdata = toGrayscale(imdata)
    -- print sample of image so we know things are working.
    print("Image sample:")
    for i = 1, imdata:getWidth(), imdata:getWidth() / 7 do
        local s = "\t"
        for j = 1, imdata:getHeight(), imdata:getHeight() / 7 do
            s = s .. string.format("[%.3f]", imdata:getPixel(i, j)) .. ' '
        end
        print(s)
    end
    imdata = scaleImageData(imdata, globals['evaluatorResolution'], globals['evaluatorResolution'])
    scaledIm = love.graphics.newImage(imdata)

    -- string canvas setup
    -- the string canvas isn't actually drawn to the screen, but generated for the sake of our error evaluation.
    -- unfortunately this means that every string is drawn twice per frame.
    stringCanvas = love.graphics.newCanvas(globals['evaluatorResolution'], globals['evaluatorResolution'])

    canvasPPU = (2 * globals['hoopRadius']) / math.min(stringCanvas:getDimensions())
    print(string.format("Canvas PPU: %.3f", canvasPPU))

    evaluator.load(imData)
end

function love.update(delta)
    ui.update(delta)
    hoop.update(delta)

    -- draw the hoop to the string canvas.
    canvasPPU = (2 * globals['hoopRadius']) / math.min(stringCanvas:getDimensions())
    love.graphics.setCanvas(stringCanvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.circle('fill', stringCanvas:getWidth() / 2, stringCanvas:getHeight() / 2, stringCanvas:getWidth() / 2)

    love.graphics.setLineWidth(globals['stringWidth'] * canvasPPU)
    love.graphics.setColor(0, 0, 0, 1)
    hoop.draw(stringCanvas:getWidth() / 2, stringCanvas:getHeight() / 2, globals['nailWidth'], canvasPPU, stringCanvas)

    -- reset anything we may have messed up.
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(1)
    love.graphics.setCanvas()
end

function love.draw()
    -- uncomment to force hoop to render as big as possible
    -- globals['ppu'] = (2 * globals['hoopRadius']) / math.min(love.graphics.getDimensions())
    love.graphics.setColor(1, 1, 1, globals['imageTransparency'])
    -- align/scale image so that it's the same size/location as the hoop.
    local imScaleFactor = 2 * globals['hoopRadius'] / im:getWidth()
    imScaleFactor = imScaleFactor / globals['ppu']
    local imX = (love.graphics.getWidth() - imScaleFactor * im:getWidth()) / 2
    local imY = (love.graphics.getHeight() - imScaleFactor * im:getHeight()) / 2
    love.graphics.draw(im, imX, imY, 0, imScaleFactor, imScaleFactor)

    -- draw the main preview of the hoop
    love.graphics.setColor(0, 0, 0, 0.4)
    hoop.draw(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, globals['nailWidth'], globals['ppu'])
    love.graphics.setColor(1, 1, 1, 1)

    ui.draw()

    -- reset color 
    love.graphics.setColor(1, 1, 1, 1)
end

