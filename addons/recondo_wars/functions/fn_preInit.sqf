/*
    Recondo_fnc_preInit
    Pre-initialization for Recondo Wars addon
    
    Description:
        Initializes global variables before mission start.
        Runs on all machines via CBA extended event handlers.
*/

RECONDO_WARS_VERSION = "1.0.0";

// AI Tweaks globals
RECONDO_AITWEAKS_CONFIGURED_UNITS = [];
RECONDO_AITWEAKS_SETTINGS = nil;
RECONDO_AITWEAKS_INITIALIZED = nil;

// Player Options globals
RECONDO_PLAYEROPTIONS_SETTINGS = nil;
RECONDO_PLAYEROPTIONS_INITIALIZED = nil;
RECONDO_PO_TERRAIN_BLACKOUT = false;
RECONDO_PO_IN_VEHICLE = false;
RECONDO_PO_VEHICLE_GRACE = false;

// ACE Arsenal Area globals
RECONDO_ARSENALAREAS = [];

// Disable ACE Rations Area globals
RECONDO_DISABLERATIONSAREAS = [];

// JIP to Group Leader Area globals
RECONDO_JIPAREAS = [];

// ACE Spectator Object globals
RECONDO_SPECTATOROBJECTS = [];

// Persistence System globals
RECONDO_PERSISTENCE_SETTINGS = nil;
RECONDO_PERSISTENCE_INITIALIZED = nil;
RECONDO_PERSISTENCE_PLAYER_STATS = nil;
RECONDO_PERSISTENCE_SAVING = false;
RECONDO_PERSISTENCE_NEXT_SAVE = 0;
RECONDO_PERSISTENCE_TRACKING_ACTIVE = nil;

// Static Defense Randomized globals
RECONDO_SDR_SETTINGS = nil;
RECONDO_SDR_SELECTED_MARKERS = [];
RECONDO_SDR_SPAWNED_STATICS = [];
RECONDO_SDR_SPAWNED_UNITS = [];

// Foot Patrols globals
RECONDO_FP_SETTINGS = nil;
RECONDO_FP_SELECTED_MARKERS = [];
RECONDO_FP_ACTIVE_TRIGGERS = [];
RECONDO_FP_SPAWNED_GROUPS = [];

// Add AI Crew globals
RECONDO_AIC_SETTINGS = nil;
RECONDO_AIC_VEHICLES = [];

// STABO globals
RECONDO_STABO_SETTINGS = nil;
RECONDO_STABO_HELICOPTERS = [];

// Path Patrols globals
RECONDO_PP_SETTINGS = nil;
RECONDO_PP_PATH_MARKERS = [];
RECONDO_PP_SPAWNED_GROUPS = [];
RECONDO_PP_ACTIVE_TRIGGER = nil;

// RW Radio globals
RECONDO_RWR_SETTINGS = nil;
RECONDO_RWR_BATTERY_LEVELS = nil;
RECONDO_RWR_TRANSMISSION_STARTS = nil;
RECONDO_RWR_GROUP_TIMES = nil;
RECONDO_RWR_GROUP_MARKERS = nil;
RECONDO_RWR_CALL_COUNT = 0;
RECONDO_RWR_LAST_ENEMY_COUNT = 0;

// Trackers globals
RECONDO_TRACKERS_SETTINGS = nil;
RECONDO_TRACKERS_FOOTPRINTS = [];  // Format: [position, time, groupIdString, trackerGroups[]]
RECONDO_TRACKERS_ACTIVE_GROUPS = [];
RECONDO_TRACKERS_SPEED_BASED = [];  // Groups with speed-based tracking enabled
RECONDO_TRACKERS_TRACKED_GROUPS = [];  // Group IDs being tracked
RECONDO_TRACKERS_ENABLED_MARKERS = [];  // Markers that passed probability roll
RECONDO_TRACKERS_ALWAYS_TRACK_MARKERS = [];  // Markers that track regardless of player speed
RECONDO_TRACKERS_ALWAYS_TRACK_GROUPS = [];  // Group IDs that are always tracked (regardless of speed)

