--[[
  Star Wars Episode I Racer Autosplitter (for LibreSplit) by Wuzzmi
  https://github.com/Wuzzmi/swe1r-autosplitter-libresplit
   - Based on Galeforce's LiveSplit Autosplitter v0.5.1
     https://github.com/everalert/swe1r-autosplitter

  FEATURES
   - Auto start when file is opened, or **optionally when "Start Race" is selected**
   - Auto split at race finish, with toggle for 1st place requirement
   - Auto reset, with choice of reset location
   - Optional run category presets
   - Choice of LRT, or **IGT** timing methods
   - **Option to remove unfocused/tabbed-out time**
  
   USING THIS SCRIPT
   - Adjust the in script settings (below) 
   - Load and enable this script in LibreSplit
   - Run Star Wars Racer

---------------------------- SETTINGS BASICS ---------------------------------
        To set your run category, adjust the value of the [preset] setting
    (the first setting under "AUTOSPLITTER SETTINGS") below. Setting a 
    [1, 2, or 3] whichever cooresponds with your run category(right of [preset]). 
    Making sure to keep the comma!!! 
---------------------------- ADVANCED SETTINGS -------------------------------
         Adjusted any settings to preference, just note that category presettings.
    [1, 2, 3] override a number of the other settings. Each preset's override 
    values, are displayed in the box on the right side of settings. If your 
    preset overrides a prefered setting, set [preset = 0,] and ensure all other 
    settings are set correctly. 

    See the github README for more indepth details on each setting.
    https://github.com/Wuzzmi/swe1r-autosplitter-libresplit
--]]

process("SWEP1RCR.EXE")
local settings = {
--____________________________________________________________________________
--------------------------- AUTOSPLITTER SETTINGS ----------------------------
--____________________________________________________________________________
-- CATEGORY PRESET -->|  None  | Any%/Amateur/Semi |  100%  | All Tracks NG+ |
   preset = 2,     -->|  [0]   |        [1]        |  [2]   |      [3]       |
--____________________|________|___________________|________|________________|
----------------------------------------------------------|  PRESET = SETS
-- TIMING METHOD      -->| Loadless RT | In Game Race Time| [1,2,3] = [true]
   loadlessRT = true, -->|    [true]   |     [false]      |  
----------------------------------------------------------|-------------------
-- WIN CONDITION       -->|  1st   |  4th/3rd(SMR/BB/BEC) |     [2] = [true] 
   require1st = true, -->| [true] |       [false]        |   [1,3] = [false]
----------------------------------------------------------|-------------------
-- AUTO START TRIGGER     -->| "START RACE" | File Select |     [3] = [true]
   startRaceTrig = false, -->|    [true]    |   [false]   |   [1,2] = [false]
----------------------------------------------------------\___________________
-- AUTO RESET TRIG -->| None | File Select(risky)| Main Menu | Settings(safe)| 
   autoReset = 2,  -->| [0]  |        [1]        |    [2]    |      [3]      |
------------------------------------------------------------------------------
-- TABBED-OUT TIME TREATMENT -->| Remove Tabbed Time | Count Tabbed Time |
   removeTabbedTime = false, -->|       [true]       |      [false]      |
--____________________________________________________________________________
------------------------------------------------------------------------------
}
-- Preset overrides 
if settings.preset == 1 or 2 or 3 then 
    settings.loadlessRT = true
    settings.require1st = settings.preset == 2 and true or false
    settings.startRaceTrig = settings.preset == 3 and true or false
else
    settings.preset = 0
end

local current = {
    raceTime = 0.0,
    racePos = 0,
    podFlags2 = 0,
    podFlags8 = 0,
    podHeat = 0.0,
    selTrk = 0,
    inRace = 0,
    frmCnt = 0,
    frmLen = 0.0,
    sceneId = 0,
    gameTabbedOut = 0,
    menTxt1 = ""
}
local old = shallow_copy_tbl(current)
local vars = {
    -- Autosplitter related variables
    raceDone = false,
    winCond = false,
    gt = 0,
    gtAdd = 0,
    inRace = 0,
    loadBuffer = 0,
    loadBufferSize = 0,
    loading = false
}
-- If address is nil, settings.it to 0 and prints alert
local function nilGuard(value, idString)
    if value == nil then
        print( 
        idString .. " has been set to 0. Cannot use nil value.\n")
        return 0
    end
    return value
end
-- Function to format time as string (h:mm:ss.ff)
local function formatTime(seconds)
    if seconds > 3600 then
        return string.format("%d:%d:%05.2f", seconds / 3600, 
        (seconds % 3600) / 60, seconds % 60)
    elseif seconds > 60 then
        return string.format("%d:%05.2f", seconds / 60, seconds % 60)
    else
        return string.format("%05.2f", seconds)
    end
end


function startup()
    useGameTime = not settings.loadlessRT
    refreshRate = 24 -- Starting point, will be calculated dynamically
