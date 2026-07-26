--[[
  Star Wars Episode I Racer Autosplitter (for LibreSplit) by Wuzzmi
  https://github.com/Wuzzmi/swe1r-autosplitter-libresplit
   * Based on Galeforce's LiveSplit Autosplitter v0.5.1
     https://github.com/everalert/swe1r-autosplitter

  FEATURES
   * Auto start when file is opened, or optionally when "Start Race" is selected
   * Auto split at race finish, with toggle for 1st place requirement
   * Optional auto reset, on return to file selection
   * Optional run category presets
   * Choice of IGT, LRT and RTA timing methods
   * Option to remove unfocused/tabbed-out time
   * Option to view extra stats in terminal
  
   USING THIS SCRIPT
   * Adjust the in script settings (below) 
   * Right click in LibreSplit, check "Enable Auto Splitter"
   * Right click again, select "Open Auto Splitter"
   * Now select the script and hit "Open"
   * Run Star Wars Racer

   POSSIBLE FUTURE IMPROVMENTS
   * Determine a proper memory address for triggering the timer on "START RACE" 
     selection (currently relying on sceneID, not ideal).
   * Add option for each individual race time (idealy with individual lap times) 
     to be printed in terminal at the end of a run.
   * Possible addition of more terminal stats. The source ASL script seems to have 
     a number of semi completed viewable stats in the process of being added.

---------------------------- SETTINGS BASICS ---------------------------------
        To set your run category, adjust the value of the [preset] setting
    (the first setting under "AUTOSPLITTER SETTINGS") below. Setting a 
    [1, 2, or 3] whichever cooresponds with your run category(right of [preset]). 
    Making sure to keep the comma!!! 
---------------------------- ADVANCED SETTINGS -------------------------------
         Adjusted any settings to preference, just note that category presets 
    [1, 2, 3] override a number of the other settings. Each preset's override 
    values, are displayed in the box on the right side of settings. If your 
    preset overrides a prefered setting, set [preset = 0,] and ensure all other 
    settings are set correctly. 

    See the github README for more indepth details on each setting and more.
    https://github.com/Wuzzmi/swe1r-autosplitter-libresplit
--]]

process("SWEP1RCR.EXE")

local sets = {
--____________________________________________________________________________
--------------------------- AUTOSPLITTER SETTINGS ----------------------------
--____________________________________________________________________________
-- CHOOSE RUN CATEGORY --> None | Any%/Amateur/Semi | 100% | New Game+ |
   preset = 1,         --> [0]  |        [1]        | [2]  |    [3]    |
--______________________________|___________________|______|___________|______
----------------------------------------------------------|  PRESET = SETS
-- TIMING METHOD  -->In race GT | RT No Loads | Real Time | [1,2,3] = [1](LRT)
   timeMethod = 1,--> [0](IGT)  |   [1](LRT)  | [2+](RTA) |      
----------------------------------------------------------|-------------------
-- REQUIRES 1ST PLACE, If [false] requires 4th place,     |     [2] = [true]
   req1st = false, --  and 3rd on SMR/BB/BEC              |   [1,3] = [false] 
----------------------------------------------------------|-------------------
-- "START RACE" TIMER TRIGGER (Semifunctional) - Move     |
   trigSR = false, -- from "Track Select" > "START RACE"  |   [1,2] = [false] 
----------------------------------------------------------|-------------------
-- ENABLE RESET TRIGGER - Triggers at file selection.     |      
   reset = true, -- set [false] if switching mode mid-run.|     [3] = [false]
----------------------------------------------------------\___________________
-- REMOVE UNFOCUSED TIME (Tabbed-Out Time) Requires RT No Loads. 
   noTab = false, -- Only affects LRT [timeMethod = 1], thus all presets. 
------------------------------------------------------------------------------
-- VIEW EXTRA STATS IN TERMINAL (when LibreSplit is run through the terminal).
   viewTermStats = false, -- Toggles the view of the following extra stats.
--  --  -VIEWABLE STATS  --  --  --  --  --  --  --  --  --  --  --  --  --  -
                viewIGT = true, -- Total race IGT
         viewCurRaceIGT = false, -- Current race IGT
          viewOverheats = true, -- Counts overheats over the whole run
             viewDeaths = true, -- Counts deaths over the whole run
--____________________________________________________________________________
------------------------------------------------------------------------------
}
-- preset overrides 
if sets.preset ~= 0 then 
    sets.timeMethod = 1
    if sets.preset == 2 then
        sets.req1st = true
        sets.trigSR = false
    elseif sets.preset == 3 then
        sets.req1st = false
        sets.trigSR = true
    end
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
    loading = 0
}

