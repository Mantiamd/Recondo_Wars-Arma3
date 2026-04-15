class CfgPatches {
    class Recondo_Wars {
        name = "Recondo Wars";
        author = "GoonSix";
        url = "";
        units[] = {"Recondo_Module_AITweaks", "Recondo_Module_PlayerOptions", "Recondo_Module_Persistence", "Recondo_Module_StaticDefenseRandomized", "Recondo_Module_FootPatrols", "Recondo_Module_PathPatrols", "Recondo_Module_AddAICrew", "Recondo_Module_STABO", "Recondo_Module_RWRadio", "Recondo_Module_Trackers", "Recondo_Module_ReinforcementWaves", "Recondo_Module_Intel", "Recondo_Module_IntelItems", "Recondo_Module_IntelBoard", "Recondo_Module_Wiretap", "Recondo_Module_ObjectiveDestroy", "Recondo_Module_ObjectiveHubSubs", "Recondo_Module_ObjectiveHVT", "Recondo_Module_ObjectiveHostages", "Recondo_Module_ObjectiveJammer", "Recondo_Module_Weather", "Recondo_Module_IntroScreen", "Recondo_Module_Terminal", "Recondo_Module_ArsenalArea", "Recondo_Module_DisableRationsArea", "Recondo_Module_JIPArea", "Recondo_Module_SpectatorObject", "Recondo_Module_PerfMonitor", "Recondo_Module_AmbientSound", "Recondo_Module_ConvoySystem", "Recondo_Module_OutpostTele", "Recondo_Module_ChatControl", "Recondo_Module_CiviliansWorking", "Recondo_Module_CivilianTraffic", "Recondo_Module_CivilianPOL", "Recondo_Module_ReconPoints", "Recondo_Module_CustomSiteSpawn", "Recondo_Module_ObjectivePhotographs", "Recondo_Module_HanoiHannah", "Recondo_Module_VillageUprising", "Recondo_Module_QRFMounted", "Recondo_Module_PlayerPersistence", "Recondo_Module_VehiclePersistence", "Recondo_Module_InventoryPersistence", "Recondo_Module_SoilSample", "Recondo_STABO_Helper", "Recondo_STABO_Harness"};
        weapons[] = {};
        requiredVersion = 2.10;
        requiredAddons[] = {"A3_Modules_F", "A3_Data_F", "cba_main"};
    };
};

#include "BIS_AddonInfo.hpp"
#include "CfgEventHandlers.hpp"
#include "CfgFunctions.hpp"
#include "Cfg3DEN.hpp"
#include "CfgVehicles.hpp"
#include "RscIntelCard.hpp"
#include "RscReconPoints.hpp"