/*
    File: fn_monitorDroppedItems.sqf
    Author: TheDUDE / generated helper

    Server-side postInit monitor. Arma normally represents a dropped magazine
    inside GroundWeaponHolder / WeaponHolderSimulated. This function detects
    RW inventory magazines in those holders, removes only those magazines,
    and creates the paired rw_obj_* physical object.

    Pairing is automatic: every CfgVehicles class with a non-empty
    rw_inventoryClass property is added to the conversion map.
*/

if (!isServer) exitWith {};

[] spawn
{
    waitUntil { time > 0 };

    private _inventoryToWorld = createHashMap;

    private _vehicleClasses = configProperties
    [
        configFile >> "CfgVehicles",
        "isClass _x",
        true
    ];

    {
        private _inventoryClass = getText (_x >> "rw_inventoryClass");

        if (_inventoryClass isNotEqualTo "") then
        {
            _inventoryToWorld set [_inventoryClass, configName _x];
        };
    }
    forEach _vehicleClasses;

    if ((count _inventoryToWorld) isEqualTo 0) exitWith
    {
        diag_log "[RW Objects] Drop conversion disabled: no rw_inventoryClass mappings were found.";
    };

    diag_log format
    [
        "[RW Objects] Automatic drop conversion active with %1 inventory/world mappings.",
        count _inventoryToWorld
    ];

    while { true } do
    {
        /*
            Weapon holders are normally kept in the engine's 'out vehicles'
            object collection. Filtering by isKindOf catches derived holder
            classes as well.
        */
        private _holders = ((allMissionObjects "GroundWeaponHolder") + (allMissionObjects "WeaponHolderSimulated")) select
        {
            !isNull _x
        };

        {
            private _holder = _x;

            if !(_holder getVariable ["rw_dropConversionProcessing", false]) then
            {
                _holder setVariable ["rw_dropConversionProcessing", true];

                private _holderPosition = getPosATL _holder;
                private _holderDirection = getDir _holder;
                private _convertedCount = 0;

                /*
                    magazinesAmmoCargo returns one entry per magazine and
                    retains the ammunition count. We do not clear the holder,
                    so unrelated or partially loaded magazines are untouched.
                */
                {
                    _x params ["_magazineClass", "_ammoCount"];

                    private _worldClass = _inventoryToWorld getOrDefault
                    [
                        _magazineClass,
                        ""
                    ];

                    if (_worldClass isNotEqualTo "") then
                    {
                        // Since Arma 3 2.14, a negative cargo count removes magazines.
                        _holder addMagazineCargoGlobal [_magazineClass, -1];

                        private _angle = _convertedCount * 137.5;
                        private _radius = 0.025 + (0.018 * floor (_convertedCount / 4));
                        private _offset =
                        [
                            (sin _angle) * _radius,
                            (cos _angle) * _radius,
                            0.025 + (0.006 * (_convertedCount mod 3))
                        ];

                        private _position = _holderPosition vectorAdd _offset;
                        private _worldObject = createVehicle
                        [
                            _worldClass,
                            [0, 0, 0],
                            [],
                            0,
                            "CAN_COLLIDE"
                        ];

                        _worldObject setDir (_holderDirection + random 30 - 15);
                        _worldObject setPosATL _position;
                        _worldObject setVelocity (velocity _holder);

                        _convertedCount = _convertedCount + 1;
                    };
                }
                forEach (magazinesAmmoCargo _holder);

                if (_convertedCount > 0) then
                {
                    private _holderIsEmpty =
                        (weaponCargo _holder isEqualTo []) &&
                        (magazineCargo _holder isEqualTo []) &&
                        (itemCargo _holder isEqualTo []) &&
                        (backpackCargo _holder isEqualTo []);

                    if (_holderIsEmpty) then
                    {
                        deleteVehicle _holder;
                    }
                    else
                    {
                        _holder setVariable ["rw_dropConversionProcessing", false];
                    };
                }
                else
                {
                    _holder setVariable ["rw_dropConversionProcessing", false];
                };
            };
        }
        forEach _holders;

        uiSleep 0.25;
    };
};