// Reinforcement Waves globals
RECONDO_RW_INSTANCES = [];  // Array of module instances (each with own settings)
RECONDO_RW_ACTIVE_GROUPS = [];  // All active reinforcement groups
RECONDO_RW_TRIGGERED_MODULES = [];  // Module IDs that have already triggered

// Intel System globals
RECONDO_INTEL_SETTINGS = nil;  // Module settings hashmap
RECONDO_INTEL_TARGETS = [];  // Registered targets: [type, id, pos, data, weight]
RECONDO_INTEL_REVEALED = nil;  // Hashmap: groupId -> [targetIds] (created as hashmap in module init)
RECONDO_INTEL_COMPLETED = [];  // Completed target IDs
RECONDO_INTEL_ITEMS = [];  // Valid intel item classnames
RECONDO_INTEL_TURNIN_OBJECTS = [];  // Objects with turn-in ACE actions
RECONDO_INTEL_LOG = [];  // Intel reveal history log: [{message, timestamp, targetType, targetName, grid, source}]

// Intel Items globals
RECONDO_INTELITEMS_SETTINGS = nil;  // Module settings hashmap
RECONDO_INTELITEMS_PROCESSED_UNITS = [];  // Units that have been processed (to avoid duplicates)
RECONDO_INTELITEMS_ITEM_DEFS = [];  // Parsed item definitions: [displayName, classname, weight]

// Wiretap System globals
RECONDO_WIRETAP_SETTINGS = nil;  // Module settings hashmap
RECONDO_WIRETAP_POLES = [];  // Spawned pole objects
RECONDO_WIRETAP_USED_POLES = [];  // Poles that have been wiretapped (one-time use)

// Objective Destroy System globals
RECONDO_OBJDESTROY_INSTANCES = [];  // Array of module instances with settings
RECONDO_OBJDESTROY_ACTIVE = [];  // Active objectives: [instanceId, markerId, compositionName, status]
RECONDO_OBJDESTROY_DESTROYED = [];  // Destroyed objective marker IDs
RECONDO_OBJDESTROY_SPAWNED_OBJECTS = [];  // Spawned composition objects for cleanup
RECONDO_OBJDESTROY_TRIGGERS = [];  // Proximity triggers
RECONDO_OBJDESTROY_SMELL_TRIGGERED = [];  // Markers where smell hint already triggered (per player)
RECONDO_OBJDESTROY_NIGHT_LIGHTS_ENABLED = false;  // Master toggle for night lights
RECONDO_OBJDESTROY_NIGHT_LIGHT_BUILDINGS = [];  // Buildings to light at night
RECONDO_OBJDESTROY_ACTIVE_LIGHTS = [];  // Currently active light objects
RECONDO_OBJDESTROY_NIGHT_LIGHT_LOOP_STARTED = false;  // Prevents multiple loops

// Terminal System globals
RECONDO_TERMINAL_SETTINGS = nil;  // Module settings hashmap
RECONDO_TERMINAL_OBJECT = objNull;  // The terminal object

// Objective Hub & Subs System globals
RECONDO_HUBSUBS_INSTANCES = [];  // Array of module instances with settings
RECONDO_HUBSUBS_ACTIVE = [];  // Active hubs: [instanceId, markerId, compositionName, subSiteMarkers, status]
RECONDO_HUBSUBS_DESTROYED = [];  // Destroyed hub marker IDs
RECONDO_HUBSUBS_SPAWNED_OBJECTS = [];  // Spawned composition objects for cleanup
RECONDO_HUBSUBS_TRIGGERS = [];  // Proximity triggers (hub and sub-site)
RECONDO_HUBSUBS_SUBSITES = [];  // Spawned sub-sites: [hubMarkerId, subSiteMarkerId, spawned]
RECONDO_HUBSUBS_SMELL_TRIGGERED = [];  // Markers where smell hint already triggered (per player)

