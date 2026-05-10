/*
    Recondo_fnc_outpostSupplyLoop
    Server-side supply, fuel, garrison, and ammo management loop

    Description:
        Runs interleaved timers for:
        - Class 1 (Supply): drain + resupply object detection.
        - Class 3 (Fuel): drain + resupply object detection.
          When fuel reaches 0, all other systems are disabled
          and the marker shows "Comms lost, no fuel for generators".
        - Garrison: scans for qualifying AI, assigns LAMBS taskGarrison.
        - Ammo Resupply (Class 5): distributes magazines from crates.
        Updates the map marker and persists data when values change.

    Parameters:
        _settings - HASHMAP - Outpost settings from module init
*/

if (!isServer) exitWith {};

params [
    ["_settings", nil, [createHashMap]]
];

if (isNil "_settings") exitWith {
    diag_log "[RECONDO_OUTPOST] ERROR: outpostSupplyLoop called with nil settings.";
};

private _instanceId            = _settings get "instanceId";
private _outpostName           = _settings get "outpostName";
private _markerPos             = _settings get "markerPos";
private _outpostRadius         = _settings get "outpostRadius";
private _class1Classname       = _settings get "class1Classname";
private _class1Resupply        = _settings get "class1Resupply";
private _maxClass1Supply       = _settings get "maxClass1Supply";
private _drainAmount           = _settings get "drainAmount";
private _drainInterval         = _settings get "drainInterval";
private _detectionInterval     = _settings get "detectionInterval";
private _enablePersistence     = _settings get "enablePersistence";
private _debugLogging          = _settings get "debugLogging";
private _displayMarker         = _settings get "displayMarker";
private _garrisonClassnames    = _settings get "garrisonClassnames";
private _maxGarrison           = _settings get "maxGarrison";
private _ammoResupplyClassname = _settings get "ammoResupplyClassname";
private _ammoResupplyInterval  = _settings get "ammoResupplyInterval";

private _class3Classname       = _settings get "class3Classname";
private _class3Resupply        = _settings get "class3Resupply";
private _maxClass3Supply       = _settings get "maxClass3Supply";
private _class3DrainAmount     = _settings get "class3DrainAmount";
private _class3DrainInterval   = _settings get "class3DrainInterval";
private _class3Enabled         = _settings get "class3Enabled";

private _normalSkills          = _settings get "normalSkills";
private _lowMoraleSkills       = _settings get "lowMoraleSkills";
private _currentMoraleState    = _settings get "currentMoraleState";

private _garrisonEnabled = count _garrisonClassnames > 0;
private _ammoResupplyEnabled = _garrisonEnabled && {_ammoResupplyClassname != ""};

private _lastDrainTime = time;
private _lastDetectTime = time;
private _lastAmmoResupplyTime = time;
private _lastClass3DrainTime = time;

private _tickInterval = _detectionInterval min _drainInterval;
if (_class3Enabled) then { _tickInterval = _tickInterval min _class3DrainInterval; };
if (_tickInterval < 1) then { _tickInterval = 1; };

// ========================================
// HELPER FUNCTIONS
// ========================================

private _fnc_updateMarker = {
    params ["_marker", "_name", "_supply", "_maxSupply", "_garrisonEnabled", "_garrisonCount", "_maxGarrison", "_ammoStatus", "_class3Enabled", "_fuel", "_maxFuel"];

    if (_class3Enabled && {_fuel <= 0}) exitWith {
        _marker setMarkerText format ["%1 - Comms lost, no fuel for generators", _name];
        _marker setMarkerColor "ColorRed";
    };

    private _text = format ["%1 - Class 1: %2/%3", _name, _supply, _maxSupply];

    if (_class3Enabled) then {
        private _fuelPct = (_fuel / _maxFuel) * 100;
        private _fuelStatus = "GREEN";
        if (_fuelPct < 35) then { _fuelStatus = "RED"; } else { if (_fuelPct < 75) then { _fuelStatus = "AMBER"; }; };
        _text = format ["%1 | Class 3: %2", _text, _fuelStatus];
    };

    if (_garrisonEnabled) then {
        _text = format ["%1 | Garrison: %2/%3", _text, _garrisonCount, _maxGarrison];
        if (_ammoStatus != "") then {
            _text = format ["%1 | Class 5: %2", _text, _ammoStatus];
        };
    };

    _marker setMarkerText _text;
    _marker setMarkerColor "ColorBLUFOR";
};

