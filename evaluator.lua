local appState = require "appstate"
if evaluator ~= nil then
    return
end
evaluator = {
    targetImageData = nil,
    currentImageData = nil,
    currentError = 1,
    errorMap = {},
    stringCanvas = {}
}
local canvasPPU

-- might not need to have its own state for this stuff tbh.
-- that or it'll handle all the image/canvas generation stuff currently in main
function evaluator.load(targetImageData)
    evaluator.targetImageData = targetImageData
    print(string.format("Target dimensions: %d %d", evaluator.targetImageData:getDimensions()))

    evaluator.temperature = globals['initialTemp']
    evaluator.currentError = 1
    -- string canvas setup
    -- the string canvas isn't actually drawn to the screen, but generated for the sake of our error evaluation.
    -- unfortunately this means that every string is drawn twice per frame.
    evaluator.stringCanvas = love.graphics.newCanvas(globals['evaluatorResolution'], globals['evaluatorResolution'])
    print(string.format("Evaluator dimensions: %d %d", evaluator.stringCanvas:getDimensions()))
    canvasPPU = (2 * hoop.radius) / math.min(evaluator.stringCanvas:getDimensions())
    evaluator.currentImageData = evaluator.stringCanvas:newImageData()
    print(string.format("Canvas PPU: %.3f", canvasPPU))
    evaluator.errorMap = {}
end

function evaluator.reset()

    evaluator.load(evaluator.targetImageData)
    -- evaluator.temperature = globals['initialTemp']
    -- evaluator.currentError = 1
end
local iter = 1

function evaluator.update(delta)
    if appState.getState() ~= 'running' then
        return
    end
    canvasPPU = (2 * hoop.radius) / math.min(evaluator.stringCanvas:getDimensions())
    -- evaluate every string
    for i = 1, #hoop.stringState.strings do
        local err = evaluator.getErrorForLine(i)
        evaluator.errorMap[i] = err
    end
    -- apply error values (i'd like to normalize this distribution eventually to make the threshold values more useful but)
    for i = 1, #hoop.stringState.strings do
        if evaluator.errorMap[i] > globals['errorThreshold'] then
            hoop.stringState.strings[i].active = false
        else
            hoop.stringState.strings[i].active = true
        end
    end
    -- for i = 10000, 10100 do
    -- print(evaluator.errorMap[i])
    -- end
    -- errorhist = Histogram:new("Line Error", evaluator.errorMap)
    appState.setState('paused')
end
function evaluator.onThresholdChanged(newValue)
    if #evaluator.errorMap < 1 then
        return
    end
    for i = 1, #hoop.stringState.strings do
        if evaluator.errorMap[i] > newValue then
            hoop.stringState.strings[i].active = false
        else
            hoop.stringState.strings[i].active = true
        end
    end
end

-- return average error value for all pixels in the evaluator
-- that are touched with the line with the given id. lol.
-- though i do wonder if wu's algorithm would give a more nuanced version
-- (by way of being antialiased)
-- maybe consider gamma correction, queen.
function evaluator.getErrorForLine(id)
    local w, h = evaluator.targetImageData:getDimensions()
    -- hey kids i heared you liked line drawing algorithms :D
    local x1, y1, x2, y2 = hoop.stringState.strings[id]:getEndpoints(w * canvasPPU / 2, h * canvasPPU / 2,
        hoop.nailRadius, canvasPPU, evaluator.stringCanvas)
    x1 = math.floor(x1)
    x2 = math.floor(x2)
    y1 = math.floor(y1)
    y2 = math.floor(y2)
    local dx = math.abs(x2 - x1)
    local sx = x1 < x2 and 1 or -1
    local dy = -math.abs(y2 - y1)
    local sy = y1 < y2 and 1 or -1
    local err = dx + dy

    -- length of the line we're looking at, in evaluator pixels
    local len = 0
    -- total error we've seen for this line so far
    local linerr = 0

    while (true) do
        -- x0 and y0 are the current point we're looking at
        if math.sqrt(x1 * x1 + y1 * y1) <= hoop.radius * canvasPPU and x1 > 0 and x1 < w and y1 > 0 and y1 < h then
            len = len + 1
            -- ... it can't be that simple.
            linerr = linerr + ((1 - evaluator.targetImageData:getPixel(x1, y1)) * imgrad:getPixel(x1, y1))
        end

        if x1 == x2 and y1 == y2 then
            break
        end
        local e2 = 2 * err
        if e2 >= dy then
            if x1 == x2 then
                break
            end
            err = err + dy
            x1 = x1 + sx
        end
        if e2 <= dx then
            if y1 == y2 then
                break
            end
            err = err + dx
            y1 = y1 + sy
        end
    end
    if len > 0 then
        return (linerr / len) * (linerr / len)
    else
        return 1
    end
end
