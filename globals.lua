globals = {
    activeDensity = 0,
    -- Preview settings
    doIsolateStep = false,
    isolateStep = 1,

    scaleFactor = 1,
    xOffset = 0,
    yOffset = 0,
    imageOpacity = 0.1,

    -- Hoop Settings
    maxNails = 360,
    maxNailRadius = 100,
    maxHoopRadius = 500,

    -- evaluator settings
    imageName = "data/dot.png",
    evaluatorResolution = 500, -- side length of grid used by evaluator function
    stringWidth = 1, -- diameter of the string in world units. functionally limited by evaluator resolution.

    errorThreshold = 0.2, -- maximum error a string can have before we deactivate it.

    --- basically a measure of how likely a line is to get toggled based on its fitness
    --- a value of 0 means that if a line is over the threshold it's off, and a line under the threshold is on,
    --- a value of 1 means that even values way way far from the threshold could still be toggled.
    --- unforch this is is somewhat nondeterministic out of necessity.
    --- todo actually implement this
    fuzziness = 0.0,

    totalEvaluationTime = 0,
    justSaved = false, -- true if nothing has changed since the last time we saved the state.

    -- UI formatting constants because ui.lua is a mess.
    ui = {
        buttonHeight = 20
    }
}