private _fnc_persist = {
    params ["_name", "_supply", "_garrisonCount", "_fuel", "_class3Enabled"];
    private _supplyKey = format ["OUTPOST_%1_CLASS1", _name];
    private _garrisonKey = format ["OUTPOST_%1_GARRISON", _name];
    [_supplyKey, _supply] call Recondo_fnc_setSaveData;
    [_garrisonKey, _garrisonCount] call Recondo_fnc_setSaveData;
    if (_class3Enabled) then {
        private _fuelKey = format ["OUTPOST_%1_CLASS3", _name];
        [_fuelKey, _fuel] call Recondo_fnc_setSaveData;
    };
    saveMissionProfileNamespace;
};

private _fnc_getUnitNeededMags = {
    params ["_unit"];
    private _neededMags = createHashMap;
    {
        if (_x != "") then {
            private _compatMags = getArray (configFile >> "CfgWeapons" >> _x >> "magazines");
            if (count _compatMags > 0) then {
                _neededMags set [_x, _compatMags];
            };
        };
    } forEach [primaryWeapon _unit, handgunWeapon _unit, secondaryWeapon _unit];
    _neededMags
};

private _fnc_evaluateAmmoStatus = {
    params ["_garrisonUnits", "_ammoResupplyClassname", "_markerPos", "_outpostRadius", "_fnc_getUnitNeededMags"];
    private _aliveUnits = _garrisonUnits select {alive _x};
    if (count _aliveUnits == 0) exitWith { "GREEN" };

    private _anyEmpty = false;
    {
        private _unit = _x;
        private _weaponMags = [_unit] call _fnc_getUnitNeededMags;
        private _currentMags = magazines _unit;

        {
            private _compatList = _weaponMags get _x;
            private _hasAmmo = false;
            { if (_x in _compatList) exitWith { _hasAmmo = true; }; } forEach _currentMags;
            if (!_hasAmmo) exitWith { _anyEmpty = true; };
        } forEach (keys _weaponMags);

        if (_anyEmpty) exitWith {};
    } forEach _aliveUnits;

    if (_anyEmpty) exitWith { "RED" };

    if (_ammoResupplyClassname != "") then {
        private _crates = nearestObjects [_markerPos, [_ammoResupplyClassname], _outpostRadius, true];
        if (count _crates == 0) exitWith { "AMBER" };

        private _hasAnyAmmo = false;
        {
            private _cargoData = getMagazineCargo _x;
            if (count (_cargoData select 0) > 0) exitWith { _hasAnyAmmo = true; };
        } forEach _crates;

        if (!_hasAnyAmmo) exitWith { "AMBER" };
    };

    "GREEN"
};

private _fnc_applySkillsToGarrison = {
    params ["_garrisonUnits", "_skillSet"];
    {
        private _unit = _x;
        if (alive _unit) then {
            { _unit setSkill [_x, _y]; } forEach _skillSet;
        };
    } forEach _garrisonUnits;
};

private _currentAmmoStatus = "";

if (_debugLogging) then {
    diag_log format ["[RECONDO_OUTPOST] Supply loop started for '%1'. Tick: %2s, Drain: %3 every %4s, Detect: every %5s, Garrison: %6, AmmoResupply: %7 every %8s, Class3: %9",
        _outpostName, _tickInterval, _drainAmount, _drainInterval, _detectionInterval, _garrisonEnabled, _ammoResupplyEnabled, _ammoResupplyInterval, _class3Enabled];
};

// ========================================
// MAIN LOOP
// ========================================

