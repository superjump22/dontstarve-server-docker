local WorldGen = require 'inject_toolbox/generate_worldgenoverride'

local function run()
    WorldGen.GenerateOverride('forest', true)
    WorldGen.GenerateOverride('forest', false)
    WorldGen.GenerateOverride('cave', true)
    WorldGen.GenerateOverride('cave', false)
    Shutdown()
end

run()
