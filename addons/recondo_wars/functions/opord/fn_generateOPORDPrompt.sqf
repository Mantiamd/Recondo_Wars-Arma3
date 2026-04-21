/*
    Recondo_fnc_generateOPORDPrompt
    Builds a structured AI prompt from all placed module data.
    Returns the prompt as a string.
*/

private _settings = RECONDO_OPORD_SETTINGS;
if (isNil "_settings") exitWith { "ERROR: OPORD settings not initialized." };

private _debug = _settings getOrDefault ["debugLogging", false];

// ========================================
// HELPER: Get grid string from position
// ========================================

private _fnc_gridStr = {
    params ["_pos"];
    if (_pos isEqualTo [0,0,0] || {_pos isEqualTo []}) exitWith { "UNKNOWN" };
    private _grid = mapGridPosition _pos;
    if (count _grid >= 6) then {
        format ["%1 %2", _grid select [0,3], _grid select [3,3]]
    } else {
        _grid
    };
};

// ========================================
// READ SETTINGS
// ========================================

private _operationName  = _settings getOrDefault ["operationName", "UNNAMED OPERATION"];
private _missionType    = _settings getOrDefault ["missionType", 0];
private _useMissionDate = _settings getOrDefault ["useMissionDate", true];
private _customDateTime = _settings getOrDefault ["customDateTime", ""];
private _higherUnit     = _settings getOrDefault ["higherUnit", ""];
private _friendlyDesig  = _settings getOrDefault ["friendlyDesignation", ""];
private _friendlyDesc   = _settings getOrDefault ["friendlyDescription", ""];
private _supportingUnits = _settings getOrDefault ["supportingUnits", ""];
private _aoName         = _settings getOrDefault ["aoName", ""];
private _terrainDesc    = _settings getOrDefault ["terrainDescription", ""];
private _civilConsid    = _settings getOrDefault ["civilConsiderations", ""];
private _roeText        = _settings getOrDefault ["roeText", ""];
private _execNotes      = _settings getOrDefault ["executionNotes", ""];
private _phaseDesc      = _settings getOrDefault ["phaseDescriptions", ""];
private _supportAssets  = _settings getOrDefault ["supportAssets", ""];
private _serviceSupport = _settings getOrDefault ["serviceSupport", ""];
private _commandSignal  = _settings getOrDefault ["commandSignal", ""];
private _specialInstr   = _settings getOrDefault ["specialInstructions", ""];

private _includeObj     = _settings getOrDefault ["includeObjectives", true];
private _includeGrids   = _settings getOrDefault ["includeGrids", false];
private _includeWeather = _settings getOrDefault ["includeWeather", true];
private _includeEnemy   = _settings getOrDefault ["includeEnemyDisposition", true];
private _includeCiv     = _settings getOrDefault ["includeCivActivity", true];
private _includeEquip   = _settings getOrDefault ["includeEquipment", true];
private _includeExtract = _settings getOrDefault ["includeExtraction", true];

private _tone       = _settings getOrDefault ["tone", 0];
private _detailLevel = _settings getOrDefault ["detailLevel", 0];

// ========================================
// RESOLVE TONE AND DETAIL STRINGS
// ========================================

private _toneStr = switch (_tone) do {
    case 1: { "an abbreviated OPORD" };
    case 2: { "a patrol order" };
    default { "a formal 5-paragraph OPORD (Situation, Mission, Execution, Sustainment, Command & Signal)" };
};

private _detailStr = switch (_detailLevel) do {
    case 1: { "moderate" };
    case 2: { "brief and concise" };
    default { "high, with tactical detail" };
};

private _missionTypeStr = switch (_missionType) do {
    case 1: { "multi-session campaign (sustained operations over days/weeks)" };
    case 2: { "patrol mission" };
    default { "single operation (one insertion, one mission, one extraction)" };
};

// ========================================
// RESOLVE DATE/TIME
// ========================================

private _dtgStr = "";
if (_useMissionDate) then {
    private _d = date;
    private _months = ["JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC"];
    _dtgStr = format ["%1%2%3H %4 %5",
        if ((_d select 2) < 10) then { format ["0%1", _d select 2] } else { str (_d select 2) },
        if ((_d select 3) < 10) then { format ["0%1", _d select 3] } else { str (_d select 3) },
        if ((_d select 4) < 10) then { format ["0%1", _d select 4] } else { str (_d select 4) },
        _months select ((_d select 1) - 1),
        _d select 0
    ];
} else {
    if (_customDateTime != "") then {
        _dtgStr = _customDateTime;
    };
};

