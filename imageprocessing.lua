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
    -- if the new size is smaller, we just need to sample pixels from the original
    -- if it's bigger, we need to interpolate
    local widthAdjustedImageData = love.image.newImageData(newWidth, oldHeight)
    -- handle x axis
    if newWidth <= oldWidth then
        local skip = oldWidth / newWidth
        -- sampling
        for i = 0, newWidth - 1 do
            for j = 0, oldHeight - 1 do
                widthAdjustedImageData:setPixel(i, j, imageData:getPixel(math.floor(i * skip + 0.5), j))
            end
        end
    else
        -- TODO interpolation
        error("The target resolution is larger than the image, and we can't handle that yet!")
    end
    local finalImageData = love.image.newImageData(newWidth, newHeight)
    -- handle y axis
    if newHeight <= oldHeight then
        local skip = oldHeight / newHeight
        -- sampling
        for i = 0, newWidth - 1 do
            for j = 0, newHeight - 1 do
                finalImageData:setPixel(i, j, widthAdjustedImageData:getPixel(i, math.floor(j * skip + 0.5)))
            end
        end
    else
        -- TODO interpolation
        error("The target resolution is larger than the image, and we can't handle that yet!")
    end
    return finalImageData
end

--- converts imageData to grayscale using luminance function
---@param imageData love.image.ImageData
---@return love.image.ImageData "a copy of imageData in grayscale"
function toGrayscale(imageData)
    local id = imageData:clone()
    id:mapPixel(function(x, y, r, g, b, a)
        local y = luminance(r, g, b)
        return y, y, y, a
    end)
    return id
end

--- returns the normalized gradient of imageData using a sobel filter.
--- if i gotta do more convolving later this is where i'm gonna have to do it :\
--- todo denoising, maybe.
function sobel(imageData)
    local xkernel = {{1, 0, -1}, {2, 0, -2}, {1, 0, -1}}
    local ykernel = {{1, 2, 1}, {0, 0, 0}, {-1, -2, -1}}
    local w, h = imageData:getDimensions()
    local tmpgrad = {}
    local gradient = love.image.newImageData(w, h)
    local maxvalue = 0
    local minvalue = 1
    for i = 0, w - 1 do
        tmpgrad[i] = {}
        for j = 0, h - 1 do
            -- apply le kernel <3
            local vx = 0
            local vy = 0
            for k = 1, 3 do
                for l = 1, 3 do
                    local a = i + k - 2
                    local b = j + l - 2
                    a = math.max(math.min(a, w - 1), 0)
                    b = math.max(math.min(b, h - 1), 0)
                    local p = imageData:getPixel(a, b)
                    vx = vx + (p * xkernel[k][l])
                    vy = vy + (p * ykernel[k][l])
                end
            end
            local v = math.sqrt(vx*vx + vy*vy)
            if v > maxvalue then
                maxvalue = v
            end
            if v < minvalue then
                minvalue = v
            end
            tmpgrad[i][j] = v
        end
    end
    -- normalize the gradient
    local newmax = 0
    local newmin = 1
    for i = 0, w - 1 do
        for j = 0, h - 1 do
            local v = tmpgrad[i][j]
            v =  (v - minvalue) / (maxvalue - minvalue)
            gradient:setPixel(i,j,v,v,v)
            if v>newmax then newmax = v end
            if v<newmin then newmin = v end
        end
    end
    print("max="..newmax..", min="..newmin)
    return gradient
end

--- return the grayscale value (0..1 inclusive)
--- of the given rgb pixel
function luminance(r, g, b)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b
end
