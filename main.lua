-- flux = require "ext.flux"
local state = require "appstate"
require "evaluator"
require "globals"
require "hoop"
require "histogram"
require "imageprocessing"
require "ui"
require "util"

function love.load(args)
    love.window.setMode(1600, 900, {
        resizable = true
    })
    love.graphics.setDefaultFilter("nearest")
    love.graphics.setBackgroundColor(1, 1, 1, 1)

    ui.load()
    hoop.load(globals['activeDensity'])

    if #args > 0 then
        globals.imageName = args[1]
    end
    initImage()
    -- errorhist = Histogram:new("Empty", {})
end

-- i don't know where to put this yet.
function initImage()
    -- image setup
    imdata = love.image.newImageData(globals['imageName'])
    im = love.graphics.newImage(imdata)
    -- convert image to black and white if it isn't already.
    imdata = toGrayscale(imdata)
    imdata = scaleImageData(imdata, globals['evaluatorResolution'], globals['evaluatorResolution'])
    scaledIm = love.graphics.newImage(imdata)
    imgrad = sobel(imdata)
    gradient = love.graphics.newImage(imgrad)
    evaluator.load(imdata:clone())
end

function love.update(delta)
    ui.update(delta)
    evaluator.update(delta)
    if state.getState() == 'running' then
        -- update total evaluation time.
        globals.totalEvaluationTime = globals.totalEvaluationTime + delta
    end
end

function love.draw()
    -- uncomment to force hoop to render as big as possible
    -- globals['ppu'] = (2 * globals['hoopRadius']) / math.min(love.graphics.getDimensions())
    love.graphics.setColor(1, 1, 1, globals['imageTransparency'])
    -- align/scale image so that it's the same size/location as the hoop.
    local imScaleFactor = 2 * hoop.radius / im:getWidth()
    imScaleFactor = imScaleFactor / globals['ppu']
    local imX = globals['xOffset'] + (love.graphics.getWidth() - imScaleFactor * im:getWidth()) / 2
    local imY = globals['yOffset'] + (love.graphics.getHeight() - imScaleFactor * im:getHeight()) / 2
    love.graphics.draw(im, imX, imY, 0, imScaleFactor, imScaleFactor)

    -- draw the main preview of the hoop
    love.graphics.setColor(0, 0, 0, 0.1)
    hoop.draw(globals['xOffset'] + love.graphics.getWidth() / 2, globals['yOffset'] + love.graphics.getHeight() / 2,
        globals['ppu'])
    love.graphics.setColor(1, 1, 1, 1)

    ui.draw()

    -- reset color 
    love.graphics.setColor(1, 1, 1, 1)

    -- errorhist:draw(100,100,320,200)
end

