--- scale an image to the given pixel dimensions,
--- using Nearest Neighbor because anything else would be difficult.
---@param image love.image.ImageData
---@param newWidth integer
---@param newHeight integer
---@return love.image.ImageData
function scaleImage(image, newWidth, newHeight)
    -- but moommmmm i don't wannaaaa
    local w, h = image:getDimensions()
    -- if the new size is smaller, we just need to sample pictures from the original
    -- if it's bigger, we need to interpolate
    local newImage = love.image.newImageData(newWidth, newHeight)
    for i = 1, newWidth do
        for j = 1, newHeight do
        end
    end
    return nil
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
