globals = {
    -- hoop settings
    hoopRadius = 350, -- inner radius of the circle defined by the nails, in world units
    hoopResolution = 64, -- number of nails
    nailWidth = 5, -- radius of a nail body, in world units

    activeDensity = 0.08,
    -- Preview settings
    doIsolateStep = false,
    isolateStep = 1,

    ppu = 1,
    xOffset = 0,
    yOffset = 0,
    imageTransparency = 0.2,

    -- evaluator settings
    imageName = "monalisa.bmp",
    evaluatorResolution = 1000, -- side length of grid used by evaluator function
    stringWidth = 0.5, -- diameter of the string in world units. functionally limited by evaluator resolution.

    iterationsPerTemp = 100, -- number of new states to check before decreasing the temperature
    initialTemp = 10
}
