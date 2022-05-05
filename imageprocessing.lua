--- scale an image to the given pixel dimensions,
--- using Nearest Neighbor because anything else would be difficult.
---@param image love.image.ImageData
---@param newWidth integer
---@param newHeight integer
---@return love.image.ImageData
function scaleImageData(imageData, newWidth, newHeight)
    -- but moommmmm i don't wannaaaa
    local oldWidth, oldHeight = imageData:getDimensions()
    -- handle x and y dimensions one at a time
    -- if the new size is smaller, we just need to sample pictures from the original
    -- if it's bigger, we need to interpolate
    local widthAdjustedImageData = love.image.newImageData(newWidth, oldHeight)
    -- handle x axis
    if newWidth <= oldWidth then
        local skip = oldWidth / newWidth
        -- sampling
        for i = 0, newWidth-1 do
            for j = 0, oldHeight-1 do
                widthAdjustedImageData:setPixel(i, j, imageData:getPixel(math.floor(i*skip+0.5),j))
            end
        end
    else
        -- interpolation
    end
    local finalImageData = love.image.newImageData(newWidth, newHeight)
    --handle y axis
    if newHeight <= oldHeight then
        local skip = oldHeight / newHeight
        -- sampling
        for i = 0, newWidth-1 do
            for j = 0, newHeight-1 do
                finalImageData:setPixel(i,j,widthAdjustedImageData:getPixel(i,math.floor(j*skip+0.5)))
            end
        end
    else
        --interpolation
    end
    return finalImageData
end

--- converts imageData to grayscale using luminance function
---@param imageData love.image.ImageData
---@return love.image.ImageData "a copy of imageData in grayscale"
function toGrayscale(imageData)
    id = imageData:clone()
    id:mapPixel(function(x, y, r, g, b, a)
        local y = luminance(r, g, b)
        return y, y, y, a
    end)
    return id
end

--- return the grayscale value (0..1 inclusive)
--- of the given rgb pixel
function luminance(r, g, b)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b
end
