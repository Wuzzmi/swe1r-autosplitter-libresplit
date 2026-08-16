# STAR WARS RACER AUTOSPLITTER (for LibreSplit)
**A script that automates LibreSplit's timer, for Star Wars Episode I Racer speedruns.**  
Based on [Galeforce's LiveSplit Autosplitter](https://github.com/everalert/swe1r-autosplitter) v0.5.1  
The same autosplitter logic converted to Lua, with some compatibility changes.

> [!note]
> Currently some features have minor bugs/caveats. There will be some rough edges while LibreSplit is in prerelease and I sort out one last issue on my end. These imperfections are small and shouldn't have an effect on the majority of runs. The bugs/caveats are detailed in the **SETTINGS BREAKDOWN** section.
>   
> *\*\*Starred Features\*\** indicate that, that feature currently has a bug/caveat associated with it.
>    
> Unlike [LiveSplit](https://github.com/LiveSplit/LiveSplit), [LibreSplit](https://github.com/LibreSplit/LibreSplit/tree/main) currently has no support for managing autosplitter settings. To resolve this difference, the provided scripts utilize in script settings that can be edited for complete settings control. For easy category switching 3 variants of the default script are provided. These variants are identical to the default script, they just have different preset settings set, so the settings can be fully edited as well.
  
### FEATURES
* Auto start when file is opened, or *\*\*optionally when "Start Race" is selected\*\**
* Auto split at race finish, with toggle for 1st place requirement
* Auto reset, with choice of reset location
* Optional run category presets
* Choice of LRT, or *\*\*IGT\*\** timing methods 
* *\*\*Option to remove unfocused/tabbed-out time\*\**

### REQUIRES
* [LibreSplit](https://github.com/LibreSplit/LibreSplit/tree/main)
* [JSON splits](https://github.com/Wuzzmi/swe1r-splits-libresplit/tree/master), or [converted](https://libresplit.org/converter) LSS splits
* Installation of the re-released PC version of Star Wars Episode I Racer (Steam, GOG, etc.)  
    - does not work with the original CD version

## SETUP
* Open **"swe1r-autosplitter.lua"** or one of it's varients in a text editor
   
At the top of the script there are notes, followed by a small settings guide, and under that are the "AUTOSPLITTER SETTINGS". 

### AUTOSPLITTER SETTINGS
```lua
local settings = {
--____________________________________________________________________________
--------------------------- AUTOSPLITTER SETTINGS ----------------------------
--____________________________________________________________________________
-- CATEGORY PRESET -->|  None  | Any%/Amateur/Semi |  100%  | All Tracks NG+ |
   preset = 0,     -->|  [0]   |        [1]        |  [2]   |      [3]       |
--____________________|________|___________________|________|________________|
----------------------------------------------------------|  PRESET = SETS
-- TIMING METHOD      -->| Loadless RT | In Game Race Time| [1,2,3] = [true]
   loadlessRT = true, -->|    [true]   |     [false]      |  
----------------------------------------------------------|-------------------
-- WIN CONDITION       -->|  1st   |  4th/3rd(SMR/BB/BEC) |     [2] = [true] 
   require1st = false, -->| [true] |       [false]        |   [1,3] = [false]
----------------------------------------------------------|-------------------
-- AUTO START TRIGGER     -->| "START RACE" | File Select |     [3] = [false]
   startRaceTrig = false, -->|    [true]    |   [false]   |   [1,2] = [true]
----------------------------------------------------------\___________________
-- AUTO RESET TRIG -->| None | File Select(risky)| Main Menu | Settings(safe)| 
   autoReset = 2,  -->| [0]  |        [1]        |    [2]    |      [3]      |
------------------------------------------------------------------------------
-- TABBED-OUT TIME TREATMENT -->| Remove Tabbed Time | Count Tabbed Time |
   removeTabbedTime = false, -->|       [true]       |      [false]      |
--____________________________________________________________________________
------------------------------------------------------------------------------
}
```
Here is where all settings can be modified. There is a minimal description of each setting to it's right. All settings are described in greater detail after the **ENABLE SCRIPT** section. 
  
It is highly recommended that you adjust the **```autoReset```** trigger to a location that works for you (Main Menu by default).      
  
> [!caution]
> ```lua
> setting = "value",
> ```
> **In order to avoid breaking the script, it is important that you:**
> * Only edit the **```value```** of a **```setting```**.
> * Only replace a **```value```** with another of its type.
> * Make sure that any **```value```** is ended with a comma **```,```**.
   
## ENABLE SCRIPT
* Open LibreSplit
* Right click, to open the autosplitter script and "Enable Autosplitter" 
  
![Rightclick in LibreSplit](https://github.com/Wuzzmi/swe1r-auto_splitter/blob/main/img/rightclick-autosplitter-libresplit.png)
  
> [!important]
> If you edit your script settings after the script has already been loaded and enabled, you will need to uncheck and recheck "Enable Auto Splitter" for the changes to take effect.
  
**Now everything is all set. The autosplitter will function when you run Star Wars Racer!**
___  
  
## SETTINGS BREAKDOWN
### CATEGORY PRESET
```lua
preset = 0,
```
**```preset```** is a one setting adjustment for switching run categories. It functions as a override for a number of other settings. For this reason **```preset``` ```0```** exists, allowing full settings control for special use cases.
|  | None | Any% / Amateur / Semi-Pro | 100% | New Game + |
|:---:|:---:|:---:|:---:|:---:|
| **preset =** | 0 | 1 | 2 | 3 |  
___
### TIMING METHOD
```lua
loadlessRT = true,
```
**```loadlessRT```** functions as a timing method toggle, choose either LRT (Loadless Real Time), or IGT (In Game Race Time). As shown in the table below, every category **```preset```** overrides to LRT . IGT is not useful for recording official runs, but is here for other uses if you have one.

|  | Loadless Real Time | In Race Game Time |
|:---:|:---:|:---:|
|**loadlessRT =**| True | false |
| **```preset```** | **```1``` ```2``` ```3```** |  |

 > [!warning]
> ***\*\*BUG\*\****
>   
> While **```loadlessRT = false```** (IGT), if you right click in LibreSplit and select reload, you will trigger a bug. This bug will make your run act as a RTA run! To fix this, reset the timer with the "Reset Timer" keybind, an auto reset (if **```autoReset```** is enabled), or restart LibreSplit.
___
### WIN CONDITION
```lua
require1st = false,
```
**```require1st```** toggles requiring a 1st place finish, to trigger a split. The default win condition is used otherwise, which requires 4th place, or 3rd on the last track of a circuit ( SMR/BB/BEC ). **```require1st```** is typically used for the 100% category.
|  | Require 1st | Require 4th, 3rd (on SMR/BB/BEC) |
|:---:|:---:|:---:|
|**require1st =**| true | false |
| **```preset```** | **```2```** | **```1``` ```3```** |

___
### AUTO START TRIGGER
```lua
startRaceTrig = false,
```
**```startRaceTrig```** sets the timer to start when "Start Race" is selected, otherwise the timer will start at file open. **```startRaceTrig```** is used for the All Tracks NG+ category, which requires timing to start when selecting "Start Race" for the first track.
|  | "Start Race" Selected | File Opened |
|:---:|:---:|:---:|
|**startRaceTrig =**| true | false |
| **```preset```** | **```3```** | **```1``` ```2```** |
> [!important]
> ***\*\*SEMIFUNCTIONAL\*\****
>   
> Currently for the timer to trigger, you must enter the track selection scene, then move directly to select "Start Race". If you deviate, just return to the track selection scene before heading to "Start Race". 

___
### AUTO RESET TRIGGER
```lua
autoReset = 2,
```
**```autoReset```** allows you to disable auto reset or choose the location it will be triggered. For any runs that require a file/mode change mid run, it is important to set **```autoReset```** to trigger at a location that will not be reached during the run, or to disable it. This ensures file/mode changes do not reset and ruining the run, otherwise **```autoReset```** is just personal preference.
|  | Disabled | File Select (Risky) | Main Menu | Settings (Safe) |
|:---:|:---:|:---:|:---:|:---:|
|**autoReset =**| 0 | 1 | 2 | 3 |
 
___
### REMOVE UNFOCUSED TIME (Tabbed-Out)
```lua
removeTabbedTime = false,
```
Use **```removeTabbedTime```** to register unfocused/tabbed-out time as loading time, so it will not be counted on the timer. **```removeTabbedTime```** will only have an effect if **```loadlessRT = true,```** (LRT). Usage of **```removeTabbedTime```** is up to you.
|  | Tabbed Time Removed | Tabbed Time Counted |
|:---:|:---:|:---:|
|**removeTabbedTime =**| true | false |
> [!warning]
> ***\*\*BUG\*\****
>  
> While **```removeTabbedTime = true```**, if you use LibreSplits "Reset Timer" keybind, or right click in LibreSplit and click reload, you will trigger a bug!
> This bug inverts loading/tabbed-out time, so when the timer would normally run it does not, but instead will run while in a loading screen or while tabbed-out.
> If this happens you will need to trigger an auto reset (if **```autoReset```** is not disabled), or fully restart LibreSplit. 

___

## POSSIBLE FUTURE IMPROVMENTS
* Determine a proper memory address for triggering the timer on "START RACE" selection (currently relying on sceneID, not ideal).
  
## LICENSE
This repo is unlicensed.
