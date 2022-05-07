globals = {
    hoopRadius = 350, -- inner radius of the circle defined by the nails, in world units
    hoopResolution = 64, -- number of nails
    nailWidth = 5, -- radius of a nail body, in world units

    doIsolateStep = false,
    isolateStep = 1,

    activeDensity = 0.5,
    ppu = 1,

    imageTransparency = 0.2,
    imageName = "monalisa.bmp",
    evaluatorResolution = 500, -- side length of grid used by evaluator function
    stringWidth = 0.5, -- diameter of the string in world units. functionally limited by evaluator resolution.

    iterationsPerTemp = 100, -- number of new states to check before decreasing the temperature
    initialTemp = 100
}
