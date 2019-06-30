-- B21
-- 
print("b21_gmeter.lua starting")

-- WRITE datarefs
-- angle of main section of yawstring (i.e. yaw)
local DATAREF_G_MIN = createGlobalPropertyf("b21/gmeter/min_g", 1.0, false, true, true)
local DATAREF_G_MAX = createGlobalPropertyf("b21/gmeter/max_g", 1.0, false, true, true)

-- READ datarefs
local DATAREF_G = globalPropertyf("sim/flightmodel/forces/g_nrml")

local g_min = 1.0
local g_max = 1.0

function update()
    local g = get(DATAREF_G)
    
    if g < g_min
    then
        g_min = g
        set(DATAREF_G_MIN, g)
    elseif g > g_max
    then
        g_max = g
        set(DATAREF_G_MAX, g)
    end
end
