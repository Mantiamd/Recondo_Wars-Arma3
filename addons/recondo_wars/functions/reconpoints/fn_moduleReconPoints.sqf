/*
    Recondo_fnc_moduleReconPoints
    Main initialization for Recon Points System module
    
    Description:
        Creates a point-based unlock system for rewarding objective completion.
        Players earn Recon Points by completing objectives (HVT, hostages, intel, etc.)
        and can spend them to permanently unlock gear items.
        
        Sync to objects to create Unlock Terminal locations.
    
    Parameters:
        _logic - Module logic object
        _units - Synchronized units (unused)
        _activated - Whether module is activated
*/

params ["_logic", "_units", "_activated"];

// Server-only initialization
if (!isServer) exitWith {};

// Validate activation
if (!_activated) exitWith {
    diag_log "[RECONDO_RP] Module not activated.";
};

// Prevent duplicate initialization
if (!isNil "RECONDO_RP_INITIALIZED") exitWith {
    diag_log "[RECONDO_RP] WARNING: Module already initialized. Only one Recon Points module should be placed.";
};
RECONDO_RP_INITIALIZED = true;

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

// General Settings
private _terminalName = _logic getVariable ["terminalname", "Unlock Terminal"];
private _debugLogging = _logic getVariable ["debuglogging", false];
if (RECONDO_MASTER_DEBUG) then { _debugLogging = true; };

// Point Rewards
private _rewardHVT = _logic getVariable ["reward_hvt", 50];
private _rewardHostage = _logic getVariable ["reward_hostage", 40];
private _rewardIntel = _logic getVariable ["reward_intel", 15];
private _rewardWiretap = _logic getVariable ["reward_wiretap", 25];
private _rewardDestroy = _logic getVariable ["reward_destroy", 30];
private _rewardPOW = _logic getVariable ["reward_pow", 20];
private _rewardKill = _logic getVariable ["reward_kill", 1];

// Death Penalty Settings
private _deathPenaltyEnabled = _logic getVariable ["deathpenaltyenabled", false];
private _deathPenaltyType = _logic getVariable ["deathpenaltytype", 0];  // 0=reset, 1=subtract
private _deathSubtractAmount = _logic getVariable ["deathsubtractamount", 25];
private _deathResetUnlocks = _logic getVariable ["deathresetunlocks", false];

// Unlockable Items (by category)
private _itemsPrimary = _logic getVariable ["items_primary", ""];
private _itemsSecondary = _logic getVariable ["items_secondary", ""];
private _itemsHandgun = _logic getVariable ["items_handgun", ""];
private _itemsAttach = _logic getVariable ["items_attach", ""];
private _itemsMags = _logic getVariable ["items_mags", ""];
private _itemsUniform = _logic getVariable ["items_uniform", ""];
private _itemsVest = _logic getVariable ["items_vest", ""];
private _itemsBackpack = _logic getVariable ["items_backpack", ""];
private _itemsHeadgear = _logic getVariable ["items_headgear", ""];
private _itemsGoggles = _logic getVariable ["items_goggles", ""];
private _itemsItems = _logic getVariable ["items_items", ""];

// ========================================
// STORE SETTINGS
// ========================================

private _rewards = createHashMapFromArray [
    ["hvt", _rewardHVT],
    ["hostage", _rewardHostage],
    ["intel", _rewardIntel],
    ["wiretap", _rewardWiretap],
    ["destroy", _rewardDestroy],
    ["pow", _rewardPOW],
    ["kill", _rewardKill]
];

RECONDO_RP_SETTINGS = createHashMapFromArray [
    ["terminalName", _terminalName],
    ["rewards", _rewards],
    ["deathPenaltyEnabled", _deathPenaltyEnabled],
    ["deathPenaltyType", _deathPenaltyType],
    ["deathSubtractAmount", _deathSubtractAmount],
    ["deathResetUnlocks", _deathResetUnlocks],
    ["debugLogging", _debugLogging]
];
publicVariable "RECONDO_RP_SETTINGS";

// ========================================
// PARSE UNLOCKABLE ITEMS
// ========================================

RECONDO_RP_ITEMS = createHashMapFromArray [
    ["PRIMARY", [_itemsPrimary] call Recondo_fnc_rpParseUnlockItems],
    ["SECONDARY", [_itemsSecondary] call Recondo_fnc_rpParseUnlockItems],
    ["HANDGUN", [_itemsHandgun] call Recondo_fnc_rpParseUnlockItems],
    ["ATTACH", [_itemsAttach] call Recondo_fnc_rpParseUnlockItems],
    ["MAGS", [_itemsMags] call Recondo_fnc_rpParseUnlockItems],
    ["UNIFORM", [_itemsUniform] call Recondo_fnc_rpParseUnlockItems],
    ["VEST", [_itemsVest] call Recondo_fnc_rpParseUnlockItems],
    ["BACKPACK", [_itemsBackpack] call Recondo_fnc_rpParseUnlockItems],
    ["HEADGEAR", [_itemsHeadgear] call Recondo_fnc_rpParseUnlockItems],
    ["GOGGLES", [_itemsGoggles] call Recondo_fnc_rpParseUnlockItems],
    ["ITEMS", [_itemsItems] call Recondo_fnc_rpParseUnlockItems]
];
publicVariable "RECONDO_RP_ITEMS";

// Count total items
private _totalItems = 0;
{
    _totalItems = _totalItems + count _y;
} forEach RECONDO_RP_ITEMS;

// ========================================
// INITIALIZE PLAYER DATA
// ========================================

