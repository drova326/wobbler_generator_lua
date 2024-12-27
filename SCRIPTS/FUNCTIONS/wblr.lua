local amplitude = 50 -- Default amplitude
local speed = 2.0 -- Default speed as float
local gvRoll = 0 -- Global variable index for Roll
local gvPitch = 1 -- Global variable index for Pitch
local gvStatus = 2 -- Global variable for status (running)
local gvAmplitude = 3 -- Global variable for Amplitude
local gvSpeed = 4 -- Global variable for Speed (x10 to store as integer)
local running = false -- Indicates whether rotation is running

-- Load params from global variables
local function load_cfg() 
    running = model.getGlobalVariable(gvStatus, 0) == 1
    amplitude = model.getGlobalVariable(gvAmplitude, 0) or amplitude
    amplitude = math.min(100, math.max(10, amplitude)) -- Clamp amplitude between 10 and 100
    speed = (model.getGlobalVariable(gvSpeed, 0) or (speed * 10)) / 10
    speed = math.min(3.0, math.max(1.0, speed)) -- Clamp speed between 0.2 and 3.0
end

-- Update Roll and Pitch values
local function update_values()
    running = model.getGlobalVariable(gvStatus, 0) == 1
    if running then
        local time_now = getTime() / 100 -- EdgeTX time in seconds
        local phase = (time_now * speed * math.pi * 2) % (math.pi * 2)
        local roll = math.floor(amplitude * math.cos(phase) * 10)
        local pitch = math.floor(amplitude * math.sin(phase) * 10)
        model.setGlobalVariable(gvRoll, 0, roll)
        model.setGlobalVariable(gvPitch, 0, pitch)
    end
end

return { init = load_cfg, run = update_values }
