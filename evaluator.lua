local appState = require "appstate"
if evaluator ~= nil then
    return
end
-- alpha should be in [0..temp)
function linearDecrease(temp, alpha)
    return math.max(temp - alpha, 0)
end

-- alpha should be in [0..1)
function multiplicativeDecrease(temp, alpha)
    return temp * alpha
end

-- beta should be.... i'm not sure
-- nor do i know why it's called beta
function slowDecrease(temp, beta)
    return temp / (1 + beta * temp)
end

evaluator = {
    targetImageData = nil,
    currentImageData = nil,
    temperature = 0,
    currentError = 1,
    errorHistory = {},
    tempDecreaseFunc = slowDecrease,
    stringCanvas = {}
}
local canvasPPU
local itersThisTemp = 0

-- might not need to have its own state for this stuff tbh.
-- that or it'll handle all the image/canvas generation stuff currently in main
function evaluator.load(targetImageData)
    evaluator.targetImageData = targetImageData
    print(string.format("Target dimensions: %d %d", evaluator.targetImageData:getDimensions()))

    evaluator.temperature = globals['initialTemp']
    -- string canvas setup
    -- the string canvas isn't actually drawn to the screen, but generated for the sake of our error evaluation.
    -- unfortunately this means that every string is drawn twice per frame.
    evaluator.stringCanvas = love.graphics.newCanvas(globals['evaluatorResolution'], globals['evaluatorResolution'])
    print(string.format("Evaluator dimensions: %d %d", evaluator.stringCanvas:getDimensions()))
    canvasPPU = (2 * globals['hoopRadius']) / math.min(evaluator.stringCanvas:getDimensions())
    evaluator.currentImageData = evaluator.stringCanvas:newImageData()
    print(string.format("Canvas PPU: %.3f", canvasPPU))
end

function evaluator.reset()
    evaluator.temperature = globals['initialTemp']
    evaluator.currentError = 1
end

function evaluator.update(delta)
    if evaluator.temperature <= 0.00001 then
        appState.setState('paused')
        return
    end
    if appState.getState() ~= 'running' then
        return
    end
    canvasPPU = (2 * globals['hoopRadius']) / math.min(evaluator.stringCanvas:getDimensions())
    -- get a neighbor.
    local old = hoop.stringState
    hoop.stringState = hoop.stringState:neighbor(math.floor(
        math.random(1, evaluator.temperature * globals['volatility'])))
    -- generate our imagedata for it
    love.graphics.setCanvas(evaluator.stringCanvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.circle('fill', evaluator.stringCanvas:getWidth() / 2, evaluator.stringCanvas:getHeight() / 2,
        evaluator.stringCanvas:getWidth() / 2)

    love.graphics.setLineWidth(globals['stringWidth'] * canvasPPU)
    love.graphics.setColor(0, 0, 0, 0.5)
    hoop.draw(evaluator.stringCanvas:getWidth() / 2, evaluator.stringCanvas:getHeight() / 2, globals['nailWidth'],
        canvasPPU, evaluator.stringCanvas)

    evaluator.currentImageData = evaluator.stringCanvas:newImageData()
    -- reset anything we may have messed up.
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(1)
    love.graphics.setCanvas()
    -- find the error of the neighbor, compare it to our current error, and decide if we
    -- want to accept it
    local newError = evaluator.getError(evaluator.currentImageData, evaluator.targetImageData)
    local dE = newError - evaluator.currentError
    local p = math.exp(-dE * 1000000 / evaluator.temperature)
    if dE <= 0 or love.math.random() < p then
        if dE > 0 then
            print(dE, p)
        end
        -- accept it
        evaluator.currentError = newError
    else
        hoop.stringState = old
    end
    -- decrease temperature, if it's time.
    itersThisTemp = itersThisTemp + 1
    if itersThisTemp >= globals['iterationsPerTemp'] then
        evaluator.temperature = evaluator.tempDecreaseFunc(evaluator.temperature, 0.01)
        itersThisTemp = 0
    end

    -- draw the current state to the string canvas.

end

--- calculate the error ("heat") between targetImage and generatedImage, defined here as the
--- sum of the differences in pixel brightness for every pixel in the images that's contained within
--- the hoop, normalized to ... something. possibly just the total number of pixels.
--- in the future we can use the # of strings as a factor as well, so we can use as little material as possible
function evaluator.getError(currentImageData, targetImageData)
    local totalError = 0
    local w, h = targetImageData:getDimensions()
    for i = 0, w - 1 do
        for j = 0, h - 1 do
            -- make sure we're within the hoop.
            local xOff = i - w / 2
            local yOff = j - h / 2
            if math.sqrt(xOff * xOff + yOff * yOff) <= globals['hoopRadius'] * canvasPPU then
                -- only taking one return value is ok for grayscale since all components should be the same.
                local t = targetImageData:getPixel(i, j)
                local g = currentImageData:getPixel(i, j)
                local err = g - t
                -- if err < 0 then
                --     -- pixel is too dark, which is worse than being too light.
                --     err = math.sqrt(math.abs(err))
                -- end
                -- pixels closer to the center matter more
                -- err = err *
                --           (1 - math.pow(math.sqrt(xOff * xOff + yOff * yOff) / (globals['hoopRadius'] * canvasPPU), 10))
                totalError = totalError + math.abs(err)
            end
        end
    end
    return totalError / (w * h)
end
