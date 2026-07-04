/*
    Recondo_fnc_initPsychWarfareUnit
    Tags a target-side unit so its side is known after death

    Description:
        A dead body's "side group" reads as UNKNOWN, so we stamp the unit's
        side while it is still alive. The server-side scanner uses this to
        identify which bodies belong to the targeted side.

    Parameters:
        0: OBJECT  - The unit to tag
        1: HASHMAP - Instance settings (unused beyond consistency)
*/

params [["_unit", objNull, [objNull]], ["_settings", createHashMap, [createHashMap]]];

if (isNull _unit) exitWith {};
if (!alive _unit) exitWith {};
if (!local _unit) exitWith {};
if (!isNil {_unit getVariable "RECONDO_PSYWAR_TAGGED"}) exitWith {};

_unit setVariable ["RECONDO_PSYWAR_TAGGED", true, true];

// Local only - the scanner runs on the server where AI bodies are local.
_unit setVariable ["RECONDO_PSYWAR_SIDE", side _unit];
