evaluator = {
    targetImageData = nil,
    currentImageData = nil,
    temperature = 0,
    currentError = 0,
    errorHistory = {}
}

-- might not need to have its own state for this stuff tbh.
-- that or it'll handle all the image/canvas generation stuff currently in main
function evaluator.load(targetImageData)
    evaluator.targetImageData = targetImageData
end

function evaluator.update(delta)
    if temperature ~= 0 then
        return
    end
    -- get a neighbor.

    -- find the error of the neighbor, compare it to our current error, and decide if we
    -- want to accept it

    -- decrease temperature, if it's time.
end

--- calculate the error ("heat") between targetImage and generatedImage, defined here as the
--- sum of the differences in pixel brightness for every pixel in the images that's contained within
--- the hoop, normalized to ... something. possibly just the total number of pixels.
function evaluator.getError()
    local totalError = 0
    local w, h = evaluator.targetImageData:getDimensions()
    for i = 1, w do
        for j = 1, h do
            -- make sure we're within the hoop.
            if math.sqrt(i * i + j * j) <= hoopRadius * canvasPPU then
                -- only taking one return value is ok for grayscale since all components should be the same.
                local t = targetImagedata.getPixel(i, j)
                local g = generatedImageData.getPixel(i, j)
                totalError = totalError + math.abs(g - t)
            end
        end
    end
    return totalError / (w * h)
end
