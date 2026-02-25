/*
    HVT Profile: Colonel Akhanteros
    Default HVT profile for Recondo Wars
*/

createHashMapFromArray [
    ["name", "Colonel Akhanteros"],
    ["classname", "I_Story_Colonel_F"],
    ["photo", "\recondo_wars\images\intel\Akhanteros_card.jpg"],
    ["background", "Foreign advisor embedded with local insurgent cells. Suspected of providing tactical training and planning operations against coalition patrols."],
    
    // Face and speaker (direct classnames)
    ["face", "GreekHead_A3_03"],
    ["speaker", "male01gre"],
    
    // Loadout array format (from getUnitLoadout / Arsenal export)
    ["loadout", [
        [],                                                      // 0: primary weapon
        [],                                                      // 1: secondary weapon
        [],                                                      // 2: handgun
        ["U_I_C_Soldier_Para_2_F", [["FirstAidKit", 1]]],        // 3: uniform [class, items]
        [],                                                      // 4: vest
        [],                                                      // 5: backpack
        "H_Beret_grn",                                           // 6: headgear
        "",                                                      // 7: goggles
        [],                                                      // 8: binoculars
        ["ItemMap", "ItemGPS", "ItemRadio", "ItemCompass", "ItemWatch", ""]  // 9: linked items
    ]]
]