// ========================================
// RESOLVE MAP NAME
// ========================================

private _mapLookup = createHashMapFromArray [
    ["vn_khe_sanh", "Khe Sanh - Mountainous jungle terrain in northern I Corps, Vietnam"],
    ["cam_lao_nam", "Cam Lao Nam - Dense triple-canopy jungle with river networks, Vietnam"],
    ["vn_the_bra", "The Bra - Coastal jungle terrain, Vietnam"],
    ["kujari", "Kujari - Semi-arid region with dispersed villages and river corridor"],
    ["lythium", "Lythium - Mountainous desert terrain with scattered villages"],
    ["tanoa", "Tanoa - Tropical island archipelago with dense jungle"],
    ["altis", "Altis - Mediterranean island with mixed urban and rural terrain"],
    ["stratis", "Stratis - Small Mediterranean island"],
    ["malden", "Malden - Mediterranean island with rolling hills"],
    ["livonia", "Livonia - Eastern European temperate forest and farmland"],
    ["enoch", "Livonia - Eastern European temperate forest and farmland"]
];

private _mapName = worldName;
private _mapDescription = _mapLookup getOrDefault [toLower _mapName, format ["%1", _mapName]];

// ========================================
// BUILD PROMPT - HEADER
// ========================================

private _lines = [];

_lines pushBack "You are a military operations planner. Generate " + _toneStr + " for the following special operations mission.";
_lines pushBack format ["The level of detail should be %1.", _detailStr];
_lines pushBack format ["This is a %1.", _missionTypeStr];
_lines pushBack "";

// ========================================
// OPERATION CONTEXT
// ========================================

_lines pushBack "=== OPERATION CONTEXT ===";
if (_operationName != "") then { _lines pushBack format ["Operation Name: %1", _operationName]; };
if (_dtgStr != "") then { _lines pushBack format ["DTG: %1", _dtgStr]; };
if (_higherUnit != "") then { _lines pushBack format ["Higher Headquarters: %1", _higherUnit]; };
if (_friendlyDesig != "") then { _lines pushBack format ["Unit Designation: %1", _friendlyDesig]; };
if (_friendlyDesc != "") then { _lines pushBack format ["Unit Description: %1", _friendlyDesc]; };
if (_supportingUnits != "") then { _lines pushBack format ["Supporting Units: %1", _supportingUnits]; };
if (_aoName != "") then { _lines pushBack format ["Area of Operations: %1", _aoName]; };

private _terrainFinal = if (_terrainDesc != "") then { _terrainDesc } else { _mapDescription };
_lines pushBack format ["Terrain: %1", _terrainFinal];

private _playerCount = count playableUnits;
if (_playerCount == 0) then { _playerCount = count switchableUnits; };
_lines pushBack format ["Friendly Strength: Approximately %1 personnel", _playerCount];
_lines pushBack "";

// ========================================
// AUTO-COLLECTED: OBJECTIVES
// ========================================

