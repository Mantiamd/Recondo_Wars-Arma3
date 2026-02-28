class Cfg3DEN {
    class Object {
        class AttributeCategories {
            
            //==========================================
            // AI TWEAKS MODULE CATEGORIES
            //==========================================
            
            // General Settings
            class Recondo_AITweaks_General {
                displayName = "General Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Base Soldiers - affects all units except Elite and AA
            class Recondo_AITweaks_Base {
                displayName = "Base Soldiers (Default)";
                collapsed = 0;
                class Attributes {};
            };
            class Recondo_AITweaks_Base_Skills {
                displayName = "Base - Skills";
                collapsed = 1;
                class Attributes {};
            };
            class Recondo_AITweaks_Base_Behavior {
                displayName = "Base - Behavior";
                collapsed = 1;
                class Attributes {};
            };
            class Recondo_AITweaks_Base_AIFeatures {
                displayName = "Base - AI Features";
                collapsed = 1;
                class Attributes {};
            };
            class Recondo_AITweaks_Base_Equipment {
                displayName = "Base - Equipment";
                collapsed = 1;
                class Attributes {};
            };
            
            // Elite Soldiers - specified by classnames
            class Recondo_AITweaks_Elite {
                displayName = "Elite Soldiers";
                collapsed = 1;
                class Attributes {};
            };
            class Recondo_AITweaks_Elite_Skills {
                displayName = "Elite - Skills";
                collapsed = 1;
                class Attributes {};
            };
            class Recondo_AITweaks_Elite_Behavior {
                displayName = "Elite - Behavior";
                collapsed = 1;
                class Attributes {};
            };
            class Recondo_AITweaks_Elite_AIFeatures {
                displayName = "Elite - AI Features";
                collapsed = 1;
                class Attributes {};
            };
            class Recondo_AITweaks_Elite_Equipment {
                displayName = "Elite - Equipment";
                collapsed = 1;
                class Attributes {};
            };
            
            // AA Gunners - specified by classnames
            class Recondo_AITweaks_AA {
                displayName = "AA Gunners";
                collapsed = 1;
                class Attributes {};
            };
            class Recondo_AITweaks_AA_Skills {
                displayName = "AA - Skills";
                collapsed = 1;
                class Attributes {};
            };
            class Recondo_AITweaks_AA_Behavior {
                displayName = "AA - Behavior";
                collapsed = 1;
                class Attributes {};
            };
            class Recondo_AITweaks_AA_AIFeatures {
                displayName = "AA - AI Features";
                collapsed = 1;
                class Attributes {};
            };
            class Recondo_AITweaks_AA_Equipment {
                displayName = "AA - Equipment";
                collapsed = 1;
                class Attributes {};
            };
            
            // Mine Knowledge - global setting
            class Recondo_AITweaks_Mine {
                displayName = "Mine Knowledge";
                collapsed = 1;
                class Attributes {};
            };
            
            // Debug
            class Recondo_AITweaks_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
            
            //==========================================
            // PLAYER OPTIONS MODULE CATEGORIES
            //==========================================
            
            // Graphics Restrictions
            class Recondo_PlayerOptions_Graphics {
                displayName = "Graphics Restrictions";
                collapsed = 0;
                class Attributes {};
            };
            class Recondo_PlayerOptions_ViewDistance {
                displayName = "View Distance";
                collapsed = 1;
                class Attributes {};
            };
            
            // Player Traits
            class Recondo_PlayerOptions_Traits {
                displayName = "Player Traits";
                collapsed = 1;
                class Attributes {};
            };
            
            // Forced Faces
            class Recondo_PlayerOptions_Faces {
                displayName = "Forced Faces";
                collapsed = 1;
                class Attributes {};
            };
            
            // ACE Rations
            class Recondo_PlayerOptions_Rations {
                displayName = "ACE Rations";
                collapsed = 1;
                class Attributes {};
            };
            
            // Pilot Restrictions
            class Recondo_PlayerOptions_Pilots {
                displayName = "Pilot Restrictions";
                collapsed = 1;
                class Attributes {};
            };
            
            // Sounds
            class Recondo_PlayerOptions_Sounds {
                displayName = "Sound Settings";
                collapsed = 1;
                class Attributes {};
            };
            
            // Body Bags
            class Recondo_PlayerOptions_Bodybags {
                displayName = "Body Bags";
                collapsed = 1;
                class Attributes {};
            };
            
            // Debug
            class Recondo_PlayerOptions_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
            
            //==========================================
            // ACE ARSENAL AREA MODULE CATEGORIES
            //==========================================
            
            // Area Settings
            class Recondo_ArsenalArea_Area {
                displayName = "Area Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Arsenal Settings
            class Recondo_ArsenalArea_Arsenal {
                displayName = "Arsenal Reference";
                collapsed = 0;
                class Attributes {};
            };
            
            // Access Settings
            class Recondo_ArsenalArea_Access {
                displayName = "Access Control";
                collapsed = 0;
                class Attributes {};
            };
            
            // Cleanup Settings
            class Recondo_ArsenalArea_Cleanup {
                displayName = "Litter Cleanup";
                collapsed = 1;
                class Attributes {};
            };
            
            // Debug
            class Recondo_ArsenalArea_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
            
            //==========================================
            // DISABLE ACE RATIONS AREA MODULE CATEGORIES
            //==========================================
            
            // Area Settings
            class Recondo_DisableRationsArea_Area {
                displayName = "Area Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Debug
            class Recondo_DisableRationsArea_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
            
            //==========================================
            // JIP TO GROUP LEADER AREA MODULE CATEGORIES
            //==========================================
            
            // Area Settings
            class Recondo_JIPArea_Area {
                displayName = "Area Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Debug
            class Recondo_JIPArea_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
            
            //==========================================
            // ACE SPECTATOR OBJECT MODULE CATEGORIES
            //==========================================
            
            // Object Settings
            class Recondo_SpectatorObject_Object {
                displayName = "Object Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Camera Settings
            class Recondo_SpectatorObject_Camera {
                displayName = "Camera Modes";
                collapsed = 0;
                class Attributes {};
            };
            
            // Vision Settings
            class Recondo_SpectatorObject_Vision {
                displayName = "Vision Modes";
                collapsed = 1;
                class Attributes {};
            };
            
            // Restrictions
            class Recondo_SpectatorObject_Restrictions {
                displayName = "Restrictions";
                collapsed = 0;
                class Attributes {};
            };
            
            // Debug
            class Recondo_SpectatorObject_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
            
            //==========================================
            // PERSISTENCE MODULE CATEGORIES
            //==========================================
            
            // Campaign Settings
            class Recondo_Persistence_Campaign {
                displayName = "Campaign Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Auto-Save Settings
            class Recondo_Persistence_AutoSave {
                displayName = "Auto-Save Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Marker Settings
            class Recondo_Persistence_Markers {
                displayName = "Marker Persistence";
                collapsed = 0;
                class Attributes {};
            };
            
            // Player Stats Settings
            class Recondo_Persistence_PlayerStats {
                displayName = "Player Statistics";
                collapsed = 0;
                class Attributes {};
            };
            
            // Debug
            class Recondo_Persistence_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
            
            //==========================================
            // STATIC DEFENSE RANDOMIZED MODULE CATEGORIES
            //==========================================
            
            // General Settings
            class Recondo_SDR_General {
                displayName = "General Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Static Weapon Settings
            class Recondo_SDR_Static {
                displayName = "Static Weapons";
                collapsed = 0;
                class Attributes {};
            };
            
            // Unit Settings
            class Recondo_SDR_Units {
                displayName = "AI Units";
                collapsed = 0;
                class Attributes {};
            };
            
            // Terrain Settings
            class Recondo_SDR_Terrain {
                displayName = "Terrain Clearing";
                collapsed = 0;
                class Attributes {};
            };
            
            // Persistence Settings
            class Recondo_SDR_Persistence {
                displayName = "Persistence";
                collapsed = 1;
                class Attributes {};
            };
            
            // Debug
            class Recondo_SDR_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
            
            //==========================================
            // FOOT PATROLS MODULE CATEGORIES
            //==========================================
            
            // General Settings
            class Recondo_FP_General {
                displayName = "General Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Unit Settings
            class Recondo_FP_Units {
                displayName = "Units";
                collapsed = 0;
                class Attributes {};
            };
            
            // Patrol Behavior Settings
            class Recondo_FP_Patrol {
                displayName = "Patrol Behavior";
                collapsed = 0;
                class Attributes {};
            };
            
            // Trigger Settings
            class Recondo_FP_Trigger {
                displayName = "Trigger Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Performance Settings
            class Recondo_FP_Performance {
                displayName = "Performance";
                collapsed = 1;
                class Attributes {};
            };
            
            // Persistence Settings
            class Recondo_FP_Persistence {
                displayName = "Persistence";
                collapsed = 1;
                class Attributes {};
            };
            
            // Debug
            class Recondo_FP_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
            
            //==========================================
            // ADD AI CREW MODULE CATEGORIES
            //==========================================
            
            // General Settings
            class Recondo_AIC_General {
                displayName = "General Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Unit Settings
            class Recondo_AIC_Units {
                displayName = "Units";
                collapsed = 0;
                class Attributes {};
            };
            
            // Skill Settings
            class Recondo_AIC_Skills {
                displayName = "AI Skills";
                collapsed = 0;
                class Attributes {};
            };
            
            // Behavior Settings
            class Recondo_AIC_Behavior {
                displayName = "Behavior";
                collapsed = 0;
                class Attributes {};
            };
            
            // Conditions Settings
            class Recondo_AIC_Conditions {
                displayName = "Conditions";
                collapsed = 0;
                class Attributes {};
            };
            
            // Debug
            class Recondo_AIC_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
            
            //==========================================
            // STABO MODULE CATEGORIES
            //==========================================
            
            // Rope Settings
            class Recondo_STABO_Rope {
                displayName = "Rope Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Height Settings
            class Recondo_STABO_Height {
                displayName = "Height Limits";
                collapsed = 0;
                class Attributes {};
            };
            
            // Interaction Settings
            class Recondo_STABO_Interaction {
                displayName = "Interaction";
                collapsed = 0;
                class Attributes {};
            };
            
            // Ground Request Settings (AI Pilots)
            class Recondo_STABO_GroundRequest {
                displayName = "Ground Request (AI Pilots)";
                collapsed = 0;
                class Attributes {};
            };
            
            // Debug
            class Recondo_STABO_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
            
            //==========================================
            // PATH PATROLS MODULE CATEGORIES
            //==========================================
            
            // General Settings
            class Recondo_PP_General {
                displayName = "General Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Unit Settings
            class Recondo_PP_Units {
                displayName = "Units";
                collapsed = 0;
                class Attributes {};
            };
            
            // Trigger Settings
            class Recondo_PP_Trigger {
                displayName = "Trigger Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Performance Settings
            class Recondo_PP_Performance {
                displayName = "Performance";
                collapsed = 1;
                class Attributes {};
            };
            
            // Debug
            class Recondo_PP_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
            
            //==========================================
            // RW_RADIO MODULE CATEGORIES
            //==========================================
            
            // General Settings
            class Recondo_RWR_General {
                displayName = "General Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Battery Settings
            class Recondo_RWR_Battery {
                displayName = "Battery System";
                collapsed = 0;
                class Attributes {};
            };
            
            // Triangulation Settings
            class Recondo_RWR_Triangulation {
                displayName = "Triangulation";
                collapsed = 0;
                class Attributes {};
            };
            
            // Enemy Spawn Settings
            class Recondo_RWR_EnemySpawn {
                displayName = "Enemy Spawn";
                collapsed = 1;
                class Attributes {};
            };
            
            // Exemptions
            class Recondo_RWR_Exemptions {
                displayName = "Exemptions";
                collapsed = 1;
                class Attributes {};
            };
            
            // Debug
            class Recondo_RWR_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
            
            //==========================================
            // TRACKERS MODULE CATEGORIES
            //==========================================
            
            // General Settings
            class Recondo_Trackers_General {
                displayName = "General Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Marker Settings
            class Recondo_Trackers_Markers {
                displayName = "Marker Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Footprint Settings
            class Recondo_Trackers_Footprints {
                displayName = "Footprint Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Tracker Behavior Settings
            class Recondo_Trackers_Behavior {
                displayName = "Tracker Behavior";
                collapsed = 0;
                class Attributes {};
            };
            
            // Dog Settings
            class Recondo_Trackers_Dog {
                displayName = "Tracker Dogs";
                collapsed = 1;
                class Attributes {};
            };
            
            // Target Filter
            class Recondo_Trackers_TargetFilter {
                displayName = "Target Filter";
                collapsed = 1;
                class Attributes {};
            };
            
            // Debug
            class Recondo_Trackers_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
            
            //==========================================
            // REINFORCEMENT WAVES MODULE CATEGORIES
            //==========================================
            
            // General Settings
            class Recondo_RW_General {
                displayName = "General Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Detection Settings
            class Recondo_RW_Detection {
                displayName = "Detection Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Spawn Settings
            class Recondo_RW_Spawn {
                displayName = "Spawn Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Wave 1 Settings
            class Recondo_RW_Wave1 {
                displayName = "Wave 1 (Main + Flankers)";
                collapsed = 0;
                class Attributes {};
            };
            
            // Flanker Settings
            class Recondo_RW_Flankers {
                displayName = "Flanker Settings";
                collapsed = 1;
                class Attributes {};
            };
            
            // Dog Settings
            class Recondo_RW_Dogs {
                displayName = "Dog Settings";
                collapsed = 1;
                class Attributes {};
            };
            
            // Wave 2+ Settings
            class Recondo_RW_Pursuit {
                displayName = "Wave 2+ (Pursuit Groups)";
                collapsed = 1;
                class Attributes {};
            };
            
            // Target Filter
            class Recondo_RW_TargetFilter {
                displayName = "Target Filter";
                collapsed = 1;
                class Attributes {};
            };
            
            // Debug
            class Recondo_RW_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
            
            //==========================================
            // INTEL MODULE CATEGORIES
            //==========================================
            
            // General Settings
            class Recondo_Intel_General {
                displayName = "General Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Turn-In Settings
            class Recondo_Intel_TurnIn {
                displayName = "Turn-In Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Persistence Settings
            class Recondo_Intel_Persistence {
                displayName = "Persistence";
                collapsed = 1;
                class Attributes {};
            };
            
            // Debug
            class Recondo_Intel_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
            
            //==========================================
            // INTEL BOARD MODULE CATEGORIES
            //==========================================
            
            class Recondo_IntelBoard_General {
                displayName = "General Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            class Recondo_IntelBoard_Display {
                displayName = "Display Options";
                collapsed = 0;
                class Attributes {};
            };
            
            class Recondo_IntelBoard_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
            
            //==========================================
            // INTEL ITEMS MODULE CATEGORIES
            //==========================================
            
            // General Settings
            class Recondo_IntelItems_General {
                displayName = "General Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Unit Settings
            class Recondo_IntelItems_Units {
                displayName = "Unit Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Item Settings
            class Recondo_IntelItems_Items {
                displayName = "Intel Items";
                collapsed = 0;
                class Attributes {};
            };
            
            // Debug
            class Recondo_IntelItems_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
            
            // POW Settings
            class Recondo_IntelItems_POW {
                displayName = "POW Turn-In";
                collapsed = 1;
                class Attributes {};
            };
            
            //==========================================
            // WIRETAP MODULE CATEGORIES
            //==========================================
            
            // General Settings
            class Recondo_Wiretap_General {
                displayName = "General Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Timing Settings
            class Recondo_Wiretap_Timing {
                displayName = "Timing";
                collapsed = 0;
                class Attributes {};
            };
            
            // Items Settings
            class Recondo_Wiretap_Items {
                displayName = "Items";
                collapsed = 0;
                class Attributes {};
            };
            
            // Placement Settings
            class Recondo_Wiretap_Placement {
                displayName = "Placement";
                collapsed = 1;
                class Attributes {};
            };
            
            // Rope Visual Settings
            class Recondo_Wiretap_Rope {
                displayName = "Rope & Ground Item";
                collapsed = 1;
                class Attributes {};
            };
            
            // Text Settings
            class Recondo_Wiretap_Text {
                displayName = "UI Text";
                collapsed = 1;
                class Attributes {};
            };
            
            // Restrictions
            class Recondo_Wiretap_Restrictions {
                displayName = "Class Restrictions";
                collapsed = 1;
                class Attributes {};
            };
            
            // Debug
            class Recondo_Wiretap_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
            
            //==========================================
            // OBJECTIVE DESTROY MODULE CATEGORIES
            //==========================================
            
            // General Settings
            class Recondo_ObjDestroy_General {
                displayName = "General";
                collapsed = 0;
                class Attributes {};
            };
            
            // Composition Settings
            class Recondo_ObjDestroy_Composition {
                displayName = "Compositions";
                collapsed = 0;
                class Attributes {};
            };
            
            // Target Settings
            class Recondo_ObjDestroy_Target {
                displayName = "Target Object";
                collapsed = 0;
                class Attributes {};
            };
            
            // Spawning Settings
            class Recondo_ObjDestroy_Spawning {
                displayName = "Spawning";
                collapsed = 0;
                class Attributes {};
            };
            
            // AI Sentries Settings
            class Recondo_ObjDestroy_AISentries {
                displayName = "AI - Sentries";
                collapsed = 1;
                class Attributes {};
            };
            
            // AI Patrols Settings
            class Recondo_ObjDestroy_AIPatrols {
                displayName = "AI - Patrols";
                collapsed = 1;
                class Attributes {};
            };
            
            // Intel Settings
            class Recondo_ObjDestroy_Intel {
                displayName = "Intel Integration";
                collapsed = 1;
                class Attributes {};
            };
            
            // Debug
            class Recondo_ObjDestroy_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
            
            // Night Lights
            class Recondo_ObjDestroy_NightLights {
                displayName = "Night Lights";
                collapsed = 1;
                class Attributes {};
            };
            
            // Smell Hints
            class Recondo_ObjDestroy_SmellHints {
                displayName = "Smell Hints";
                collapsed = 1;
                class Attributes {};
            };
            
            //==========================================
            // TERMINAL MODULE CATEGORIES
            //==========================================
            
            // General Settings
            class Recondo_Terminal_General {
                displayName = "General";
                collapsed = 0;
                class Attributes {};
            };
            
            // Debug
            class Recondo_Terminal_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
            
            //==========================================
            // OBJECTIVE HUB & SUBS MODULE CATEGORIES
            //==========================================
            
            // General Settings
            class Recondo_HubSubs_General {
                displayName = "General";
                collapsed = 0;
                class Attributes {};
            };
            
            // Hub Composition
            class Recondo_HubSubs_HubComposition {
                displayName = "Hub Composition";
                collapsed = 0;
                class Attributes {};
            };
            
            // Hub Target
            class Recondo_HubSubs_HubTarget {
                displayName = "Hub Target";
                collapsed = 0;
                class Attributes {};
            };
            
            // Hub Spawning
            class Recondo_HubSubs_HubSpawning {
                displayName = "Hub Spawning";
                collapsed = 1;
                class Attributes {};
            };
            
            // Hub AI
            class Recondo_HubSubs_HubAI {
                displayName = "Hub AI";
                collapsed = 1;
                class Attributes {};
            };
            
            // Security Patrol
            class Recondo_HubSubs_SecurityPatrol {
                displayName = "Security Patrol";
                collapsed = 1;
                class Attributes {};
            };
            
            // Sub-Site Settings
            class Recondo_HubSubs_SubSites {
                displayName = "Sub-Sites";
                collapsed = 0;
                class Attributes {};
            };
            
            // Sub-Site AI
            class Recondo_HubSubs_SubSiteAI {
                displayName = "Sub-Site AI";
                collapsed = 1;
                class Attributes {};
            };
            
            // Intel Integration
            class Recondo_HubSubs_Intel {
                displayName = "Intel Integration";
                collapsed = 1;
                class Attributes {};
            };
            
            // Debug
            class Recondo_HubSubs_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
            
            // Smell Hints
            class Recondo_HubSubs_SmellHints {
                displayName = "Smell Hints";
                collapsed = 1;
                class Attributes {};
            };
            
            //==========================================
            // SIDE CHAT AND MARKER CONTROL MODULE CATEGORIES
            //==========================================
            
            // Text - OPFOR
            class Recondo_ChatControl_TextOPFOR {
                displayName = "Text - OPFOR";
                collapsed = 0;
                class Attributes {};
            };
            
            // Text - BLUFOR
            class Recondo_ChatControl_TextBLUFOR {
                displayName = "Text - BLUFOR";
                collapsed = 0;
                class Attributes {};
            };
            
            // Text - Independent
            class Recondo_ChatControl_TextIndependent {
                displayName = "Text - Independent";
                collapsed = 1;
                class Attributes {};
            };
            
            // Text - Civilian
            class Recondo_ChatControl_TextCivilian {
                displayName = "Text - Civilian";
                collapsed = 1;
                class Attributes {};
            };
            
            // Markers - OPFOR
            class Recondo_ChatControl_MarkersOPFOR {
                displayName = "Markers - OPFOR";
                collapsed = 1;
                class Attributes {};
            };
            
            // Markers - BLUFOR
            class Recondo_ChatControl_MarkersBLUFOR {
                displayName = "Markers - BLUFOR";
                collapsed = 1;
                class Attributes {};
            };
            
            // Markers - Independent
            class Recondo_ChatControl_MarkersIndependent {
                displayName = "Markers - Independent";
                collapsed = 1;
                class Attributes {};
            };
            
            // Markers - Civilian
            class Recondo_ChatControl_MarkersCivilian {
                displayName = "Markers - Civilian";
                collapsed = 1;
                class Attributes {};
            };
            
            // Voice Chat - OPFOR
            class Recondo_ChatControl_VoiceOPFOR {
                displayName = "Voice Chat - OPFOR";
                collapsed = 1;
                class Attributes {};
            };
            
            // Voice Chat - BLUFOR
            class Recondo_ChatControl_VoiceBLUFOR {
                displayName = "Voice Chat - BLUFOR";
                collapsed = 1;
                class Attributes {};
            };
            
            // Voice Chat - Independent
            class Recondo_ChatControl_VoiceIndependent {
                displayName = "Voice Chat - Independent";
                collapsed = 1;
                class Attributes {};
            };
            
            // Voice Chat - Civilian
            class Recondo_ChatControl_VoiceCivilian {
                displayName = "Voice Chat - Civilian";
                collapsed = 1;
                class Attributes {};
            };
            
            // Debug
            class Recondo_ChatControl_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
            
            //==========================================
            // CIVILIANS WORKING FIELDS MODULE CATEGORIES
            //==========================================
            
            // General Settings
            class Recondo_CivWorking_General {
                displayName = "General Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Trigger Settings
            class Recondo_CivWorking_Trigger {
                displayName = "Trigger Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Behavior Settings
            class Recondo_CivWorking_Behavior {
                displayName = "Behavior Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Performance Settings
            class Recondo_CivWorking_Performance {
                displayName = "Performance";
                collapsed = 1;
                class Attributes {};
            };
            
            // Debug Settings
            class Recondo_CivWorking_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
            
            //==========================================
            // CAMPS RANDOM MODULE CATEGORIES
            //==========================================
            
            // General Settings
            class Recondo_CampsRandom_General {
                displayName = "General";
                collapsed = 0;
                class Attributes {};
            };
            
            // Default Compositions (Mod-bundled)
            class Recondo_CampsRandom_DefaultComp {
                displayName = "Default Compositions";
                collapsed = 0;
                class Attributes {};
            };
            
            // Custom Compositions (Mission folder)
            class Recondo_CampsRandom_CustomComp {
                displayName = "Custom Compositions";
                collapsed = 1;
                class Attributes {};
            };
            
            // Spawning Settings
            class Recondo_CampsRandom_Spawning {
                displayName = "Spawning";
                collapsed = 0;
                class Attributes {};
            };
            
            // AI Settings
            class Recondo_CampsRandom_AI {
                displayName = "AI Sentries";
                collapsed = 0;
                class Attributes {};
            };
            
            // Intel Settings - Object
            class Recondo_CampsRandom_IntelObject {
                displayName = "Intel - Ground Object";
                collapsed = 0;
                class Attributes {};
            };
            
            // Intel Settings - Unit Inventory
            class Recondo_CampsRandom_IntelUnit {
                displayName = "Intel - Unit Inventory";
                collapsed = 1;
                class Attributes {};
            };
            
            // Intel Integration
            class Recondo_CampsRandom_Intel {
                displayName = "Intel System Integration";
                collapsed = 1;
                class Attributes {};
            };
            
            // Smell Hints
            class Recondo_CampsRandom_SmellHints {
                displayName = "Smell Hints";
                collapsed = 1;
                class Attributes {};
            };
            
            // Debug
            class Recondo_CampsRandom_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
            
            //==========================================
            // PLAYER LIMITATIONS MODULE CATEGORIES
            //==========================================
            
            // General Settings
            class Recondo_PlayerLimits_General {
                displayName = "General Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Item Limitation 1
            class Recondo_PlayerLimits_Limit1 {
                displayName = "Item Limit 1";
                collapsed = 0;
                class Attributes {};
            };
            
            // Item Limitation 2
            class Recondo_PlayerLimits_Limit2 {
                displayName = "Item Limit 2";
                collapsed = 1;
                class Attributes {};
            };
            
            // Item Limitation 3
            class Recondo_PlayerLimits_Limit3 {
                displayName = "Item Limit 3";
                collapsed = 1;
                class Attributes {};
            };
            
            // Item Limitation 4
            class Recondo_PlayerLimits_Limit4 {
                displayName = "Item Limit 4";
                collapsed = 1;
                class Attributes {};
            };
            
            // Item Limitation 5
            class Recondo_PlayerLimits_Limit5 {
                displayName = "Item Limit 5";
                collapsed = 1;
                class Attributes {};
            };
            
            // Debug
            class Recondo_PlayerLimits_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
            
            //==========================================
            // PLAYER INTEL DROPS MODULE CATEGORIES
            //==========================================
            
            // General Settings
            class Recondo_PlayerIntelDrops_General {
                displayName = "General Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Intel Items
            class Recondo_PlayerIntelDrops_Intel {
                displayName = "Intel Items";
                collapsed = 0;
                class Attributes {};
            };
            
            // Debug
            class Recondo_PlayerIntelDrops_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
            
            //==========================================
            // ELDEST SON MODULE CATEGORIES
            //==========================================
            
            // General Settings
            class Recondo_EldestSon_General {
                displayName = "General Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Poison Items
            class Recondo_EldestSon_Items {
                displayName = "Poison Items";
                collapsed = 0;
                class Attributes {};
            };
            
            // Debug
            class Recondo_EldestSon_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
            
            //==========================================
            // DEPLOYABLE RALLYPOINT MODULE CATEGORIES
            //==========================================
            
            // General Settings
            class Recondo_DRP_General {
                displayName = "General Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Rally Object Settings
            class Recondo_DRP_RallyObject {
                displayName = "Rally Object";
                collapsed = 0;
                class Attributes {};
            };
            
            // Map Marker Settings
            class Recondo_DRP_Marker {
                displayName = "Map Marker";
                collapsed = 0;
                class Attributes {};
            };
            
            // Limits & Restrictions
            class Recondo_DRP_Limits {
                displayName = "Limits & Restrictions";
                collapsed = 0;
                class Attributes {};
            };
            
            // Requirements
            class Recondo_DRP_Requirements {
                displayName = "Requirements";
                collapsed = 0;
                class Attributes {};
            };
            
            // Teleport Settings
            class Recondo_DRP_Teleport {
                displayName = "Teleport Settings";
                collapsed = 1;
                class Attributes {};
            };
            
            // UI Text
            class Recondo_DRP_Text {
                displayName = "UI Text";
                collapsed = 1;
                class Attributes {};
            };
            
            // Persistence
            class Recondo_DRP_Persistence {
                displayName = "Persistence";
                collapsed = 1;
                class Attributes {};
            };
            
            // Debug
            class Recondo_DRP_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
            
            //==========================================
            // RECON POINTS MODULE CATEGORIES
            //==========================================
            
            // General Settings
            class Recondo_RP_General {
                displayName = "General Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Point Rewards
            class Recondo_RP_Rewards {
                displayName = "Point Rewards";
                collapsed = 0;
                class Attributes {};
            };
            
            // Death Penalty
            class Recondo_RP_Death {
                displayName = "Death Penalty";
                collapsed = 1;
                class Attributes {};
            };
            
            // Unlockable Items - Weapons
            class Recondo_RP_Items_Weapons {
                displayName = "Items - Weapons";
                collapsed = 0;
                class Attributes {};
            };
            
            // Unlockable Items - Attachments
            class Recondo_RP_Items_Attach {
                displayName = "Items - Attachments & Mags";
                collapsed = 1;
                class Attributes {};
            };
            
            // Unlockable Items - Equipment
            class Recondo_RP_Items_Equipment {
                displayName = "Items - Equipment";
                collapsed = 1;
                class Attributes {};
            };
            
            // Unlockable Items - Misc
            class Recondo_RP_Items_Misc {
                displayName = "Items - Misc";
                collapsed = 1;
                class Attributes {};
            };
        };
    };
    
    // ==========================================
    // OBJECTIVE HVT MODULE CATEGORIES
    // ==========================================
    class Recondo_Module_ObjectiveHVT {
        class AttributeCategories {
            // Profile Pool
            class Recondo_HVT_ProfilePool {
                displayName = "Profile Pool";
                collapsed = 0;
                class Attributes {};
            };
            
            // General
            class Recondo_HVT_General {
                displayName = "General (Manual Entry)";
                collapsed = 1;
                class Attributes {};
            };
            
            // Composition Pool
            class Recondo_HVT_CompositionPool {
                displayName = "Composition Pool";
                collapsed = 0;
                class Attributes {};
            };
            
            // Custom Composition
            class Recondo_HVT_CompositionCustom {
                displayName = "Custom Compositions";
                collapsed = 1;
                class Attributes {};
            };
            
            // Spawning
            class Recondo_HVT_Spawning {
                displayName = "Spawning";
                collapsed = 1;
                class Attributes {};
            };
            
            // HVT
            class Recondo_HVT_HVT {
                displayName = "HVT Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Decoys
            class Recondo_HVT_Decoys {
                displayName = "Decoys";
                collapsed = 1;
                class Attributes {};
            };
            
            // Garrison AI
            class Recondo_HVT_GarrisonAI {
                displayName = "Garrison AI";
                collapsed = 1;
                class Attributes {};
            };
            
            // Civilians
            class Recondo_HVT_Civilians {
                displayName = "Civilians";
                collapsed = 1;
                class Attributes {};
            };
            
            // Animals
            class Recondo_HVT_Animals {
                displayName = "Animals";
                collapsed = 1;
                class Attributes {};
            };
            
            // Night Lights
            class Recondo_HVT_NightLights {
                displayName = "Night Lights";
                collapsed = 1;
                class Attributes {};
            };
            
            // Smell Hints
            class Recondo_HVT_SmellHints {
                displayName = "Smell Hints";
                collapsed = 1;
                class Attributes {};
            };
            
            // Intel
            class Recondo_HVT_Intel {
                displayName = "Intel Integration";
                collapsed = 1;
                class Attributes {};
            };
            
            // Debug
            class Recondo_HVT_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
        };
    };
    
    // ==========================================
    // OBJECTIVE HOSTAGES MODULE CATEGORIES
    // ==========================================
    class Recondo_Module_ObjectiveHostages {
        class AttributeCategories {
            // Profile Pool
            class Recondo_Hostage_ProfilePool {
                displayName = "Profile Pool";
                collapsed = 0;
                class Attributes {};
            };
            
            // General
            class Recondo_Hostage_General {
                displayName = "General";
                collapsed = 0;
                class Attributes {};
            };
            
            // Hostages
            class Recondo_Hostage_Hostages {
                displayName = "Hostage Settings (Manual Entry)";
                collapsed = 1;
                class Attributes {};
            };
            
            // Animation
            class Recondo_Hostage_Animation {
                displayName = "Animation";
                collapsed = 1;
                class Attributes {};
            };
            
            // Composition Pool
            class Recondo_Hostage_CompositionPool {
                displayName = "Composition Pool";
                collapsed = 0;
                class Attributes {};
            };
            
            // Custom Composition
            class Recondo_Hostage_CompositionCustom {
                displayName = "Custom Compositions";
                collapsed = 1;
                class Attributes {};
            };
            
            // Spawning
            class Recondo_Hostage_Spawning {
                displayName = "Spawning";
                collapsed = 1;
                class Attributes {};
            };
            
            // Decoys
            class Recondo_Hostage_Decoys {
                displayName = "Decoys";
                collapsed = 1;
                class Attributes {};
            };
            
            // Garrison AI
            class Recondo_Hostage_GarrisonAI {
                displayName = "Garrison AI";
                collapsed = 1;
                class Attributes {};
            };
            
            // Civilians
            class Recondo_Hostage_Civilians {
                displayName = "Civilians";
                collapsed = 1;
                class Attributes {};
            };
            
            // Animals
            class Recondo_Hostage_Animals {
                displayName = "Animals";
                collapsed = 1;
                class Attributes {};
            };
            
            // Intel
            class Recondo_Hostage_Intel {
                displayName = "Intel Integration";
                collapsed = 1;
                class Attributes {};
            };
            
            // Debug
            class Recondo_Hostage_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
            
            // Night Lights
            class Recondo_Hostage_NightLights {
                displayName = "Night Lights";
                collapsed = 1;
                class Attributes {};
            };
            
            // Smell Hints
            class Recondo_Hostage_SmellHints {
                displayName = "Smell Hints";
                collapsed = 1;
                class Attributes {};
            };
        };
    };
    
    // ==========================================
    // OBJECTIVE JAMMER (ACRE JAMMING) MODULE CATEGORIES
    // ==========================================
    class Recondo_Module_ObjectiveJammer {
        class AttributeCategories {
            // General
            class Recondo_Jammer_General {
                displayName = "General";
                collapsed = 0;
                class Attributes {};
            };
            
            // Default Compositions (Mod-bundled)
            class Recondo_Jammer_DefaultComp {
                displayName = "Default Compositions";
                collapsed = 0;
                class Attributes {};
            };
            
            // Custom Compositions (Mission folder)
            class Recondo_Jammer_CustomComp {
                displayName = "Custom Compositions";
                collapsed = 1;
                class Attributes {};
            };
            
            // Jammer Settings
            class Recondo_Jammer_Jammer {
                displayName = "Jammer Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Spawning
            class Recondo_Jammer_Spawning {
                displayName = "Spawning";
                collapsed = 1;
                class Attributes {};
            };
            
            // Sentry AI
            class Recondo_Jammer_SentryAI {
                displayName = "Sentry AI";
                collapsed = 1;
                class Attributes {};
            };
            
            // Patrol AI
            class Recondo_Jammer_PatrolAI {
                displayName = "Patrol AI";
                collapsed = 1;
                class Attributes {};
            };
            
            // Intel
            class Recondo_Jammer_Intel {
                displayName = "Intel Integration";
                collapsed = 1;
                class Attributes {};
            };
            
            // Debug
            class Recondo_Jammer_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
            
            // Night Lights
            class Recondo_Jammer_NightLights {
                displayName = "Night Lights";
                collapsed = 1;
                class Attributes {};
            };
            
            // Smell Hints
            class Recondo_Jammer_SmellHints {
                displayName = "Smell Hints";
                collapsed = 1;
                class Attributes {};
            };
        };
    };
    
    // ==========================================
    // WEATHER CONTROL MODULE CATEGORIES
    // ==========================================
    class Recondo_Module_Weather {
        class AttributeCategories {
            // General
            class Recondo_Weather_General {
                displayName = "General";
                collapsed = 0;
                class Attributes {};
            };
            
            // Access
            class Recondo_Weather_Access {
                displayName = "Access Control";
                collapsed = 0;
                class Attributes {};
            };
            
            // Time
            class Recondo_Weather_Time {
                displayName = "Time Control";
                collapsed = 0;
                class Attributes {};
            };
            
            // Debug
            class Recondo_Weather_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
        };
    };
    
    // ==========================================
    // INTRO SCREEN MODULE CATEGORIES
    // ==========================================
    class Recondo_Module_IntroScreen {
        class AttributeCategories {
            // Title
            class Recondo_Intro_Title {
                displayName = "Title";
                collapsed = 0;
                class Attributes {};
            };
            
            // Story
            class Recondo_Intro_Story {
                displayName = "Story Panels";
                collapsed = 0;
                class Attributes {};
            };
            
            // Timing
            class Recondo_Intro_Timing {
                displayName = "Timing";
                collapsed = 1;
                class Attributes {};
            };
            
            // Audio
            class Recondo_Intro_Audio {
                displayName = "Audio";
                collapsed = 1;
                class Attributes {};
            };
            
            // Debug
            class Recondo_Intro_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
        };
    };
    
    // ==========================================
    // AMBIENT SOUND TRIGGERS MODULE CATEGORIES
    // ==========================================
    class Recondo_Module_AmbientSound {
        class AttributeCategories {
            // General
            class Recondo_Ambient_General {
                displayName = "General";
                collapsed = 0;
                class Attributes {};
            };
            
            // Trigger Settings
            class Recondo_Ambient_Trigger {
                displayName = "Trigger Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Sound Settings
            class Recondo_Ambient_Sound {
                displayName = "Sound Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Custom Sounds
            class Recondo_Ambient_Custom {
                displayName = "Custom Sounds";
                collapsed = 1;
                class Attributes {};
            };
            
            // Debug
            class Recondo_Ambient_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
        };
    };
    
    // ==========================================
    // BASE TO OUTPOST TELE MODULE CATEGORIES
    // ==========================================
    class Recondo_Module_OutpostTele {
        class AttributeCategories {
            // General Settings
            class Recondo_OutpostTele_General {
                displayName = "General";
                collapsed = 0;
                class Attributes {};
            };
            
            // Outpost Settings
            class Recondo_OutpostTele_Outposts {
                displayName = "Outposts";
                collapsed = 0;
                class Attributes {};
            };
            
            // Composition Settings
            class Recondo_OutpostTele_Compositions {
                displayName = "Compositions";
                collapsed = 1;
                class Attributes {};
            };
            
            // Destruction Settings
            class Recondo_OutpostTele_Destruction {
                displayName = "Destruction";
                collapsed = 1;
                class Attributes {};
            };
            
            // Persistence Settings
            class Recondo_OutpostTele_Persistence {
                displayName = "Persistence";
                collapsed = 1;
                class Attributes {};
            };
            
            // Debug
            class Recondo_OutpostTele_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
        };
    };
    
    // ==========================================
    // CONVOY SYSTEM MODULE CATEGORIES
    // ==========================================
    class Recondo_Module_ConvoySystem {
        class AttributeCategories {
            // General
            class Recondo_Convoy_General {
                displayName = "General";
                collapsed = 0;
                class Attributes {};
            };
            
            // Markers
            class Recondo_Convoy_Markers {
                displayName = "Markers";
                collapsed = 0;
                class Attributes {};
            };
            
            // Vehicles
            class Recondo_Convoy_Vehicles {
                displayName = "Vehicles";
                collapsed = 0;
                class Attributes {};
            };
            
            // Crew
            class Recondo_Convoy_Crew {
                displayName = "Crew";
                collapsed = 0;
                class Attributes {};
            };
            
            // Convoy Behavior
            class Recondo_Convoy_Behavior {
                displayName = "Convoy Behavior";
                collapsed = 0;
                class Attributes {};
            };
            
            // Speed Control (Advanced)
            class Recondo_Convoy_SpeedControl {
                displayName = "Speed Control (Advanced)";
                collapsed = 1;
                class Attributes {};
            };
            
            // Debug
            class Recondo_Convoy_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
        };
    };
    
    // ==========================================
    // CIVILIAN TRAFFIC MODULE CATEGORIES
    // ==========================================
    class Recondo_Module_CivilianTraffic {
        class AttributeCategories {
            // General Settings
            class Recondo_CivTraffic_General {
                displayName = "General Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Spawn Settings
            class Recondo_CivTraffic_Spawn {
                displayName = "Spawn Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            // Unit Settings
            class Recondo_CivTraffic_Units {
                displayName = "Units & Vehicles";
                collapsed = 0;
                class Attributes {};
            };
            
            // Behavior Settings
            class Recondo_CivTraffic_Behavior {
                displayName = "Behavior";
                collapsed = 0;
                class Attributes {};
            };
            
            // Debug Settings
            class Recondo_CivTraffic_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
        };
    };
    
    // ==========================================
    // BLINDFOLD MODULE CATEGORIES
    // ==========================================
    class Recondo_Module_Blindfold {
        class AttributeCategories {
            // General Settings
            class Recondo_Blindfold_General {
                displayName = "General";
                collapsed = 0;
                class Attributes {};
            };
            
            // Timing Settings
            class Recondo_Blindfold_Timing {
                displayName = "Timing";
                collapsed = 0;
                class Attributes {};
            };
            
            // UI Text Settings
            class Recondo_Blindfold_Text {
                displayName = "UI Text";
                collapsed = 1;
                class Attributes {};
            };
            
            // Debug Settings
            class Recondo_Blindfold_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
            
            //==========================================
            // CUSTOM SITE SPAWN MODULE CATEGORIES
            //==========================================
            
            class Recondo_CSS_General {
                displayName = "General Settings";
                collapsed = 0;
                class Attributes {};
            };
            
            class Recondo_CSS_Compositions {
                displayName = "Compositions";
                collapsed = 0;
                class Attributes {};
            };
            
            class Recondo_CSS_Spawning {
                displayName = "Spawning";
                collapsed = 0;
                class Attributes {};
            };
            
            class Recondo_CSS_Garrison {
                displayName = "Garrison AI";
                collapsed = 1;
                class Attributes {};
            };
            
            class Recondo_CSS_Patrols {
                displayName = "Patrol AI";
                collapsed = 1;
                class Attributes {};
            };
            
            class Recondo_CSS_NightLights {
                displayName = "Night Lights";
                collapsed = 1;
                class Attributes {};
            };
            
            class Recondo_CSS_Debug {
                displayName = "Debug";
                collapsed = 1;
                class Attributes {};
            };
        };
    };
    
};
