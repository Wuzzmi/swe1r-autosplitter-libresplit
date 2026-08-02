# STAR WARS RACER AUTOSPLITTER (for LibreSplit)
**A script that automates LibreSplit's timer, for Star Wars Episode I Racer speedruns.**  
Based on [Galeforce's LiveSplit Autosplitter](https://github.com/everalert/swe1r-autosplitter) v0.5.1  
The same autosplitter logic, converted to Lua, with some additions/compatibility changes.

> [!note]
> This script includes all of the base functionalities required for all speedrun categories, but some extra features still have bugs/caveats, so is still a work in progress.
>   
> *\*\*Starred Features\*\** indicate that, that feature currently has a bug/caveat associated with it.
>    
> Unlike [LiveSplit](https://github.com/LiveSplit/LiveSplit), [LibreSplit](https://github.com/LibreSplit/LibreSplit/tree/main) currently has no support for managing autosplitter settings. Viewing extra stats like LiveSplit does with the "[ASL variable viewer](https://github.com/hawkerm/LiveSplit.ASLVarViewer)" plugin, is also not supported. As a solution for these differences, this script utilizes in script settings, and the ability to print these stats in the terminal.
  
### FEATURES
* Auto start when file is opened, or *\*\*optionally when "Start Race" is selected\*\**
* Auto split at race finish, with toggle for 1st place requirement
* Optional auto reset, on return to file selection
* Optional run category presets
* Choice of LRT, or *\*\*IGT\*\** timing methods 
* *\*\*Option to remove unfocused/tabbed-out time\*\**
* *\*\*Option to view extra stats in terminal\*\**

### REQUIRES
* [LibreSplit](https://github.com/LibreSplit/LibreSplit/tree/main)
* Star Wars Racer [JSON splits](https://github.com/Wuzzmi/swe1r-splits-libresplit/tree/master), or [converted](https://libresplit.org/converter) LSS splits
* Installation of the re-released PC version of Star Wars Episode I Racer (Steam, GOG, etc.)  
    - does not work with the original CD version
___
## SETUP TLDR (Advanced Users)
* Edit the **in script** settings, under **"AUTOSPLITTER SETTINGS"**
* Load and Enable the script in LibreSplit
* Run Star Wars Racer

## SETUP
* [Download](https://github.com/Wuzzmi/swe1r-autosplitter-libresplit/archive/refs/heads/main.zip) and extract the autosplitter
* Place either the extracted folder, or just "swe1r-autosplitter.lua", where you prefer
  * commonly in: ```~/.config/libresplit/auto-splitters/```
* Open "swe1r-autosplitter.lua" in a text editor
   
At the top of the script there are notes, followed by a small settings guide, and under that will be the "AUTOSPLITTER SETTING". 

### AUTOSPLITTER SETTINGS
```lua
local sets = {
--____________________________________________________________________________
--------------------------- AUTOSPLITTER SETTINGS ----------------------------
--____________________________________________________________________________
-- CHOOSE RUN CATEGORY -->| None | Any%/Amateur/Semi | 100% | All Tracks NG+ |
   preset = 1,         -->| [0]  |        [1]        | [2]  |      [3]       |
--________________________|______|___________________|______|________________|
----------------------------------------------------------|  PRESET = SETS
-- TIMING METHOD   -->| In Game Time | Real Time No Loads | 
   useIGT = false, -->|     true     |       false        | [1,2,3] = [false] 
----------------------------------------------------------|-------------------
-- REQUIRES 1ST PLACE, If [false] requires 4th place,     |     [2] = [true]
   req1st = false, --  and 3rd on SMR/BB/BEC              |   [1,3] = [false] 
----------------------------------------------------------|-------------------
-- "START RACE" TIMER TRIGGER (Semifunctional) - Move     |     [3] = [true]
   trigSR = false, -- from "Track Select" > "START RACE"  |   [1,2] = [false] 
----------------------------------------------------------\___________________
-- ENABLE RESET TRIGGER - Triggers at file selection.
   reset = false, -- Ensure to set [false] if switching file/mode mid-run.
------------------------------------------------------------------------------
-- REMOVE UNFOCUSED TIME (Tabbed-Out Time) Requires RT No Loads. 
   noTab = false, -- Only affects LRT [useIGT = false], thus all presets. 
------------------------------------------------------------------------------
-- VIEW EXTRA STATS IN TERMINAL (when LibreSplit is run through the terminal).
   viewTermStats = false, -- Toggles the view of the following extra stats.
--  --  -VIEWABLE STATS  --  --  --  --  --  --  --  --  --  --  --  --  --  -
                viewIGT = true, -- Total race IGT
         viewCurRaceIGT = false, -- Current race IGT
          viewOverheats = false, -- Counts overheats over the whole run
             viewDeaths = true, -- Counts deaths over the whole run
--____________________________________________________________________________
------------------------------------------------------------------------------
}
```
Here is where all settings can be modified. The script settings include a minimal description of each option, this should be enough to work with. In most cases **```preset```** is the only setting that requires adjustment.  
  
> [!caution]
> ```lua
> setting = "value",
> ```
> **When adjusting a **```setting```** it is important that you:**
> * Only edit the **```value```**.
> * Only replace a **```value```** with another of its type. 
> * Make sure that any **```value```** is ended with a comma **```,```**.
>   
> Changing or removing any other syntax (like **```setting```** names, missing any commas **```,```** etc.) will break the script.
  
If you feel comfotable go ahead and adjust the settings to your liking. If you would like more information, each setting is described in greater detail after the **ENABLE SCRIPT** section.  
  

   
## ENABLE SCRIPT
* Open LibreSplit
* Right click in LibreSplit, check "Enable Auto Splitter" 
* Right click again, select "Open Auto Splitter"
  
![Rightclick in LibreSplit](https://github.com/Wuzzmi/swe1r-auto_splitter/blob/main/img/rightclick-autosplitter-libresplit.png)
  
* Now select the script and hit "Open"
  
![Open and Enable Autosplitter in LibreSplit](https://github.com/Wuzzmi/swe1r-autosplitter-libresplit/blob/main/img/open-autosplitter-libresplit.png)
  

  
> [!important]
> If you edit your script settings after the script has already been loaded and enabled, you will need to uncheck and recheck "Enable Auto Splitter" for the changes to take effect.
  
**Now everything is all set. The autosplitter will function when you run Star Wars Racer!**
___  
  
## FULL SETTINGS BREAKDOWN
### CATEGORY PRESET
```lua
preset = 1,
```
**```preset```** is a one setting adjustment for switching run categories. It functions as a override for a number of other settings. For this reason **```preset``` ```0```** exists, allowing full settings control for special use cases.
|  | None | Any% / Amateur / Semi-Pro | 100% | New Game + |
|:---:|:---:|:---:|:---:|:---:|
| **preset =** | 0 | 1 | 2 | 3 |  
___
### TIMING METHOD
```lua
useIGT = false,
```
Use **```useIGT```** to choose either LRT, or IGT. As shown in the table below, every category **```preset```** overrides to LRT (**```useIGT = false,```**). IGT is not useful for recording official runs, but is there if you have a use for them.

|  | In race Game Time (IGT) | Real Time No loads (LRT) |
|:---:|:---:|:---:|
|**useIGT =**| true | false |
| **```preset```** |  | **```1``` ```2``` ```3```** |

 > [!warning]
> ***\*\*BUG\*\****
>   
> While **```useIGT = true```**, if you right click in LibreSplit and select reload, you will trigger a bug. This bug will make your run act as a RTA run! To fix this, trigger a reset with the "reset timer" keybind, trigger an auto reset (if **```reset = true```**), or fully restart LibreSplit.
___
### REQUIRE 1ST PLACE
```lua
req1st = false,
```
**```req1st```** sets a requirement to finish in 1st place, in order to trigger a split. The normal win condition requires 4th place, or 3rd on the last track of a circuit ( SMR/BB/BEC ). **```req1st```** is mostly used for 100% runs, it is not of much use otherwise.
|  | Require 1st | Require 4th, 3rd (on SMR/BB/BEC) |
|:---:|:---:|:---:|
|**req1st =**| true | false |
| **```preset```** | **```2```** | **```1``` ```3```** |

___
### "START RACE" TIMER TRIGGER (Semifunctional)
```lua
trigSR = false,
```
**```trigSR```** will trigger auto start when "Start Race" is selected. Otherwise auto start will trigger at file open. **```trigSR```** is used for the New Game + category, which requires timing to start when selecting "Start Race" for the first track. Otherwise it's uses are limited.
|  | "Start Race" trigger | File open trigger |
|:---:|:---:|:---:|
|**trigSR =**| true | false |
| **```preset```** | **```3```** | **```1``` ```2```** |
> [!important]
> ***\*\*SEMIFUNCTIONAL\*\****
>   
> Currently for the timer to trigger, you must enter the track selection scene, then move directly to select "Start Race". If you deviate, just return to the track selection scene before heading to "Start Race". 

___
### ENABLE RESET TRIGGER
```lua
reset = false,
```
**```reset```** toggles auto reset on/off. It is important to use **```reset = false```** for All Tracks NG+ runs that require a file/mode change mid run. This stops file/mode changes from resetting and ruining the run. Aside from All Tracks NG+ runs, **```reset```** is just personal preference.
|  | Auto Reset On | Auto Reset Off |
|:---:|:---:|:---:|
|**reset =**| true | false |
| **```preset```** |  | **```3```** |
 
___
### REMOVE UNFOCUSED TIME (Tabbed-Out)
```lua
noTab = false,
```
Use **```noTab```** to set unfocused/tabbed-out time to registered as loading time, so it will not be counted on the timer. **```noTab```** will only take effect if **```useIGT = false,```** is set (this is most cases). Otherwise unfocused/tabbed-out time will be counted like normal. Usage of **```noTab```** is up to you.
|  | Tabbed Time Removed | Tabbed Time Counted |
|:---:|:---:|:---:|
|**noTab =**| true | false |
> [!warning]
> ***\*\*BUG\*\****
>  
> While **```noTab = true```**, if you use LibreSplits "Reset Timer" keybind, or right click in LibreSplit and click reload, you will trigger a bug!
> This bug seems to invert loading/tabbed-out time. So if the timer would normally be running it will not, but will run while in a loading screen or while tabbed-out.
> If this happens you will need to trigger an auto reset (if **```reset = true```**), or fully restart LibreSplit. 

___
### VIEW EXTRA STATS IN TERMINAL
```lua
viewTermStats = false,
```
**```viewTermStats```** toggles the viewing of your enabled stats in the terminal. **```viewTermStats```** has no effect unless you are running LibreSplit through the terminal, so keep **```false```** if not. This is not ideal, but is currently the best option. LiveSplit's "[ASL variable viewer](https://github.com/hawkerm/LiveSplit.ASLVarViewer)" plugin allows these stats to be viewed in [LiveSplit](https://github.com/LiveSplit/LiveSplit) (there is no LibreSplit alternative).   
  
Each stat is set the same way as **```viewTermStats```**.  
Like in this table:
  
|  | Enabled | Disabled |
|:---:|:---:|:---:|
|**viewTermStats =**| true | false |
|  |  |  |
|**viewIGT =**| true | false |
|**viewCurRaceIGT =**| true | etc... |  
  
### DISPLAYABLE STATS
___
**IGT**
```lua
viewIGT = true,
```
**```viewIGT```** displays you true IGT (totaled in game race times). This is very useful if you are using LRT or RTA as your timing method and also want to track IGT. The time displayed is the same as the IGT timing method.
___
**CURRENT RACE IGT**
```lua
viewCurRaceIGT = false,
```
**```viewCurRaceIGT```** displays the IGT of your current race only. This is identical to the ingame race timer. Not of much use, but it's here if you want it... maybe you want to see the most recent race IGT in the menu before starting your next race?
___
**OVERHEAT COUNT**
```lua
viewOverheats = false,
```
**```viewOverheats```** shows how many times you have overheated during your run.
> [!important]
> ***\*\*INACCURATE\*\****
> 
> **```viewOverheats```** is not totally accurate. Sometimes an overheat will be counted when a boost is cancelled within the last 0.2%. This stat maybe removed in the future, due to an indistinguishable grey area for determining if an overheat triggered or not. Use not recommended.
___
**DEATH COUNT**
```lua
viewDeaths = true,
```
**```viewDeaths```** shows how many times you have died during your run.
___

## POSSIBLE FUTURE IMPROVMENTS
* Determine a proper memory address for triggering the timer on "START RACE" selection (currently relying on sceneID, not ideal).
* Add option for each individual race time (idealy with individual lap times) to be printed in terminal at the end of a run.
* Fix/improve the accuacy of **```viewOverheats```** if possible.
* Possible addition of more terminal stats. The source [ASL script](https://github.com/everalert/swe1r-autosplitter/blob/master/swe1r.asl) seems to have a number of semi completed viewable stats in the process of being added.
  
## LICENSE
This repo is unlicensed.
