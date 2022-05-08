globals = {
    activeDensity = 0,
    -- Preview settings
    doIsolateStep = false,
    isolateStep = 1,

    ppu = 1,
    xOffset = 0,
    yOffset = 0,
    imageTransparency = 0.0,

    -- evaluator settings
    imageName = "moon.png",
    evaluatorResolution = 500, -- side length of grid used by evaluator function
    stringWidth = 0.5, -- diameter of the string in world units. functionally limited by evaluator resolution.

    iterationsPerTemp = 100, -- number of new states to check before decreasing the temperature
    initialTemp = 1.0,
    volatility = 2 -- max number of strings that can be changed per iteration * `temperature`
}
