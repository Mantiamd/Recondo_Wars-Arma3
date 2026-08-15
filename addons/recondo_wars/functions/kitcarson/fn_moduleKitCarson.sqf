/*
    Recondo_fnc_moduleKitCarson
    Main initialization for Kit Carson System module

    Description:
        Advanced informant NPCs (named after the Kit Carson Scouts - former
        VC who fed intel to US forces). Synced AI units get a configurable
        ACE interaction; using it reveals one target from the central intel
        pool to the player's group, exactly like an intel item turn-in.

        Options:
        - Required item: the player must hand over one instance of a
          configurable classname (item, magazine, or weapon - money, a
          rifle, water...), consumed on success. Without it the informant
          answers with the demand line.
        - Translator restriction: only players of the configured classnames
          can talk to the informant; everyone else gets the refusal line.

        Each informant gives intel ONCE per mission start - runtime state
        only, never saved - so a server restart makes every informant
        talkative again. Revisits before restart get the depleted line.

        Multi-instance: place one module per informant, or sync several
        NPCs to one module to share the same configuration (each NPC is
        still individually one-time).

        Dedicated-server flow: the server tags each synced unit with its
        config (public, JIP-safe), registers it in a broadcast list, and
        clients add the ACE action locally. The reveal transaction runs on
        the server (fn_kitCarsonProcess); item consumption runs on the
        interacting player's client where the inventory is local.

    Priority: 10 (UI/presentation - reveal path needs the Intel module,
        which initializes earlier; targets only have to exist by first talk)

    Parameters:
        _logic     - Module logic object
        _units     - Synchronized units
        _activated - Whether module is activated
*/

params ["_logic", "_units", "_activated"];

if (!isServer) exitWith {};

if (!_activated) exitWith {
    diag_log "[RECONDO_KITCARSON] Module not activated.";
};

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

// Fallbacks match the Eden defaults (defaults are not stored in mission.sqm)
private _actionText = _logic getVariable ["actiontext", "Ask about enemy activity"];
private _requiredItem = _logic getVariable ["requireditem", ""];
private _demandLine = _logic getVariable ["demandline", "Bring me something worth my time first."];
private _intelLine = _logic getVariable ["intelline", "I hear things. Listen closely..."];
private _depletedLine = _logic getVariable ["depletedline", "I have no more intel for you today."];
private _allowedRaw = _logic getVariable ["allowedclassnames", ""];
private _refusalLine = _logic getVariable ["refusalline", "He looks at you blankly. You need a translator."];
private _debugLogging = _logic getVariable ["debuglogging", false];
if (RECONDO_MASTER_DEBUG) then { _debugLogging = true; };

private _allowedClassnames = [_allowedRaw] call Recondo_fnc_parseClassnames;

// ========================================
// VALIDATE
// ========================================

if (_actionText == "") then { _actionText = "Ask about enemy activity"; };

private _npcs = (synchronizedObjects _logic) select { _x isKindOf "CAManBase" && {alive _x} };

if (_npcs isEqualTo []) exitWith {
    diag_log "[RECONDO_KITCARSON] ERROR: No living AI units synced to module. Sync at least one unit in Eden.";
};

// ========================================
// TAG INFORMANTS AND BROADCAST
// ========================================

{
    _x setVariable ["RECONDO_KITCARSON_CFG", [
        _actionText, _requiredItem, _demandLine, _intelLine,
        _depletedLine, _allowedClassnames, _refusalLine, _debugLogging
    ], true];
} forEach _npcs;

if (isNil "RECONDO_KITCARSON_UNITS") then { RECONDO_KITCARSON_UNITS = []; };
RECONDO_KITCARSON_UNITS append _npcs;
publicVariable "RECONDO_KITCARSON_UNITS";

// ========================================
// MAIN LOGIC
// ========================================

// Add the ACE action on every client (JIP-safe via static id)
[] remoteExec ["Recondo_fnc_initKitCarsonClient", 0, "RECONDO_KITCARSON_CLIENTINIT"];

if (_debugLogging) then {
    diag_log format ["[RECONDO_KITCARSON] Informants: %1 | action: '%2' | item: '%3' | allowed: %4",
        _npcs apply { typeOf _x }, _actionText, _requiredItem, _allowedClassnames];
};

// ========================================
// FINAL LOG
// ========================================

diag_log format ["[RECONDO_KITCARSON] Module initialized. Informants: %1, required item: '%2', translator-restricted: %3",
    count _npcs, _requiredItem, _allowedClassnames isNotEqualTo []];