if (_includeObj) then {
    private _objLines = [];
    private _objIndex = 1;

    // HVT Objectives
    if (!isNil "RECONDO_HVT_INSTANCES") then {
        {
            private _s = _x;
            private _name = _s getOrDefault ["objectiveName", "HVT Target"];
            private _hvtName = _s getOrDefault ["hvtName", ""];
            private _line = format ["%1. [HVT - CAPTURE/KILL] %2", _objIndex, _name];
            if (_hvtName != "") then { _line = _line + format [" - Target: %1", _hvtName]; };
            if (_includeGrids) then {
                private _prefix = _s getOrDefault ["markerPrefix", ""];
                if (_prefix != "") then {
                    private _mPos = getMarkerPos (_prefix + "_1");
                    if !(_mPos isEqualTo [0,0,0]) then {
                        _line = _line + format [" at grid %1", _mPos call _fnc_gridStr];
                    };
                };
            };
            _objLines pushBack _line;
            _objIndex = _objIndex + 1;
        } forEach RECONDO_HVT_INSTANCES;
    };

    // Hostage Objectives
    if (!isNil "RECONDO_HOSTAGE_INSTANCES") then {
        {
            private _s = _x;
            private _name = _s getOrDefault ["objectiveName", "Hostage Rescue"];
            private _count = _s getOrDefault ["hostageCount", 1];
            private _guards = _s getOrDefault ["guardCount", 0];
            private _line = format ["%1. [PERSONNEL RECOVERY] %2 - %3 hostage(s)", _objIndex, _name, _count];
            if (_guards > 0) then { _line = _line + format [", guarded by approximately %1 combatants", _guards]; };
            if (_includeGrids) then {
                private _prefix = _s getOrDefault ["markerPrefix", ""];
                if (_prefix != "") then {
                    private _mPos = getMarkerPos (_prefix + "_1");
                    if !(_mPos isEqualTo [0,0,0]) then {
                        _line = _line + format [" at grid %1", _mPos call _fnc_gridStr];
                    };
                };
            };
            _objLines pushBack _line;
            _objIndex = _objIndex + 1;
        } forEach RECONDO_HOSTAGE_INSTANCES;
    };

    // Destroy Objectives
    if (!isNil "RECONDO_OBJDESTROY_INSTANCES") then {
        {
            private _s = _x;
            private _name = _s getOrDefault ["objectiveName", "Destroy Target"];
            private _compType = _s getOrDefault ["compositionType", "target"];
            private _line = format ["%1. [DESTROY] %2 - %3", _objIndex, _name, _compType];
            if (_includeGrids) then {
                private _prefix = _s getOrDefault ["markerPrefix", ""];
                if (_prefix != "") then {
                    private _mPos = getMarkerPos (_prefix + "_1");
                    if !(_mPos isEqualTo [0,0,0]) then {
                        _line = _line + format [" at grid %1", _mPos call _fnc_gridStr];
                    };
                };
            };
            _objLines pushBack _line;
            _objIndex = _objIndex + 1;
        } forEach RECONDO_OBJDESTROY_INSTANCES;
    };

    // Photograph Objectives
    if (!isNil "RECONDO_PHOTO_INSTANCES") then {
        {
            private _s = _x;
            private _name = _s getOrDefault ["objectiveName", "Photograph Target"];
            private _line = format ["%1. [RECONNAISSANCE - PHOTOGRAPH] %2", _objIndex, _name];
            if (_includeGrids) then {
                private _prefix = _s getOrDefault ["markerPrefix", ""];
                if (_prefix != "") then {
                    private _mPos = getMarkerPos (_prefix + "_1");
                    if !(_mPos isEqualTo [0,0,0]) then {
                        _line = _line + format [" at grid %1", _mPos call _fnc_gridStr];
                    };
                };
            };
            _objLines pushBack _line;
            _objIndex = _objIndex + 1;
        } forEach RECONDO_PHOTO_INSTANCES;
    };

    // Jammer Objectives
    if (!isNil "RECONDO_JAMMER_INSTANCES") then {
        {
            private _s = _x;
            private _name = _s getOrDefault ["objectiveName", "Radio Jammer"];
            private _line = format ["%1. [DESTROY - COMMUNICATIONS] %2", _objIndex, _name];
            _objLines pushBack _line;
            _objIndex = _objIndex + 1;
        } forEach RECONDO_JAMMER_INSTANCES;
    };

    // POO Site Hunt
    if (!isNil "RECONDO_POO_INSTANCES") then {
        {
            private _s = _x;
            private _line = format ["%1. [SEARCH AND DESTROY] Locate and destroy enemy mortar/artillery positions", _objIndex];
            _objLines pushBack _line;
            _objIndex = _objIndex + 1;
        } forEach RECONDO_POO_INSTANCES;
    };

    // Soil Sample
    if (!isNil "RECONDO_SOIL_INSTANCES") then {
        if (count RECONDO_SOIL_INSTANCES > 0) then {
            private _line = format ["%1. [COLLECTION] Collect soil/environmental samples from road networks", _objIndex];
            _objLines pushBack _line;
            _objIndex = _objIndex + 1;
        };
    };

    // Wiretap
    if (!isNil "RECONDO_WIRETAP_SETTINGS") then {
        private _line = format ["%1. [SIGINT] Establish wiretap on enemy communications infrastructure", _objIndex];
        _objLines pushBack _line;
        _objIndex = _objIndex + 1;
    };

    // Hub & Subs
    if (!isNil "RECONDO_HUBSUBS_INSTANCES") then {
        {
            private _s = _x;
            private _name = _s getOrDefault ["objectiveName", "Hub Site"];
            private _line = format ["%1. [DESTROY - NETWORK] %2 (hub and sub-sites)", _objIndex, _name];
            _objLines pushBack _line;
            _objIndex = _objIndex + 1;
        } forEach RECONDO_HUBSUBS_INSTANCES;
    };

    if (count _objLines > 0) then {
        _lines pushBack "=== OBJECTIVES ===";
        _lines append _objLines;
        _lines pushBack "";
    };
};

