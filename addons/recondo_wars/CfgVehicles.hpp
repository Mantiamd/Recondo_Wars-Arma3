class CfgFactionClasses {
    class NO_CATEGORY;
    class Recondo_Modules: NO_CATEGORY {
        displayName = "Recondo Wars";
        priority = 2;
        side = 7;
    };
};

class CfgVehicles {
    class Logic;
    class Module_F: Logic {
        class AttributesBase {
            class Default;
            class Edit;
            class Combo;
            class Checkbox;
            class Slider;
            class ModuleDescription;
        };
        class ModuleDescription;
    };
    
    //==========================================
    // AI TWEAKS MODULE
    //==========================================
    class Recondo_Module_AITweaks: Module_F {
        scope = 2;
        displayName = "AI Tweaks";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleAITweaks";
        functionPriority = 1;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 1;
        icon = "\recondo_wars\images\icons\AI_Tweaks.paa";
        
        class ModuleDescription: ModuleDescription {
            description = "Configures AI skill levels, behavior, and equipment per side. Place one module per side you want to tweak. Base settings apply to all units except those defined as Elite Soldiers or AA Gunners.";
            sync[] = {};
        };
        
        class Attributes: AttributesBase {
            
            // GENERAL SETTINGS
            class TargetSide {
                displayName = "GENERAL - Target Side";
                tooltip = "Which side's AI units should be affected by these tweaks.";
                control = "Combo";
                property = "Recondo_AITweaks_TargetSide";
                expression = "_this setVariable ['targetside', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0";
                category = "Recondo_AITweaks_General";
                class Values {
                    class East { name = "OPFOR (East)"; value = 0; };
                    class West { name = "BLUFOR (West)"; value = 1; };
                    class Guer { name = "Independent"; value = 2; };
                    class Civ { name = "Civilian"; value = 3; };
                };
            };
            
            // REGULAR SOLDIERS
            class EnableBaseSkills {
                displayName = "REGULAR - Enable Skill Modifications";
                tooltip = "Enable skill modifications for Regular soldiers (all units not listed as Elite or AA).";
                control = "Checkbox";
                property = "Recondo_AITweaks_EnableBaseSkills";
                expression = "_this setVariable ['enablebaseskills', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_AITweaks_Base";
            };
            class Base_AimingAccuracy {
                displayName = "Aiming Accuracy";
                tooltip = "How accurately the AI aims. 0 = very inaccurate, 1 = perfect aim.";
                control = "Slider";
                property = "Recondo_AITweaks_Base_AimingAccuracy";
                expression = "_this setVariable ['base_aimingaccuracy', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.1";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_AITweaks_Base_Skills";
            };
            class Base_AimingShake {
                displayName = "Aiming Shake";
                tooltip = "How much the AI's aim shakes. 0 = lots of shake, 1 = steady aim.";
                control = "Slider";
                property = "Recondo_AITweaks_Base_AimingShake";
                expression = "_this setVariable ['base_aimingshake', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.1";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_AITweaks_Base_Skills";
            };
            class Base_AimingSpeed {
                displayName = "Aiming Speed";
                tooltip = "How quickly AI acquires targets. 0 = slow, 1 = instant.";
                control = "Slider";
                property = "Recondo_AITweaks_Base_AimingSpeed";
                expression = "_this setVariable ['base_aimingspeed', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.1";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_AITweaks_Base_Skills";
            };
            class Base_SpotDistance {
                displayName = "Spot Distance";
                tooltip = "How far AI can detect enemies. 0 = short range, 1 = maximum range.";
                control = "Slider";
                property = "Recondo_AITweaks_Base_SpotDistance";
                expression = "_this setVariable ['base_spotdistance', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.1";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_AITweaks_Base_Skills";
            };
            class Base_SpotTime {
                displayName = "Spot Time";
                tooltip = "How quickly AI spots enemies. 0 = slow, 1 = instant detection.";
                control = "Slider";
                property = "Recondo_AITweaks_Base_SpotTime";
                expression = "_this setVariable ['base_spottime', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.1";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_AITweaks_Base_Skills";
            };
            class Base_Courage {
                displayName = "Courage";
                tooltip = "AI willingness to engage and resist suppression. 0 = cowardly, 1 = fearless.";
                control = "Slider";
                property = "Recondo_AITweaks_Base_Courage";
                expression = "_this setVariable ['base_courage', _value, true];";
                typeName = "NUMBER";
                defaultValue = "1.0";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_AITweaks_Base_Skills";
            };
            class Base_Commanding {
                displayName = "Commanding";
                tooltip = "AI leadership ability and group coordination. 0 = poor, 1 = excellent.";
                control = "Slider";
                property = "Recondo_AITweaks_Base_Commanding";
                expression = "_this setVariable ['base_commanding', _value, true];";
                typeName = "NUMBER";
                defaultValue = "1.0";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_AITweaks_Base_Skills";
            };
            class Base_General {
                displayName = "General";
                tooltip = "Overall AI intelligence. 0 = dumb, 1 = smart.";
                control = "Slider";
                property = "Recondo_AITweaks_Base_General";
                expression = "_this setVariable ['base_general', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.1";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_AITweaks_Base_Skills";
            };
            class Base_ReloadSpeed {
                displayName = "Reload Speed";
                tooltip = "How fast AI reloads weapons. 0 = slow, 1 = fast.";
                control = "Slider";
                property = "Recondo_AITweaks_Base_ReloadSpeed";
                expression = "_this setVariable ['base_reloadspeed', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.3";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_AITweaks_Base_Skills";
            };
            class Base_ForceWalk {
                displayName = "Force Walk";
                tooltip = "Force AI to walk instead of run. Released when combat starts.";
                control = "Checkbox";
                property = "Recondo_AITweaks_Base_ForceWalk";
                expression = "_this setVariable ['base_forcewalk', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_AITweaks_Base_Behavior";
            };
            class Base_ForceStand {
                displayName = "Force Stand";
                tooltip = "Force AI to remain standing (no prone or crouch).";
                control = "Checkbox";
                property = "Recondo_AITweaks_Base_ForceStand";
                expression = "_this setVariable ['base_forcestand', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_AITweaks_Base_Behavior";
            };
            class Base_AnimSpeedCoef {
                displayName = "Animation Speed";
                tooltip = "Animation speed multiplier. 1.0 = normal, 1.5 = 50% faster.";
                control = "Slider";
                property = "Recondo_AITweaks_Base_AnimSpeedCoef";
                expression = "_this setVariable ['base_animspeedcoef', _value, true];";
                typeName = "NUMBER";
                defaultValue = "1.5";
                sliderRange[] = {0.5, 2.0};
                sliderStep = 0.1;
                category = "Recondo_AITweaks_Base_Behavior";
            };
            class Base_DisableCover {
                displayName = "Disable Cover Seeking";
                tooltip = "Prevent AI from automatically seeking cover. WARNING: Enabling this may cause AI to spam voicelines.";
                control = "Checkbox";
                property = "Recondo_AITweaks_Base_DisableCover";
                expression = "_this setVariable ['base_disablecover', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_AITweaks_Base_AIFeatures";
            };
            class Base_DisableMineDetection {
                displayName = "Disable Mine Detection";
                tooltip = "Prevent AI from detecting mines.";
                control = "Checkbox";
                property = "Recondo_AITweaks_Base_DisableMineDetection";
                expression = "_this setVariable ['base_disableminedetection', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_AITweaks_Base_AIFeatures";
            };
            class Base_DisableNVG {
                displayName = "Disable NVG Usage";
                tooltip = "Prevent AI from using night vision goggles.";
                control = "Checkbox";
                property = "Recondo_AITweaks_Base_DisableNVG";
                expression = "_this setVariable ['base_disablenvg', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_AITweaks_Base_AIFeatures";
            };
            class Base_DisableSuppression {
                displayName = "Disable Suppression";
                tooltip = "Prevent AI from being affected by suppressive fire.";
                control = "Checkbox";
                property = "Recondo_AITweaks_Base_DisableSuppression";
                expression = "_this setVariable ['base_disablesuppression', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_AITweaks_Base_AIFeatures";
            };
            class Base_DisableAutoCombat {
                displayName = "Disable Auto Combat";
                tooltip = "Prevent AI from automatically switching to combat mode.";
                control = "Checkbox";
                property = "Recondo_AITweaks_Base_DisableAutoCombat";
                expression = "_this setVariable ['base_disableautocombat', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_AITweaks_Base_AIFeatures";
            };
            class Base_RemoveGrenades {
                displayName = "Remove Grenades";
                tooltip = "Remove specified grenades/throwables from AI inventory.";
                control = "Checkbox";
                property = "Recondo_AITweaks_Base_RemoveGrenades";
                expression = "_this setVariable ['base_removegrenades', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_AITweaks_Base_Equipment";
            };
            class Base_GrenadesToRemove {
                displayName = "Grenades to Remove";
                tooltip = "Comma-separated list of grenade classnames to remove.";
                control = "Edit";
                property = "Recondo_AITweaks_Base_GrenadesToRemove";
                expression = "_this setVariable ['base_grenadestoremove', _value, true];";
                typeName = "STRING";
                defaultValue = """vn_t67_grenade_mag,vn_rdg2_mag,vn_rgd5_grenade_mag,vn_molotov_grenade_mag""";
                category = "Recondo_AITweaks_Base_Equipment";
            };
            class Base_EnableFlashlights {
                displayName = "Enable Flashlights";
                tooltip = "Equip flashlights and automatically toggle them on/off based on light level (on at dusk/night, off during day). Enable 'Disable NVG' for AI to use visible light effectively.";
                control = "Checkbox";
                property = "Recondo_AITweaks_Base_EnableFlashlights";
                expression = "_this setVariable ['base_enableflashlights', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_AITweaks_Base_Equipment";
            };
            class Base_FlashlightClass {
                displayName = "Flashlight Classname";
                tooltip = "Classname of the flashlight attachment. Default: acc_flashlight";
                control = "Edit";
                property = "Recondo_AITweaks_Base_FlashlightClass";
                expression = "_this setVariable ['base_flashlightclass', _value, true];";
                typeName = "STRING";
                defaultValue = """acc_flashlight""";
                category = "Recondo_AITweaks_Base_Equipment";
            };
            
            // ELITE SOLDIERS
            class EliteClassnames {
                displayName = "ELITE - Classnames";
                tooltip = "Comma-separated list of unit classnames to treat as Elite Soldiers.";
                control = "Edit";
                property = "Recondo_AITweaks_EliteClassnames";
                expression = "_this setVariable ['eliteclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_AITweaks_Elite";
            };
            class EnableEliteSkills {
                displayName = "Enable Skill Modifications";
                tooltip = "Enable skill modifications for Elite soldiers.";
                control = "Checkbox";
                property = "Recondo_AITweaks_EnableEliteSkills";
                expression = "_this setVariable ['enableeliteskills', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_AITweaks_Elite";
            };
            class Elite_AimingAccuracy {
                displayName = "Aiming Accuracy";
                tooltip = "How accurately the AI aims.";
                control = "Slider";
                property = "Recondo_AITweaks_Elite_AimingAccuracy";
                expression = "_this setVariable ['elite_aimingaccuracy', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.4";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_AITweaks_Elite_Skills";
            };
            class Elite_AimingShake {
                displayName = "Aiming Shake";
                tooltip = "How much the AI's aim shakes.";
                control = "Slider";
                property = "Recondo_AITweaks_Elite_AimingShake";
                expression = "_this setVariable ['elite_aimingshake', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.3";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_AITweaks_Elite_Skills";
            };
            class Elite_AimingSpeed {
                displayName = "Aiming Speed";
                tooltip = "How quickly AI acquires targets.";
                control = "Slider";
                property = "Recondo_AITweaks_Elite_AimingSpeed";
                expression = "_this setVariable ['elite_aimingspeed', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.4";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_AITweaks_Elite_Skills";
            };
            class Elite_SpotDistance {
                displayName = "Spot Distance";
                tooltip = "How far AI can detect enemies.";
                control = "Slider";
                property = "Recondo_AITweaks_Elite_SpotDistance";
                expression = "_this setVariable ['elite_spotdistance', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.5";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_AITweaks_Elite_Skills";
            };
            class Elite_SpotTime {
                displayName = "Spot Time";
                tooltip = "How quickly AI spots enemies.";
                control = "Slider";
                property = "Recondo_AITweaks_Elite_SpotTime";
                expression = "_this setVariable ['elite_spottime', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.4";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_AITweaks_Elite_Skills";
            };
            class Elite_Courage {
                displayName = "Courage";
                tooltip = "AI willingness to engage and resist suppression.";
                control = "Slider";
                property = "Recondo_AITweaks_Elite_Courage";
                expression = "_this setVariable ['elite_courage', _value, true];";
                typeName = "NUMBER";
                defaultValue = "1.0";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_AITweaks_Elite_Skills";
            };
            class Elite_Commanding {
                displayName = "Commanding";
                tooltip = "AI leadership ability and group coordination.";
                control = "Slider";
                property = "Recondo_AITweaks_Elite_Commanding";
                expression = "_this setVariable ['elite_commanding', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.8";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_AITweaks_Elite_Skills";
            };
            class Elite_General {
                displayName = "General";
                tooltip = "Overall AI intelligence.";
                control = "Slider";
                property = "Recondo_AITweaks_Elite_General";
                expression = "_this setVariable ['elite_general', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.4";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_AITweaks_Elite_Skills";
            };
            class Elite_ReloadSpeed {
                displayName = "Reload Speed";
                tooltip = "How fast AI reloads weapons.";
                control = "Slider";
                property = "Recondo_AITweaks_Elite_ReloadSpeed";
                expression = "_this setVariable ['elite_reloadspeed', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.5";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_AITweaks_Elite_Skills";
            };
            class Elite_ForceWalk {
                displayName = "Force Walk";
                tooltip = "Force AI to walk instead of run.";
                control = "Checkbox";
                property = "Recondo_AITweaks_Elite_ForceWalk";
                expression = "_this setVariable ['elite_forcewalk', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_AITweaks_Elite_Behavior";
            };
            class Elite_ForceStand {
                displayName = "Force Stand";
                tooltip = "Force AI to remain standing.";
                control = "Checkbox";
                property = "Recondo_AITweaks_Elite_ForceStand";
                expression = "_this setVariable ['elite_forcestand', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_AITweaks_Elite_Behavior";
            };
            class Elite_AnimSpeedCoef {
                displayName = "Animation Speed";
                tooltip = "Animation speed multiplier.";
                control = "Slider";
                property = "Recondo_AITweaks_Elite_AnimSpeedCoef";
                expression = "_this setVariable ['elite_animspeedcoef', _value, true];";
                typeName = "NUMBER";
                defaultValue = "1.0";
                sliderRange[] = {0.5, 2.0};
                sliderStep = 0.1;
                category = "Recondo_AITweaks_Elite_Behavior";
            };
            class Elite_DisableCover {
                displayName = "Disable Cover Seeking";
                tooltip = "Prevent AI from seeking cover. WARNING: Enabling this may cause AI to spam voicelines.";
                control = "Checkbox";
                property = "Recondo_AITweaks_Elite_DisableCover";
                expression = "_this setVariable ['elite_disablecover', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_AITweaks_Elite_AIFeatures";
            };
            class Elite_DisableMineDetection {
                displayName = "Disable Mine Detection";
                tooltip = "Prevent AI from detecting mines.";
                control = "Checkbox";
                property = "Recondo_AITweaks_Elite_DisableMineDetection";
                expression = "_this setVariable ['elite_disableminedetection', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_AITweaks_Elite_AIFeatures";
            };
            class Elite_DisableNVG {
                displayName = "Disable NVG Usage";
                tooltip = "Prevent AI from using NVGs.";
                control = "Checkbox";
                property = "Recondo_AITweaks_Elite_DisableNVG";
                expression = "_this setVariable ['elite_disablenvg', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_AITweaks_Elite_AIFeatures";
            };
            class Elite_DisableSuppression {
                displayName = "Disable Suppression";
                tooltip = "Prevent AI from being suppressed.";
                control = "Checkbox";
                property = "Recondo_AITweaks_Elite_DisableSuppression";
                expression = "_this setVariable ['elite_disablesuppression', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_AITweaks_Elite_AIFeatures";
            };
            class Elite_DisableAutoCombat {
                displayName = "Disable Auto Combat";
                tooltip = "Prevent AI from auto combat mode.";
                control = "Checkbox";
                property = "Recondo_AITweaks_Elite_DisableAutoCombat";
                expression = "_this setVariable ['elite_disableautocombat', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_AITweaks_Elite_AIFeatures";
            };
            class Elite_RemoveGrenades {
                displayName = "Remove Grenades";
                tooltip = "Remove grenades from inventory.";
                control = "Checkbox";
                property = "Recondo_AITweaks_Elite_RemoveGrenades";
                expression = "_this setVariable ['elite_removegrenades', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_AITweaks_Elite_Equipment";
            };
            class Elite_GrenadesToRemove {
                displayName = "Grenades to Remove";
                tooltip = "Comma-separated list of grenade classnames.";
                control = "Edit";
                property = "Recondo_AITweaks_Elite_GrenadesToRemove";
                expression = "_this setVariable ['elite_grenadestoremove', _value, true];";
                typeName = "STRING";
                defaultValue = """vn_t67_grenade_mag,vn_rdg2_mag,vn_rgd5_grenade_mag,vn_molotov_grenade_mag""";
                category = "Recondo_AITweaks_Elite_Equipment";
            };
            class Elite_EnableFlashlights {
                displayName = "Enable Flashlights";
                tooltip = "Equip flashlights and automatically toggle them on/off based on light level (on at dusk/night, off during day). Enable 'Disable NVG' for AI to use visible light effectively.";
                control = "Checkbox";
                property = "Recondo_AITweaks_Elite_EnableFlashlights";
                expression = "_this setVariable ['elite_enableflashlights', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_AITweaks_Elite_Equipment";
            };
            class Elite_FlashlightClass {
                displayName = "Flashlight Classname";
                tooltip = "Classname of the flashlight attachment. Default: acc_flashlight";
                control = "Edit";
                property = "Recondo_AITweaks_Elite_FlashlightClass";
                expression = "_this setVariable ['elite_flashlightclass', _value, true];";
                typeName = "STRING";
                defaultValue = """acc_flashlight""";
                category = "Recondo_AITweaks_Elite_Equipment";
            };
            
            // AA GUNNERS
            class AAGunnerClassnames {
                displayName = "AA GUNNERS - Classnames";
                tooltip = "Comma-separated list of unit classnames to treat as AA Gunners.";
                control = "Edit";
                property = "Recondo_AITweaks_AAGunnerClassnames";
                expression = "_this setVariable ['aagunnerclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_AITweaks_AA";
            };
            class EnableAASkills {
                displayName = "Enable Skill Modifications";
                tooltip = "Enable skill modifications for AA Gunners.";
                control = "Checkbox";
                property = "Recondo_AITweaks_EnableAASkills";
                expression = "_this setVariable ['enableaaskills', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_AITweaks_AA";
            };
            class AA_AimingAccuracy {
                displayName = "Aiming Accuracy";
                tooltip = "How accurately the AI aims.";
                control = "Slider";
                property = "Recondo_AITweaks_AA_AimingAccuracy";
                expression = "_this setVariable ['aa_aimingaccuracy', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.6";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_AITweaks_AA_Skills";
            };
            class AA_AimingShake {
                displayName = "Aiming Shake";
                tooltip = "How much the AI's aim shakes.";
                control = "Slider";
                property = "Recondo_AITweaks_AA_AimingShake";
                expression = "_this setVariable ['aa_aimingshake', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.1";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_AITweaks_AA_Skills";
            };
            class AA_AimingSpeed {
                displayName = "Aiming Speed";
                tooltip = "How quickly AI acquires targets.";
                control = "Slider";
                property = "Recondo_AITweaks_AA_AimingSpeed";
                expression = "_this setVariable ['aa_aimingspeed', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.6";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_AITweaks_AA_Skills";
            };
            class AA_SpotDistance {
                displayName = "Spot Distance";
                tooltip = "How far AI can detect enemies.";
                control = "Slider";
                property = "Recondo_AITweaks_AA_SpotDistance";
                expression = "_this setVariable ['aa_spotdistance', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.9";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_AITweaks_AA_Skills";
            };
            class AA_SpotTime {
                displayName = "Spot Time";
                tooltip = "How quickly AI spots enemies.";
                control = "Slider";
                property = "Recondo_AITweaks_AA_SpotTime";
                expression = "_this setVariable ['aa_spottime', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.8";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_AITweaks_AA_Skills";
            };
            class AA_Courage {
                displayName = "Courage";
                tooltip = "AI willingness to engage.";
                control = "Slider";
                property = "Recondo_AITweaks_AA_Courage";
                expression = "_this setVariable ['aa_courage', _value, true];";
                typeName = "NUMBER";
                defaultValue = "1.0";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_AITweaks_AA_Skills";
            };
            class AA_Commanding {
                displayName = "Commanding";
                tooltip = "AI leadership ability.";
                control = "Slider";
                property = "Recondo_AITweaks_AA_Commanding";
                expression = "_this setVariable ['aa_commanding', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.7";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_AITweaks_AA_Skills";
            };
            class AA_General {
                displayName = "General";
                tooltip = "Overall AI intelligence.";
                control = "Slider";
                property = "Recondo_AITweaks_AA_General";
                expression = "_this setVariable ['aa_general', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.1";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_AITweaks_AA_Skills";
            };
            class AA_ReloadSpeed {
                displayName = "Reload Speed";
                tooltip = "How fast AI reloads weapons.";
                control = "Slider";
                property = "Recondo_AITweaks_AA_ReloadSpeed";
                expression = "_this setVariable ['aa_reloadspeed', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.3";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_AITweaks_AA_Skills";
            };
            class AA_ForceWalk {
                displayName = "Force Walk";
                tooltip = "Force AI to walk instead of run.";
                control = "Checkbox";
                property = "Recondo_AITweaks_AA_ForceWalk";
                expression = "_this setVariable ['aa_forcewalk', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_AITweaks_AA_Behavior";
            };
            class AA_ForceStand {
                displayName = "Force Stand";
                tooltip = "Force AI to remain standing.";
                control = "Checkbox";
                property = "Recondo_AITweaks_AA_ForceStand";
                expression = "_this setVariable ['aa_forcestand', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_AITweaks_AA_Behavior";
            };
            class AA_AnimSpeedCoef {
                displayName = "Animation Speed";
                tooltip = "Animation speed multiplier.";
                control = "Slider";
                property = "Recondo_AITweaks_AA_AnimSpeedCoef";
                expression = "_this setVariable ['aa_animspeedcoef', _value, true];";
                typeName = "NUMBER";
                defaultValue = "1.0";
                sliderRange[] = {0.5, 2.0};
                sliderStep = 0.1;
                category = "Recondo_AITweaks_AA_Behavior";
            };
            class AA_DisableCover {
                displayName = "Disable Cover Seeking";
                tooltip = "Prevent AI from seeking cover. WARNING: Enabling this may cause AI to spam voicelines.";
                control = "Checkbox";
                property = "Recondo_AITweaks_AA_DisableCover";
                expression = "_this setVariable ['aa_disablecover', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_AITweaks_AA_AIFeatures";
            };
            class AA_DisableMineDetection {
                displayName = "Disable Mine Detection";
                tooltip = "Prevent AI from detecting mines.";
                control = "Checkbox";
                property = "Recondo_AITweaks_AA_DisableMineDetection";
                expression = "_this setVariable ['aa_disableminedetection', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_AITweaks_AA_AIFeatures";
            };
            class AA_DisableNVG {
                displayName = "Disable NVG Usage";
                tooltip = "Prevent AI from using NVGs.";
                control = "Checkbox";
                property = "Recondo_AITweaks_AA_DisableNVG";
                expression = "_this setVariable ['aa_disablenvg', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_AITweaks_AA_AIFeatures";
            };
            class AA_DisableSuppression {
                displayName = "Disable Suppression";
                tooltip = "Prevent AI from being suppressed.";
                control = "Checkbox";
                property = "Recondo_AITweaks_AA_DisableSuppression";
                expression = "_this setVariable ['aa_disablesuppression', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_AITweaks_AA_AIFeatures";
            };
            class AA_DisableAutoCombat {
                displayName = "Disable Auto Combat";
                tooltip = "Prevent AI from auto combat mode.";
                control = "Checkbox";
                property = "Recondo_AITweaks_AA_DisableAutoCombat";
                expression = "_this setVariable ['aa_disableautocombat', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_AITweaks_AA_AIFeatures";
            };
            class AA_RemoveGrenades {
                displayName = "Remove Grenades";
                tooltip = "Remove grenades from inventory.";
                control = "Checkbox";
                property = "Recondo_AITweaks_AA_RemoveGrenades";
                expression = "_this setVariable ['aa_removegrenades', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_AITweaks_AA_Equipment";
            };
            class AA_GrenadesToRemove {
                displayName = "Grenades to Remove";
                tooltip = "Comma-separated list of grenade classnames.";
                control = "Edit";
                property = "Recondo_AITweaks_AA_GrenadesToRemove";
                expression = "_this setVariable ['aa_grenadestoremove', _value, true];";
                typeName = "STRING";
                defaultValue = """vn_t67_grenade_mag,vn_rdg2_mag,vn_rgd5_grenade_mag,vn_molotov_grenade_mag""";
                category = "Recondo_AITweaks_AA_Equipment";
            };
            class AA_EnableFlashlights {
                displayName = "Enable Flashlights";
                tooltip = "Equip flashlights and automatically toggle them on/off based on light level (on at dusk/night, off during day). Enable 'Disable NVG' for AI to use visible light effectively.";
                control = "Checkbox";
                property = "Recondo_AITweaks_AA_EnableFlashlights";
                expression = "_this setVariable ['aa_enableflashlights', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_AITweaks_AA_Equipment";
            };
            class AA_FlashlightClass {
                displayName = "Flashlight Classname";
                tooltip = "Classname of the flashlight attachment. Default: acc_flashlight";
                control = "Edit";
                property = "Recondo_AITweaks_AA_FlashlightClass";
                expression = "_this setVariable ['aa_flashlightclass', _value, true];";
                typeName = "STRING";
                defaultValue = """acc_flashlight""";
                category = "Recondo_AITweaks_AA_Equipment";
            };
            
            // MINE KNOWLEDGE
            class EnableMineKnowledge {
                displayName = "MINE KNOWLEDGE - Enable Anonymity";
                tooltip = "Prevent AI from learning player positions when damaged by player-placed mines.";
                control = "Checkbox";
                property = "Recondo_AITweaks_EnableMineKnowledge";
                expression = "_this setVariable ['enablemineknowledge', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_AITweaks_Mine";
            };
            
            // DEBUG
            class EnableDebug {
                displayName = "DEBUG - Enable Logging";
                tooltip = "Enable detailed logging to RPT file for troubleshooting.";
                control = "Checkbox";
                property = "Recondo_AITweaks_EnableDebug";
                expression = "_this setVariable ['enabledebug', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_AITweaks_Debug";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    //==========================================
    // PLAYER OPTIONS MODULE
    //==========================================
    class Recondo_Module_PlayerOptions: Module_F {
        scope = 2;
        displayName = "Player Options";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_modulePlayerOptions";
        functionPriority = 1;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 1;
        icon = "\recondo_wars\images\icons\Player_Settings.paa";
        
        class ModuleDescription: ModuleDescription {
            description = "Configures player graphics restrictions, traits, forced faces, and ACE rations settings.";
            sync[] = {};
        };
        
        class Attributes: AttributesBase {
            
            // GRAPHICS RESTRICTIONS
            class EnableGammaRestrictions {
                displayName = "GRAPHICS - Enable Gamma Restrictions";
                tooltip = "Enable enforcement of gamma/brightness limits. Players exceeding the limit will see a black screen with warning.";
                control = "Checkbox";
                property = "Recondo_PO_EnableGammaRestrictions";
                expression = "_this setVariable ['enablegammarestrictions', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_PlayerOptions_Graphics";
            };
            class MaxGamma {
                displayName = "Max Gamma Value";
                tooltip = "Maximum allowed gamma/brightness value. Default: 1.05";
                control = "Edit";
                property = "Recondo_PO_MaxGamma";
                expression = "_this setVariable ['maxgamma', _value, true];";
                typeName = "NUMBER";
                defaultValue = "1.05";
                category = "Recondo_PlayerOptions_Graphics";
            };
            class EnableTerrainGrid {
                displayName = "Enable Terrain Grid Enforcement";
                tooltip = "Force a specific terrain grid value for all players.";
                control = "Checkbox";
                property = "Recondo_PO_EnableTerrainGrid";
                expression = "_this setVariable ['enableterraingrid', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_PlayerOptions_Graphics";
            };
            class TerrainGridValue {
                displayName = "Terrain Grid Value";
                tooltip = "Terrain grid value to enforce. Lower = better quality. Values: 3.125, 6.25, 12.5, 25, 50. Default: 3.125";
                control = "Edit";
                property = "Recondo_PO_TerrainGridValue";
                expression = "_this setVariable ['terraingridvalue', _value, true];";
                typeName = "NUMBER";
                defaultValue = "3.125";
                category = "Recondo_PlayerOptions_Graphics";
            };
            
            // VIEW DISTANCE
            class EnableViewDistanceRestrictions {
                displayName = "VIEW DISTANCE - Enable Restrictions";
                tooltip = "Enable view distance restrictions for players.";
                control = "Checkbox";
                property = "Recondo_PO_EnableVDRestrictions";
                expression = "_this setVariable ['enablevdrestrictions', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_PlayerOptions_ViewDistance";
            };
            class MaxViewDistance {
                displayName = "Max View Distance";
                tooltip = "Maximum view distance in meters. Default: 8000";
                control = "Edit";
                property = "Recondo_PO_MaxViewDistance";
                expression = "_this setVariable ['maxviewdistance', _value, true];";
                typeName = "NUMBER";
                defaultValue = "8000";
                category = "Recondo_PlayerOptions_ViewDistance";
            };
            class MaxObjectViewDistance {
                displayName = "Max Object View Distance";
                tooltip = "Maximum object view distance in meters. Default: 8000";
                control = "Edit";
                property = "Recondo_PO_MaxObjectViewDistance";
                expression = "_this setVariable ['maxobjectviewdistance', _value, true];";
                typeName = "NUMBER";
                defaultValue = "8000";
                category = "Recondo_PlayerOptions_ViewDistance";
            };
            class ExemptClassnames {
                displayName = "Exempt Unit Classnames";
                tooltip = "Comma-separated list of unit classnames exempt from view distance restrictions (e.g., vn_b_men_army_13).";
                control = "Edit";
                property = "Recondo_PO_ExemptClassnames";
                expression = "_this setVariable ['exemptclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_PlayerOptions_ViewDistance";
            };
            
            // PLAYER TRAITS
            class EnableTraitAdjustments {
                displayName = "TRAITS - Enable Trait Adjustments";
                tooltip = "Enable adjustments to player camouflage and audible coefficients.";
                control = "Checkbox";
                property = "Recondo_PO_EnableTraits";
                expression = "_this setVariable ['enabletraits', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_PlayerOptions_Traits";
            };
            class CamouflageCoef {
                displayName = "Camouflage Coefficient";
                tooltip = "Player visibility to AI. Lower = harder to spot. 1.0 = normal, 0.5 = half as visible. Default: 0.6";
                control = "Edit";
                property = "Recondo_PO_CamouflageCoef";
                expression = "_this setVariable ['camouflagecoef', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.6";
                category = "Recondo_PlayerOptions_Traits";
            };
            class AudibleCoef {
                displayName = "Audible Coefficient";
                tooltip = "Player sound level to AI. Lower = quieter. 1.0 = normal, 0.5 = half as loud. Default: 0.6";
                control = "Edit";
                property = "Recondo_PO_AudibleCoef";
                expression = "_this setVariable ['audiblecoef', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.6";
                category = "Recondo_PlayerOptions_Traits";
            };
            
            // FORCED FACES
            class EnableForcedFaces {
                displayName = "FACES - Enable Forced Faces";
                tooltip = "Force specific faces on players using specific unit classnames.";
                control = "Checkbox";
                property = "Recondo_PO_EnableForcedFaces";
                expression = "_this setVariable ['enableforcedfaces', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_PlayerOptions_Faces";
            };
            class ForcedFaceUnits {
                displayName = "Unit Classnames";
                tooltip = "Comma-separated list of unit classnames that should have forced faces.";
                control = "Edit";
                property = "Recondo_PO_ForcedFaceUnits";
                expression = "_this setVariable ['forcedfaceunits', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_PlayerOptions_Faces";
            };
            class ForcedFaceList {
                displayName = "Face Classnames";
                tooltip = "Comma-separated list of face classnames to randomly apply.";
                control = "Edit";
                property = "Recondo_PO_ForcedFaceList";
                expression = "_this setVariable ['forcedfacelist', _value, true];";
                typeName = "STRING";
                defaultValue = """vn_b_AsianHead_A3_06_02,vn_b_AsianHead_A3_07_02,vn_b_AsianHead_A3_07_03,vn_b_AsianHead_A3_07_04,vn_b_AsianHead_A3_07_05,vn_b_AsianHead_A3_07_06,vn_b_AsianHead_A3_07_07,vn_b_AsianHead_A3_07_08,vn_b_AsianHead_A3_07_09""";
                category = "Recondo_PlayerOptions_Faces";
            };
            class FaceCheckInterval {
                displayName = "Face Check Interval";
                tooltip = "How often to check and enforce faces (seconds). Default: 300";
                control = "Edit";
                property = "Recondo_PO_FaceCheckInterval";
                expression = "_this setVariable ['facecheckinterval', _value, true];";
                typeName = "NUMBER";
                defaultValue = "300";
                category = "Recondo_PlayerOptions_Faces";
            };
            
            // ACE RATIONS
            class EnableDisableRations {
                displayName = "RATIONS - Disable ACE Rations";
                tooltip = "Disable ACE Field Rations (hunger/thirst) for specified unit classnames.";
                control = "Checkbox";
                property = "Recondo_PO_EnableDisableRations";
                expression = "_this setVariable ['enabledisablerations', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_PlayerOptions_Rations";
            };
            class RationsExemptUnits {
                displayName = "Unit Classnames";
                tooltip = "Comma-separated list of unit classnames to exempt from ACE Rations.";
                control = "Edit";
                property = "Recondo_PO_RationsExemptUnits";
                expression = "_this setVariable ['rationsexemptunits', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_PlayerOptions_Rations";
            };
            
            // PILOT RESTRICTIONS
            class EnablePilotRestrictions {
                displayName = "PILOTS - Enable Pilot Restrictions";
                tooltip = "Restrict pilot seats in specified aircraft to authorized player classnames only.";
                control = "Checkbox";
                property = "Recondo_PO_EnablePilotRestrictions";
                expression = "_this setVariable ['enablepilotrestrictions', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_PlayerOptions_Pilots";
            };
            class RestrictedAircraftClassnames {
                displayName = "Restricted Aircraft Classnames";
                tooltip = "Comma-separated list of aircraft classnames that should have restricted pilot seats.";
                control = "Edit";
                property = "Recondo_PO_RestrictedAircraft";
                expression = "_this setVariable ['restrictedaircraft', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_PlayerOptions_Pilots";
            };
            class AllowedPilotClassnames {
                displayName = "Allowed Pilot Classnames";
                tooltip = "Comma-separated list of player unit classnames allowed to pilot the restricted aircraft.";
                control = "Edit";
                property = "Recondo_PO_AllowedPilots";
                expression = "_this setVariable ['allowedpilots', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_PlayerOptions_Pilots";
            };
            
            // SOUNDS
            class EnableLimitPainSounds {
                displayName = "SOUNDS - Limit Pain Sounds";
                tooltip = "Completely disables player moaning/pain sounds.";
                control = "Checkbox";
                property = "Recondo_PO_EnableLimitPainSounds";
                expression = "_this setVariable ['enablelimitpainsounds', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_PlayerOptions_Sounds";
            };
            
            // BODY BAGS
            class EnableCarryBodybags {
                displayName = "BODYBAGS - Enable Carry/Drag Bodybags";
                tooltip = "Allow players to carry and drag ACE body bags using the ACE dragging system.";
                control = "Checkbox";
                property = "Recondo_PO_EnableCarryBodybags";
                expression = "_this setVariable ['enablecarrybodybags', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_PlayerOptions_Bodybags";
            };
            
            // DEBUG
            class EnableDebugPO {
                displayName = "DEBUG - Enable Logging";
                tooltip = "Enable detailed logging to RPT file for troubleshooting.";
                control = "Checkbox";
                property = "Recondo_PO_EnableDebug";
                expression = "_this setVariable ['enabledebug', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_PlayerOptions_Debug";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    //==========================================
    // ACE ARSENAL AREA MODULE
    //==========================================
    class Recondo_Module_ArsenalArea: Module_F {
        scope = 2;
        displayName = "ACE Arsenal Area";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleArsenalArea";
        functionPriority = 1;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 1;
        icon = "\recondo_wars\images\icons\Arsenal_Area.paa";
        
        class ModuleDescription: ModuleDescription {
            description = "Creates an area where authorized players can access an ACE Arsenal. Items available are determined by a reference ammo box.";
            sync[] = {};
        };
        
        class Attributes: AttributesBase {
            
            // AREA SETTINGS
            class AreaWidth {
                displayName = "AREA - Width (X)";
                tooltip = "Width of the arsenal area in meters (X axis). Default: 50";
                control = "Edit";
                property = "Recondo_ArsenalArea_Width";
                expression = "_this setVariable ['areawidth', _value, true];";
                typeName = "NUMBER";
                defaultValue = "50";
                category = "Recondo_ArsenalArea_Area";
            };
            class AreaLength {
                displayName = "Length (Y)";
                tooltip = "Length of the arsenal area in meters (Y axis). Default: 50";
                control = "Edit";
                property = "Recondo_ArsenalArea_Length";
                expression = "_this setVariable ['arealength', _value, true];";
                typeName = "NUMBER";
                defaultValue = "50";
                category = "Recondo_ArsenalArea_Area";
            };
            class AreaHeight {
                displayName = "Height (Z)";
                tooltip = "Height of the arsenal area in meters. Default: 25";
                control = "Edit";
                property = "Recondo_ArsenalArea_Height";
                expression = "_this setVariable ['areaheight', _value, true];";
                typeName = "NUMBER";
                defaultValue = "25";
                category = "Recondo_ArsenalArea_Area";
            };
            
            // ARSENAL SETTINGS
            class ReferenceBoxVar {
                displayName = "ARSENAL - Reference Box Variable";
                tooltip = "Variable name of the ammo box containing the arsenal items (set in the box's Eden attributes). Example: myArsenalBox";
                control = "Edit";
                property = "Recondo_ArsenalArea_RefBox";
                expression = "_this setVariable ['referenceboxvar', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_ArsenalArea_Arsenal";
            };
            
            // ACCESS SETTINGS
            class AllowedClassnames {
                displayName = "ACCESS - Allowed Player Classnames";
                tooltip = "Comma-separated list of player unit classnames allowed to access this arsenal. Leave empty to allow all players.";
                control = "Edit";
                property = "Recondo_ArsenalArea_Allowed";
                expression = "_this setVariable ['allowedclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_ArsenalArea_Access";
            };
            
            // CLEANUP SETTINGS
            class EnableCleanup {
                displayName = "CLEANUP - Enable Litter Cleanup";
                tooltip = "Automatically clean up dropped items (weapons, gear) in the cleanup area every 5 minutes. Runs server-side.";
                control = "Checkbox";
                property = "Recondo_ArsenalArea_EnableCleanup";
                expression = "_this setVariable ['enablecleanup', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ArsenalArea_Cleanup";
            };
            class CleanupWidth {
                displayName = "Cleanup Width (X)";
                tooltip = "Width of the cleanup area in meters (X axis). Default: 100";
                control = "Edit";
                property = "Recondo_ArsenalArea_CleanupWidth";
                expression = "_this setVariable ['cleanupwidth', _value, true];";
                typeName = "NUMBER";
                defaultValue = "100";
                category = "Recondo_ArsenalArea_Cleanup";
            };
            class CleanupLength {
                displayName = "Cleanup Length (Y)";
                tooltip = "Length of the cleanup area in meters (Y axis). Default: 100";
                control = "Edit";
                property = "Recondo_ArsenalArea_CleanupLength";
                expression = "_this setVariable ['cleanuplength', _value, true];";
                typeName = "NUMBER";
                defaultValue = "100";
                category = "Recondo_ArsenalArea_Cleanup";
            };
            class CleanupHeight {
                displayName = "Cleanup Height (Z)";
                tooltip = "Height of the cleanup area in meters. Default: 25";
                control = "Edit";
                property = "Recondo_ArsenalArea_CleanupHeight";
                expression = "_this setVariable ['cleanupheight', _value, true];";
                typeName = "NUMBER";
                defaultValue = "25";
                category = "Recondo_ArsenalArea_Cleanup";
            };
            
            // DEBUG
            class EnableDebugAA {
                displayName = "DEBUG - Enable Logging";
                tooltip = "Enable detailed logging to RPT file for troubleshooting.";
                control = "Checkbox";
                property = "Recondo_ArsenalArea_Debug";
                expression = "_this setVariable ['enabledebug', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ArsenalArea_Debug";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    //==========================================
    // DISABLE ACE RATIONS AREA MODULE
    //==========================================
    class Recondo_Module_DisableRationsArea: Module_F {
        scope = 2;
        displayName = "Disable ACE Rations Area";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleDisableRationsArea";
        functionPriority = 1;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 1;
        
        class ModuleDescription: ModuleDescription {
            description = "Creates an area where ACE Field Rations (hunger/thirst) are disabled. Players inside this area won't need to eat or drink.";
            sync[] = {};
        };
        
        class Attributes: AttributesBase {
            
            // AREA SETTINGS
            class AreaWidth {
                displayName = "AREA - Width (X)";
                tooltip = "Width of the no-rations area in meters (X axis). Default: 100";
                control = "Edit";
                property = "Recondo_DisableRationsArea_Width";
                expression = "_this setVariable ['areawidth', _value, true];";
                typeName = "NUMBER";
                defaultValue = "100";
                category = "Recondo_DisableRationsArea_Area";
            };
            class AreaLength {
                displayName = "Length (Y)";
                tooltip = "Length of the no-rations area in meters (Y axis). Default: 100";
                control = "Edit";
                property = "Recondo_DisableRationsArea_Length";
                expression = "_this setVariable ['arealength', _value, true];";
                typeName = "NUMBER";
                defaultValue = "100";
                category = "Recondo_DisableRationsArea_Area";
            };
            class AreaHeight {
                displayName = "Height (Z)";
                tooltip = "Height of the no-rations area in meters. Default: 25";
                control = "Edit";
                property = "Recondo_DisableRationsArea_Height";
                expression = "_this setVariable ['areaheight', _value, true];";
                typeName = "NUMBER";
                defaultValue = "25";
                category = "Recondo_DisableRationsArea_Area";
            };
            
            // DEBUG
            class EnableDebugDRA {
                displayName = "DEBUG - Enable Logging";
                tooltip = "Enable detailed logging to RPT file for troubleshooting.";
                control = "Checkbox";
                property = "Recondo_DisableRationsArea_Debug";
                expression = "_this setVariable ['enabledebug', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_DisableRationsArea_Debug";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    //==========================================
    // JIP TO GROUP LEADER AREA MODULE
    //==========================================
    class Recondo_Module_JIPArea: Module_F {
        scope = 2;
        displayName = "JIP to Group Leader Area";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleJIPArea";
        functionPriority = 1;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 1;
        
        class ModuleDescription: ModuleDescription {
            description = "Creates an area where players can teleport to their group leader (or random member if leader). Useful for JIP players at base.";
            sync[] = {};
        };
        
        class Attributes: AttributesBase {
            
            // AREA SETTINGS
            class AreaWidth {
                displayName = "AREA - Width (X)";
                tooltip = "Width of the JIP teleport area in meters (X axis). Default: 100";
                control = "Edit";
                property = "Recondo_JIPArea_Width";
                expression = "_this setVariable ['areawidth', _value, true];";
                typeName = "NUMBER";
                defaultValue = "100";
                category = "Recondo_JIPArea_Area";
            };
            class AreaLength {
                displayName = "Length (Y)";
                tooltip = "Length of the JIP teleport area in meters (Y axis). Default: 100";
                control = "Edit";
                property = "Recondo_JIPArea_Length";
                expression = "_this setVariable ['arealength', _value, true];";
                typeName = "NUMBER";
                defaultValue = "100";
                category = "Recondo_JIPArea_Area";
            };
            class AreaHeight {
                displayName = "Height (Z)";
                tooltip = "Height of the JIP teleport area in meters. Default: 25";
                control = "Edit";
                property = "Recondo_JIPArea_Height";
                expression = "_this setVariable ['areaheight', _value, true];";
                typeName = "NUMBER";
                defaultValue = "25";
                category = "Recondo_JIPArea_Area";
            };
            
            // DEBUG
            class EnableDebugJIP {
                displayName = "DEBUG - Enable Logging";
                tooltip = "Enable detailed logging to RPT file for troubleshooting.";
                control = "Checkbox";
                property = "Recondo_JIPArea_Debug";
                expression = "_this setVariable ['enabledebug', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_JIPArea_Debug";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    //==========================================
    // ACE SPECTATOR OBJECT MODULE
    //==========================================
    class Recondo_Module_SpectatorObject: Module_F {
        scope = 2;
        displayName = "ACE Spectator Object";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleSpectatorObject";
        functionPriority = 1;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 1;
        
        class ModuleDescription: ModuleDescription {
            description = "Adds ACE Spectator access to an object. Configure camera modes, vision modes, and side restrictions.";
            sync[] = {};
        };
        
        class Attributes: AttributesBase {
            
            // OBJECT SETTINGS
            class ObjectVarName {
                displayName = "OBJECT - Variable Name";
                tooltip = "Variable name of the object to add spectator interaction to (set in object's Eden attributes).";
                control = "Edit";
                property = "Recondo_SpectatorObject_VarName";
                expression = "_this setVariable ['objectvarname', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_SpectatorObject_Object";
            };
            class ActionText {
                displayName = "Action Text";
                tooltip = "Text displayed on the ACE interaction. Default: Enter Spectator";
                control = "Edit";
                property = "Recondo_SpectatorObject_ActionText";
                expression = "_this setVariable ['actiontext', _value, true];";
                typeName = "STRING";
                defaultValue = """Enter Spectator""";
                category = "Recondo_SpectatorObject_Object";
            };
            
            // CAMERA MODES
            class AllowFreeCam {
                displayName = "CAMERA - Allow Free Camera";
                tooltip = "Enable free-flying camera mode (can go anywhere, potential for scouting).";
                control = "Checkbox";
                property = "Recondo_SpectatorObject_FreeCam";
                expression = "_this setVariable ['allowfreecam', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_SpectatorObject_Camera";
            };
            class AllowFirstPerson {
                displayName = "Allow First Person";
                tooltip = "Enable first-person view through unit's eyes.";
                control = "Checkbox";
                property = "Recondo_SpectatorObject_FirstPerson";
                expression = "_this setVariable ['allowfirstperson', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_SpectatorObject_Camera";
            };
            class AllowThirdPerson {
                displayName = "Allow Third Person";
                tooltip = "Enable third-person over-the-shoulder view.";
                control = "Checkbox";
                property = "Recondo_SpectatorObject_ThirdPerson";
                expression = "_this setVariable ['allowthirdperson', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_SpectatorObject_Camera";
            };
            
            // VISION MODES
            class AllowNVG {
                displayName = "VISION - Allow NVG Mode";
                tooltip = "Enable night vision mode in spectator.";
                control = "Checkbox";
                property = "Recondo_SpectatorObject_NVG";
                expression = "_this setVariable ['allownvg', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_SpectatorObject_Vision";
            };
            class AllowThermal {
                displayName = "Allow Thermal Modes";
                tooltip = "Enable thermal/infrared vision modes in spectator.";
                control = "Checkbox";
                property = "Recondo_SpectatorObject_Thermal";
                expression = "_this setVariable ['allowthermal', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_SpectatorObject_Vision";
            };
            
            // RESTRICTIONS
            class RestrictToOwnSide {
                displayName = "RESTRICTIONS - Own Side Only";
                tooltip = "Only allow viewing units on the player's own side. Prevents intel gathering on enemies.";
                control = "Checkbox";
                property = "Recondo_SpectatorObject_OwnSide";
                expression = "_this setVariable ['restricttoownside', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_SpectatorObject_Restrictions";
            };
            class PlayersOnly {
                displayName = "Players Only (Hide AI)";
                tooltip = "Only show player-controlled units in spectator. AI units will be hidden.";
                control = "Checkbox";
                property = "Recondo_SpectatorObject_PlayersOnly";
                expression = "_this setVariable ['playersonly', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_SpectatorObject_Restrictions";
            };
            
            // DEBUG
            class EnableDebugSO {
                displayName = "DEBUG - Enable Logging";
                tooltip = "Enable detailed logging to RPT file for troubleshooting.";
                control = "Checkbox";
                property = "Recondo_SpectatorObject_Debug";
                expression = "_this setVariable ['enabledebug', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_SpectatorObject_Debug";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    //==========================================
    // PERSISTENCE MODULE
    //==========================================
    class Recondo_Module_Persistence: Module_F {
        scope = 2;
        displayName = "Persistence System";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_modulePersistence";
        functionPriority = 0;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 0;
        
        class ModuleDescription: ModuleDescription {
            description = "Enables persistent saving and loading of mission data including map markers and player statistics. Data persists across server restarts.";
            sync[] = {};
        };
        
        class Attributes: AttributesBase {
            
            // CAMPAIGN SETTINGS
            class CampaignID {
                displayName = "CAMPAIGN - Campaign ID";
                tooltip = "Unique identifier for this campaign save. Leave empty to auto-generate based on mission name. Use same ID across sessions to continue a campaign.";
                control = "Edit";
                property = "Recondo_Persistence_CampaignID";
                expression = "_this setVariable ['campaignid', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_Persistence_Campaign";
            };
            class LoadOnStart {
                displayName = "Load Save on Mission Start";
                tooltip = "Automatically load saved data when the mission starts. Disable if you want to start fresh.";
                control = "Checkbox";
                property = "Recondo_Persistence_LoadOnStart";
                expression = "_this setVariable ['loadonstart', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_Persistence_Campaign";
            };
            
            // AUTO-SAVE SETTINGS
            class EnableAutoSave {
                displayName = "AUTO-SAVE - Enable Auto-Save";
                tooltip = "Automatically save mission data at regular intervals.";
                control = "Checkbox";
                property = "Recondo_Persistence_EnableAutoSave";
                expression = "_this setVariable ['enableautosave', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_Persistence_AutoSave";
            };
            class AutoSaveInterval {
                displayName = "Auto-Save Interval (minutes)";
                tooltip = "How often to automatically save mission data in minutes. Default: 15 minutes.";
                control = "Edit";
                property = "Recondo_Persistence_AutoSaveInterval";
                expression = "_this setVariable ['autosaveinterval', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """15""";
                category = "Recondo_Persistence_AutoSave";
            };
            class SaveWarningTime {
                displayName = "Save Warning Time (seconds)";
                tooltip = "How many seconds before save to warn players. Set to 0 to disable warning. Default: 10 seconds.";
                control = "Edit";
                property = "Recondo_Persistence_SaveWarningTime";
                expression = "_this setVariable ['savewarningtime', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """10""";
                category = "Recondo_Persistence_AutoSave";
            };
            
            // MARKER SETTINGS
            class SaveMarkers {
                displayName = "MARKERS - Save Map Markers";
                tooltip = "Enable saving of all global map markers created during the mission (player-drawn markers). Eden-placed markers are not saved as they auto-appear on mission start.";
                control = "Checkbox";
                property = "Recondo_Persistence_SaveMarkers";
                expression = "_this setVariable ['savemarkers', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_Persistence_Markers";
            };
            
            // PLAYER STATS SETTINGS
            class SavePlayerStats {
                displayName = "PLAYER STATS - Save Player Statistics";
                tooltip = "Enable tracking and saving of player statistics (kills, deaths, disconnects).";
                control = "Checkbox";
                property = "Recondo_Persistence_SavePlayerStats";
                expression = "_this setVariable ['saveplayerstats', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_Persistence_PlayerStats";
            };
            class TrackAIKills {
                displayName = "Track AI Kills";
                tooltip = "Count AI kills in player statistics.";
                control = "Checkbox";
                property = "Recondo_Persistence_TrackAIKills";
                expression = "_this setVariable ['trackaikills', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_Persistence_PlayerStats";
            };
            class TrackPlayerKills {
                displayName = "Track Player Kills";
                tooltip = "Count player vs player kills in player statistics.";
                control = "Checkbox";
                property = "Recondo_Persistence_TrackPlayerKills";
                expression = "_this setVariable ['trackplayerkills', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_Persistence_PlayerStats";
            };
            
            // DEBUG
            class EnableDebugPersistence {
                displayName = "DEBUG - Enable Logging";
                tooltip = "Enable detailed logging to RPT file for troubleshooting.";
                control = "Checkbox";
                property = "Recondo_Persistence_Debug";
                expression = "_this setVariable ['enabledebug', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_Persistence_Debug";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    //==========================================
    // STATIC DEFENSE RANDOMIZED MODULE
    //==========================================
    class Recondo_Module_StaticDefenseRandomized: Module_F {
        scope = 2;
        displayName = "Static Defense Randomized";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleStaticDefenseRandomized";
        functionPriority = 5;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 0;
        
        class ModuleDescription: ModuleDescription {
            description = "Spawns static weapons with AI gunners at randomized positions based on invisible map markers. Useful for creating varied defensive positions each mission.";
            sync[] = {};
        };
        
        class Attributes: AttributesBase {
            
            // GENERAL SETTINGS
            class TargetSide {
                displayName = "GENERAL - Target Side";
                tooltip = "Which side the spawned AI units should belong to.";
                control = "Combo";
                property = "Recondo_SDR_TargetSide";
                expression = "_this setVariable ['targetside', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0";
                category = "Recondo_SDR_General";
                class Values {
                    class East { name = "OPFOR (East)"; value = 0; };
                    class West { name = "BLUFOR (West)"; value = 1; };
                    class Guer { name = "Independent"; value = 2; };
                    class Civ { name = "Civilian"; value = 3; };
                };
            };
            class MarkerPrefix {
                displayName = "Marker Prefix";
                tooltip = "Prefix for invisible markers to use as spawn points. Example: 'AA_' will find markers AA_1, AA_2, AA_3, etc.";
                control = "Edit";
                property = "Recondo_SDR_MarkerPrefix";
                expression = "_this setVariable ['markerprefix', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_SDR_General";
            };
            class SpawnPercentage {
                displayName = "Spawn Percentage";
                tooltip = "Percentage of found markers that will spawn static defenses. 1.0 = all markers, 0.5 = half randomly selected.";
                control = "Slider";
                property = "Recondo_SDR_SpawnPercentage";
                expression = "_this setVariable ['spawnpercentage', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.5";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_SDR_General";
            };
            
            // STATIC WEAPON SETTINGS
            class StaticClassnames {
                displayName = "STATIC - Weapon Classnames";
                tooltip = "Comma-separated list of static weapon classnames. One will be randomly selected per spawn point.";
                control = "EditMulti3";
                property = "Recondo_SDR_StaticClassnames";
                expression = "_this setVariable ['staticclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_SDR_Static";
            };
            
            // UNIT SETTINGS
            class UnitClassnames {
                displayName = "UNITS - Gunner Classnames";
                tooltip = "Comma-separated list of AI unit classnames to garrison the statics. One will be randomly selected per spawn point.";
                control = "EditMulti3";
                property = "Recondo_SDR_UnitClassnames";
                expression = "_this setVariable ['unitclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_SDR_Units";
            };
            
            // TERRAIN SETTINGS
            class ClearRadius {
                displayName = "TERRAIN - Clear Radius (meters)";
                tooltip = "Radius around spawn point to delete terrain objects (trees, rocks, etc.) before spawning. Set to 0 to disable clearing.";
                control = "Edit";
                property = "Recondo_SDR_ClearRadius";
                expression = "_this setVariable ['clearradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """10""";
                category = "Recondo_SDR_Terrain";
            };
            
            // PERSISTENCE SETTINGS
            class EnablePersistence {
                displayName = "PERSISTENCE - Enable Persistence";
                tooltip = "If enabled, the same markers will spawn statics after server restart. If disabled, markers are re-randomized each mission start.";
                control = "Checkbox";
                property = "Recondo_SDR_EnablePersistence";
                expression = "_this setVariable ['enablepersistence', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_SDR_Persistence";
            };
            
            // DEBUG
            class EnableDebugSDR {
                displayName = "DEBUG - Enable Logging";
                tooltip = "Enable detailed logging to RPT file for troubleshooting.";
                control = "Checkbox";
                property = "Recondo_SDR_Debug";
                expression = "_this setVariable ['enabledebug', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_SDR_Debug";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    //==========================================
    // FOOT PATROLS MODULE
    //==========================================
    class Recondo_Module_FootPatrols: Module_F {
        scope = 2;
        displayName = "Foot Patrols";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleFootPatrols";
        functionPriority = 5;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 0;
        
        class ModuleDescription: ModuleDescription {
            description = "Spawns AI foot patrols when players enter trigger areas. Patrols are created at invisible map markers with configurable group sizes, patrol behavior, and waypoint patterns.";
            sync[] = {};
        };
        
        class Attributes: AttributesBase {
            
            // GENERAL SETTINGS
            class TargetSide {
                displayName = "GENERAL - Target Side";
                tooltip = "Which side the spawned AI units should belong to.";
                control = "Combo";
                property = "Recondo_FP_TargetSide";
                expression = "_this setVariable ['targetside', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0";
                category = "Recondo_FP_General";
                class Values {
                    class East { name = "OPFOR (East)"; value = 0; };
                    class West { name = "BLUFOR (West)"; value = 1; };
                    class Guer { name = "Independent"; value = 2; };
                    class Civ { name = "Civilian"; value = 3; };
                };
            };
            class MarkerPrefix {
                displayName = "Marker Prefix";
                tooltip = "Prefix for invisible markers to use as spawn points. Example: 'PATROL_' will find markers PATROL_1, PATROL_2, etc.";
                control = "Edit";
                property = "Recondo_FP_MarkerPrefix";
                expression = "_this setVariable ['markerprefix', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_FP_General";
            };
            class SpawnPercentage {
                displayName = "Spawn Percentage";
                tooltip = "Percentage of found markers that will have patrol triggers. 1.0 = all markers, 0.5 = half randomly selected.";
                control = "Slider";
                property = "Recondo_FP_SpawnPercentage";
                expression = "_this setVariable ['spawnpercentage', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.5";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_FP_General";
            };
            
            // UNIT SETTINGS
            class UnitClassnames {
                displayName = "UNITS - Classnames";
                tooltip = "Comma-separated list of AI unit classnames. Units will be randomly selected for each patrol.";
                control = "EditMulti3";
                property = "Recondo_FP_UnitClassnames";
                expression = "_this setVariable ['unitclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_FP_Units";
            };
            class MinGroupSize {
                displayName = "Min Group Size";
                tooltip = "Minimum number of units per patrol group.";
                control = "Edit";
                property = "Recondo_FP_MinGroupSize";
                expression = "_this setVariable ['mingroupsize', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """3""";
                category = "Recondo_FP_Units";
            };
            class MaxGroupSize {
                displayName = "Max Group Size";
                tooltip = "Maximum number of units per patrol group. Actual size is randomized between min and max.";
                control = "Edit";
                property = "Recondo_FP_MaxGroupSize";
                expression = "_this setVariable ['maxgroupsize', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """6""";
                category = "Recondo_FP_Units";
            };
            
            // PATROL BEHAVIOR SETTINGS
            class PatrolRadius {
                displayName = "PATROL - Radius (meters)";
                tooltip = "How far the patrol will move from their spawn point.";
                control = "Edit";
                property = "Recondo_FP_PatrolRadius";
                expression = "_this setVariable ['patrolradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """300""";
                category = "Recondo_FP_Patrol";
            };
            class WaypointCount {
                displayName = "Waypoint Count";
                tooltip = "Number of waypoints in the patrol loop. More waypoints = more complex patrol pattern.";
                control = "Edit";
                property = "Recondo_FP_WaypointCount";
                expression = "_this setVariable ['waypointcount', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """4""";
                category = "Recondo_FP_Patrol";
            };
            class WaypointPauseMin {
                displayName = "Waypoint Pause Min (sec)";
                tooltip = "Minimum seconds the patrol pauses at each waypoint.";
                control = "Edit";
                property = "Recondo_FP_WaypointPauseMin";
                expression = "_this setVariable ['waypointpausemin', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """15""";
                category = "Recondo_FP_Patrol";
            };
            class WaypointPauseMax {
                displayName = "Waypoint Pause Max (sec)";
                tooltip = "Maximum seconds the patrol pauses at each waypoint. Actual pause is randomized.";
                control = "Edit";
                property = "Recondo_FP_WaypointPauseMax";
                expression = "_this setVariable ['waypointpausemax', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """45""";
                category = "Recondo_FP_Patrol";
            };
            class PatrolBehaviour {
                displayName = "Behaviour";
                tooltip = "Default behaviour mode for the patrol.";
                control = "Combo";
                property = "Recondo_FP_Behaviour";
                expression = "_this setVariable ['behaviour', _value, true];";
                typeName = "STRING";
                defaultValue = """SAFE""";
                category = "Recondo_FP_Patrol";
                class Values {
                    class Safe { name = "SAFE"; value = "SAFE"; };
                    class Aware { name = "AWARE"; value = "AWARE"; };
                    class Combat { name = "COMBAT"; value = "COMBAT"; };
                    class Stealth { name = "STEALTH"; value = "STEALTH"; };
                };
            };
            class PatrolSpeedMode {
                displayName = "Speed Mode";
                tooltip = "Movement speed for the patrol.";
                control = "Combo";
                property = "Recondo_FP_SpeedMode";
                expression = "_this setVariable ['speedmode', _value, true];";
                typeName = "STRING";
                defaultValue = """LIMITED""";
                category = "Recondo_FP_Patrol";
                class Values {
                    class Limited { name = "LIMITED"; value = "LIMITED"; };
                    class Normal { name = "NORMAL"; value = "NORMAL"; };
                    class Full { name = "FULL"; value = "FULL"; };
                };
            };
            class PatrolCombatMode {
                displayName = "Combat Mode";
                tooltip = "Rules of engagement for the patrol.";
                control = "Combo";
                property = "Recondo_FP_CombatMode";
                expression = "_this setVariable ['combatmode', _value, true];";
                typeName = "STRING";
                defaultValue = """YELLOW""";
                category = "Recondo_FP_Patrol";
                class Values {
                    class Blue { name = "BLUE (Never fire)"; value = "BLUE"; };
                    class Green { name = "GREEN (Hold fire)"; value = "GREEN"; };
                    class White { name = "WHITE (Hold fire, defend)"; value = "WHITE"; };
                    class Yellow { name = "YELLOW (Fire at will)"; value = "YELLOW"; };
                    class Red { name = "RED (Fire at will, engage)"; value = "RED"; };
                };
            };
            class PatrolFormation {
                displayName = "Formation";
                tooltip = "Movement formation for the patrol.";
                control = "Combo";
                property = "Recondo_FP_Formation";
                expression = "_this setVariable ['formation', _value, true];";
                typeName = "STRING";
                defaultValue = """STAG COLUMN""";
                category = "Recondo_FP_Patrol";
                class Values {
                    class Column { name = "COLUMN"; value = "COLUMN"; };
                    class StagColumn { name = "STAG COLUMN"; value = "STAG COLUMN"; };
                    class Wedge { name = "WEDGE"; value = "WEDGE"; };
                    class Echelon_L { name = "ECH LEFT"; value = "ECH LEFT"; };
                    class Echelon_R { name = "ECH RIGHT"; value = "ECH RIGHT"; };
                    class Vee { name = "VEE"; value = "VEE"; };
                    class Line { name = "LINE"; value = "LINE"; };
                    class File { name = "FILE"; value = "FILE"; };
                    class Diamond { name = "DIAMOND"; value = "DIAMOND"; };
                };
            };
            
            // TRIGGER SETTINGS
            class TriggerActivationSide {
                displayName = "TRIGGER - Activation Side";
                tooltip = "Which side will trigger patrol spawns when entering the area.";
                control = "Combo";
                property = "Recondo_FP_TriggerSide";
                expression = "_this setVariable ['triggerside', _value, true];";
                typeName = "STRING";
                defaultValue = """WEST""";
                category = "Recondo_FP_Trigger";
                class Values {
                    class West { name = "BLUFOR (West)"; value = "WEST"; };
                    class East { name = "OPFOR (East)"; value = "EAST"; };
                    class Guer { name = "Independent"; value = "GUER"; };
                    class Civ { name = "Civilian"; value = "CIV"; };
                    class Any { name = "Any Player"; value = "ANY"; };
                };
            };
            class TriggerRadius {
                displayName = "Trigger Radius (meters)";
                tooltip = "Detection radius of the spawn trigger.";
                control = "Edit";
                property = "Recondo_FP_TriggerRadius";
                expression = "_this setVariable ['triggerradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """500""";
                category = "Recondo_FP_Trigger";
            };
            class TriggerHeight {
                displayName = "Trigger Height (meters)";
                tooltip = "Vertical detection range of the trigger. Useful for detecting aircraft.";
                control = "Edit";
                property = "Recondo_FP_TriggerHeight";
                expression = "_this setVariable ['triggerheight', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """20""";
                category = "Recondo_FP_Trigger";
            };
            
            // PERFORMANCE SETTINGS
            class SimulationDistance {
                displayName = "PERFORMANCE - Simulation Distance";
                tooltip = "Distance at which simulation is enabled for spawned units. Units start with simulation disabled and are enabled when players approach. Set to 0 to disable this feature (units always simulated).";
                control = "Edit";
                property = "Recondo_FP_SimulationDistance";
                expression = "_this setVariable ['simulationdistance', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """1000""";
                category = "Recondo_FP_Performance";
            };
            class LambsReinforce {
                displayName = "LAMBS - Group Reinforce";
                tooltip = "Enable LAMBS Danger FSM group reinforcement behavior (requires LAMBS Danger mod).";
                control = "Checkbox";
                property = "Recondo_FP_LambsReinforce";
                expression = "_this setVariable ['lambsreinforce', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_FP_Performance";
            };
            
            // PERSISTENCE SETTINGS
            class EnablePersistence {
                displayName = "PERSISTENCE - Enable Persistence";
                tooltip = "If enabled, the same markers will have triggers after server restart. If disabled, markers are re-randomized each mission start.";
                control = "Checkbox";
                property = "Recondo_FP_EnablePersistence";
                expression = "_this setVariable ['enablepersistence', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_FP_Persistence";
            };
            
            // DEBUG
            class EnableDebugFP {
                displayName = "DEBUG - Enable Logging";
                tooltip = "Enable detailed logging to RPT file for troubleshooting.";
                control = "Checkbox";
                property = "Recondo_FP_Debug";
                expression = "_this setVariable ['enabledebug', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_FP_Debug";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    //==========================================
    // ADD AI CREW MODULE
    //==========================================
    class Recondo_Module_AddAICrew: Module_F {
        scope = 2;
        displayName = "Add AI Crew";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleAddAICrew";
        functionPriority = 5;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 1;
        icon = "\recondo_wars\images\icons\Add_AI_Crew.paa";
        
        class ModuleDescription: ModuleDescription {
            description = "Adds ACE self-interaction options to request/remove AI crew for synced vehicles. Sync this module to vehicles that should have crew management capability.";
            sync[] = {"AnyVehicle"};
        };
        
        class Attributes: AttributesBase {
            
            // GENERAL SETTINGS
            class CrewSide {
                displayName = "GENERAL - Crew Side";
                tooltip = "Which side the AI crew should belong to. 'Same as Driver' will match the player's side.";
                control = "Combo";
                property = "Recondo_AIC_CrewSide";
                expression = "_this setVariable ['crewside', _value, true];";
                typeName = "NUMBER";
                defaultValue = "-1";
                category = "Recondo_AIC_General";
                class Values {
                    class SameAsDriver { name = "Same as Driver"; value = -1; };
                    class East { name = "OPFOR (East)"; value = 0; };
                    class West { name = "BLUFOR (West)"; value = 1; };
                    class Guer { name = "Independent"; value = 2; };
                    class Civ { name = "Civilian"; value = 3; };
                };
            };
            
            // UNIT SETTINGS
            class GunnerClassnames {
                displayName = "UNITS - Gunner Classnames";
                tooltip = "Comma-separated list of AI unit classnames for turret positions. One will be randomly selected per turret. Leave empty to use a default unit.";
                control = "EditMulti3";
                property = "Recondo_AIC_GunnerClassnames";
                expression = "_this setVariable ['gunnerclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_AIC_Units";
            };
            class MaxCrewCount {
                displayName = "Max Crew Count";
                tooltip = "Maximum number of AI crew to add. Set to 0 to fill all available turret positions. Turrets are filled in order returned by allTurrets (typically main gunner first).";
                control = "Edit";
                property = "Recondo_AIC_MaxCrewCount";
                expression = "_this setVariable ['maxcrewcount', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """0""";
                category = "Recondo_AIC_Units";
            };
            
            // SKILL SETTINGS
            class SkillAimingAccuracy {
                displayName = "SKILLS - Aiming Accuracy";
                tooltip = "How accurately the AI crew aims. 0 = very inaccurate, 1 = perfect aim.";
                control = "Slider";
                property = "Recondo_AIC_AimingAccuracy";
                expression = "_this setVariable ['skill_aimingaccuracy', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.5";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_AIC_Skills";
            };
            class SkillAimingShake {
                displayName = "Aiming Shake";
                tooltip = "How much the AI's aim shakes. 0 = lots of shake, 1 = steady aim.";
                control = "Slider";
                property = "Recondo_AIC_AimingShake";
                expression = "_this setVariable ['skill_aimingshake', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.3";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_AIC_Skills";
            };
            class SkillAimingSpeed {
                displayName = "Aiming Speed";
                tooltip = "How quickly AI acquires targets. 0 = slow, 1 = instant.";
                control = "Slider";
                property = "Recondo_AIC_AimingSpeed";
                expression = "_this setVariable ['skill_aimingspeed', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.5";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_AIC_Skills";
            };
            class SkillSpotDistance {
                displayName = "Spot Distance";
                tooltip = "How far AI can detect enemies. 0 = short range, 1 = maximum range.";
                control = "Slider";
                property = "Recondo_AIC_SpotDistance";
                expression = "_this setVariable ['skill_spotdistance', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.6";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_AIC_Skills";
            };
            class SkillSpotTime {
                displayName = "Spot Time";
                tooltip = "How quickly AI spots enemies. 0 = slow, 1 = instant detection.";
                control = "Slider";
                property = "Recondo_AIC_SpotTime";
                expression = "_this setVariable ['skill_spottime', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.5";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_AIC_Skills";
            };
            class SkillCourage {
                displayName = "Courage";
                tooltip = "AI willingness to engage. 0 = cowardly, 1 = fearless.";
                control = "Slider";
                property = "Recondo_AIC_Courage";
                expression = "_this setVariable ['skill_courage', _value, true];";
                typeName = "NUMBER";
                defaultValue = "1.0";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_AIC_Skills";
            };
            
            // BEHAVIOR SETTINGS
            class DeletionDistance {
                displayName = "BEHAVIOR - Deletion Distance (meters)";
                tooltip = "If AI crew moves more than this distance from the vehicle, they are deleted. Set to 0 to disable.";
                control = "Edit";
                property = "Recondo_AIC_DeletionDistance";
                expression = "_this setVariable ['deletiondistance', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """30""";
                category = "Recondo_AIC_Behavior";
            };
            class MonitorInterval {
                displayName = "Monitor Interval (seconds)";
                tooltip = "How often to check crew distance and status.";
                control = "Edit";
                property = "Recondo_AIC_MonitorInterval";
                expression = "_this setVariable ['monitorinterval', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """5""";
                category = "Recondo_AIC_Behavior";
            };
            class LockPositions {
                displayName = "Lock Crew Positions";
                tooltip = "Lock turret and cargo positions to prevent players from taking AI seats.";
                control = "Checkbox";
                property = "Recondo_AIC_LockPositions";
                expression = "_this setVariable ['lockpositions', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_AIC_Behavior";
            };
            
            // CONDITIONS SETTINGS
            class RequireLanded {
                displayName = "CONDITIONS - Require Landed";
                tooltip = "Vehicle must be on the ground to request/remove crew.";
                control = "Checkbox";
                property = "Recondo_AIC_RequireLanded";
                expression = "_this setVariable ['requirelanded', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_AIC_Conditions";
            };
            class RequireEngineOff {
                displayName = "Require Engine Off";
                tooltip = "Vehicle engine must be off to request/remove crew.";
                control = "Checkbox";
                property = "Recondo_AIC_RequireEngineOff";
                expression = "_this setVariable ['requireengineoff', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_AIC_Conditions";
            };
            
            // DEBUG
            class EnableDebugAIC {
                displayName = "DEBUG - Enable Logging";
                tooltip = "Enable detailed logging to RPT file for troubleshooting.";
                control = "Checkbox";
                property = "Recondo_AIC_Debug";
                expression = "_this setVariable ['enabledebug', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_AIC_Debug";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    //==========================================
    // STABO MODULE
    //==========================================
    class Recondo_Module_STABO: Module_F {
        scope = 2;
        displayName = "STABO Extraction";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleSTABO";
        functionPriority = 5;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 1;
        
        class ModuleDescription: ModuleDescription {
            description = "Adds STABO extraction capability to synced helicopters. Crew can deploy a rope for ground personnel to attach and be extracted. Supports extracting players, unconscious units, and bodybags.";
            sync[] = {"AnyVehicle"};
        };
        
        class Attributes: AttributesBase {
            
            // ROPE SETTINGS
            class AnchorClassname {
                displayName = "ROPE - Anchor Classname";
                tooltip = "The object classname used as the visible rope anchor on the ground. Should be a small, unobtrusive object.";
                control = "Edit";
                property = "Recondo_STABO_AnchorClassname";
                expression = "_this setVariable ['anchorclassname', _value, true];";
                typeName = "STRING";
                defaultValue = """vn_b_vest_anzac_03""";
                category = "Recondo_STABO_Rope";
            };
            class RopeLength {
                displayName = "Rope Length (meters)";
                tooltip = "Length of the STABO rope in meters. Should be long enough to reach the ground from typical hover height.";
                control = "Edit";
                property = "Recondo_STABO_RopeLength";
                expression = "_this setVariable ['ropelength', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """40""";
                category = "Recondo_STABO_Rope";
            };
            class BreakDistance {
                displayName = "Break Distance (meters)";
                tooltip = "If the helicopter moves this far from the anchor, the STABO will automatically raise. Prevents rope from stretching unrealistically.";
                control = "Edit";
                property = "Recondo_STABO_BreakDistance";
                expression = "_this setVariable ['breakdistance', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """60""";
                category = "Recondo_STABO_Rope";
            };
            
            // HEIGHT SETTINGS
            class MinHeight {
                displayName = "HEIGHT - Minimum Altitude (meters)";
                tooltip = "Minimum altitude above ground to deploy STABO. Prevents deployment too close to the ground.";
                control = "Edit";
                property = "Recondo_STABO_MinHeight";
                expression = "_this setVariable ['minheight', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """3""";
                category = "Recondo_STABO_Height";
            };
            class MaxHeight {
                displayName = "Maximum Altitude (meters)";
                tooltip = "Maximum altitude above ground to deploy STABO. Prevents deployment at unsafe heights.";
                control = "Edit";
                property = "Recondo_STABO_MaxHeight";
                expression = "_this setVariable ['maxheight', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """35""";
                category = "Recondo_STABO_Height";
            };
            
            // INTERACTION SETTINGS
            class SearchRadius {
                displayName = "INTERACTION - Search Radius (meters)";
                tooltip = "Radius to search for STABO helicopters when attaching unconscious units or bodybags.";
                control = "Edit";
                property = "Recondo_STABO_SearchRadius";
                expression = "_this setVariable ['searchradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """50""";
                category = "Recondo_STABO_Interaction";
            };
            class AttachDistance {
                displayName = "Attach Distance (meters)";
                tooltip = "Maximum distance from the rope anchor to attach to STABO.";
                control = "Edit";
                property = "Recondo_STABO_AttachDistance";
                expression = "_this setVariable ['attachdistance', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """6""";
                category = "Recondo_STABO_Interaction";
            };
            class MaxAttachments {
                displayName = "Max Attachments";
                tooltip = "Maximum number of players/units that can attach to the STABO rope at once.";
                control = "Edit";
                property = "Recondo_STABO_MaxAttachments";
                expression = "_this setVariable ['maxattachments', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """8""";
                category = "Recondo_STABO_Interaction";
            };
            class DetachDistance {
                displayName = "Detach Distance (meters)";
                tooltip = "If an attached player moves this far from the anchor, they will be automatically detached.";
                control = "Edit";
                property = "Recondo_STABO_DetachDistance";
                expression = "_this setVariable ['detachdistance', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """5""";
                category = "Recondo_STABO_Interaction";
            };
            
            // GROUND REQUEST SETTINGS (for AI pilots)
            class GroundRequestRadius {
                displayName = "GROUND REQUEST - Horizontal Radius (meters)";
                tooltip = "Maximum horizontal distance a ground player can be from helicopter to request STABO drop. Only works with AI pilots.";
                control = "Edit";
                property = "Recondo_STABO_GroundRequestRadius";
                expression = "_this setVariable ['groundrequestradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """50""";
                category = "Recondo_STABO_GroundRequest";
            };
            class GroundRequestMinHeight {
                displayName = "Minimum Helicopter Altitude (meters)";
                tooltip = "Helicopter must be at least this high above the player to allow ground STABO request.";
                control = "Edit";
                property = "Recondo_STABO_GroundRequestMinHeight";
                expression = "_this setVariable ['groundrequestminheight', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """5""";
                category = "Recondo_STABO_GroundRequest";
            };
            class GroundRequestMaxHeight {
                displayName = "Maximum Helicopter Altitude (meters)";
                tooltip = "Helicopter must be no higher than this above the player to allow ground STABO request.";
                control = "Edit";
                property = "Recondo_STABO_GroundRequestMaxHeight";
                expression = "_this setVariable ['groundrequestmaxheight', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """50""";
                category = "Recondo_STABO_GroundRequest";
            };
            
            // DEBUG
            class EnableDebugSTABO {
                displayName = "DEBUG - Enable Logging";
                tooltip = "Enable detailed logging to RPT file for troubleshooting.";
                control = "Checkbox";
                property = "Recondo_STABO_Debug";
                expression = "_this setVariable ['enabledebug', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_STABO_Debug";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    //==========================================
    // PATH PATROLS MODULE
    //==========================================
    class Recondo_Module_PathPatrols: Module_F {
        scope = 2;
        displayName = "Path Patrols";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_modulePathPatrols";
        functionPriority = 5;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 0;
        
        class ModuleDescription: ModuleDescription {
            description = "Spawns AI patrols that move along predefined marker paths. Patrols ping-pong between endpoints, reversing direction when reaching the end of the path.";
            sync[] = {};
        };
        
        class Attributes: AttributesBase {
            
            // GENERAL SETTINGS
            class AISide {
                displayName = "GENERAL - AI Side";
                tooltip = "Which side the spawned AI units should belong to.";
                control = "Combo";
                property = "Recondo_PP_AISide";
                expression = "_this setVariable ['aiside', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0";
                category = "Recondo_PP_General";
                class Values {
                    class East { name = "OPFOR (East)"; value = 0; };
                    class West { name = "BLUFOR (West)"; value = 1; };
                    class Guer { name = "Independent"; value = 2; };
                    class Civ { name = "Civilian"; value = 3; };
                };
            };
            class MarkerPrefix {
                displayName = "Path Marker Prefix";
                tooltip = "Prefix for path markers. Example: 'PATROLa_' will find markers PATROLa_1, PATROLa_2, PATROLa_3, etc. The patrol will move along these markers in sequence.";
                control = "Edit";
                property = "Recondo_PP_MarkerPrefix";
                expression = "_this setVariable ['markerprefix', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_PP_General";
            };
            class NumberOfGroups {
                displayName = "Number of Patrol Groups";
                tooltip = "How many patrol groups to spawn on this path.";
                control = "Edit";
                property = "Recondo_PP_NumberOfGroups";
                expression = "_this setVariable ['numberofgroups', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """1""";
                category = "Recondo_PP_General";
            };
            class SpawnPercentage {
                displayName = "Spawn Percentage";
                tooltip = "Percentage chance for each group to spawn. 1.0 = all groups spawn, 0.5 = 50% chance per group.";
                control = "Slider";
                property = "Recondo_PP_SpawnPercentage";
                expression = "_this setVariable ['spawnpercentage', _value, true];";
                typeName = "NUMBER";
                defaultValue = "1";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_PP_General";
            };
            
            // UNIT SETTINGS
            class UnitClassnames {
                displayName = "UNITS - Classnames";
                tooltip = "Comma-separated list of AI unit classnames. Units will be randomly selected for each patrol.";
                control = "EditMulti3";
                property = "Recondo_PP_UnitClassnames";
                expression = "_this setVariable ['unitclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_PP_Units";
            };
            class MinGroupSize {
                displayName = "Min Group Size";
                tooltip = "Minimum number of units per patrol group.";
                control = "Edit";
                property = "Recondo_PP_MinGroupSize";
                expression = "_this setVariable ['mingroupsize', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """3""";
                category = "Recondo_PP_Units";
            };
            class MaxGroupSize {
                displayName = "Max Group Size";
                tooltip = "Maximum number of units per patrol group. Actual size is randomized between min and max.";
                control = "Edit";
                property = "Recondo_PP_MaxGroupSize";
                expression = "_this setVariable ['maxgroupsize', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """6""";
                category = "Recondo_PP_Units";
            };
            
            // TRIGGER SETTINGS
            class TriggerActivationSide {
                displayName = "TRIGGER - Activation Side";
                tooltip = "Which side will trigger patrol spawns when entering the area.";
                control = "Combo";
                property = "Recondo_PP_TriggerSide";
                expression = "_this setVariable ['triggerside', _value, true];";
                typeName = "STRING";
                defaultValue = """WEST""";
                category = "Recondo_PP_Trigger";
                class Values {
                    class West { name = "BLUFOR (West)"; value = "WEST"; };
                    class East { name = "OPFOR (East)"; value = "EAST"; };
                    class Guer { name = "Independent"; value = "GUER"; };
                    class Civ { name = "Civilian"; value = "CIV"; };
                    class Any { name = "Any Player"; value = "ANY"; };
                };
            };
            class TriggerRadius {
                displayName = "Trigger Radius (meters)";
                tooltip = "Detection radius of the spawn trigger. Trigger is placed at the center of all path markers.";
                control = "Edit";
                property = "Recondo_PP_TriggerRadius";
                expression = "_this setVariable ['triggerradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """500""";
                category = "Recondo_PP_Trigger";
            };
            class TriggerHeight {
                displayName = "Trigger Height (meters)";
                tooltip = "Vertical detection range of the trigger. Useful for detecting aircraft.";
                control = "Edit";
                property = "Recondo_PP_TriggerHeight";
                expression = "_this setVariable ['triggerheight', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """20""";
                category = "Recondo_PP_Trigger";
            };
            
            // PERFORMANCE SETTINGS
            class SimulationDistance {
                displayName = "PERFORMANCE - Simulation Distance";
                tooltip = "Distance at which simulation is enabled for spawned units. Units start with simulation disabled and are enabled when players approach. Set to 0 to disable this feature (units always simulated).";
                control = "Edit";
                property = "Recondo_PP_SimulationDistance";
                expression = "_this setVariable ['simulationdistance', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """1000""";
                category = "Recondo_PP_Performance";
            };
            class LambsReinforce {
                displayName = "LAMBS - Group Reinforce";
                tooltip = "Enable LAMBS Danger FSM group reinforcement behavior (requires LAMBS Danger mod).";
                control = "Checkbox";
                property = "Recondo_PP_LambsReinforce";
                expression = "_this setVariable ['lambsreinforce', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_PP_Performance";
            };
            
            // DEBUG
            class EnableDebugPP {
                displayName = "DEBUG - Enable Logging";
                tooltip = "Enable detailed logging to RPT file for troubleshooting.";
                control = "Checkbox";
                property = "Recondo_PP_Debug";
                expression = "_this setVariable ['enabledebug', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_PP_Debug";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    //==========================================
    // RW_RADIO MODULE
    //==========================================
    class Recondo_Module_RWRadio: Module_F {
        scope = 2;
        displayName = "RW Radio";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleRWRadio";
        functionPriority = 5;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 0;
        
        class ModuleDescription: ModuleDescription {
            description = "Adds battery management and radio triangulation to ACRE radios. Long transmissions can reveal your position to enemies via map markers.";
            sync[] = {};
        };
        
        class Attributes: AttributesBase {
            
            // GENERAL SETTINGS
            class EnableBattery {
                displayName = "GENERAL - Enable Battery System";
                tooltip = "Enable battery drain for configured radios.";
                control = "Checkbox";
                property = "Recondo_RWR_EnableBattery";
                expression = "_this setVariable ['enablebattery', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_RWR_General";
            };
            class EnableTriangulation {
                displayName = "Enable Triangulation";
                tooltip = "Enable triangulation markers that reveal radio users on the map.";
                control = "Checkbox";
                property = "Recondo_RWR_EnableTriangulation";
                expression = "_this setVariable ['enabletriangulation', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_RWR_General";
            };
            class EnableEnemySpawn {
                displayName = "Enable Enemy Spawn";
                tooltip = "Enable enemy group spawning after excessive radio use.";
                control = "Checkbox";
                property = "Recondo_RWR_EnableEnemySpawn";
                expression = "_this setVariable ['enableenemyspawn', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_RWR_General";
            };
            class EnablePersistence {
                displayName = "Enable Persistence";
                tooltip = "Save battery levels and transmission times across server restarts.";
                control = "Checkbox";
                property = "Recondo_RWR_EnablePersistence";
                expression = "_this setVariable ['enablepersistence', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_RWR_General";
            };
            
            // BATTERY SETTINGS
            class RadioClassnames {
                displayName = "BATTERY - Radio Classnames";
                tooltip = "Comma-separated ACRE radio base classnames affected by battery system. Example: ACRE_PRC77, ACRE_PRC152";
                control = "EditMulti3";
                property = "Recondo_RWR_RadioClassnames";
                expression = "_this setVariable ['radioclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """ACRE_PRC77""";
                category = "Recondo_RWR_Battery";
            };
            class BatteryCapacity {
                displayName = "Battery Capacity (seconds)";
                tooltip = "Seconds of talk time per full battery.";
                control = "Edit";
                property = "Recondo_RWR_BatteryCapacity";
                expression = "_this setVariable ['batterycapacity', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """360""";
                category = "Recondo_RWR_Battery";
            };
            class DrainRateMultiplier {
                displayName = "Drain Rate Multiplier";
                tooltip = "Battery drain speed. 1.0 = real-time, 2.0 = drains twice as fast, 0.5 = half speed.";
                control = "Slider";
                property = "Recondo_RWR_DrainRate";
                expression = "_this setVariable ['drainrate', _value, true];";
                typeName = "NUMBER";
                defaultValue = "1";
                sliderRange[] = {0.1, 5};
                sliderStep = 0.1;
                category = "Recondo_RWR_Battery";
            };
            class BatteryItemClassnames {
                displayName = "Battery Item Classnames";
                tooltip = "Comma-separated inventory item classnames that can recharge batteries.";
                control = "EditMulti3";
                property = "Recondo_RWR_BatteryItems";
                expression = "_this setVariable ['batteryitems', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_RWR_Battery";
            };
            class LowBatteryWarning {
                displayName = "Low Battery Warning (%)";
                tooltip = "Battery percentage at which to show warning.";
                control = "Edit";
                property = "Recondo_RWR_LowBatteryWarning";
                expression = "_this setVariable ['lowbatterywarning', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """20""";
                category = "Recondo_RWR_Battery";
            };
            
            // TRIANGULATION SETTINGS
            class TriangThreshold1 {
                displayName = "TRIANGULATION - Time Threshold 1 (sec)";
                tooltip = "Cumulative transmission seconds before first triangulation marker appears.";
                control = "Edit";
                property = "Recondo_RWR_TriangThreshold1";
                expression = "_this setVariable ['triangthreshold1', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """35""";
                category = "Recondo_RWR_Triangulation";
            };
            class TriangRadius1 {
                displayName = "Radius 1 (meters)";
                tooltip = "Marker radius at first threshold.";
                control = "Edit";
                property = "Recondo_RWR_TriangRadius1";
                expression = "_this setVariable ['triangradius1', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """400""";
                category = "Recondo_RWR_Triangulation";
            };
            class TriangThreshold2 {
                displayName = "Time Threshold 2 (sec)";
                tooltip = "Cumulative transmission seconds for second accuracy level.";
                control = "Edit";
                property = "Recondo_RWR_TriangThreshold2";
                expression = "_this setVariable ['triangthreshold2', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """70""";
                category = "Recondo_RWR_Triangulation";
            };
            class TriangRadius2 {
                displayName = "Radius 2 (meters)";
                tooltip = "Marker radius at second threshold.";
                control = "Edit";
                property = "Recondo_RWR_TriangRadius2";
                expression = "_this setVariable ['triangradius2', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """250""";
                category = "Recondo_RWR_Triangulation";
            };
            class TriangThreshold3 {
                displayName = "Time Threshold 3 (sec)";
                tooltip = "Cumulative transmission seconds for third accuracy level.";
                control = "Edit";
                property = "Recondo_RWR_TriangThreshold3";
                expression = "_this setVariable ['triangthreshold3', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """105""";
                category = "Recondo_RWR_Triangulation";
            };
            class TriangRadius3 {
                displayName = "Radius 3 (meters)";
                tooltip = "Marker radius at third threshold.";
                control = "Edit";
                property = "Recondo_RWR_TriangRadius3";
                expression = "_this setVariable ['triangradius3', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """150""";
                category = "Recondo_RWR_Triangulation";
            };
            class TriangThreshold4 {
                displayName = "Time Threshold 4 (sec)";
                tooltip = "Cumulative transmission seconds for maximum accuracy.";
                control = "Edit";
                property = "Recondo_RWR_TriangThreshold4";
                expression = "_this setVariable ['triangthreshold4', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """140""";
                category = "Recondo_RWR_Triangulation";
            };
            class TriangRadius4 {
                displayName = "Radius 4 (meters)";
                tooltip = "Minimum marker radius (maximum accuracy).";
                control = "Edit";
                property = "Recondo_RWR_TriangRadius4";
                expression = "_this setVariable ['triangradius4', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """125""";
                category = "Recondo_RWR_Triangulation";
            };
            class MarkerDuration {
                displayName = "Marker Duration (sec)";
                tooltip = "Seconds before triangulation marker auto-deletes.";
                control = "Edit";
                property = "Recondo_RWR_MarkerDuration";
                expression = "_this setVariable ['markerduration', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """600""";
                category = "Recondo_RWR_Triangulation";
            };
            class MarkerColor {
                displayName = "Marker Color";
                tooltip = "Color of triangulation markers on map.";
                control = "Combo";
                property = "Recondo_RWR_MarkerColor";
                expression = "_this setVariable ['markercolor', _value, true];";
                typeName = "STRING";
                defaultValue = """ColorRed""";
                category = "Recondo_RWR_Triangulation";
                class Values {
                    class Red { name = "Red"; value = "ColorRed"; };
                    class Orange { name = "Orange"; value = "ColorOrange"; };
                    class Yellow { name = "Yellow"; value = "ColorYellow"; };
                    class Blue { name = "Blue"; value = "ColorBlue"; };
                    class Green { name = "Green"; value = "ColorGreen"; };
                    class Grey { name = "Grey"; value = "ColorGrey"; };
                    class Black { name = "Black"; value = "ColorBlack"; };
                };
            };
            
            // ENEMY SPAWN SETTINGS
            class SpawnThreshold {
                displayName = "ENEMY - Spawn Threshold (calls)";
                tooltip = "Number of radio transmissions before enemy group spawns.";
                control = "Edit";
                property = "Recondo_RWR_SpawnThreshold";
                expression = "_this setVariable ['spawnthreshold', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """15""";
                category = "Recondo_RWR_EnemySpawn";
            };
            class EnemyClassnames {
                displayName = "Enemy Unit Classnames";
                tooltip = "Comma-separated enemy unit classnames to spawn.";
                control = "EditMulti3";
                property = "Recondo_RWR_EnemyClassnames";
                expression = "_this setVariable ['enemyclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_RWR_EnemySpawn";
            };
            class EnemySide {
                displayName = "Enemy Side";
                tooltip = "Side of spawned enemy units.";
                control = "Combo";
                property = "Recondo_RWR_EnemySide";
                expression = "_this setVariable ['enemyside', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0";
                category = "Recondo_RWR_EnemySpawn";
                class Values {
                    class East { name = "OPFOR (East)"; value = 0; };
                    class West { name = "BLUFOR (West)"; value = 1; };
                    class Guer { name = "Independent"; value = 2; };
                };
            };
            class EnemyMinSize {
                displayName = "Min Group Size";
                tooltip = "Minimum enemies per spawn.";
                control = "Edit";
                property = "Recondo_RWR_EnemyMinSize";
                expression = "_this setVariable ['enemyminsize', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """4""";
                category = "Recondo_RWR_EnemySpawn";
            };
            class EnemyMaxSize {
                displayName = "Max Group Size";
                tooltip = "Maximum enemies per spawn.";
                control = "Edit";
                property = "Recondo_RWR_EnemyMaxSize";
                expression = "_this setVariable ['enemymaxsize', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """8""";
                category = "Recondo_RWR_EnemySpawn";
            };
            class SpawnDistance {
                displayName = "Spawn Distance (meters)";
                tooltip = "Distance from player where enemies spawn.";
                control = "Edit";
                property = "Recondo_RWR_SpawnDistance";
                expression = "_this setVariable ['spawndistance', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """250""";
                category = "Recondo_RWR_EnemySpawn";
            };
            
            // EXEMPTIONS
            class ExemptGroupPrefixes {
                displayName = "EXEMPTIONS - Exempt Group Prefixes";
                tooltip = "Comma-separated group name prefixes exempt from system. Example: FLIGHT, SUPPORT";
                control = "EditMulti3";
                property = "Recondo_RWR_ExemptGroups";
                expression = "_this setVariable ['exemptgroups', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_RWR_Exemptions";
            };
            class NoCountMarkerPrefix {
                displayName = "No-Count Marker Prefix";
                tooltip = "Markers with this prefix define safe zones where radio use won't count.";
                control = "Edit";
                property = "Recondo_RWR_NoCountPrefix";
                expression = "_this setVariable ['nocountprefix', _value, true];";
                typeName = "STRING";
                defaultValue = """NO_RADIO_""";
                category = "Recondo_RWR_Exemptions";
            };
            class NoCountRadius {
                displayName = "No-Count Zone Radius (meters)";
                tooltip = "Radius around no-count markers where radio use is safe.";
                control = "Edit";
                property = "Recondo_RWR_NoCountRadius";
                expression = "_this setVariable ['nocountradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """500""";
                category = "Recondo_RWR_Exemptions";
            };
            
            // DEBUG
            class EnableDebugRWR {
                displayName = "DEBUG - Enable Logging";
                tooltip = "Enable detailed logging to RPT file for troubleshooting.";
                control = "Checkbox";
                property = "Recondo_RWR_Debug";
                expression = "_this setVariable ['enabledebug', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_RWR_Debug";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    //==========================================
    // STABO HELPER OBJECTS
    //==========================================
    
    // Base classes for inheritance
    class AllVehicles;
    class Air: AllVehicles {};
    class Helicopter: Air {};
    class Helicopter_Base_F: Helicopter {};
    class ThingX;
    
    // Helper vehicle for STABO anchor - provides physics support for rope attachment
    // Inherits from Helicopter_Base_F like ACE refuel helper for guaranteed rope compatibility
    class Recondo_STABO_Helper: Helicopter_Base_F {
        scope = 1;
        scopeCurator = 0;
        displayName = "STABO Helper";
        author = "GoonSix";
        model = "\A3\Weapons_f\empty";
        
        // Disable all vehicle functionality
        class HitPoints {};
        class Turrets {};
        class TransportItems {};
        
        // No damage
        armor = 999999;
        damageEffect = "";
        destrType = "";
        
        // Prevent cargo/interaction
        transportSoldier = 0;
        
        // Hide from arsenal/editor
        editorCategory = "";
        editorSubcategory = "";
        vehicleClass = "";
    };
    
    // Harness object attached to players - acts as rope endpoint
    // Inherits from ThingX for physics support while being attachable
    class Recondo_STABO_Harness: ThingX {
        scope = 1;
        scopeCurator = 0;
        displayName = "STABO Harness";
        author = "GoonSix";
        model = "\A3\Weapons_f\empty";
        
        // Indestructible
        destrType = "DestructNo";
        
        // Hide from arsenal/editor
        editorCategory = "";
        editorSubcategory = "";
        vehicleClass = "";
    };
    
    //==========================================
    // TRACKERS MODULE
    // Priority: 5 (Feature module, depends on persistence settings)
    //==========================================
    class Recondo_Module_Trackers: Module_F {
        scope = 2;
        displayName = "Trackers";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleTrackers";
        functionPriority = 5;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 0;
        
        class ModuleDescription: ModuleDescription {
            description = "Spawns tracker groups that hunt players by following their footprints. Trackers spawn when players enter trigger areas near configured map markers. Optional tracker dogs can detect players at close range.";
            sync[] = {};
        };
        
        class Attributes: AttributesBase {
            
            // ========================================
            // GENERAL SETTINGS
            // ========================================
            class TrackerSide {
                displayName = "GENERAL - Tracker Side";
                tooltip = "Which side the tracker units belong to.";
                control = "Combo";
                property = "Recondo_Trackers_TrackerSide";
                expression = "_this setVariable ['trackerside', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0";
                category = "Recondo_Trackers_General";
                class Values {
                    class East { name = "OPFOR (East)"; value = 0; };
                    class West { name = "BLUFOR (West)"; value = 1; };
                    class Guer { name = "Independent"; value = 2; };
                };
            };
            class TargetSide {
                displayName = "Target Side";
                tooltip = "Which side the trackers will hunt (creates footprints for this side).";
                control = "Combo";
                property = "Recondo_Trackers_TargetSide";
                expression = "_this setVariable ['targetside', _value, true];";
                typeName = "NUMBER";
                defaultValue = "1";
                category = "Recondo_Trackers_General";
                class Values {
                    class East { name = "OPFOR (East)"; value = 0; };
                    class West { name = "BLUFOR (West)"; value = 1; };
                    class Guer { name = "Independent"; value = 2; };
                };
            };
            class TrackerClassnames {
                displayName = "Tracker Classnames";
                tooltip = "Comma-separated unit classnames for tracker units. One will be randomly selected per unit.";
                control = "EditMulti3";
                property = "Recondo_Trackers_TrackerClassnames";
                expression = "_this setVariable ['trackerclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_Trackers_General";
            };
            class MinGroupSize {
                displayName = "Min Group Size";
                tooltip = "Minimum number of units in each tracker group.";
                control = "Edit";
                property = "Recondo_Trackers_MinGroupSize";
                expression = "_this setVariable ['mingroupsize', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """2""";
                category = "Recondo_Trackers_General";
            };
            class MaxGroupSize {
                displayName = "Max Group Size";
                tooltip = "Maximum number of units in each tracker group.";
                control = "Edit";
                property = "Recondo_Trackers_MaxGroupSize";
                expression = "_this setVariable ['maxgroupsize', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """4""";
                category = "Recondo_Trackers_General";
            };
            class MaxActiveGroups {
                displayName = "Max Active Groups";
                tooltip = "Maximum number of tracker groups that can exist at once. -1 for unlimited.";
                control = "Edit";
                property = "Recondo_Trackers_MaxActiveGroups";
                expression = "_this setVariable ['maxactivegroups', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """20""";
                category = "Recondo_Trackers_General";
            };
            
            // ========================================
            // MARKER SETTINGS
            // ========================================
            class MarkerPrefix {
                displayName = "MARKERS - Tracker Marker Prefix";
                tooltip = "Prefix for invisible map markers that spawn trackers when players approach. Example: TRACKER_ will match TRACKER_1, TRACKER_2, etc.";
                control = "Edit";
                property = "Recondo_Trackers_MarkerPrefix";
                expression = "_this setVariable ['markerprefix', _value, true];";
                typeName = "STRING";
                defaultValue = """TRACKER_""";
                category = "Recondo_Trackers_Markers";
            };
            class NoFootprintPrefix {
                displayName = "No Footprint Marker Prefix";
                tooltip = "Prefix for markers that define safe zones where footprints are not created.";
                control = "Edit";
                property = "Recondo_Trackers_NoFootprintPrefix";
                expression = "_this setVariable ['nofootprintprefix', _value, true];";
                typeName = "STRING";
                defaultValue = """NO_FOOTPRINT_""";
                category = "Recondo_Trackers_Markers";
            };
            class SpawnProbability {
                displayName = "Spawn Probability";
                tooltip = "Chance (0-100%) that each tracker marker will be enabled for spawning at mission start.";
                control = "Slider";
                property = "Recondo_Trackers_SpawnProbability";
                expression = "_this setVariable ['spawnprobability', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.2";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_Trackers_Markers";
            };
            class TriggerDistance {
                displayName = "Trigger Distance (m)";
                tooltip = "Distance in meters from marker at which trackers spawn when target side enters.";
                control = "Edit";
                property = "Recondo_Trackers_TriggerDistance";
                expression = "_this setVariable ['triggerdistance', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """1000""";
                category = "Recondo_Trackers_Markers";
            };
            class NoFootprintRadius {
                displayName = "No Footprint Zone Radius (m)";
                tooltip = "Radius around no-footprint markers where footprints will not be created.";
                control = "Edit";
                property = "Recondo_Trackers_NoFootprintRadius";
                expression = "_this setVariable ['nofootprintradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """500""";
                category = "Recondo_Trackers_Markers";
            };
            class HeightLimit {
                displayName = "Height Limit (m)";
                tooltip = "Maximum height above ground for detection/spawning. Units higher than this (e.g., in aircraft) are ignored.";
                control = "Edit";
                property = "Recondo_Trackers_HeightLimit";
                expression = "_this setVariable ['heightlimit', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """45""";
                category = "Recondo_Trackers_Markers";
            };
            
            // ========================================
            // FOOTPRINT SETTINGS
            // ========================================
            class FootprintSpacing {
                displayName = "FOOTPRINTS - Spacing (m)";
                tooltip = "Distance between footprints in meters. Lower values create more accurate but performance-heavy tracking.";
                control = "Edit";
                property = "Recondo_Trackers_FootprintSpacing";
                expression = "_this setVariable ['footprintspacing', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """10""";
                category = "Recondo_Trackers_Footprints";
            };
            class AlwaysTrackChance {
                displayName = "Always Track Chance";
                tooltip = "Chance (0-100%) that a marker will track players regardless of movement speed. Otherwise, footprints are only created when moving faster than walking pace (6 km/h).";
                control = "Slider";
                property = "Recondo_Trackers_AlwaysTrackChance";
                expression = "_this setVariable ['alwaystrackchance', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.2";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_Trackers_Footprints";
            };
            class FootprintLifetime {
                displayName = "Footprint Lifetime (min)";
                tooltip = "Minutes before footprints expire and are cleaned up.";
                control = "Edit";
                property = "Recondo_Trackers_FootprintLifetime";
                expression = "_this setVariable ['footprintlifetime', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """20""";
                category = "Recondo_Trackers_Footprints";
            };
            
            // ========================================
            // TRACKER BEHAVIOR SETTINGS
            // ========================================
            class MovementSpeed {
                displayName = "BEHAVIOR - Movement Speed";
                tooltip = "Speed mode for tracker movement.";
                control = "Combo";
                property = "Recondo_Trackers_MovementSpeed";
                expression = "_this setVariable ['movementspeed', _value, true];";
                typeName = "STRING";
                defaultValue = """LIMITED""";
                category = "Recondo_Trackers_Behavior";
                class Values {
                    class Limited { name = "LIMITED (Walk)"; value = "LIMITED"; };
                    class Normal { name = "NORMAL"; value = "NORMAL"; };
                    class Full { name = "FULL (Run)"; value = "FULL"; };
                };
            };
            class SoundInterval {
                displayName = "Sound Interval (sec)";
                tooltip = "Seconds between tracker sounds. Set to 0 to disable sounds.";
                control = "Edit";
                property = "Recondo_Trackers_SoundInterval";
                expression = "_this setVariable ['soundinterval', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """30""";
                category = "Recondo_Trackers_Behavior";
            };
            class PredictiveDistanceMin {
                displayName = "Predictive Distance Min (m)";
                tooltip = "Minimum distance trackers will pursue in the predicted direction when footprints run out.";
                control = "Edit";
                property = "Recondo_Trackers_PredictiveDistanceMin";
                expression = "_this setVariable ['predictivedistancemin', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """200""";
                category = "Recondo_Trackers_Behavior";
            };
            class PredictiveDistanceMax {
                displayName = "Predictive Distance Max (m)";
                tooltip = "Maximum distance trackers will pursue in the predicted direction when footprints run out.";
                control = "Edit";
                property = "Recondo_Trackers_PredictiveDistanceMax";
                expression = "_this setVariable ['predictivedistancemax', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """300""";
                category = "Recondo_Trackers_Behavior";
            };
            
            // ========================================
            // DOG SETTINGS
            // ========================================
            class DogSpawnChance {
                displayName = "DOG - Spawn Chance";
                tooltip = "Chance (0-100%) that each tracker group will have a tracker dog.";
                control = "Slider";
                property = "Recondo_Trackers_DogSpawnChance";
                expression = "_this setVariable ['dogspawnchance', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.5";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_Trackers_Dog";
            };
            class DogClassnames {
                displayName = "Dog Classnames";
                tooltip = "Comma-separated dog unit classnames. One will be randomly selected per dog.";
                control = "EditMulti3";
                property = "Recondo_Trackers_DogClassnames";
                expression = "_this setVariable ['dogclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """Alsatian_Random_F,Alsatian_Black_F,Alsatian_Sandblack_F,Fin_random_F,Fin_blackwhite_F,Fin_ocherwhite_F""";
                category = "Recondo_Trackers_Dog";
            };
            class DogDetectionDay {
                displayName = "Day Detection Range (m)";
                tooltip = "Dog detection range during daytime.";
                control = "Edit";
                property = "Recondo_Trackers_DogDetectionDay";
                expression = "_this setVariable ['dogdetectionday', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """15""";
                category = "Recondo_Trackers_Dog";
            };
            class DogDetectionNight {
                displayName = "Night Detection Range (m)";
                tooltip = "Dog detection range during nighttime.";
                control = "Edit";
                property = "Recondo_Trackers_DogDetectionNight";
                expression = "_this setVariable ['dogdetectionnight', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """10""";
                category = "Recondo_Trackers_Dog";
            };
            class DogLeadDistance {
                displayName = "Lead Distance (m)";
                tooltip = "How far ahead of the group the dog moves.";
                control = "Edit";
                property = "Recondo_Trackers_DogLeadDistance";
                expression = "_this setVariable ['dogleaddistance', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """12""";
                category = "Recondo_Trackers_Dog";
            };
            class DogHarassmentRange {
                displayName = "Harassment Range (m)";
                tooltip = "Range at which dog chases and harasses detected enemies.";
                control = "Edit";
                property = "Recondo_Trackers_DogHarassmentRange";
                expression = "_this setVariable ['dogharassmentrange', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """5""";
                category = "Recondo_Trackers_Dog";
            };
            
            // ========================================
            // TARGET FILTER SETTINGS
            // ========================================
            class TargetFilterHeight {
                displayName = "TARGET FILTER - Ignore Height (m)";
                tooltip = "Tracker AI will ignore (forget about) units in vehicles above this height. Set to 0 to disable height filtering.";
                control = "Edit";
                property = "Recondo_Trackers_TargetFilterHeight";
                expression = "_this setVariable ['targetfilterheight', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """60""";
                category = "Recondo_Trackers_TargetFilter";
            };
            class TargetFilterUnits {
                displayName = "Ignore Unit Classnames";
                tooltip = "Comma-separated unit classnames that tracker AI will ignore. Example: B_Pilot_F,B_helicrew_F";
                control = "EditMulti3";
                property = "Recondo_Trackers_TargetFilterUnits";
                expression = "_this setVariable ['targetfilterunits', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_Trackers_TargetFilter";
            };
            class TargetFilterVehicles {
                displayName = "Ignore Vehicle Classnames";
                tooltip = "Comma-separated vehicle classnames whose occupants tracker AI will ignore. All aircraft (isKindOf Air) are automatically ignored regardless of this setting.";
                control = "EditMulti3";
                property = "Recondo_Trackers_TargetFilterVehicles";
                expression = "_this setVariable ['targetfiltervehicles', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_Trackers_TargetFilter";
            };
            
            // ========================================
            // DEBUG SETTINGS
            // ========================================
            class DebugMarkers {
                displayName = "DEBUG - Show Debug Markers";
                tooltip = "Show debug markers on map for footprints and tracker positions.";
                control = "Checkbox";
                property = "Recondo_Trackers_DebugMarkers";
                expression = "_this setVariable ['debugmarkers', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_Trackers_Debug";
            };
            class DebugLogging {
                displayName = "Enable Debug Logging";
                tooltip = "Enable detailed logging to RPT file for troubleshooting.";
                control = "Checkbox";
                property = "Recondo_Trackers_DebugLogging";
                expression = "_this setVariable ['debuglogging', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_Trackers_Debug";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    //==========================================
    // REINFORCEMENT WAVES MODULE
    // Priority: 5 (Feature module)
    // Multiple instances can be placed for different areas
    //==========================================
    class Recondo_Module_ReinforcementWaves: Module_F {
        scope = 2;
        displayName = "Reinforcement Waves";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleReinforcementWaves";
        functionPriority = 5;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 0;
        
        class ModuleDescription: ModuleDescription {
            description = "Creates a detection zone where OPFOR units trigger reinforcement waves when they detect BLUFOR. Spawns progressive waves of pursuit groups that follow player footprints. Multiple modules can be placed for different areas.";
            sync[] = {};
        };
        
        class Attributes: AttributesBase {
            
            // ========================================
            // GENERAL SETTINGS
            // ========================================
            class ReinforcementSide {
                displayName = "GENERAL - Reinforcement Side";
                tooltip = "Which side the reinforcement units belong to.";
                control = "Combo";
                property = "Recondo_RW_ReinforcementSide";
                expression = "_this setVariable ['reinforcementside', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0";
                category = "Recondo_RW_General";
                class Values {
                    class East { name = "OPFOR (East)"; value = 0; };
                    class West { name = "BLUFOR (West)"; value = 1; };
                    class Guer { name = "Independent"; value = 2; };
                };
            };
            class TargetSide {
                displayName = "Target Side";
                tooltip = "Which side the reinforcements will hunt (OPFOR in trigger must detect this side).";
                control = "Combo";
                property = "Recondo_RW_TargetSide";
                expression = "_this setVariable ['targetside', _value, true];";
                typeName = "NUMBER";
                defaultValue = "1";
                category = "Recondo_RW_General";
                class Values {
                    class East { name = "OPFOR (East)"; value = 0; };
                    class West { name = "BLUFOR (West)"; value = 1; };
                    class Guer { name = "Independent"; value = 2; };
                };
            };
            class ReinforcementChance {
                displayName = "Reinforcement Chance";
                tooltip = "Chance (0-100%) that reinforcements will spawn when triggered.";
                control = "Slider";
                property = "Recondo_RW_ReinforcementChance";
                expression = "_this setVariable ['reinforcementchance', _value, true];";
                typeName = "NUMBER";
                defaultValue = "1";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_RW_General";
            };
            class UnitClassnames {
                displayName = "Unit Classnames";
                tooltip = "Comma-separated unit classnames for reinforcement units.";
                control = "EditMulti3";
                property = "Recondo_RW_UnitClassnames";
                expression = "_this setVariable ['unitclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_RW_General";
            };
            class MaxActiveGroups {
                displayName = "Max Active Groups";
                tooltip = "Maximum number of reinforcement groups that can exist at once from this module. -1 for unlimited.";
                control = "Edit";
                property = "Recondo_RW_MaxActiveGroups";
                expression = "_this setVariable ['maxactivegroups', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """20""";
                category = "Recondo_RW_General";
            };
            
            // ========================================
            // DETECTION SETTINGS
            // ========================================
            class TriggerRadius {
                displayName = "DETECTION - Trigger Radius (m)";
                tooltip = "Radius of the detection zone around this module.";
                control = "Edit";
                property = "Recondo_RW_TriggerRadius";
                expression = "_this setVariable ['triggerradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """500""";
                category = "Recondo_RW_Detection";
            };
            class DetectionThreshold {
                displayName = "Detection Threshold";
                tooltip = "knowsAbout value required for detection (0-4). Higher = requires better visual contact.";
                control = "Slider";
                property = "Recondo_RW_DetectionThreshold";
                expression = "_this setVariable ['detectionthreshold', _value, true];";
                typeName = "NUMBER";
                defaultValue = "1.5";
                sliderRange[] = {0.5, 4};
                sliderStep = 0.1;
                category = "Recondo_RW_Detection";
            };
            class HeightLimit {
                displayName = "Height Limit (m)";
                tooltip = "Maximum height above ground for detection. Units higher than this (aircraft) are ignored.";
                control = "Edit";
                property = "Recondo_RW_HeightLimit";
                expression = "_this setVariable ['heightlimit', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """20""";
                category = "Recondo_RW_Detection";
            };
            
            // ========================================
            // SPAWN SETTINGS
            // ========================================
            class SpawnDistance {
                displayName = "SPAWN - Spawn Distance (m)";
                tooltip = "Distance behind the detecting unit where reinforcements spawn.";
                control = "Edit";
                property = "Recondo_RW_SpawnDistance";
                expression = "_this setVariable ['spawndistance', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """300""";
                category = "Recondo_RW_Spawn";
            };
            class SafetyDistance {
                displayName = "Safety Distance (m)";
                tooltip = "Minimum distance from target side units for spawn point. If too close, picks another direction.";
                control = "Edit";
                property = "Recondo_RW_SafetyDistance";
                expression = "_this setVariable ['safetydistance', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """200""";
                category = "Recondo_RW_Spawn";
            };
            
            // ========================================
            // WAVE 1 SETTINGS (Main + Flankers)
            // ========================================
            class Wave1MinSize {
                displayName = "WAVE 1 - Main Group Min Size";
                tooltip = "Minimum number of units in the main reinforcement group.";
                control = "Edit";
                property = "Recondo_RW_Wave1MinSize";
                expression = "_this setVariable ['wave1minsize', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """2""";
                category = "Recondo_RW_Wave1";
            };
            class Wave1MaxSize {
                displayName = "Main Group Max Size";
                tooltip = "Maximum number of units in the main reinforcement group.";
                control = "Edit";
                property = "Recondo_RW_Wave1MaxSize";
                expression = "_this setVariable ['wave1maxsize', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """4""";
                category = "Recondo_RW_Wave1";
            };
            class SoundInterval {
                displayName = "Sound Interval (sec)";
                tooltip = "Seconds between tracker sounds for Wave 1 groups. 0 to disable.";
                control = "Edit";
                property = "Recondo_RW_SoundInterval";
                expression = "_this setVariable ['soundinterval', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """30""";
                category = "Recondo_RW_Wave1";
            };
            
            // ========================================
            // FLANKER SETTINGS
            // ========================================
            class EnableFlankers {
                displayName = "FLANKERS - Enable Flankers";
                tooltip = "Enable left and right flanker groups for Wave 1.";
                control = "Checkbox";
                property = "Recondo_RW_EnableFlankers";
                expression = "_this setVariable ['enableflankers', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_RW_Flankers";
            };
            class FlankerMinSize {
                displayName = "Flanker Min Size";
                tooltip = "Minimum number of units per flanker group.";
                control = "Edit";
                property = "Recondo_RW_FlankerMinSize";
                expression = "_this setVariable ['flankerminsize', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """2""";
                category = "Recondo_RW_Flankers";
            };
            class FlankerMaxSize {
                displayName = "Flanker Max Size";
                tooltip = "Maximum number of units per flanker group.";
                control = "Edit";
                property = "Recondo_RW_FlankerMaxSize";
                expression = "_this setVariable ['flankermaxsize', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """2""";
                category = "Recondo_RW_Flankers";
            };
            class FlankerLateralOffset {
                displayName = "Lateral Offset (m)";
                tooltip = "Side offset distance for flanker groups from the main group.";
                control = "Edit";
                property = "Recondo_RW_FlankerLateralOffset";
                expression = "_this setVariable ['flankerlateraloffset', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """120""";
                category = "Recondo_RW_Flankers";
            };
            class FlankerForwardOffset {
                displayName = "Forward Offset (m)";
                tooltip = "Forward offset distance for flanker groups ahead of the main group.";
                control = "Edit";
                property = "Recondo_RW_FlankerForwardOffset";
                expression = "_this setVariable ['flankerforwardoffset', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """75""";
                category = "Recondo_RW_Flankers";
            };
            
            // ========================================
            // DOG SETTINGS
            // ========================================
            class DogSpawnChance {
                displayName = "DOG - Spawn Chance";
                tooltip = "Chance (0-100%) that Wave 1 main group will have a tracker dog.";
                control = "Slider";
                property = "Recondo_RW_DogSpawnChance";
                expression = "_this setVariable ['dogspawnchance', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.5";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_RW_Dogs";
            };
            class DogClassnames {
                displayName = "Dog Classnames";
                tooltip = "Comma-separated dog unit classnames. One will be randomly selected per dog.";
                control = "EditMulti3";
                property = "Recondo_RW_DogClassnames";
                expression = "_this setVariable ['dogclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """Alsatian_Random_F,Alsatian_Black_F,Alsatian_Sandblack_F,Fin_random_F,Fin_blackwhite_F,Fin_ocherwhite_F""";
                category = "Recondo_RW_Dogs";
            };
            class DogDetectionDay {
                displayName = "Day Detection Range (m)";
                tooltip = "Dog detection range during daytime.";
                control = "Edit";
                property = "Recondo_RW_DogDetectionDay";
                expression = "_this setVariable ['dogdetectionday', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """15""";
                category = "Recondo_RW_Dogs";
            };
            class DogDetectionNight {
                displayName = "Night Detection Range (m)";
                tooltip = "Dog detection range during nighttime.";
                control = "Edit";
                property = "Recondo_RW_DogDetectionNight";
                expression = "_this setVariable ['dogdetectionnight', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """10""";
                category = "Recondo_RW_Dogs";
            };
            class DogLeadDistance {
                displayName = "Lead Distance (m)";
                tooltip = "How far ahead of the group the dog moves.";
                control = "Edit";
                property = "Recondo_RW_DogLeadDistance";
                expression = "_this setVariable ['dogleaddistance', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """12""";
                category = "Recondo_RW_Dogs";
            };
            class DogHarassmentRange {
                displayName = "Harassment Range (m)";
                tooltip = "Range at which dog chases and harasses detected enemies.";
                control = "Edit";
                property = "Recondo_RW_DogHarassmentRange";
                expression = "_this setVariable ['dogharassmentrange', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """5""";
                category = "Recondo_RW_Dogs";
            };
            
            // ========================================
            // WAVE 2+ SETTINGS (Pursuit Groups)
            // ========================================
            class NumberOfWaves {
                displayName = "PURSUIT - Number of Additional Waves";
                tooltip = "Number of pursuit waves after Wave 1 (0-4). Each wave spawns when the previous detects the target.";
                control = "Edit";
                property = "Recondo_RW_NumberOfWaves";
                expression = "_this setVariable ['numberofwaves', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """3""";
                category = "Recondo_RW_Pursuit";
            };
            class PursuitMinSize {
                displayName = "Pursuit Group Min Size";
                tooltip = "Minimum number of units in pursuit groups (Wave 2+).";
                control = "Edit";
                property = "Recondo_RW_PursuitMinSize";
                expression = "_this setVariable ['pursuitminsize', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """4""";
                category = "Recondo_RW_Pursuit";
            };
            class PursuitMaxSize {
                displayName = "Pursuit Group Max Size";
                tooltip = "Maximum number of units in pursuit groups (Wave 2+).";
                control = "Edit";
                property = "Recondo_RW_PursuitMaxSize";
                expression = "_this setVariable ['pursuitmaxsize', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """6""";
                category = "Recondo_RW_Pursuit";
            };
            
            // ========================================
            // TARGET FILTER SETTINGS
            // ========================================
            class TargetFilterHeight {
                displayName = "TARGET FILTER - Ignore Height (m)";
                tooltip = "Reinforcement AI will ignore (forget about) units in vehicles above this height. Set to 0 to disable height filtering.";
                control = "Edit";
                property = "Recondo_RW_TargetFilterHeight";
                expression = "_this setVariable ['targetfilterheight', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """60""";
                category = "Recondo_RW_TargetFilter";
            };
            class TargetFilterUnits {
                displayName = "Ignore Unit Classnames";
                tooltip = "Comma-separated unit classnames that reinforcement AI will ignore. Example: B_Pilot_F,B_helicrew_F";
                control = "EditMulti3";
                property = "Recondo_RW_TargetFilterUnits";
                expression = "_this setVariable ['targetfilterunits', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_RW_TargetFilter";
            };
            class TargetFilterVehicles {
                displayName = "Ignore Vehicle Classnames";
                tooltip = "Comma-separated vehicle classnames whose occupants reinforcement AI will ignore. All aircraft (isKindOf Air) are automatically ignored regardless of this setting.";
                control = "EditMulti3";
                property = "Recondo_RW_TargetFilterVehicles";
                expression = "_this setVariable ['targetfiltervehicles', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_RW_TargetFilter";
            };
            
            // ========================================
            // DEBUG SETTINGS
            // ========================================
            class DebugMarkers {
                displayName = "DEBUG - Show Debug Markers";
                tooltip = "Show debug markers on map for triggers and spawn positions.";
                control = "Checkbox";
                property = "Recondo_RW_DebugMarkers";
                expression = "_this setVariable ['debugmarkers', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_RW_Debug";
            };
            class DebugLogging {
                displayName = "Enable Debug Logging";
                tooltip = "Enable detailed logging to RPT file for troubleshooting.";
                control = "Checkbox";
                property = "Recondo_RW_DebugLogging";
                expression = "_this setVariable ['debuglogging', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_RW_Debug";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    //==========================================
    // INTEL MODULE
    // Priority: 1 (Core system module - loads early)
    // Central hub for intel gathering and reveal system
    //==========================================
    class Recondo_Module_Intel: Module_F {
        scope = 2;
        displayName = "Intel System";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleIntel";
        functionPriority = 1;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 0;
        canSetArea = 0;
        
        class ModuleDescription: ModuleDescription {
            description = "Central intel system that manages intel gathering and target reveals. Sync to an object or unit to designate it as the intel turn-in point. Other modules register their targets with this system.";
            sync[] = {"AnyAI", "AnyVehicle", "AnyStaticObject"};
        };
        
        class Attributes: AttributesBase {
            
            // ========================================
            // GENERAL SETTINGS
            // ========================================
            class IntelItemClassnames {
                displayName = "GENERAL - Intel Item Classnames";
                tooltip = "Comma-separated classnames of items that count as intel documents. Leave empty to use any item with 'intel' in the classname.";
                control = "EditMulti3";
                property = "Recondo_Intel_ItemClassnames";
                expression = "_this setVariable ['intelitemclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_Intel_General";
            };
            
            // ========================================
            // TURN-IN SETTINGS
            // ========================================
            class TurnInActionText {
                displayName = "TURN-IN - Action Text";
                tooltip = "Text shown in the ACE interaction menu for turning in intel.";
                control = "Edit";
                property = "Recondo_Intel_TurnInActionText";
                expression = "_this setVariable ['turninactiontext', _value, true];";
                typeName = "STRING";
                defaultValue = """Turn In Intel""";
                category = "Recondo_Intel_TurnIn";
            };
            class TurnInSuccessText {
                displayName = "Success Message";
                tooltip = "Message shown when intel is successfully turned in. Use %1 for grid coordinates.";
                control = "Edit";
                property = "Recondo_Intel_TurnInSuccessText";
                expression = "_this setVariable ['turninsuccesstext', _value, true];";
                typeName = "STRING";
                defaultValue = """Intel Report: Grid %1""";
                category = "Recondo_Intel_TurnIn";
            };
            class TurnInNoIntelText {
                displayName = "No Intel Message";
                tooltip = "Message shown when player has no intel to turn in.";
                control = "Edit";
                property = "Recondo_Intel_TurnInNoIntelText";
                expression = "_this setVariable ['turninnointeltext', _value, true];";
                typeName = "STRING";
                defaultValue = """You have no intel to turn in.""";
                category = "Recondo_Intel_TurnIn";
            };
            class TurnInNoTargetsText {
                displayName = "No Targets Message";
                tooltip = "Message shown when there are no unrevealed targets available.";
                control = "Edit";
                property = "Recondo_Intel_TurnInNoTargetsText";
                expression = "_this setVariable ['turninnotargetstext', _value, true];";
                typeName = "STRING";
                defaultValue = """No actionable intelligence at this time.""";
                category = "Recondo_Intel_TurnIn";
            };
            
            // ========================================
            // PERSISTENCE SETTINGS
            // ========================================
            class EnablePersistence {
                displayName = "PERSISTENCE - Enable Persistence";
                tooltip = "Save and load intel state (revealed targets, completed targets) between mission restarts.";
                control = "Checkbox";
                property = "Recondo_Intel_EnablePersistence";
                expression = "_this setVariable ['enablepersistence', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_Intel_Persistence";
            };
            
            // ========================================
            // DEBUG SETTINGS
            // ========================================
            class DebugLogging {
                displayName = "DEBUG - Enable Debug Logging";
                tooltip = "Enable detailed logging to RPT file for troubleshooting.";
                control = "Checkbox";
                property = "Recondo_Intel_DebugLogging";
                expression = "_this setVariable ['debuglogging', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_Intel_Debug";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    //==========================================
    // INTEL ITEMS MODULE
    // Priority: 3 (Feature module - after Intel core)
    // Adds intel items to AI unit inventories
    //==========================================
    class Recondo_Module_IntelItems: Module_F {
        scope = 2;
        displayName = "Intel - Items";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleIntelItems";
        functionPriority = 3;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 0;
        canSetArea = 0;
        
        class ModuleDescription: ModuleDescription {
            description = "Adds intel items to AI unit inventories based on unit classnames and probability. Sync to the Intel System module to register as an intel source. Intel can be taken via ACE interaction on living or dead units.";
            sync[] = {"Recondo_Module_Intel"};
        };
        
        class Attributes: AttributesBase {
            
            // ========================================
            // GENERAL SETTINGS
            // ========================================
            class IntelChance {
                displayName = "GENERAL - Intel Chance";
                tooltip = "Percentage chance (0-100%) that a matching unit will have intel items.";
                control = "Slider";
                property = "Recondo_IntelItems_IntelChance";
                expression = "_this setVariable ['intelchance', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.5";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_IntelItems_General";
            };
            class MinItems {
                displayName = "Min Intel Items";
                tooltip = "Minimum number of intel items per unit (if they have intel).";
                control = "Edit";
                property = "Recondo_IntelItems_MinItems";
                expression = "_this setVariable ['minitems', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """1""";
                category = "Recondo_IntelItems_General";
            };
            class MaxItems {
                displayName = "Max Intel Items";
                tooltip = "Maximum number of intel items per unit (if they have intel).";
                control = "Edit";
                property = "Recondo_IntelItems_MaxItems";
                expression = "_this setVariable ['maxitems', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """1""";
                category = "Recondo_IntelItems_General";
            };
            
            // ========================================
            // UNIT SETTINGS
            // ========================================
            class UnitClassnames {
                displayName = "UNITS - Unit Classnames";
                tooltip = "Comma-separated classnames of units that can receive intel items. Only units in this list will be eligible. If empty, no units will receive intel.";
                control = "EditMulti5";
                property = "Recondo_IntelItems_UnitClassnames";
                expression = "_this setVariable ['unitclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_IntelItems_Units";
            };
            class TargetSide {
                displayName = "Target Side";
                tooltip = "Which side's units can have intel. Set to 'Any' to allow all sides.";
                control = "Combo";
                property = "Recondo_IntelItems_TargetSide";
                expression = "_this setVariable ['targetside', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0";
                category = "Recondo_IntelItems_Units";
                class Values {
                    class East { name = "OPFOR (East)"; value = 0; };
                    class West { name = "BLUFOR (West)"; value = 1; };
                    class Guer { name = "Independent"; value = 2; };
                    class Any { name = "Any Side"; value = 3; };
                };
            };
            
            // ========================================
            // ITEM SETTINGS
            // ========================================
            class IntelItemsConfig {
                displayName = "ITEMS - Intel Items Config";
                tooltip = "Define intel items, one per line. Format: DisplayName:Classname:Weight\nExample:\nMobile Phone:ACE_Cellphone:5\nField Orders:ACE_Documents:3";
                control = "EditMulti5";
                property = "Recondo_IntelItems_ItemsConfig";
                expression = "_this setVariable ['intelitemsconfig', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_IntelItems_Items";
            };
            class TakeActionText {
                displayName = "Take Action Text";
                tooltip = "Text format for ACE interaction. Use %1 for item display name.";
                control = "Edit";
                property = "Recondo_IntelItems_TakeActionText";
                expression = "_this setVariable ['takeactiontext', _value, true];";
                typeName = "STRING";
                defaultValue = """Take %1""";
                category = "Recondo_IntelItems_Items";
            };
            
            // ========================================
            // DEBUG SETTINGS
            // ========================================
            class DebugLogging {
                displayName = "DEBUG - Enable Debug Logging";
                tooltip = "Enable detailed logging to RPT file for troubleshooting.";
                control = "Checkbox";
                property = "Recondo_IntelItems_DebugLogging";
                expression = "_this setVariable ['debuglogging', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_IntelItems_Debug";
            };
            
            // ========================================
            // POW SETTINGS
            // ========================================
            class EnablePOW {
                displayName = "POW - Enable POW Turn-In";
                tooltip = "Enable turning in prisoners of war at Intel turn-in points.";
                control = "Checkbox";
                property = "Recondo_IntelItems_EnablePOW";
                expression = "_this setVariable ['enablepow', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_IntelItems_POW";
            };
            class POWTargetSide {
                displayName = "POW Target Side";
                tooltip = "Which side's units can be turned in as POWs. Uses OR logic with classnames.";
                control = "Combo";
                property = "Recondo_IntelItems_POWTargetSide";
                expression = "_this setVariable ['powtargetside', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0";
                category = "Recondo_IntelItems_POW";
                class Values {
                    class East { name = "OPFOR (East)"; value = 0; };
                    class West { name = "BLUFOR (West)"; value = 1; };
                    class Guer { name = "Independent"; value = 2; };
                    class Civ { name = "Civilian"; value = 3; };
                    class Any { name = "Any Side"; value = 4; };
                };
            };
            class POWClassnames {
                displayName = "POW Classnames";
                tooltip = "Optional: Comma-separated classnames that can be turned in as POWs. Uses OR logic with side filter.";
                control = "EditMulti3";
                property = "Recondo_IntelItems_POWClassnames";
                expression = "_this setVariable ['powclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_IntelItems_POW";
            };
            class POWTurnInRadius {
                displayName = "POW Turn-In Radius";
                tooltip = "How close the POW must be to the turn-in point (meters).";
                control = "Edit";
                property = "Recondo_IntelItems_POWTurnInRadius";
                expression = "_this setVariable ['powturninradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """10""";
                category = "Recondo_IntelItems_POW";
            };
            class POWIntelValue {
                displayName = "POW Intel Value";
                tooltip = "Weight for intel reveal chance when turning in POW (lower = less likely to reveal targets).";
                control = "Slider";
                property = "Recondo_IntelItems_POWIntelValue";
                expression = "_this setVariable ['powintelvalue', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.3";
                sliderRange[] = {0.1, 2};
                sliderStep = 0.1;
                category = "Recondo_IntelItems_POW";
            };
            class POWActionText {
                displayName = "POW Action Text";
                tooltip = "Text for the ACE action to turn in a POW.";
                control = "Edit";
                property = "Recondo_IntelItems_POWActionText";
                expression = "_this setVariable ['powactiontext', _value, true];";
                typeName = "STRING";
                defaultValue = """Turn In Prisoner""";
                category = "Recondo_IntelItems_POW";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    //==========================================
    // INTEL BOARD MODULE
    // Priority: 3 (Feature module - after Intel core)
    // Creates a mission intel board for viewing target dossiers
    //==========================================
    class Recondo_Module_IntelBoard: Module_F {
        scope = 2;
        displayName = "Intel - Board";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleIntelBoard";
        functionPriority = 3;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 0;
        canSetArea = 0;
        
        class ModuleDescription: ModuleDescription {
            description = "Creates an Intel Board for viewing mission target information. Sync any object (board, laptop, screen) to this module. Players can access via ACE interaction to view HVTs, Hostages, and other objectives with photos, backgrounds, and revealed locations.";
            sync[] = {"AnyStaticObject"};
        };
        
        class Attributes: AttributesBase {
            
            // ========================================
            // GENERAL SETTINGS
            // ========================================
            class BoardName {
                displayName = "GENERAL - Board Name";
                tooltip = "Display name shown at top of the Intel Board dialog.";
                control = "Edit";
                property = "Recondo_IntelBoard_BoardName";
                expression = "_this setVariable ['boardname', _value, true];";
                typeName = "STRING";
                defaultValue = """MISSION INTEL""";
                category = "Recondo_IntelBoard_General";
            };
            class ACEActionName {
                displayName = "ACE Action Name";
                tooltip = "Text shown in ACE interaction menu.";
                control = "Edit";
                property = "Recondo_IntelBoard_ACEActionName";
                expression = "_this setVariable ['aceactionname', _value, true];";
                typeName = "STRING";
                defaultValue = """View Intel Board""";
                category = "Recondo_IntelBoard_General";
            };
            
            // ========================================
            // DISPLAY OPTIONS
            // ========================================
            class EnableHVT {
                displayName = "DISPLAY - Show HVT";
                tooltip = "Show High Value Target objectives on the Intel Board.";
                control = "Checkbox";
                property = "Recondo_IntelBoard_EnableHVT";
                expression = "_this setVariable ['enablehvt', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_IntelBoard_Display";
            };
            class EnableHostages {
                displayName = "Show Hostages";
                tooltip = "Show Hostage Rescue objectives on the Intel Board.";
                control = "Checkbox";
                property = "Recondo_IntelBoard_EnableHostages";
                expression = "_this setVariable ['enablehostages', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_IntelBoard_Display";
            };
            class EnableDestroy {
                displayName = "Show Destroy Objectives";
                tooltip = "Show Destroy objectives on the Intel Board.";
                control = "Checkbox";
                property = "Recondo_IntelBoard_EnableDestroy";
                expression = "_this setVariable ['enabledestroy', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_IntelBoard_Display";
            };
            class EnableHubSubs {
                displayName = "Show Hub & Subs";
                tooltip = "Show Hub & Subs objectives on the Intel Board.";
                control = "Checkbox";
                property = "Recondo_IntelBoard_EnableHubSubs";
                expression = "_this setVariable ['enablehubsubs', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_IntelBoard_Display";
            };
            class EnableJammer {
                displayName = "Show Jammer Objectives";
                tooltip = "Show ACRE Jammer objectives on the Intel Board.";
                control = "Checkbox";
                property = "Recondo_IntelBoard_EnableJammer";
                expression = "_this setVariable ['enablejammer', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_IntelBoard_Display";
            };
            class ShowRevealedLocations {
                displayName = "Show Revealed Locations";
                tooltip = "Show grid references for targets that have been revealed through intel.";
                control = "Checkbox";
                property = "Recondo_IntelBoard_ShowRevealedLocations";
                expression = "_this setVariable ['showrevealedlocations', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_IntelBoard_Display";
            };
            
            // ========================================
            // DEBUG SETTINGS
            // ========================================
            class DebugLogging {
                displayName = "DEBUG - Enable Logging";
                tooltip = "Enable detailed logging to RPT file.";
                control = "Checkbox";
                property = "Recondo_IntelBoard_DebugLogging";
                expression = "_this setVariable ['debuglogging', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_IntelBoard_Debug";
            };
        };
    };
    
    //==========================================
    // WIRETAP MODULE
    // Spawns telephone poles at markers for wiretap missions
    //==========================================
    class Recondo_Module_Wiretap: Module_F {
        scope = 2;
        displayName = "Wiretap System";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleWiretap";
        functionPriority = 5;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 0;
        canSetArea = 0;
        
        class ModuleDescription: ModuleDescription {
            description = "Spawns telephone poles at invisible map markers. Players with a wiretap item can place and retrieve wiretaps to gain intel items.";
            sync[] = {};
        };
        
        class Attributes: AttributesBase {
            
            // ========================================
            // GENERAL SETTINGS
            // ========================================
            class MarkerPrefix {
                displayName = "GENERAL - Marker Prefix";
                tooltip = "Prefix for invisible map markers. Example: 'WIRETAP_' will find WIRETAP_1, WIRETAP_2, etc.";
                control = "Edit";
                property = "Recondo_Wiretap_MarkerPrefix";
                expression = "_this setVariable ['markerprefix', _value, true];";
                typeName = "STRING";
                defaultValue = """WIRETAP_""";
                category = "Recondo_Wiretap_General";
            };
            class SpawnPercentage {
                displayName = "Spawn Percentage";
                tooltip = "Percentage of available markers that will have poles spawned (0-100%).";
                control = "Slider";
                property = "Recondo_Wiretap_SpawnPercentage";
                expression = "_this setVariable ['spawnpercentage', _value, true];";
                typeName = "NUMBER";
                defaultValue = "1";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_Wiretap_General";
            };
            class PoleClassname {
                displayName = "Pole Classname";
                tooltip = "Classname of the object to spawn as the telephone pole.";
                control = "Edit";
                property = "Recondo_Wiretap_PoleClassname";
                expression = "_this setVariable ['poleclassname', _value, true];";
                typeName = "STRING";
                defaultValue = """Land_PowerLine_02_pole_junction_A_F""";
                category = "Recondo_Wiretap_General";
            };
            
            // ========================================
            // TIMING SETTINGS
            // ========================================
            class ClimbDuration {
                displayName = "TIMING - Climb Duration";
                tooltip = "Duration in seconds for climbing up/down the pole.";
                control = "Edit";
                property = "Recondo_Wiretap_ClimbDuration";
                expression = "_this setVariable ['climbduration', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """5""";
                category = "Recondo_Wiretap_Timing";
            };
            class PlaceDuration {
                displayName = "Place/Retrieve Duration";
                tooltip = "Duration in seconds for placing or retrieving the wiretap.";
                control = "Edit";
                property = "Recondo_Wiretap_PlaceDuration";
                expression = "_this setVariable ['placeduration', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """5""";
                category = "Recondo_Wiretap_Timing";
            };
            class RetrievalDelay {
                displayName = "Retrieval Delay";
                tooltip = "Time in seconds after placing before wiretap can be retrieved.";
                control = "Edit";
                property = "Recondo_Wiretap_RetrievalDelay";
                expression = "_this setVariable ['retrievaldelay', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """5""";
                category = "Recondo_Wiretap_Timing";
            };
            
            // ========================================
            // ITEMS SETTINGS
            // ========================================
            class WiretapItem {
                displayName = "ITEMS - Wiretap Kit Item";
                tooltip = "Classname of the item required to place a wiretap.";
                control = "Edit";
                property = "Recondo_Wiretap_WiretapItem";
                expression = "_this setVariable ['wiretapitem', _value, true];";
                typeName = "STRING";
                defaultValue = """vn_b_item_wiretap""";
                category = "Recondo_Wiretap_Items";
            };
            class RewardItem {
                displayName = "Reward Item";
                tooltip = "Classname of the item given when wiretap is retrieved. This should be an intel item for turn-in.";
                control = "Edit";
                property = "Recondo_Wiretap_RewardItem";
                expression = "_this setVariable ['rewarditem', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_Wiretap_Items";
            };
            
            // ========================================
            // PLACEMENT SETTINGS
            // ========================================
            class PoleHeight {
                displayName = "PLACEMENT - Pole Height";
                tooltip = "Height in meters for the climbing position on the pole.";
                control = "Edit";
                property = "Recondo_Wiretap_PoleHeight";
                expression = "_this setVariable ['poleheight', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """8""";
                category = "Recondo_Wiretap_Placement";
            };
            class RoadSearchRadius {
                displayName = "Road Search Radius";
                tooltip = "Distance in meters to search for roads from marker position.";
                control = "Edit";
                property = "Recondo_Wiretap_RoadSearchRadius";
                expression = "_this setVariable ['roadsearchradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """100""";
                category = "Recondo_Wiretap_Placement";
            };
            class RoadOffset {
                displayName = "Road Offset";
                tooltip = "Distance in meters from road to place pole.";
                control = "Edit";
                property = "Recondo_Wiretap_RoadOffset";
                expression = "_this setVariable ['roadoffset', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """8""";
                category = "Recondo_Wiretap_Placement";
            };
            class ClearRadius {
                displayName = "Clear Radius";
                tooltip = "Radius in meters to clear terrain objects around poles.";
                control = "Edit";
                property = "Recondo_Wiretap_ClearRadius";
                expression = "_this setVariable ['clearradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """4""";
                category = "Recondo_Wiretap_Placement";
            };
            class DisableSimulation {
                displayName = "Disable Simulation";
                tooltip = "Disable simulation on poles. Prevents accidental destruction by vehicles while maintaining ACE interactions.";
                control = "Checkbox";
                property = "Recondo_Wiretap_DisableSimulation";
                expression = "_this setVariable ['disablesimulation', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_Wiretap_Placement";
            };
            
            // ========================================
            // ROPE & GROUND ITEM SETTINGS
            // ========================================
            class GroundWiretapDistance {
                displayName = "ROPE - Ground Item Distance";
                tooltip = "Distance in meters from pole base where the ground wiretap item spawns (away from road).";
                control = "Edit";
                property = "Recondo_Wiretap_GroundWiretapDistance";
                expression = "_this setVariable ['groundwiretapdistance', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """6""";
                category = "Recondo_Wiretap_Rope";
            };
            class GroundWiretapClassname {
                displayName = "Ground Item Classname";
                tooltip = "Classname of the object spawned on the ground connected to the rope.";
                control = "Edit";
                property = "Recondo_Wiretap_GroundWiretapClassname";
                expression = "_this setVariable ['groundwiretapclassname', _value, true];";
                typeName = "STRING";
                defaultValue = """vn_b_item_wiretap_gh""";
                category = "Recondo_Wiretap_Rope";
            };
            class PoleGroundObjectClassname {
                displayName = "Pole Ground Connection Object";
                tooltip = "Object spawned at ground where pole-to-ground ropes terminate (when poles are >50m apart or at first/last poles).";
                control = "Edit";
                property = "Recondo_Wiretap_PoleGroundObjectClassname";
                expression = "_this setVariable ['polegroundobjectclassname', _value, true];";
                typeName = "STRING";
                defaultValue = """Land_DirtPatch_01_4x4_F""";
                category = "Recondo_Wiretap_Rope";
            };
            
            // ========================================
            // TEXT SETTINGS
            // ========================================
            class TextPlaced {
                displayName = "TEXT - Wiretap Placed";
                tooltip = "Hint shown when wiretap is placed.";
                control = "Edit";
                property = "Recondo_Wiretap_TextPlaced";
                expression = "_this setVariable ['textplaced', _value, true];";
                typeName = "STRING";
                defaultValue = """Wiretap placed""";
                category = "Recondo_Wiretap_Text";
            };
            class TextRetrieved {
                displayName = "Wiretap Retrieved";
                tooltip = "Hint shown when wiretap is retrieved.";
                control = "Edit";
                property = "Recondo_Wiretap_TextRetrieved";
                expression = "_this setVariable ['textretrieved', _value, true];";
                typeName = "STRING";
                defaultValue = """Wiretap retrieved - return intel to base""";
                category = "Recondo_Wiretap_Text";
            };
            class TextCancelled {
                displayName = "Action Cancelled";
                tooltip = "Hint shown when action is cancelled.";
                control = "Edit";
                property = "Recondo_Wiretap_TextCancelled";
                expression = "_this setVariable ['textcancelled', _value, true];";
                typeName = "STRING";
                defaultValue = """Wiretap cancelled""";
                category = "Recondo_Wiretap_Text";
            };
            class TextWaitTime {
                displayName = "Wait Time Format";
                tooltip = "Format for time remaining hint. Use %1 for seconds.";
                control = "Edit";
                property = "Recondo_Wiretap_TextWaitTime";
                expression = "_this setVariable ['textwaittime', _value, true];";
                typeName = "STRING";
                defaultValue = """Wait %1 seconds""";
                category = "Recondo_Wiretap_Text";
            };
            class ActionPlaceWiretap {
                displayName = "Action: Place Wiretap";
                tooltip = "ACE action text for placing wiretap.";
                control = "Edit";
                property = "Recondo_Wiretap_ActionPlace";
                expression = "_this setVariable ['actionplace', _value, true];";
                typeName = "STRING";
                defaultValue = """Place Wiretap""";
                category = "Recondo_Wiretap_Text";
            };
            class ActionRetrieveWiretap {
                displayName = "Action: Retrieve Wiretap";
                tooltip = "ACE action text for retrieving wiretap.";
                control = "Edit";
                property = "Recondo_Wiretap_ActionRetrieve";
                expression = "_this setVariable ['actionretrieve', _value, true];";
                typeName = "STRING";
                defaultValue = """Retrieve Wiretap""";
                category = "Recondo_Wiretap_Text";
            };
            class ActionCheckTime {
                displayName = "Action: Check Time";
                tooltip = "ACE action text for checking time remaining.";
                control = "Edit";
                property = "Recondo_Wiretap_ActionCheckTime";
                expression = "_this setVariable ['actionchecktime', _value, true];";
                typeName = "STRING";
                defaultValue = """Check Time Until Retrieval""";
                category = "Recondo_Wiretap_Text";
            };
            class TextClimbingUp {
                displayName = "Progress: Climbing Up";
                tooltip = "Progress bar text for climbing up.";
                control = "Edit";
                property = "Recondo_Wiretap_TextClimbingUp";
                expression = "_this setVariable ['textclimbingup', _value, true];";
                typeName = "STRING";
                defaultValue = """Climbing pole""";
                category = "Recondo_Wiretap_Text";
            };
            class TextClimbingDown {
                displayName = "Progress: Climbing Down";
                tooltip = "Progress bar text for climbing down.";
                control = "Edit";
                property = "Recondo_Wiretap_TextClimbingDown";
                expression = "_this setVariable ['textclimbingdown', _value, true];";
                typeName = "STRING";
                defaultValue = """Climbing down""";
                category = "Recondo_Wiretap_Text";
            };
            class TextPlacing {
                displayName = "Progress: Placing";
                tooltip = "Progress bar text for placing wiretap.";
                control = "Edit";
                property = "Recondo_Wiretap_TextPlacing";
                expression = "_this setVariable ['textplacing', _value, true];";
                typeName = "STRING";
                defaultValue = """Placing wiretap""";
                category = "Recondo_Wiretap_Text";
            };
            class TextRetrieving {
                displayName = "Progress: Retrieving";
                tooltip = "Progress bar text for retrieving wiretap.";
                control = "Edit";
                property = "Recondo_Wiretap_TextRetrieving";
                expression = "_this setVariable ['textretrieving', _value, true];";
                typeName = "STRING";
                defaultValue = """Retrieving wiretap""";
                category = "Recondo_Wiretap_Text";
            };
            
            // ========================================
            // CLASS RESTRICTIONS
            // ========================================
            class EnableClassRestriction {
                displayName = "RESTRICTIONS - Enable Class Restriction";
                tooltip = "When enabled, only players with specified unit classnames can place and retrieve wiretaps.";
                control = "Checkbox";
                property = "Recondo_Wiretap_EnableClassRestriction";
                expression = "_this setVariable ['enableclassrestriction', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_Wiretap_Restrictions";
            };
            class AllowedClassnames {
                displayName = "Allowed Unit Classnames";
                tooltip = "Unit classnames that can place/retrieve wiretaps. One per line or comma-separated. Only used if class restriction is enabled.";
                control = "EditCodeMulti5";
                property = "Recondo_Wiretap_AllowedClassnames";
                expression = "_this setVariable ['allowedclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_Wiretap_Restrictions";
            };
            class RestrictedText {
                displayName = "Restricted Message";
                tooltip = "Hint shown when a player without the required classname tries to use wiretap.";
                control = "Edit";
                property = "Recondo_Wiretap_RestrictedText";
                expression = "_this setVariable ['restrictedtext', _value, true];";
                typeName = "STRING";
                defaultValue = """Only specialized personnel can operate wiretaps""";
                category = "Recondo_Wiretap_Restrictions";
            };
            
            // ========================================
            // DEBUG SETTINGS
            // ========================================
            class DebugLogging {
                displayName = "DEBUG - Enable Debug Logging";
                tooltip = "Enable detailed logging to RPT file for troubleshooting.";
                control = "Checkbox";
                property = "Recondo_Wiretap_DebugLogging";
                expression = "_this setVariable ['debuglogging', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_Wiretap_Debug";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    //==========================================
    // OBJECTIVE - DESTROY MODULE
    // Spawns destroyable objectives at markers
    //==========================================
    class Recondo_Module_ObjectiveDestroy: Module_F {
        scope = 2;
        displayName = "Objective - Destroy";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleObjectiveDestroy";
        functionPriority = 4;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 0;
        canSetArea = 0;
        
        class ModuleDescription: ModuleDescription {
            description = "Spawns destroyable objectives using compositions at invisible map markers. Integrates with Intel system for location reveals. Supports persistence across mission restarts.";
            sync[] = {"Recondo_Module_Intel"};
        };
        
        class Attributes: AttributesBase {
            
            // ========================================
            // GENERAL SETTINGS
            // ========================================
            class ObjectiveName {
                displayName = "GENERAL - Objective Name";
                tooltip = "Name of this objective type (e.g., 'Weapons Cache', 'Radio Station').";
                control = "Edit";
                property = "Recondo_ObjDestroy_Name";
                expression = "_this setVariable ['objectivename', _value, true];";
                typeName = "STRING";
                defaultValue = """Weapons Cache""";
                category = "Recondo_ObjDestroy_General";
            };
            class ObjectiveDescription {
                displayName = "Objective Description";
                tooltip = "Description of this objective type (used for future briefing/intel systems).";
                control = "EditMulti5";
                property = "Recondo_ObjDestroy_Description";
                expression = "_this setVariable ['objectivedesc', _value, true];";
                typeName = "STRING";
                defaultValue = """A hidden cache containing enemy weapons and supplies.""";
                category = "Recondo_ObjDestroy_General";
            };
            class IntelBoardCategoryName {
                displayName = "Intel Board Category Name";
                tooltip = "Custom category name displayed on the Intel Board. Leave blank for default ('DESTROY OBJECTIVES').";
                control = "Edit";
                property = "Recondo_ObjDestroy_IntelBoardCategoryName";
                expression = "_this setVariable ['intelboardcategoryname', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_ObjDestroy_General";
            };
            class MarkerPrefix {
                displayName = "Marker Prefix";
                tooltip = "Prefix for invisible map markers. Example: 'CACHE_' will find CACHE_1, CACHE_2, etc.";
                control = "Edit";
                property = "Recondo_ObjDestroy_MarkerPrefix";
                expression = "_this setVariable ['markerprefix', _value, true];";
                typeName = "STRING";
                defaultValue = """CACHE_""";
                category = "Recondo_ObjDestroy_General";
            };
            class SpawnPercentage {
                displayName = "Spawn Percentage";
                tooltip = "Percentage of available markers that will have objectives (0-100%).";
                control = "Slider";
                property = "Recondo_ObjDestroy_SpawnPercentage";
                expression = "_this setVariable ['spawnpercentage', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.5";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_ObjDestroy_General";
            };
            
            // ========================================
            // COMPOSITION POOL (Mod Bundled)
            // ========================================
            class Comp_Cache1 {
                displayName = "Cache 1";
                tooltip = "Enable this composition in the selection pool (Cache_1.sqe / Cache_1_destroyed.sqe).";
                control = "Checkbox";
                property = "Recondo_ObjDestroy_Comp_Cache1";
                expression = "_this setVariable ['comp_cache1', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ObjDestroy_CompPool";
            };
            class Comp_Cache2 {
                displayName = "Cache 2";
                tooltip = "Enable this composition in the selection pool (Cache_2.sqe / Cache_2_destroyed.sqe).";
                control = "Checkbox";
                property = "Recondo_ObjDestroy_Comp_Cache2";
                expression = "_this setVariable ['comp_cache2', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ObjDestroy_CompPool";
            };
            class Comp_Cache3 {
                displayName = "Cache 3";
                tooltip = "Enable this composition in the selection pool (Cache_3.sqe / Cache_3_destroyed.sqe).";
                control = "Checkbox";
                property = "Recondo_ObjDestroy_Comp_Cache3";
                expression = "_this setVariable ['comp_cache3', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ObjDestroy_CompPool";
            };
            class Comp_Cache4 {
                displayName = "Cache 4";
                tooltip = "Enable this composition in the selection pool (Cache_4.sqe / Cache_4_destroyed.sqe).";
                control = "Checkbox";
                property = "Recondo_ObjDestroy_Comp_Cache4";
                expression = "_this setVariable ['comp_cache4', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ObjDestroy_CompPool";
            };
            class Comp_Cache5 {
                displayName = "Cache 5";
                tooltip = "Enable this composition in the selection pool (Cache_5.sqe / Cache_5_destroyed.sqe).";
                control = "Checkbox";
                property = "Recondo_ObjDestroy_Comp_Cache5";
                expression = "_this setVariable ['comp_cache5', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ObjDestroy_CompPool";
            };
            class Comp_AACache1 {
                displayName = "AA Cache";
                tooltip = "Enable this composition in the selection pool (AAcache1.sqe / AAcache1_destroyed.sqe).";
                control = "Checkbox";
                property = "Recondo_ObjDestroy_Comp_AACache1";
                expression = "_this setVariable ['comp_aacache1', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ObjDestroy_CompPool";
            };
            
            // ========================================
            // CUSTOM COMPOSITIONS
            // ========================================
            class CustomCompositionPath {
                displayName = "CUSTOM - Folder Path";
                tooltip = "Path to compositions folder relative to mission root for custom compositions.";
                control = "Edit";
                property = "Recondo_ObjDestroy_CustomCompPath";
                expression = "_this setVariable ['customcomppath', _value, true];";
                typeName = "STRING";
                defaultValue = """compositions""";
                category = "Recondo_ObjDestroy_CompCustom";
            };
            class CustomActiveCompositions {
                displayName = "CUSTOM - Active Compositions";
                tooltip = "Names of your custom composition files (with or without .sqe extension), one per line or comma-separated. Random selection per objective.";
                control = "EditCodeMulti5";
                property = "Recondo_ObjDestroy_CustomActiveComps";
                expression = "_this setVariable ['customactivecomps', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_ObjDestroy_CompCustom";
            };
            class CustomDestroyedCompositions {
                displayName = "CUSTOM - Destroyed Compositions";
                tooltip = "Names of custom destroyed variant composition files (with or without .sqe extension), one per line or comma-separated. Leave empty to spawn nothing after destruction.";
                control = "EditCodeMulti5";
                property = "Recondo_ObjDestroy_CustomDestroyedComps";
                expression = "_this setVariable ['customdestroyedcomps', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_ObjDestroy_CompCustom";
            };
            class ClearRadius {
                displayName = "Terrain Clear Radius";
                tooltip = "Radius in meters to clear terrain objects around composition spawn point.";
                control = "Edit";
                property = "Recondo_ObjDestroy_ClearRadius";
                expression = "_this setVariable ['clearradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """25""";
                category = "Recondo_ObjDestroy_CompCustom";
            };
            
            // ========================================
            // TARGET SETTINGS
            // ========================================
            class TargetClassname {
                displayName = "TARGET - Object Classname";
                tooltip = "Classname of the object to destroy. Must exist in your composition. First object matching this classname will be the target.";
                control = "Edit";
                property = "Recondo_ObjDestroy_TargetClassname";
                expression = "_this setVariable ['targetclassname', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_ObjDestroy_Target";
            };
            class DisableSimulation {
                displayName = "TARGET - Disable Simulation";
                tooltip = "Disable simulation on composition objects (except the destroyable target). Improves performance but objects won't react to physics/explosions.";
                control = "Checkbox";
                property = "Recondo_ObjDestroy_DisableSimulation";
                expression = "_this setVariable ['disablesimulation', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_ObjDestroy_Target";
            };
            
            // ========================================
            // SPAWNING SETTINGS
            // ========================================
            class SpawnMode {
                displayName = "SPAWNING - Spawn Mode";
                tooltip = "When to spawn compositions: Immediate (mission start) or Proximity (when players approach).";
                control = "Combo";
                property = "Recondo_ObjDestroy_SpawnMode";
                expression = "_this setVariable ['spawnmode', _value, true];";
                typeName = "NUMBER";
                defaultValue = "1";
                category = "Recondo_ObjDestroy_Spawning";
                class Values {
                    class Immediate { name = "Immediate (Mission Start)"; value = 0; };
                    class Proximity { name = "Proximity Trigger"; value = 1; };
                };
            };
            class TriggerRadius {
                displayName = "Trigger Radius";
                tooltip = "Radius in meters for proximity spawn trigger (only used if Spawn Mode is Proximity).";
                control = "Edit";
                property = "Recondo_ObjDestroy_TriggerRadius";
                expression = "_this setVariable ['triggerradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """500""";
                category = "Recondo_ObjDestroy_Spawning";
            };
            class TriggerSide {
                displayName = "Trigger Side";
                tooltip = "Which side triggers the spawn.";
                control = "Combo";
                property = "Recondo_ObjDestroy_TriggerSide";
                expression = "_this setVariable ['triggerside', _value, true];";
                typeName = "NUMBER";
                defaultValue = "1";
                category = "Recondo_ObjDestroy_Spawning";
                class Values {
                    class East { name = "OPFOR (East)"; value = 0; };
                    class West { name = "BLUFOR (West)"; value = 1; };
                    class Guer { name = "Independent"; value = 2; };
                    class Any { name = "Any Side"; value = 3; };
                };
            };
            class SimulationDistance {
                displayName = "Simulation Distance";
                tooltip = "Distance at which simulation is enabled for spawned AI and objects. Entities start with simulation disabled and are enabled when players approach. Set to 0 to disable this feature (entities always simulated).";
                control = "Edit";
                property = "Recondo_ObjDestroy_SimulationDistance";
                expression = "_this setVariable ['simulationdistance', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """1000""";
                category = "Recondo_ObjDestroy_Spawning";
            };
            
            // ========================================
            // AI SENTRIES SETTINGS
            // ========================================
            class SentryClassnames {
                displayName = "SENTRIES - Unit Classnames";
                tooltip = "Comma-separated classnames for sentry units.";
                control = "EditMulti5";
                property = "Recondo_ObjDestroy_SentryClassnames";
                expression = "_this setVariable ['sentryclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_ObjDestroy_AISentries";
            };
            class SentryMinCount {
                displayName = "Min Sentries";
                tooltip = "Minimum number of sentry units to spawn.";
                control = "Edit";
                property = "Recondo_ObjDestroy_SentryMinCount";
                expression = "_this setVariable ['sentrymincount', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """2""";
                category = "Recondo_ObjDestroy_AISentries";
            };
            class SentryMaxCount {
                displayName = "Max Sentries";
                tooltip = "Maximum number of sentry units to spawn.";
                control = "Edit";
                property = "Recondo_ObjDestroy_SentryMaxCount";
                expression = "_this setVariable ['sentrymaxcount', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """4""";
                category = "Recondo_ObjDestroy_AISentries";
            };
            class SentrySide {
                displayName = "Sentry Side";
                tooltip = "Which side the sentry AI belongs to.";
                control = "Combo";
                property = "Recondo_ObjDestroy_SentrySide";
                expression = "_this setVariable ['sentryside', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0";
                category = "Recondo_ObjDestroy_AISentries";
                class Values {
                    class East { name = "OPFOR (East)"; value = 0; };
                    class West { name = "BLUFOR (West)"; value = 1; };
                    class Guer { name = "Independent"; value = 2; };
                };
            };
            
            // ========================================
            // AI PATROLS SETTINGS
            // ========================================
            class PatrolClassnames {
                displayName = "PATROLS - Unit Classnames";
                tooltip = "Comma-separated classnames for patrol units.";
                control = "EditMulti5";
                property = "Recondo_ObjDestroy_PatrolClassnames";
                expression = "_this setVariable ['patrolclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_ObjDestroy_AIPatrols";
            };
            class PatrolCount {
                displayName = "Number of Patrols";
                tooltip = "Number of patrol groups to spawn.";
                control = "Edit";
                property = "Recondo_ObjDestroy_PatrolCount";
                expression = "_this setVariable ['patrolcount', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """1""";
                category = "Recondo_ObjDestroy_AIPatrols";
            };
            class PatrolMinSize {
                displayName = "Min Group Size";
                tooltip = "Minimum units per patrol group.";
                control = "Edit";
                property = "Recondo_ObjDestroy_PatrolMinSize";
                expression = "_this setVariable ['patrolminsize', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """2""";
                category = "Recondo_ObjDestroy_AIPatrols";
            };
            class PatrolMaxSize {
                displayName = "Max Group Size";
                tooltip = "Maximum units per patrol group.";
                control = "Edit";
                property = "Recondo_ObjDestroy_PatrolMaxSize";
                expression = "_this setVariable ['patrolmaxsize', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """4""";
                category = "Recondo_ObjDestroy_AIPatrols";
            };
            class PatrolRadius {
                displayName = "Patrol Radius";
                tooltip = "Radius in meters for patrol waypoints around the objective.";
                control = "Edit";
                property = "Recondo_ObjDestroy_PatrolRadius";
                expression = "_this setVariable ['patrolradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """50""";
                category = "Recondo_ObjDestroy_AIPatrols";
            };
            class PatrolFormation {
                displayName = "Patrol Formation";
                tooltip = "Formation for patrol groups.";
                control = "Combo";
                property = "Recondo_ObjDestroy_PatrolFormation";
                expression = "_this setVariable ['patrolformation', _value, true];";
                typeName = "STRING";
                defaultValue = """WEDGE""";
                category = "Recondo_ObjDestroy_AIPatrols";
                class Values {
                    class Wedge { name = "Wedge"; value = "WEDGE"; };
                    class Column { name = "Column"; value = "COLUMN"; };
                    class File { name = "File"; value = "FILE"; };
                    class Line { name = "Line"; value = "LINE"; };
                    class Stag { name = "Staggered Column"; value = "STAG COLUMN"; };
                    class Vee { name = "Vee"; value = "VEE"; };
                    class Diamond { name = "Diamond"; value = "DIAMOND"; };
                };
            };
            
            // ========================================
            // INTEL SETTINGS
            // ========================================
            class IntelWeight {
                displayName = "INTEL - Reveal Weight";
                tooltip = "Weight for intel reveal priority (1-10). Lower = easier to reveal. Only applies when synced to Intel module.";
                control = "Slider";
                property = "Recondo_ObjDestroy_IntelWeight";
                expression = "_this setVariable ['intelweight', _value, true];";
                typeName = "NUMBER";
                defaultValue = "5";
                sliderRange[] = {1, 10};
                sliderStep = 1;
                category = "Recondo_ObjDestroy_Intel";
            };
            class IntelRevealMessagesDoc {
                displayName = "Intel Reveal Messages (Documents)";
                tooltip = "Messages shown when intel from documents reveals this objective. One per line. Placeholders: %GRID%, %NAME%, %OBJECTIVE%. Random selection. Leave blank for default.";
                control = "EditCodeMulti5";
                property = "Recondo_ObjDestroy_IntelRevealMessagesDoc";
                expression = "_this setVariable ['intelrevealmessagesdoc', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_ObjDestroy_Intel";
            };
            class IntelRevealMessagesPOW {
                displayName = "Intel Reveal Messages (POW)";
                tooltip = "Messages shown when intel from POW interrogation reveals this objective. One per line. Placeholders: %GRID%, %NAME%, %OBJECTIVE%. Random selection. Leave blank for default.";
                control = "EditCodeMulti5";
                property = "Recondo_ObjDestroy_IntelRevealMessagesPOW";
                expression = "_this setVariable ['intelrevealmessagespow', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_ObjDestroy_Intel";
            };
            
            // ========================================
            // DEBUG SETTINGS
            // ========================================
            class DebugLogging {
                displayName = "DEBUG - Enable Debug Logging";
                tooltip = "Enable detailed logging to RPT file for troubleshooting.";
                control = "Checkbox";
                property = "Recondo_ObjDestroy_DebugLogging";
                expression = "_this setVariable ['debuglogging', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ObjDestroy_Debug";
            };
            class DebugMarkers {
                displayName = "Debug Markers";
                tooltip = "Show debug markers on map for objectives.";
                control = "Checkbox";
                property = "Recondo_ObjDestroy_DebugMarkers";
                expression = "_this setVariable ['debugmarkers', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ObjDestroy_Debug";
            };
            
            // ========================================
            // NIGHT LIGHTS
            // ========================================
            class EnableNightLights {
                displayName = "NIGHT LIGHTS - Enable Night Lights";
                tooltip = "Enable warm lights inside buildings at night. Lights turn on automatically when dark (sunOrMoon < 0.5).";
                control = "Checkbox";
                property = "Recondo_ObjDestroy_EnableNightLights";
                expression = "_this setVariable ['enablenightlights', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_ObjDestroy_NightLights";
            };
            
            // ========================================
            // SMELL HINTS
            // ========================================
            class EnableSmellHints {
                displayName = "Enable Smell Hints";
                tooltip = "Shows atmospheric text hints when players approach objective locations.";
                control = "Checkbox";
                property = "Recondo_ObjDestroy_EnableSmellHints";
                expression = "_this setVariable ['enablesmellhints', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_ObjDestroy_SmellHints";
            };
            class SmellHintRadius {
                displayName = "Smell Hint Radius";
                tooltip = "Distance (meters) at which players detect smells from locations.";
                control = "Edit";
                property = "Recondo_ObjDestroy_SmellHintRadius";
                expression = "_this setVariable ['smellhintradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """200""";
                category = "Recondo_ObjDestroy_SmellHints";
            };
            class SmellHintMessages {
                displayName = "Smell Hint Messages";
                tooltip = "Comma-separated list of atmospheric messages. One is randomly chosen per trigger.";
                control = "EditMulti5";
                property = "Recondo_ObjDestroy_SmellHintMessages";
                expression = "_this setVariable ['smellhintmessages', _value, true];";
                typeName = "STRING";
                defaultValue = """The smell of oil and gunpowder hangs in the air...,A faint chemical odor drifts on the breeze...,You catch a whiff of ammunition and weapon lubricant...,Something metallic taints the air nearby.""";
                category = "Recondo_ObjDestroy_SmellHints";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    //==========================================
    // TERMINAL MODULE
    // Admin interface for mission management
    //==========================================
    class Recondo_Module_Terminal: Module_F {
        scope = 2;
        displayName = "Terminal";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleTerminal";
        functionPriority = 10;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 0;
        canSetArea = 0;
        
        class ModuleDescription: ModuleDescription {
            description = "Admin terminal for viewing mission status and managing persistence. Sync to an object to create the terminal interface. Sync to Persistence module for reset functionality.";
            sync[] = {"Recondo_Module_Persistence", "LocationArea_F"};
        };
        
        class Attributes: AttributesBase {
            
            // ========================================
            // GENERAL SETTINGS
            // ========================================
            class TerminalName {
                displayName = "GENERAL - Terminal Name";
                tooltip = "Display name for the terminal in ACE interactions.";
                control = "Edit";
                property = "Recondo_Terminal_Name";
                expression = "_this setVariable ['terminalname', _value, true];";
                typeName = "STRING";
                defaultValue = """Command Terminal""";
                category = "Recondo_Terminal_General";
            };
            
            // ========================================
            // DEBUG SETTINGS
            // ========================================
            class DebugLogging {
                displayName = "DEBUG - Enable Debug Logging";
                tooltip = "Enable detailed logging to RPT file for troubleshooting.";
                control = "Checkbox";
                property = "Recondo_Terminal_DebugLogging";
                expression = "_this setVariable ['debuglogging', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_Terminal_Debug";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    //==========================================
    // OBJECTIVE HUB & SUBS MODULE
    // Main objective with satellite sub-sites
    //==========================================
    class Recondo_Module_ObjectiveHubSubs: Module_F {
        scope = 2;
        displayName = "Objective - Hub & Subs";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleObjectiveHubSubs";
        functionPriority = 4;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 0;
        canSetArea = 0;
        
        class ModuleDescription: ModuleDescription {
            description = "Creates destroyable hub objectives with surrounding sub-site defensive positions. Sub-sites use letter suffixes (e.g., CACHE_1a, CACHE_1b). Sync to Intel module for intel integration.";
            sync[] = {"Recondo_Module_Intel"};
        };
        
        class Attributes: AttributesBase {
            
            // ========================================
            // GENERAL SETTINGS
            // ========================================
            class ObjectiveName {
                displayName = "GENERAL - Objective Name";
                tooltip = "Display name for this objective type (e.g., 'Command Post', 'Supply Depot').";
                control = "Edit";
                property = "Recondo_HubSubs_ObjectiveName";
                expression = "_this setVariable ['objectivename', _value, true];";
                typeName = "STRING";
                defaultValue = """Command Post""";
                category = "Recondo_HubSubs_General";
            };
            class ObjectiveDescription {
                displayName = "Objective Description";
                tooltip = "Description shown in objective briefings.";
                control = "EditMulti5";
                property = "Recondo_HubSubs_ObjectiveDescription";
                expression = "_this setVariable ['objectivedescription', _value, true];";
                typeName = "STRING";
                defaultValue = """Destroy the enemy command post.""";
                category = "Recondo_HubSubs_General";
            };
            class IntelBoardCategoryName {
                displayName = "Intel Board Category Name";
                tooltip = "Custom category name displayed on the Intel Board. Leave blank for default ('HUB & SUBS').";
                control = "Edit";
                property = "Recondo_HubSubs_IntelBoardCategoryName";
                expression = "_this setVariable ['intelboardcategoryname', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_HubSubs_General";
            };
            class MarkerPrefix {
                displayName = "Marker Prefix";
                tooltip = "Prefix for invisible map markers. Example: 'HUB_' will find HUB_1, HUB_2, etc. Sub-sites use HUB_1a, HUB_1b, etc.";
                control = "Edit";
                property = "Recondo_HubSubs_MarkerPrefix";
                expression = "_this setVariable ['markerprefix', _value, true];";
                typeName = "STRING";
                defaultValue = """HUB_""";
                category = "Recondo_HubSubs_General";
            };
            class ActivePercentage {
                displayName = "Active Percentage";
                tooltip = "Percentage of hub markers that will be active objectives (0-100%).";
                control = "Slider";
                property = "Recondo_HubSubs_ActivePercentage";
                expression = "_this setVariable ['activepercentage', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.5";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_HubSubs_General";
            };
            
            // ========================================
            // HUB COMPOSITION POOL (Mod Bundled)
            // ========================================
            class Comp_OneRow {
                displayName = "One Row";
                tooltip = "Enable this composition (comp_one_row.sqe / comp_one_row_destroyed.sqe).";
                control = "Checkbox";
                property = "Recondo_HubSubs_Comp_OneRow";
                expression = "_this setVariable ['comp_one_row', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_HubSubs_CompPool";
            };
            class Comp_TwoRows {
                displayName = "Two Rows";
                tooltip = "Enable this composition (comp_two_rows.sqe / comp_two_rows_destroyed.sqe).";
                control = "Checkbox";
                property = "Recondo_HubSubs_Comp_TwoRows";
                expression = "_this setVariable ['comp_two_rows', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_HubSubs_CompPool";
            };
            class Comp_GatesTents {
                displayName = "Gates & Tents";
                tooltip = "Enable this composition (comp_gates_tents.sqe / comp_gates_tents_destroyed.sqe).";
                control = "Checkbox";
                property = "Recondo_HubSubs_Comp_GatesTents";
                expression = "_this setVariable ['comp_gates_tents', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_HubSubs_CompPool";
            };
            class Comp_TwoHuts {
                displayName = "Two Huts";
                tooltip = "Enable this composition (comp_two_huts.sqe / comp_two_huts_destroyed.sqe).";
                control = "Checkbox";
                property = "Recondo_HubSubs_Comp_TwoHuts";
                expression = "_this setVariable ['comp_two_huts', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_HubSubs_CompPool";
            };
            class Comp_Tower {
                displayName = "Tower";
                tooltip = "Enable this composition (comp_tower.sqe / comp_tower_destroyed.sqe).";
                control = "Checkbox";
                property = "Recondo_HubSubs_Comp_Tower";
                expression = "_this setVariable ['comp_tower', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_HubSubs_CompPool";
            };
            class Comp_MapTents {
                displayName = "Map Tents";
                tooltip = "Enable this composition (comp_map_tents.sqe / comp_map_tents_destroyed.sqe).";
                control = "Checkbox";
                property = "Recondo_HubSubs_Comp_MapTents";
                expression = "_this setVariable ['comp_map_tents', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_HubSubs_CompPool";
            };
            class Comp_HVTBASE1 {
                displayName = "HVT Base 1";
                tooltip = "Enable this composition (HVTBASE_comp_1.sqe - no destroyed variant).";
                control = "Checkbox";
                property = "Recondo_HubSubs_Comp_HVTBASE1";
                expression = "_this setVariable ['comp_hvtbase_1', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_HubSubs_CompPool";
            };
            class Comp_HVTBASE2 {
                displayName = "HVT Base 2";
                tooltip = "Enable this composition (HVTBASE_comp_2.sqe - no destroyed variant).";
                control = "Checkbox";
                property = "Recondo_HubSubs_Comp_HVTBASE2";
                expression = "_this setVariable ['comp_hvtbase_2', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_HubSubs_CompPool";
            };
            class Comp_HVTBASE3 {
                displayName = "HVT Base 3";
                tooltip = "Enable this composition (HVTBASE_comp_3.sqe - no destroyed variant).";
                control = "Checkbox";
                property = "Recondo_HubSubs_Comp_HVTBASE3";
                expression = "_this setVariable ['comp_hvtbase_3', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_HubSubs_CompPool";
            };
            
            // ========================================
            // CUSTOM COMPOSITIONS
            // ========================================
            class CustomCompositionPath {
                displayName = "CUSTOM - Folder Path";
                tooltip = "Folder path relative to mission root containing your custom composition files.";
                control = "Edit";
                property = "Recondo_HubSubs_CustomCompPath";
                expression = "_this setVariable ['customcomppath', _value, true];";
                typeName = "STRING";
                defaultValue = """compositions""";
                category = "Recondo_HubSubs_CompCustom";
            };
            class CustomActiveCompositions {
                displayName = "CUSTOM - Active Compositions";
                tooltip = "Your custom composition names for active hubs (with or without .sqe extension). One per line or comma-separated.";
                control = "EditCodeMulti5";
                property = "Recondo_HubSubs_CustomActiveComps";
                expression = "_this setVariable ['customactivecomps', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_HubSubs_CompCustom";
            };
            class CustomDestroyedCompositions {
                displayName = "CUSTOM - Destroyed Compositions";
                tooltip = "Your custom composition names for destroyed hubs (with or without .sqe extension). One per line or comma-separated.";
                control = "EditCodeMulti5";
                property = "Recondo_HubSubs_CustomDestroyedComps";
                expression = "_this setVariable ['customdestroyedcomps', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_HubSubs_CompCustom";
            };
            class ClearRadius {
                displayName = "Terrain Clear Radius";
                tooltip = "Radius in meters to hide terrain objects around the hub.";
                control = "Edit";
                property = "Recondo_HubSubs_ClearRadius";
                expression = "_this setVariable ['clearradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """30""";
                category = "Recondo_HubSubs_CompCustom";
            };
            class DisableSimulation {
                displayName = "Disable Simulation";
                tooltip = "Disable simulation on hub composition objects (except the destroyable target). Improves performance but objects won't react to physics/explosions. Does NOT affect sub-sites.";
                control = "Checkbox";
                property = "Recondo_HubSubs_DisableSimulation";
                expression = "_this setVariable ['disablesimulation', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_HubSubs_CompCustom";
            };
            
            // ========================================
            // HUB TARGET SETTINGS
            // ========================================
            class TargetClassname {
                displayName = "HUB TARGET - Target Classname";
                tooltip = "Classname of the object in the composition that must be destroyed to complete the objective.";
                control = "Edit";
                property = "Recondo_HubSubs_TargetClassname";
                expression = "_this setVariable ['targetclassname', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_HubSubs_HubTarget";
            };
            
            // ========================================
            // HUB SPAWNING SETTINGS
            // ========================================
            class HubSpawnMode {
                displayName = "HUB SPAWNING - Spawn Mode";
                tooltip = "How/when to spawn hub compositions.";
                control = "Combo";
                property = "Recondo_HubSubs_HubSpawnMode";
                expression = "_this setVariable ['hubspawnmode', _value, true];";
                typeName = "STRING";
                defaultValue = """proximity""";
                category = "Recondo_HubSubs_HubSpawning";
                class Values {
                    class Proximity { name = "Proximity Trigger"; value = "proximity"; };
                    class Immediate { name = "Immediate (Mission Start)"; value = "immediate"; };
                };
            };
            class HubTriggerRadius {
                displayName = "Hub Trigger Radius";
                tooltip = "Radius in meters for proximity trigger activation.";
                control = "Edit";
                property = "Recondo_HubSubs_HubTriggerRadius";
                expression = "_this setVariable ['hubtriggerradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """1500""";
                category = "Recondo_HubSubs_HubSpawning";
            };
            class HubTriggerSide {
                displayName = "Hub Trigger Side";
                tooltip = "Side that triggers hub spawning.";
                control = "Combo";
                property = "Recondo_HubSubs_HubTriggerSide";
                expression = "_this setVariable ['hubtriggerside', _value, true];";
                typeName = "STRING";
                defaultValue = """WEST""";
                category = "Recondo_HubSubs_HubSpawning";
                class Values {
                    class West { name = "BLUFOR"; value = "WEST"; };
                    class East { name = "OPFOR"; value = "EAST"; };
                    class Guer { name = "Independent"; value = "GUER"; };
                    class Civ { name = "Civilian"; value = "CIV"; };
                    class Any { name = "Any Player"; value = "ANY"; };
                };
            };
            class SimulationDistance {
                displayName = "Simulation Distance";
                tooltip = "Distance at which simulation is enabled for spawned AI and objects. Entities start with simulation disabled and are enabled when players approach. Set to 0 to disable this feature (entities always simulated).";
                control = "Edit";
                property = "Recondo_HubSubs_SimulationDistance";
                expression = "_this setVariable ['simulationdistance', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """1000""";
                category = "Recondo_HubSubs_HubSpawning";
            };
            
            // ========================================
            // HUB AI SETTINGS
            // ========================================
            class HubAISide {
                displayName = "HUB AI - AI Side";
                tooltip = "Side of AI units at the hub.";
                control = "Combo";
                property = "Recondo_HubSubs_HubAISide";
                expression = "_this setVariable ['hubaiside', _value, true];";
                typeName = "STRING";
                defaultValue = """EAST""";
                category = "Recondo_HubSubs_HubAI";
                class Values {
                    class East { name = "OPFOR"; value = "EAST"; };
                    class West { name = "BLUFOR"; value = "WEST"; };
                    class Guer { name = "Independent"; value = "GUER"; };
                };
            };
            class HubSentryClassnames {
                displayName = "Hub Sentry Classnames";
                tooltip = "Unit classnames for hub sentries. One per line or comma-separated.";
                control = "EditCodeMulti5";
                property = "Recondo_HubSubs_HubSentryClassnames";
                expression = "_this setVariable ['hubsentryclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_HubSubs_HubAI";
            };
            class HubSentryMin {
                displayName = "Hub Sentry Min";
                tooltip = "Minimum number of sentries at hub.";
                control = "Edit";
                property = "Recondo_HubSubs_HubSentryMin";
                expression = "_this setVariable ['hubsentrymin', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """2""";
                category = "Recondo_HubSubs_HubAI";
            };
            class HubSentryMax {
                displayName = "Hub Sentry Max";
                tooltip = "Maximum number of sentries at hub.";
                control = "Edit";
                property = "Recondo_HubSubs_HubSentryMax";
                expression = "_this setVariable ['hubsentrymax', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """4""";
                category = "Recondo_HubSubs_HubAI";
            };
            // ========================================
            // SECURITY PATROL SETTINGS
            // ========================================
            class SecurityPatrolCount {
                displayName = "SECURITY PATROL - Patrol Groups";
                tooltip = "Number of security patrol groups that patrol between hub and sub-sites.";
                control = "Edit";
                property = "Recondo_HubSubs_SecurityPatrolCount";
                expression = "_this setVariable ['securitypatrolcount', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """1""";
                category = "Recondo_HubSubs_SecurityPatrol";
            };
            class SecurityPatrolMin {
                displayName = "Patrol Min Size";
                tooltip = "Minimum units per security patrol group.";
                control = "Edit";
                property = "Recondo_HubSubs_SecurityPatrolMin";
                expression = "_this setVariable ['securitypatrolmin', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """2""";
                category = "Recondo_HubSubs_SecurityPatrol";
            };
            class SecurityPatrolMax {
                displayName = "Patrol Max Size";
                tooltip = "Maximum units per security patrol group.";
                control = "Edit";
                property = "Recondo_HubSubs_SecurityPatrolMax";
                expression = "_this setVariable ['securitypatrolmax', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """4""";
                category = "Recondo_HubSubs_SecurityPatrol";
            };
            class SecurityPatrolPauseMin {
                displayName = "Pause Min (seconds)";
                tooltip = "Minimum time in seconds to pause at each location.";
                control = "Edit";
                property = "Recondo_HubSubs_SecurityPatrolPauseMin";
                expression = "_this setVariable ['securitypatrolpausemin', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """30""";
                category = "Recondo_HubSubs_SecurityPatrol";
            };
            class SecurityPatrolPauseMax {
                displayName = "Pause Max (seconds)";
                tooltip = "Maximum time in seconds to pause at each location.";
                control = "Edit";
                property = "Recondo_HubSubs_SecurityPatrolPauseMax";
                expression = "_this setVariable ['securitypatrolpausemax', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """60""";
                category = "Recondo_HubSubs_SecurityPatrol";
            };
            class SecurityPatrolBehaviour {
                displayName = "Patrol Behaviour";
                tooltip = "AI behaviour mode for security patrols.";
                control = "Combo";
                property = "Recondo_HubSubs_SecurityPatrolBehaviour";
                expression = "_this setVariable ['securitypatrolbehaviour', _value, true];";
                typeName = "STRING";
                defaultValue = """SAFE""";
                category = "Recondo_HubSubs_SecurityPatrol";
                class Values {
                    class Safe { name = "SAFE"; value = "SAFE"; };
                    class Aware { name = "AWARE"; value = "AWARE"; };
                    class Combat { name = "COMBAT"; value = "COMBAT"; };
                };
            };
            class SecurityPatrolSpeed {
                displayName = "Patrol Speed";
                tooltip = "Movement speed for security patrols.";
                control = "Combo";
                property = "Recondo_HubSubs_SecurityPatrolSpeed";
                expression = "_this setVariable ['securitypatrolspeed', _value, true];";
                typeName = "STRING";
                defaultValue = """LIMITED""";
                category = "Recondo_HubSubs_SecurityPatrol";
                class Values {
                    class Limited { name = "LIMITED"; value = "LIMITED"; };
                    class Normal { name = "NORMAL"; value = "NORMAL"; };
                    class Full { name = "FULL"; value = "FULL"; };
                };
            };
            class SecurityPatrolFormation {
                displayName = "Patrol Formation";
                tooltip = "Formation for security patrol groups.";
                control = "Combo";
                property = "Recondo_HubSubs_SecurityPatrolFormation";
                expression = "_this setVariable ['securitypatrolformation', _value, true];";
                typeName = "STRING";
                defaultValue = """STAG COLUMN""";
                category = "Recondo_HubSubs_SecurityPatrol";
                class Values {
                    class Column { name = "COLUMN"; value = "COLUMN"; };
                    class StagColumn { name = "STAG COLUMN"; value = "STAG COLUMN"; };
                    class Wedge { name = "WEDGE"; value = "WEDGE"; };
                    class Line { name = "LINE"; value = "LINE"; };
                    class File { name = "FILE"; value = "FILE"; };
                };
            };
            
            // ========================================
            // SUB-SITE SETTINGS
            // ========================================
            class EnableSubSites {
                displayName = "SUB-SITES - Enable Sub-Sites";
                tooltip = "Enable spawning of sub-site defensive positions around hubs.";
                control = "Checkbox";
                property = "Recondo_HubSubs_EnableSubSites";
                expression = "_this setVariable ['enablesubsites', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_HubSubs_SubSites";
            };
            class SubSiteMin {
                displayName = "Sub-Sites Min";
                tooltip = "Minimum number of sub-sites per hub.";
                control = "Edit";
                property = "Recondo_HubSubs_SubSiteMin";
                expression = "_this setVariable ['subsitemin', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """1""";
                category = "Recondo_HubSubs_SubSites";
            };
            class SubSiteMax {
                displayName = "Sub-Sites Max";
                tooltip = "Maximum number of sub-sites per hub.";
                control = "Edit";
                property = "Recondo_HubSubs_SubSiteMax";
                expression = "_this setVariable ['subsitemax', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """3""";
                category = "Recondo_HubSubs_SubSites";
            };
            class SubSiteClassnames {
                displayName = "Sub-Site Object Classnames";
                tooltip = "Object classnames for sub-sites (static weapons, bunkers). One per line or comma-separated. Random selection per site.";
                control = "EditCodeMulti5";
                property = "Recondo_HubSubs_SubSiteClassnames";
                expression = "_this setVariable ['subsiteclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_HubSubs_SubSites";
            };
            class SubSiteClearRadius {
                displayName = "Sub-Site Clear Radius";
                tooltip = "Radius in meters to hide terrain objects around sub-sites.";
                control = "Edit";
                property = "Recondo_HubSubs_SubSiteClearRadius";
                expression = "_this setVariable ['subsiteclearradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """15""";
                category = "Recondo_HubSubs_SubSites";
            };
            class SubSiteSpawnMode {
                displayName = "Sub-Site Spawn Mode";
                tooltip = "How/when to spawn sub-site compositions.";
                control = "Combo";
                property = "Recondo_HubSubs_SubSiteSpawnMode";
                expression = "_this setVariable ['subsitespawnmode', _value, true];";
                typeName = "STRING";
                defaultValue = """proximity""";
                category = "Recondo_HubSubs_SubSites";
                class Values {
                    class Proximity { name = "Proximity Trigger"; value = "proximity"; };
                    class Immediate { name = "Immediate (Mission Start)"; value = "immediate"; };
                };
            };
            class SubSiteTriggerRadius {
                displayName = "Sub-Site Trigger Radius";
                tooltip = "Radius in meters for sub-site proximity trigger.";
                control = "Edit";
                property = "Recondo_HubSubs_SubSiteTriggerRadius";
                expression = "_this setVariable ['subsitetriggerradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """800""";
                category = "Recondo_HubSubs_SubSites";
            };
            
            // ========================================
            // SUB-SITE AI SETTINGS
            // ========================================
            class SubSiteAIClassnames {
                displayName = "SUB-SITE AI - Unit Classnames";
                tooltip = "Unit classnames for sub-site garrison AI. One per line or comma-separated.";
                control = "EditCodeMulti5";
                property = "Recondo_HubSubs_SubSiteAIClassnames";
                expression = "_this setVariable ['subsiteaiclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_HubSubs_SubSiteAI";
            };
            class SubSiteGarrisonMin {
                displayName = "Garrison Min";
                tooltip = "Minimum garrison units per sub-site.";
                control = "Edit";
                property = "Recondo_HubSubs_SubSiteGarrisonMin";
                expression = "_this setVariable ['subsitegarrisonmin', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """2""";
                category = "Recondo_HubSubs_SubSiteAI";
            };
            class SubSiteGarrisonMax {
                displayName = "Garrison Max";
                tooltip = "Maximum garrison units per sub-site.";
                control = "Edit";
                property = "Recondo_HubSubs_SubSiteGarrisonMax";
                expression = "_this setVariable ['subsitegarrisonmax', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """4""";
                category = "Recondo_HubSubs_SubSiteAI";
            };
            class SubSiteGarrisonRadius {
                displayName = "Garrison Radius";
                tooltip = "Radius in meters to search for buildings/statics to garrison.";
                control = "Edit";
                property = "Recondo_HubSubs_SubSiteGarrisonRadius";
                expression = "_this setVariable ['subsitegarrisonradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """50""";
                category = "Recondo_HubSubs_SubSiteAI";
            };
            
            // ========================================
            // INTEL SETTINGS
            // ========================================
            class IntelWeight {
                displayName = "INTEL - Intel Weight";
                tooltip = "Weight for intel reveal priority (1-10). Higher = more likely to be revealed.";
                control = "Slider";
                property = "Recondo_HubSubs_IntelWeight";
                expression = "_this setVariable ['intelweight', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.5";
                sliderRange[] = {0.1, 1};
                sliderStep = 0.1;
                category = "Recondo_HubSubs_Intel";
            };
            class IntelRevealMessagesDoc {
                displayName = "Intel Reveal Messages (Documents)";
                tooltip = "Messages shown when intel from documents reveals this hub location. One per line. Placeholders: %GRID%, %NAME%, %OBJECTIVE%. Random selection. Leave blank for default.";
                control = "EditCodeMulti5";
                property = "Recondo_HubSubs_IntelRevealMessagesDoc";
                expression = "_this setVariable ['intelrevealmessagesdoc', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_HubSubs_Intel";
            };
            class IntelRevealMessagesPOW {
                displayName = "Intel Reveal Messages (POW)";
                tooltip = "Messages shown when intel from POW interrogation reveals this hub location. One per line. Placeholders: %GRID%, %NAME%, %OBJECTIVE%. Random selection. Leave blank for default.";
                control = "EditCodeMulti5";
                property = "Recondo_HubSubs_IntelRevealMessagesPOW";
                expression = "_this setVariable ['intelrevealmessagespow', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_HubSubs_Intel";
            };
            
            // ========================================
            // DEBUG SETTINGS
            // ========================================
            class DebugLogging {
                displayName = "DEBUG - Enable Debug Logging";
                tooltip = "Enable detailed logging to RPT file for troubleshooting.";
                control = "Checkbox";
                property = "Recondo_HubSubs_DebugLogging";
                expression = "_this setVariable ['debuglogging', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_HubSubs_Debug";
            };
            class DebugMarkers {
                displayName = "Enable Debug Markers";
                tooltip = "Show debug markers on map for hub and sub-site positions.";
                control = "Checkbox";
                property = "Recondo_HubSubs_DebugMarkers";
                expression = "_this setVariable ['debugmarkers', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_HubSubs_Debug";
            };
            
            // ========================================
            // SMELL HINTS
            // ========================================
            class EnableSmellHints {
                displayName = "Enable Smell Hints";
                tooltip = "Shows atmospheric text hints when players approach hub locations.";
                control = "Checkbox";
                property = "Recondo_HubSubs_EnableSmellHints";
                expression = "_this setVariable ['enablesmellhints', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_HubSubs_SmellHints";
            };
            class SmellHintRadius {
                displayName = "Smell Hint Radius";
                tooltip = "Distance (meters) at which players detect smells from hub locations.";
                control = "Edit";
                property = "Recondo_HubSubs_SmellHintRadius";
                expression = "_this setVariable ['smellhintradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """200""";
                category = "Recondo_HubSubs_SmellHints";
            };
            class SmellHintMessages {
                displayName = "Smell Hint Messages";
                tooltip = "Comma-separated list of atmospheric messages. One is randomly chosen per trigger.";
                control = "EditMulti5";
                property = "Recondo_HubSubs_SmellHintMessages";
                expression = "_this setVariable ['smellhintmessages', _value, true];";
                typeName = "STRING";
                defaultValue = """Wood smoke and the scent of a camp fire drift nearby...,The smell of cooked rice and fish sauce lingers in the air...,You catch a whiff of burning charcoal and tobacco...,Something cooking wafts on the breeze.""";
                category = "Recondo_HubSubs_SmellHints";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    //==========================================
    // OBJECTIVE HVT MODULE
    // High Value Target capture objective
    //==========================================
    class Recondo_Module_ObjectiveHVT: Module_F {
        scope = 2;
        displayName = "Objective - HVT";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleObjectiveHVT";
        functionPriority = 4;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 0;
        canSetArea = 0;
        
        class ModuleDescription: ModuleDescription {
            description = "Creates a High Value Target capture objective. One location is randomly selected as the real HVT location, others become decoys. Sync to Intel module for turn-in and intel integration.";
            sync[] = {"Recondo_Module_Intel"};
        };
        
        class Attributes: AttributesBase {
            
            // ========================================
            // PROFILE POOL SETTINGS
            // ========================================
            class Profile_HVT1 {
                displayName = "Nikos Panagopoulos (HVT1)";
                tooltip = "Enable this profile in the selection pool.";
                control = "Checkbox";
                property = "Recondo_HVT_Profile_HVT1";
                expression = "_this setVariable ['profile_hvt1', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_HVT_ProfilePool";
            };
            class Profile_HVT2 {
                displayName = "HVT2";
                tooltip = "Enable this profile in the selection pool.";
                control = "Checkbox";
                property = "Recondo_HVT_Profile_HVT2";
                expression = "_this setVariable ['profile_hvt2', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_HVT_ProfilePool";
            };
            class Profile_HVT3 {
                displayName = "HVT3";
                tooltip = "Enable this profile in the selection pool.";
                control = "Checkbox";
                property = "Recondo_HVT_Profile_HVT3";
                expression = "_this setVariable ['profile_hvt3', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_HVT_ProfilePool";
            };
            class Profile_VC_Taxman {
                displayName = "Khanh Le (VC_Taxman)";
                tooltip = "Enable this profile in the selection pool.";
                control = "Checkbox";
                property = "Recondo_HVT_Profile_VC_Taxman";
                expression = "_this setVariable ['profile_vc_taxman', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_HVT_ProfilePool";
            };
            
            // ========================================
            // GENERAL SETTINGS
            // ========================================
            class ObjectiveName {
                displayName = "GENERAL - Objective Name";
                tooltip = "Display name for this objective type.";
                control = "Edit";
                property = "Recondo_HVT_ObjectiveName";
                expression = "_this setVariable ['objectivename', _value, true];";
                typeName = "STRING";
                defaultValue = """High Value Target""";
                category = "Recondo_HVT_General";
            };
            class ObjectiveDescription {
                displayName = "Objective Description";
                tooltip = "Description shown in briefings.";
                control = "EditMulti5";
                property = "Recondo_HVT_ObjectiveDescription";
                expression = "_this setVariable ['objectivedescription', _value, true];";
                typeName = "STRING";
                defaultValue = """Locate and capture the High Value Target.""";
                category = "Recondo_HVT_General";
            };
            class IntelBoardCategoryName {
                displayName = "Intel Board Category Name";
                tooltip = "Custom category name displayed on the Intel Board. Leave blank for default ('HIGH VALUE TARGETS').";
                control = "Edit";
                property = "Recondo_HVT_IntelBoardCategoryName";
                expression = "_this setVariable ['intelboardcategoryname', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_HVT_General";
            };
            class MarkerPrefix {
                displayName = "Marker Prefix";
                tooltip = "Prefix for invisible map markers. Example: 'HVT_' will find HVT_1, HVT_2, etc.";
                control = "Edit";
                property = "Recondo_HVT_MarkerPrefix";
                expression = "_this setVariable ['markerprefix', _value, true];";
                typeName = "STRING";
                defaultValue = """HVT_""";
                category = "Recondo_HVT_General";
            };
            class MakeInvincible {
                displayName = "Make HVT Invincible";
                tooltip = "When enabled, the HVT cannot be killed (prevents accidental deaths).";
                control = "Checkbox";
                property = "Recondo_HVT_MakeInvincible";
                expression = "_this setVariable ['makeinvincible', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_HVT_General";
            };
            
            // ========================================
            // COMPOSITION POOL SETTINGS (Checkboxes)
            // ========================================
            class Comp_HVTBASE_1 {
                displayName = "HVTBASE_comp_1";
                tooltip = "Enable this composition in the selection pool.";
                control = "Checkbox";
                property = "Recondo_HVT_Comp_HVTBASE_1";
                expression = "_this setVariable ['comp_hvtbase_1', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_HVT_CompositionPool";
            };
            class Comp_HVTBASE_2 {
                displayName = "HVTBASE_comp_2";
                tooltip = "Enable this composition in the selection pool.";
                control = "Checkbox";
                property = "Recondo_HVT_Comp_HVTBASE_2";
                expression = "_this setVariable ['comp_hvtbase_2', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_HVT_CompositionPool";
            };
            class Comp_HVTBASE_3 {
                displayName = "HVTBASE_comp_3";
                tooltip = "Enable this composition in the selection pool.";
                control = "Checkbox";
                property = "Recondo_HVT_Comp_HVTBASE_3";
                expression = "_this setVariable ['comp_hvtbase_3', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_HVT_CompositionPool";
            };
            class Comp_VC_camp1 {
                displayName = "VC_camp1";
                tooltip = "Enable this composition in the selection pool.";
                control = "Checkbox";
                property = "Recondo_HVT_Comp_VC_camp1";
                expression = "_this setVariable ['comp_vc_camp1', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_HVT_CompositionPool";
            };
            class Comp_VC_camp2 {
                displayName = "VC_camp2";
                tooltip = "Enable this composition in the selection pool.";
                control = "Checkbox";
                property = "Recondo_HVT_Comp_VC_camp2";
                expression = "_this setVariable ['comp_vc_camp2', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_HVT_CompositionPool";
            };
            class Comp_VC_POW_camp1 {
                displayName = "VC_POW_camp1";
                tooltip = "Enable this composition in the selection pool.";
                control = "Checkbox";
                property = "Recondo_HVT_Comp_VC_POW_camp1";
                expression = "_this setVariable ['comp_vc_pow_camp1', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_HVT_CompositionPool";
            };
            class Comp_VC_POW_camp2 {
                displayName = "VC_POW_camp2";
                tooltip = "Enable this composition in the selection pool.";
                control = "Checkbox";
                property = "Recondo_HVT_Comp_VC_POW_camp2";
                expression = "_this setVariable ['comp_vc_pow_camp2', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_HVT_CompositionPool";
            };
            
            // ========================================
            // CUSTOM COMPOSITION SETTINGS
            // ========================================
            class CustomCompositionPath {
                displayName = "CUSTOM - Folder Path";
                tooltip = "Folder path relative to mission root containing your custom composition files.";
                control = "Edit";
                property = "Recondo_HVT_CustomCompPath";
                expression = "_this setVariable ['customcomppath', _value, true];";
                typeName = "STRING";
                defaultValue = """compositions""";
                category = "Recondo_HVT_CompositionCustom";
            };
            class CustomActiveCompositions {
                displayName = "CUSTOM - Composition List";
                tooltip = "List of your custom composition filenames (with or without .sqe extension).\nOne per line or comma-separated. These are added to the pool alongside checked compositions above.";
                control = "EditCodeMulti5";
                property = "Recondo_HVT_CustomActiveComps";
                expression = "_this setVariable ['customactivecomps', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_HVT_CompositionCustom";
            };
            class ClearRadius {
                displayName = "Terrain Clear Radius";
                tooltip = "Radius in meters to hide terrain objects around the location.";
                control = "Edit";
                property = "Recondo_HVT_ClearRadius";
                expression = "_this setVariable ['clearradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """25""";
                category = "Recondo_HVT_CompositionCustom";
            };
            class DisableSimulation {
                displayName = "Disable Simulation";
                tooltip = "Disable simulation on composition objects. Improves performance but objects won't react to physics/explosions.";
                control = "Checkbox";
                property = "Recondo_HVT_DisableSimulation";
                expression = "_this setVariable ['disablesimulation', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_HVT_CompositionCustom";
            };
            
            // ========================================
            // SPAWNING SETTINGS
            // ========================================
            class SpawnMode {
                displayName = "SPAWNING - Spawn Mode";
                tooltip = "How/when to spawn compositions.";
                control = "Combo";
                property = "Recondo_HVT_SpawnMode";
                expression = "_this setVariable ['spawnmode', _value, true];";
                typeName = "STRING";
                defaultValue = """proximity""";
                category = "Recondo_HVT_Spawning";
                class Values {
                    class Proximity { name = "Proximity Trigger"; value = "proximity"; };
                    class Immediate { name = "Immediate (Mission Start)"; value = "immediate"; };
                };
            };
            class CompositionTriggerRadius {
                displayName = "Composition Trigger Radius";
                tooltip = "Radius in meters for composition spawn trigger (outer ring).";
                control = "Edit";
                property = "Recondo_HVT_CompositionTriggerRadius";
                expression = "_this setVariable ['compositiontriggerradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """800""";
                category = "Recondo_HVT_Spawning";
            };
            class AITriggerRadius {
                displayName = "AI Trigger Radius";
                tooltip = "Radius in meters for AI spawn trigger (inner ring).";
                control = "Edit";
                property = "Recondo_HVT_AITriggerRadius";
                expression = "_this setVariable ['aitriggerradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """600""";
                category = "Recondo_HVT_Spawning";
            };
            class TriggerSide {
                displayName = "Trigger Side";
                tooltip = "Side that triggers spawning.";
                control = "Combo";
                property = "Recondo_HVT_TriggerSide";
                expression = "_this setVariable ['triggerside', _value, true];";
                typeName = "STRING";
                defaultValue = """WEST""";
                category = "Recondo_HVT_Spawning";
                class Values {
                    class West { name = "BLUFOR"; value = "WEST"; };
                    class East { name = "OPFOR"; value = "EAST"; };
                    class Guer { name = "Independent"; value = "GUER"; };
                    class Any { name = "Any Player"; value = "ANY"; };
                };
            };
            class SimulationDistance {
                displayName = "Simulation Distance";
                tooltip = "Distance at which simulation is enabled for spawned AI and objects. Entities start with simulation disabled and are enabled when players approach. Set to 0 to disable this feature (entities always simulated).";
                control = "Edit";
                property = "Recondo_HVT_SimulationDistance";
                expression = "_this setVariable ['simulationdistance', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """1000""";
                category = "Recondo_HVT_Spawning";
            };
            
            // ========================================
            // HVT SETTINGS
            // ========================================
            class HVTSide {
                displayName = "HVT - Unit Side";
                tooltip = "Which side the HVT unit belongs to. The unit will be set to this side regardless of its classname's default.";
                control = "Combo";
                property = "Recondo_HVT_HVTSide";
                expression = "_this setVariable ['hvtside', _value, true];";
                typeName = "STRING";
                defaultValue = """EAST""";
                category = "Recondo_HVT_HVT";
                class Values {
                    class East { name = "OPFOR"; value = "EAST"; };
                    class West { name = "BLUFOR"; value = "WEST"; };
                    class Guer { name = "Independent"; value = "GUER"; };
                    class Civ { name = "Civilian"; value = "CIV"; };
                };
            };
            class HVTTurnInRadius {
                displayName = "Turn-In Radius";
                tooltip = "Distance in meters the HVT must be from the turn-in object to allow capture.";
                control = "Edit";
                property = "Recondo_HVT_HVTTurnInRadius";
                expression = "_this setVariable ['hvtturninradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """10""";
                category = "Recondo_HVT_HVT";
            };
            class HVTEnableWandering {
                displayName = "Enable Wandering";
                tooltip = "Allow the HVT to walk between building positions. Stops when combat is detected.";
                control = "Checkbox";
                property = "Recondo_HVT_EnableWandering";
                expression = "_this setVariable ['hvtenablewandering', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_HVT_HVT";
            };
            class HVTWanderWaitTime {
                displayName = "Wander Wait Time (sec)";
                tooltip = "Seconds the HVT waits at each position before moving to the next.";
                control = "Edit";
                property = "Recondo_HVT_WanderWaitTime";
                expression = "_this setVariable ['hvtwanderwaittime', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """15""";
                category = "Recondo_HVT_HVT";
            };
            class HVTWanderTimeout {
                displayName = "Wander Move Timeout (sec)";
                tooltip = "Maximum seconds allowed for HVT to reach next position before selecting a new one.";
                control = "Edit";
                property = "Recondo_HVT_WanderTimeout";
                expression = "_this setVariable ['hvtwandertimeout', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """60""";
                category = "Recondo_HVT_HVT";
            };
            
            // ========================================
            // DECOY SETTINGS
            // ========================================
            class DecoyCount {
                displayName = "DECOYS - Number of Decoys";
                tooltip = "Number of decoy locations (composition only, may have AI based on chance).";
                control = "Edit";
                property = "Recondo_HVT_DecoyCount";
                expression = "_this setVariable ['decoycount', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """3""";
                category = "Recondo_HVT_Decoys";
            };
            class DecoyAIChance {
                displayName = "Decoy AI Spawn Chance";
                tooltip = "Percentage chance for AI to spawn at decoy locations (0-100%).";
                control = "Slider";
                property = "Recondo_HVT_DecoyAIChance";
                expression = "_this setVariable ['decoyaichance', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.5";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_HVT_Decoys";
            };
            
            // ========================================
            // GARRISON AI SETTINGS
            // ========================================
            class AISide {
                displayName = "GARRISON AI - AI Side";
                tooltip = "Side of garrison AI units.";
                control = "Combo";
                property = "Recondo_HVT_AISide";
                expression = "_this setVariable ['aiside', _value, true];";
                typeName = "STRING";
                defaultValue = """EAST""";
                category = "Recondo_HVT_GarrisonAI";
                class Values {
                    class East { name = "OPFOR"; value = "EAST"; };
                    class West { name = "BLUFOR"; value = "WEST"; };
                    class Guer { name = "Independent"; value = "GUER"; };
                };
            };
            class GarrisonClassnames {
                displayName = "Garrison Classnames";
                tooltip = "Unit classnames for garrison AI. One per line or comma-separated.";
                control = "EditCodeMulti5";
                property = "Recondo_HVT_GarrisonClassnames";
                expression = "_this setVariable ['garrisonclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """O_G_Soldier_F,O_G_Soldier_A_F,O_G_Soldier_AR_F,O_G_medic_F,O_G_Soldier_GL_F,O_G_Soldier_M_F,O_G_Soldier_SL_F,O_G_Soldier_TL_F""";
                category = "Recondo_HVT_GarrisonAI";
            };
            class GarrisonMin {
                displayName = "Garrison Min";
                tooltip = "Minimum garrison units at the location.";
                control = "Edit";
                property = "Recondo_HVT_GarrisonMin";
                expression = "_this setVariable ['garrisonmin', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """2""";
                category = "Recondo_HVT_GarrisonAI";
            };
            class GarrisonMax {
                displayName = "Garrison Max";
                tooltip = "Maximum garrison units at the location.";
                control = "Edit";
                property = "Recondo_HVT_GarrisonMax";
                expression = "_this setVariable ['garrisonmax', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """4""";
                category = "Recondo_HVT_GarrisonAI";
            };
            class EnableRovingSentry {
                displayName = "Enable Roving Sentry";
                tooltip = "Spawn a single sentry that patrols through building positions.";
                control = "Checkbox";
                property = "Recondo_HVT_EnableRovingSentry";
                expression = "_this setVariable ['enablerovingsentry', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_HVT_GarrisonAI";
            };
            class InvulnTime {
                displayName = "Invulnerability Time";
                tooltip = "Seconds AI are invulnerable after spawning (prevents instant death).";
                control = "Edit";
                property = "Recondo_HVT_InvulnTime";
                expression = "_this setVariable ['invulntime', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """30""";
                category = "Recondo_HVT_GarrisonAI";
            };
            
            // ========================================
            // CIVILIAN SETTINGS
            // ========================================
            class EnableCivilians {
                displayName = "CIVILIANS - Enable Civilians";
                tooltip = "Enable random civilian spawning at locations.";
                control = "Checkbox";
                property = "Recondo_HVT_EnableCivilians";
                expression = "_this setVariable ['enablecivilians', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_HVT_Civilians";
            };
            class CivilianChance {
                displayName = "Civilian Spawn Chance";
                tooltip = "Percentage chance for civilians to spawn (0-100%).";
                control = "Slider";
                property = "Recondo_HVT_CivilianChance";
                expression = "_this setVariable ['civilianchance', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.5";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_HVT_Civilians";
            };
            class CivilianClassnames {
                displayName = "Civilian Classnames";
                tooltip = "Civilian unit classnames. One per line or comma-separated.";
                control = "EditCodeMulti5";
                property = "Recondo_HVT_CivilianClassnames";
                expression = "_this setVariable ['civilianclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """C_man_1,C_Man_casual_1_F,C_Man_casual_2_F,C_Man_casual_3_F""";
                category = "Recondo_HVT_Civilians";
            };
            
            // ========================================
            // ANIMAL SETTINGS
            // ========================================
            class EnableAnimals {
                displayName = "ANIMALS - Enable Animals";
                tooltip = "Enable random animal spawning at locations (chickens, goats, etc.).";
                control = "Checkbox";
                property = "Recondo_HVT_EnableAnimals";
                expression = "_this setVariable ['enableanimals', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_HVT_Animals";
            };
            class AnimalChance {
                displayName = "Animal Spawn Chance";
                tooltip = "Percentage chance for animals to spawn at each location (0-100%).";
                control = "Slider";
                property = "Recondo_HVT_AnimalChance";
                expression = "_this setVariable ['animalchance', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.75";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_HVT_Animals";
            };
            class AnimalClassnames {
                displayName = "Animal Classnames";
                tooltip = "Animal classnames. One per line or comma-separated. Common: Hen_random_F, Cock_random_F, Goat_random_F, Sheep_random_F";
                control = "EditCodeMulti5";
                property = "Recondo_HVT_AnimalClassnames";
                expression = "_this setVariable ['animalclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """Hen_random_F,Cock_random_F""";
                category = "Recondo_HVT_Animals";
            };
            class AnimalMin {
                displayName = "Animal Min";
                tooltip = "Minimum number of animals to spawn.";
                control = "Edit";
                property = "Recondo_HVT_AnimalMin";
                expression = "_this setVariable ['animalmin', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """3""";
                category = "Recondo_HVT_Animals";
            };
            class AnimalMax {
                displayName = "Animal Max";
                tooltip = "Maximum number of animals to spawn.";
                control = "Edit";
                property = "Recondo_HVT_AnimalMax";
                expression = "_this setVariable ['animalmax', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """6""";
                category = "Recondo_HVT_Animals";
            };
            
            // ========================================
            // NIGHT LIGHTS SETTINGS
            // ========================================
            class EnableNightLights {
                displayName = "NIGHT LIGHTS - Enable Night Lights";
                tooltip = "Enable warm lights inside buildings at night. Lights turn on automatically when dark (sunOrMoon < 0.5).";
                control = "Checkbox";
                property = "Recondo_HVT_EnableNightLights";
                expression = "_this setVariable ['enablenightlights', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_HVT_NightLights";
            };
            
            // ========================================
            // SMELL HINTS SETTINGS
            // ========================================
            class EnableSmellHints {
                displayName = "SMELL HINTS - Enable Smell Hints";
                tooltip = "Display atmospheric smell text when players approach locations. Creates immersive environmental awareness.";
                control = "Checkbox";
                property = "Recondo_HVT_EnableSmellHints";
                expression = "_this setVariable ['enablesmellhints', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_HVT_SmellHints";
            };
            class SmellHintRadius {
                displayName = "Smell Hint Radius";
                tooltip = "Distance (meters) at which players detect smells from locations.";
                control = "Edit";
                property = "Recondo_HVT_SmellHintRadius";
                expression = "_this setVariable ['smellhintradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """200""";
                category = "Recondo_HVT_SmellHints";
            };
            class SmellHintMessages {
                displayName = "Smell Hint Messages";
                tooltip = "List of smell messages (one per line or comma-separated). A random message is shown when triggered.";
                control = "EditMulti5";
                property = "Recondo_HVT_SmellHintMessages";
                expression = "_this setVariable ['smellhintmessages', _value, true];";
                typeName = "STRING";
                defaultValue = """A faint smell of cigarette smoke drifts on the breeze...,The air carries the scent of wood smoke...,You catch a whiff of cooking fires nearby...,Something burning... somewhere close.""";
                category = "Recondo_HVT_SmellHints";
            };
            
            // ========================================
            // INTEL SETTINGS
            // ========================================
            class IntelWeight {
                displayName = "INTEL - Intel Weight";
                tooltip = "Weight for intel reveal priority (0.1-1). Higher = more likely to be revealed.";
                control = "Slider";
                property = "Recondo_HVT_IntelWeight";
                expression = "_this setVariable ['intelweight', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.5";
                sliderRange[] = {0.1, 1};
                sliderStep = 0.1;
                category = "Recondo_HVT_Intel";
            };
            class IntelRevealMessagesDoc {
                displayName = "Intel Reveal Messages (Documents)";
                tooltip = "Messages shown when intel from documents reveals this target. One per line. Placeholders: %GRID%, %NAME%, %OBJECTIVE%. Random selection.";
                control = "EditCodeMulti5";
                property = "Recondo_HVT_IntelRevealMessagesDoc";
                expression = "_this setVariable ['intelrevealmessagesdoc', _value, true];";
                typeName = "STRING";
                defaultValue = """Captured documents indicate %NAME% was recently spotted near grid %GRID%.\nIntel suggests the target %NAME% may be located around grid %GRID%.\nEnemy communications mention %NAME% operating in the vicinity of grid %GRID%.""";
                category = "Recondo_HVT_Intel";
            };
            class IntelRevealMessagesPOW {
                displayName = "Intel Reveal Messages (POW)";
                tooltip = "Messages shown when intel from POW interrogation reveals this target. One per line. Placeholders: %GRID%, %NAME%, %OBJECTIVE%. Random selection.";
                control = "EditCodeMulti5";
                property = "Recondo_HVT_IntelRevealMessagesPOW";
                expression = "_this setVariable ['intelrevealmessagespow', _value, true];";
                typeName = "STRING";
                defaultValue = """Under interrogation, the prisoner disclosed that %NAME% is hiding near grid %GRID%.\nThe POW revealed %NAME% was last seen around grid %GRID%.\nInterrogation confirms %NAME% operates from a location near grid %GRID%.""";
                category = "Recondo_HVT_Intel";
            };
            class IntelConfirmMessage {
                displayName = "Intel Confirm Message";
                tooltip = "Message shown when intel confirms an already-revealed location. Placeholders: %GRID%, %NAME%, %OBJECTIVE%.";
                control = "Edit";
                property = "Recondo_HVT_IntelConfirmMessage";
                expression = "_this setVariable ['intelconfirmmessage', _value, true];";
                typeName = "STRING";
                defaultValue = """This confirms earlier reports about %NAME% near grid %GRID%.""";
                category = "Recondo_HVT_Intel";
            };
            
            // ========================================
            // DEBUG SETTINGS
            // ========================================
            class DebugLogging {
                displayName = "DEBUG - Enable Logging";
                tooltip = "Enable detailed logging to RPT file.";
                control = "Checkbox";
                property = "Recondo_HVT_DebugLogging";
                expression = "_this setVariable ['debuglogging', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_HVT_Debug";
            };
            class DebugMarkers {
                displayName = "Debug Markers";
                tooltip = "Show debug markers on map for HVT and decoy positions.";
                control = "Checkbox";
                property = "Recondo_HVT_DebugMarkers";
                expression = "_this setVariable ['debugmarkers', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_HVT_Debug";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    //==========================================
    // OBJECTIVE HOSTAGES MODULE
    // Creates hostage rescue objectives
    //==========================================
    class Recondo_Module_ObjectiveHostages: Module_F {
        scope = 2;
        displayName = "Objective - Hostages";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleObjectiveHostages";
        functionPriority = 5;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 0;
        canSetArea = 0;
        
        class ModuleDescription: ModuleDescription {
            description = "Creates a Hostage Rescue objective. Hostages are distributed across selected locations. Decoy locations can be configured. Each hostage can be turned in individually. Sync to Intel module for turn-in and intel integration.";
            sync[] = {"Recondo_Module_Intel"};
        };
        
        class Attributes: AttributesBase {
            
            // ========================================
            // PROFILE POOL SETTINGS
            // ========================================
            class Profile_Hostage1 {
                displayName = "Markos Kouris (Hostage1)";
                tooltip = "Enable this profile in the selection pool.";
                control = "Checkbox";
                property = "Recondo_Hostage_Profile_Hostage1";
                expression = "_this setVariable ['profile_hostage1', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_Hostage_ProfilePool";
            };
            class Profile_Hostage2 {
                displayName = "Hostage2";
                tooltip = "Enable this profile in the selection pool.";
                control = "Checkbox";
                property = "Recondo_Hostage_Profile_Hostage2";
                expression = "_this setVariable ['profile_hostage2', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_Hostage_ProfilePool";
            };
            class Profile_Hostage3 {
                displayName = "Hostage3";
                tooltip = "Enable this profile in the selection pool.";
                control = "Checkbox";
                property = "Recondo_Hostage_Profile_Hostage3";
                expression = "_this setVariable ['profile_hostage3', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_Hostage_ProfilePool";
            };
            class Profile_Hostage_ARVN {
                displayName = "Tan Dung Lieu (Hostage_ARVN)";
                tooltip = "Enable this profile in the selection pool.";
                control = "Checkbox";
                property = "Recondo_Hostage_Profile_Hostage_ARVN";
                expression = "_this setVariable ['profile_hostage_arvn', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_Hostage_ProfilePool";
            };
            
            // ========================================
            // GENERAL SETTINGS
            // ========================================
            class ObjectiveName {
                displayName = "GENERAL - Objective Name";
                tooltip = "Display name for this objective type.";
                control = "Edit";
                property = "Recondo_Hostage_ObjectiveName";
                expression = "_this setVariable ['objectivename', _value, true];";
                typeName = "STRING";
                defaultValue = """Hostage Rescue""";
                category = "Recondo_Hostage_General";
            };
            class ObjectiveDescription {
                displayName = "Objective Description";
                tooltip = "Description shown in briefings.";
                control = "EditMulti5";
                property = "Recondo_Hostage_ObjectiveDescription";
                expression = "_this setVariable ['objectivedescription', _value, true];";
                typeName = "STRING";
                defaultValue = """Locate and rescue the hostages.""";
                category = "Recondo_Hostage_General";
            };
            class IntelBoardCategoryName {
                displayName = "Intel Board Category Name";
                tooltip = "Custom category name displayed on the Intel Board. Leave blank for default ('HOSTAGES').";
                control = "Edit";
                property = "Recondo_Hostage_IntelBoardCategoryName";
                expression = "_this setVariable ['intelboardcategoryname', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_Hostage_General";
            };
            class MarkerPrefix {
                displayName = "Marker Prefix";
                tooltip = "Prefix for invisible map markers. Example: 'HOSTAGE_' will find HOSTAGE_1, HOSTAGE_2, etc.";
                control = "Edit";
                property = "Recondo_Hostage_MarkerPrefix";
                expression = "_this setVariable ['markerprefix', _value, true];";
                typeName = "STRING";
                defaultValue = """HOSTAGE_""";
                category = "Recondo_Hostage_General";
            };
            class MakeInvincible {
                displayName = "Make Hostages Invincible";
                tooltip = "When enabled, hostages cannot be killed (prevents accidental deaths).";
                control = "Checkbox";
                property = "Recondo_Hostage_MakeInvincible";
                expression = "_this setVariable ['makeinvincible', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_Hostage_General";
            };
            
            // ========================================
            // HOSTAGE LOCATION SETTINGS
            // ========================================
            class HostageLocationCount {
                displayName = "Hostage Location Count";
                tooltip = "Number of markers that will have hostages (real locations).";
                control = "Edit";
                property = "Recondo_Hostage_HostageLocationCount";
                expression = "_this setVariable ['hostagelocationcount', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """1""";
                category = "Recondo_Hostage_Hostages";
            };
            class DecoyCount {
                displayName = "Decoy Location Count";
                tooltip = "Number of decoy locations (no hostages).";
                control = "Edit";
                property = "Recondo_Hostage_DecoyCount";
                expression = "_this setVariable ['decoycount', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """2""";
                category = "Recondo_Hostage_Hostages";
            };
            class DistributionMode {
                displayName = "Distribution Mode";
                tooltip = "How hostages are distributed across locations.";
                control = "Combo";
                property = "Recondo_Hostage_DistributionMode";
                expression = "_this setVariable ['distributionmode', _value, true];";
                typeName = "STRING";
                defaultValue = """random""";
                category = "Recondo_Hostage_Hostages";
                class Values {
                    class Random { name = "Random (spread across locations)"; value = "random"; };
                    class Grouped { name = "Grouped (all at one location)"; value = "grouped"; };
                };
            };
            class HostageTurnInRadius {
                displayName = "Turn-In Radius";
                tooltip = "Distance in meters hostage must be from turn-in point.";
                control = "Edit";
                property = "Recondo_Hostage_TurnInRadius";
                expression = "_this setVariable ['hostageturninradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """10""";
                category = "Recondo_Hostage_Hostages";
            };
            
            // ========================================
            // ANIMATION SETTINGS
            // ========================================
            class AnimationMode {
                displayName = "ANIMATION - Mode";
                tooltip = "How hostage animations are selected.";
                control = "Combo";
                property = "Recondo_Hostage_AnimationMode";
                expression = "_this setVariable ['animationmode', _value, true];";
                typeName = "STRING";
                defaultValue = """random""";
                category = "Recondo_Hostage_Animation";
                class Values {
                    class Random { name = "Random (sitting/kneeling)"; value = "random"; };
                    class Specific { name = "Specific Animation"; value = "specific"; };
                };
            };
            class HostageAnimation {
                displayName = "Specific Animation";
                tooltip = "Animation to use when mode is 'Specific'. Options: Acts_AidlPsitMstpSsurWnonDnon01 (sitting), Acts_AidlPsitMstpSsurWnonDnon02 (kneeling), Acts_AidlPsitMstpSsurWnonDnon05 (against wall)";
                control = "Edit";
                property = "Recondo_Hostage_Animation";
                expression = "_this setVariable ['hostageanimation', _value, true];";
                typeName = "STRING";
                defaultValue = """Acts_AidlPsitMstpSsurWnonDnon01""";
                category = "Recondo_Hostage_Animation";
            };
            
            // ========================================
            // COMPOSITION POOL SETTINGS (Checkboxes)
            // ========================================
            class Comp_HVTBASE_1 {
                displayName = "HVTBASE_comp_1";
                tooltip = "Enable this composition in the selection pool.";
                control = "Checkbox";
                property = "Recondo_Hostage_Comp_HVTBASE_1";
                expression = "_this setVariable ['comp_hvtbase_1', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_Hostage_CompositionPool";
            };
            class Comp_HVTBASE_2 {
                displayName = "HVTBASE_comp_2";
                tooltip = "Enable this composition in the selection pool.";
                control = "Checkbox";
                property = "Recondo_Hostage_Comp_HVTBASE_2";
                expression = "_this setVariable ['comp_hvtbase_2', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_Hostage_CompositionPool";
            };
            class Comp_HVTBASE_3 {
                displayName = "HVTBASE_comp_3";
                tooltip = "Enable this composition in the selection pool.";
                control = "Checkbox";
                property = "Recondo_Hostage_Comp_HVTBASE_3";
                expression = "_this setVariable ['comp_hvtbase_3', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_Hostage_CompositionPool";
            };
            class Comp_VC_camp1 {
                displayName = "VC_camp1";
                tooltip = "Enable this composition in the selection pool.";
                control = "Checkbox";
                property = "Recondo_Hostage_Comp_VC_camp1";
                expression = "_this setVariable ['comp_vc_camp1', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_Hostage_CompositionPool";
            };
            class Comp_VC_camp2 {
                displayName = "VC_camp2";
                tooltip = "Enable this composition in the selection pool.";
                control = "Checkbox";
                property = "Recondo_Hostage_Comp_VC_camp2";
                expression = "_this setVariable ['comp_vc_camp2', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_Hostage_CompositionPool";
            };
            class Comp_VC_POW_camp1 {
                displayName = "VC_POW_camp1";
                tooltip = "Enable this composition in the selection pool.";
                control = "Checkbox";
                property = "Recondo_Hostage_Comp_VC_POW_camp1";
                expression = "_this setVariable ['comp_vc_pow_camp1', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_Hostage_CompositionPool";
            };
            class Comp_VC_POW_camp2 {
                displayName = "VC_POW_camp2";
                tooltip = "Enable this composition in the selection pool.";
                control = "Checkbox";
                property = "Recondo_Hostage_Comp_VC_POW_camp2";
                expression = "_this setVariable ['comp_vc_pow_camp2', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_Hostage_CompositionPool";
            };
            
            // ========================================
            // CUSTOM COMPOSITION SETTINGS
            // ========================================
            class CustomCompositionPath {
                displayName = "CUSTOM - Folder Path";
                tooltip = "Folder path relative to mission root containing your custom composition files.";
                control = "Edit";
                property = "Recondo_Hostage_CustomCompPath";
                expression = "_this setVariable ['customcomppath', _value, true];";
                typeName = "STRING";
                defaultValue = """compositions""";
                category = "Recondo_Hostage_CompositionCustom";
            };
            class CustomActiveCompositions {
                displayName = "CUSTOM - Composition List";
                tooltip = "List of your custom composition filenames (with or without .sqe extension).\nOne per line or comma-separated. These are added to the pool alongside checked compositions above.";
                control = "EditCodeMulti5";
                property = "Recondo_Hostage_CustomActiveComps";
                expression = "_this setVariable ['customactivecomps', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_Hostage_CompositionCustom";
            };
            class ClearRadius {
                displayName = "Terrain Clear Radius";
                tooltip = "Radius in meters to hide terrain objects around the location.";
                control = "Edit";
                property = "Recondo_Hostage_ClearRadius";
                expression = "_this setVariable ['clearradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """25""";
                category = "Recondo_Hostage_CompositionCustom";
            };
            class DisableSimulation {
                displayName = "Disable Simulation";
                tooltip = "Disable simulation on composition objects. Improves performance but objects won't react to physics/explosions.";
                control = "Checkbox";
                property = "Recondo_Hostage_DisableSimulation";
                expression = "_this setVariable ['disablesimulation', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_Hostage_CompositionCustom";
            };
            
            // ========================================
            // SPAWNING SETTINGS
            // ========================================
            class SpawnMode {
                displayName = "SPAWNING - Spawn Mode";
                tooltip = "How/when to spawn compositions.";
                control = "Combo";
                property = "Recondo_Hostage_SpawnMode";
                expression = "_this setVariable ['spawnmode', _value, true];";
                typeName = "STRING";
                defaultValue = """proximity""";
                category = "Recondo_Hostage_Spawning";
                class Values {
                    class Proximity { name = "Proximity Trigger"; value = "proximity"; };
                    class Immediate { name = "Immediate (Mission Start)"; value = "immediate"; };
                };
            };
            class CompositionTriggerRadius {
                displayName = "Composition Trigger Radius";
                tooltip = "Radius in meters for composition spawn trigger (outer ring).";
                control = "Edit";
                property = "Recondo_Hostage_CompositionTriggerRadius";
                expression = "_this setVariable ['compositiontriggerradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """800""";
                category = "Recondo_Hostage_Spawning";
            };
            class AITriggerRadius {
                displayName = "AI Trigger Radius";
                tooltip = "Radius in meters for AI and hostage spawn trigger (inner ring).";
                control = "Edit";
                property = "Recondo_Hostage_AITriggerRadius";
                expression = "_this setVariable ['aitriggerradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """600""";
                category = "Recondo_Hostage_Spawning";
            };
            class TriggerSide {
                displayName = "Trigger Side";
                tooltip = "Side that triggers spawning.";
                control = "Combo";
                property = "Recondo_Hostage_TriggerSide";
                expression = "_this setVariable ['triggerside', _value, true];";
                typeName = "STRING";
                defaultValue = """WEST""";
                category = "Recondo_Hostage_Spawning";
                class Values {
                    class West { name = "BLUFOR"; value = "WEST"; };
                    class East { name = "OPFOR"; value = "EAST"; };
                    class Guer { name = "Independent"; value = "GUER"; };
                    class Any { name = "Any Side"; value = "ANY"; };
                };
            };
            class SimulationDistance {
                displayName = "Simulation Distance";
                tooltip = "Distance at which simulation is enabled for spawned AI and objects (not hostages - they remain simulated). Set to 0 to disable this feature.";
                control = "Edit";
                property = "Recondo_Hostage_SimulationDistance";
                expression = "_this setVariable ['simulationdistance', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """1000""";
                category = "Recondo_Hostage_Spawning";
            };
            
            // ========================================
            // DECOY SETTINGS
            // ========================================
            class DecoyAIChance {
                displayName = "DECOYS - AI Spawn Chance";
                tooltip = "Percentage chance for AI to spawn at decoy locations (0-100%).";
                control = "Slider";
                property = "Recondo_Hostage_DecoyAIChance";
                expression = "_this setVariable ['decoyaichance', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.5";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_Hostage_Decoys";
            };
            
            // ========================================
            // GARRISON AI SETTINGS
            // ========================================
            class AISide {
                displayName = "GARRISON - AI Side";
                tooltip = "Side for garrison AI units.";
                control = "Combo";
                property = "Recondo_Hostage_AISide";
                expression = "_this setVariable ['aiside', _value, true];";
                typeName = "STRING";
                defaultValue = """EAST""";
                category = "Recondo_Hostage_GarrisonAI";
                class Values {
                    class East { name = "OPFOR"; value = "EAST"; };
                    class West { name = "BLUFOR"; value = "WEST"; };
                    class Guer { name = "Independent"; value = "GUER"; };
                };
            };
            class GarrisonClassnames {
                displayName = "Garrison Classnames";
                tooltip = "Garrison unit classnames. One per line or comma-separated.";
                control = "EditCodeMulti5";
                property = "Recondo_Hostage_GarrisonClassnames";
                expression = "_this setVariable ['garrisonclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_Hostage_GarrisonAI";
            };
            class GarrisonMin {
                displayName = "Garrison Min";
                tooltip = "Minimum garrison units at the location.";
                control = "Edit";
                property = "Recondo_Hostage_GarrisonMin";
                expression = "_this setVariable ['garrisonmin', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """2""";
                category = "Recondo_Hostage_GarrisonAI";
            };
            class GarrisonMax {
                displayName = "Garrison Max";
                tooltip = "Maximum garrison units at the location.";
                control = "Edit";
                property = "Recondo_Hostage_GarrisonMax";
                expression = "_this setVariable ['garrisonmax', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """4""";
                category = "Recondo_Hostage_GarrisonAI";
            };
            class EnableRovingSentry {
                displayName = "Enable Roving Sentry";
                tooltip = "Spawn a single sentry that patrols through building positions.";
                control = "Checkbox";
                property = "Recondo_Hostage_EnableRovingSentry";
                expression = "_this setVariable ['enablerovingsentry', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_Hostage_GarrisonAI";
            };
            class InvulnTime {
                displayName = "Invulnerability Time";
                tooltip = "Seconds AI are invulnerable after spawning (prevents instant death).";
                control = "Edit";
                property = "Recondo_Hostage_InvulnTime";
                expression = "_this setVariable ['invulntime', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """30""";
                category = "Recondo_Hostage_GarrisonAI";
            };
            
            // ========================================
            // CIVILIAN SETTINGS
            // ========================================
            class EnableCivilians {
                displayName = "CIVILIANS - Enable Civilians";
                tooltip = "Enable random civilian spawning at locations.";
                control = "Checkbox";
                property = "Recondo_Hostage_EnableCivilians";
                expression = "_this setVariable ['enablecivilians', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_Hostage_Civilians";
            };
            class CivilianChance {
                displayName = "Civilian Spawn Chance";
                tooltip = "Percentage chance for civilians to spawn (0-100%).";
                control = "Slider";
                property = "Recondo_Hostage_CivilianChance";
                expression = "_this setVariable ['civilianchance', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.5";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_Hostage_Civilians";
            };
            class CivilianClassnames {
                displayName = "Civilian Classnames";
                tooltip = "Civilian unit classnames. One per line or comma-separated.";
                control = "EditCodeMulti5";
                property = "Recondo_Hostage_CivilianClassnames";
                expression = "_this setVariable ['civilianclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """C_man_1,C_Man_casual_1_F,C_Man_casual_2_F,C_Man_casual_3_F""";
                category = "Recondo_Hostage_Civilians";
            };
            
            // ========================================
            // ANIMAL SETTINGS
            // ========================================
            class EnableAnimals {
                displayName = "ANIMALS - Enable Animals";
                tooltip = "Enable random animal spawning at locations (chickens, goats, etc.).";
                control = "Checkbox";
                property = "Recondo_Hostage_EnableAnimals";
                expression = "_this setVariable ['enableanimals', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_Hostage_Animals";
            };
            class AnimalChance {
                displayName = "Animal Spawn Chance";
                tooltip = "Percentage chance for animals to spawn at each location (0-100%).";
                control = "Slider";
                property = "Recondo_Hostage_AnimalChance";
                expression = "_this setVariable ['animalchance', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.75";
                sliderRange[] = {0, 1};
                sliderStep = 0.05;
                category = "Recondo_Hostage_Animals";
            };
            class AnimalClassnames {
                displayName = "Animal Classnames";
                tooltip = "Animal classnames. One per line or comma-separated. Common: Hen_random_F, Cock_random_F, Goat_random_F, Sheep_random_F";
                control = "EditCodeMulti5";
                property = "Recondo_Hostage_AnimalClassnames";
                expression = "_this setVariable ['animalclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """Hen_random_F,Cock_random_F""";
                category = "Recondo_Hostage_Animals";
            };
            class AnimalMin {
                displayName = "Animal Min";
                tooltip = "Minimum number of animals to spawn.";
                control = "Edit";
                property = "Recondo_Hostage_AnimalMin";
                expression = "_this setVariable ['animalmin', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """3""";
                category = "Recondo_Hostage_Animals";
            };
            class AnimalMax {
                displayName = "Animal Max";
                tooltip = "Maximum number of animals to spawn.";
                control = "Edit";
                property = "Recondo_Hostage_AnimalMax";
                expression = "_this setVariable ['animalmax', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """6""";
                category = "Recondo_Hostage_Animals";
            };
            
            // ========================================
            // INTEL SETTINGS
            // ========================================
            class IntelWeight {
                displayName = "INTEL - Intel Weight";
                tooltip = "Weight for intel reveal priority (0.1-1). Higher = more likely to be revealed.";
                control = "Slider";
                property = "Recondo_Hostage_IntelWeight";
                expression = "_this setVariable ['intelweight', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.5";
                sliderRange[] = {0.1, 1};
                sliderStep = 0.1;
                category = "Recondo_Hostage_Intel";
            };
            class IntelRevealMessagesDoc {
                displayName = "Intel Reveal Messages (Documents)";
                tooltip = "Messages shown when intel from documents reveals hostage location. One per line. Placeholders: %GRID%, %NAME%, %OBJECTIVE%. Random selection.";
                control = "EditCodeMulti5";
                property = "Recondo_Hostage_IntelRevealMessagesDoc";
                expression = "_this setVariable ['intelrevealmessagesdoc', _value, true];";
                typeName = "STRING";
                defaultValue = """Captured documents indicate hostages are being held near grid %GRID%.\nIntel suggests prisoners may be located around grid %GRID%.\nEnemy records mention a detention site near grid %GRID%.""";
                category = "Recondo_Hostage_Intel";
            };
            class IntelRevealMessagesPOW {
                displayName = "Intel Reveal Messages (POW)";
                tooltip = "Messages shown when intel from POW interrogation reveals hostage location. One per line. Placeholders: %GRID%, %NAME%, %OBJECTIVE%. Random selection.";
                control = "EditCodeMulti5";
                property = "Recondo_Hostage_IntelRevealMessagesPOW";
                expression = "_this setVariable ['intelrevealmessagespow', _value, true];";
                typeName = "STRING";
                defaultValue = """Under interrogation, the prisoner disclosed hostages are held near grid %GRID%.\nThe POW revealed prisoners are being kept around grid %GRID%.\nInterrogation confirms a holding site near grid %GRID%.""";
                category = "Recondo_Hostage_Intel";
            };
            class IntelConfirmMessage {
                displayName = "Intel Confirm Message";
                tooltip = "Message shown when intel confirms an already-revealed location. Placeholders: %GRID%, %NAME%, %OBJECTIVE%.";
                control = "Edit";
                property = "Recondo_Hostage_IntelConfirmMessage";
                expression = "_this setVariable ['intelconfirmmessage', _value, true];";
                typeName = "STRING";
                defaultValue = """This confirms earlier reports about hostages near grid %GRID%.""";
                category = "Recondo_Hostage_Intel";
            };
            
            // ========================================
            // DEBUG SETTINGS
            // ========================================
            class DebugLogging {
                displayName = "DEBUG - Enable Logging";
                tooltip = "Enable detailed logging to RPT file.";
                control = "Checkbox";
                property = "Recondo_Hostage_DebugLogging";
                expression = "_this setVariable ['debuglogging', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_Hostage_Debug";
            };
            class DebugMarkers {
                displayName = "Debug Markers";
                tooltip = "Show debug markers on map for hostage and decoy positions.";
                control = "Checkbox";
                property = "Recondo_Hostage_DebugMarkers";
                expression = "_this setVariable ['debugmarkers', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_Hostage_Debug";
            };
            
            // ========================================
            // NIGHT LIGHTS
            // ========================================
            class EnableNightLights {
                displayName = "NIGHT LIGHTS - Enable Night Lights";
                tooltip = "Enable warm lights inside buildings at night. Lights turn on automatically when dark (sunOrMoon < 0.5).";
                control = "Checkbox";
                property = "Recondo_Hostage_EnableNightLights";
                expression = "_this setVariable ['enablenightlights', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_Hostage_NightLights";
            };
            
            // ========================================
            // SMELL HINTS
            // ========================================
            class EnableSmellHints {
                displayName = "Enable Smell Hints";
                tooltip = "Shows atmospheric text hints when players approach hostage/decoy locations.";
                control = "Checkbox";
                property = "Recondo_Hostage_EnableSmellHints";
                expression = "_this setVariable ['enablesmellhints', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_Hostage_SmellHints";
            };
            class SmellHintRadius {
                displayName = "Smell Hint Radius";
                tooltip = "Distance (meters) at which players detect smells from locations.";
                control = "Edit";
                property = "Recondo_Hostage_SmellHintRadius";
                expression = "_this setVariable ['smellhintradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """200""";
                category = "Recondo_Hostage_SmellHints";
            };
            class SmellHintMessages {
                displayName = "Smell Hint Messages";
                tooltip = "Comma-separated list of atmospheric messages. One is randomly chosen per trigger.";
                control = "EditMulti5";
                property = "Recondo_Hostage_SmellHintMessages";
                expression = "_this setVariable ['smellhintmessages', _value, true];";
                typeName = "STRING";
                defaultValue = """You catch the faint smell of sweat and fear...,The air carries a hint of desperation...,A stale human odor drifts from nearby...,You sense the presence of captives somewhere close.""";
                category = "Recondo_Hostage_SmellHints";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    //==========================================
    // OBJECTIVE JAMMER (ACRE JAMMING) MODULE
    // Creates ACRE radio jamming objectives
    //==========================================
    class Recondo_Module_ObjectiveJammer: Module_F {
        scope = 2;
        displayName = "Objective - Jamming ACRE";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleObjectiveJammer";
        functionPriority = 4;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 0;
        canSetArea = 0;
        
        class ModuleDescription: ModuleDescription {
            description = "Creates ACRE radio jamming objectives using compositions. When the jammer object is destroyed, jamming stops. Sync to Intel module for intel integration.";
            sync[] = {"Recondo_Module_Intel"};
        };
        
        class Attributes: AttributesBase {
            
            // ========================================
            // GENERAL SETTINGS
            // ========================================
            class ObjectiveName {
                displayName = "GENERAL - Objective Name";
                tooltip = "Display name for this jammer objective type.";
                control = "Edit";
                property = "Recondo_Jammer_ObjectiveName";
                expression = "_this setVariable ['objectivename', _value, true];";
                typeName = "STRING";
                defaultValue = """Radio Jammer""";
                category = "Recondo_Jammer_General";
            };
            class ObjectiveDesc {
                displayName = "Objective Description";
                tooltip = "Description of this objective type for intel/tasks.";
                control = "EditMulti5";
                property = "Recondo_Jammer_ObjectiveDesc";
                expression = "_this setVariable ['objectivedesc', _value, true];";
                typeName = "STRING";
                defaultValue = """An enemy radio jamming station disrupting communications.""";
                category = "Recondo_Jammer_General";
            };
            class IntelBoardCategoryName {
                displayName = "Intel Board Category Name";
                tooltip = "Custom category name displayed on the Intel Board. Leave blank for default ('JAMMER INSTALLATIONS').";
                control = "Edit";
                property = "Recondo_Jammer_IntelBoardCategoryName";
                expression = "_this setVariable ['intelboardcategoryname', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_Jammer_General";
            };
            class MarkerPrefix {
                displayName = "Marker Prefix";
                tooltip = "Prefix for invisible markers (e.g., JAMMER_ for JAMMER_1, JAMMER_2, etc.)";
                control = "Edit";
                property = "Recondo_Jammer_MarkerPrefix";
                expression = "_this setVariable ['markerprefix', _value, true];";
                typeName = "STRING";
                defaultValue = """JAMMER_""";
                category = "Recondo_Jammer_General";
            };
            class ActiveLocationCount {
                displayName = "Active Location Count";
                tooltip = "Number of markers to spawn jammers at. Locations are randomly selected from available markers with the prefix.";
                control = "Edit";
                property = "Recondo_Jammer_ActiveLocationCount";
                expression = "_this setVariable ['activelocationcount', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """1""";
                category = "Recondo_Jammer_General";
            };
            
            // ========================================
            // DEFAULT COMPOSITIONS (MOD-BUNDLED)
            // ========================================
            class UseTowerComposition {
                displayName = "COMPOSITIONS - Use Tower";
                tooltip = "Use the built-in Radio Tower composition (JAMMER_TOWER1.sqe). If both are enabled, one is randomly selected per location.";
                control = "Checkbox";
                property = "Recondo_Jammer_UseTowerComp";
                expression = "_this setVariable ['usetowercomp', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_Jammer_DefaultComp";
            };
            class UseCampComposition {
                displayName = "Use Camp";
                tooltip = "Use the built-in Camp composition (JAMMER_Camp1.sqe). If both are enabled, one is randomly selected per location.";
                control = "Checkbox";
                property = "Recondo_Jammer_UseCampComp";
                expression = "_this setVariable ['usecampcomp', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_Jammer_DefaultComp";
            };
            class ClearRadius {
                displayName = "Clear Radius";
                tooltip = "Radius around marker to clear terrain objects (trees, bushes, rocks).";
                control = "Edit";
                property = "Recondo_Jammer_ClearRadius";
                expression = "_this setVariable ['clearradius', _value, true];";
                typeName = "NUMBER";
                defaultValue = "25";
                category = "Recondo_Jammer_DefaultComp";
            };
            class DisableSimulation {
                displayName = "Disable Simulation";
                tooltip = "Disable simulation on composition objects (except the destroyable jammer). Improves performance but objects won't react to physics/explosions.";
                control = "Checkbox";
                property = "Recondo_Jammer_DisableSimulation";
                expression = "_this setVariable ['disablesimulation', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_Jammer_DefaultComp";
            };
            
            // ========================================
            // CUSTOM COMPOSITIONS (MISSION FOLDER)
            // ========================================
            class CustomCompositionPath {
                displayName = "CUSTOM - Folder Path";
                tooltip = "Path in mission folder for custom compositions (e.g., 'compositions'). Custom compositions are added to the pool alongside any enabled default compositions.";
                control = "Edit";
                property = "Recondo_Jammer_CustomCompPath";
                expression = "_this setVariable ['customcomppath', _value, true];";
                typeName = "STRING";
                defaultValue = """compositions""";
                category = "Recondo_Jammer_CustomComp";
            };
            class CustomActiveCompositions {
                displayName = "Active Compositions";
                tooltip = "List of custom composition filenames for active jammers (with or without .sqe extension). One per line or comma-separated. These must have matching destroyed versions with '_destroyed' suffix.";
                control = "EditCodeMulti5";
                property = "Recondo_Jammer_CustomActiveComps";
                expression = "_this setVariable ['customactivecomps', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_Jammer_CustomComp";
            };
            class CustomDestroyedCompositions {
                displayName = "Destroyed Compositions";
                tooltip = "List of custom composition filenames for destroyed jammers (with or without .sqe extension). Should match the order of Active Compositions. If empty, '_destroyed' suffix is auto-appended to active names.";
                control = "EditCodeMulti5";
                property = "Recondo_Jammer_CustomDestroyedComps";
                expression = "_this setVariable ['customdestroyedcomps', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_Jammer_CustomComp";
            };
            
            // ========================================
            // JAMMER SETTINGS
            // ========================================
            class JammerClassname {
                displayName = "JAMMER - Target Classname";
                tooltip = "Classname of the object in the composition that acts as the jammer. When destroyed, jamming stops.";
                control = "Edit";
                property = "Recondo_Jammer_JammerClassname";
                expression = "_this setVariable ['jammerclassname', _value, true];";
                typeName = "STRING";
                defaultValue = """Land_TTowerBig_1_F""";
                category = "Recondo_Jammer_Jammer";
            };
            class PartialJamRadius {
                displayName = "Partial Jam Radius";
                tooltip = "Maximum radius where jamming has any effect. Between Full and Partial radius, interference decreases linearly.";
                control = "Edit";
                property = "Recondo_Jammer_PartialJamRadius";
                expression = "_this setVariable ['partialjamradius', _value, true];";
                typeName = "NUMBER";
                defaultValue = "1000";
                category = "Recondo_Jammer_Jammer";
            };
            class FullJamRadius {
                displayName = "Full Jam Radius";
                tooltip = "Radius where jamming is at maximum strength. Must be less than Partial Jam Radius.";
                control = "Edit";
                property = "Recondo_Jammer_FullJamRadius";
                expression = "_this setVariable ['fulljamradius', _value, true];";
                typeName = "NUMBER";
                defaultValue = "800";
                category = "Recondo_Jammer_Jammer";
            };
            class JamStrength {
                displayName = "Jam Strength";
                tooltip = "Interference multiplier at full jam radius. Higher = stronger jamming. 49 matches Antistasi default.";
                control = "Edit";
                property = "Recondo_Jammer_JamStrength";
                expression = "_this setVariable ['jamstrength', _value, true];";
                typeName = "NUMBER";
                defaultValue = "49";
                category = "Recondo_Jammer_Jammer";
            };
            class SideToJam {
                displayName = "Side to Jam";
                tooltip = "Which side's radio communications are jammed by this jammer.";
                control = "Combo";
                property = "Recondo_Jammer_SideToJam";
                expression = "_this setVariable ['sidetojam', _value, true];";
                typeName = "NUMBER";
                class Values {
                    class OPFOR { name = "OPFOR (East)"; value = 0; };
                    class BLUFOR { name = "BLUFOR (West)"; value = 1; default = 1; };
                    class INDEP { name = "Independent"; value = 2; };
                };
                category = "Recondo_Jammer_Jammer";
            };
            
            // ========================================
            // SPAWNING SETTINGS
            // ========================================
            class SpawnMode {
                displayName = "SPAWNING - Spawn Mode";
                tooltip = "When to spawn the composition and AI.";
                control = "Combo";
                property = "Recondo_Jammer_SpawnMode";
                expression = "_this setVariable ['spawnmode', _value, true];";
                typeName = "NUMBER";
                class Values {
                    class Immediate { name = "Immediate"; value = 0; };
                    class Proximity { name = "Proximity Trigger"; value = 1; default = 1; };
                };
                category = "Recondo_Jammer_Spawning";
            };
            class CompositionTriggerRadius {
                displayName = "Composition Trigger Radius";
                tooltip = "Distance at which the composition is spawned when using proximity spawn mode.";
                control = "Edit";
                property = "Recondo_Jammer_CompositionTriggerRadius";
                expression = "_this setVariable ['compositiontriggerradius', _value, true];";
                typeName = "NUMBER";
                defaultValue = "800";
                category = "Recondo_Jammer_Spawning";
            };
            class AITriggerRadius {
                displayName = "AI Trigger Radius";
                tooltip = "Distance at which AI are spawned (closer than composition trigger).";
                control = "Edit";
                property = "Recondo_Jammer_AITriggerRadius";
                expression = "_this setVariable ['aitriggerradius', _value, true];";
                typeName = "NUMBER";
                defaultValue = "600";
                category = "Recondo_Jammer_Spawning";
            };
            class TriggerSide {
                displayName = "Trigger Side";
                tooltip = "Which side activates the proximity triggers.";
                control = "Combo";
                property = "Recondo_Jammer_TriggerSide";
                expression = "_this setVariable ['triggerside', _value, true];";
                typeName = "NUMBER";
                class Values {
                    class OPFOR { name = "OPFOR (East)"; value = 0; };
                    class BLUFOR { name = "BLUFOR (West)"; value = 1; default = 1; };
                    class INDEP { name = "Independent"; value = 2; };
                    class ANY { name = "Any"; value = 3; };
                };
                category = "Recondo_Jammer_Spawning";
            };
            class SimulationDistance {
                displayName = "Simulation Distance";
                tooltip = "Distance at which simulation is enabled for spawned AI and objects. Entities start with simulation disabled and are enabled when players approach. Set to 0 to disable this feature (entities always simulated).";
                control = "Edit";
                property = "Recondo_Jammer_SimulationDistance";
                expression = "_this setVariable ['simulationdistance', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """1000""";
                category = "Recondo_Jammer_Spawning";
            };
            
            // ========================================
            // SENTRY AI SETTINGS
            // ========================================
            class SentryClassnames {
                displayName = "SENTRY AI - Classnames";
                tooltip = "Unit classnames for sentry guards. One per line or comma-separated. Leave empty for no sentries.";
                control = "EditCodeMulti5";
                property = "Recondo_Jammer_SentryClassnames";
                expression = "_this setVariable ['sentryclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_Jammer_SentryAI";
            };
            class SentryMinCount {
                displayName = "Minimum Sentries";
                tooltip = "Minimum number of sentry units to spawn.";
                control = "Edit";
                property = "Recondo_Jammer_SentryMinCount";
                expression = "_this setVariable ['sentrymincount', _value, true];";
                typeName = "NUMBER";
                defaultValue = "2";
                category = "Recondo_Jammer_SentryAI";
            };
            class SentryMaxCount {
                displayName = "Maximum Sentries";
                tooltip = "Maximum number of sentry units to spawn.";
                control = "Edit";
                property = "Recondo_Jammer_SentryMaxCount";
                expression = "_this setVariable ['sentrymaxcount', _value, true];";
                typeName = "NUMBER";
                defaultValue = "4";
                category = "Recondo_Jammer_SentryAI";
            };
            class SentryBuildingRadius {
                displayName = "Building Search Radius";
                tooltip = "Radius to search for building positions for sentries. Sentries prefer buildings, then fall back to positions within 3m of composition center.";
                control = "Edit";
                property = "Recondo_Jammer_SentryBuildingRadius";
                expression = "_this setVariable ['sentrybuildingradius', _value, true];";
                typeName = "NUMBER";
                defaultValue = "50";
                category = "Recondo_Jammer_SentryAI";
            };
            class SentrySide {
                displayName = "AI Side";
                tooltip = "Side for sentry and patrol AI units.";
                control = "Combo";
                property = "Recondo_Jammer_SentrySide";
                expression = "_this setVariable ['sentryside', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0";
                class Values {
                    class OPFOR { name = "OPFOR (East)"; value = 0; default = 1; };
                    class BLUFOR { name = "BLUFOR (West)"; value = 1; };
                    class INDEP { name = "Independent"; value = 2; };
                };
                category = "Recondo_Jammer_SentryAI";
            };
            
            // ========================================
            // PATROL AI SETTINGS
            // ========================================
            class PatrolClassnames {
                displayName = "PATROL AI - Classnames";
                tooltip = "Unit classnames for roving patrols. One per line or comma-separated. Leave empty for no patrols.";
                control = "EditCodeMulti5";
                property = "Recondo_Jammer_PatrolClassnames";
                expression = "_this setVariable ['patrolclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_Jammer_PatrolAI";
            };
            class PatrolCount {
                displayName = "Number of Patrols";
                tooltip = "How many patrol groups to spawn.";
                control = "Edit";
                property = "Recondo_Jammer_PatrolCount";
                expression = "_this setVariable ['patrolcount', _value, true];";
                typeName = "NUMBER";
                defaultValue = "1";
                category = "Recondo_Jammer_PatrolAI";
            };
            class PatrolMinSize {
                displayName = "Minimum Patrol Size";
                tooltip = "Minimum units per patrol group.";
                control = "Edit";
                property = "Recondo_Jammer_PatrolMinSize";
                expression = "_this setVariable ['patrolminsize', _value, true];";
                typeName = "NUMBER";
                defaultValue = "2";
                category = "Recondo_Jammer_PatrolAI";
            };
            class PatrolMaxSize {
                displayName = "Maximum Patrol Size";
                tooltip = "Maximum units per patrol group.";
                control = "Edit";
                property = "Recondo_Jammer_PatrolMaxSize";
                expression = "_this setVariable ['patrolmaxsize', _value, true];";
                typeName = "NUMBER";
                defaultValue = "4";
                category = "Recondo_Jammer_PatrolAI";
            };
            class PatrolRadius {
                displayName = "Patrol Radius";
                tooltip = "Radius around composition that patrols will move within.";
                control = "Edit";
                property = "Recondo_Jammer_PatrolRadius";
                expression = "_this setVariable ['patrolradius', _value, true];";
                typeName = "NUMBER";
                defaultValue = "75";
                category = "Recondo_Jammer_PatrolAI";
            };
            class PatrolFormation {
                displayName = "Patrol Formation";
                tooltip = "Formation for patrol groups.";
                control = "Combo";
                property = "Recondo_Jammer_PatrolFormation";
                expression = "_this setVariable ['patrolformation', _value, true];";
                typeName = "STRING";
                class Values {
                    class Wedge { name = "Wedge"; value = "WEDGE"; default = 1; };
                    class Line { name = "Line"; value = "LINE"; };
                    class Column { name = "Column"; value = "COLUMN"; };
                    class File { name = "File"; value = "FILE"; };
                    class Stag { name = "Staggered Column"; value = "STAG COLUMN"; };
                    class Vee { name = "Vee"; value = "VEE"; };
                };
                category = "Recondo_Jammer_PatrolAI";
            };
            
            // ========================================
            // INTEL SETTINGS
            // ========================================
            class IntelWeight {
                displayName = "INTEL - Weight";
                tooltip = "Priority weight for intel reveals (higher = more likely to be revealed first).";
                control = "Edit";
                property = "Recondo_Jammer_IntelWeight";
                expression = "_this setVariable ['intelweight', _value, true];";
                typeName = "NUMBER";
                defaultValue = "5";
                category = "Recondo_Jammer_Intel";
            };
            class IntelRevealMessagesDoc {
                displayName = "Intel Reveal Messages (Documents)";
                tooltip = "Messages shown when intel from documents reveals this jammer location. One per line. Placeholders: %GRID%, %NAME%, %OBJECTIVE%. Random selection. Leave blank for default.";
                control = "EditCodeMulti5";
                property = "Recondo_Jammer_IntelRevealMessagesDoc";
                expression = "_this setVariable ['intelrevealmessagesdoc', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_Jammer_Intel";
            };
            class IntelRevealMessagesPOW {
                displayName = "Intel Reveal Messages (POW)";
                tooltip = "Messages shown when intel from POW interrogation reveals this jammer location. One per line. Placeholders: %GRID%, %NAME%, %OBJECTIVE%. Random selection. Leave blank for default.";
                control = "EditCodeMulti5";
                property = "Recondo_Jammer_IntelRevealMessagesPOW";
                expression = "_this setVariable ['intelrevealmessagespow', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_Jammer_Intel";
            };
            
            // ========================================
            // DEBUG SETTINGS
            // ========================================
            class DebugLogging {
                displayName = "DEBUG - Enable Logging";
                tooltip = "Log detailed debug information to RPT file.";
                control = "Checkbox";
                property = "Recondo_Jammer_DebugLogging";
                expression = "_this setVariable ['debuglogging', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_Jammer_Debug";
            };
            class DebugMarkers {
                displayName = "Enable Debug Markers";
                tooltip = "Show debug markers for jammer positions and jam radii.";
                control = "Checkbox";
                property = "Recondo_Jammer_DebugMarkers";
                expression = "_this setVariable ['debugmarkers', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_Jammer_Debug";
            };
            
            // ========================================
            // NIGHT LIGHTS
            // ========================================
            class EnableNightLights {
                displayName = "NIGHT LIGHTS - Enable Night Lights";
                tooltip = "Enable warm lights inside buildings at night. Lights turn on automatically when dark (sunOrMoon < 0.5).";
                control = "Checkbox";
                property = "Recondo_Jammer_EnableNightLights";
                expression = "_this setVariable ['enablenightlights', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_Jammer_NightLights";
            };
            
            // ========================================
            // SMELL HINTS
            // ========================================
            class EnableSmellHints {
                displayName = "Enable Smell Hints";
                tooltip = "Shows atmospheric text hints when players approach jammer locations.";
                control = "Checkbox";
                property = "Recondo_Jammer_EnableSmellHints";
                expression = "_this setVariable ['enablesmellhints', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_Jammer_SmellHints";
            };
            class SmellHintRadius {
                displayName = "Smell Hint Radius";
                tooltip = "Distance (meters) at which players detect the jammer presence.";
                control = "Edit";
                property = "Recondo_Jammer_SmellHintRadius";
                expression = "_this setVariable ['smellhintradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """200""";
                category = "Recondo_Jammer_SmellHints";
            };
            class SmellHintMessages {
                displayName = "Smell Hint Messages";
                tooltip = "Comma-separated list of atmospheric messages. One is randomly chosen per trigger.";
                control = "EditMulti5";
                property = "Recondo_Jammer_SmellHintMessages";
                expression = "_this setVariable ['smellhintmessages', _value, true];";
                typeName = "STRING";
                defaultValue = """You sense a low electricity hum in the air...,A faint buzzing fills your ears...,Static crackles at the edge of your hearing...,The air feels charged with electromagnetic energy.""";
                category = "Recondo_Jammer_SmellHints";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    //==========================================
    // WEATHER CONTROL MODULE
    // Controls weather with ACE interactions
    //==========================================
    class Recondo_Module_Weather: Module_F {
        scope = 2;
        displayName = "Weather Control";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleWeather";
        functionPriority = 1;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 0;
        canSetArea = 0;
        
        class ModuleDescription: ModuleDescription {
            description = "Controls mission weather. Sets default weather on mission start. Sync to objects to add ACE weather control interactions for admins.";
            sync[] = {};
        };
        
        class Attributes: AttributesBase {
            
            // ========================================
            // GENERAL SETTINGS
            // ========================================
            class DefaultWeather {
                displayName = "GENERAL - Default Weather";
                tooltip = "Weather preset applied on mission start.";
                control = "Combo";
                property = "Recondo_Weather_DefaultWeather";
                expression = "_this setVariable ['defaultweather', _value, true];";
                typeName = "STRING";
                defaultValue = """clear""";
                category = "Recondo_Weather_General";
                class Values {
                    class Clear { name = "Clear Sunny"; value = "clear"; };
                    class Overcast { name = "Overcast"; value = "overcast"; };
                    class LightRain { name = "Light Rain"; value = "lightrain"; };
                    class Thunderstorm { name = "Thunderstorm"; value = "thunderstorm"; };
                    class Fog { name = "Fog"; value = "fog"; };
                    class DenseFog { name = "Dense Fog"; value = "densefog"; };
                };
            };
            class TransitionTime {
                displayName = "Transition Time";
                tooltip = "Time in seconds for weather to transition.";
                control = "Edit";
                property = "Recondo_Weather_TransitionTime";
                expression = "_this setVariable ['transitiontime', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """30""";
                category = "Recondo_Weather_General";
            };
            
            // ========================================
            // ACCESS SETTINGS
            // ========================================
            class AdminOnly {
                displayName = "ACCESS - Admin Only";
                tooltip = "Only server admins can change weather via ACE interactions.";
                control = "Checkbox";
                property = "Recondo_Weather_AdminOnly";
                expression = "_this setVariable ['adminonly', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_Weather_Access";
            };
            
            // ========================================
            // DEBUG SETTINGS
            // ========================================
            // TIME CONTROL SETTINGS
            // ========================================
            class EnableTimeControl {
                displayName = "TIME - Enable Time Control";
                tooltip = "Enable time of day control via ACE interaction.";
                control = "Checkbox";
                property = "Recondo_Weather_EnableTimeControl";
                expression = "_this setVariable ['enabletimecontrol', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_Weather_Time";
            };
            class DefaultTime {
                displayName = "Default Time";
                tooltip = "Starting time of day preset.";
                control = "Combo";
                property = "Recondo_Weather_DefaultTime";
                expression = "_this setVariable ['defaulttime', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0";
                category = "Recondo_Weather_Time";
                class Values {
                    class None { name = "No Change"; value = 0; };
                    class Dawn { name = "Dawn (05:00)"; value = 1; };
                    class Morning { name = "Morning (08:00)"; value = 2; };
                    class Noon { name = "Noon (12:00)"; value = 3; };
                    class Afternoon { name = "Afternoon (15:00)"; value = 4; };
                    class Dusk { name = "Dusk (19:00)"; value = 5; };
                    class Night { name = "Night (22:00)"; value = 6; };
                    class Midnight { name = "Midnight (00:00)"; value = 7; };
                };
            };
            
            // ========================================
            // DEBUG SETTINGS
            // ========================================
            class DebugLogging {
                displayName = "DEBUG - Enable Logging";
                tooltip = "Log weather changes to RPT file.";
                control = "Checkbox";
                property = "Recondo_Weather_DebugLogging";
                expression = "_this setVariable ['debuglogging', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_Weather_Debug";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    //==========================================
    // INTRO SCREEN MODULE
    // Displays cinematic intro on mission start
    //==========================================
    class Recondo_Module_IntroScreen: Module_F {
        scope = 2;
        displayName = "Intro Screen";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleIntroScreen";
        functionPriority = 10;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 0;
        canSetArea = 0;
        
        class ModuleDescription: ModuleDescription {
            description = "Displays a cinematic intro screen with story panels and title card on mission start. Runs on all clients.";
            sync[] = {};
        };
        
        class Attributes: AttributesBase {
            
            // ========================================
            // TITLE SETTINGS
            // ========================================
            class MissionTitle {
                displayName = "TITLE - Mission Title";
                tooltip = "Main title text displayed after story panels.";
                control = "Edit";
                property = "Recondo_Intro_MissionTitle";
                expression = "_this setVariable ['missiontitle', _value, true];";
                typeName = "STRING";
                defaultValue = """MISSION TITLE""";
                category = "Recondo_Intro_Title";
            };
            class TitleSize {
                displayName = "Title Size";
                tooltip = "Font size for title (1-7, larger = bigger).";
                control = "Edit";
                property = "Recondo_Intro_TitleSize";
                expression = "_this setVariable ['titlesize', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """5""";
                category = "Recondo_Intro_Title";
            };
            class TitleColor {
                displayName = "Title Color";
                tooltip = "Hex color for title text (e.g., #FFFFFF for white).";
                control = "Edit";
                property = "Recondo_Intro_TitleColor";
                expression = "_this setVariable ['titlecolor', _value, true];";
                typeName = "STRING";
                defaultValue = """#FFFFFF""";
                category = "Recondo_Intro_Title";
            };
            class Subtitle {
                displayName = "Subtitle";
                tooltip = "Subtitle text (location, date, etc.). Displayed above title.";
                control = "Edit";
                property = "Recondo_Intro_Subtitle";
                expression = "_this setVariable ['subtitle', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_Intro_Title";
            };
            class SubtitleColor {
                displayName = "Subtitle Color";
                tooltip = "Hex color for subtitle text.";
                control = "Edit";
                property = "Recondo_Intro_SubtitleColor";
                expression = "_this setVariable ['subtitlecolor', _value, true];";
                typeName = "STRING";
                defaultValue = """#FFFFFF""";
                category = "Recondo_Intro_Title";
            };
            
            // ========================================
            // STORY PANELS
            // ========================================
            class StoryPanel1 {
                displayName = "STORY - Panel 1";
                tooltip = "First story panel text. Leave empty to skip.";
                control = "EditCodeMulti5";
                property = "Recondo_Intro_StoryPanel1";
                expression = "_this setVariable ['storypanel1', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_Intro_Story";
            };
            class StoryPanel2 {
                displayName = "Panel 2";
                tooltip = "Second story panel text. Leave empty to skip.";
                control = "EditCodeMulti5";
                property = "Recondo_Intro_StoryPanel2";
                expression = "_this setVariable ['storypanel2', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_Intro_Story";
            };
            class StoryPanel3 {
                displayName = "Panel 3";
                tooltip = "Third story panel text. Leave empty to skip.";
                control = "EditCodeMulti5";
                property = "Recondo_Intro_StoryPanel3";
                expression = "_this setVariable ['storypanel3', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_Intro_Story";
            };
            class StoryPanel4 {
                displayName = "Panel 4";
                tooltip = "Fourth story panel text. Leave empty to skip.";
                control = "EditCodeMulti5";
                property = "Recondo_Intro_StoryPanel4";
                expression = "_this setVariable ['storypanel4', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_Intro_Story";
            };
            class StoryPanel5 {
                displayName = "Panel 5";
                tooltip = "Fifth story panel text. Leave empty to skip.";
                control = "EditCodeMulti5";
                property = "Recondo_Intro_StoryPanel5";
                expression = "_this setVariable ['storypanel5', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_Intro_Story";
            };
            class StoryTextColor {
                displayName = "Story Text Color";
                tooltip = "Hex color for all story panel text.";
                control = "Edit";
                property = "Recondo_Intro_StoryTextColor";
                expression = "_this setVariable ['storytextcolor', _value, true];";
                typeName = "STRING";
                defaultValue = """#FFFFFF""";
                category = "Recondo_Intro_Story";
            };
            
            // ========================================
            // TIMING SETTINGS
            // ========================================
            class InitialDelay {
                displayName = "TIMING - Initial Delay";
                tooltip = "Seconds before intro starts (screen stays black).";
                control = "Edit";
                property = "Recondo_Intro_InitialDelay";
                expression = "_this setVariable ['initialdelay', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """3""";
                category = "Recondo_Intro_Timing";
            };
            class PanelDuration {
                displayName = "Panel Duration";
                tooltip = "Seconds each story panel is displayed.";
                control = "Edit";
                property = "Recondo_Intro_PanelDuration";
                expression = "_this setVariable ['panelduration', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """10""";
                category = "Recondo_Intro_Timing";
            };
            class TitleDuration {
                displayName = "Title Duration";
                tooltip = "Seconds the title card is displayed.";
                control = "Edit";
                property = "Recondo_Intro_TitleDuration";
                expression = "_this setVariable ['titleduration', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """6""";
                category = "Recondo_Intro_Timing";
            };
            class FadeInTime {
                displayName = "Fade In Time";
                tooltip = "Seconds to fade from black to gameplay.";
                control = "Edit";
                property = "Recondo_Intro_FadeInTime";
                expression = "_this setVariable ['fadeintime', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """3""";
                category = "Recondo_Intro_Timing";
            };
            
            // ========================================
            // AUDIO SETTINGS
            // ========================================
            class MuteAudio {
                displayName = "AUDIO - Mute During Intro";
                tooltip = "Mute all audio during intro sequence.";
                control = "Checkbox";
                property = "Recondo_Intro_MuteAudio";
                expression = "_this setVariable ['muteaudio', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_Intro_Audio";
            };
            
            // ========================================
            // DEBUG SETTINGS
            // ========================================
            class DebugLogging {
                displayName = "DEBUG - Enable Logging";
                tooltip = "Log intro sequence to RPT file.";
                control = "Checkbox";
                property = "Recondo_Intro_DebugLogging";
                expression = "_this setVariable ['debuglogging', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_Intro_Debug";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    // ========================================
    // PERFORMANCE MONITORING MODULE
    // ========================================
    class Recondo_Module_PerfMonitor: Module_F {
        scope = 2;
        displayName = "Performance Monitoring";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_modulePerfMonitor";
        functionPriority = 1;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 0;
        canSetArea = 0;
        
        class ModuleDescription: ModuleDescription {
            description = "Provides real-time performance monitoring for admins via ACE self-interaction menu. Tracks FPS, AI counts, object counts, active scripts, and more. Requires ACE3 and CBA_A3. Only visible to logged-in admins.";
            sync[] = {};
        };
        
        class Attributes: AttributesBase {
            
            // ========================================
            // MONITORING SETTINGS
            // ========================================
            class UpdateInterval {
                displayName = "MONITORING - Update Interval";
                tooltip = "How often to refresh metrics (in seconds). Minimum 1 second.";
                control = "Edit";
                property = "Recondo_Perf_UpdateInterval";
                expression = "_this setVariable ['updateinterval', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """5""";
                category = "Recondo_Perf_Monitoring";
            };
            
            class AutoStart {
                displayName = "Auto-Start Monitoring";
                tooltip = "Automatically start the monitoring loop when the mission begins.";
                control = "Checkbox";
                property = "Recondo_Perf_AutoStart";
                expression = "_this setVariable ['autostart', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_Perf_Monitoring";
            };
            
            // ========================================
            // DISPLAY SETTINGS
            // ========================================
            class DisplayMode {
                displayName = "DISPLAY - Output Mode";
                tooltip = "How to display metrics when monitoring is active.";
                control = "Combo";
                property = "Recondo_Perf_DisplayMode";
                expression = "_this setVariable ['displaymode', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0";
                category = "Recondo_Perf_Display";
                class Values {
                    class Hint {
                        name = "Hint (Screen Overlay)";
                        value = 0;
                        default = 1;
                    };
                    class SystemChat {
                        name = "System Chat";
                        value = 1;
                    };
                    class RPTOnly {
                        name = "RPT Log Only (No Visual)";
                        value = 2;
                    };
                };
            };
            
            class ShowLocalOnly {
                displayName = "Local Metrics Only";
                tooltip = "Each admin sees their own machine's metrics. If disabled, server metrics are broadcast to all admins.";
                control = "Checkbox";
                property = "Recondo_Perf_ShowLocalOnly";
                expression = "_this setVariable ['showlocalonly', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_Perf_Display";
            };
            
            // ========================================
            // LOGGING SETTINGS
            // ========================================
            class LogToRPT {
                displayName = "LOGGING - Write to RPT";
                tooltip = "Write detailed metrics to server RPT file each update cycle.";
                control = "Checkbox";
                property = "Recondo_Perf_LogToRPT";
                expression = "_this setVariable ['logtorpt', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_Perf_Logging";
            };
            
            // ========================================
            // DEBUG SETTINGS
            // ========================================
            class DebugLogging {
                displayName = "DEBUG - Enable Debug Logging";
                tooltip = "Log additional debug information to RPT file.";
                control = "Checkbox";
                property = "Recondo_Perf_DebugLogging";
                expression = "_this setVariable ['debuglogging', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_Perf_Debug";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    // ========================================
    // AMBIENT SOUND TRIGGERS MODULE
    // ========================================
    class Recondo_Module_AmbientSound: Module_F {
        scope = 2;
        displayName = "Ambient Sound Triggers";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleAmbientSound";
        functionPriority = 5;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 0;
        canSetArea = 0;
        
        class ModuleDescription: ModuleDescription {
            description = "Creates trigger areas that play 3D positioned ambient sounds when units enter. Simulates wildlife (monkeys, birds, etc.) being disturbed by movement. Supports default sounds and custom mission sounds.";
            sync[] = {};
        };
        
        class Attributes: AttributesBase {
            
            // ========================================
            // GENERAL SETTINGS
            // ========================================
            class MarkerPrefix {
                displayName = "GENERAL - Marker Prefix";
                tooltip = "Prefix for invisible markers that define trigger areas. Example: 'AMBIENT_' will find markers AMBIENT_1, AMBIENT_2, etc.";
                control = "Edit";
                property = "Recondo_Ambient_MarkerPrefix";
                expression = "_this setVariable ['markerprefix', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_Ambient_General";
            };
            
            // ========================================
            // TRIGGER SETTINGS
            // ========================================
            class TriggerRadius {
                displayName = "TRIGGER - Radius (meters)";
                tooltip = "Radius of the circular trigger area around each marker.";
                control = "Edit";
                property = "Recondo_Ambient_TriggerRadius";
                expression = "_this setVariable ['triggerradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """50""";
                category = "Recondo_Ambient_Trigger";
            };
            class TriggerHeight {
                displayName = "Trigger Height (meters)";
                tooltip = "Vertical height of trigger. Units above this height won't activate (prevents helicopters triggering ground sounds).";
                control = "Edit";
                property = "Recondo_Ambient_TriggerHeight";
                expression = "_this setVariable ['triggerheight', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """10""";
                category = "Recondo_Ambient_Trigger";
            };
            class TriggerSide {
                displayName = "Trigger Side";
                tooltip = "Which side's units will activate the trigger.";
                control = "Combo";
                property = "Recondo_Ambient_TriggerSide";
                expression = "_this setVariable ['triggerside', _value, true];";
                typeName = "STRING";
                defaultValue = """WEST""";
                category = "Recondo_Ambient_Trigger";
                class Values {
                    class West { name = "BLUFOR (West)"; value = "WEST"; default = 1; };
                    class East { name = "OPFOR (East)"; value = "EAST"; };
                    class Guer { name = "Independent"; value = "GUER"; };
                    class Any { name = "Any Side"; value = "ANY"; };
                };
            };
            class TriggerTarget {
                displayName = "Trigger Target";
                tooltip = "Which unit types will activate the trigger.";
                control = "Combo";
                property = "Recondo_Ambient_TriggerTarget";
                expression = "_this setVariable ['triggertarget', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0";
                category = "Recondo_Ambient_Trigger";
                class Values {
                    class PlayersOnly { name = "Players Only"; value = 0; default = 1; };
                    class AIOnly { name = "AI Only"; value = 1; };
                    class Both { name = "Both Players and AI"; value = 2; };
                };
            };
            class Cooldown {
                displayName = "Cooldown (seconds)";
                tooltip = "Time before the trigger can activate again after playing a sound.";
                control = "Edit";
                property = "Recondo_Ambient_Cooldown";
                expression = "_this setVariable ['cooldown', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """60""";
                category = "Recondo_Ambient_Trigger";
            };
            class Delay {
                displayName = "Delay (seconds)";
                tooltip = "Delay between trigger activation and sound playback. Makes sounds feel more natural.";
                control = "Edit";
                property = "Recondo_Ambient_Delay";
                expression = "_this setVariable ['delay', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """10""";
                category = "Recondo_Ambient_Trigger";
            };
            
            // ========================================
            // SOUND SETTINGS
            // ========================================
            class SoundMode {
                displayName = "SOUND - Selection Mode";
                tooltip = "How sounds are selected when trigger activates.";
                control = "Combo";
                property = "Recondo_Ambient_SoundMode";
                expression = "_this setVariable ['soundmode', _value, true];";
                typeName = "NUMBER";
                defaultValue = "1";
                category = "Recondo_Ambient_Sound";
                class Values {
                    class Single { name = "Single Sound"; value = 0; };
                    class Pool { name = "Random from Pool"; value = 1; default = 1; };
                };
            };
            class SoundCategory {
                displayName = "Sound Category";
                tooltip = "Category of default sounds to use. Only used if custom sounds are not specified.";
                control = "Combo";
                property = "Recondo_Ambient_SoundCategory";
                expression = "_this setVariable ['soundcategory', _value, true];";
                typeName = "STRING";
                defaultValue = """wildlife""";
                category = "Recondo_Ambient_Sound";
                class Values {
                    class Wildlife { name = "Wildlife (Monkeys)"; value = "wildlife"; default = 1; };
                };
            };
            class SingleSound {
                displayName = "Single Sound Override";
                tooltip = "Full path to a specific sound file. Only used in Single mode. Leave empty to use category sounds.";
                control = "Edit";
                property = "Recondo_Ambient_SingleSound";
                expression = "_this setVariable ['singlesound', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_Ambient_Sound";
            };
            class SoundDistance {
                displayName = "Sound Distance (meters)";
                tooltip = "Maximum distance at which the sound can be heard.";
                control = "Edit";
                property = "Recondo_Ambient_SoundDistance";
                expression = "_this setVariable ['sounddistance', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """100""";
                category = "Recondo_Ambient_Sound";
            };
            class SoundVolume {
                displayName = "Sound Volume";
                tooltip = "Volume multiplier for the sound (0.0 - 2.0).";
                control = "Slider";
                property = "Recondo_Ambient_SoundVolume";
                expression = "_this setVariable ['soundvolume', _value, true];";
                typeName = "NUMBER";
                defaultValue = "1";
                sliderRange[] = {0, 2};
                sliderStep = 0.1;
                category = "Recondo_Ambient_Sound";
            };
            class SoundOriginDistance {
                displayName = "Sound Origin Distance (meters)";
                tooltip = "How far from the triggering unit the sound originates. The sound plays at a random direction at this distance from the player.";
                control = "Edit";
                property = "Recondo_Ambient_SoundOriginDistance";
                expression = "_this setVariable ['soundorigindistance', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """5""";
                category = "Recondo_Ambient_Sound";
            };
            class SoundOriginHeight {
                displayName = "Sound Origin Height (meters)";
                tooltip = "Height above ground level where the sound originates. Higher values simulate sounds from trees/canopy.";
                control = "Edit";
                property = "Recondo_Ambient_SoundOriginHeight";
                expression = "_this setVariable ['soundoriginheight', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """4""";
                category = "Recondo_Ambient_Sound";
            };
            
            // ========================================
            // CUSTOM SOUNDS
            // ========================================
            class CustomSoundsPath {
                displayName = "CUSTOM - Mission Folder Path";
                tooltip = "Path to custom sounds in mission folder (e.g., 'sounds\\ambient'). Leave empty to use default mod sounds.";
                control = "Edit";
                property = "Recondo_Ambient_CustomSoundsPath";
                expression = "_this setVariable ['customsoundspath', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_Ambient_Custom";
            };
            class CustomSoundsList {
                displayName = "Custom Sounds List";
                tooltip = "Comma-separated list of sound filenames in the custom path (e.g., 'monkey1.ogg, monkey2.ogg').";
                control = "EditMulti3";
                property = "Recondo_Ambient_CustomSoundsList";
                expression = "_this setVariable ['customsoundslist', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_Ambient_Custom";
            };
            
            // ========================================
            // DEBUG SETTINGS
            // ========================================
            class DebugLogging {
                displayName = "DEBUG - Enable Logging";
                tooltip = "Log detailed debug information to RPT file.";
                control = "Checkbox";
                property = "Recondo_Ambient_DebugLogging";
                expression = "_this setVariable ['debuglogging', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_Ambient_Debug";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    // ========================================
    // SIDE CHAT AND MARKER CONTROL MODULE
    // ========================================
    class Recondo_Module_ChatControl: Module_F {
        scope = 2;
        displayName = "Side Chat and Marker Control";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleChatControl";
        functionPriority = 1;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 0;
        
        class ModuleDescription: ModuleDescription {
            description = "Controls text chat, voice chat, and map marker permissions per side and channel. Check a box to DISABLE that feature.";
            sync[] = {};
        };
        
        class Attributes: AttributesBase {
            
            // ========================================
            // TEXT CHAT - OPFOR
            // ========================================
            class TextOPFOR_Global {
                displayName = "TEXT OPFOR - Disable Global";
                tooltip = "Disable Global (0) text chat for OPFOR";
                control = "Checkbox";
                property = "Recondo_CC_TextOPFOR_Global";
                expression = "_this setVariable ['textopfor_global', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_TextOPFOR";
            };
            class TextOPFOR_Side {
                displayName = "Disable Side";
                tooltip = "Disable Side (1) text chat for OPFOR";
                control = "Checkbox";
                property = "Recondo_CC_TextOPFOR_Side";
                expression = "_this setVariable ['textopfor_side', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_TextOPFOR";
            };
            class TextOPFOR_Command {
                displayName = "Disable Command";
                tooltip = "Disable Command (2) text chat for OPFOR";
                control = "Checkbox";
                property = "Recondo_CC_TextOPFOR_Command";
                expression = "_this setVariable ['textopfor_command', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_TextOPFOR";
            };
            class TextOPFOR_Group {
                displayName = "Disable Group";
                tooltip = "Disable Group (3) text chat for OPFOR";
                control = "Checkbox";
                property = "Recondo_CC_TextOPFOR_Group";
                expression = "_this setVariable ['textopfor_group', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_TextOPFOR";
            };
            class TextOPFOR_Vehicle {
                displayName = "Disable Vehicle";
                tooltip = "Disable Vehicle (4) text chat for OPFOR";
                control = "Checkbox";
                property = "Recondo_CC_TextOPFOR_Vehicle";
                expression = "_this setVariable ['textopfor_vehicle', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_TextOPFOR";
            };
            class TextOPFOR_Direct {
                displayName = "Disable Direct";
                tooltip = "Disable Direct (5) text chat for OPFOR";
                control = "Checkbox";
                property = "Recondo_CC_TextOPFOR_Direct";
                expression = "_this setVariable ['textopfor_direct', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_TextOPFOR";
            };
            
            // ========================================
            // TEXT CHAT - BLUFOR
            // ========================================
            class TextBLUFOR_Global {
                displayName = "TEXT BLUFOR - Disable Global";
                tooltip = "Disable Global (0) text chat for BLUFOR";
                control = "Checkbox";
                property = "Recondo_CC_TextBLUFOR_Global";
                expression = "_this setVariable ['textblufor_global', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_TextBLUFOR";
            };
            class TextBLUFOR_Side {
                displayName = "Disable Side";
                tooltip = "Disable Side (1) text chat for BLUFOR";
                control = "Checkbox";
                property = "Recondo_CC_TextBLUFOR_Side";
                expression = "_this setVariable ['textblufor_side', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_TextBLUFOR";
            };
            class TextBLUFOR_Command {
                displayName = "Disable Command";
                tooltip = "Disable Command (2) text chat for BLUFOR";
                control = "Checkbox";
                property = "Recondo_CC_TextBLUFOR_Command";
                expression = "_this setVariable ['textblufor_command', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_TextBLUFOR";
            };
            class TextBLUFOR_Group {
                displayName = "Disable Group";
                tooltip = "Disable Group (3) text chat for BLUFOR";
                control = "Checkbox";
                property = "Recondo_CC_TextBLUFOR_Group";
                expression = "_this setVariable ['textblufor_group', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_TextBLUFOR";
            };
            class TextBLUFOR_Vehicle {
                displayName = "Disable Vehicle";
                tooltip = "Disable Vehicle (4) text chat for BLUFOR";
                control = "Checkbox";
                property = "Recondo_CC_TextBLUFOR_Vehicle";
                expression = "_this setVariable ['textblufor_vehicle', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_TextBLUFOR";
            };
            class TextBLUFOR_Direct {
                displayName = "Disable Direct";
                tooltip = "Disable Direct (5) text chat for BLUFOR";
                control = "Checkbox";
                property = "Recondo_CC_TextBLUFOR_Direct";
                expression = "_this setVariable ['textblufor_direct', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_TextBLUFOR";
            };
            
            // ========================================
            // TEXT CHAT - INDEPENDENT
            // ========================================
            class TextIndependent_Global {
                displayName = "TEXT INDEPENDENT - Disable Global";
                tooltip = "Disable Global (0) text chat for Independent";
                control = "Checkbox";
                property = "Recondo_CC_TextIndependent_Global";
                expression = "_this setVariable ['textindependent_global', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_TextIndependent";
            };
            class TextIndependent_Side {
                displayName = "Disable Side";
                tooltip = "Disable Side (1) text chat for Independent";
                control = "Checkbox";
                property = "Recondo_CC_TextIndependent_Side";
                expression = "_this setVariable ['textindependent_side', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_TextIndependent";
            };
            class TextIndependent_Command {
                displayName = "Disable Command";
                tooltip = "Disable Command (2) text chat for Independent";
                control = "Checkbox";
                property = "Recondo_CC_TextIndependent_Command";
                expression = "_this setVariable ['textindependent_command', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_TextIndependent";
            };
            class TextIndependent_Group {
                displayName = "Disable Group";
                tooltip = "Disable Group (3) text chat for Independent";
                control = "Checkbox";
                property = "Recondo_CC_TextIndependent_Group";
                expression = "_this setVariable ['textindependent_group', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_TextIndependent";
            };
            class TextIndependent_Vehicle {
                displayName = "Disable Vehicle";
                tooltip = "Disable Vehicle (4) text chat for Independent";
                control = "Checkbox";
                property = "Recondo_CC_TextIndependent_Vehicle";
                expression = "_this setVariable ['textindependent_vehicle', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_TextIndependent";
            };
            class TextIndependent_Direct {
                displayName = "Disable Direct";
                tooltip = "Disable Direct (5) text chat for Independent";
                control = "Checkbox";
                property = "Recondo_CC_TextIndependent_Direct";
                expression = "_this setVariable ['textindependent_direct', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_TextIndependent";
            };
            
            // ========================================
            // TEXT CHAT - CIVILIAN
            // ========================================
            class TextCivilian_Global {
                displayName = "TEXT CIVILIAN - Disable Global";
                tooltip = "Disable Global (0) text chat for Civilian";
                control = "Checkbox";
                property = "Recondo_CC_TextCivilian_Global";
                expression = "_this setVariable ['textcivilian_global', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_TextCivilian";
            };
            class TextCivilian_Side {
                displayName = "Disable Side";
                tooltip = "Disable Side (1) text chat for Civilian";
                control = "Checkbox";
                property = "Recondo_CC_TextCivilian_Side";
                expression = "_this setVariable ['textcivilian_side', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_TextCivilian";
            };
            class TextCivilian_Command {
                displayName = "Disable Command";
                tooltip = "Disable Command (2) text chat for Civilian";
                control = "Checkbox";
                property = "Recondo_CC_TextCivilian_Command";
                expression = "_this setVariable ['textcivilian_command', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_TextCivilian";
            };
            class TextCivilian_Group {
                displayName = "Disable Group";
                tooltip = "Disable Group (3) text chat for Civilian";
                control = "Checkbox";
                property = "Recondo_CC_TextCivilian_Group";
                expression = "_this setVariable ['textcivilian_group', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_TextCivilian";
            };
            class TextCivilian_Vehicle {
                displayName = "Disable Vehicle";
                tooltip = "Disable Vehicle (4) text chat for Civilian";
                control = "Checkbox";
                property = "Recondo_CC_TextCivilian_Vehicle";
                expression = "_this setVariable ['textcivilian_vehicle', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_TextCivilian";
            };
            class TextCivilian_Direct {
                displayName = "Disable Direct";
                tooltip = "Disable Direct (5) text chat for Civilian";
                control = "Checkbox";
                property = "Recondo_CC_TextCivilian_Direct";
                expression = "_this setVariable ['textcivilian_direct', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_TextCivilian";
            };
            
            // ========================================
            // MAP MARKERS - OPFOR
            // ========================================
            class MarkersOPFOR_Global {
                displayName = "MARKERS OPFOR - Disable Global";
                tooltip = "Disable Global (0) channel markers for OPFOR";
                control = "Checkbox";
                property = "Recondo_CC_MarkersOPFOR_Global";
                expression = "_this setVariable ['markersopfor_global', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_MarkersOPFOR";
            };
            class MarkersOPFOR_Side {
                displayName = "Disable Side";
                tooltip = "Disable Side (1) channel markers for OPFOR";
                control = "Checkbox";
                property = "Recondo_CC_MarkersOPFOR_Side";
                expression = "_this setVariable ['markersopfor_side', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_MarkersOPFOR";
            };
            class MarkersOPFOR_Command {
                displayName = "Disable Command";
                tooltip = "Disable Command (2) channel markers for OPFOR";
                control = "Checkbox";
                property = "Recondo_CC_MarkersOPFOR_Command";
                expression = "_this setVariable ['markersopfor_command', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_MarkersOPFOR";
            };
            class MarkersOPFOR_Group {
                displayName = "Disable Group";
                tooltip = "Disable Group (3) channel markers for OPFOR";
                control = "Checkbox";
                property = "Recondo_CC_MarkersOPFOR_Group";
                expression = "_this setVariable ['markersopfor_group', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_MarkersOPFOR";
            };
            class MarkersOPFOR_Vehicle {
                displayName = "Disable Vehicle";
                tooltip = "Disable Vehicle (4) channel markers for OPFOR";
                control = "Checkbox";
                property = "Recondo_CC_MarkersOPFOR_Vehicle";
                expression = "_this setVariable ['markersopfor_vehicle', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_MarkersOPFOR";
            };
            class MarkersOPFOR_Direct {
                displayName = "Disable Direct";
                tooltip = "Disable Direct (5) channel markers for OPFOR";
                control = "Checkbox";
                property = "Recondo_CC_MarkersOPFOR_Direct";
                expression = "_this setVariable ['markersopfor_direct', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_MarkersOPFOR";
            };
            
            // ========================================
            // MAP MARKERS - BLUFOR
            // ========================================
            class MarkersBLUFOR_Global {
                displayName = "MARKERS BLUFOR - Disable Global";
                tooltip = "Disable Global (0) channel markers for BLUFOR";
                control = "Checkbox";
                property = "Recondo_CC_MarkersBLUFOR_Global";
                expression = "_this setVariable ['markersblufor_global', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_MarkersBLUFOR";
            };
            class MarkersBLUFOR_Side {
                displayName = "Disable Side";
                tooltip = "Disable Side (1) channel markers for BLUFOR";
                control = "Checkbox";
                property = "Recondo_CC_MarkersBLUFOR_Side";
                expression = "_this setVariable ['markersblufor_side', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_MarkersBLUFOR";
            };
            class MarkersBLUFOR_Command {
                displayName = "Disable Command";
                tooltip = "Disable Command (2) channel markers for BLUFOR";
                control = "Checkbox";
                property = "Recondo_CC_MarkersBLUFOR_Command";
                expression = "_this setVariable ['markersblufor_command', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_MarkersBLUFOR";
            };
            class MarkersBLUFOR_Group {
                displayName = "Disable Group";
                tooltip = "Disable Group (3) channel markers for BLUFOR";
                control = "Checkbox";
                property = "Recondo_CC_MarkersBLUFOR_Group";
                expression = "_this setVariable ['markersblufor_group', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_MarkersBLUFOR";
            };
            class MarkersBLUFOR_Vehicle {
                displayName = "Disable Vehicle";
                tooltip = "Disable Vehicle (4) channel markers for BLUFOR";
                control = "Checkbox";
                property = "Recondo_CC_MarkersBLUFOR_Vehicle";
                expression = "_this setVariable ['markersblufor_vehicle', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_MarkersBLUFOR";
            };
            class MarkersBLUFOR_Direct {
                displayName = "Disable Direct";
                tooltip = "Disable Direct (5) channel markers for BLUFOR";
                control = "Checkbox";
                property = "Recondo_CC_MarkersBLUFOR_Direct";
                expression = "_this setVariable ['markersblufor_direct', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_MarkersBLUFOR";
            };
            
            // ========================================
            // MAP MARKERS - INDEPENDENT
            // ========================================
            class MarkersIndependent_Global {
                displayName = "MARKERS INDEPENDENT - Disable Global";
                tooltip = "Disable Global (0) channel markers for Independent";
                control = "Checkbox";
                property = "Recondo_CC_MarkersIndependent_Global";
                expression = "_this setVariable ['markersindependent_global', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_MarkersIndependent";
            };
            class MarkersIndependent_Side {
                displayName = "Disable Side";
                tooltip = "Disable Side (1) channel markers for Independent";
                control = "Checkbox";
                property = "Recondo_CC_MarkersIndependent_Side";
                expression = "_this setVariable ['markersindependent_side', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_MarkersIndependent";
            };
            class MarkersIndependent_Command {
                displayName = "Disable Command";
                tooltip = "Disable Command (2) channel markers for Independent";
                control = "Checkbox";
                property = "Recondo_CC_MarkersIndependent_Command";
                expression = "_this setVariable ['markersindependent_command', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_MarkersIndependent";
            };
            class MarkersIndependent_Group {
                displayName = "Disable Group";
                tooltip = "Disable Group (3) channel markers for Independent";
                control = "Checkbox";
                property = "Recondo_CC_MarkersIndependent_Group";
                expression = "_this setVariable ['markersindependent_group', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_MarkersIndependent";
            };
            class MarkersIndependent_Vehicle {
                displayName = "Disable Vehicle";
                tooltip = "Disable Vehicle (4) channel markers for Independent";
                control = "Checkbox";
                property = "Recondo_CC_MarkersIndependent_Vehicle";
                expression = "_this setVariable ['markersindependent_vehicle', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_MarkersIndependent";
            };
            class MarkersIndependent_Direct {
                displayName = "Disable Direct";
                tooltip = "Disable Direct (5) channel markers for Independent";
                control = "Checkbox";
                property = "Recondo_CC_MarkersIndependent_Direct";
                expression = "_this setVariable ['markersindependent_direct', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_MarkersIndependent";
            };
            
            // ========================================
            // MAP MARKERS - CIVILIAN
            // ========================================
            class MarkersCivilian_Global {
                displayName = "MARKERS CIVILIAN - Disable Global";
                tooltip = "Disable Global (0) channel markers for Civilian";
                control = "Checkbox";
                property = "Recondo_CC_MarkersCivilian_Global";
                expression = "_this setVariable ['markerscivilian_global', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_MarkersCivilian";
            };
            class MarkersCivilian_Side {
                displayName = "Disable Side";
                tooltip = "Disable Side (1) channel markers for Civilian";
                control = "Checkbox";
                property = "Recondo_CC_MarkersCivilian_Side";
                expression = "_this setVariable ['markerscivilian_side', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_MarkersCivilian";
            };
            class MarkersCivilian_Command {
                displayName = "Disable Command";
                tooltip = "Disable Command (2) channel markers for Civilian";
                control = "Checkbox";
                property = "Recondo_CC_MarkersCivilian_Command";
                expression = "_this setVariable ['markerscivilian_command', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_MarkersCivilian";
            };
            class MarkersCivilian_Group {
                displayName = "Disable Group";
                tooltip = "Disable Group (3) channel markers for Civilian";
                control = "Checkbox";
                property = "Recondo_CC_MarkersCivilian_Group";
                expression = "_this setVariable ['markerscivilian_group', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_MarkersCivilian";
            };
            class MarkersCivilian_Vehicle {
                displayName = "Disable Vehicle";
                tooltip = "Disable Vehicle (4) channel markers for Civilian";
                control = "Checkbox";
                property = "Recondo_CC_MarkersCivilian_Vehicle";
                expression = "_this setVariable ['markerscivilian_vehicle', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_MarkersCivilian";
            };
            class MarkersCivilian_Direct {
                displayName = "Disable Direct";
                tooltip = "Disable Direct (5) channel markers for Civilian";
                control = "Checkbox";
                property = "Recondo_CC_MarkersCivilian_Direct";
                expression = "_this setVariable ['markerscivilian_direct', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_MarkersCivilian";
            };
            
            // ========================================
            // VOICE CHAT - OPFOR
            // ========================================
            class VoiceOPFOR_Global {
                displayName = "VOICE OPFOR - Disable Global";
                tooltip = "Disable Global (0) voice chat for OPFOR";
                control = "Checkbox";
                property = "Recondo_CC_VoiceOPFOR_Global";
                expression = "_this setVariable ['voiceopfor_global', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_VoiceOPFOR";
            };
            class VoiceOPFOR_Side {
                displayName = "Disable Side Voice";
                tooltip = "Disable Side (1) voice chat for OPFOR";
                control = "Checkbox";
                property = "Recondo_CC_VoiceOPFOR_Side";
                expression = "_this setVariable ['voiceopfor_side', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_VoiceOPFOR";
            };
            class VoiceOPFOR_Command {
                displayName = "Disable Command Voice";
                tooltip = "Disable Command (2) voice chat for OPFOR";
                control = "Checkbox";
                property = "Recondo_CC_VoiceOPFOR_Command";
                expression = "_this setVariable ['voiceopfor_command', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_VoiceOPFOR";
            };
            class VoiceOPFOR_Group {
                displayName = "Disable Group Voice";
                tooltip = "Disable Group (3) voice chat for OPFOR";
                control = "Checkbox";
                property = "Recondo_CC_VoiceOPFOR_Group";
                expression = "_this setVariable ['voiceopfor_group', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_VoiceOPFOR";
            };
            class VoiceOPFOR_Vehicle {
                displayName = "Disable Vehicle Voice";
                tooltip = "Disable Vehicle (4) voice chat for OPFOR";
                control = "Checkbox";
                property = "Recondo_CC_VoiceOPFOR_Vehicle";
                expression = "_this setVariable ['voiceopfor_vehicle', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_VoiceOPFOR";
            };
            class VoiceOPFOR_Direct {
                displayName = "Disable Direct Voice";
                tooltip = "Disable Direct (5) voice chat for OPFOR";
                control = "Checkbox";
                property = "Recondo_CC_VoiceOPFOR_Direct";
                expression = "_this setVariable ['voiceopfor_direct', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_VoiceOPFOR";
            };
            
            // ========================================
            // VOICE CHAT - BLUFOR
            // ========================================
            class VoiceBLUFOR_Global {
                displayName = "VOICE BLUFOR - Disable Global";
                tooltip = "Disable Global (0) voice chat for BLUFOR";
                control = "Checkbox";
                property = "Recondo_CC_VoiceBLUFOR_Global";
                expression = "_this setVariable ['voiceblufor_global', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_VoiceBLUFOR";
            };
            class VoiceBLUFOR_Side {
                displayName = "Disable Side Voice";
                tooltip = "Disable Side (1) voice chat for BLUFOR";
                control = "Checkbox";
                property = "Recondo_CC_VoiceBLUFOR_Side";
                expression = "_this setVariable ['voiceblufor_side', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_VoiceBLUFOR";
            };
            class VoiceBLUFOR_Command {
                displayName = "Disable Command Voice";
                tooltip = "Disable Command (2) voice chat for BLUFOR";
                control = "Checkbox";
                property = "Recondo_CC_VoiceBLUFOR_Command";
                expression = "_this setVariable ['voiceblufor_command', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_VoiceBLUFOR";
            };
            class VoiceBLUFOR_Group {
                displayName = "Disable Group Voice";
                tooltip = "Disable Group (3) voice chat for BLUFOR";
                control = "Checkbox";
                property = "Recondo_CC_VoiceBLUFOR_Group";
                expression = "_this setVariable ['voiceblufor_group', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_VoiceBLUFOR";
            };
            class VoiceBLUFOR_Vehicle {
                displayName = "Disable Vehicle Voice";
                tooltip = "Disable Vehicle (4) voice chat for BLUFOR";
                control = "Checkbox";
                property = "Recondo_CC_VoiceBLUFOR_Vehicle";
                expression = "_this setVariable ['voiceblufor_vehicle', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_VoiceBLUFOR";
            };
            class VoiceBLUFOR_Direct {
                displayName = "Disable Direct Voice";
                tooltip = "Disable Direct (5) voice chat for BLUFOR";
                control = "Checkbox";
                property = "Recondo_CC_VoiceBLUFOR_Direct";
                expression = "_this setVariable ['voiceblufor_direct', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_VoiceBLUFOR";
            };
            
            // ========================================
            // VOICE CHAT - INDEPENDENT
            // ========================================
            class VoiceIndependent_Global {
                displayName = "VOICE INDEPENDENT - Disable Global";
                tooltip = "Disable Global (0) voice chat for Independent";
                control = "Checkbox";
                property = "Recondo_CC_VoiceIndependent_Global";
                expression = "_this setVariable ['voiceindependent_global', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_VoiceIndependent";
            };
            class VoiceIndependent_Side {
                displayName = "Disable Side Voice";
                tooltip = "Disable Side (1) voice chat for Independent";
                control = "Checkbox";
                property = "Recondo_CC_VoiceIndependent_Side";
                expression = "_this setVariable ['voiceindependent_side', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_VoiceIndependent";
            };
            class VoiceIndependent_Command {
                displayName = "Disable Command Voice";
                tooltip = "Disable Command (2) voice chat for Independent";
                control = "Checkbox";
                property = "Recondo_CC_VoiceIndependent_Command";
                expression = "_this setVariable ['voiceindependent_command', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_VoiceIndependent";
            };
            class VoiceIndependent_Group {
                displayName = "Disable Group Voice";
                tooltip = "Disable Group (3) voice chat for Independent";
                control = "Checkbox";
                property = "Recondo_CC_VoiceIndependent_Group";
                expression = "_this setVariable ['voiceindependent_group', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_VoiceIndependent";
            };
            class VoiceIndependent_Vehicle {
                displayName = "Disable Vehicle Voice";
                tooltip = "Disable Vehicle (4) voice chat for Independent";
                control = "Checkbox";
                property = "Recondo_CC_VoiceIndependent_Vehicle";
                expression = "_this setVariable ['voiceindependent_vehicle', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_VoiceIndependent";
            };
            class VoiceIndependent_Direct {
                displayName = "Disable Direct Voice";
                tooltip = "Disable Direct (5) voice chat for Independent";
                control = "Checkbox";
                property = "Recondo_CC_VoiceIndependent_Direct";
                expression = "_this setVariable ['voiceindependent_direct', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_VoiceIndependent";
            };
            
            // ========================================
            // VOICE CHAT - CIVILIAN
            // ========================================
            class VoiceCivilian_Global {
                displayName = "VOICE CIVILIAN - Disable Global";
                tooltip = "Disable Global (0) voice chat for Civilian";
                control = "Checkbox";
                property = "Recondo_CC_VoiceCivilian_Global";
                expression = "_this setVariable ['voicecivilian_global', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_VoiceCivilian";
            };
            class VoiceCivilian_Side {
                displayName = "Disable Side Voice";
                tooltip = "Disable Side (1) voice chat for Civilian";
                control = "Checkbox";
                property = "Recondo_CC_VoiceCivilian_Side";
                expression = "_this setVariable ['voicecivilian_side', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_VoiceCivilian";
            };
            class VoiceCivilian_Command {
                displayName = "Disable Command Voice";
                tooltip = "Disable Command (2) voice chat for Civilian";
                control = "Checkbox";
                property = "Recondo_CC_VoiceCivilian_Command";
                expression = "_this setVariable ['voicecivilian_command', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_VoiceCivilian";
            };
            class VoiceCivilian_Group {
                displayName = "Disable Group Voice";
                tooltip = "Disable Group (3) voice chat for Civilian";
                control = "Checkbox";
                property = "Recondo_CC_VoiceCivilian_Group";
                expression = "_this setVariable ['voicecivilian_group', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_VoiceCivilian";
            };
            class VoiceCivilian_Vehicle {
                displayName = "Disable Vehicle Voice";
                tooltip = "Disable Vehicle (4) voice chat for Civilian";
                control = "Checkbox";
                property = "Recondo_CC_VoiceCivilian_Vehicle";
                expression = "_this setVariable ['voicecivilian_vehicle', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_VoiceCivilian";
            };
            class VoiceCivilian_Direct {
                displayName = "Disable Direct Voice";
                tooltip = "Disable Direct (5) voice chat for Civilian";
                control = "Checkbox";
                property = "Recondo_CC_VoiceCivilian_Direct";
                expression = "_this setVariable ['voicecivilian_direct', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_VoiceCivilian";
            };
            
            // ========================================
            // DEBUG
            // ========================================
            class DebugLogging {
                displayName = "DEBUG - Enable Logging";
                tooltip = "Log chat control settings to RPT";
                control = "Checkbox";
                property = "Recondo_CC_DebugLogging";
                expression = "_this setVariable ['debuglogging', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_ChatControl_Debug";
            };
        };
    };
    
    // ========================================
    // CONVOY SYSTEM MODULE
    // ========================================
    class Recondo_Module_ConvoySystem: Module_F {
        scope = 2;
        displayName = "Convoy System";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleConvoySystem";
        functionPriority = 5;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 0;
        canSetArea = 0;
        
        class ModuleDescription: ModuleDescription {
            description = "Spawns enemy convoys that simulate live logistics supply routes. SYNC this module to objective modules (HVT, Hostages, Destroy, Hub & Subs) to route convoys to those objectives. If not synced to any objective module, convoys travel directly from start to end marker. For HVT and Hostage objectives, convoys also route to decoy locations.";
            sync[] = {"Recondo_Module_ObjectiveHVT", "Recondo_Module_ObjectiveHostages", "Recondo_Module_ObjectiveDestroy", "Recondo_Module_ObjectiveHubSubs"};
        };
        
        class Attributes: AttributesBase {
            
            // ========================================
            // GENERAL SETTINGS
            // ========================================
            class ConvoySide {
                displayName = "GENERAL - Convoy Side";
                tooltip = "Side of the convoy units.";
                control = "Combo";
                property = "Recondo_Convoy_Side";
                expression = "_this setVariable ['convoyside', _value, true];";
                typeName = "STRING";
                defaultValue = """EAST""";
                category = "Recondo_Convoy_General";
                class Values {
                    class East { name = "OPFOR (East)"; value = "EAST"; default = 1; };
                    class West { name = "BLUFOR (West)"; value = "WEST"; };
                    class Guer { name = "Independent"; value = "GUER"; };
                };
            };
            class MaxActiveConvoys {
                displayName = "Max Active Convoys";
                tooltip = "Maximum number of convoys that can be active simultaneously.";
                control = "Edit";
                property = "Recondo_Convoy_MaxActive";
                expression = "_this setVariable ['maxactive', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """2""";
                category = "Recondo_Convoy_General";
            };
            class SpawnDelayMin {
                displayName = "Spawn Delay Min (seconds)";
                tooltip = "Minimum delay between convoy spawns.";
                control = "Edit";
                property = "Recondo_Convoy_SpawnDelayMin";
                expression = "_this setVariable ['spawndelaymin', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """1500""";
                category = "Recondo_Convoy_General";
            };
            class SpawnDelayMax {
                displayName = "Spawn Delay Max (seconds)";
                tooltip = "Maximum delay between convoy spawns.";
                control = "Edit";
                property = "Recondo_Convoy_SpawnDelayMax";
                expression = "_this setVariable ['spawndelaymax', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """2100""";
                category = "Recondo_Convoy_General";
            };
            class ConvoyTimeout {
                displayName = "Convoy Timeout (minutes)";
                tooltip = "Time after which a convoy is automatically cleaned up if it hasn't reached its destination.";
                control = "Edit";
                property = "Recondo_Convoy_Timeout";
                expression = "_this setVariable ['timeout', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """45""";
                category = "Recondo_Convoy_General";
            };
            
            // ========================================
            // MARKER SETTINGS
            // ========================================
            class StartMarker {
                displayName = "MARKERS - Start Marker";
                tooltip = "Name of the marker where convoys spawn.";
                control = "Edit";
                property = "Recondo_Convoy_StartMarker";
                expression = "_this setVariable ['startmarker', _value, true];";
                typeName = "STRING";
                defaultValue = """CONVOY_START""";
                category = "Recondo_Convoy_Markers";
            };
            class EndMarker {
                displayName = "End Marker";
                tooltip = "Name of the marker where convoys are deleted after completing their route.";
                control = "Edit";
                property = "Recondo_Convoy_EndMarker";
                expression = "_this setVariable ['endmarker', _value, true];";
                typeName = "STRING";
                defaultValue = """CONVOY_END""";
                category = "Recondo_Convoy_Markers";
            };
            class DirMarkerSuffix {
                displayName = "Direction Marker Suffix";
                tooltip = "Suffix added to start marker name to find direction marker. Example: If start marker is 'CONVOY_START' and suffix is '_DIR', system looks for 'CONVOY_START_DIR'. Convoy will face toward the direction marker when spawning. Leave empty to use start marker's rotation instead.";
                control = "Edit";
                property = "Recondo_Convoy_DirMarkerSuffix";
                expression = "_this setVariable ['dirmarkersuffix', _value, true];";
                typeName = "STRING";
                defaultValue = """_DIR""";
                category = "Recondo_Convoy_Markers";
            };
            class WaypointPrefix {
                displayName = "Waypoint Marker Prefix";
                tooltip = "Prefix for intermediate waypoint markers when convoy has no objective. Example: 'CONVOY' looks for 'CONVOY_1', 'CONVOY_2', etc. Convoy visits markers in order until one is missing, then proceeds to end marker. Leave empty to go directly to end marker.";
                control = "Edit";
                property = "Recondo_Convoy_WaypointPrefix";
                expression = "_this setVariable ['waypointprefix', _value, true];";
                typeName = "STRING";
                defaultValue = """CONVOY""";
                category = "Recondo_Convoy_Markers";
            };
            
            // ========================================
            // VEHICLE SETTINGS
            // ========================================
            class VehicleClassnames {
                displayName = "VEHICLES - Vehicle Classnames";
                tooltip = "Comma-separated list of vehicle classnames to use for convoys.";
                control = "EditMulti3";
                property = "Recondo_Convoy_VehicleClassnames";
                expression = "_this setVariable ['vehicleclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_Convoy_Vehicles";
            };
            class MinVehicles {
                displayName = "Min Vehicles";
                tooltip = "Minimum number of vehicles per convoy.";
                control = "Edit";
                property = "Recondo_Convoy_MinVehicles";
                expression = "_this setVariable ['minvehicles', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """2""";
                category = "Recondo_Convoy_Vehicles";
            };
            class MaxVehicles {
                displayName = "Max Vehicles";
                tooltip = "Maximum number of vehicles per convoy.";
                control = "Edit";
                property = "Recondo_Convoy_MaxVehicles";
                expression = "_this setVariable ['maxvehicles', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """4""";
                category = "Recondo_Convoy_Vehicles";
            };
            
            // ========================================
            // CREW SETTINGS
            // ========================================
            class DriverClassnames {
                displayName = "CREW - Driver Classnames";
                tooltip = "Comma-separated list of unit classnames for drivers. Leave empty to use first from cargo pool.";
                control = "EditMulti3";
                property = "Recondo_Convoy_DriverClassnames";
                expression = "_this setVariable ['driverclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_Convoy_Crew";
            };
            class GunnerClassnames {
                displayName = "Gunner Classnames";
                tooltip = "Comma-separated list of unit classnames for gunners. Leave empty to use first from cargo pool.";
                control = "EditMulti3";
                property = "Recondo_Convoy_GunnerClassnames";
                expression = "_this setVariable ['gunnerclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_Convoy_Crew";
            };
            class CargoClassnames {
                displayName = "Cargo Classnames";
                tooltip = "Comma-separated list of unit classnames for cargo passengers.";
                control = "EditMulti3";
                property = "Recondo_Convoy_CargoClassnames";
                expression = "_this setVariable ['cargoclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_Convoy_Crew";
            };
            class FillCargo {
                displayName = "Fill Cargo Seats";
                tooltip = "Fill all available cargo seats with units.";
                control = "Checkbox";
                property = "Recondo_Convoy_FillCargo";
                expression = "_this setVariable ['fillcargo', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_Convoy_Crew";
            };
            
            // ========================================
            // CONVOY BEHAVIOR SETTINGS
            // ========================================
            class MaxSpeed {
                displayName = "BEHAVIOR - Max Speed (km/h)";
                tooltip = "Maximum speed of the convoy.";
                control = "Edit";
                property = "Recondo_Convoy_MaxSpeed";
                expression = "_this setVariable ['maxspeed', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """40""";
                category = "Recondo_Convoy_Behavior";
            };
            class VehicleSeparation {
                displayName = "Vehicle Separation (meters)";
                tooltip = "Target distance between vehicles in the convoy.";
                control = "Edit";
                property = "Recondo_Convoy_Separation";
                expression = "_this setVariable ['separation', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """25""";
                category = "Recondo_Convoy_Behavior";
            };
            class StopAtObjective {
                displayName = "Stop at Active Objectives";
                tooltip = "When enabled, convoys route to active objectives first, then to end marker. If no objectives exist, falls back to waypoint markers. If disabled, convoys only use waypoint markers.";
                control = "Checkbox";
                property = "Recondo_Convoy_StopAtObjective";
                expression = "_this setVariable ['stopatobjective', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_Convoy_Behavior";
            };
            class StopDuration {
                displayName = "Stop Duration (seconds)";
                tooltip = "How long the convoy pauses at the objective.";
                control = "Edit";
                property = "Recondo_Convoy_StopDuration";
                expression = "_this setVariable ['stopduration', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """30""";
                category = "Recondo_Convoy_Behavior";
            };
            
            // ========================================
            // SPEED CONTROL (ADVANCED)
            // ========================================
            class StiffnessCoeff {
                displayName = "SPEED CTRL - Stiffness";
                tooltip = "How aggressively the lead vehicle slows to maintain convoy spacing. Higher = more responsive.";
                control = "Slider";
                property = "Recondo_Convoy_Stiffness";
                expression = "_this setVariable ['stiffness', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.2";
                sliderRange[] = {0.05, 0.5};
                sliderStep = 0.05;
                category = "Recondo_Convoy_SpeedControl";
            };
            class DampingCoeff {
                displayName = "Damping";
                tooltip = "How much to minimize speed differences between vehicles. Higher = smoother convoy.";
                control = "Slider";
                property = "Recondo_Convoy_Damping";
                expression = "_this setVariable ['damping', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.6";
                sliderRange[] = {0.1, 1.0};
                sliderStep = 0.1;
                category = "Recondo_Convoy_SpeedControl";
            };
            class CurvatureCoeff {
                displayName = "Curvature";
                tooltip = "How much to slow on curves. Higher = slower on turns.";
                control = "Slider";
                property = "Recondo_Convoy_Curvature";
                expression = "_this setVariable ['curvature', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.3";
                sliderRange[] = {0.1, 0.6};
                sliderStep = 0.05;
                category = "Recondo_Convoy_SpeedControl";
            };
            class LinkStiffness {
                displayName = "Link Stiffness";
                tooltip = "How aggressively followers adjust speed to maintain spacing with vehicle ahead.";
                control = "Slider";
                property = "Recondo_Convoy_LinkStiffness";
                expression = "_this setVariable ['linkstiffness', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.1";
                sliderRange[] = {0.05, 0.3};
                sliderStep = 0.05;
                category = "Recondo_Convoy_SpeedControl";
            };
            class PathUpdateFreq {
                displayName = "Path Update Frequency (seconds)";
                tooltip = "How often the lead vehicle's path is recorded. Lower = smoother but more CPU.";
                control = "Slider";
                property = "Recondo_Convoy_PathFreq";
                expression = "_this setVariable ['pathfreq', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.05";
                sliderRange[] = {0.02, 0.2};
                sliderStep = 0.01;
                category = "Recondo_Convoy_SpeedControl";
            };
            class SpeedUpdateFreq {
                displayName = "Speed Update Frequency (seconds)";
                tooltip = "How often speed control adjustments are made. Lower = smoother but more CPU.";
                control = "Slider";
                property = "Recondo_Convoy_SpeedFreq";
                expression = "_this setVariable ['speedfreq', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.2";
                sliderRange[] = {0.1, 0.5};
                sliderStep = 0.05;
                category = "Recondo_Convoy_SpeedControl";
            };
            
            // ========================================
            // DEBUG SETTINGS
            // ========================================
            class DebugLogging {
                displayName = "DEBUG - Enable Logging";
                tooltip = "Log detailed debug information to RPT file.";
                control = "Checkbox";
                property = "Recondo_Convoy_DebugLogging";
                expression = "_this setVariable ['debuglogging', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_Convoy_Debug";
            };
            class DebugMarkers {
                displayName = "Enable Debug Markers";
                tooltip = "Show debug markers for convoy paths and positions.";
                control = "Checkbox";
                property = "Recondo_Convoy_DebugMarkers";
                expression = "_this setVariable ['debugmarkers', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_Convoy_Debug";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    //==========================================
    // BASE TO OUTPOST TELE MODULE
    //==========================================
    class Recondo_Module_OutpostTele: Module_F {
        scope = 2;
        displayName = "Base to Outpost Tele";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleOutpostTele";
        functionPriority = 1;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 1;
        
        class ModuleDescription: ModuleDescription {
            description = "Bidirectional teleportation system between a base object and outpost markers. Sync to an object (flag, table, laptop, etc.) to make it a base teleporter. Players can deploy to outposts and return to base using ACE interactions.";
            sync[] = {};
        };
        
        class Attributes: AttributesBase {
            
            // ========================================
            // GENERAL SETTINGS
            // ========================================
            class AllowedSide {
                displayName = "GENERAL - Allowed Side";
                tooltip = "Which side can use this teleporter system.";
                control = "Combo";
                property = "Recondo_OutpostTele_Side";
                expression = "_this setVariable ['allowedside', _value, true];";
                typeName = "NUMBER";
                defaultValue = "1";
                class Values {
                    class OPFOR { name = "OPFOR"; value = 0; };
                    class BLUFOR { name = "BLUFOR"; value = 1; default = 1; };
                    class INDFOR { name = "Independent"; value = 2; };
                    class CIV { name = "Civilian"; value = 3; };
                    class ANY { name = "Any Side"; value = 4; };
                };
                category = "Recondo_OutpostTele_General";
            };
            class ActionText {
                displayName = "Deploy Action Text";
                tooltip = "Text shown in ACE menu for deploying to outpost. Use %1 for outpost name. Example: 'Deploy to %1'";
                control = "Edit";
                property = "Recondo_OutpostTele_ActionText";
                expression = "_this setVariable ['actiontext', _value, true];";
                typeName = "STRING";
                defaultValue = """Deploy to %1""";
                category = "Recondo_OutpostTele_General";
            };
            class ReturnText {
                displayName = "Return Action Text";
                tooltip = "Text shown in ACE menu for returning to base.";
                control = "Edit";
                property = "Recondo_OutpostTele_ReturnText";
                expression = "_this setVariable ['returntext', _value, true];";
                typeName = "STRING";
                defaultValue = """Return to Base""";
                category = "Recondo_OutpostTele_General";
            };
            class Cooldown {
                displayName = "Cooldown (seconds)";
                tooltip = "Time in seconds before a player can teleport again. 0 = no cooldown.";
                control = "Edit";
                property = "Recondo_OutpostTele_Cooldown";
                expression = "_this setVariable ['cooldown', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0";
                category = "Recondo_OutpostTele_General";
            };
            
            // ========================================
            // OUTPOST SETTINGS
            // ========================================
            class MarkerMode {
                displayName = "OUTPOSTS - Marker Mode";
                tooltip = "How to select outpost markers. Specific = use exact marker names. Random = randomly select from markers with prefix.";
                control = "Combo";
                property = "Recondo_OutpostTele_MarkerMode";
                expression = "_this setVariable ['markermode', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0";
                class Values {
                    class Specific { name = "Specific Markers"; value = 0; default = 1; };
                    class Random { name = "Random from Prefix"; value = 1; };
                };
                category = "Recondo_OutpostTele_Outposts";
            };
            class MarkerList {
                displayName = "Marker List (Specific Mode)";
                tooltip = "List of exact marker names to use as outposts. One per line or comma-separated. Example:\nOutpost_Alpha\nOutpost_Bravo\nOutpost_Charlie";
                control = "EditMulti5";
                property = "Recondo_OutpostTele_MarkerList";
                expression = "_this setVariable ['markerlist', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_OutpostTele_Outposts";
            };
            class MarkerPrefix {
                displayName = "Marker Prefix (Random Mode)";
                tooltip = "Prefix to search for when using Random mode. Example: 'Outpost_' will find Outpost_1, Outpost_2, etc.";
                control = "Edit";
                property = "Recondo_OutpostTele_MarkerPrefix";
                expression = "_this setVariable ['markerprefix', _value, true];";
                typeName = "STRING";
                defaultValue = """Outpost_""";
                category = "Recondo_OutpostTele_Outposts";
            };
            class RandomCount {
                displayName = "Random Count";
                tooltip = "Number of outposts to randomly select when using Random mode.";
                control = "Edit";
                property = "Recondo_OutpostTele_RandomCount";
                expression = "_this setVariable ['randomcount', _value, true];";
                typeName = "NUMBER";
                defaultValue = "3";
                category = "Recondo_OutpostTele_Outposts";
            };
            class DisplayNames {
                displayName = "Display Names (Optional)";
                tooltip = "Custom display names for outposts in the ACE menu. One per line, matching marker order. Leave empty to use marker names.\nExample:\nAlpha FOB\nBravo FOB\nCharlie FOB";
                control = "EditMulti5";
                property = "Recondo_OutpostTele_DisplayNames";
                expression = "_this setVariable ['displaynames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_OutpostTele_Outposts";
            };
            class OutpostRadius {
                displayName = "Outpost Radius (meters)";
                tooltip = "Radius around outpost marker where 'Return to Base' action becomes available.";
                control = "Edit";
                property = "Recondo_OutpostTele_OutpostRadius";
                expression = "_this setVariable ['outpostradius', _value, true];";
                typeName = "NUMBER";
                defaultValue = "25";
                category = "Recondo_OutpostTele_Outposts";
            };
            
            // ========================================
            // COMPOSITION SETTINGS
            // ========================================
            class EnableCompositions {
                displayName = "COMPOSITIONS - Enable";
                tooltip = "Spawn compositions at outpost markers on mission start.";
                control = "Checkbox";
                property = "Recondo_OutpostTele_EnableCompositions";
                expression = "_this setVariable ['enablecompositions', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_OutpostTele_Compositions";
            };
            class CompositionPath {
                displayName = "Composition Path";
                tooltip = "Folder path for compositions relative to mission root. Example: 'compositions'";
                control = "Edit";
                property = "Recondo_OutpostTele_CompositionPath";
                expression = "_this setVariable ['compositionpath', _value, true];";
                typeName = "STRING";
                defaultValue = """compositions""";
                category = "Recondo_OutpostTele_Compositions";
            };
            class CompositionList {
                displayName = "Composition List";
                tooltip = "List of composition filenames (.sqe). One per line or comma-separated. Matched to markers in order, or randomly assigned if fewer compositions than markers.\nExample:\noutpost_small.sqe\noutpost_medium.sqe";
                control = "EditMulti5";
                property = "Recondo_OutpostTele_CompositionList";
                expression = "_this setVariable ['compositionlist', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_OutpostTele_Compositions";
            };
            class UseModCompositions {
                displayName = "Use Mod Compositions";
                tooltip = "Load compositions from the mod's compositions folder instead of mission folder.";
                control = "Checkbox";
                property = "Recondo_OutpostTele_UseModCompositions";
                expression = "_this setVariable ['usemodcompositions', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_OutpostTele_Compositions";
            };
            class ClearRadius {
                displayName = "Terrain Clear Radius";
                tooltip = "Radius around outpost to clear terrain objects (trees, bushes, rocks) before spawning composition.";
                control = "Edit";
                property = "Recondo_OutpostTele_ClearRadius";
                expression = "_this setVariable ['clearradius', _value, true];";
                typeName = "NUMBER";
                defaultValue = "15";
                category = "Recondo_OutpostTele_Compositions";
            };
            
            // ========================================
            // DESTRUCTION SETTINGS
            // ========================================
            class DestroyableClassname {
                displayName = "DESTRUCTION - Destroyable Object Classname";
                tooltip = "Classname of an object within the composition that can be destroyed by the enemy. When destroyed, the outpost is permanently disabled on next mission restart. Leave empty to disable destruction.";
                control = "Edit";
                property = "Recondo_OutpostTele_DestroyableClassname";
                expression = "_this setVariable ['destroyableclassname', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_OutpostTele_Destruction";
            };
            
            // ========================================
            // PERSISTENCE SETTINGS
            // ========================================
            class EnablePersistence {
                displayName = "PERSISTENCE - Enable";
                tooltip = "Save random marker selection across mission restarts. Requires Persistence module.";
                control = "Checkbox";
                property = "Recondo_OutpostTele_EnablePersistence";
                expression = "_this setVariable ['enablepersistence', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_OutpostTele_Persistence";
            };
            
            // ========================================
            // DEBUG SETTINGS
            // ========================================
            class DebugLogging {
                displayName = "DEBUG - Enable Logging";
                tooltip = "Log detailed debug information to RPT file.";
                control = "Checkbox";
                property = "Recondo_OutpostTele_DebugLogging";
                expression = "_this setVariable ['debuglogging', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_OutpostTele_Debug";
            };
            class DebugMarkers {
                displayName = "Enable Debug Markers";
                tooltip = "Show debug markers on map for outposts and base teleporters.";
                control = "Checkbox";
                property = "Recondo_OutpostTele_DebugMarkers";
                expression = "_this setVariable ['debugmarkers', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_OutpostTele_Debug";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    // ==========================================
    // CIVILIANS WORKING FIELDS MODULE
    // ==========================================
    class Recondo_Module_CiviliansWorking: Module_F {
        scope = 2;
        displayName = "Civilians Working Fields";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleCiviliansWorking";
        functionPriority = 5;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 0;
        canSetArea = 1;
        canSetAreaShape = 0;
        canSetAreaHeight = 0;
        icon = "\a3\modules_f\data\iconTaskSetState_ca.paa";
        
        class AttributeValues {
            size3[] = {50, 50, -1};
            isRectangle = 1;
        };
        
        class ModuleDescription: ModuleDescription {
            description = "Spawns civilians that work in fields (rice paddies, farms). They kneel, perform working animations, then move to another spot. Civilians flee if gunfire is detected nearby. Uses proximity-based spawning for performance.";
            sync[] = {};
        };
        
        class Attributes: AttributesBase {
            
            // ========================================
            // GENERAL SETTINGS
            // ========================================
            class CivilianCount {
                displayName = "GENERAL - Civilian Count";
                tooltip = "Number of civilians to spawn in the field area.";
                control = "Edit";
                property = "Recondo_CivWorking_CivilianCount";
                expression = "_this setVariable ['civiliancount', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """5""";
                category = "Recondo_CivWorking_General";
            };
            class UnitClassnames {
                displayName = "Unit Classnames";
                tooltip = "Comma-separated list of civilian unit classnames to spawn. Random selection per civilian.";
                control = "EditMulti5";
                property = "Recondo_CivWorking_UnitClassnames";
                expression = "_this setVariable ['unitclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """vn_c_men_01,vn_c_men_02,vn_c_men_03,vn_c_men_04,vn_c_men_05""";
                category = "Recondo_CivWorking_General";
            };
            
            // ========================================
            // TRIGGER SETTINGS
            // ========================================
            class SpawnDistance {
                displayName = "TRIGGER - Spawn Distance";
                tooltip = "Players within this distance (meters) will trigger civilian spawning.";
                control = "Edit";
                property = "Recondo_CivWorking_SpawnDistance";
                expression = "_this setVariable ['spawndistance', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """500""";
                category = "Recondo_CivWorking_Trigger";
            };
            class DespawnDistance {
                displayName = "Despawn Distance";
                tooltip = "Civilians despawn when no players are within this distance. Should be >= Spawn Distance.";
                control = "Edit";
                property = "Recondo_CivWorking_DespawnDistance";
                expression = "_this setVariable ['despawndistance', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """600""";
                category = "Recondo_CivWorking_Trigger";
            };
            class TriggerSide {
                displayName = "Trigger Side";
                tooltip = "Which side's units trigger the civilian spawn.";
                control = "Combo";
                property = "Recondo_CivWorking_TriggerSide";
                expression = "_this setVariable ['triggerside', _value, true];";
                typeName = "STRING";
                defaultValue = """WEST""";
                category = "Recondo_CivWorking_Trigger";
                class Values {
                    class West { name = "BLUFOR (West)"; value = "WEST"; };
                    class East { name = "OPFOR (East)"; value = "EAST"; };
                    class Guer { name = "Independent"; value = "GUER"; };
                    class Any { name = "Any Player"; value = "ANY"; };
                };
            };
            
            // ========================================
            // BEHAVIOR SETTINGS
            // ========================================
            class WorkDurationMin {
                displayName = "BEHAVIOR - Work Duration Min";
                tooltip = "Minimum seconds a civilian works at a spot before moving.";
                control = "Edit";
                property = "Recondo_CivWorking_WorkDurationMin";
                expression = "_this setVariable ['workdurationmin', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """15""";
                category = "Recondo_CivWorking_Behavior";
            };
            class WorkDurationMax {
                displayName = "Work Duration Max";
                tooltip = "Maximum seconds a civilian works at a spot before moving.";
                control = "Edit";
                property = "Recondo_CivWorking_WorkDurationMax";
                expression = "_this setVariable ['workdurationmax', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """60""";
                category = "Recondo_CivWorking_Behavior";
            };
            class MoveDistanceMin {
                displayName = "Move Distance Min";
                tooltip = "Minimum meters to walk when moving to next work spot.";
                control = "Edit";
                property = "Recondo_CivWorking_MoveDistanceMin";
                expression = "_this setVariable ['movedistancemin', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """5""";
                category = "Recondo_CivWorking_Behavior";
            };
            class MoveDistanceMax {
                displayName = "Move Distance Max";
                tooltip = "Maximum meters to walk when moving to next work spot.";
                control = "Edit";
                property = "Recondo_CivWorking_MoveDistanceMax";
                expression = "_this setVariable ['movedistancemax', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """20""";
                category = "Recondo_CivWorking_Behavior";
            };
            class Animations {
                displayName = "Work Animations";
                tooltip = "Comma-separated animation classnames for working. Random selection per work cycle.";
                control = "EditMulti5";
                property = "Recondo_CivWorking_Animations";
                expression = "_this setVariable ['animations', _value, true];";
                typeName = "STRING";
                defaultValue = """AinvPknlMstpSnonWnonDnon_medic_1,AinvPknlMstpSnonWnonDnon_medic0,AinvPknlMstpSlayWnonDnon_medic,Acts_carFixingWheel""";
                category = "Recondo_CivWorking_Behavior";
            };
            class FleeOnGunfire {
                displayName = "Flee on Gunfire";
                tooltip = "Civilians will flee in panic if shots are fired nearby.";
                control = "Checkbox";
                property = "Recondo_CivWorking_FleeOnGunfire";
                expression = "_this setVariable ['fleeongunfire', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_CivWorking_Behavior";
            };
            class GunfireDetectRadius {
                displayName = "Gunfire Detect Radius";
                tooltip = "Distance (meters) at which gunfire triggers fleeing.";
                control = "Edit";
                property = "Recondo_CivWorking_GunfireDetectRadius";
                expression = "_this setVariable ['gunfiredetectradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """100""";
                category = "Recondo_CivWorking_Behavior";
            };
            
            // ========================================
            // PROPS SETTINGS
            // ========================================
            class PropsCount {
                displayName = "PROPS - Props Count";
                tooltip = "Number of field props (carts, sacks, baskets) to spawn in the work area. Set to 0 to disable.";
                control = "Edit";
                property = "Recondo_CivWorking_PropsCount";
                expression = "_this setVariable ['propscount', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """4""";
                category = "Recondo_CivWorking_Props";
            };
            class PropsClassnames {
                displayName = "Props Classnames";
                tooltip = "Comma-separated list of object classnames to spawn as field props. Random selection per prop.";
                control = "EditMulti5";
                property = "Recondo_CivWorking_PropsClassnames";
                expression = "_this setVariable ['propsclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """Land_WoodenCart_F,Land_Sacks_goods_F,Land_Sack_F,Land_Basket_F""";
                category = "Recondo_CivWorking_Props";
            };
            
            // ========================================
            // DEBUG SETTINGS
            // ========================================
            class DebugLogging {
                displayName = "DEBUG - Enable Logging";
                tooltip = "Enable debug logging to RPT file.";
                control = "Checkbox";
                property = "Recondo_CivWorking_DebugLogging";
                expression = "_this setVariable ['debuglogging', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_CivWorking_Debug";
            };
            class DebugMarkers {
                displayName = "Debug Markers";
                tooltip = "Show debug markers for area and civilian positions.";
                control = "Checkbox";
                property = "Recondo_CivWorking_DebugMarkers";
                expression = "_this setVariable ['debugmarkers', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_CivWorking_Debug";
            };
        };
    };
    
    // =====================================================================
    // CIVILIAN TRAFFIC MODULE
    // =====================================================================
    class Recondo_Module_CivilianTraffic: Module_F {
        scope = 2;
        displayName = "Civilian Traffic";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleCivilianTraffic";
        functionPriority = 5;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 0;
        canSetArea = 0;
        canSetAreaShape = 0;
        canSetAreaHeight = 0;
        icon = "\a3\modules_f\data\iconTaskSetState_ca.paa";
        
        class ModuleDescription: ModuleDescription {
            description = "Spawns civilian vehicles that drive around on roads within marker-defined zones. Vehicles spawn when players approach and despawn when players leave the area. Civilians react to player interaction and gunfire.";
            sync[] = {};
        };
        
        class Attributes: AttributesBase {
            
            // ========================================
            // GENERAL SETTINGS
            // ========================================
            class MarkerPrefix {
                displayName = "GENERAL - Marker Prefix";
                tooltip = "Prefix for map markers defining traffic zones. All markers starting with this prefix become active zones.";
                control = "Edit";
                property = "Recondo_CivTraffic_MarkerPrefix";
                expression = "_this setVariable ['markerprefix', _value, true];";
                typeName = "STRING";
                defaultValue = """CIVTRAFFIC_""";
                category = "Recondo_CivTraffic_General";
            };
            class MaxVehicles {
                displayName = "Max Vehicles Per Zone";
                tooltip = "Maximum number of civilian vehicles active at any time per zone.";
                control = "Edit";
                property = "Recondo_CivTraffic_MaxVehicles";
                expression = "_this setVariable ['maxvehicles', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """5""";
                category = "Recondo_CivTraffic_General";
            };
            
            // ========================================
            // SPAWN SETTINGS
            // ========================================
            class TriggerRadius {
                displayName = "SPAWN - Trigger Radius";
                tooltip = "Distance (meters) from marker center at which players trigger vehicle spawning.";
                control = "Edit";
                property = "Recondo_CivTraffic_TriggerRadius";
                expression = "_this setVariable ['triggerradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """800""";
                category = "Recondo_CivTraffic_Spawn";
            };
            class SpawnRadius {
                displayName = "Spawn Radius";
                tooltip = "Vehicles spawn on roads within this radius (meters) of the marker center.";
                control = "Edit";
                property = "Recondo_CivTraffic_SpawnRadius";
                expression = "_this setVariable ['spawnradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """600""";
                category = "Recondo_CivTraffic_Spawn";
            };
            class SpawnDelay {
                displayName = "Spawn Delay";
                tooltip = "Seconds between spawning each vehicle (when under max limit).";
                control = "Edit";
                property = "Recondo_CivTraffic_SpawnDelay";
                expression = "_this setVariable ['spawndelay', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """5""";
                category = "Recondo_CivTraffic_Spawn";
            };
            class DespawnDelay {
                displayName = "Despawn Delay";
                tooltip = "Seconds to wait after players leave before despawning vehicles.";
                control = "Edit";
                property = "Recondo_CivTraffic_DespawnDelay";
                expression = "_this setVariable ['despawndelay', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """10""";
                category = "Recondo_CivTraffic_Spawn";
            };
            
            // ========================================
            // UNIT SETTINGS
            // ========================================
            class CivilianClassnames {
                displayName = "UNITS - Civilian Classnames";
                tooltip = "Comma-separated list of civilian unit classnames. Random selection per vehicle.";
                control = "EditMulti5";
                property = "Recondo_CivTraffic_CivilianClassnames";
                expression = "_this setVariable ['civilianclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """vn_c_men_01,vn_c_men_02,vn_c_men_03,vn_c_men_04,vn_c_men_05""";
                category = "Recondo_CivTraffic_Units";
            };
            class VehicleClassnames {
                displayName = "Vehicle Classnames";
                tooltip = "Comma-separated list of vehicle classnames. Random selection per spawn.";
                control = "EditMulti5";
                property = "Recondo_CivTraffic_VehicleClassnames";
                expression = "_this setVariable ['vehicleclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """vn_c_bicycle_01,vn_c_wheeled_m151_01,vn_c_wheeled_m151_02""";
                category = "Recondo_CivTraffic_Units";
            };
            
            // ========================================
            // BEHAVIOR SETTINGS
            // ========================================
            class SpeedMode {
                displayName = "BEHAVIOR - Speed Mode";
                tooltip = "How fast vehicles drive between destinations.";
                control = "Combo";
                property = "Recondo_CivTraffic_SpeedMode";
                expression = "_this setVariable ['speedmode', _value, true];";
                typeName = "STRING";
                defaultValue = """LIMITED""";
                category = "Recondo_CivTraffic_Behavior";
                class Values {
                    class Limited { name = "Limited (Slow)"; value = "LIMITED"; };
                    class Normal { name = "Normal"; value = "NORMAL"; };
                    class Full { name = "Full (Fast)"; value = "FULL"; };
                };
            };
            class ParkDurationMin {
                displayName = "Park Duration Min";
                tooltip = "Minimum seconds a vehicle parks at a destination before driving again.";
                control = "Edit";
                property = "Recondo_CivTraffic_ParkDurationMin";
                expression = "_this setVariable ['parkdurationmin', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """30""";
                category = "Recondo_CivTraffic_Behavior";
            };
            class ParkDurationMax {
                displayName = "Park Duration Max";
                tooltip = "Maximum seconds a vehicle parks at a destination before driving again.";
                control = "Edit";
                property = "Recondo_CivTraffic_ParkDurationMax";
                expression = "_this setVariable ['parkdurationmax', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """120""";
                category = "Recondo_CivTraffic_Behavior";
            };
            class ArrivalDistance {
                displayName = "Arrival Distance";
                tooltip = "Distance (meters) from destination at which vehicle considers itself 'arrived' and will stop to park.";
                control = "Edit";
                property = "Recondo_CivTraffic_ArrivalDistance";
                expression = "_this setVariable ['arrivaldistance', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """30""";
                category = "Recondo_CivTraffic_Behavior";
            };
            class EarlyStopDistance {
                displayName = "Early Stop Distance";
                tooltip = "If vehicle speed drops below 1 km/h within this distance of destination, consider it arrived. Set to 0 to disable early stopping.";
                control = "Edit";
                property = "Recondo_CivTraffic_EarlyStopDistance";
                expression = "_this setVariable ['earlystopdistance', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """100""";
                category = "Recondo_CivTraffic_Behavior";
            };
            class FleeOnPlayerEnter {
                displayName = "Flee When Player Enters";
                tooltip = "Civilian driver flees if a player enters their vehicle.";
                control = "Checkbox";
                property = "Recondo_CivTraffic_FleeOnPlayerEnter";
                expression = "_this setVariable ['fleeonplayerenter', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_CivTraffic_Behavior";
            };
            class CowerUnderFire {
                displayName = "Cower Under Fire";
                tooltip = "Civilian stops and cowers when shots are fired nearby.";
                control = "Checkbox";
                property = "Recondo_CivTraffic_CowerUnderFire";
                expression = "_this setVariable ['cowerunderfire', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_CivTraffic_Behavior";
            };
            
            // ========================================
            // DEBUG SETTINGS
            // ========================================
            class DebugLogging {
                displayName = "DEBUG - Enable Logging";
                tooltip = "Enable debug logging to RPT file.";
                control = "Checkbox";
                property = "Recondo_CivTraffic_DebugLogging";
                expression = "_this setVariable ['debuglogging', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_CivTraffic_Debug";
            };
            class DebugMarkers {
                displayName = "Debug Markers";
                tooltip = "Show debug markers for traffic zones and spawn areas.";
                control = "Checkbox";
                property = "Recondo_CivTraffic_DebugMarkers";
                expression = "_this setVariable ['debugmarkers', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_CivTraffic_Debug";
            };
        };
    };
    
    // ==========================================
    // CIVILIAN PATTERNS OF LIFE MODULE
    // ==========================================
    class Recondo_Module_CivilianPOL: Module_F {
        scope = 2;
        displayName = "Civilian - Patterns of Life";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleCivilianPOL";
        functionPriority = 3;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 0;
        canSetArea = 0;
        icon = "\a3\modules_f\data\iconTaskSetState_ca.paa";
        
        class ModuleDescription: ModuleDescription {
            description = "Creates realistic civilian daily routines in villages. Civilians have homes, jobs (farming, fishing), daily schedules, and night lights. They flee from combat. Players can interact and occasionally receive intel documents.";
            sync[] = {};
        };
        
        class Attributes: AttributesBase {
            
            // ========================================
            // MARKER SETTINGS
            // ========================================
            class VillageMarkerPrefix {
                displayName = "MARKERS - Village Prefix";
                tooltip = "Prefix for village area markers (e.g., 'Village_' for Village_1, Village_2, etc.)";
                control = "Edit";
                property = "Recondo_CivPOL_VillageMarkerPrefix";
                expression = "_this setVariable ['villagemarkerprefix', _value, true];";
                typeName = "STRING";
                defaultValue = """VILLAGE_""";
                category = "Recondo_CivPOL_Markers";
            };
            class FieldsMarkerPrefix {
                displayName = "Fields Job Prefix";
                tooltip = "Prefix for farming job location markers (e.g., 'Fields_' for Fields_1, Fields_2, etc.)";
                control = "Edit";
                property = "Recondo_CivPOL_FieldsMarkerPrefix";
                expression = "_this setVariable ['fieldsmarkerprefix', _value, true];";
                typeName = "STRING";
                defaultValue = """FIELDS_""";
                category = "Recondo_CivPOL_Markers";
            };
            class FishermanMarkerPrefix {
                displayName = "Fisherman Job Prefix";
                tooltip = "Prefix for fishing job location markers (e.g., 'Fisherman_' for Fisherman_1, etc.)";
                control = "Edit";
                property = "Recondo_CivPOL_FishermanMarkerPrefix";
                expression = "_this setVariable ['fishermanmarkerprefix', _value, true];";
                typeName = "STRING";
                defaultValue = """FISHERMAN_""";
                category = "Recondo_CivPOL_Markers";
            };
            
            // ========================================
            // POPULATION SETTINGS
            // ========================================
            class CiviliansPerVillage {
                displayName = "POPULATION - Civilians Per Village";
                tooltip = "Number of civilians to spawn in each village.";
                control = "Edit";
                property = "Recondo_CivPOL_CiviliansPerVillage";
                expression = "_this setVariable ['civilianspervillage', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """3""";
                category = "Recondo_CivPOL_Population";
            };
            class HomeSearchRadius {
                displayName = "Home Search Radius";
                tooltip = "Radius in meters to search for buildings to use as homes in each village.";
                control = "Edit";
                property = "Recondo_CivPOL_HomeSearchRadius";
                expression = "_this setVariable ['homesearchradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """150""";
                category = "Recondo_CivPOL_Population";
            };
            class UnitClassnames {
                displayName = "Civilian Unit Classnames";
                tooltip = "Comma-separated list of civilian unit classnames to spawn.";
                control = "EditMulti5";
                property = "Recondo_CivPOL_UnitClassnames";
                expression = "_this setVariable ['unitclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """vn_c_men_01,vn_c_men_02,vn_c_men_03,vn_c_men_04""";
                category = "Recondo_CivPOL_Population";
            };
            
            // ========================================
            // SPAWN SETTINGS
            // ========================================
            class SpawnDistance {
                displayName = "SPAWN - Spawn Distance";
                tooltip = "Distance at which civilians spawn when players approach a village.";
                control = "Edit";
                property = "Recondo_CivPOL_SpawnDistance";
                expression = "_this setVariable ['spawndistance', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """400""";
                category = "Recondo_CivPOL_Spawn";
            };
            class DespawnDistance {
                displayName = "Despawn Distance";
                tooltip = "Distance at which civilians despawn when players leave a village.";
                control = "Edit";
                property = "Recondo_CivPOL_DespawnDistance";
                expression = "_this setVariable ['despawndistance', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """500""";
                category = "Recondo_CivPOL_Spawn";
            };
            class TriggerSide {
                displayName = "Trigger Side";
                tooltip = "Which side triggers civilian spawning. WEST, EAST, GUER, CIV, or ANYPLAYER.";
                control = "Edit";
                property = "Recondo_CivPOL_TriggerSide";
                expression = "_this setVariable ['triggerside', _value, true];";
                typeName = "STRING";
                defaultValue = """WEST""";
                category = "Recondo_CivPOL_Spawn";
            };
            
            // ========================================
            // INTERACTION SETTINGS
            // ========================================
            class DocumentDropChance {
                displayName = "INTERACTION - Document Drop Chance";
                tooltip = "Percentage chance (0-100) that a civilian gives intel documents when interacted with.";
                control = "Edit";
                property = "Recondo_CivPOL_DocumentDropChance";
                expression = "_this setVariable ['documentdropchance', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """10""";
                category = "Recondo_CivPOL_Interaction";
            };
            class DocumentClass {
                displayName = "Document Item Class";
                tooltip = "Classname of the document item given by civilians.";
                control = "Edit";
                property = "Recondo_CivPOL_DocumentClass";
                expression = "_this setVariable ['documentclass', _value, true];";
                typeName = "STRING";
                defaultValue = """ACE_Documents""";
                category = "Recondo_CivPOL_Interaction";
            };
            
            // ========================================
            // BEHAVIOR SETTINGS
            // ========================================
            class FleeOnCombat {
                displayName = "BEHAVIOR - Flee on Combat";
                tooltip = "Civilians flee when gunfire is detected nearby.";
                control = "Checkbox";
                property = "Recondo_CivPOL_FleeOnCombat";
                expression = "_this setVariable ['fleeoncombat', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_CivPOL_Behavior";
            };
            class CombatDetectRadius {
                displayName = "Combat Detect Radius";
                tooltip = "Distance in meters at which civilians detect gunfire and flee.";
                control = "Edit";
                property = "Recondo_CivPOL_CombatDetectRadius";
                expression = "_this setVariable ['combatdetectradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """150""";
                category = "Recondo_CivPOL_Behavior";
            };
            class FieldWorkRadius {
                displayName = "Field Work Radius";
                tooltip = "Radius (in meters) that farmers will move around within when working at fields markers.";
                control = "Edit";
                property = "Recondo_CivPOL_FieldWorkRadius";
                expression = "_this setVariable ['fieldworkradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """30""";
                category = "Recondo_CivPOL_Behavior";
            };
            class FishermanWorkRadius {
                displayName = "Fisherman Work Radius";
                tooltip = "Radius (in meters) that fishermen will work within around fisherman markers.";
                control = "Edit";
                property = "Recondo_CivPOL_FishermanWorkRadius";
                expression = "_this setVariable ['fishermanworkradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """20""";
                category = "Recondo_CivPOL_Behavior";
            };
            class WorkMoveDistanceMin {
                displayName = "Work Move Distance (Min)";
                tooltip = "Minimum distance civilians move between work spots.";
                control = "Edit";
                property = "Recondo_CivPOL_WorkMoveDistanceMin";
                expression = "_this setVariable ['workmovedistancemin', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """5""";
                category = "Recondo_CivPOL_Behavior";
            };
            class WorkMoveDistanceMax {
                displayName = "Work Move Distance (Max)";
                tooltip = "Maximum distance civilians move between work spots.";
                control = "Edit";
                property = "Recondo_CivPOL_WorkMoveDistanceMax";
                expression = "_this setVariable ['workmovedistancemax', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """15""";
                category = "Recondo_CivPOL_Behavior";
            };
            class WorkDurationMin {
                displayName = "Work Duration (Min)";
                tooltip = "Minimum seconds civilians spend at each work spot before moving.";
                control = "Edit";
                property = "Recondo_CivPOL_WorkDurationMin";
                expression = "_this setVariable ['workdurationmin', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """15""";
                category = "Recondo_CivPOL_Behavior";
            };
            class WorkDurationMax {
                displayName = "Work Duration (Max)";
                tooltip = "Maximum seconds civilians spend at each work spot before moving.";
                control = "Edit";
                property = "Recondo_CivPOL_WorkDurationMax";
                expression = "_this setVariable ['workdurationmax', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """45""";
                category = "Recondo_CivPOL_Behavior";
            };
            class FieldPropsCount {
                displayName = "Field Props Count";
                tooltip = "Number of props (carts, baskets, sacks) to spawn at each FIELDS_ marker when civilians spawn.";
                control = "Edit";
                property = "Recondo_CivPOL_FieldPropsCount";
                expression = "_this setVariable ['fieldpropscount', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """4""";
                category = "Recondo_CivPOL_Behavior";
            };
            class FieldPropsClasses {
                displayName = "Field Props Classnames";
                tooltip = "Comma-separated list of object classnames to spawn at FIELDS_ markers (carts, baskets, sacks, etc).";
                control = "EditMulti5";
                property = "Recondo_CivPOL_FieldPropsClasses";
                expression = "_this setVariable ['fieldpropsclasses', _value, true];";
                typeName = "STRING";
                defaultValue = """Land_WoodenCart_F,Land_Sacks_goods_F,Land_Sack_F,Land_Basket_F""";
                category = "Recondo_CivPOL_Behavior";
            };
            class FishermanPropsCount {
                displayName = "Fisherman Props Count";
                tooltip = "Number of props (fishing gear, cages, boats) to spawn at each FISHERMAN_ marker when civilians spawn.";
                control = "Edit";
                property = "Recondo_CivPOL_FishermanPropsCount";
                expression = "_this setVariable ['fishermanpropscount', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """4""";
                category = "Recondo_CivPOL_Behavior";
            };
            class FishermanPropsClasses {
                displayName = "Fisherman Props Classnames";
                tooltip = "Comma-separated list of object classnames to spawn at FISHERMAN_ markers (fishing gear, boats, cages, etc).";
                control = "EditMulti5";
                property = "Recondo_CivPOL_FishermanPropsClasses";
                expression = "_this setVariable ['fishermanpropsclasses', _value, true];";
                typeName = "STRING";
                defaultValue = """Land_FishingGear_01_F,Land_FishingGear_02_F,Land_Cages_F,Land_CrabCages_F,Land_vn_boat_01_abandoned_blue_f,Land_vn_boat_03_abandoned_f,Land_vn_boat_02_abandoned_f,Land_vn_boat_01_abandoned_red_f,Land_RowBoat_V1_F,Land_RowBoat_V2_F""";
                category = "Recondo_CivPOL_Behavior";
            };
            class WorkAnimations {
                displayName = "Work Animations (Farmers)";
                tooltip = "Comma-separated list of animations for farmer work behavior.";
                control = "EditMulti5";
                property = "Recondo_CivPOL_WorkAnimations";
                expression = "_this setVariable ['workanimations', _value, true];";
                typeName = "STRING";
                defaultValue = """AinvPknlMstpSnonWnonDnon_medic_1,AinvPknlMstpSnonWnonDnon_medic0,Acts_carFixingWheel""";
                category = "Recondo_CivPOL_Behavior";
            };
            class FishAnimations {
                displayName = "Work Animations (Fishermen)";
                tooltip = "Comma-separated list of animations for fisherman work behavior.";
                control = "EditMulti5";
                property = "Recondo_CivPOL_FishAnimations";
                expression = "_this setVariable ['fishanimations', _value, true];";
                typeName = "STRING";
                defaultValue = """AinvPknlMstpSlayWnonDnon_medic,Acts_PercMwlkSlowWrflDf_FlvG1""";
                category = "Recondo_CivPOL_Behavior";
            };
            
            // ========================================
            // NIGHT LIGHT SETTINGS
            // ========================================
            class EnableNightLights {
                displayName = "LIGHTS - Enable Night Lights";
                tooltip = "Enable lights in occupied homes during evening and night hours.";
                control = "Checkbox";
                property = "Recondo_CivPOL_EnableNightLights";
                expression = "_this setVariable ['enablenightlights', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_CivPOL_Lights";
            };
            class LightBrightnessMin {
                displayName = "Light Brightness Min";
                tooltip = "Minimum brightness of night lights (0.0 - 1.0).";
                control = "Edit";
                property = "Recondo_CivPOL_LightBrightnessMin";
                expression = "_this setVariable ['lightbrightnessmin', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """0.02""";
                category = "Recondo_CivPOL_Lights";
            };
            class LightBrightnessMax {
                displayName = "Light Brightness Max";
                tooltip = "Maximum brightness of night lights (0.0 - 1.0).";
                control = "Edit";
                property = "Recondo_CivPOL_LightBrightnessMax";
                expression = "_this setVariable ['lightbrightnessmax', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """0.08""";
                category = "Recondo_CivPOL_Lights";
            };
            
            // ========================================
            // DEBUG SETTINGS
            // ========================================
            class DebugLogging {
                displayName = "DEBUG - Enable Logging";
                tooltip = "Enable debug logging to RPT file.";
                control = "Checkbox";
                property = "Recondo_CivPOL_DebugLogging";
                expression = "_this setVariable ['debuglogging', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_CivPOL_Debug";
            };
            class DebugMarkers {
                displayName = "Enable Debug Markers";
                tooltip = "Show debug markers for village centers and home locations.";
                control = "Checkbox";
                property = "Recondo_CivPOL_DebugMarkers";
                expression = "_this setVariable ['debugmarkers', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_CivPOL_Debug";
            };
        };
    };
    
    //==========================================
    // CAMPS RANDOM MODULE
    // Spawns small enemy campsites with intel
    //==========================================
    class Recondo_Module_CampsRandom: Module_F {
        scope = 2;
        displayName = "Camps - Random";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleCampsRandom";
        functionPriority = 5;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 1;
        
        class ModuleDescription: ModuleDescription {
            description = "Spawns small enemy campsites with intel at random marker locations. Camps are NOT persistent between mission restarts. Sync to Intel module for location reveals.";
            sync[] = {"Recondo_Module_Intel"};
        };
        
        class Attributes: AttributesBase {
            
            // ========================================
            // GENERAL SETTINGS
            // ========================================
            
            class CampName {
                displayName = "GENERAL - Camp Name";
                tooltip = "Display name for these camps (used in Intel Board and hints).";
                control = "Edit";
                property = "Recondo_CampsRandom_CampName";
                expression = "_this setVariable ['campname', _value, true];";
                typeName = "STRING";
                defaultValue = """Enemy Camp""";
                category = "Recondo_CampsRandom_General";
            };
            
            class CampDesc {
                displayName = "Camp Description";
                tooltip = "Description shown in Intel Board.";
                control = "EditMulti5";
                property = "Recondo_CampsRandom_CampDesc";
                expression = "_this setVariable ['campdesc', _value, true];";
                typeName = "STRING";
                defaultValue = """A small enemy campsite with potential intelligence.""";
                category = "Recondo_CampsRandom_General";
            };
            
            class MarkerPrefix {
                displayName = "Marker Prefix";
                tooltip = "Prefix for invisible map markers where camps can spawn. Example: 'CAMP_' will find markers named CAMP_1, CAMP_2, etc.";
                control = "Edit";
                property = "Recondo_CampsRandom_MarkerPrefix";
                expression = "_this setVariable ['markerprefix', _value, true];";
                typeName = "STRING";
                defaultValue = """CAMP_""";
                category = "Recondo_CampsRandom_General";
            };
            
            class SpawnPercentage {
                displayName = "Spawn Percentage";
                tooltip = "Percentage of markers that will have camps spawned (0.0 - 1.0). Example: 0.5 = 50% of markers.";
                control = "Slider";
                property = "Recondo_CampsRandom_SpawnPercentage";
                expression = "_this setVariable ['spawnpercentage', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.5";
                sliderRange[] = {0.1, 1.0};
                sliderStep = 0.05;
                category = "Recondo_CampsRandom_General";
            };
            
            // ========================================
            // COMPOSITION POOL (Mod Bundled)
            // ========================================
            class Comp_VCCamp1 {
                displayName = "VC Camp 1";
                tooltip = "Enable this composition (VC_camp1.sqe).";
                control = "Checkbox";
                property = "Recondo_CampsRandom_Comp_VCCamp1";
                expression = "_this setVariable ['comp_vc_camp1', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_CampsRandom_CompPool";
            };
            class Comp_VCCamp2 {
                displayName = "VC Camp 2";
                tooltip = "Enable this composition (VC_camp2.sqe).";
                control = "Checkbox";
                property = "Recondo_CampsRandom_Comp_VCCamp2";
                expression = "_this setVariable ['comp_vc_camp2', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_CampsRandom_CompPool";
            };
            
            // ========================================
            // CUSTOM COMPOSITIONS
            // ========================================
            class CustomCompositionPath {
                displayName = "CUSTOM - Folder Path";
                tooltip = "Path to compositions folder in mission directory for your custom compositions.";
                control = "Edit";
                property = "Recondo_CampsRandom_CustomCompPath";
                expression = "_this setVariable ['customcomppath', _value, true];";
                typeName = "STRING";
                defaultValue = """compositions""";
                category = "Recondo_CampsRandom_CompCustom";
            };
            class CustomCompositions {
                displayName = "CUSTOM - Composition List";
                tooltip = "Your custom composition filenames (with or without .sqe extension). One per line or comma-separated. These are added to checked compositions above.";
                control = "EditCodeMulti5";
                property = "Recondo_CampsRandom_CustomComps";
                expression = "_this setVariable ['customcompositions', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_CampsRandom_CompCustom";
            };
            
            // ========================================
            // SPAWNING SETTINGS
            // ========================================
            
            class SpawnMode {
                displayName = "SPAWN - Spawn Mode";
                tooltip = "Immediate spawns all camps at mission start. Proximity spawns when players approach.";
                control = "Combo";
                property = "Recondo_CampsRandom_SpawnMode";
                expression = "_this setVariable ['spawnmode', _value, true];";
                typeName = "NUMBER";
                defaultValue = "1";
                category = "Recondo_CampsRandom_Spawning";
                class Values {
                    class Immediate { name = "Immediate"; value = 0; };
                    class Proximity { name = "Proximity Trigger"; value = 1; };
                };
            };
            
            class TriggerRadius {
                displayName = "Trigger Radius";
                tooltip = "Distance at which proximity spawning activates (meters).";
                control = "Edit";
                property = "Recondo_CampsRandom_TriggerRadius";
                expression = "_this setVariable ['triggerradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """500""";
                category = "Recondo_CampsRandom_Spawning";
            };
            
            class TriggerSide {
                displayName = "Trigger Side";
                tooltip = "Which side activates proximity triggers.";
                control = "Combo";
                property = "Recondo_CampsRandom_TriggerSide";
                expression = "_this setVariable ['triggerside', _value, true];";
                typeName = "NUMBER";
                defaultValue = "1";
                category = "Recondo_CampsRandom_Spawning";
                class Values {
                    class East { name = "OPFOR"; value = 0; };
                    class West { name = "BLUFOR"; value = 1; };
                    class Guer { name = "Independent"; value = 2; };
                    class Any { name = "Any"; value = 3; };
                };
            };
            
            class ClearRadius {
                displayName = "Terrain Clear Radius";
                tooltip = "Radius to clear terrain objects (trees, bushes) around camp center (meters).";
                control = "Edit";
                property = "Recondo_CampsRandom_ClearRadius";
                expression = "_this setVariable ['clearradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """15""";
                category = "Recondo_CampsRandom_Spawning";
            };
            
            class SimulationDistance {
                displayName = "Simulation Distance";
                tooltip = "Distance in meters at which simulation is enabled for camp objects and AI. When players are outside this range, simulation is disabled for performance. AI will return to sitting when players leave.";
                control = "Edit";
                property = "Recondo_CampsRandom_SimulationDistance";
                expression = "_this setVariable ['simulationdistance', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """150""";
                category = "Recondo_CampsRandom_Spawning";
            };
            
            class UseSimpleObjects {
                displayName = "Use Simple Objects";
                tooltip = "Convert composition objects to simple objects for better performance. Simple objects cannot be interacted with, damaged, or animated.";
                control = "Checkbox";
                property = "Recondo_CampsRandom_UseSimpleObjects";
                expression = "_this setVariable ['usesimpleobjects', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_CampsRandom_Spawning";
            };
            
            class SimpleObjectExclusions {
                displayName = "Simple Object Exclusions";
                tooltip = "Classnames of objects to exclude from simple object conversion. One classname per line. Useful for campfires, lights, or animated objects that need to remain interactive.";
                control = "EditMulti5";
                property = "Recondo_CampsRandom_SimpleObjectExclusions";
                expression = "_this setVariable ['simpleobjectexclusions', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_CampsRandom_Spawning";
            };
            
            // ========================================
            // AI SETTINGS
            // ========================================
            
            class SentryClassnames {
                displayName = "AI - Sentry Classnames";
                tooltip = "Unit classnames for camp sentries. One per line or comma-separated.";
                control = "EditMulti5";
                property = "Recondo_CampsRandom_SentryClassnames";
                expression = "_this setVariable ['sentryclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_CampsRandom_AI";
            };
            
            class SentryMinCount {
                displayName = "Minimum Sentries";
                tooltip = "Minimum number of AI sentries at each camp.";
                control = "Edit";
                property = "Recondo_CampsRandom_SentryMinCount";
                expression = "_this setVariable ['sentrymincount', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """2""";
                category = "Recondo_CampsRandom_AI";
            };
            
            class SentryMaxCount {
                displayName = "Maximum Sentries";
                tooltip = "Maximum number of AI sentries at each camp.";
                control = "Edit";
                property = "Recondo_CampsRandom_SentryMaxCount";
                expression = "_this setVariable ['sentrymaxcount', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """3""";
                category = "Recondo_CampsRandom_AI";
            };
            
            class SentrySide {
                displayName = "Sentry Side";
                tooltip = "Side for spawned AI sentries.";
                control = "Combo";
                property = "Recondo_CampsRandom_SentrySide";
                expression = "_this setVariable ['sentryside', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0";
                category = "Recondo_CampsRandom_AI";
                class Values {
                    class East { name = "OPFOR"; value = 0; };
                    class West { name = "BLUFOR"; value = 1; };
                    class Guer { name = "Independent"; value = 2; };
                };
            };
            
            class SentryAnimations {
                displayName = "Sentry Animations";
                tooltip = "Sitting animations for camp sentries. Comma-separated list of animation class names.";
                control = "EditMulti5";
                property = "Recondo_CampsRandom_SentryAnimations";
                expression = "_this setVariable ['sentryanimations', _value, true];";
                typeName = "STRING";
                defaultValue = """AmovPsitMstpSrasWrflDnon, AmovPsitMstpSrasWrflDnon_WeaponCheck1, AmovPsitMstpSrasWrflDnon_WeaponCheck2, AmovPsitMstpSrasWrflDnon_Smoking""";
                category = "Recondo_CampsRandom_AI";
            };
            
            // ========================================
            // INTEL - GROUND OBJECT
            // ========================================
            
            class EnableIntelObject {
                displayName = "INTEL OBJ - Enable Intel Object";
                tooltip = "Spawn a physical intel object at camps that players can pick up.";
                control = "Checkbox";
                property = "Recondo_CampsRandom_EnableIntelObject";
                expression = "_this setVariable ['enableintelobject', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_CampsRandom_IntelObject";
            };
            
            class IntelObjectClassname {
                displayName = "Intel Object Classname";
                tooltip = "Classname of the intel object to spawn (e.g., Land_File1_F, Land_Map_F).";
                control = "Edit";
                property = "Recondo_CampsRandom_IntelObjectClassname";
                expression = "_this setVariable ['intelobjectclassname', _value, true];";
                typeName = "STRING";
                defaultValue = """Land_File1_F""";
                category = "Recondo_CampsRandom_IntelObject";
            };
            
            class IntelObjectActionText {
                displayName = "Pickup Action Text";
                tooltip = "Text shown for the ACE interaction to pick up the intel.";
                control = "Edit";
                property = "Recondo_CampsRandom_IntelObjectActionText";
                expression = "_this setVariable ['intelobjectactiontext', _value, true];";
                typeName = "STRING";
                defaultValue = """Take Documents""";
                category = "Recondo_CampsRandom_IntelObject";
            };
            
            class IntelObjectDisplayName {
                displayName = "Intel Display Name";
                tooltip = "Name shown in intel card when examining picked up intel.";
                control = "Edit";
                property = "Recondo_CampsRandom_IntelObjectDisplayName";
                expression = "_this setVariable ['intelobjectdisplayname', _value, true];";
                typeName = "STRING";
                defaultValue = """Field Documents""";
                category = "Recondo_CampsRandom_IntelObject";
            };
            
            class IntelObjectItemClassname {
                displayName = "Inventory Item Classname";
                tooltip = "Item classname added to player inventory when picking up intel (from Intel module's intel items list).";
                control = "Edit";
                property = "Recondo_CampsRandom_IntelObjectItemClassname";
                expression = "_this setVariable ['intelobjectitemclassname', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_CampsRandom_IntelObject";
            };
            
            // ========================================
            // INTEL - UNIT INVENTORY
            // ========================================
            
            class EnableIntelUnit {
                displayName = "INTEL UNIT - Enable Intel on Units";
                tooltip = "Add intel items to sentry unit inventories (uses IntelItems module if available).";
                control = "Checkbox";
                property = "Recondo_CampsRandom_EnableIntelUnit";
                expression = "_this setVariable ['enableintelunit', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_CampsRandom_IntelUnit";
            };
            
            class IntelUnitChance {
                displayName = "Intel Chance Per Unit";
                tooltip = "Probability (0-1) that each sentry will have intel in their inventory.";
                control = "Slider";
                property = "Recondo_CampsRandom_IntelUnitChance";
                expression = "_this setVariable ['intelunitchance', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0.5";
                sliderRange[] = {0, 1};
                sliderStep = 0.1;
                category = "Recondo_CampsRandom_IntelUnit";
            };
            
            // ========================================
            // INTEL SYSTEM INTEGRATION
            // ========================================
            
            class IntelWeight {
                displayName = "INTEL SYS - Intel Weight";
                tooltip = "Reveal weight for Intel system (1 = easy to reveal, 10 = hard). Lower = more likely to be revealed when intel is turned in.";
                control = "Slider";
                property = "Recondo_CampsRandom_IntelWeight";
                expression = "_this setVariable ['intelweight', _value, true];";
                typeName = "NUMBER";
                defaultValue = "3";
                sliderRange[] = {1, 10};
                sliderStep = 1;
                category = "Recondo_CampsRandom_Intel";
            };
            
            // ========================================
            // SMELL HINTS
            // ========================================
            
            class EnableSmellHints {
                displayName = "SMELL - Enable Smell Hints";
                tooltip = "Show atmospheric hints when players approach camps.";
                control = "Checkbox";
                property = "Recondo_CampsRandom_EnableSmellHints";
                expression = "_this setVariable ['enablesmellhints', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_CampsRandom_SmellHints";
            };
            
            class SmellHintRadius {
                displayName = "Smell Hint Radius";
                tooltip = "Distance at which smell hints trigger (meters).";
                control = "Edit";
                property = "Recondo_CampsRandom_SmellHintRadius";
                expression = "_this setVariable ['smellhintradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """150""";
                category = "Recondo_CampsRandom_SmellHints";
            };
            
            class SmellHintMessages {
                displayName = "Smell Hint Messages";
                tooltip = "Comma-separated list of hint messages. One is randomly selected.";
                control = "EditMulti5";
                property = "Recondo_CampsRandom_SmellHintMessages";
                expression = "_this setVariable ['smellhintmessages', _value, true];";
                typeName = "STRING";
                defaultValue = """The smell of woodsmoke drifts on the breeze...,A faint campfire scent hangs in the air...,You catch a whiff of smoke nearby...,Something is burning nearby...""";
                category = "Recondo_CampsRandom_SmellHints";
            };
            
            // ========================================
            // DEBUG
            // ========================================
            
            class DebugLogging {
                displayName = "DEBUG - Enable Logging";
                tooltip = "Enable detailed RPT logging for troubleshooting.";
                control = "Checkbox";
                property = "Recondo_CampsRandom_DebugLogging";
                expression = "_this setVariable ['debuglogging', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_CampsRandom_Debug";
            };
            
            class DebugMarkers {
                displayName = "Enable Debug Markers";
                tooltip = "Show visible debug markers at camp locations.";
                control = "Checkbox";
                property = "Recondo_CampsRandom_DebugMarkers";
                expression = "_this setVariable ['debugmarkers', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_CampsRandom_Debug";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    // ==========================================
    // PLAYER LIMITATIONS MODULE
    // ==========================================
    class Recondo_Module_PlayerLimitations: Module_F {
        scope = 2;
        displayName = "Player Limitations";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_modulePlayerLimitations";
        functionPriority = 1;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 1;
        icon = "\a3\modules_f\data\iconTaskSetState_ca.paa";
        
        class ModuleDescription: ModuleDescription {
            description = "Limits player inventory items for balancing purposes. Periodically checks player inventories and removes excess items that exceed configured limits. Supports wildcard pattern matching for item classnames.";
            sync[] = {};
        };
        
        class Attributes: AttributesBase {
            
            // ========================================
            // GENERAL SETTINGS
            // ========================================
            class AllowedSide {
                displayName = "GENERAL - Affected Side";
                tooltip = "Which side of players should be affected by these limitations.";
                control = "Combo";
                property = "Recondo_PlayerLimits_Side";
                expression = "_this setVariable ['allowedside', _value, true];";
                typeName = "NUMBER";
                defaultValue = "1";
                class Values {
                    class OPFOR { name = "OPFOR"; value = 0; };
                    class BLUFOR { name = "BLUFOR"; value = 1; default = 1; };
                    class INDFOR { name = "Independent"; value = 2; };
                    class CIV { name = "Civilian"; value = 3; };
                    class ANY { name = "Any Side"; value = 4; };
                };
                category = "Recondo_PlayerLimits_General";
            };
            
            class CheckInterval {
                displayName = "Check Interval (seconds)";
                tooltip = "How often to check player inventories. Minimum 10 seconds. Default: 60";
                control = "Edit";
                property = "Recondo_PlayerLimits_CheckInterval";
                expression = "_this setVariable ['checkinterval', _value, true];";
                typeName = "NUMBER";
                defaultValue = "60";
                category = "Recondo_PlayerLimits_General";
            };
            
            class AnnounceTeamkillers {
                displayName = "Announce Teamkillers";
                tooltip = "When enabled, globally announces in system chat when a player kills another player of the same side.";
                control = "Checkbox";
                property = "Recondo_PlayerLimits_AnnounceTeamkillers";
                expression = "_this setVariable ['announceteamkillers', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_PlayerLimits_General";
            };
            
            // ========================================
            // ITEM LIMITATION 1
            // ========================================
            class Item1Class {
                displayName = "LIMIT 1 - Item Pattern";
                tooltip = "Item classname or pattern. Supports wildcards: *grenade* matches any item containing 'grenade'. Leave empty to skip.";
                control = "Edit";
                property = "Recondo_PlayerLimits_Item1Class";
                expression = "_this setVariable ['item1class', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_PlayerLimits_Limit1";
            };
            
            class Item1Limit {
                displayName = "Max Quantity";
                tooltip = "Maximum number of matching items allowed. Excess will be removed.";
                control = "Edit";
                property = "Recondo_PlayerLimits_Item1Limit";
                expression = "_this setVariable ['item1limit', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0";
                category = "Recondo_PlayerLimits_Limit1";
            };
            
            // ========================================
            // ITEM LIMITATION 2
            // ========================================
            class Item2Class {
                displayName = "LIMIT 2 - Item Pattern";
                tooltip = "Item classname or pattern. Supports wildcards: *grenade* matches any item containing 'grenade'. Leave empty to skip.";
                control = "Edit";
                property = "Recondo_PlayerLimits_Item2Class";
                expression = "_this setVariable ['item2class', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_PlayerLimits_Limit2";
            };
            
            class Item2Limit {
                displayName = "Max Quantity";
                tooltip = "Maximum number of matching items allowed. Excess will be removed.";
                control = "Edit";
                property = "Recondo_PlayerLimits_Item2Limit";
                expression = "_this setVariable ['item2limit', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0";
                category = "Recondo_PlayerLimits_Limit2";
            };
            
            // ========================================
            // ITEM LIMITATION 3
            // ========================================
            class Item3Class {
                displayName = "LIMIT 3 - Item Pattern";
                tooltip = "Item classname or pattern. Supports wildcards: *grenade* matches any item containing 'grenade'. Leave empty to skip.";
                control = "Edit";
                property = "Recondo_PlayerLimits_Item3Class";
                expression = "_this setVariable ['item3class', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_PlayerLimits_Limit3";
            };
            
            class Item3Limit {
                displayName = "Max Quantity";
                tooltip = "Maximum number of matching items allowed. Excess will be removed.";
                control = "Edit";
                property = "Recondo_PlayerLimits_Item3Limit";
                expression = "_this setVariable ['item3limit', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0";
                category = "Recondo_PlayerLimits_Limit3";
            };
            
            // ========================================
            // ITEM LIMITATION 4
            // ========================================
            class Item4Class {
                displayName = "LIMIT 4 - Item Pattern";
                tooltip = "Item classname or pattern. Supports wildcards: *grenade* matches any item containing 'grenade'. Leave empty to skip.";
                control = "Edit";
                property = "Recondo_PlayerLimits_Item4Class";
                expression = "_this setVariable ['item4class', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_PlayerLimits_Limit4";
            };
            
            class Item4Limit {
                displayName = "Max Quantity";
                tooltip = "Maximum number of matching items allowed. Excess will be removed.";
                control = "Edit";
                property = "Recondo_PlayerLimits_Item4Limit";
                expression = "_this setVariable ['item4limit', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0";
                category = "Recondo_PlayerLimits_Limit4";
            };
            
            // ========================================
            // ITEM LIMITATION 5
            // ========================================
            class Item5Class {
                displayName = "LIMIT 5 - Item Pattern";
                tooltip = "Item classname or pattern. Supports wildcards: *grenade* matches any item containing 'grenade'. Leave empty to skip.";
                control = "Edit";
                property = "Recondo_PlayerLimits_Item5Class";
                expression = "_this setVariable ['item5class', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_PlayerLimits_Limit5";
            };
            
            class Item5Limit {
                displayName = "Max Quantity";
                tooltip = "Maximum number of matching items allowed. Excess will be removed.";
                control = "Edit";
                property = "Recondo_PlayerLimits_Item5Limit";
                expression = "_this setVariable ['item5limit', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0";
                category = "Recondo_PlayerLimits_Limit5";
            };
            
            // ========================================
            // DEBUG
            // ========================================
            class EnableDebug {
                displayName = "DEBUG - Enable Debug Logging";
                tooltip = "Enable detailed RPT logging for troubleshooting.";
                control = "Checkbox";
                property = "Recondo_PlayerLimits_EnableDebug";
                expression = "_this setVariable ['enabledebug', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_PlayerLimits_Debug";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    // ==========================================
    // PLAYER INTEL DROPS MODULE
    // ==========================================
    class Recondo_Module_PlayerIntelDrops: Module_F {
        scope = 2;
        displayName = "Player Intel Drops";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_modulePlayerIntelDrops";
        functionPriority = 1;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 1;
        icon = "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\intel_ca.paa";
        
        class ModuleDescription: ModuleDescription {
            description = "When configured players die, intel items are added to their body for enemies to collect. Integrates with the Intel module for turn-in and reveals.";
            sync[] = {};
        };
        
        class Attributes: AttributesBase {
            
            // ========================================
            // GENERAL SETTINGS
            // ========================================
            class AffectedSide {
                displayName = "GENERAL - Affected Side";
                tooltip = "Which player side will drop intel on death.";
                control = "Combo";
                property = "Recondo_PlayerIntelDrops_Side";
                expression = "_this setVariable ['affectedside', _value, true];";
                typeName = "NUMBER";
                defaultValue = "1";
                class Values {
                    class OPFOR { name = "OPFOR"; value = 0; };
                    class BLUFOR { name = "BLUFOR"; value = 1; default = 1; };
                    class INDFOR { name = "Independent"; value = 2; };
                    class CIV { name = "Civilian"; value = 3; };
                };
                category = "Recondo_PlayerIntelDrops_General";
            };
            
            class UnitClassnames {
                displayName = "Unit Classnames (Filter)";
                tooltip = "Comma-separated list of unit classnames that drop intel. Leave empty to affect ALL players of the selected side.";
                control = "Edit";
                property = "Recondo_PlayerIntelDrops_UnitClassnames";
                expression = "_this setVariable ['unitclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_PlayerIntelDrops_General";
            };
            
            class DropChance {
                displayName = "Drop Chance (%)";
                tooltip = "Percentage chance (0-100) that intel drops on death. Default: 100";
                control = "Edit";
                property = "Recondo_PlayerIntelDrops_DropChance";
                expression = "_this setVariable ['dropchance', _value, true];";
                typeName = "NUMBER";
                defaultValue = "100";
                category = "Recondo_PlayerIntelDrops_General";
            };
            
            // ========================================
            // INTEL ITEMS
            // ========================================
            class IntelItems {
                displayName = "INTEL - Item Definitions";
                tooltip = "Define intel items. Format: DisplayName,Classname (one per line). Example:\nMobile Phone,ACE_Cellphone\nNotebook,acex_intelitems_notepad";
                control = "EditMulti5";
                property = "Recondo_PlayerIntelDrops_IntelItems";
                expression = "_this setVariable ['intelitems', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_PlayerIntelDrops_Intel";
            };
            
            // ========================================
            // DEBUG
            // ========================================
            class EnableDebug {
                displayName = "DEBUG - Enable Debug Logging";
                tooltip = "Enable detailed RPT logging for troubleshooting.";
                control = "Checkbox";
                property = "Recondo_PlayerIntelDrops_EnableDebug";
                expression = "_this setVariable ['enabledebug', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_PlayerIntelDrops_Debug";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    // ==========================================
    // ELDEST SON MODULE
    // ==========================================
    class Recondo_Module_EldestSon: Module_F {
        scope = 2;
        displayName = "Eldest Son (Ammo Sabotage)";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleEldestSon";
        functionPriority = 1;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 1;
        icon = "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\destroy_ca.paa";
        
        class ModuleDescription: ModuleDescription {
            description = "Operation Eldest Son - Sabotaged enemy ammunition. Players place 'poison' items in dead enemy bodies. Each item increases the chance that enemy weapons explode when fired. Simulates booby-trapped ammo supply.";
            sync[] = {};
        };
        
        class Attributes: AttributesBase {
            
            // ========================================
            // GENERAL SETTINGS
            // ========================================
            class TargetSide {
                displayName = "GENERAL - Target Side";
                tooltip = "Which side's units can be affected by sabotaged ammunition.";
                control = "Combo";
                property = "Recondo_EldestSon_TargetSide";
                expression = "_this setVariable ['targetside', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0";
                class Values {
                    class OPFOR { name = "OPFOR"; value = 0; default = 1; };
                    class BLUFOR { name = "BLUFOR"; value = 1; };
                    class INDFOR { name = "Independent"; value = 2; };
                    class CIV { name = "Civilian"; value = 3; };
                };
                category = "Recondo_EldestSon_General";
            };
            
            class ChancePerItem {
                displayName = "Chance Per Item (%)";
                tooltip = "Percentage chance added to sabotage for each poison item found. Default: 1";
                control = "Edit";
                property = "Recondo_EldestSon_ChancePerItem";
                expression = "_this setVariable ['chanceperitem', _value, true];";
                typeName = "NUMBER";
                defaultValue = "1";
                category = "Recondo_EldestSon_General";
            };
            
            class MaxChance {
                displayName = "Maximum Chance (%)";
                tooltip = "Maximum sabotage chance cap. Default: 5";
                control = "Edit";
                property = "Recondo_EldestSon_MaxChance";
                expression = "_this setVariable ['maxchance', _value, true];";
                typeName = "NUMBER";
                defaultValue = "5";
                category = "Recondo_EldestSon_General";
            };
            
            class ScanInterval {
                displayName = "Body Scan Interval (seconds)";
                tooltip = "How often to scan dead bodies for poison items. Default: 30";
                control = "Edit";
                property = "Recondo_EldestSon_ScanInterval";
                expression = "_this setVariable ['scaninterval', _value, true];";
                typeName = "NUMBER";
                defaultValue = "30";
                category = "Recondo_EldestSon_General";
            };
            
            // ========================================
            // POISON ITEMS
            // ========================================
            class PoisonItems {
                displayName = "POISON - Item Classnames";
                tooltip = "Classnames of poison items players place in bodies. Comma-separated or one per line. Example:\nuns_ak47mag\nACE_Chemlight_HiRed";
                control = "EditMulti5";
                property = "Recondo_EldestSon_PoisonItems";
                expression = "_this setVariable ['poisonitems', _value, true];";
                typeName = "STRING";
                defaultValue = """uns_ak47mag""";
                category = "Recondo_EldestSon_Items";
            };
            
            // ========================================
            // DEBUG
            // ========================================
            class EnableDebug {
                displayName = "DEBUG - Enable Debug Logging";
                tooltip = "Enable detailed RPT logging for troubleshooting.";
                control = "Checkbox";
                property = "Recondo_EldestSon_EnableDebug";
                expression = "_this setVariable ['enabledebug', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_EldestSon_Debug";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    //==========================================
    // DEPLOYABLE RALLYPOINT MODULE
    //==========================================
    class Recondo_Module_DeployableRallypoint: Module_F {
        scope = 2;
        displayName = "Deployable Rallypoint";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleDeployableRallypoint";
        functionPriority = 1;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 1;
        
        class ModuleDescription: ModuleDescription {
            description = "Deployable rally point system with ACE integration. Players can deploy rally points in the field and teammates can teleport to them from base. Sync to a base object (flag, table, etc.) for the teleport menu. Requires ACE3.";
            sync[] = {};
        };
        
        class Attributes: AttributesBase {
            
            // ========================================
            // GENERAL SETTINGS
            // ========================================
            class SystemName {
                displayName = "GENERAL - System Name";
                tooltip = "The name shown in ACE self-interaction menu for deploying. Example: 'Deploy Rally Point' or 'Deploy RON Site'.";
                control = "Edit";
                property = "Recondo_DRP_SystemName";
                expression = "_this setVariable ['systemname', _value, true];";
                typeName = "STRING";
                defaultValue = """Deploy Rally Point""";
                category = "Recondo_DRP_General";
            };
            class AllowedSide {
                displayName = "Allowed Side";
                tooltip = "Which side can use this rally point system.";
                control = "Combo";
                property = "Recondo_DRP_AllowedSide";
                expression = "_this setVariable ['allowedside', _value, true];";
                typeName = "NUMBER";
                defaultValue = "1";
                class Values {
                    class OPFOR { name = "OPFOR"; value = 0; };
                    class BLUFOR { name = "BLUFOR"; value = 1; default = 1; };
                    class INDFOR { name = "Independent"; value = 2; };
                    class CIV { name = "Civilian"; value = 3; };
                    class ANY { name = "Any Side"; value = 4; };
                };
                category = "Recondo_DRP_General";
            };
            class BaseMarkerName {
                displayName = "Base Marker Name";
                tooltip = "Variable name of the marker at your base. Used for minimum distance check. Leave empty to disable base distance restriction.";
                control = "Edit";
                property = "Recondo_DRP_BaseMarkerName";
                expression = "_this setVariable ['basemarkername', _value, true];";
                typeName = "STRING";
                defaultValue = """base_marker""";
                category = "Recondo_DRP_General";
            };
            
            // ========================================
            // RALLY OBJECT SETTINGS
            // ========================================
            class RallyObjectClass {
                displayName = "RALLY OBJECT - Object Classname";
                tooltip = "Classname of object to spawn as rally point. Default: Land_TentDome_F (camping tent). See Arma 3 Wiki CfgVehicles EMPTY for options.";
                control = "Edit";
                property = "Recondo_DRP_RallyObjectClass";
                expression = "_this setVariable ['rallyobjectclass', _value, true];";
                typeName = "STRING";
                defaultValue = """Land_TentDome_F""";
                category = "Recondo_DRP_RallyObject";
            };
            class SpawnDistance {
                displayName = "Spawn Distance (meters)";
                tooltip = "How far in front of the player to spawn the rally point object.";
                control = "Edit";
                property = "Recondo_DRP_SpawnDistance";
                expression = "_this setVariable ['spawndistance', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """5""";
                category = "Recondo_DRP_RallyObject";
            };
            
            // ========================================
            // MARKER SETTINGS
            // ========================================
            class MarkerType {
                displayName = "MARKER - Marker Type";
                tooltip = "Icon type for the rally point marker on the map.";
                control = "Edit";
                property = "Recondo_DRP_MarkerType";
                expression = "_this setVariable ['markertype', _value, true];";
                typeName = "STRING";
                defaultValue = """mil_start""";
                category = "Recondo_DRP_Marker";
            };
            class MarkerColor {
                displayName = "Marker Color";
                tooltip = "Color of the rally point marker. Examples: ColorBlue, ColorRed, ColorGreen, ColorYellow, ColorOrange.";
                control = "Edit";
                property = "Recondo_DRP_MarkerColor";
                expression = "_this setVariable ['markercolor', _value, true];";
                typeName = "STRING";
                defaultValue = """ColorBlue""";
                category = "Recondo_DRP_Marker";
            };
            class MarkerText {
                displayName = "Marker Text";
                tooltip = "Text displayed on the map marker. Use %1 for rally number (e.g., 'Rally Point %1' becomes 'Rally Point 1').";
                control = "Edit";
                property = "Recondo_DRP_MarkerText";
                expression = "_this setVariable ['markertext', _value, true];";
                typeName = "STRING";
                defaultValue = """Rally Point""";
                category = "Recondo_DRP_Marker";
            };
            
            // ========================================
            // LIMITS & RESTRICTIONS
            // ========================================
            class MaxRallies {
                displayName = "LIMITS - Max Rallies Per Side";
                tooltip = "Maximum number of rally points per side. When exceeded, the oldest rally is automatically removed. Set to 0 for unlimited.";
                control = "Edit";
                property = "Recondo_DRP_MaxRallies";
                expression = "_this setVariable ['maxrallies', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """3""";
                category = "Recondo_DRP_Limits";
            };
            class MinDistanceFromBase {
                displayName = "Min Distance from Base (meters)";
                tooltip = "Minimum distance from the base marker required to deploy a rally point. Set to 0 to disable.";
                control = "Edit";
                property = "Recondo_DRP_MinDistanceFromBase";
                expression = "_this setVariable ['mindistancefrombase', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """150""";
                category = "Recondo_DRP_Limits";
            };
            class EnemyProximity {
                displayName = "Enemy Proximity (meters)";
                tooltip = "Cannot deploy a rally point if enemies are within this distance. Set to 0 to disable.";
                control = "Edit";
                property = "Recondo_DRP_EnemyProximity";
                expression = "_this setVariable ['enemyproximity', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """100""";
                category = "Recondo_DRP_Limits";
            };
            class DestroyRemovesRally {
                displayName = "Destroy Object Removes Rally";
                tooltip = "If enabled, destroying the rally point object (tent, etc.) will permanently remove that rally point. Destroyed rallies will NOT reappear on mission restart.";
                control = "Checkbox";
                property = "Recondo_DRP_DestroyRemovesRally";
                expression = "_this setVariable ['destroyremovesrally', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_DRP_Limits";
            };
            
            // ========================================
            // REQUIREMENTS
            // ========================================
            class RequireItemEnabled {
                displayName = "REQUIREMENTS - Require Inventory Item";
                tooltip = "If enabled, player must have the specified item in their inventory to deploy a rally point.";
                control = "Checkbox";
                property = "Recondo_DRP_RequireItemEnabled";
                expression = "_this setVariable ['requireitemenabled', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_DRP_Requirements";
            };
            class RequiredItem {
                displayName = "Required Item Classname";
                tooltip = "Classname of item required to deploy rally point. Default: ACRE_PRC77 (PRC-77 radio). Only checked if 'Require Inventory Item' is enabled.";
                control = "Edit";
                property = "Recondo_DRP_RequiredItem";
                expression = "_this setVariable ['requireditem', _value, true];";
                typeName = "STRING";
                defaultValue = """ACRE_PRC77""";
                category = "Recondo_DRP_Requirements";
            };
            class RequiredItemName {
                displayName = "Required Item Display Name";
                tooltip = "Friendly name shown in hint messages when player lacks the required item.";
                control = "Edit";
                property = "Recondo_DRP_RequiredItemName";
                expression = "_this setVariable ['requireditemname', _value, true];";
                typeName = "STRING";
                defaultValue = """PRC-77 Radio""";
                category = "Recondo_DRP_Requirements";
            };
            
            // ========================================
            // TELEPORT SETTINGS
            // ========================================
            class AutoRespawnToRally {
                displayName = "TELEPORT - Auto-Respawn to Rally";
                tooltip = "If enabled, players automatically teleport to their side's most recent rally point on respawn. Note: May not work with custom respawn position systems.";
                control = "Checkbox";
                property = "Recondo_DRP_AutoRespawnToRally";
                expression = "_this setVariable ['autorespawntorally', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_DRP_Teleport";
            };
            
            // ========================================
            // UI TEXT
            // ========================================
            class DeployHint {
                displayName = "UI TEXT - Deploy Hint";
                tooltip = "Hint message shown when a rally point is deployed.";
                control = "Edit";
                property = "Recondo_DRP_DeployHint";
                expression = "_this setVariable ['deployhint', _value, true];";
                typeName = "STRING";
                defaultValue = """Rally point deployed!""";
                category = "Recondo_DRP_Text";
            };
            class UndeployHint {
                displayName = "Undeploy Hint";
                tooltip = "Hint message shown when a rally point is packed/removed.";
                control = "Edit";
                property = "Recondo_DRP_UndeployHint";
                expression = "_this setVariable ['undeployhint', _value, true];";
                typeName = "STRING";
                defaultValue = """Rally point undeployed!""";
                category = "Recondo_DRP_Text";
            };
            class PackActionText {
                displayName = "Pack Action Text";
                tooltip = "Text shown on the rally point object for packing it up.";
                control = "Edit";
                property = "Recondo_DRP_PackActionText";
                expression = "_this setVariable ['packactiontext', _value, true];";
                typeName = "STRING";
                defaultValue = """Pack Rally Point""";
                category = "Recondo_DRP_Text";
            };
            class SelectActionText {
                displayName = "Select Action Text";
                tooltip = "Text shown on the base object for selecting a rally point.";
                control = "Edit";
                property = "Recondo_DRP_SelectActionText";
                expression = "_this setVariable ['selectactiontext', _value, true];";
                typeName = "STRING";
                defaultValue = """Select Rally Point""";
                category = "Recondo_DRP_Text";
            };
            class ReplacedHint {
                displayName = "Rally Replaced Hint";
                tooltip = "Hint shown when an old rally is auto-removed due to max limit. Use %1 for the removed rally marker text.";
                control = "Edit";
                property = "Recondo_DRP_ReplacedHint";
                expression = "_this setVariable ['replacedhint', _value, true];";
                typeName = "STRING";
                defaultValue = """Oldest rally point replaced.""";
                category = "Recondo_DRP_Text";
            };
            
            // ========================================
            // PERSISTENCE
            // ========================================
            class EnablePersistence {
                displayName = "PERSISTENCE - Enable Persistence";
                tooltip = "Save rally points across mission restarts. Requires the Persistence module to be placed.";
                control = "Checkbox";
                property = "Recondo_DRP_EnablePersistence";
                expression = "_this setVariable ['enablepersistence', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_DRP_Persistence";
            };
            
            // ========================================
            // DEBUG
            // ========================================
            class EnableDebug {
                displayName = "DEBUG - Enable Logging";
                tooltip = "Enable detailed logging to RPT file for troubleshooting.";
                control = "Checkbox";
                property = "Recondo_DRP_EnableDebug";
                expression = "_this setVariable ['enabledebug', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_DRP_Debug";
            };
            class EnableDebugMarkers {
                displayName = "Enable Debug Markers";
                tooltip = "Show debug markers on the map for rally points.";
                control = "Checkbox";
                property = "Recondo_DRP_EnableDebugMarkers";
                expression = "_this setVariable ['enabledebugmarkers', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_DRP_Debug";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    // ============================================================================
    // RECON POINTS SYSTEM MODULE
    // ============================================================================
    class Recondo_Module_ReconPoints: Module_F {
        scope = 2;
        displayName = "Recon Points System";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleReconPoints";
        functionPriority = 1;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 0;
        canSetArea = 0;
        icon = "\a3\ui_f\data\igui\cfg\actions\arrow_up_gs.paa";
        
        class ModuleDescription: ModuleDescription {
            description = "Point-based progression system. Players earn Recon Points by completing objectives (HVT captures, hostage rescues, intel turn-ins, etc.) and enemy kills. Points can be spent at Unlock Terminals to permanently unlock gear items. Sync objects to this module to create Unlock Terminals.";
            sync[] = {"LocationArea_F"};
        };
        
        class Attributes: AttributesBase {
            
            // ========================================
            // GENERAL SETTINGS
            // ========================================
            class TerminalName {
                displayName = "GENERAL - Terminal Display Name";
                tooltip = "Name displayed for unlock terminals in ACE interactions.";
                control = "Edit";
                property = "Recondo_RP_TerminalName";
                expression = "_this setVariable ['terminalname', _value, true];";
                typeName = "STRING";
                defaultValue = """Unlock Terminal""";
                category = "Recondo_RP_General";
            };
            class DebugLogging {
                displayName = "Enable Debug Logging";
                tooltip = "Log detailed RP events to RPT file for troubleshooting.";
                control = "Checkbox";
                property = "Recondo_RP_DebugLogging";
                expression = "_this setVariable ['debuglogging', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_RP_General";
            };
            
            // ========================================
            // POINT REWARDS
            // ========================================
            class RewardHVT {
                displayName = "REWARDS - HVT Capture";
                tooltip = "Points awarded for successfully capturing a High Value Target. Awarded to all players in the capturing group.";
                control = "Edit";
                property = "Recondo_RP_RewardHVT";
                expression = "_this setVariable ['reward_hvt', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """50""";
                category = "Recondo_RP_Rewards";
            };
            class RewardHostage {
                displayName = "Hostage Rescue";
                tooltip = "Points awarded for successfully rescuing a hostage. Awarded to all players in the rescuing group.";
                control = "Edit";
                property = "Recondo_RP_RewardHostage";
                expression = "_this setVariable ['reward_hostage', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """40""";
                category = "Recondo_RP_Rewards";
            };
            class RewardIntel {
                displayName = "Intel Turn-In";
                tooltip = "Points awarded for turning in intelligence documents. Awarded to the player turning in the intel.";
                control = "Edit";
                property = "Recondo_RP_RewardIntel";
                expression = "_this setVariable ['reward_intel', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """15""";
                category = "Recondo_RP_Rewards";
            };
            class RewardWiretap {
                displayName = "Wiretap Completed";
                tooltip = "Points awarded for successfully placing a wiretap. Awarded to the player completing the wiretap.";
                control = "Edit";
                property = "Recondo_RP_RewardWiretap";
                expression = "_this setVariable ['reward_wiretap', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """25""";
                category = "Recondo_RP_Rewards";
            };
            class RewardDestroy {
                displayName = "Objective Destroyed";
                tooltip = "Points awarded for destroying an objective (cache, jammer, hub). Awarded to players who dealt damage.";
                control = "Edit";
                property = "Recondo_RP_RewardDestroy";
                expression = "_this setVariable ['reward_destroy', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """30""";
                category = "Recondo_RP_Rewards";
            };
            class RewardPOW {
                displayName = "POW Turn-In";
                tooltip = "Points awarded for turning in a prisoner of war. Awarded to the player turning in the POW.";
                control = "Edit";
                property = "Recondo_RP_RewardPOW";
                expression = "_this setVariable ['reward_pow', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """20""";
                category = "Recondo_RP_Rewards";
            };
            class RewardKill {
                displayName = "Enemy Kill";
                tooltip = "Points awarded per enemy AI kill. Set to 0 to disable kill rewards. Only the killer receives points.";
                control = "Edit";
                property = "Recondo_RP_RewardKill";
                expression = "_this setVariable ['reward_kill', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """1""";
                category = "Recondo_RP_Rewards";
            };
            
            // ========================================
            // DEATH PENALTY
            // ========================================
            class DeathPenaltyEnabled {
                displayName = "DEATH PENALTY - Enable";
                tooltip = "Enable point penalty when player dies.";
                control = "Checkbox";
                property = "Recondo_RP_DeathPenaltyEnabled";
                expression = "_this setVariable ['deathpenaltyenabled', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_RP_Death";
            };
            class DeathPenaltyType {
                displayName = "Penalty Type";
                tooltip = "0 = Reset points to 0, 1 = Subtract fixed amount";
                control = "Edit";
                property = "Recondo_RP_DeathPenaltyType";
                expression = "_this setVariable ['deathpenaltytype', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """0""";
                category = "Recondo_RP_Death";
            };
            class DeathSubtractAmount {
                displayName = "Subtract Amount";
                tooltip = "Points to subtract on death (only used if Penalty Type is 1).";
                control = "Edit";
                property = "Recondo_RP_DeathSubtractAmount";
                expression = "_this setVariable ['deathsubtractamount', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """25""";
                category = "Recondo_RP_Death";
            };
            class DeathResetUnlocks {
                displayName = "Reset Unlocks on Death";
                tooltip = "If enabled, player loses all unlocked items when they die (hardcore mode).";
                control = "Checkbox";
                property = "Recondo_RP_DeathResetUnlocks";
                expression = "_this setVariable ['deathresetunlocks', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_RP_Death";
            };
            
            // ========================================
            // UNLOCKABLE ITEMS - PRIMARY
            // ========================================
            class ItemsPrimary {
                displayName = "ITEMS - Primary Weapons";
                tooltip = "Unlockable primary weapons. Format: classname, Display Name, cost (one per line)\nExample:\nvn_m16_camo, M16 (Tiger Stripe), 25\nvn_m40a1, M40A1 Sniper, 100";
                control = "EditCodeMulti5";
                property = "Recondo_RP_ItemsPrimary";
                expression = "_this setVariable ['items_primary', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_RP_Items_Weapons";
            };
            class ItemsSecondary {
                displayName = "Secondary Weapons";
                tooltip = "Unlockable secondary weapons (launchers). Format: classname, Display Name, cost (one per line)";
                control = "EditCodeMulti5";
                property = "Recondo_RP_ItemsSecondary";
                expression = "_this setVariable ['items_secondary', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_RP_Items_Weapons";
            };
            class ItemsHandgun {
                displayName = "Handguns";
                tooltip = "Unlockable handguns. Format: classname, Display Name, cost (one per line)";
                control = "EditCodeMulti5";
                property = "Recondo_RP_ItemsHandgun";
                expression = "_this setVariable ['items_handgun', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_RP_Items_Weapons";
            };
            
            // ========================================
            // UNLOCKABLE ITEMS - ATTACHMENTS & MAGS
            // ========================================
            class ItemsAttach {
                displayName = "ITEMS - Attachments";
                tooltip = "Unlockable weapon attachments (scopes, suppressors, etc.). Format: classname, Display Name, cost (one per line)";
                control = "EditCodeMulti5";
                property = "Recondo_RP_ItemsAttach";
                expression = "_this setVariable ['items_attach', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_RP_Items_Attach";
            };
            class ItemsMags {
                displayName = "Magazines";
                tooltip = "Unlockable magazines. Format: classname, Display Name, cost (one per line)";
                control = "EditCodeMulti5";
                property = "Recondo_RP_ItemsMags";
                expression = "_this setVariable ['items_mags', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_RP_Items_Attach";
            };
            
            // ========================================
            // UNLOCKABLE ITEMS - EQUIPMENT
            // ========================================
            class ItemsUniform {
                displayName = "ITEMS - Uniforms";
                tooltip = "Unlockable uniforms. Format: classname, Display Name, cost (one per line)";
                control = "EditCodeMulti5";
                property = "Recondo_RP_ItemsUniform";
                expression = "_this setVariable ['items_uniform', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_RP_Items_Equipment";
            };
            class ItemsVest {
                displayName = "Vests";
                tooltip = "Unlockable vests. Format: classname, Display Name, cost (one per line)";
                control = "EditCodeMulti5";
                property = "Recondo_RP_ItemsVest";
                expression = "_this setVariable ['items_vest', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_RP_Items_Equipment";
            };
            class ItemsBackpack {
                displayName = "Backpacks";
                tooltip = "Unlockable backpacks. Format: classname, Display Name, cost (one per line)";
                control = "EditCodeMulti5";
                property = "Recondo_RP_ItemsBackpack";
                expression = "_this setVariable ['items_backpack', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_RP_Items_Equipment";
            };
            class ItemsHeadgear {
                displayName = "Headgear";
                tooltip = "Unlockable headgear (helmets, hats). Format: classname, Display Name, cost (one per line)";
                control = "EditCodeMulti5";
                property = "Recondo_RP_ItemsHeadgear";
                expression = "_this setVariable ['items_headgear', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_RP_Items_Equipment";
            };
            class ItemsGoggles {
                displayName = "Facewear";
                tooltip = "Unlockable facewear (goggles, masks). Format: classname, Display Name, cost (one per line)";
                control = "EditCodeMulti5";
                property = "Recondo_RP_ItemsGoggles";
                expression = "_this setVariable ['items_goggles', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_RP_Items_Equipment";
            };
            
            // ========================================
            // UNLOCKABLE ITEMS - MISC
            // ========================================
            class ItemsItems {
                displayName = "ITEMS - Misc Items";
                tooltip = "Unlockable misc items (NVG, maps, radios, medkits, etc.). Format: classname, Display Name, cost (one per line)";
                control = "EditCodeMulti5";
                property = "Recondo_RP_ItemsItems";
                expression = "_this setVariable ['items_items', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_RP_Items_Misc";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    //==========================================
    // SENSORS MODULE
    // Deployable reconnaissance sensors for monitoring enemy movement
    //==========================================
    class Recondo_Module_Sensors: Module_F {
        scope = 2;
        displayName = "Sensors";
        icon = "\a3\ui_f\data\igui\cfg\simpletasks\types\listen_ca.paa";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleSensors";
        functionPriority = 5;
        isGlobal = 1;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorInfoType = "";
        
        class ModuleDescription {
            description = "Enables deployable reconnaissance sensors that detect and log enemy movement. Players can place foot traffic and vehicle sensors that persist across sessions. Data can be retrieved and turned in at Intel objects.";
            sync[] = {"Recondo_Module_Intel"};
        };
        
        class Attributes: AttributesBase {
            // ========================================
            // ATTRIBUTE CATEGORIES
            // ========================================
            class Recondo_Sensors_General {
                displayName = "General";
                collapsed = 0;
            };
            class Recondo_Sensors_FootSensor {
                displayName = "Foot Traffic Sensor";
                collapsed = 1;
            };
            class Recondo_Sensors_VehicleSensor {
                displayName = "Vehicle Sensor";
                collapsed = 1;
            };
            class Recondo_Sensors_Detection {
                displayName = "Detection Settings";
                collapsed = 1;
            };
            class Recondo_Sensors_Notification {
                displayName = "Notification Settings";
                collapsed = 1;
            };
            class Recondo_Sensors_Debug {
                displayName = "Debug";
                collapsed = 1;
            };
            
            // ========================================
            // GENERAL SETTINGS
            // ========================================
            class ObjectiveName {
                displayName = "Intel Board Category Name";
                tooltip = "Name for the sensor data category on the Intel Board.";
                control = "Edit";
                property = "Recondo_Sensors_ObjectiveName";
                expression = "_this setVariable ['objectivename', _value, true];";
                typeName = "STRING";
                defaultValue = """Sensor Network""";
                category = "Recondo_Sensors_General";
            };
            
            // ========================================
            // FOOT TRAFFIC SENSOR
            // ========================================
            class EnableFootSensor {
                displayName = "Enable Foot Sensor";
                tooltip = "Enable the foot traffic sensor system.";
                control = "Checkbox";
                property = "Recondo_Sensors_EnableFootSensor";
                expression = "_this setVariable ['enablefootsensor', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_Sensors_FootSensor";
            };
            class FootInventoryItem {
                displayName = "Inventory Item Classname";
                tooltip = "Classname of the inventory item players carry to deploy foot sensors.";
                control = "Edit";
                property = "Recondo_Sensors_FootInventoryItem";
                expression = "_this setVariable ['footinventoryitem', _value, true];";
                typeName = "STRING";
                defaultValue = """colsog_inv_sensor""";
                category = "Recondo_Sensors_FootSensor";
            };
            class FootWorldObject {
                displayName = "World Object Classname";
                tooltip = "Classname of the world object spawned when a foot sensor is placed.";
                control = "Edit";
                property = "Recondo_Sensors_FootWorldObject";
                expression = "_this setVariable ['footworldobject', _value, true];";
                typeName = "STRING";
                defaultValue = """colsog_thing_sensor""";
                category = "Recondo_Sensors_FootSensor";
            };
            class FootDetectionRadius {
                displayName = "Detection Radius (m)";
                tooltip = "Radius in meters for foot sensor detection.";
                control = "Edit";
                property = "Recondo_Sensors_FootDetectionRadius";
                expression = "_this setVariable ['footdetectionradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """50""";
                category = "Recondo_Sensors_FootSensor";
            };
            class FootMaxSensors {
                displayName = "Max Sensors Per Side";
                tooltip = "Maximum number of foot sensors that can be deployed by the notification side.";
                control = "Edit";
                property = "Recondo_Sensors_FootMaxSensors";
                expression = "_this setVariable ['footmaxsensors', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """5""";
                category = "Recondo_Sensors_FootSensor";
            };
            
            // ========================================
            // VEHICLE SENSOR
            // ========================================
            class EnableVehicleSensor {
                displayName = "Enable Vehicle Sensor";
                tooltip = "Enable the vehicle sensor system.";
                control = "Checkbox";
                property = "Recondo_Sensors_EnableVehicleSensor";
                expression = "_this setVariable ['enablevehiclesensor', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_Sensors_VehicleSensor";
            };
            class VehicleInventoryItem {
                displayName = "Inventory Item Classname";
                tooltip = "Classname of the inventory item players carry to deploy vehicle sensors.";
                control = "Edit";
                property = "Recondo_Sensors_VehicleInventoryItem";
                expression = "_this setVariable ['vehicleinventoryitem', _value, true];";
                typeName = "STRING";
                defaultValue = """colsog_inv_handsid_sensor""";
                category = "Recondo_Sensors_VehicleSensor";
            };
            class VehicleWorldObject {
                displayName = "World Object Classname";
                tooltip = "Classname of the world object spawned when a vehicle sensor is placed.";
                control = "Edit";
                property = "Recondo_Sensors_VehicleWorldObject";
                expression = "_this setVariable ['vehicleworldobject', _value, true];";
                typeName = "STRING";
                defaultValue = """colsog_thing_handsid_sensor""";
                category = "Recondo_Sensors_VehicleSensor";
            };
            class VehicleDetectionRadius {
                displayName = "Detection Radius (m)";
                tooltip = "Radius in meters for vehicle sensor detection.";
                control = "Edit";
                property = "Recondo_Sensors_VehicleDetectionRadius";
                expression = "_this setVariable ['vehicledetectionradius', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """100""";
                category = "Recondo_Sensors_VehicleSensor";
            };
            class VehicleMaxSensors {
                displayName = "Max Sensors Per Side";
                tooltip = "Maximum number of vehicle sensors that can be deployed by the notification side.";
                control = "Edit";
                property = "Recondo_Sensors_VehicleMaxSensors";
                expression = "_this setVariable ['vehiclemaxsensors', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """5""";
                category = "Recondo_Sensors_VehicleSensor";
            };
            
            // ========================================
            // DETECTION SETTINGS
            // ========================================
            class DetectionSide {
                displayName = "Detection Side";
                tooltip = "Which side's units should be detected by sensors.";
                control = "Combo";
                property = "Recondo_Sensors_DetectionSide";
                expression = "_this setVariable ['detectionside', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0";
                category = "Recondo_Sensors_Detection";
                class Values {
                    class East { name = "OPFOR (East)"; value = 0; };
                    class West { name = "BLUFOR (West)"; value = 1; };
                    class Guer { name = "Independent"; value = 2; };
                };
            };
            class DetectionInterval {
                displayName = "Detection Interval (sec)";
                tooltip = "How often sensors check for nearby units (in seconds).";
                control = "Edit";
                property = "Recondo_Sensors_DetectionInterval";
                expression = "_this setVariable ['detectioninterval', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """5""";
                category = "Recondo_Sensors_Detection";
            };
            class LogFrequency {
                displayName = "Log Frequency (sec)";
                tooltip = "Minimum time between log entries on a sensor (prevents spam).";
                control = "Edit";
                property = "Recondo_Sensors_LogFrequency";
                expression = "_this setVariable ['logfrequency', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """30""";
                category = "Recondo_Sensors_Detection";
            };
            
            // ========================================
            // NOTIFICATION SETTINGS
            // ========================================
            class NotificationSide {
                displayName = "Notification Side";
                tooltip = "Which side receives sensor alerts.";
                control = "Combo";
                property = "Recondo_Sensors_NotificationSide";
                expression = "_this setVariable ['notificationside', _value, true];";
                typeName = "NUMBER";
                defaultValue = "1";
                category = "Recondo_Sensors_Notification";
                class Values {
                    class East { name = "OPFOR (East)"; value = 0; };
                    class West { name = "BLUFOR (West)"; value = 1; };
                    class Guer { name = "Independent"; value = 2; };
                };
            };
            class NotificationClassnames {
                displayName = "Notification Unit Classnames";
                tooltip = "Unit classnames that receive Intel Card alerts when sensors detect activity.\nComma-separated or one per line. Leave empty to notify all players of the notification side.";
                control = "EditCodeMulti5";
                property = "Recondo_Sensors_NotificationClassnames";
                expression = "_this setVariable ['notificationclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_Sensors_Notification";
            };
            class NotificationFrequency {
                displayName = "Notification Frequency (sec)";
                tooltip = "Minimum time between Intel Card alerts (prevents spam).";
                control = "Edit";
                property = "Recondo_Sensors_NotificationFrequency";
                expression = "_this setVariable ['notificationfrequency', parseNumber _value, true];";
                typeName = "STRING";
                defaultValue = """30""";
                category = "Recondo_Sensors_Notification";
            };
            
            // ========================================
            // DEBUG SETTINGS
            // ========================================
            class DebugLogging {
                displayName = "Debug Logging";
                tooltip = "Enable debug logging to RPT file.";
                control = "Checkbox";
                property = "Recondo_Sensors_DebugLogging";
                expression = "_this setVariable ['debuglogging', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_Sensors_Debug";
            };
            class DebugMarkers {
                displayName = "Debug Markers";
                tooltip = "Show debug markers for sensor detection ranges.";
                control = "Checkbox";
                property = "Recondo_Sensors_DebugMarkers";
                expression = "_this setVariable ['debugmarkers', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_Sensors_Debug";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    //==========================================
    // STATIC WEAPON LIMIT MODULE
    //==========================================
    class Recondo_Module_StaticWeaponLimit: Module_F {
        scope = 2;
        displayName = "Limit Static Weapon Movement";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleStaticWeaponLimit";
        functionPriority = 1;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 0;
        icon = "\a3\ui_f\data\igui\cfg\simpletasks\types\default_ca.paa";
        
        class ModuleDescription: ModuleDescription {
            description = "Disables ACE carry on specified static weapons while keeping drag enabled. Works with ACE CSW assembled weapons.";
            sync[] = {};
        };
        
        class Attributes: AttributesBase {
            
            class WeaponClassnames {
                displayName = "Weapon Classnames";
                tooltip = "Comma-separated list of static weapon classnames to restrict.\nCarry will be disabled, drag will remain enabled.\n\nExamples:\n- StaticWeapon (all static weapons)\n- B_HMG_01_high_F, O_HMG_01_high_F (specific weapons)";
                control = "EditMulti5";
                property = "Recondo_StaticWeaponLimit_Classnames";
                expression = "_this setVariable ['weaponclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
            };
            
            class DebugLogging {
                displayName = "Debug Logging";
                tooltip = "Enable debug logging to RPT file.";
                control = "Checkbox";
                property = "Recondo_StaticWeaponLimit_DebugLogging";
                expression = "_this setVariable ['debuglogging', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    //==========================================
    // CUSTOM SITE SPAWN MODULE
    //==========================================
    class Recondo_Module_CustomSiteSpawn: Module_F {
        scope = 2;
        displayName = "Custom Site Spawn";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleCustomSiteSpawn";
        functionPriority = 1;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 1;
        icon = "\a3\ui_f\data\igui\cfg\simpletasks\types\default_ca.paa";
        
        class ModuleDescription: ModuleDescription {
            description = "Spawns custom compositions from mission folder at map markers with optional garrison AI, patrols, and persistence.";
            sync[] = {};
        };
        
        class Attributes: AttributesBase {
            
            // ========================================
            // GENERAL SETTINGS
            // ========================================
            class SiteName {
                displayName = "Site Name";
                tooltip = "Descriptive name for this site type (used in logging and persistence keys).";
                control = "Edit";
                property = "Recondo_CSS_SiteName";
                expression = "_this setVariable ['sitename', _value, true];";
                typeName = "STRING";
                defaultValue = """Custom Site""";
                category = "Recondo_CSS_General";
            };
            class MarkerPrefix {
                displayName = "Marker Prefix";
                tooltip = "Prefix for invisible map markers where sites can spawn. All markers starting with this prefix will be detected.";
                control = "Edit";
                property = "Recondo_CSS_MarkerPrefix";
                expression = "_this setVariable ['markerprefix', _value, true];";
                typeName = "STRING";
                defaultValue = """SITE_""";
                category = "Recondo_CSS_General";
            };
            class ActiveCount {
                displayName = "Active Site Count";
                tooltip = "Number of markers to randomly select as active sites. If more than available markers, all markers will be used.";
                control = "Edit";
                property = "Recondo_CSS_ActiveCount";
                expression = "_this setVariable ['activecount', _value, true];";
                typeName = "NUMBER";
                defaultValue = "3";
                category = "Recondo_CSS_General";
            };
            class EnablePersistence {
                displayName = "Enable Persistence";
                tooltip = "When enabled, selected markers are saved and reused across mission restarts. When disabled, markers are randomly re-selected each time.";
                control = "Checkbox";
                property = "Recondo_CSS_EnablePersistence";
                expression = "_this setVariable ['enablepersistence', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_CSS_General";
            };
            
            // ========================================
            // COMPOSITION SETTINGS
            // ========================================
            class CompositionPath {
                displayName = "Composition Folder Path";
                tooltip = "Path to compositions folder relative to mission root.";
                control = "Edit";
                property = "Recondo_CSS_CompositionPath";
                expression = "_this setVariable ['compositionpath', _value, true];";
                typeName = "STRING";
                defaultValue = """compositions""";
                category = "Recondo_CSS_Compositions";
            };
            class CompositionList {
                displayName = "Composition Files";
                tooltip = "List of composition filenames (with or without .sqe extension). One per line or comma-separated. A random composition is selected per site.";
                control = "EditCodeMulti5";
                property = "Recondo_CSS_CompositionList";
                expression = "_this setVariable ['compositionlist', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_CSS_Compositions";
            };
            class ClearRadius {
                displayName = "Terrain Clear Radius";
                tooltip = "Radius (meters) around each marker to hide terrain objects before spawning the composition. Set to 0 to skip terrain clearing.";
                control = "Edit";
                property = "Recondo_CSS_ClearRadius";
                expression = "_this setVariable ['clearradius', _value, true];";
                typeName = "NUMBER";
                defaultValue = "25";
                category = "Recondo_CSS_Compositions";
            };
            class DisableSimulation {
                displayName = "Disable Simulation on Objects";
                tooltip = "Disables physics simulation on spawned composition objects for better performance. Recommended for static decorative objects.";
                control = "Checkbox";
                property = "Recondo_CSS_DisableSimulation";
                expression = "_this setVariable ['disablesimulation', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_CSS_Compositions";
            };
            
            // ========================================
            // SPAWNING SETTINGS
            // ========================================
            class SpawnMode {
                displayName = "Spawn Mode";
                tooltip = "Immediate: spawns all sites on mission start. Proximity: spawns when the defined side enters the trigger radius.";
                control = "Combo";
                property = "Recondo_CSS_SpawnMode";
                expression = "_this setVariable ['spawnmode', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0";
                class values {
                    class Immediate {
                        name = "Immediate (Mission Start)";
                        value = 0;
                    };
                    class Proximity {
                        name = "Proximity Trigger";
                        value = 1;
                    };
                };
                category = "Recondo_CSS_Spawning";
            };
            class TriggerRadius {
                displayName = "Trigger Radius (meters)";
                tooltip = "Distance at which the composition spawns when using Proximity mode.";
                control = "Edit";
                property = "Recondo_CSS_TriggerRadius";
                expression = "_this setVariable ['triggerradius', _value, true];";
                typeName = "NUMBER";
                defaultValue = "800";
                category = "Recondo_CSS_Spawning";
            };
            class TriggerSide {
                displayName = "Trigger Side";
                tooltip = "Which side activates the proximity trigger.";
                control = "Combo";
                property = "Recondo_CSS_TriggerSide";
                expression = "_this setVariable ['triggerside', _value, true];";
                typeName = "NUMBER";
                defaultValue = "1";
                class values {
                    class East {
                        name = "EAST (OPFOR)";
                        value = 0;
                    };
                    class West {
                        name = "WEST (BLUFOR)";
                        value = 1;
                    };
                    class Guer {
                        name = "GUER (Independent)";
                        value = 2;
                    };
                    class Any {
                        name = "ANY";
                        value = 3;
                    };
                };
                category = "Recondo_CSS_Spawning";
            };
            
            // ========================================
            // GARRISON AI
            // ========================================
            class GarrisonClassnames {
                displayName = "Garrison Unit Classnames";
                tooltip = "Comma-separated list of unit classnames for garrison AI. Leave empty for no garrison.";
                control = "EditCodeMulti5";
                property = "Recondo_CSS_GarrisonClassnames";
                expression = "_this setVariable ['garrisonclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_CSS_Garrison";
            };
            class GarrisonCount {
                displayName = "Garrison Count";
                tooltip = "Number of garrison units to spawn at each site.";
                control = "Edit";
                property = "Recondo_CSS_GarrisonCount";
                expression = "_this setVariable ['garrisoncount', _value, true];";
                typeName = "NUMBER";
                defaultValue = "4";
                category = "Recondo_CSS_Garrison";
            };
            class GarrisonSide {
                displayName = "Garrison Side";
                tooltip = "Side of spawned garrison units.";
                control = "Combo";
                property = "Recondo_CSS_GarrisonSide";
                expression = "_this setVariable ['garrisonside', _value, true];";
                typeName = "NUMBER";
                defaultValue = "0";
                class values {
                    class East {
                        name = "EAST (OPFOR)";
                        value = 0;
                    };
                    class West {
                        name = "WEST (BLUFOR)";
                        value = 1;
                    };
                    class Guer {
                        name = "GUER (Independent)";
                        value = 2;
                    };
                };
                category = "Recondo_CSS_Garrison";
            };
            
            // ========================================
            // PATROL AI
            // ========================================
            class EnablePatrols {
                displayName = "Enable Patrols";
                tooltip = "Spawn patrol groups that roam around the site.";
                control = "Checkbox";
                property = "Recondo_CSS_EnablePatrols";
                expression = "_this setVariable ['enablepatrols', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_CSS_Patrols";
            };
            class PatrolClassnames {
                displayName = "Patrol Unit Classnames";
                tooltip = "Comma-separated list of unit classnames for patrol groups. If empty, uses garrison classnames.";
                control = "EditCodeMulti5";
                property = "Recondo_CSS_PatrolClassnames";
                expression = "_this setVariable ['patrolclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_CSS_Patrols";
            };
            class PatrolCount {
                displayName = "Number of Patrol Groups";
                tooltip = "Number of patrol groups to spawn per site.";
                control = "Edit";
                property = "Recondo_CSS_PatrolCount";
                expression = "_this setVariable ['patrolcount', _value, true];";
                typeName = "NUMBER";
                defaultValue = "1";
                category = "Recondo_CSS_Patrols";
            };
            class PatrolSize {
                displayName = "Patrol Group Size";
                tooltip = "Number of units per patrol group.";
                control = "Edit";
                property = "Recondo_CSS_PatrolSize";
                expression = "_this setVariable ['patrolsize', _value, true];";
                typeName = "NUMBER";
                defaultValue = "3";
                category = "Recondo_CSS_Patrols";
            };
            class PatrolRadius {
                displayName = "Patrol Radius (meters)";
                tooltip = "Distance from site center that patrols will roam.";
                control = "Edit";
                property = "Recondo_CSS_PatrolRadius";
                expression = "_this setVariable ['patrolradius', _value, true];";
                typeName = "NUMBER";
                defaultValue = "75";
                category = "Recondo_CSS_Patrols";
            };
            class PatrolFormation {
                displayName = "Patrol Formation";
                tooltip = "Formation used by patrol groups.";
                control = "Combo";
                property = "Recondo_CSS_PatrolFormation";
                expression = "_this setVariable ['patrolformation', _value, true];";
                typeName = "STRING";
                defaultValue = """WEDGE""";
                class values {
                    class Wedge { name = "WEDGE"; value = "WEDGE"; };
                    class Column { name = "COLUMN"; value = "COLUMN"; };
                    class StagColumn { name = "STAG COLUMN"; value = "STAG COLUMN"; };
                    class Line { name = "LINE"; value = "LINE"; };
                    class File { name = "FILE"; value = "FILE"; };
                    class Vee { name = "VEE"; value = "VEE"; };
                };
                category = "Recondo_CSS_Patrols";
            };
            
            // ========================================
            // NIGHT LIGHTS
            // ========================================
            class EnableNightLights {
                displayName = "Enable Night Lights";
                tooltip = "Automatically light buildings in spawned compositions at night.";
                control = "Checkbox";
                property = "Recondo_CSS_EnableNightLights";
                expression = "_this setVariable ['enablenightlights', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_CSS_NightLights";
            };
            
            // ========================================
            // DEBUG
            // ========================================
            class DebugLogging {
                displayName = "Debug Logging";
                tooltip = "Enable detailed logging to RPT file for troubleshooting.";
                control = "Checkbox";
                property = "Recondo_CSS_DebugLogging";
                expression = "_this setVariable ['debuglogging', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_CSS_Debug";
            };
            class DebugMarkers {
                displayName = "Debug Map Markers";
                tooltip = "Show debug markers on the map for all sites.";
                control = "Checkbox";
                property = "Recondo_CSS_DebugMarkers";
                expression = "_this setVariable ['debugmarkers', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_CSS_Debug";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    //==========================================
    // BAD CIVI MODULE
    //==========================================
    class Recondo_Module_BadCivi: Module_F {
        scope = 2;
        displayName = "Bad Civi";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleBadCivi";
        functionPriority = 5;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 1;
        icon = "\a3\ui_f\data\igui\cfg\simpletasks\types\kill_ca.paa";
        
        class ModuleDescription: ModuleDescription {
            description = "Sync to one or more AI units. Strips their weapons so they appear unarmed. When the configured side enters detection range, each unit independently rolls a chance to pull a concealed weapon and switch to combat. Supports multiple modules.";
            sync[] = {};
        };
        
        class Attributes: AttributesBase {
            
            // ========================================
            // GENERAL SETTINGS
            // ========================================
            class TriggerSide {
                displayName = "Trigger Side";
                tooltip = "Which side's presence triggers the weapon pull.";
                control = "Combo";
                property = "Recondo_BC_TriggerSide";
                expression = "_this setVariable ['triggerside', _value, true];";
                typeName = "STRING";
                defaultValue = """WEST""";
                class values {
                    class West {
                        name = "WEST (BLUFOR)";
                        value = "WEST";
                    };
                    class East {
                        name = "EAST (OPFOR)";
                        value = "EAST";
                    };
                    class Guer {
                        name = "GUER (Independent)";
                        value = "GUER";
                    };
                    class Any {
                        name = "ANY";
                        value = "ANY";
                    };
                };
                category = "Recondo_BC_General";
            };
            class DetectionDistance {
                displayName = "Detection Distance (meters)";
                tooltip = "How close the trigger side must be before the unit may pull a weapon.";
                control = "Edit";
                property = "Recondo_BC_DetectionDistance";
                expression = "_this setVariable ['detectiondistance', _value, true];";
                typeName = "NUMBER";
                defaultValue = "5";
                category = "Recondo_BC_General";
            };
            class Chance {
                displayName = "Chance (%)";
                tooltip = "Percent chance (0-100) each unit pulls a weapon when triggered. If the roll fails, it will try again the next time the side enters the radius.";
                control = "Edit";
                property = "Recondo_BC_Chance";
                expression = "_this setVariable ['chance', _value, true];";
                typeName = "NUMBER";
                defaultValue = "50";
                category = "Recondo_BC_General";
            };
            
            // ========================================
            // WEAPON SETTINGS
            // ========================================
            class WeaponClassname {
                displayName = "Weapon Classname";
                tooltip = "Classname of the weapon the unit pulls out.";
                control = "Edit";
                property = "Recondo_BC_WeaponClassname";
                expression = "_this setVariable ['weaponclassname', _value, true];";
                typeName = "STRING";
                defaultValue = """hgun_Pistol_01_F""";
                category = "Recondo_BC_Weapon";
            };
            class MagazineClassname {
                displayName = "Magazine Classname";
                tooltip = "Classname of the compatible magazine for the weapon.";
                control = "Edit";
                property = "Recondo_BC_MagazineClassname";
                expression = "_this setVariable ['magazineclassname', _value, true];";
                typeName = "STRING";
                defaultValue = """10Rnd_9x21_Mag""";
                category = "Recondo_BC_Weapon";
            };
            class MagazineCount {
                displayName = "Magazine Count";
                tooltip = "Number of magazines to add when the weapon is given.";
                control = "Edit";
                property = "Recondo_BC_MagazineCount";
                expression = "_this setVariable ['magazinecount', _value, true];";
                typeName = "NUMBER";
                defaultValue = "1";
                category = "Recondo_BC_Weapon";
            };
            
            // ========================================
            // BEHAVIOR SETTINGS
            // ========================================
            class DisableMovement {
                displayName = "Disable Movement";
                tooltip = "Disables the unit's movement AI at init so they stay in place until triggered. Movement is re-enabled when they pull a weapon.";
                control = "Checkbox";
                property = "Recondo_BC_DisableMovement";
                expression = "_this setVariable ['disablemovement', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_BC_Behavior";
            };
            class ForceStanding {
                displayName = "Force Standing";
                tooltip = "Forces the unit to stand upright at init.";
                control = "Checkbox";
                property = "Recondo_BC_ForceStanding";
                expression = "_this setVariable ['forcestanding', _value, true];";
                typeName = "BOOL";
                defaultValue = "true";
                category = "Recondo_BC_Behavior";
            };
            
            // ========================================
            // DEBUG
            // ========================================
            class DebugLogging {
                displayName = "Debug Logging";
                tooltip = "Enable detailed logging to RPT file for troubleshooting.";
                control = "Checkbox";
                property = "Recondo_BC_DebugLogging";
                expression = "_this setVariable ['debuglogging', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_BC_Debug";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
    
    //==========================================
    // DESTROY POWERGRID MODULE
    //==========================================
    class Recondo_Module_DestroyPowergrid: Module_F {
        scope = 2;
        displayName = "Destroy Powergrid";
        author = "GoonSix";
        vehicleClass = "Modules";
        category = "Recondo_Modules";
        function = "Recondo_fnc_moduleDestroyPowergrid";
        functionPriority = 5;
        isGlobal = 0;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;
        curatorCanAttach = 1;
        icon = "\a3\ui_f\data\igui\cfg\simpletasks\types\destroy_ca.paa";
        
        class ModuleDescription: ModuleDescription {
            description = "Turns off or destroys lights within a radius by interacting with or destroying a synced object. Sync to a world object in Eden. Supports multiple instances for different locations.";
            sync[] = {};
        };
        
        class Attributes: AttributesBase {
            
            // ========================================
            // GENERAL SETTINGS
            // ========================================
            class Mode {
                displayName = "Mode";
                tooltip = "Turn Off Power: adds an ACE interaction to toggle power on/off (reversible, objects intact). Destroy Object: destroying the synced object permanently kills power (lamps physically damaged).";
                control = "Combo";
                property = "Recondo_PG_Mode";
                expression = "_this setVariable ['mode', _value, true];";
                typeName = "STRING";
                defaultValue = """turnoff""";
                class values {
                    class TurnOff {
                        name = "Turn Off Power (ACE Action)";
                        value = "turnoff";
                    };
                    class Destroy {
                        name = "Destroy Object";
                        value = "destroy";
                    };
                    class Both {
                        name = "Both (ACE Action + Destroy)";
                        value = "both";
                    };
                };
                category = "Recondo_PG_General";
            };
            class EffectRadius {
                displayName = "Effect Radius (meters)";
                tooltip = "Radius around the synced object in which lights will be turned off or destroyed. All objects with light sources within this radius are affected.";
                control = "Edit";
                property = "Recondo_PG_EffectRadius";
                expression = "_this setVariable ['effectradius', _value, true];";
                typeName = "NUMBER";
                defaultValue = "300";
                category = "Recondo_PG_General";
            };
            class AdditionalClassnames {
                displayName = "Additional Object Classnames";
                tooltip = "Extra object classnames to target beyond the built-in lamp and powerline classes (Lamps_Base_F, PowerLines_base_F, Land_PowerPoleWooden_L_F). One per line or comma-separated. Only relevant for Destroy mode physical damage — switchLight is applied to ALL objects regardless.";
                control = "EditCodeMulti5";
                property = "Recondo_PG_AdditionalClassnames";
                expression = "_this setVariable ['additionalclassnames', _value, true];";
                typeName = "STRING";
                defaultValue = """""";
                category = "Recondo_PG_General";
            };
            
            // ========================================
            // TURN OFF MODE SETTINGS
            // ========================================
            class ActionText {
                displayName = "ACE Action Text — Turn Off";
                tooltip = "Display text for the ACE interaction to turn off power. Only used in Turn Off Power mode.";
                control = "Edit";
                property = "Recondo_PG_ActionText";
                expression = "_this setVariable ['actiontext', _value, true];";
                typeName = "STRING";
                defaultValue = """Turn Off Power""";
                category = "Recondo_PG_TurnOff";
            };
            class RestoreActionText {
                displayName = "ACE Action Text — Turn On";
                tooltip = "Display text for the ACE interaction to restore power. Only used in Turn Off Power mode.";
                control = "Edit";
                property = "Recondo_PG_RestoreActionText";
                expression = "_this setVariable ['restoreactiontext', _value, true];";
                typeName = "STRING";
                defaultValue = """Turn On Power""";
                category = "Recondo_PG_TurnOff";
            };
            
            // ========================================
            // DESTROY MODE SETTINGS
            // ========================================
            class EnablePersistence {
                displayName = "Enable Persistence";
                tooltip = "When enabled, the destroyed state is saved and restored on mission restart. Only used in Destroy Object mode.";
                control = "Checkbox";
                property = "Recondo_PG_EnablePersistence";
                expression = "_this setVariable ['enablepersistence', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_PG_Destroy";
            };
            
            // ========================================
            // DEBUG
            // ========================================
            class DebugLogging {
                displayName = "Debug Logging";
                tooltip = "Enable detailed logging to RPT file for troubleshooting.";
                control = "Checkbox";
                property = "Recondo_PG_DebugLogging";
                expression = "_this setVariable ['debuglogging', _value, true];";
                typeName = "BOOL";
                defaultValue = "false";
                category = "Recondo_PG_Debug";
            };
            
            class ModuleDescription: ModuleDescription {};
        };
    };
};
