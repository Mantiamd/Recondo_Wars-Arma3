/*
    HVT Profile: Nikos Panagopoulos
    Default HVT profile for Recondo Wars
*/

createHashMapFromArray [
    ["name", "Nikos Panagopoulos"],
    ["classname", "C_Nikos"],
    ["photo", "\recondo_wars\images\intel\Nikos_cards.jpg"],
    ["background", "Local warlord with connections to regional smuggling operations. Wanted for orchestrating attacks on coalition forces and civilian infrastructure."],
    
    // Identity class from CfgIdentities (handles face, voice, name)
    ["identity", "Nikos"],
    
    // Loadout array format (from getUnitLoadout / Arsenal export)
    ["loadout", [
        [],                                                      // 0: primary weapon
        [],                                                      // 1: secondary weapon
        [],                                                      // 2: handgun
        ["U_NikosBody", []],                                     // 3: uniform [class, items]
        [],                                                      // 4: vest
        [],                                                      // 5: backpack
        "",                                                      // 6: headgear
        "",                                                      // 7: goggles
        [],                                                      // 8: binoculars
        ["ItemMap", "", "", "ItemCompass", "ItemWatch", ""]      // 9: linked items [map, gps, radio, compass, watch, nvg]
    ]]
]
