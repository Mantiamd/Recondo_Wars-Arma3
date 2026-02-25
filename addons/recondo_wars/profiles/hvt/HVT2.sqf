/*
    HVT Profile: Solomon Maru
    Default HVT profile for Recondo Wars
*/

createHashMapFromArray [
    ["name", "Solomon Maru"],
    ["classname", "I_C_Soldier_Camo_F"],
    ["photo", "\recondo_wars\images\intel\Maru_card.jpg"],
    ["background", "Former military officer turned insurgent commander. Intelligence suggests he coordinates supply routes and weapons distribution across the region."],
    
    // Face and speaker (direct classnames)
    ["face", "TanoanBossHead"],
    ["speaker", "male02fre"],
    
    // Loadout array format (from getUnitLoadout / Arsenal export)
    ["loadout", [
        [],                                                      // 0: primary weapon
        [],                                                      // 1: secondary weapon
        [],                                                      // 2: handgun
        ["U_I_C_Soldier_Camo_F", [["FirstAidKit", 1]]],          // 3: uniform [class, items]
        [],                                                      // 4: vest
        [],                                                      // 5: backpack
        "H_MilCap_gry",                                          // 6: headgear
        "",                                                      // 7: goggles
        [],                                                      // 8: binoculars
        ["ItemMap", "", "ItemRadio", "ItemCompass", "ItemWatch", ""]  // 9: linked items
    ]]
]