// ========================================
// AUTO-COLLECTED: ENEMY DISPOSITION
// ========================================

if (_includeEnemy) then {
    private _enemyLines = [];

    // Reinforcement Waves
    if (!isNil "RECONDO_RW_INSTANCES") then {
        if (count RECONDO_RW_INSTANCES > 0) then {
            _enemyLines pushBack format ["- Enemy reinforcement capability: %1 wave source(s) detected in AO. Expect rapid enemy response upon detection.", count RECONDO_RW_INSTANCES];
        };
    };

    // QRF Mounted
    if (!isNil "RECONDO_QRF_INSTANCES") then {
        if (count RECONDO_QRF_INSTANCES > 0) then {
            _enemyLines pushBack format ["- Enemy QRF: %1 vehicle-mounted quick reaction force(s) staged in the area. Expect motorized response.", count RECONDO_QRF_INSTANCES];
        };
    };

    // Foot Patrols
    if (!isNil "RECONDO_FP_SETTINGS") then {
        _enemyLines pushBack "- Enemy foot patrols are active in the AO.";
    };

    // Path Patrols
    if (!isNil "RECONDO_PP_SETTINGS") then {
        _enemyLines pushBack "- Enemy patrols follow established routes in the AO.";
    };

    // Static Defenses
    if (!isNil "RECONDO_SDR_SETTINGS") then {
        _enemyLines pushBack "- Enemy static defensive positions observed in the AO.";
    };

    // Bad Civi
    if (!isNil "RECONDO_BADCIVI_INSTANCES") then {
        if (count RECONDO_BADCIVI_INSTANCES > 0) then {
            _enemyLines pushBack "- Intelligence indicates some civilians may be armed and hostile.";
        };
    };

    if (count _enemyLines > 0) then {
        _lines pushBack "=== ENEMY FORCES ===";
        _lines append _enemyLines;
        _lines pushBack "";
    };
};

// ========================================
// AUTO-COLLECTED: CIVILIAN ACTIVITY
// ========================================

if (_includeCiv) then {
    private _civLines = [];

    if (!isNil "RECONDO_CIVWORKING_INSTANCES") then {
        if (count RECONDO_CIVWORKING_INSTANCES > 0) then {
            _civLines pushBack "- Civilian workers present in villages and fields.";
        };
    };

    if (!isNil "RECONDO_CIVTRAFFIC_SETTINGS") then {
        _civLines pushBack "- Civilian vehicle traffic active on roads.";
    };

    if (_civilConsid != "") then {
        _civLines pushBack format ["- %1", _civilConsid];
    };

    // Village Uprising threat
    private _villageUprisingActive = false;
    {
        if (typeOf _x == "Recondo_Module_VillageUprising") then {
            _villageUprisingActive = true;
        };
    } forEach (allMissionObjects "Module_F");

    if (_villageUprisingActive) then {
        _civLines pushBack "- WARNING: Intelligence suggests civilian populations in some villages may mobilize and arm themselves if hostile forces are detected. Treat civilian gatherings with caution.";
    };

    if (count _civLines > 0) then {
        _lines pushBack "=== CIVIL CONSIDERATIONS ===";
        _lines append _civLines;
        _lines pushBack "";
    };
};

// ========================================
// AUTO-COLLECTED: WEATHER
// ========================================

if (_includeWeather) then {
    if (!isNil "RECONDO_WEATHER_SETTINGS") then {
        _lines pushBack "=== WEATHER ===";
        private _overcast = overcast;
        private _fog = fog;
        private _rain = rain;
        private _wind = wind;
        private _windSpd = vectorMagnitude _wind;
        private _weatherStr = "Clear";
        if (_overcast > 0.7) then { _weatherStr = "Overcast"; };
        if (_overcast > 0.3 && _overcast <= 0.7) then { _weatherStr = "Partly Cloudy"; };
        if (_rain > 0.3) then { _weatherStr = _weatherStr + ", Rain"; };
        if (_fog > 0.3) then { _weatherStr = _weatherStr + ", Fog (reduced visibility)"; };
        _lines pushBack format ["- Conditions: %1", _weatherStr];
        _lines pushBack format ["- Wind: %1 m/s", round _windSpd];
        _lines pushBack format ["- Visibility: %1m", round viewDistance];
        _lines pushBack "";
    };
};

