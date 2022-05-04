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
            -- ughhhhhh i'm too pretty to deal with this
            --[[
                ok let's think with our brains or whatever
                if the new size is smaller than our current size,
                we need to round/discard unnecessary pixels so we're just taking
                a sample of the full size image basically

                if it's larger, 
                we copy all the known pixels to the bigger image and just
                fill them in with the value of the known pixel they're closest to.
                we could interpolate I guess but like, why do that to myself.
                it could cause problems if the staircasing is somehow replicatedd by the wires
                but like...

                the specifics of how many pixels to fill and which one is nearest and which ones to sample
                all require me to actually use my massive beautiful brain ugh this is Tomorrow Vi's prolem.
            ]]
        end
    end
    return nil
end
