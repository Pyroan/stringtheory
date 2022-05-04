im = love.image.newImageData(globals['imageName'])

--- scale an image to the given pixel dimensions,
--- using Nearest Neighbor because anything else would be difficult.
---@param image love.image.ImageData
---@param newWidth integer
---@param newHeight integer
---@return love.image.ImageData
function scaleImage(image, newWidth, newHeight)
    -- but moommmmm i don't wannaaaa
    local w, h = image:getDimensions()
    local newImage = love.image.newImageData(newWidth, newHeight)
    for i = 1, newWidth do
        for j = 1, newHeight do
        end
    end
    return nil
end
