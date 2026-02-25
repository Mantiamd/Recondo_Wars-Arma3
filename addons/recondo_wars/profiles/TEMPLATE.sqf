/*
    RECONDO WARS - TARGET PROFILE TEMPLATE
    ======================================
    
    This file serves as a template for creating HVT and Hostage profiles.
    Copy this file and rename it to something descriptive.
    
    NAMING:
        - You can use ANY filename you want (e.g., DrugLord.sqf, Warlord.sqf, Journalist.sqf)
        - The module's "Profile Pool List" attribute specifies which files to load
        - Example pool list: "HVT1.sqf, DrugLord.sqf, Warlord.sqf, BadGuy.sqf"
    
    LOCATION:
        - Default (mod): addons/recondo_wars/profiles/hvt/ or /hostages/
        - Custom (mission): yourMission.mapName/profiles/hvt/ or /hostages/
    
    HOW IT WORKS:
        1. Create profile .sqf files with target data
        2. In the module, enable "Use Profile Pool"
        3. List the filenames you want in the pool (e.g., "HVT1.sqf, HVT2.sqf, DrugLord.sqf")
        4. Set how many to randomly select per mission
        5. Each playthrough picks different targets from your specified pool
    
    REQUIRED FIELDS:
        - name: Display name shown to players
        - classname: Unit classname to spawn
    
    OPTIONAL FIELDS:
        - identity: Identity class from CfgIdentities (e.g., "Nikos", "Miller"). 
                    Sets face, voice, and default name. Takes priority over 'face' field.
        - loadout: Full loadout array from getUnitLoadout / Arsenal "Array" export.
                   If not defined, HVT spawns stripped to basic unarmed civilian.
        - face: Direct face classname (e.g., "GreekHead_A3_03", "TanoanBossHead").
                Used when 'identity' is not defined.
        - speaker: Voice/speaker classname (e.g., "male01gre", "male02fre").
                   Used with 'face' when 'identity' is not defined.
        - photo: Path to 256x256 face image (.paa recommended)
        - background: Lore/backstory text shown in intel and terminal
    
    EXPORTING LOADOUTS FROM ARSENAL:
        1. Open Arsenal on a unit in Eden Editor
        2. Configure appearance and gear as desired
        3. Click "Export" button (bottom right)
        4. Select "Array" format (NOT "SQF" or "Config")
        5. Copy the array and paste into the "loadout" field below
    
    COMMON IDENTITY CLASSES (from CfgIdentities):
        - "Nikos" - Greek civilian
        - "Orestes" - Greek civilian  
        - "Miller" - NATO officer
        - "Kerry" - NATO soldier
        (Check CfgIdentities in config viewer for more options)
    
    COMMON FACE CLASSNAMES (for legacy 'face' field):
        - WhiteHead_01 through WhiteHead_20
        - GreekHead_A3_01 through GreekHead_A3_09
        - AfricanHead_01 through AfricanHead_03
        - AsianHead_A3_01 through AsianHead_A3_03
        - PersianHead_A3_01 through PersianHead_A3_03
        (Check CfgFaces in config viewer for more options)
    
    PHOTO PATHS:
        - Mod photos: \recondo_wars\images\intel\filename.paa
        - Mission photos: photos\filename.paa (relative to mission folder)
        - Recommended size: 480x700 pixels (portrait orientation)
        - Supported formats: .paa, .jpg, .png
    
    Returns: HASHMAP with target data
*/

// EXAMPLE PROFILE - Replace values with your own
createHashMapFromArray [
    // REQUIRED: Target's display name
    ["name", "Target Name Here"],
    
    // REQUIRED: Unit classname to spawn
    // Common civilians: C_man_1, C_Man_casual_1_F, C_Nikos, C_Orestes
    // Story civilians: C_Story_Mechanic_01_F, C_Story_EOD_01_F
    ["classname", "C_man_1"],
    
    // OPTIONAL: Identity class from CfgIdentities (face, voice, name)
    // Examples: "Nikos", "Orestes", "Miller", "Kerry"
    // Leave empty "" to use default from classname or 'face' field
    ["identity", ""],
    
    // OPTIONAL: Full loadout array (export from Arsenal as "Array" format)
    // Leave empty [] to use default stripped civilian appearance
    // Format: [primaryWeapon, secondaryWeapon, handgun, uniform, vest, backpack, headgear, goggles, binoculars, linkedItems]
    // Example (unarmed civilian with uniform, headgear, and basic items):
    // ["loadout", [
    //     [],                                                      // 0: primary weapon
    //     [],                                                      // 1: secondary weapon
    //     [],                                                      // 2: handgun
    //     ["U_C_Poloshirt_blue", []],                              // 3: uniform [class, items]
    //     [],                                                      // 4: vest
    //     [],                                                      // 5: backpack
    //     "H_Cap_blk",                                             // 6: headgear
    //     "",                                                      // 7: goggles
    //     [],                                                      // 8: binoculars
    //     ["ItemMap", "", "", "ItemCompass", "ItemWatch", ""]      // 9: linked items [map, gps, radio, compass, watch, nvg]
    // ]],
    ["loadout", []],
    
    // OPTIONAL: Direct face classname (used when 'identity' is not defined)
    // Examples: "GreekHead_A3_05", "WhiteHead_12", "TanoanBossHead"
    ["face", ""],
    
    // OPTIONAL: Voice/speaker classname (used with 'face' when 'identity' is not defined)
    // Examples: "male01gre", "male02fre", "male01eng"
    ["speaker", ""],
    
    // OPTIONAL: Path to face photo (256x256 .paa recommended)
    // Leave empty "" to use default silhouette
    ["photo", ""],
    
    // OPTIONAL: Background/lore text
    // Shown when intel is revealed and in the mission terminal
    // Can be multiple sentences describing who they are and why they matter
    ["background", ""]
]