// Load existing data from persistence
[] call Recondo_fnc_rpLoadData;

// If no data loaded, create empty hashmap
if (isNil "RECONDO_RP_PLAYER_DATA") then {
    RECONDO_RP_PLAYER_DATA = createHashMap;
};
publicVariable "RECONDO_RP_PLAYER_DATA";

// ========================================
// SETUP KILL HANDLER
// ========================================

if (_rewardKill > 0) then {
    RECONDO_RP_KILL_HANDLER = addMissionEventHandler ["EntityKilled", {
        params ["_killed", "_killer", "_instigator"];
        
        // Only track AI kills (not players, not vehicles)
        if (!(_killed isKindOf "CAManBase") || isPlayer _killed) exitWith {};
        
        // Determine actual killer
        private _actualKiller = if (!isNull _instigator) then { _instigator } else { _killer };
        
        // Skip if killer is null, not a player, or killed themselves
        if (isNull _actualKiller || {!isPlayer _actualKiller} || {_actualKiller == _killed}) exitWith {};
        
        // Award kill points to the killer only (not group)
        private _killerUID = getPlayerUID _actualKiller;
        if (_killerUID == "") exitWith {};
        
        private _settings = RECONDO_RP_SETTINGS;
        if (isNil "_settings") exitWith {};
        
        private _rewards = _settings get "rewards";
        private _killReward = _rewards getOrDefault ["kill", 1];
        
        if (_killReward <= 0) exitWith {};
        
        // Award points to killer only
        private _playerData = [_killerUID] call Recondo_fnc_rpGetPlayerData;
        private _currentPoints = _playerData getOrDefault ["points", 0];
        private _totalEarned = _playerData getOrDefault ["totalEarned", 0];
        
        _playerData set ["points", _currentPoints + _killReward];
        _playerData set ["totalEarned", _totalEarned + _killReward];
        
        [_killerUID, _playerData] call Recondo_fnc_rpSetPlayerData;
        
        // Show notification to killer (silent, no popup for kills)
        if (_settings get "debugLogging") then {
            diag_log format ["[RECONDO_RP] %1 earned %2 RP for enemy kill", name _actualKiller, _killReward];
        };
    }];
    
    if (_debugLogging) then {
        diag_log format ["[RECONDO_RP] Kill handler registered. Kill reward: %1 RP", _rewardKill];
    };
};

// ========================================
// SETUP DEATH PENALTY HANDLER
// ========================================

if (_deathPenaltyEnabled) then {
    RECONDO_RP_DEATH_HANDLER = addMissionEventHandler ["EntityKilled", {
        params ["_killed", "_killer", "_instigator"];
        
        // Only track player deaths
        if (!isPlayer _killed) exitWith {};
        
        [_killed] call Recondo_fnc_rpHandlePlayerDeath;
    }];
    
    if (_debugLogging) then {
        private _penaltyDesc = if (_deathPenaltyType == 0) then { "Reset to 0" } else { format ["Subtract %1", _deathSubtractAmount] };
        diag_log format ["[RECONDO_RP] Death penalty enabled: %1, Reset unlocks: %2", _penaltyDesc, _deathResetUnlocks];
    };
};

// ========================================
// SETUP UNLOCK TERMINALS
// ========================================

private _syncedObjects = synchronizedObjects _logic;
private _terminalCount = 0;

{
    // Skip if it's another module
    if (_x isKindOf "Module_F") then { continue; };
    
    // Add ACE actions to this terminal
    RECONDO_RP_TERMINAL_OBJECTS pushBack _x;
    _terminalCount = _terminalCount + 1;
    
    // Broadcast to all clients (with JIP)
    [_x, _terminalName] remoteExec ["Recondo_fnc_rpAddTerminalActions", 0, true];
    
} forEach _syncedObjects;

publicVariable "RECONDO_RP_TERMINAL_OBJECTS";

if (_terminalCount == 0) then {
    diag_log "[RECONDO_RP] WARNING: No objects synced to Recon Points module. Unlock terminals will not be available.";
};

// ========================================
// LOG INITIALIZATION
// ========================================

diag_log format ["[RECONDO_RP] Module initialized. Terminals: %1, Unlockable items: %2", _terminalCount, _totalItems];

if (_debugLogging) then {
    diag_log "[RECONDO_RP] === Recon Points Module Settings ===";
    diag_log format ["[RECONDO_RP] Terminal Name: %1", _terminalName];
    diag_log format ["[RECONDO_RP] Rewards - HVT: %1, Hostage: %2, Intel: %3, Wiretap: %4, Destroy: %5, POW: %6, Kill: %7",
        _rewardHVT, _rewardHostage, _rewardIntel, _rewardWiretap, _rewardDestroy, _rewardPOW, _rewardKill];
    diag_log format ["[RECONDO_RP] Death Penalty: %1, Type: %2, Subtract: %3, Reset Unlocks: %4",
        _deathPenaltyEnabled, _deathPenaltyType, _deathSubtractAmount, _deathResetUnlocks];
    
    // Log item counts per category
    {
        private _cat = _x;
        private _items = RECONDO_RP_ITEMS getOrDefault [_cat, []];
        if (count _items > 0) then {
            diag_log format ["[RECONDO_RP] Category %1: %2 items", _cat, count _items];
        };
    } forEach ["PRIMARY", "SECONDARY", "HANDGUN", "ATTACH", "MAGS", "UNIFORM", "VEST", "BACKPACK", "HEADGEAR", "GOGGLES", "ITEMS"];
};
