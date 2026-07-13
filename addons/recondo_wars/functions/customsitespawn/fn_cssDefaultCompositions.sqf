/*
    Recondo_fnc_cssDefaultCompositions
    Returns the built-in Custom Site Spawn compositions.

    Description:
        Provides the ready-made compositions selectable via checkboxes on the
        Custom Site Spawn module. Each value is an SQF array literal (as text)
        in the same format the paste box accepts, so it can be handed straight
        to Recondo_fnc_registerCustomComposition. Only the first three entries
        of each object row (classname, relative position, direction) are used
        by Recondo_fnc_loadComposition; the remaining grabber fields are ignored.

    Parameters:
        None

    Returns:
        HASHMAP - key (STRING) -> composition text (STRING)
                  keys: "abandonedcamp", "nvaccp", "nvatelegraph"
*/

private _abandonedCamp = str [
    ["Land_vn_c_prop_pot_01",[1.08252,1.07715,0],0,1,0,[0,0],"","",true,false],
    ["vn_weapon_srifle_sks_sniper",[-0.634766,2.04102,0.254332],227.693,1,0,[22.3611,-42.1209],"","",true,false],
    ["Land_vn_c_bigfallenbranches_pine",[-1.64307,-0.464844,0],0,1,0,[0,0],"","",true,false],
    ["Land_vn_pavn_can",[1.52051,1.96338,0],33.825,1,0,[0,0],"","",true,false],
    ["vn_weapon_arifle_type56",[0.138672,2.54565,0.369259],259.712,1,0,[-24.0288,-67.8461],"","",true,false],
    ["Land_vn_c_bigfallenbranches_pine02",[2.75781,-1.16089,0],73.3641,1,0,[0,0],"","",true,false],
    ["Land_vn_c_bigfallenbranches_pine02",[-0.941406,-3.11353,0],113.439,1,0,[0,-0],"","",true,false],
    ["Land_vn_d_fallentrunk_branches_lc_f",[0.851074,3.67163,-1.90735e-06],309.206,1,0,[0,0],"","",true,false],
    ["Land_vn_c_bigfallenbranches_pine03",[-4.021,2.16724,0],323.315,1,0,[0,0],"","",true,false],
    ["Land_vn_c_bigfallenbranches_pine03",[-5.44824,-0.913818,0],73.5584,1,0,[0,0],"","",true,false]
];

