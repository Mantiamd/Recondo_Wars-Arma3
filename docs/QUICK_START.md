# Recondo Wars - Quick Start Guide

This guide walks you through setting up a basic mission using Recondo Wars modules. By the end, you'll have a working mission with an HVT objective, AI patrols, persistence, and an admin terminal.

## Prerequisites

- Arma 3 with Eden Editor
- [CBA_A3](https://steamcommunity.com/sharedfiles/filedetails/?id=450814997)
- [ACE3](https://steamcommunity.com/sharedfiles/filedetails/?id=463939057)
- Recondo Wars mod loaded

## Step 1: Place Core Modules

Open Eden Editor and place these modules from the **Recondo Wars** category:

### Persistence System (Required for saving)
1. Place a **Persistence System** module
2. Set a **Campaign Name** (e.g., "MyFirstMission") - this is used as the save identifier
3. Leave other settings at defaults

### Terminal (Recommended)
1. Place a **Terminal** module
2. Place a map object (e.g., a table or laptop) near your player spawn
3. **Sync** the Terminal module to the object (drag a line from module to object)
4. **Sync** the Terminal module to the Persistence module (drag a line between them)
5. During the mission, ACE-interact with the object to access admin functions

> **Tip:** Enable **Master Debug** on the Terminal module during testing. This turns on debug logging for ALL modules at once.

## Step 2: Place Map Markers

Most Recondo Wars modules use map markers to define locations. Markers must follow a naming convention based on the module's **Marker Prefix** setting.

### Marker Naming Rules
- Markers must start with the prefix defined in the module
- Add numbers after the prefix: `PREFIX_1`, `PREFIX_2`, `PREFIX_3`, etc.
- Markers should be **invisible** (empty icon) unless you want them visible on the map
- Place markers where you want things to spawn

### Example: HVT Markers
If your HVT module uses prefix `HVT_`:
- Place markers named `HVT_1`, `HVT_2`, `HVT_3`, etc.
- You need at least enough markers for 1 HVT location + your configured number of decoys

## Step 3: Set Up an Objective

### Objective HVT (Example)
1. Place an **Objective - HVT** module
2. Configure the **Profile Pool** tab - check at least one profile or manually enter HVT details
3. Set **Marker Prefix** to `HVT_` (must match your markers)
4. Under **Composition Pool**, check at least one default composition
5. Under **Spawning**, choose "Immediate" or "Proximity"
   - **Immediate**: Everything spawns at mission start
   - **Proximity**: Compositions spawn when players approach (better for performance)
6. Under **Garrison AI**, set classnames for guards (e.g., `vn_o_men_nva_01,vn_o_men_nva_02`)
7. Under **HVT Settings**, set the number of decoy locations

### Other Objectives Follow the Same Pattern
- **Objective Destroy**: Prefix markers (e.g., `CACHE_1`, `CACHE_2`), set target classname
- **Objective Hostages**: Prefix markers (e.g., `HOSTAGE_1`, `HOSTAGE_2`), configure hostage profiles
- **Objective Jammer**: Prefix markers (e.g., `JAMMER_1`, `JAMMER_2`), set jammer classname

## Step 4: Add AI Patrols

### Foot Patrols
1. Place a **Foot Patrols** module
2. Set **Marker Prefix** (e.g., `PATROL_`)
3. Place markers where patrols should spawn: `PATROL_1`, `PATROL_2`, etc.
4. Set **Unit Classnames** (e.g., `vn_o_men_nva_01,vn_o_men_nva_02`)
5. Configure group size, behavior, and trigger side

### AI Tweaks
1. Place an **AI Tweaks** module
2. Set **Target Side** to the AI side you want to configure (e.g., OPFOR)
3. Adjust skill sliders under the Regular, Elite, and AA categories
4. Place a second module if you want different settings for another side

## Step 5: Configure Players

### Player Options
1. Place a **Player Options** module
2. Configure graphics restrictions, traits, and other player settings
3. This module affects all players automatically

## Step 6: Test Your Mission

1. Save and preview your mission
2. On mission start, you'll see `Recondo Wars v1.0.0 loaded` in system chat
3. If any modules have configuration issues (like missing markers), you'll see warnings in system chat
4. Check the RPT log for detailed debug output if Master Debug is enabled

## Common Issues

### "No markers found with prefix..."
You'll see this warning in system chat if a module can't find its markers. Make sure:
- Marker names exactly match the prefix (case-sensitive)
- Markers are numbered: `PREFIX_1`, `PREFIX_2`, etc.
- You've placed enough markers for the module's requirements

### AI not spawning on the correct side
Use the module's **AI Side** or **Garrison AI Side** setting. If using unit classnames from a different faction (e.g., independent classnames but want OPFOR), the module will force them to the configured side.

### Compositions not appearing
- Check that the composition source is set correctly (Default, Custom, or Both)
- For custom compositions, verify the folder path is relative to your mission root
- Enable debug logging to see composition spawn messages in RPT

### Persistence not saving
- Ensure the **Persistence System** module is placed
- The Campaign Name must not be empty
- Persistence saves automatically at the configured interval
- Use the Terminal to manually trigger saves or reset persistence

## Module Reference

For detailed information on each module's attributes, hover over any setting in Eden Editor to see its tooltip with descriptions and examples.

### Modules That Use Markers
| Module | Default Prefix | Marker Example |
|--------|---------------|----------------|
| Objective Destroy | `CACHE_` | CACHE_1, CACHE_2 |
| Objective HVT | `HVT_` | HVT_1, HVT_2 |
| Objective Hostages | `HOSTAGE_` | HOSTAGE_1, HOSTAGE_2 |
| Objective Jammer | `JAMMER_` | JAMMER_1, JAMMER_2 |
| Objective Hub & Subs | `HUB_` | HUB_1, HUB_1a, HUB_1b |
| Foot Patrols | `PATROL_` | PATROL_1, PATROL_2 |
| Path Patrols | `PATROLa_` | PATROLa_1, PATROLa_2 |
| Static Defense | `AA_` | AA_1, AA_2 |
| Camps Random | `CAMP_` | CAMP_1, CAMP_2 |
| Outpost Teleport | `Outpost_` | Outpost_1, Outpost_2 |
| POO Site Hunt | `POO_` | POO_1, POO_2 |
| Custom Site Spawn | `SITE_` | SITE_1, SITE_2 |

### Modules That Sync to Objects
| Module | Sync To |
|--------|---------|
| Terminal | Any object + Persistence module |
| Bad Civi | AI unit(s) |
| Destroy Powergrid | World object with lights |
| ACE Arsenal Area | Object or area |
| ACE Spectator Object | Object |
| STABO Extraction | Helicopter(s) |
| Intel Board | Object (whiteboard, etc.) |

### Multi-Instance Modules
These modules can be placed multiple times:
- AI Tweaks (one per side)
- Objective Destroy, HVT, Hostages, Jammer, Hub & Subs
- Foot Patrols, Path Patrols
- Camps Random, Custom Site Spawn
- Bad Civi, POO Site Hunt, Destroy Powergrid
- Reinforcement Waves
- Ambient Sound, Civilians Working
