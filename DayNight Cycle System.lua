--[[
Day/Night Cycle System for Roblox
Author: Vain_ie

--- HOW TO IMPLEMENT ---
1. Copy this script into a Script object in ServerScriptService in your Roblox game.
2. The system will automatically control the day/night cycle using Lighting.TimeOfDay.
3. To set the length of a full day (in real seconds), change the DAY_LENGTH_SECONDS variable.
4. To get the current time of day (in hours), call:
   GetCurrentDayTime()
5. To get notified when day or night starts, customize the onDayNightChanged(isDay) function.
6. You can manually set the time of day using SetDayTime(hour) (0 = midnight, 12 = noon, 18 = evening, etc.).
7. The system will automatically update Lighting.Brightness and Lighting.OutdoorAmbient for day/night, but you can customize this in onDayNightChanged.

--- END OF TUTORIAL ---

Credits: System created by Vain_ie

--- EXPLANATION OF EVERY SECTION ---
-- DAY_LENGTH_SECONDS: How many real seconds a full day lasts (e.g., 600 = 10 minutes per day).
-- Lighting: Roblox service that controls the game's lighting and time of day.
-- currentTime: The current time of day in hours (0-24).
-- isDay: Boolean tracking if it's currently day (true) or night (false).
-- GetCurrentDayTime(): Returns the current time of day in hours.
-- SetDayTime(hour): Sets the current time of day (0-24).
-- onDayNightChanged(isDay): Called when the cycle switches between day and night. Handles lighting changes and notifications.
-- dayNightCycle(): Main loop that advances the time and triggers day/night changes.
-- spawn(dayNightCycle): Starts the cycle in the background.
--- END OF EXPLANATION ---
]]

-- Day/Night Cycle System for Roblox
-- This script manages a day/night cycle using Lighting.TimeOfDay and provides hooks for custom actions.

-- How many real seconds a full day lasts (e.g., 600 = 10 minutes per day)
local DAY_LENGTH_SECONDS = 600

-- Get the Lighting service to control time of day
local Lighting = game:GetService("Lighting")

-- Current time of day in hours (0-24)
local currentTime = 6 -- Start at 6 AM
-- Track if it's currently day or night
local isDay = true

-- Option: Enable smooth transitions for Lighting properties
local SMOOTH_TRANSITIONS = true
local TRANSITION_SPEED = 0.05 -- How fast to interpolate (0-1, higher is faster)

-- Function to get the current time of day (in hours)
function GetCurrentDayTime()
    return currentTime
end

-- Function to set the current time of day (0-24)
function SetDayTime(hour)
    currentTime = math.clamp(hour, 0, 24)
    Lighting.TimeOfDay = string.format("%02d:00:00", math.floor(currentTime))
end

-- Internal: smoothly interpolate Lighting properties
local function lerpColor3(a, b, t)
    return Color3.new(
        a.R + (b.R - a.R) * t,
        a.G + (b.G - a.G) * t,
        a.B + (b.B - a.B) * t
    )
end

local function smoothLightingUpdate(targetBrightness, targetAmbient)
    if not SMOOTH_TRANSITIONS then
        Lighting.Brightness = targetBrightness
        Lighting.OutdoorAmbient = targetAmbient
        return
    end
    -- Smoothly interpolate to target values
    Lighting.Brightness = Lighting.Brightness + (targetBrightness - Lighting.Brightness) * TRANSITION_SPEED
    Lighting.OutdoorAmbient = lerpColor3(Lighting.OutdoorAmbient, targetAmbient, TRANSITION_SPEED)
end

-- Enhanced day/night handler with smooth transitions and event support
DayNightEvent = Instance.new("BindableEvent")

-- === CUSTOMIZATION HOOKS ===
-- You can override these functions or connect to these events in your own scripts for custom behavior.

-- Called when the day/night state changes. Override or connect to DayNightEvent for custom logic.
function onDayNightChanged(isDayNow)
    if isDayNow then
        print("It's now DAY!")
        smoothLightingUpdate(2, Color3.fromRGB(180, 180, 180))
    else
        print("It's now NIGHT!")
        smoothLightingUpdate(0.5, Color3.fromRGB(40, 40, 80))
    end
    DayNightEvent:Fire(isDayNow)
end

-- Connect to this event for custom day/night logic (e.g., spawn NPCs, change music)
-- Example usage in another script:
--   local conn = ConnectDayNightChanged(function(isDay)
--       if isDay then ... else ... end
--   end)

-- To customize lighting for different times, override this function:
function getLightingForTime(hour)
    -- Example: smoothly blend between day and night settings
    if hour >= 6 and hour < 18 then
        return 2, Color3.fromRGB(180, 180, 180) -- Day
    else
        return 0.5, Color3.fromRGB(40, 40, 80) -- Night
    end
end

-- Utility: Get current time as a string (e.g., "14:30")
function GetCurrentTimeString()
    local hour = math.floor(currentTime)
    local minute = math.floor((currentTime - hour) * 60)
    return string.format("%02d:%02d", hour, minute)
end

-- Main function: advances the time and triggers day/night changes
local function dayNightCycle()
    local lastIsDay = isDay
    while true do
        -- Advance time based on real time
        local delta = 24 / DAY_LENGTH_SECONDS * 1 -- 1 second per loop
        currentTime = currentTime + delta
        if currentTime >= 24 then
            currentTime = currentTime - 24
        end
        -- Update Lighting.TimeOfDay
        local hour = math.floor(currentTime)
        local minute = math.floor((currentTime - hour) * 60)
        Lighting.TimeOfDay = string.format("%02d:%02d:00", hour, minute)
        -- Determine if it's day or night (e.g., day: 6-18, night: 18-6)
        if currentTime >= 6 and currentTime < 18 then
            isDay = true
        else
            isDay = false
        end
        -- If day/night changed, call the handler
        if isDay ~= lastIsDay then
            onDayNightChanged(isDay)
            lastIsDay = isDay
        else
            -- Even if not changed, update lighting smoothly
            local targetBrightness, targetAmbient = getLightingForTime(currentTime)
            smoothLightingUpdate(targetBrightness, targetAmbient)
        end
        wait(1)
    end
end

-- Start the day/night cycle loop in the background
spawn(dayNightCycle)
