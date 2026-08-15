/*
    Recondo_fnc_kitCarsonConsume
    Removes one instance of the informant's required item from a player

    Description:
        Runs on the interacting player's client (inventory commands need a
        local argument). Checks items, then magazines, then weapons, and
        removes exactly one instance of the first match - so the required
        classname can be an inventory item (money, water), a magazine, or
        a full weapon (rifle). Case-insensitive match, removal uses the
        exact classname from the inventory.

    Parameters:
        0: OBJECT - Player handing over the item
        1: STRING - Classname to consume

    Returns:
        Nothing
*/

params [["_unit", objNull, [objNull]], ["_classname", "", [""]]];

if (isNull _unit || {_classname == ""} || {!local _unit}) exitWith {};

private _wanted = toLower _classname;

private _list = items _unit;
private _idx = _list findIf { (toLower _x) == _wanted };
if (_idx > -1) exitWith { _unit removeItem (_list select _idx); };

_list = magazines _unit;
_idx = _list findIf { (toLower _x) == _wanted };
if (_idx > -1) exitWith { _unit removeMagazine (_list select _idx); };

_list = weapons _unit;
_idx = _list findIf { (toLower _x) == _wanted };
if (_idx > -1) exitWith { _unit removeWeapon (_list select _idx); };