private _nvaCCP = str [
    ["Land_vn_b_prop_litter_01_02",[-0.192871,3.01855,0],360,1,0,[-5.84803e-06,-1.38076e-05],"","",true,false],
    ["BloodSplatter_01_Large_New_F",[-1.26172,2.77222,0],0,1,0,[0,0],"","",true,false],
    ["Land_vn_o_shelter_04",[-1.28174,2.94141,0],94.4245,1,0,[0,-0],"","",true,false],
    ["MedicalGarbage_01_1x1_v3_F",[-1.3252,2.95703,0],0,1,0,[0,0],"","",true,false],
    ["ACE_medicalSupplyCrate",[-0.119629,-3.26489,-4.76837e-07],277.359,1,0,[-0.00015964,-6.09552e-05],"","",true,false],
    ["Land_vn_rubber_tree_01",[1.21533,3.12695,0],0,1,0,[0,0],"","",true,false],
    ["Land_vn_o_shelter_04",[-1.77246,-3.10327,0],278.109,1,0,[0,0],"","",true,false],
    ["Land_vn_b_prop_litter_01_02",[-2.03516,3.07739,-4.76837e-07],0.000180586,1,0,[-3.23851e-05,0.000157647],"","",true,false],
    ["Land_vn_b_prop_litter_01_02",[-1.00635,-3.56445,0],180.525,1,0,[9.24306e-06,2.39163e-05],"","",true,false],
    ["MedicalGarbage_01_1x1_v3_F",[-2.41406,-3.16577,0],0,1,0,[0,0],"","",true,false],
    ["Land_vn_b_prop_litter_01_02",[3.13672,2.5415,-1.90735e-06],0.000510327,1,0,[-4.13496e-05,0.000280281],"","",true,false],
    ["MedicalGarbage_01_Bandage_F",[3.49854,2.25439,0],0,1,0,[0,0],"","",true,false],
    ["MedicalGarbage_01_Bandage_F",[-2.93994,-3.01611,0.0528531],0,1,0,[0,0],"","",true,false],
    ["BloodSplatter_01_Medium_New_F",[-2.6499,-3.28247,0],0,1,0,[0,0],"","",true,false],
    ["MedicalGarbage_01_Bandage_F",[3.78564,1.92358,0],0,1,0,[0,0],"","",true,false],
    ["BloodSplatter_01_Medium_New_F",[3.63232,2.19971,0],283.36,1,0,[0,0],"","",true,false],
    ["Land_vn_b_prop_litter_01_02",[-2.94824,-3.24072,-4.76837e-07],7.68386e-06,1,0,[1.55675e-08,6.44448e-07],"","",true,false],
    ["Land_vn_b_prop_litter_02",[2.41357,-3.69507,-9.53674e-07],0.00234153,1,0,[4.3195e-05,0.0019938],"","",true,false],
    ["Land_vn_o_shelter_04",[3.72949,2.37769,0],94.4245,1,0,[0,-0],"","",true,false],
    ["BloodSplatter_01_Small_New_F",[2.65723,-3.65723,0],0,1,0,[0,0],"","",true,false],
    ["MedicalGarbage_01_1x1_v3_F",[3.86377,2.82788,0],0,1,0,[0,0],"","",true,false],
    ["Land_vn_rubber_tree_01",[-4.90332,-1.38403,0],0,1,0,[0,0],"","",true,false],
    ["Land_vn_o_shelter_04",[3.57471,-3.6394,0],278.109,1,0,[0,0],"","",true,false],
    ["Land_vn_rubber_tree_01",[0.809082,-5.09253,0],0,1,0,[0,0],"","",true,false],
    ["Land_vn_b_prop_litter_01_02",[4.77344,2.51538,-4.76837e-07],1.71068e-05,1,0,[1.14797e-06,2.13516e-06],"","",true,false],
    ["Land_vn_b_prop_litter_01_02",[4.18555,-3.7605,0],360,1,0,[-5.84803e-06,-1.38076e-05],"","",true,false],
    ["Land_vn_rubber_tree_01",[5.55762,-1.46582,0],0,1,0,[0,0],"","",true,false],
    ["Land_vn_elephant_grass_01",[4.54297,7.24658,0],0,1,0,[0,0],"","",true,false],
    ["Land_vn_elephant_grass_01",[-7.38184,5.00562,0],0,1,0,[0,0],"","",true,false],
    ["Land_vn_elephant_grass_01",[-0.686523,8.9104,0],0,1,0,[0,0],"","",true,false],
    ["Land_vn_elephant_grass_01",[-9.24951,-1.96924,0],0,1,0,[0,0],"","",true,false],
    ["Land_vn_elephant_grass_01",[0.737793,-9.45093,0],0,1,0,[0,0],"","",true,false],
    ["Land_vn_elephant_grass_01",[8.604,3.89966,0],0,1,0,[0,0],"","",true,false],
    ["Land_vn_elephant_grass_01",[6.72363,-7.5769,0],0,1,0,[0,0],"","",true,false],
    ["Land_vn_elephant_grass_01",[-6.99023,-7.47192,0],0,1,0,[0,0],"","",true,false],
    ["Land_vn_elephant_grass_01",[9.95166,-3.3772,0],0,1,0,[0,0],"","",true,false],
    ["Land_vn_elephant_grass_01",[-3.39697,-10.8496,0],0,1,0,[0,0],"","",true,false]
];