while {true} do {
    sleep _tickInterval;

    private _supply = _settings get "class1Supply";
    private _fuel = _settings get "class3Supply";
    private _supplyChanged = false;
    private _fuelChanged = false;
    private _garrisonChanged = false;
    private _commsLost = _class3Enabled && {_fuel <= 0};

    // ========================================
    // CLASS 3 (FUEL) DRAIN
    // ========================================

    if (_class3Enabled && {time - _lastClass3DrainTime >= _class3DrainInterval}) then {
        _lastClass3DrainTime = time;

        if (_fuel > 0) then {
            _fuel = (_fuel - _class3DrainAmount) max 0;
            _fuelChanged = true;
            _settings set ["class3Supply", _fuel];
            _commsLost = _fuel <= 0;

            if (_debugLogging) then {
                diag_log format ["[RECONDO_OUTPOST] '%1' fuel drained %2. Class 3: %3/%4",
                    _outpostName, _class3DrainAmount, _fuel, _maxClass3Supply];
            };

            if (_commsLost) then {
                diag_log format ["[RECONDO_OUTPOST] '%1' FUEL DEPLETED - Comms lost, systems disabled.", _outpostName];
            };
        };
    };

    // ========================================
    // CLASS 3 (FUEL) RESUPPLY (always active even during comms lost)
    // ========================================

    if (_class3Enabled && {time - _lastDetectTime >= _detectionInterval || _commsLost}) then {
        private _fuelObjects = nearestObjects [_markerPos, [_class3Classname], _outpostRadius, true];
        if (count _fuelObjects > 0) then {
            {
                if (_fuel >= _maxClass3Supply) exitWith {};

                private _addAmount = (_class3Resupply min (_maxClass3Supply - _fuel));
                _fuel = _fuel + _addAmount;
                _fuelChanged = true;
                _settings set ["class3Supply", _fuel];

                if (_debugLogging) then {
                    diag_log format ["[RECONDO_OUTPOST] '%1' consumed fuel object %2 (+%3). Class 3: %4/%5",
                        _outpostName, typeOf _x, _addAmount, _fuel, _maxClass3Supply];
                };

                deleteVehicle _x;

                if (_fuel > 0 && _commsLost) then {
                    _commsLost = false;
                    diag_log format ["[RECONDO_OUTPOST] '%1' FUEL RESTORED - Comms restored, systems re-enabled.", _outpostName];
                };
            } forEach _fuelObjects;
        };
    };

    // All systems below are disabled when comms are lost
    if (_commsLost) then {
        // Still update marker and persist fuel changes
        if (_fuelChanged) then {
            [_displayMarker, _outpostName, _supply, _maxClass1Supply, _garrisonEnabled, _settings get "garrisonCount", _maxGarrison, _currentAmmoStatus, _class3Enabled, _fuel, _maxClass3Supply] call _fnc_updateMarker;

            {
                if ((_x get "instanceId") == _instanceId) exitWith {
                    _x set ["class3Supply", _fuel];
                };
            } forEach RECONDO_OUTPOST_INSTANCES;
            publicVariable "RECONDO_OUTPOST_INSTANCES";

            if (_enablePersistence) then {
                [_outpostName, _supply, _settings get "garrisonCount", _fuel, _class3Enabled] call _fnc_persist;
            };
        };
        continue;
    };

    // ========================================
    // CLASS 1 DRAIN
    // ========================================

    if (time - _lastDrainTime >= _drainInterval) then {
        _lastDrainTime = time;

        if (_supply > 0) then {
            _supply = (_supply - _drainAmount) max 0;
            _supplyChanged = true;

            if (_debugLogging) then {
                diag_log format ["[RECONDO_OUTPOST] '%1' drained %2 supply. Supply: %3/%4",
                    _outpostName, _drainAmount, _supply, _maxClass1Supply];
            };
        };
    };

    // ========================================
    // DETECTION: scan for Class 1 resupply objects
    // ========================================

    if (time - _lastDetectTime >= _detectionInterval) then {
        _lastDetectTime = time;

        if (_class1Classname != "") then {
            private _nearObjects = nearestObjects [_markerPos, [_class1Classname], _outpostRadius, true];

            if (count _nearObjects > 0) then {
                {
                    if (_supply >= _maxClass1Supply) exitWith {};

                    private _addAmount = (_class1Resupply min (_maxClass1Supply - _supply));
                    _supply = _supply + _addAmount;
                    _supplyChanged = true;

                    if (_debugLogging) then {
                        diag_log format ["[RECONDO_OUTPOST] '%1' consumed resupply object %2 (+%3). Supply: %4/%5",
                            _outpostName, typeOf _x, _addAmount, _supply, _maxClass1Supply];
                    };

                    deleteVehicle _x;
                } forEach _nearObjects;
            };
        };

        // ========================================
        // MORALE CHECK: apply skills when Class 1 crosses zero
        // ========================================

        if (_garrisonEnabled && _supplyChanged) then {
            private _newMoraleState = if (_supply > 0) then { "normal" } else { "lowMorale" };
            if (_newMoraleState != _currentMoraleState) then {
                _currentMoraleState = _newMoraleState;
                _settings set ["currentMoraleState", _currentMoraleState];

                private _skillSet = if (_currentMoraleState == "normal") then { _normalSkills } else { _lowMoraleSkills };
                private _garrisonUnits = _settings get "garrisonUnits";
                [_garrisonUnits, _skillSet] call _fnc_applySkillsToGarrison;

                if (_debugLogging) then {
                    diag_log format ["[RECONDO_OUTPOST] '%1' morale state changed to '%2'. Applied skills to %3 garrison units.",
                        _outpostName, _currentMoraleState, count (_garrisonUnits select {alive _x})];
                };
            };
        };

        // ========================================
        // GARRISON: scan for qualifying AI
        // ========================================

        if (_garrisonEnabled) then {
            private _garrisonUnits = _settings get "garrisonUnits";
            private _garrisonedGroups = _settings get "garrisonedGroups";

            private _prunedCount = 0;
            _garrisonUnits = _garrisonUnits select {
                if (!alive _x) then {
                    _x setVariable ["RECONDO_OUTPOST_GARRISONED", nil];
                    _prunedCount = _prunedCount + 1;
                    false
                } else {
                    true
                };
            };

            if (_prunedCount > 0 && _debugLogging) then {
                diag_log format ["[RECONDO_OUTPOST] '%1' pruned %2 dead garrison units.", _outpostName, _prunedCount];
            };

            private _nearUnits = _markerPos nearEntities ["CAManBase", _outpostRadius];
            private _addedCount = 0;
            private _newGroups = [];
            {
                if (count _garrisonUnits >= _maxGarrison) exitWith {};

                private _unit = _x;
                if (
                    alive _unit
                    && {!isPlayer _unit}
                    && {isNil {_unit getVariable "RECONDO_OUTPOST_GARRISONED"}}
                    && {(typeOf _unit) in _garrisonClassnames}
                ) then {
                    _unit setVariable ["RECONDO_OUTPOST_GARRISONED", _instanceId];
                    _garrisonUnits pushBack _unit;
                    _addedCount = _addedCount + 1;

                    private _skillSet = if (_currentMoraleState == "normal") then { _normalSkills } else { _lowMoraleSkills };
                    { _unit setSkill [_x, _y]; } forEach _skillSet;

                    private _grp = group _unit;
                    if !(_grp in _garrisonedGroups) then {
                        if !(_grp in _newGroups) then {
                            _newGroups pushBack _grp;
                        };
                    };
                };
            } forEach _nearUnits;

            {
                [_x, _markerPos, _outpostRadius] call lambs_wp_fnc_taskGarrison;
                _garrisonedGroups pushBack _x;

                if (_debugLogging) then {
                    diag_log format ["[RECONDO_OUTPOST] '%1' garrisoned group '%2' (%3 units) via LAMBS taskGarrison.",
                        _outpostName, groupId _x, count (units _x)];
                };
            } forEach _newGroups;

            if (_addedCount > 0 && _debugLogging) then {
                diag_log format ["[RECONDO_OUTPOST] '%1' added %2 new garrison units. Total groups: %3",
                    _outpostName, _addedCount, count _garrisonedGroups];
            };

            private _newCount = count _garrisonUnits;
            private _oldCount = _settings get "garrisonCount";

            _settings set ["garrisonUnits", _garrisonUnits];
            _settings set ["garrisonedGroups", _garrisonedGroups];

            if (_newCount != _oldCount) then {
                _settings set ["garrisonCount", _newCount];
                _garrisonChanged = true;

                if (_debugLogging) then {
                    diag_log format ["[RECONDO_OUTPOST] '%1' garrison count: %2/%3", _outpostName, _newCount, _maxGarrison];
                };
            };

            if (_ammoResupplyEnabled) then {
                private _newAmmoStatus = [_garrisonUnits, _ammoResupplyClassname, _markerPos, _outpostRadius, _fnc_getUnitNeededMags] call _fnc_evaluateAmmoStatus;
                if (_newAmmoStatus != _currentAmmoStatus) then {
                    _currentAmmoStatus = _newAmmoStatus;
                    _garrisonChanged = true;
                    if (_debugLogging) then {
                        diag_log format ["[RECONDO_OUTPOST] '%1' Class 5 ammo status: %2", _outpostName, _currentAmmoStatus];
                    };
                };
            };
        };
    };

    // ========================================
    // AMMO RESUPPLY: distribute from crates to garrison
    // ========================================

    if (_ammoResupplyEnabled && {time - _lastAmmoResupplyTime >= _ammoResupplyInterval}) then {
        _lastAmmoResupplyTime = time;

        private _garrisonUnits = _settings get "garrisonUnits";
        private _aliveGarrison = _garrisonUnits select {alive _x};

        if (count _aliveGarrison > 0) then {
            private _crates = nearestObjects [_markerPos, [_ammoResupplyClassname], _outpostRadius, true];

            if (count _crates > 0) then {
                if (_debugLogging) then {
                    diag_log format ["[RECONDO_OUTPOST] '%1' ammo resupply: found %2 crate(s), %3 alive garrison units.",
                        _outpostName, count _crates, count _aliveGarrison];
                };

                {
                    private _crate = _x;
                    private _cargoData = getMagazineCargo _crate;
                    private _cargoClasses = _cargoData select 0;
                    private _cargoCounts = _cargoData select 1;

                    if (count _cargoClasses == 0) then {
                        if (_debugLogging) then {
                            diag_log format ["[RECONDO_OUTPOST] '%1' deleting empty ammo crate %2.", _outpostName, typeOf _crate];
                        };
                        deleteVehicle _crate;
                    } else {
                        private _inventory = createHashMap;
                        {
                            private _cls = _x;
                            private _cnt = _cargoCounts select _forEachIndex;
                            private _existing = _inventory getOrDefault [_cls, 0];
                            _inventory set [_cls, _existing + _cnt];
                        } forEach _cargoClasses;

                        private _totalDistributed = 0;

                        {
                            private _unit = _x;
                            if (!alive _unit) then { continue; };

                            private _weaponMags = [_unit] call _fnc_getUnitNeededMags;

                            {
                                private _compatList = _weaponMags get _x;

                                {
                                    private _magClass = _x;
                                    private _available = _inventory getOrDefault [_magClass, 0];

                                    while {_available > 0 && {_unit canAdd _magClass}} do {
                                        _unit addMagazine _magClass;
                                        _available = _available - 1;
                                        _inventory set [_magClass, _available];
                                        _totalDistributed = _totalDistributed + 1;
                                    };
                                } forEach _compatList;
                            } forEach (keys _weaponMags);
                        } forEach _aliveGarrison;

                        if (_debugLogging) then {
                            diag_log format ["[RECONDO_OUTPOST] '%1' ammo resupply distributed %2 magazines from crate %3.",
                                _outpostName, _totalDistributed, typeOf _crate];
                        };

                        private _totalRemaining = 0;
                        {
                            _totalRemaining = _totalRemaining + _y;
                        } forEach _inventory;

                        if (_totalRemaining <= 0) then {
                            if (_debugLogging) then {
                                diag_log format ["[RECONDO_OUTPOST] '%1' ammo crate %2 depleted, deleting.", _outpostName, typeOf _crate];
                            };
                            deleteVehicle _crate;
                        } else {
                            clearMagazineCargoGlobal _crate;
                            {
                                if (_y > 0) then {
                                    _crate addMagazineCargoGlobal [_x, _y];
                                };
                            } forEach _inventory;
                        };
                    };
                } forEach _crates;
            };
        };
    };

    // ========================================
    // UPDATE if changed
    // ========================================

    if (_supplyChanged || _fuelChanged || _garrisonChanged) then {
        if (_supplyChanged) then {
            _settings set ["class1Supply", _supply];
        };

        private _garrisonCount = _settings get "garrisonCount";
        [_displayMarker, _outpostName, _supply, _maxClass1Supply, _garrisonEnabled, _garrisonCount, _maxGarrison, _currentAmmoStatus, _class3Enabled, _fuel, _maxClass3Supply] call _fnc_updateMarker;

        {
            if ((_x get "instanceId") == _instanceId) exitWith {
                _x set ["class1Supply", _supply];
                _x set ["garrisonCount", _garrisonCount];
                if (_class3Enabled) then { _x set ["class3Supply", _fuel]; };
            };
        } forEach RECONDO_OUTPOST_INSTANCES;
        publicVariable "RECONDO_OUTPOST_INSTANCES";

        if (_enablePersistence) then {
            [_outpostName, _supply, _garrisonCount, _fuel, _class3Enabled] call _fnc_persist;
        };
    };
};