-- Add more to vars when term stats is enabled
if sets.viewTermStats then
    -- Terminal info variables
    vars.infoTRIGT = "0.00"
    vars.infoRIGT = "0.00"
    vars.infoOHC = "0"
    vars.infoDC = "0"
    vars.cntOverHeat = 0
    vars.cntDeath = 0
    vars.statsIndent = 3
    vars.statsWidth = 24
    -- Terminal formatting variables
    vars.titles = { 
        strTRIGT = "IGT", 
        strRIGT = "Current Race IGT", 
        strOHC = "Overheat Counter", 
        strDC = "Death Counter"
    }
end

function startup()
    useGameTime = sets.timeMethod == 0 
    refreshRate = 24 -- Starting point, will be calculated dynamically
end

local function nilGuard(value, idString)
    if value == nil then
        print( 
        idString .. " has been set to 0. Can't use nil value.\n")
        return 0
    end
    return value
end

function state()
    old = shallow_copy_tbl(current)

    -- Addresses that always hold a value
    current.inRace = readAddress("byte", 0xA9BB81)
    current.frmCnt = readAddress("int", 0xA22A30)
    current.frmLen = readAddress("double", 0xA22A40)
    current.sceneId = readAddress("short", 0xA9BA62)
    current.gameTabbedOut = readAddress("byte", 0x10CB64)
    current.menTxt1 = readAddress("string17", 0xA2C380)
    -- Addresses assigned to 0 when nil(with print info)
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

-- Prints title and value @ width(in chars) of viewable stat, if enabled
local function termDisplay(title, value, width, condition)
    local indent = string.rep(" ", 3)
    local line = string.rep("_", width) 
    if condition then
        print(    line .. "\n" .. 
        indent .. title .. "\n" ..
        indent .. value)
    end
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

function update()
    -- View terminal info
    if sets.viewTermStats then
        print("\n")
        termDisplay(vars.titles.strTRIGT, vars.infoTRIGT, vars.statsWidth, 
        sets.viewIGT) 
        termDisplay(vars.titles.strRIGT, vars.infoRIGT, vars.statsWidth, 
        sets.viewCurRaceIGT) 
        termDisplay(vars.titles.strOHC, vars.infoOHC, vars.statsWidth, 
        sets.viewOverheats) 
        termDisplay(vars.titles.strDC, vars.infoDC, vars.statsWidth, 
        sets.viewDeaths) 
        print("\n")
    end
    -- Dynamically update refresh rate based on frame time
    refreshRate = current.frmLen > 0 and math.floor(1 / current.frmLen) or 24
    -- calculate and set "death counter & overheat counter" if needed
    if sets.viewTermStats then
        if b_and(current.podFlags2, b_lshift(1, 6)) ~= 0 and 
        b_and(old.podFlags2, b_lshift(1, 6)) == 0 then
            vars.cntDeath = vars.cntDeath + 1 
        end
        if vars.inRace == 1 and current.podHeat == 0 and old.podHeat > 0 and
        b_and(current.podFlags2, b_lshift(1, 6)) == 0 then
            vars.cntOverHeat = vars.cntOverHeat + 1 
        end
            vars.infoDC = (vars.cntDeath > 0) and vars.cntDeath or "0" 
            vars.infoOHC = (vars.cntOverHeat > 0) and 
                vars.cntOverHeat or "0" 
    end
    if sets.timeMethod == 0 or sets.viewTermStats then
        -- When entering race
        if current.inRace == 1 and old.inRace == 0 then
            vars.inRace = 1
            vars.infoRIGT = sets.viewTermStats and 
                "0.00" or vars.infoRIGT 
        end
        -- Format current race in-game time
        vars.gtAdd = (vars.inRace == 1 and 
        b_and(current.podFlags8, b_lshift(1, 1)) == 0) and 
            current.raceTime or 0
            vars.infoRIGT = (sets.viewTermStats and 
            (vars.gtAdd > 0)) and 
                formatTime(vars.gtAdd) or vars.infoRIGT
        -- Handle race completion
        if ((b_and(current.podFlags8, b_lshift(1, 1)) ~= 0 and 
        b_and(old.podFlags8, b_lshift(1, 1)) == 0) or
        (current.inRace == 0 and old.inRace == 1 and vars.inRace ~= 0)) then
                vars.infoRIGT = sets.viewTermStats and 
                    formatTime(current.raceTime) or vars.infoRIGT
            vars.gt = vars.gt + current.raceTime
            vars.gtAdd = 0
            vars.inRace = 0
        end
        vars.infoTRIGT = formatTime(vars.gt + vars.gtAdd)
    end
