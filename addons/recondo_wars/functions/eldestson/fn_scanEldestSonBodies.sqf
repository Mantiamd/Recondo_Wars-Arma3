/*
    Recondo_fnc_scanEldestSonBodies
    Periodic scanner for poison items in dead enemy bodies
    
    Description:
        Runs on server in a loop. Scans dead units of the target side
        for poison items. When found, removes the item, marks the body
        as processed, and increments the global sabotage chance.
    
    Parameters:
        None
        
    Returns:
        Nothing
*/

if (!isServer) exitWith {};

private _settings = RECONDO_ELDESTSON_SETTINGS;
if (isNil "_settings") exitWith {
    diag_log "[RECONDO_ELDESTSON] Scanner: Settings not found. Exiting.";
};

private _debug = _settings get "enableDebug";
private _targetSide = _settings get "targetSide";
private _poisonClassnames = _settings get "poisonClassnames";
private _chancePerItem = _settings get "chancePerItem";
private _maxChance = _settings get "maxChance";
private _scanInterval = _settings get "scanInterval";
private _persistenceKey = "RECONDO_ELDESTSON";

diag_log format ["[RECONDO_ELDESTSON] Body scanner started. Target side: %1, Looking for: %2", _targetSide, _poisonClassnames];

// Main scanner loop
while {true} do {
    // Wait for scan interval
    sleep _scanInterval;
    
    // Re-check settings in case module was disabled
    if (isNil "RECONDO_ELDESTSON_SETTINGS") exitWith {
        diag_log "[RECONDO_ELDESTSON] Scanner: Settings removed. Stopping.";
    };
    
    // Get current chance
    private _currentChance = RECONDO_ELDESTSON_CHANCE;
    if (isNil "_currentChance") then { _currentChance = 0; };
    
    // Skip if already at max
    if (_currentChance >= _maxChance) then {
        if (_debug) then {
            diag_log format ["[RECONDO_ELDESTSON] Scanner: Already at max chance (%1%%). Skipping scan.", _maxChance];
        };
        continue;
    };
    
    // Get ALL dead bodies first (for debugging)
    private _allDeadBodies = allDeadMen;
    
    // Find all dead units of target side that haven't been processed
    private _deadBodies = _allDeadBodies select {
        // Use stored side (set when unit was tagged while alive) - fallback to side group if not tagged
        private _storedSide = _x getVariable "RECONDO_ELDESTSON_SIDE";
        private _bodySide = if (!isNil "_storedSide") then { _storedSide } else { side group _x };
        private _isTargetSide = _bodySide == _targetSide;
        private _isProcessed = !isNil {_x getVariable "RECONDO_ELDESTSON_PROCESSED"};
        
        if (_debug) then {
            diag_log format ["[RECONDO_ELDESTSON] Body check: %1 | Side: %2 (stored: %3) | TargetSide: %4 | Match: %5 | Processed: %6", 
                typeOf _x, _bodySide, !isNil "_storedSide", _targetSide, _isTargetSide, _isProcessed];
        };
        
        _isTargetSide && {!_isProcessed}
    };
    
    // Always log scan summary
    diag_log format ["[RECONDO_ELDESTSON] Scan: %1 total dead, %2 unprocessed %3 bodies to check. Current sabotage: %4%%", 
        count _allDeadBodies, count _deadBodies, _targetSide, _currentChance];
    
    private _itemsFound = 0;
    
    {
        private _body = _x;
        
        // Get all items in the body's inventory
        private _allItems = [];
        _allItems append (uniformItems _body);
        _allItems append (vestItems _body);
        _allItems append (backpackItems _body);
        
        if (_debug) then {
            diag_log format ["[RECONDO_ELDESTSON] Checking body %1, items: %2", typeOf _body, _allItems];
        };
        
        // Check for any poison items
        private _foundPoison = false;
        private _foundClassname = "";
        
        {
            private _poisonClass = _x;
            if (_poisonClass in _allItems) exitWith {
                _foundPoison = true;
                _foundClassname = _poisonClass;
            };
        } forEach _poisonClassnames;
        
        if (_foundPoison) then {
            // Remove the poison item from the body
            _body removeItem _foundClassname;
            
            // Mark body as processed (only when poison found and consumed)
            _body setVariable ["RECONDO_ELDESTSON_PROCESSED", true, true];
            
            _itemsFound = _itemsFound + 1;
            
            diag_log format ["[RECONDO_ELDESTSON] FOUND poison item '%1' in body %2!", _foundClassname, typeOf _body];
        };
        // Bodies without poison are NOT marked as processed - they will be re-checked
        // each scan interval until poison is placed or body is cleaned up
        
    } forEach _deadBodies;
    
    // Increment chance if items were found
    if (_itemsFound > 0) then {
        private _addedChance = _itemsFound * _chancePerItem;
        private _newChance = (_currentChance + _addedChance) min _maxChance;
        
        // Update global variable
        RECONDO_ELDESTSON_CHANCE = _newChance;
        publicVariable "RECONDO_ELDESTSON_CHANCE";
        
        // Save to persistence
        [_persistenceKey + "_CHANCE", _newChance] call Recondo_fnc_setSaveData;
        saveMissionProfileNamespace;
        
        diag_log format ["[RECONDO_ELDESTSON] Sabotage increased: %1%% -> %2%% (+%3%% from %4 item(s))", 
            _currentChance, _newChance, _addedChance, _itemsFound];
        
        if (_newChance >= _maxChance) then {
            diag_log format ["[RECONDO_ELDESTSON] Maximum sabotage reached: %1%%", _maxChance];
        };
    } else {
        if (_debug) then {
            diag_log "[RECONDO_ELDESTSON] No poison items found this scan.";
        };
    };
};
