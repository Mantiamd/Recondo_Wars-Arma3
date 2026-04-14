class CfgFunctions {
    class Recondo {
        tag = "Recondo";
        
        // Main initialization functions
        class Main {
            file = "\recondo_wars\functions";
            class preInit {};
            class postInit {};
            class parseClassnames {};
            class validateModules {};
        };
        
        // Centralized Simulation Monitoring System Functions
        class Simulation {
            file = "\recondo_wars\functions\simulation";
            class registerSimulation {};
            class simulationMonitorLoop {};
        };
        
        // AI Tweaks Module Functions
        class AITweaks {
            file = "\recondo_wars\functions\aitweaks";
            class moduleAITweaks {};
            class configureUnit {};
            class applySkills {};
            class removeItems {};
            class setupBehavior {};
            class initMineKnowledge {};
            class getAITweaksUnitType {};
        };
        
        // Player Options Module Functions
        class PlayerOptions {
            file = "\recondo_wars\functions\playeroptions";
            class modulePlayerOptions {};
            class restrictGraphics {};
            class adjustTraits {};
            class enforceFaces {};
            class disableRations {};
            class restrictPilots {};
            class limitPainSounds {};
            class enableCarryBodybags {};
        };
        
        // ACE Arsenal Area Module Functions
        class ArsenalArea {
            file = "\recondo_wars\functions\arsenalarea";
            class moduleArsenalArea {};
            class initArsenalAreas {};
        };
        
        // Disable ACE Rations Area Module Functions
        class DisableRationsArea {
            file = "\recondo_wars\functions\disablerationsarea";
            class moduleDisableRationsArea {};
            class initDisableRationsAreas {};
        };
        
        // JIP to Group Leader Area Module Functions
        class JIPArea {
            file = "\recondo_wars\functions\jiparea";
            class moduleJIPArea {};
            class initJIPAreas {};
        };
        
        // ACE Spectator Object Module Functions
        class SpectatorObject {
            file = "\recondo_wars\functions\spectatorobject";
            class moduleSpectatorObject {};
            class initSpectatorObjects {};
            class enterSpectator {};
        };
        
        // Persistence Module Functions
        class Persistence {
            file = "\recondo_wars\functions\persistence";
            class modulePersistence {};
            class getSaveTag {};
            class getSaveData {};
            class setSaveData {};
            class saveMission {};
            class loadMission {};
            class saveMarkers {};
            class loadMarkers {};
            class savePlayerStats {};
            class loadPlayerStats {};
            class trackPlayerStats {};
            class deleteSave {};
        };
        
        // Static Defense Randomized Module Functions
        class StaticDefenseRandomized {
            file = "\recondo_wars\functions\staticdefenserandomized";
            class moduleStaticDefenseRandomized {};
            class spawnStaticDefense {};
            class clearTerrainObjects {};
        };
        
        // Foot Patrols Module Functions
        class FootPatrols {
            file = "\recondo_wars\functions\footpatrols";
            class moduleFootPatrols {};
            class createPatrolTrigger {};
            class spawnFootPatrol {};
        };
        
        // Add AI Crew Module Functions
        class AddAICrew {
            file = "\recondo_wars\functions\addaicrew";
            class moduleAddAICrew {};
            class requestCrew {};
            class removeCrew {};
            class monitorCrew {};
        };
        
        // STABO Module Functions
        class STABO {
            file = "\recondo_wars\functions\stabo";
            class moduleSTABO {};
            class addStaboActions {};
            class addStaboAnchorAction {};
            class dropStabo {};
            class raiseStabo {};
            class pullIntoHeli {};
            class attachToStabo {};
            class attachUnconscious {};
            class attachBodybag {};
        };
        
        // Path Patrols Module Functions
        class PathPatrols {
            file = "\recondo_wars\functions\pathpatrols";
            class modulePathPatrols {};
            class createPathTrigger {};
            class spawnPathPatrol {};
        };
        
        // RW_Radio Module Functions
        class RWRadio {
            file = "\recondo_wars\functions\rwradio";
            class moduleRWRadio {};
            class initRadioClient {};
            class startTransmission {};
            class stopTransmission {};
            class getBatteryLevel {};
            class setBatteryLevel {};
            class displayBatteryLevel {};
            class replaceBattery {};
            class updateTriangulation {};
            class spawnRadioEnemy {};
            class isGroupExempt {};
            class isInSafeZone {};
        };
        
        // Trackers Module Functions
        class Trackers {
            file = "\recondo_wars\functions\trackers";
            class moduleTrackers {};
            class createTrackerGroup {};
            class trackerBehavior {};
            class createFootprint {};
            class cleanFootprints {};
            class isInNoFootprintZone {};
            class createTrackerTrigger {};
            class createTrackerDog {};
            class trackerDogBehavior {};
            class assignDogBulletMagnet {};
            class filterAirTargets {};
        };
        
        // Reinforcement Waves Module Functions
        class ReinforcementWaves {
            file = "\recondo_wars\functions\reinforcementwaves";
            class moduleReinforcementWaves {};
            class createRWDetectionTrigger {};
            class spawnReinforcementParty {};
            class createRWFlankerGroup {};
            class rwFlankerBehavior {};
            class spawnPursuitGroup {};
            class addRWDetectionHandlers {};
            class findSafeSpawnPos {};
            class rwTrackerBehavior {};
            class createRWDog {};
        };
        
        // Intel Module Functions
        class Intel {
            file = "\recondo_wars\functions\intel";
            class moduleIntel {};
            class registerIntelTarget {};
            class removeIntelTarget {};
            class revealIntel {};
            class isIntelRevealed {};
            class completeIntelTarget {};
            class getRevealedTargets {};
            class addIntelTurnIn {};
            class addIntelTurnInClient {};
            class posToGrid {};
            class playerHasIntel {};
            class processTurnIn {};
            class showIntelCard {};
        };
        
        // Intel Items Module Functions
        class IntelItems {
            file = "\recondo_wars\functions\intelitems";
            class moduleIntelItems {};
            class processUnitForIntel {};
            class addIntelToUnit {};
            class parseIntelItemsConfig {};
            class addTakeIntelAction {};
            class addTakeIntelActionClient {};
            class takeIntelFromUnit {};
            class addItemToPlayerClient {};
            class addPOWTurnIn {};
            class addPOWTurnInClient {};
            class handlePOWTurnIn {};
            class findNearestValidPOW {};
        };
        
        // Intel Board Module Functions
        class IntelBoard {
            file = "\recondo_wars\functions\intelboard";
            class moduleIntelBoard {};
            class getIntelBoardData {};
            class openIntelBoard {};
            class closeIntelBoard {};
            class updateIntelBoardDetail {};
            class addIntelBoardAction {};
            class addIntelBoardActionClient {};
        };
        
        // Wiretap Module Functions
        class Wiretap {
            file = "\recondo_wars\functions\wiretap";
            class moduleWiretap {};
            class spawnWiretapPole {};
            class addWiretapPlaceAction {};
            class startWiretapPlace {};
            class completeWiretapPlace {};
            class addWiretapRetrieveAction {};
            class startWiretapRetrieve {};
            class completeWiretapRetrieve {};
        };
        
        // Objective Destroy Module Functions
        class ObjectiveDestroy {
            file = "\recondo_wars\functions\objectivedestroy";
            class moduleObjectiveDestroy {};
            class selectObjectiveMarkers {};
            class createObjectiveTrigger {};
            class spawnObjective {};
            class loadComposition {};
            class spawnObjectiveAI {};
            class handleObjectiveDestroyed {};
            class getObjectiveCount {};
            class createObjDestroySmellTrigger { file = "\recondo_wars\functions\objectivedestroy\fn_createSmellTrigger.sqf"; };
            class showObjDestroySmellHint { file = "\recondo_wars\functions\objectivedestroy\fn_showSmellHint.sqf"; };
            class updateObjDestroyNightLights { file = "\recondo_wars\functions\objectivedestroy\fn_updateNightLights.sqf"; };
        };
        
        // Terminal Module Functions
        class Terminal {
            file = "\recondo_wars\functions\terminal";
            class moduleTerminal {};
            class addTerminalActions {};
            class addTerminalActionsClient {};
            class isPlayerAdmin {};
            class showObjectiveStatus {};
            class showPlayerStats {};
            class resetAllPersistence {};
        };
        
        // Objective Hub & Subs Module Functions
        class ObjectiveHubSubs {
            file = "\recondo_wars\functions\objectivehubsubs";
            class moduleObjectiveHubSubs {};
            class selectHubMarkers {};
            class findSubSiteMarkers {};
            class createHubTrigger {};
            class createSubSiteTrigger {};
            class spawnHub {};
            class spawnSubSite {};
            class spawnSubSiteGarrison {};
            class spawnSecurityPatrol {};
            class handleHubDestroyed {};
            class getHubObjectiveCount {};
            class createHubSubsSmellTrigger { file = "\recondo_wars\functions\objectivehubsubs\fn_createSmellTrigger.sqf"; };
            class showHubSubsSmellHint { file = "\recondo_wars\functions\objectivehubsubs\fn_showSmellHint.sqf"; };
        };
        
        class Profiles {
            file = "\recondo_wars\functions\profiles";
            class loadProfiles {};
            class selectRandomProfiles {};
        };
        
        // Camps Random Module Functions
        class CampsRandom {
            file = "\recondo_wars\functions\campsrandom";
            class moduleCampsRandom {};
            class selectCampMarkers {};
            class createCampTrigger {};
            class spawnCamp {};
            class spawnCampAI {};
            class createCampSmellTrigger {};
            class showCampSmellHint {};
            class handleIntelPickup {};
            class addCampIntelAction {};
            class createSimulationMonitor {};
        };
        
        class ObjectiveHVT {
            file = "\recondo_wars\functions\objectivehvt";
            class moduleObjectiveHVT {};
            class selectHVTLocation {};
            class createHVTTrigger {};
            class handleHVTTriggerActivation {};
            class spawnHVTComposition {};
            class spawnHVTAI {};
            class spawnHVT {};
            class spawnHVTRovingSentry {};
            class spawnHVTCivilians {};
            class spawnHVTAnimals {};
            class createDecoyTrigger {};
            class handleDecoyTriggerActivation {};
            class addHVTTurnIn {};
            class addHVTTurnInClient {};
            class handleHVTCapture {};
            class getHVTObjectiveCount {};
            class updateHVTNightLights {};
            class createSmellTrigger {};
            class showSmellHint {};
        };
        
        class ObjectiveHostages {
            file = "\recondo_wars\functions\objectivehostages";
            class moduleObjectiveHostages {};
            class selectHostageLocations {};
            class distributeHostages {};
            class createHostageTrigger {};
            class handleHostageTriggerActivation {};
            class spawnHostageComposition {};
            class spawnHostages {};
            class createHostageDecoyTrigger {};
            class handleHostageDecoyTriggerActivation {};
            class addHostageTurnIn {};
            class addHostageTurnInClient {};
            class handleHostageRescue {};
            class getHostageObjectiveStatus {};
            class createHostageSmellTrigger { file = "\recondo_wars\functions\objectivehostages\fn_createSmellTrigger.sqf"; };
            class showHostageSmellHint { file = "\recondo_wars\functions\objectivehostages\fn_showSmellHint.sqf"; };
            class updateHostageNightLights { file = "\recondo_wars\functions\objectivehostages\fn_updateNightLights.sqf"; };
        };
        
        // Objective Jammer (ACRE Jamming) Module Functions
        class ObjectiveJammer {
            file = "\recondo_wars\functions\objectivejammer";
            class moduleObjectiveJammer {};
            class selectJammerMarkers {};
            class createJammerTrigger {};
            class spawnJammerComposition {};
            class spawnJammerAI {};
            class handleJammerDestroyed {};
            class getJammerCount {};
            class initACREJamming {};
            class acreJamLoop {};
            class createJammerSmellTrigger { file = "\recondo_wars\functions\objectivejammer\fn_createSmellTrigger.sqf"; };
            class showJammerSmellHint { file = "\recondo_wars\functions\objectivejammer\fn_showSmellHint.sqf"; };
            class updateJammerNightLights { file = "\recondo_wars\functions\objectivejammer\fn_updateNightLights.sqf"; };
        };
        
        class Weather {
            file = "\recondo_wars\functions\weather";
            class moduleWeather {};
            class addWeatherControlClient {};
            class setWeather {};
            class setTime {};
        };
        
        class IntroScreen {
            file = "\recondo_wars\functions\introscreen";
            class moduleIntroScreen {};
            class showIntroScreen {};
        };
        
        // Performance Monitor Module Functions
        class PerfMonitor {
            file = "\recondo_wars\functions\perfmonitor";
            class modulePerfMonitor {};
            class initPerfMonitor {};
            class startPerfMonitor {};
            class stopPerfMonitor {};
            class collectMetrics {};
            class displayMetrics {};
            class addPerfActions {};
        };
        
        // Ambient Sound Triggers Module Functions
        class AmbientSound {
            file = "\recondo_wars\functions\ambientsound";
            class moduleAmbientSound {};
            class createAmbientTrigger {};
            class handleAmbientTrigger {};
            class playAmbientSound {};
            class getAmbientSounds {};
        };
        
        // Convoy System Module Functions
        class Convoy {
            file = "\recondo_wars\functions\convoy";
            class moduleConvoySystem {};
            class convoySpawnLoop {};
            class getActiveObjectives {};
            class spawnConvoy {};
            class initConvoyBehavior {};
            class convoyPathCreator {};
            class convoyLeadSpeedControl {};
            class convoyLinkSpeedControl {};
            class convoyDriverMonitor {};
            class convoyCleanup {};
            class terminateConvoy {};
        };
        
        // Base to Outpost Tele Module Functions
        class OutpostTele {
            file = "\recondo_wars\functions\outposttele";
            class moduleOutpostTele {};
            class initOutpostTele {};
            class selectOutpostMarkers {};
            class spawnOutpostComposition {};
            class teleportToOutpost {};
            class teleportToBase {};
            class outpostDestroyed {};
        };
        
        // Side Chat and Marker Control Module Functions
        class ChatControl {
            file = "\recondo_wars\functions\chatcontrol";
            class moduleChatControl {};
            class applyChatSettings {};
        };
        
        // Civilians Working Fields Module Functions
        class CiviliansWorking {
            file = "\recondo_wars\functions\civiliansworking";
            class moduleCiviliansWorking {};
            class createFieldTrigger {};
            class spawnFieldCivilians {};
            class civilianFieldBehavior {};
        };
        
        // Civilian Traffic Module Functions
        class CivilianTraffic {
            file = "\recondo_wars\functions\civiliantraffic";
            class moduleCivilianTraffic {};
            class createTrafficZone {};
            class activateTrafficZone {};
            class deactivateTrafficZone {};
            class spawnTrafficVehicle {};
            class trafficVehicleBehavior {};
            class findRandomRoadPos {};
            class handleTrafficGetIn {};
            class handleTrafficFiredNear {};
            class cleanupTrafficVehicle {};
        };
        
        // Blindfold Module Functions
        
        // Player Limitations Module Functions
        class PlayerLimitations {
            file = "\recondo_wars\functions\playerlimitations";
            class modulePlayerLimitations {};
            class initPlayerLimitations {};
            class checkPlayerInventory {};
            class matchesPattern {};
        };
        
        // Player Intel Drops Module Functions
        class PlayerIntelDrops {
            file = "\recondo_wars\functions\playerinteldrops";
            class modulePlayerIntelDrops {};
            class handlePlayerIntelDrop {};
        };
        
        // Eldest Son (Ammo Sabotage) Module Functions
        class EldestSon {
            file = "\recondo_wars\functions\eldestson";
            class moduleEldestSon {};
            class scanEldestSonBodies {};
            class initEldestSonUnit {};
            class handleEldestSonFired {};
        };
        
        // Deployable Rallypoint System Module Functions
        class DeployableRallypoint {
            file = "\recondo_wars\functions\deployablerallypoint";
            class moduleDeployableRallypoint {};
            class initDeployableRallypoint {};
            class deployRallypoint {};
            class deployRallypointServer {};
            class removeRallypoint {};
            class openRallyMenu {};
            class teleportToRally {};
            class saveRallypoints {};
            class loadRallypoints {};
            class addDestroyAction {};
        };
        
        // Civilian Patterns of Life Module Functions
        class CivilianPOL {
            file = "\recondo_wars\functions\civilianpol";
            class moduleCivilianPOL {};
            class initVillage {};
            class findHomePositions {};
            class createVillageTrigger {};
            class isVillageSpawned {};
            class spawnVillageCivilians {};
            class despawnVillageCivilians {};
            class civilianDailyRoutine {};
            class handleCivilianPOLKilled {};
            class handleCivilianPOLFiredNear {};
            class updateVillageNightLights {};
            class setBuildingLight {};
            class nightLightLoop {};
            class addCivilianPOLAction {};
            class civilianPOLInteract {};
            class saveCivilianPOL {};
            class loadCivilianPOL {};
        };
        
        // Recon Points System Module Functions
        class ReconPoints {
            file = "\recondo_wars\functions\reconpoints";
            class moduleReconPoints {};
            class rpGetPlayerData {};
            class rpSetPlayerData {};
            class rpAwardPoints {};
            class rpSpendPoints {};
            class rpHandlePlayerDeath {};
            class rpHasUnlocked {};
            class rpParseUnlockItems {};
            class rpAddTerminalActions {};
            class rpAddTerminalActionsClient {};
            class rpOpenUnlockShop {};
            class rpRefreshUnlockShop {};
            class rpUnlockItem {};
            class rpTakeItem {};
            class rpSaveData {};
            class rpLoadData {};
            class rpShowNotification {};
        };
        
        // Sensors Module Functions
        class Sensors {
            file = "\recondo_wars\functions\sensors";
            class moduleSensors {};
            class initSensorActions {};
            class placeSensor {};
            class pickUpSensor {};
            class sensorDetectionLoop {};
            class recordSensorEvent {};
            class sendSensorNotification {};
            class turnInSensorData {};
            class getSensorCount {};
            class saveSensors {};
            class loadSensors {};
            class classifyVehicle {};
        };
        
        // Static Weapon Limit Module Functions
        class StaticWeaponLimit {
            file = "\recondo_wars\functions\staticweaponlimit";
            class moduleStaticWeaponLimit {};
        };
        
        // Custom Site Spawn Module Functions
        class CustomSiteSpawn {
            file = "\recondo_wars\functions\customsitespawn";
            class moduleCustomSiteSpawn {};
            class spawnCustomSite {};
            class createCustomSiteTrigger {};
            class updateCustomSiteNightLights {};
        };
        
        // Bad Civi Module Functions
        class BadCivi {
            file = "\recondo_wars\functions\badcivi";
            class moduleBadCivi {};
            class setupBadCivi {};
            class spawnBadCivis {};
        };
        
        // POO Site Hunt Module Functions
        class POOSiteHunt {
            file = "\recondo_wars\functions\poositehunt";
            class modulePOOSiteHunt {};
            class createPOOTrigger {};
            class spawnPOOSite {};
            class startArtilleryFire {};
            class handlePOODestroyed {};
        };
        
        // Destroy Powergrid Module Functions
        class DestroyPowergrid {
            file = "\recondo_wars\functions\destroypowergrid";
            class moduleDestroyPowergrid {};
            class addPowergridActionClient {};
            class togglePowergridLights {};
            class applyLightsLocal {};
            class handlePowergridDestroyed {};
        };
        
        // Objective Photographs Module Functions
        class ObjectivePhotographs {
            file = "\recondo_wars\functions\objectivephotographs";
            class moduleObjectivePhotographs {};
            class spawnPhotoObjective {};
            class spawnPhotoAI {};
            class createPhotoTrigger {};
            class initPhotoCamera {};
            class handlePhotoTaken {};
            class handlePhotoComplete {};
            class addPhotoTurnIn {};
            class addPhotoTurnInClient {};
            class handlePhotoTurnIn {};
            class getPhotoObjectiveCount {};
            class createPhotoSmellTrigger { file = "\recondo_wars\functions\objectivephotographs\fn_createSmellTrigger.sqf"; };
            class showPhotoSmellHint { file = "\recondo_wars\functions\objectivephotographs\fn_showSmellHint.sqf"; };
            class updatePhotoNightLights { file = "\recondo_wars\functions\objectivephotographs\fn_updateNightLights.sqf"; };
        };
        
        // Hanoi Hannah Loudspeakers Module Functions
        class HanoiHannah {
            file = "\recondo_wars\functions\hanoihannah";
            class moduleHanoiHannah {};
            class spawnHannahSpeaker {};
            class handleSpeakerDisabled {};
        };
        
        // QRF Mounted Module Functions
        class QRFMounted {
            file = "\recondo_wars\functions\qrfmounted";
            class moduleQRFMounted {};
            class qrfDetectionLoop {};
            class spawnQRFMounted {};
        };
        
        // Village Uprising Module Functions
        class VillageUprising {
            file = "\recondo_wars\functions\villageuprising";
            class moduleVillageUprising {};
            class spawnUprisingCivilians {};
            class triggerUprising {};
        };
        
        // Player Persistence Module Functions
        class PlayerPersistence {
            file = "\recondo_wars\functions\playerpersistence";
            class modulePlayerPersistence {};
            class savePlayers {};
            class loadPlayers {};
        };
        
        // Vehicle Persistence Module Functions
        class VehiclePersistence {
            file = "\recondo_wars\functions\vehiclepersistence";
            class moduleVehiclePersistence {};
            class saveVehicles {};
            class loadVehicles {};
        };
        
        // Inventory Persistence Module Functions
        class InventoryPersistence {
            file = "\recondo_wars\functions\inventorypersistence";
            class moduleInventoryPersistence {};
            class saveInventories {};
            class loadInventories {};
        };
        
    };
};