end

function isLoading()
    -- actual ingame isLoading bool unknown, detect loading based on frame counter with small dynamic buffer to account for framerate discrepancies
    if sets.timeMethod == 1 then
        vars.loadBufferSize = math.floor(old.frmLen / current.frmLen) + 2
        vars.loadBuffer = (current.frmCnt == old.frmCnt) and 
            (vars.loadBuffer + 1) or (vars.loadBuffer - 1)
        if vars.loadBuffer <= 0 then
            vars.loading = 0
            vars.loadBuffer = 0
        end
        if vars.loadBuffer >= vars.loadBufferSize then
            vars.loading = 1
            vars.loadBuffer = vars.loadBufferSize
        end
        if not sets.noTab then
            return (vars.loading > 0 and current.gameTabbedOut == 0)
        else
            return vars.loading > 0 
        end
    else
        return true  -- Always loading if not using load removal
    end
end

function gameTime()
    if sets.timeMethod == 0 then
        return (vars.gt + vars.gtAdd) * 1000
    end
end

function reset()
    if sets.reset then
        -- Reset when entering file select screen
        return (current.menTxt1 == "~F6Current Player" or 
        current.menTxt1 == "~F6~sSingle Playe")
    end
end

function split()
    -- Handle race finish
    vars.raceDone = ((b_and(current.podFlags8, b_lshift(1, 1)) ~= 0) and 
    (b_and(old.podFlags8, b_lshift(1, 1)) == 0))
    if sets.req1st then
        vars.winCond = (current.racePos == 1)
    else
        if current.selTrk == 17 or 
        current.selTrk == 8 or 
        current.selTrk == 1 then
            vars.winCond = (current.racePos <= 3)
        else
            vars.winCond = (current.racePos <= 4)
        end
    end
    return (vars.raceDone and vars.winCond)
end

function start()
    -- Reset all counters and variables
    if sets.viewTermStats then 
        vars.infoRIGT = "0.00"
        vars.infoTRIGT = "0.00"
        vars.infoOHC = "0"
        vars.infoDC = "0"
    end
    vars.gt = 0
    vars.gtAdd = 0
    vars.inRace = 0
    vars.loadBuffer = 0
    vars.loadBufferSize = 0
    -- determine start location
    if not sets.trigSR then
        return (current.sceneId == 60 and 
        current.menTxt1 ~= "~F6Current Player" and 
        current.menTxt1 ~= "~F6~sSingle Playe")
    else
        return (current.sceneId == 0 and 
        old.sceneId == 260)
    end
end
