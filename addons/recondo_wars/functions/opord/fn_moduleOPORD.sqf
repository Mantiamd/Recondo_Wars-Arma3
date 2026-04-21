/*
    Recondo_fnc_moduleOPORD
    OPORD Generator & Display Module

    Collects objective and mission data from all placed modules,
    generates a structured AI prompt for OPORD creation, and
    optionally displays an imported OPORD to players.
*/

params ["_logic", "_units", "_activated"];

if (!isServer) exitWith {};

if (!_activated) exitWith {
    diag_log "[RECONDO_OPORD] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _debugLogging = _logic getVariable ["debuglogging", false];
if (RECONDO_MASTER_DEBUG) then { _debugLogging = true; };

// Operation Context
private _operationName      = _logic getVariable ["operationname", ""];
private _missionType        = _logic getVariable ["missiontype", 0];
private _useMissionDate     = _logic getVariable ["usemissiondate", true];
private _customDateTime     = _logic getVariable ["customdatetime", ""];
private _higherUnit         = _logic getVariable ["higherunit", ""];
private _friendlyDesignation = _logic getVariable ["friendlyunitdesignation", ""];
private _friendlyDescription = _logic getVariable ["friendlyunitdescription", ""];
private _supportingUnits    = _logic getVariable ["supportingunits", ""];
private _aoName             = _logic getVariable ["aoname", ""];
private _terrainDescription = _logic getVariable ["terraindescription", ""];

// OPORD Sections
private _civilConsiderations = _logic getVariable ["civilconsiderations", ""];
private _roeText            = _logic getVariable ["roetext", ""];
private _executionNotes     = _logic getVariable ["executionnotes", ""];
private _phaseDescriptions  = _logic getVariable ["phasedescriptions", ""];
private _supportAssets      = _logic getVariable ["supportassets", ""];
private _serviceSupport     = _logic getVariable ["servicesupport", ""];
private _commandSignal      = _logic getVariable ["commandsignal", ""];
private _specialInstructions = _logic getVariable ["specialinstructions", ""];

// Auto-Collection Toggles
private _includeObjectives      = _logic getVariable ["includeobjectives", true];
private _includeGrids           = _logic getVariable ["includegrids", false];
private _includeWeather         = _logic getVariable ["includeweather", true];
private _includeEnemyDisposition = _logic getVariable ["includeenemydisposition", true];
private _includeCivActivity     = _logic getVariable ["includecivactivity", true];
private _includeEquipment       = _logic getVariable ["includeequipment", true];
private _includeExtraction      = _logic getVariable ["includeextraction", true];

// Prompt Settings
private _tone       = _logic getVariable ["tone", 0];
private _detailLevel = _logic getVariable ["detaillevel", 0];

// OPORD Display
private _enableDisplay = _logic getVariable ["enableoporddisplay", true];
private _opordFilename = _logic getVariable ["opordfilename", "recondo_opord.sqf"];

// ========================================
// STORE SETTINGS
// ========================================

RECONDO_OPORD_SETTINGS = createHashMapFromArray [
    ["debugLogging", _debugLogging],
    ["operationName", _operationName],
    ["missionType", _missionType],
    ["useMissionDate", _useMissionDate],
    ["customDateTime", _customDateTime],
    ["higherUnit", _higherUnit],
    ["friendlyDesignation", _friendlyDesignation],
    ["friendlyDescription", _friendlyDescription],
    ["supportingUnits", _supportingUnits],
    ["aoName", _aoName],
    ["terrainDescription", _terrainDescription],
    ["civilConsiderations", _civilConsiderations],
    ["roeText", _roeText],
    ["executionNotes", _executionNotes],
    ["phaseDescriptions", _phaseDescriptions],
    ["supportAssets", _supportAssets],
    ["serviceSupport", _serviceSupport],
    ["commandSignal", _commandSignal],
    ["specialInstructions", _specialInstructions],
    ["includeObjectives", _includeObjectives],
    ["includeGrids", _includeGrids],
    ["includeWeather", _includeWeather],
    ["includeEnemyDisposition", _includeEnemyDisposition],
    ["includeCivActivity", _includeCivActivity],
    ["includeEquipment", _includeEquipment],
    ["includeExtraction", _includeExtraction],
    ["tone", _tone],
    ["detailLevel", _detailLevel],
    ["enableDisplay", _enableDisplay],
    ["opordFilename", _opordFilename]
];
publicVariable "RECONDO_OPORD_SETTINGS";

// ========================================
// FIND SYNCED OBJECT
// ========================================

private _syncedObjects = synchronizedObjects _logic;
private _opordObject = objNull;

{
    if (!(_x isKindOf "Module_F") && !isNull _x) exitWith {
        _opordObject = _x;
    };
} forEach _syncedObjects;

if (isNull _opordObject) exitWith {
    diag_log "[RECONDO_OPORD] ERROR: No object synced to OPORD module. Sync an object in Eden Editor.";
};

RECONDO_OPORD_OBJECT = _opordObject;
publicVariable "RECONDO_OPORD_OBJECT";

// ========================================
// LOAD IMPORTED OPORD (if file exists)
// ========================================

if (_enableDisplay) then {
    [_opordFilename, _debugLogging] call Recondo_fnc_loadOPORDDisplay;
};

// ========================================
// ADD ACE ACTIONS
// ========================================

[_opordObject] remoteExec ["Recondo_fnc_addOPORDActions", 0, true];

// ========================================
// LOG
// ========================================

diag_log format ["[RECONDO_OPORD] Module initialized. Object: %1, Operation: %2", typeOf _opordObject, _operationName];

if (_debugLogging) then {
    diag_log "[RECONDO_OPORD] === OPORD Module Settings ===";
    diag_log format ["[RECONDO_OPORD] Operation: %1 | AO: %2 | Type: %3", _operationName, _aoName, _missionType];
    diag_log format ["[RECONDO_OPORD] Include Grids: %1 | Display Enabled: %2 | File: %3", _includeGrids, _enableDisplay, _opordFilename];
};