// ========================================
// AUTO-COLLECTED: AVAILABLE EQUIPMENT
// ========================================

if (_includeEquip) then {
    private _equipLines = [];

    if (!isNil "RECONDO_WIRETAP_SETTINGS") then {
        _equipLines pushBack "- Wiretap equipment available for SIGINT collection.";
    };

    if (!isNil "RECONDO_RP_SETTINGS") then {
        _equipLines pushBack "- Recon point system active for reconnaissance scoring.";
    };

    if (!isNil "RECONDO_SOIL_INSTANCES") then {
        if (count RECONDO_SOIL_INSTANCES > 0) then {
            _equipLines pushBack "- Environmental sample collection kits available.";
        };
    };

    if (count _equipLines > 0) then {
        _lines pushBack "=== AVAILABLE EQUIPMENT & CAPABILITIES ===";
        _lines append _equipLines;
        _lines pushBack "";
    };
};

// ========================================
// AUTO-COLLECTED: EXTRACTION OPTIONS
// ========================================

if (_includeExtract) then {
    private _extractLines = [];

    if (!isNil "RECONDO_STABO_SETTINGS") then {
        _extractLines pushBack "- STABO extraction via rotary wing available.";
    };

    if (!isNil "RECONDO_DRP_SETTINGS") then {
        _extractLines pushBack "- Deployable rally points available for forward staging.";
    };

    if (!isNil "RECONDO_OUTPOSTTELE_INSTANCES") then {
        if (count RECONDO_OUTPOSTTELE_INSTANCES > 0) then {
            _extractLines pushBack "- Forward outpost locations established in AO.";
        };
    };

    if (count _extractLines > 0) then {
        _lines pushBack "=== EXTRACTION & MOVEMENT ===";
        _lines append _extractLines;
        _lines pushBack "";
    };
};

// ========================================
// USER-PROVIDED OPORD SECTIONS
// ========================================

if (_roeText != "") then {
    _lines pushBack "=== RULES OF ENGAGEMENT ===";
    _lines pushBack _roeText;
    _lines pushBack "";
};

if (_phaseDesc != "") then {
    _lines pushBack "=== PHASE OUTLINE (incorporate into Execution paragraph) ===";
    _lines pushBack _phaseDesc;
    _lines pushBack "";
};

if (_execNotes != "") then {
    _lines pushBack "=== EXECUTION NOTES (incorporate into Execution paragraph) ===";
    _lines pushBack _execNotes;
    _lines pushBack "";
};

if (_supportAssets != "") then {
    _lines pushBack "=== SUPPORT ASSETS (available and restricted) ===";
    _lines pushBack _supportAssets;
    _lines pushBack "";
};

if (_serviceSupport != "") then {
    _lines pushBack "=== SERVICE & SUPPORT NOTES (incorporate into Sustainment paragraph) ===";
    _lines pushBack _serviceSupport;
    _lines pushBack "";
};

if (_commandSignal != "") then {
    _lines pushBack "=== COMMAND & SIGNAL NOTES ===";
    _lines pushBack _commandSignal;
    _lines pushBack "";
};

if (_specialInstr != "") then {
    _lines pushBack "=== SPECIAL INSTRUCTIONS ===";
    _lines pushBack _specialInstr;
    _lines pushBack "";
};

// ========================================
// FINAL INSTRUCTION TO AI
// ========================================

_lines pushBack "=== GENERATION INSTRUCTIONS ===";
_lines pushBack format ["Generate %1 incorporating all the above information.", _toneStr];
_lines pushBack "Use proper military formatting and terminology.";
_lines pushBack "Include actions on contact, contingency planning, and coordination measures where appropriate.";

if (_tone == 0) then {
    _lines pushBack "Structure the output with clear paragraph headers: 1. SITUATION, 2. MISSION, 3. EXECUTION, 4. SUSTAINMENT, 5. COMMAND AND SIGNAL.";
};

if (!_includeGrids) then {
    _lines pushBack "Do not invent specific grid coordinates. Use general directional references and area names instead.";
};

_lines pushBack "Do not invent unit names or assets that were not provided above.";

// ========================================
// JOIN AND RETURN
// ========================================

private _prompt = _lines joinString (toString [10]);

if (_debug) then {
    diag_log format ["[RECONDO_OPORD] Generated prompt: %1 characters, %2 lines", count _prompt, count _lines];
};

_prompt