end

function state()
    old = shallow_copy_tbl(current)
-- Addresses that always hold a value
    current.inRace = readAddress("byte", 0xA9BB81)
    current.frmCnt = readAddress("int", 0xA22A30)
    current.frmLen = readAddress("double", 0xA22A40)
    current.sceneId = readAddress("short", 0xA9BA62)
    current.gameTabbedOut = readAddress("byte", 0x10CB64)
    -- Limit string to 17 chars, sometimes odd chars are added at end 
    current.menTxt1 = string.sub (readAddress("string17", 0xA2C380), 1, 17)
-- Nil guarded addresses, since they don't always hold a value, fixes bitwise errors
    current.selTrk = nilGuard(readAddress("byte", 0xBFDB8, 0x5D),
    "(0) [current.selTrk]")
    current.raceTime = nilGuard(readAddress("float", 0xD78A4, 0x74),
    "(1) [current.raceTime]")
    current.racePos = nilGuard(readAddress("byte", 0xD78A4, 0x5C),
    "(2) [current.racePos]")
    current.podFlags2 = nilGuard(readAddress("byte", 0xd78a4, 0x84, 0x61),
    "(3) [current.podFlags2]")
    current.podFlags8 = nilGuard(readAddress("byte", 0xD78A4, 0x84, 0x67),
    "(4) [current.podFlags8]")
    current.podHeat = nilGuard(readAddress("float", 0xD78A4, 0x84, 0x218),
    "(5) [current.podHeat]")
end

function update()
    -- Dynamically update refresh rate based on frame time
    refreshRate = current.frmLen > 0 and math.floor(1 / current.frmLen) or 24
    end

function start()
    vars.gt = 0
    vars.gtAdd = 0
    vars.inRace = 0
    vars.loadBuffer = 0
    vars.loadBufferSize = 0
    -- Auto start trigger based on settings
    if settings.startRaceTrig then
        return current.sceneId == 0 and old.sceneId == 260
    end
    return current.menTxt1 == "~F6~sBack" and old.menTxt1 == "~F6Current Player"
end

function split()
    -- Handle race finish
    vars.raceDone = (b_and(current.podFlags8, b_lshift(1, 1)) ~= 0) and 
    (b_and(old.podFlags8, b_lshift(1, 1)) == 0)
    -- Split based on win condition setting
    if settings.require1st then
        vars.winCond = current.racePos == 1
    else
        if current.selTrk == 17 or 
        current.selTrk == 8 or 
        current.selTrk == 1 then
            vars.winCond = current.racePos <= 3
        else
            vars.winCond = current.racePos <= 4
        end
    end
    return vars.raceDone and vars.winCond
end

function isLoading()
    -- Actual ingame isLoading bool unknown. Detects loading based on frame 
    -- counter with small dynamic buffer to account for framerate discrepancies
    if settings.loadlessRT then
        vars.loadBufferSize = math.floor(old.frmLen / current.frmLen) + 2
        if current.frmCnt == old.frmCnt then
            vars.loadBuffer = vars.loadBuffer + 1
        else
            vars.loadBuffer = vars.loadBuffer - 1
        end
        if vars.loadBuffer <= 0 then
            vars.loading = false
            vars.loadBuffer = 0
        end
        if vars.loadBuffer >= vars.loadBufferSize then
            vars.loading = true
            vars.loadBuffer = vars.loadBufferSize
        end
        -- Real Time - Loads and Unfocused Time Removed
        if settings.removeTabbedTime then
            return vars.loading
        end
        -- Real Time - Loads Removed 
        return vars.loading and current.gameTabbedOut == 0
    end
    -- In Game Race Time
    return true
end

function reset()
    -- Determine auto reset trigger
    if settings.autoReset == 1 then
        return current.menTxt1 == "~F6Current Player"
    elseif settings.autoReset == 2 then
        return current.menTxt1 == "~F6~sSingle Playe"
    elseif settings.autoReset == 3 then
        return current.menTxt1 == "~F6~sVIDEO SETTIN"
    end
end

function gameTime()
    -- Entering race
    if current.inRace == 1 and old.inRace == 0 then
        vars.inRace = 1
    end
    -- Current race in-game time 
    if vars.inRace == 1 and (b_and(current.podFlags8, b_lshift(1, 1)) == 0) then
        vars.gtAdd = current.raceTime
    else
        vars.gtAdd = 0    
    end
    -- Race completion
    if (b_and(current.podFlags8, b_lshift(1, 1)) ~= 0 and 
    b_and(old.podFlags8, b_lshift(1, 1)) == 0) or
    (current.inRace == 0 and old.inRace == 1 and vars.inRace ~= 0) then
        vars.gt = vars.gt + current.raceTime
        vars.gtAdd = 0
        vars.inRace = 0
    end
    -- IGT in milliseconds
    return (vars.gt + vars.gtAdd) * 1000
end

