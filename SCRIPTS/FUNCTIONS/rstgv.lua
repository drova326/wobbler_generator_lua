local gvRoll = 0 -- Global variable index for Roll
local gvPitch = 1 -- Global variable index for Pitch
local gvStatus = 2 -- Global variable for status (running)
local gvAmplitude = 3 -- Global variable for Amplitude
local gvSpeed = 4 -- Global variable for Speed (x10 to store as integer)

local is_reset = 0

local function reset_global()  
    if is_reset == 0 then
    	model.setGlobalVariable(gvStatus, 0, 0)
        model.setGlobalVariable(gvRoll, 0, 0)
        model.setGlobalVariable(gvPitch, 0, 0)
        is_reset = 1
    end
end

return { run = reset_global }
