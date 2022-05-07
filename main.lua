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
    -- love.graphics.setBackgroundColor(1, 1, 1, 1)

    ui.load()
    hoop.load(globals['hoopResolution'], globals['hoopRadius'], globals['nailWidth'], globals['activeDensity'])

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
    evaluator.load(imdata:clone())
end

function love.update(delta)
    ui.update(delta)
    hoop.update(delta)
    evaluator.update(delta)
end

function love.draw()
    -- uncomment to force hoop to render as big as possible
    -- globals['ppu'] = (2 * globals['hoopRadius']) / math.min(love.graphics.getDimensions())
    love.graphics.setColor(1, 1, 1, globals['imageTransparency'])
    -- align/scale image so that it's the same size/location as the hoop.
    local imScaleFactor = 2 * globals['hoopRadius'] / im:getWidth()
    imScaleFactor = imScaleFactor / globals['ppu']
    local imX = globals['xOffset'] + (love.graphics.getWidth() - imScaleFactor * im:getWidth()) / 2
    local imY = globals['yOffset'] + (love.graphics.getHeight() - imScaleFactor * im:getHeight()) / 2
    love.graphics.draw(im, imX, imY, 0, imScaleFactor, imScaleFactor)

    -- draw the main preview of the hoop
    love.graphics.setColor(0, 0, 0, 0.4)
    hoop.draw(globals['xOffset'] + love.graphics.getWidth() / 2, globals['yOffset'] + love.graphics.getHeight() / 2,
        globals['nailWidth'], globals['ppu'])
    love.graphics.setColor(1, 1, 1, 1)

    ui.draw()

    -- reset color 
    love.graphics.setColor(1, 1, 1, 1)
end