// Objective HVT System globals
RECONDO_HVT_INSTANCES = [];  // Array of module instances with settings
RECONDO_HVT_LOCATIONS = createHashMap;  // instanceId -> [hvtMarker, decoyMarkers]
RECONDO_HVT_CAPTURED = [];  // Captured HVT instance IDs
RECONDO_HVT_SPAWNED_OBJECTS = [];  // Spawned composition objects for cleanup
RECONDO_HVT_TRIGGERS = [];  // Proximity triggers
RECONDO_HVT_UNITS = createHashMap;  // instanceId -> HVT unit object
RECONDO_HVT_NIGHT_LIGHTS_ENABLED = false;  // Master toggle for night lights
RECONDO_HVT_NIGHT_LIGHT_BUILDINGS = [];  // Buildings to light at night
RECONDO_HVT_ACTIVE_LIGHTS = [];  // Currently active light objects
RECONDO_HVT_NIGHT_LIGHT_LOOP_STARTED = false;  // Prevents multiple loops
RECONDO_HVT_SMELL_TRIGGERED = [];  // Markers where smell hint already triggered (per player)

// Weather System globals
RECONDO_WEATHER_SETTINGS = nil;

// Intro Screen globals
RECONDO_INTRO_SETTINGS = nil;
RECONDO_INTRO_COMPLETE = false;

// Performance Monitor globals
RECONDO_PERF_SETTINGS = nil;
RECONDO_PERF_RUNNING = false;
RECONDO_PERF_HANDLE = nil;
RECONDO_PERF_METRICS = createHashMap;

// Convoy System globals
RECONDO_CONVOY_SETTINGS = nil;           // Module settings hashmap
RECONDO_CONVOY_ACTIVE = [];              // Active convoy data: [group, createTime, vehicles, destination, leaderVeh]
RECONDO_CONVOY_SPAWN_LOOP_HANDLE = nil;  // Spawn loop script handle
RECONDO_CONVOY_CLEANUP_HANDLE = nil;     // Cleanup loop script handle

// Hostage System globals (additional)
RECONDO_HOSTAGE_LOCATIONS = createHashMap;  // Ensure initialized
RECONDO_HOSTAGE_TRIGGERS = [];  // Proximity triggers
RECONDO_HOSTAGE_SMELL_TRIGGERED = [];  // Markers where smell hint already triggered (per player)
RECONDO_HOSTAGE_NIGHT_LIGHTS_ENABLED = false;  // Master toggle for night lights
RECONDO_HOSTAGE_NIGHT_LIGHT_BUILDINGS = [];  // Buildings to light at night
RECONDO_HOSTAGE_ACTIVE_LIGHTS = [];  // Currently active light objects
RECONDO_HOSTAGE_NIGHT_LIGHT_LOOP_STARTED = false;  // Prevents multiple loops

// Objective Jammer (ACRE Jamming) System globals
RECONDO_JAMMER_INSTANCES = [];  // Array of module instances with settings
RECONDO_JAMMER_ACTIVE = [];  // Active jammers: [instanceId, markerId, compositionName, status]
RECONDO_JAMMER_DESTROYED = [];  // Destroyed jammer marker IDs
RECONDO_JAMMER_SPAWNED_OBJECTS = [];  // Spawned composition objects for cleanup
RECONDO_JAMMER_TRIGGERS = [];  // Proximity triggers
RECONDO_JAMMER_OBJECTS = createHashMap;  // markerId -> jammer object
RECONDO_JAMMER_ACTIVE_DATA = [];  // Active jammer data for client jamming: [{instanceId, markerId, position, radii, strength, side, active}]
RECONDO_JAMMER_SMELL_TRIGGERED = [];  // Markers where smell hint already triggered (per player)
RECONDO_JAMMER_NIGHT_LIGHTS_ENABLED = false;  // Master toggle for night lights
RECONDO_JAMMER_NIGHT_LIGHT_BUILDINGS = [];  // Buildings to light at night
RECONDO_JAMMER_ACTIVE_LIGHTS = [];  // Currently active light objects
RECONDO_JAMMER_NIGHT_LIGHT_LOOP_STARTED = false;  // Prevents multiple loops

