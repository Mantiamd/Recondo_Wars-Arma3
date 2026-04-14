/*
    Recondo_fnc_qrfDetectionLoop
    Detection loop for QRF Mounted module

    Description:
        Polls every 5 seconds (with random initial offset to stagger multiple
        instances). When a QRF Side unit within the trigger radius detects a
        Target Side unit above the knowsAbout threshold, triggers the QRF spawn.
        One-time trigger, loop ends after activation.

    Parameters:
        _moduleSettings - HashMap of module settings

    Returns:
        Nothing (spawned detection loop)
*/

if (!isServer) exitWith {};

params ["_moduleSettings"];

private _moduleId = _moduleSettings get "moduleId";
private _modulePos = _moduleSettings get "modulePos";
private _triggerRadius = _moduleSettings get "triggerRadius";
private _detectionThreshold = _moduleSettings get "detectionThreshold";
private _heightLimit = _moduleSettings get "heightLimit";
private _qrfSide = _moduleSettings get "qrfSide";
private _targetSide = _moduleSettings get "targetSide";
private _debugMarkers = _moduleSettings get "debugMarkers";
private _debugLogging = _moduleSettings get "debugLogging";

if (_debugMarkers) then {
    private _markerName = format ["RECONDO_QRF_trigger_%1", _moduleId];
    private _marker = createMarker [_markerName, _modulePos];
    _marker setMarkerShape "ELLIPSE";
    _marker setMarkerSize [_triggerRadius, _triggerRadius];
    _marker setMarkerColor "ColorOrange";
    _marker setMarkerBrush "Border";
    _marker setMarkerAlpha 0.5;
};

if (_debugLogging) then {
    diag_log format ["[RECONDO_QRF] Detection loop started for module %1 at %2", _moduleId, _modulePos];
};

[_moduleSettings] spawn {
    params ["_moduleSettings"];

    private _moduleId = _moduleSettings get "moduleId";
    private _modulePos = _moduleSettings get "modulePos";
    private _triggerRadius = _moduleSettings get "triggerRadius";
    private _detectionThreshold = _moduleSettings get "detectionThreshold";
    private _heightLimit = _moduleSettings get "heightLimit";
    private _qrfSide = _moduleSettings get "qrfSide";
    private _targetSide = _moduleSettings get "targetSide";
    private _debugLogging = _moduleSettings get "debugLogging";

    // Random initial offset (0-4s) to stagger multiple module instances
    sleep (5 + random 4);

    private _triggered = false;

    while {!_triggered} do {
        if (_moduleId in RECONDO_QRF_TRIGGERED_MODULES) exitWith {
            _triggered = true;
        };

        private _detectorUnits = allUnits select {
            alive _x &&
            side _x == _qrfSide &&
            _x distance _modulePos <= _triggerRadius &&
            (getPosATL _x select 2) <= _heightLimit
        };

        {
            private _detector = _x;

            {
                private _target = _x;

                if (!alive _target || side _target != _targetSide) then { continue };

                private _targetHeight = (getPosATL _target) select 2;
                if (_targetHeight > _heightLimit) then { continue };

                private _knowsAbout = _detector knowsAbout _target;

                if (_knowsAbout >= _detectionThreshold) then {
                    RECONDO_QRF_TRIGGERED_MODULES pushBack _moduleId;
                    _moduleSettings set ["triggered", true];
                    _triggered = true;

                    if (_debugLogging) then {
                        diag_log format ["[RECONDO_QRF] Module %1: %2 detected %3 (knowsAbout: %4)",
                            _moduleId, _detector, _target, _knowsAbout];
                    };

                    private _targetPos = getPos _target;
                    [_moduleSettings, _targetPos] call Recondo_fnc_spawnQRFMounted;
                };

                if (_triggered) exitWith {};
            } forEach allUnits;

            if (_triggered) exitWith {};
        } forEach _detectorUnits;

        if (!_triggered) then {
            sleep 5;
        };
    };

    // Cleanup debug marker
    private _debugMarkers = _moduleSettings get "debugMarkers";
    if (_debugMarkers) then {
        private _markerName = format ["RECONDO_QRF_trigger_%1", _moduleId];
        deleteMarker _markerName;
    };

    if (_debugLogging) then {
        diag_log format ["[RECONDO_QRF] Detection loop ended for module %1", _moduleId];
    };
};