private _nvaTelegraph = str [
    ["hatg_mirror",[0,0,0.00144196],259.648,1,0,[0,0],"","",true,false],
    ["Land_vn_ch_mod_c",[-1.13477,0.0303955,-1.52588e-05],88.9719,1,0,[-0.231895,-0.225619],"","",true,false],
    ["Land_vn_ch_mod_c",[0.0742188,-1.26395,0.254448],358.656,1,0,[-86.6683,44.7642],"","",true,false],
    ["Land_vn_o_shelter_02",[-0.983398,-0.623413,0.00723267],267.706,1,0,[0,0],"","",true,false],
    ["Land_vn_ch_mod_c",[-0.599609,-1.43344,-7.62939e-06],2.36131,1,0,[-0.46737,0.211237],"","",true,false],
    ["vn_o_item_map_case_01",[-1.61914,-0.336517,0.863884],0,1,0,[-0.228997,0.228994],"","",true,false],
    ["Land_WoodenTable_large_F",[-0.143555,-1.89532,0.00967407],267.614,1,0,[0.355175,2.106],"","",true,false],
    ["rtbf_flag_1_nva_3",[-0.0527344,1.548,1.20229],355.768,1,0,[0,0],"","",true,false],
    ["Land_WoodenTable_large_F",[-2.03125,-0.384613,-0.0001297],359.409,1,0,[-0.20644,0.31134],"","",true,false],
    ["vn_o_prop_r311_01",[0.305664,-1.9017,0.871819],182.382,1,0,[2.38981,-0.178399],"","",true,false],
    ["vn_o_prop_r311_01",[-0.568359,-1.86844,0.869865],182.866,1,0,[2.37807,-0.147285],"","",true,false],
    ["vn_o_prop_t102e_01",[-2.06445,0.107727,0.862198],268.845,1,0,[0.26852,0.254126],"","",true,false],
    ["vn_o_prop_t884_01",[-1.93164,-0.814941,0.862381],262.119,1,0,[1.2913,0.220285],"","",true,false],
    ["wx_defenceposition_06_MapTripod",[-1.98438,-2.01816,-7.62939e-06],226.645,1,0,[0.157212,0.166506],"","",true,false],
    ["Land_vn_rubber_tree_01",[-1.75488,2.43472,7.62939e-06],0,1,0,[0,0.228993],"","",true,false],
    ["Land_vn_rubber_tree_01",[0.0664063,-3.71909,7.62939e-06],0,1,0,[-0.228997,0],"","",true,false],
    ["Land_vn_elephant_grass_01",[1.6582,4.1626,0],0,1,0,[0,0],"","",true,false],
    ["Land_vn_rubber_tree_01",[-5.81445,-1.12021,0],0,1,0,[0,0.228993],"","",true,false],
    ["Land_vn_elephant_grass_01",[-5.88672,0.337402,9.91821e-05],0,1,0,[0,0.228993],"","",true,false],
    ["Land_vn_elephant_grass_01",[1.08203,-5.80261,0.00012207],0,1,0,[-0.228997,0],"","",true,false],
    ["Land_vn_elephant_grass_01",[4.98535,-3.22473,6.86646e-05],0,1,0,[-0.228997,-0.228999],"","",true,false],
    ["Land_vn_elephant_grass_01",[-3.5752,4.89807,3.8147e-05],0,1,0,[0.228993,0.228994],"","",true,false],
    ["Land_vn_elephant_grass_01",[-4.61426,-4.86987,0],0,1,0,[0,0],"","",true,false],
    ["Land_vn_elephant_grass_01",[6.96973,3.42029,6.86646e-05],0,1,0,[-0.228997,-0.228999],"","",true,false]
];

createHashMapFromArray [
    ["abandonedcamp", _abandonedCamp],
    ["nvaccp", _nvaCCP],
    ["nvatelegraph", _nvaTelegraph]
]