// Base to Outpost Tele System globals
RECONDO_OUTPOSTTELE_INSTANCES = [];       // Array of module instances with settings
RECONDO_OUTPOSTTELE_OUTPOSTS = [];        // Active outposts: [{instanceId, markerId, displayName, position, hasComposition}]
RECONDO_OUTPOSTTELE_BASE_OBJECTS = [];    // Base teleporter objects: [{instanceId, object, position}]
RECONDO_OUTPOSTTELE_SPAWNED_OBJECTS = []; // Spawned composition objects for cleanup

// Chat Control global variables
RECONDO_CHATCONTROL_TEXT = createHashMap;     // Text restrictions per side (via HandleChatMessage)
RECONDO_CHATCONTROL_MARKERS = createHashMap;  // Marker restrictions per side (via MarkerCreated)
RECONDO_CHATCONTROL_VOICE = createHashMap;    // Voice restrictions per side (via enableChannel)
RECONDO_CHATCONTROL_DEBUG = false;            // Debug logging flag

// Civilians Working Fields global variables
RECONDO_CIVWORKING_INSTANCES = [];            // Array of module instances with settings

// Civilian Traffic global variables
RECONDO_CIVTRAFFIC_SETTINGS = nil;            // Module settings hashmap
RECONDO_CIVTRAFFIC_ZONES = [];                // Active zone data: [{markerId, trigger, active, vehicles[], spawnHandle}]
RECONDO_CIVTRAFFIC_ACTIVE_VEHICLES = [];      // All active vehicle objects (for global cleanup)

// Camps Random global variables
RECONDO_CAMPSRANDOM_INSTANCES = [];           // Array of module instances with settings
RECONDO_CAMPSRANDOM_ACTIVE = [];              // Active camps: [instanceId, markerId, composition, isModPath, status]
RECONDO_CAMPSRANDOM_SPAWNED = [];             // Spawned camps: [markerId, objects[]]
RECONDO_CAMPSRANDOM_INTEL_OBJECTS = [];       // Spawned intel objects
RECONDO_CAMPSRANDOM_SMELL_TRIGGERED = [];     // Player/marker combinations that triggered smell
RECONDO_CAMPSRANDOM_TRIGGERS = [];            // Created triggers (spawn and smell)

// Centralized Simulation Monitoring System globals
RECONDO_SIM_REGISTRY = [];                    // Registered entities: [identifier, entities[], position, simulationDistance, currentlyEnabled]
RECONDO_SIM_LOOP_RUNNING = false;             // Whether the monitor loop is active
RECONDO_SIM_DEBUG = false;                    // Debug logging flag

// Deployable Rallypoint System globals
RECONDO_DRP_SETTINGS = nil;                   // Module settings hashmap
RECONDO_DRP_RALLIES = [];                     // Active rallies: [{side, tent, marker, position, createTime}]
RECONDO_DRP_BASE_OBJECTS = [];                // Synced base teleporter objects (netIds)
RECONDO_DRP_INITIALIZED = nil;                // Prevent duplicate init

// Recon Points System globals
RECONDO_RP_SETTINGS = nil;                    // Module settings hashmap
RECONDO_RP_ITEMS = nil;                       // Unlockable items hashmap (category -> [[classname, name, cost], ...])
RECONDO_RP_PLAYER_DATA = nil;                 // Player data hashmap (uid -> {points, totalEarned, unlocks[], lastSeen})
RECONDO_RP_TERMINAL_OBJECTS = [];             // Objects with unlock terminal ACE actions
RECONDO_RP_INITIALIZED = nil;                 // Prevent duplicate init
RECONDO_RP_KILL_HANDLER = nil;                // EntityKilled handler ID
RECONDO_RP_DEATH_HANDLER = nil;               // Player death handler ID

diag_log format ["[RECONDO_WARS] PreInit complete. Version: %1", RECONDO_WARS_VERSION];
