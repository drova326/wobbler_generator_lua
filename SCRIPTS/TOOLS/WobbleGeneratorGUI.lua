-- Defaults
local amplitude = 50 -- Default amplitude
local speed = 2.0 -- Default speed as float
-- GV binds
local gvRoll = 0 -- Global variable index for Roll
local gvPitch = 1 -- Global variable index for Pitch
local gvStatus = 2 -- Global variable for status (running)
local gvAmplitude = 3 -- Global variable for Amplitude
local gvSpeed = 4 -- Global variable for Speed (x10 to store as integer)
-- Current state
local in_settings = false
local current_option = 1
local editing = false
local running = false -- Indicates whether rotation is running
local roll = 0
local pitch = 0

-- Menu options
local menu_options = {
    { name = "Amplitude", value = function() return amplitude end, adjust = function(delta) amplitude = math.min(100, math.max(0, amplitude + delta)) end },
    { name = "Frequency", value = function() return string.format("%.1f", speed) end, adjust = function(delta) speed = math.min(3.0, math.max(1.0, speed + delta * 0.1)) end }
}

-- Load from global variables
local function load_cfg()
    running = model.getGlobalVariable(gvStatus, 0) == 1
    amplitude = model.getGlobalVariable(gvAmplitude, 0) or amplitude
    amplitude = math.min(100, math.max(10, amplitude)) -- Clamp amplitude between 10 and 100
    speed = (model.getGlobalVariable(gvSpeed, 0) or (speed * 10)) / 10
    speed = math.min(3.0, math.max(1.0, speed)) -- Clamp speed between 0.2 and 3.0
end

-- Save to global variables
local function save_cfg()
    model.setGlobalVariable(gvStatus, 0, running and 1 or 0)
    model.setGlobalVariable(gvAmplitude, 0, math.floor(amplitude))
    model.setGlobalVariable(gvSpeed, 0, math.floor(speed * 10))
end

-- Update Roll and Pitch values
local function update_values()
    if running then
        local time_now = getTime() / 100 -- EdgeTX time in seconds
        local phase = (time_now * speed * math.pi * 2) % (math.pi * 2)
        roll = math.floor(amplitude * math.cos(phase) * 10)
        pitch = math.floor(amplitude * math.sin(phase) * 10)
        model.setGlobalVariable(gvRoll, 0, roll)
        model.setGlobalVariable(gvPitch, 0, pitch)
    else
        roll = 0
        pitch = 0
    end
end

-- Settings menu
local function refresh_settings_page(event)
    lcd.clear()
    for i, option in ipairs(menu_options) do
        local y = 5 + (i - 1) * 12
        if i == current_option then
            lcd.drawText(1, y, option.name .. ":", INVERS)
            if editing then
                lcd.drawText(80, y, option.value(), INVERS)
            else
                lcd.drawText(80, y, option.value(), SMLSIZE)
            end
        else
            lcd.drawText(1, y, option.name .. ":", SMLSIZE)
            lcd.drawText(80, y, option.value(), SMLSIZE)
        end
    end

    -- Instructions
    lcd.drawText(1, 55, editing and "+/-: adjust, ENT/RTN: save" or "+/-: navigate, ENT/RTN: exit", SMLSIZE)

    -- Handle button events
    if editing then
        if event == 4100 then
            menu_options[current_option].adjust(1)
        elseif event == 4099 then
            menu_options[current_option].adjust(-1)
        elseif event == EVT_ENTER_BREAK or event == EVT_EXIT_BREAK or event == EVT_RT_BREAK then
            editing = false
        end
    else
        if event == 4100 then
            current_option = (current_option % #menu_options) + 1
        elseif event == 4099 then
            current_option = (current_option - 2 + #menu_options) % #menu_options + 1
        elseif event == EVT_ENTER_BREAK then
            editing = true
        elseif event == EVT_EXIT_BREAK or event == EVT_RT_BREAK then
            in_settings = false
        end
    end

    return 0
end

-- Main run function
local function run_func(event)
    if in_settings then
        return refresh_settings_page(event)
    end

    if event == EVT_ENTER_BREAK then
        running = not running
    elseif event == EVT_ENTER_LONG then
        in_settings = true
        killEvents(EVT_ENTER_LONG)
    elseif event == EVT_EXIT_BREAK or event == EVT_RT_BREAK then
        save_cfg()
        return 1
    end

    update_values()

    -- Display status
    lcd.clear()
    lcd.drawText(2, 1, "Wobble Generator", MIDSIZE + INVERS)
    lcd.drawText(1, 18, string.format(" Ampitude: %d%%    Freq: %.1fHz", amplitude, speed), SMLSIZE)
    lcd.drawText(14, 30, "generated Roll: " .. roll, SMLSIZE)
    lcd.drawText(14, 42, "generated Pitch: " .. pitch, SMLSIZE)
    lcd.drawText(1, 55, "HOLD ENT: set, ENT: begin/end", SMLSIZE)

    return 0
end

return { init = load_cfg, run = run_func }

