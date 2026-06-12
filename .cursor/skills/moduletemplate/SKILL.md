---
name: moduletemplate
description: Standard boilerplate and patterns for creating new Eden Editor modules in Recondo Wars
---

# Standard Module Init Pattern

Every new module init function (`fn_module<Name>.sqf`) must follow this structure. Remove sections marked OPTIONAL if they don't apply.

## Boilerplate Template

```sqf
/*
    Recondo_fnc_module<Name>
    Main initialization for <Name> module

    Description:
        <Brief description of what the module does.>

    Priority: <number> (<category> — see edenrules skill)

    Parameters:
        _logic     - Module logic object
        _units     - Synchronized units (unused unless stated)
        _activated - Whether module is activated
*/

params ["_logic", "_units", "_activated"];

// --- LOCALITY GUARD ---
// Server-only modules: use this. Omit ONLY if the module must run on all clients
// (e.g., weather, intro screens, client-side UI).
if (!isServer) exitWith {};

// --- ACTIVATION GUARD ---
if (!_activated) exitWith {
    diag_log "[RECONDO_<TAG>] Module not activated.";
};

// --- SINGLETON GUARD (OPTIONAL) ---
// Include ONLY for modules that must never run more than once per mission.
// Omit for multi-instance modules (e.g., AI Tweaks, Bad Civi, Custom Site Spawn).
if (!isNil "RECONDO_<TAG>_INITIALIZED") exitWith {
    diag_log "[RECONDO_<TAG>] WARNING: Module already initialized. Skipping duplicate.";
};
RECONDO_<TAG>_INITIALIZED = true;

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _debugLogging = _logic getVariable ["debuglogging", false];
if (RECONDO_MASTER_DEBUG) then { _debugLogging = true; };

// Read attributes using lowercase variable names matching CfgVehicles property names:
// private _myParam = _logic getVariable ["myparam", defaultValue];

// ========================================
// VALIDATE
// ========================================

// Exit early with a clear error if required attributes are missing or invalid:
// if (_requiredParam == "") exitWith {
//     diag_log "[RECONDO_<TAG>] ERROR: <param> not configured. Module disabled.";
// };

// ========================================
// STORE SETTINGS
// ========================================

// Use a hashmap for settings when the module has helper functions or loops:
// private _settings = createHashMap;
// _settings set ["myParam", _myParam];
// _settings set ["debugLogging", _debugLogging];
// RECONDO_<TAG>_SETTINGS = _settings;

// For multi-instance modules, push to a global array:
// if (isNil "RECONDO_<TAG>_INSTANCES") then { RECONDO_<TAG>_INSTANCES = []; };
// RECONDO_<TAG>_INSTANCES pushBack _settings;

// ========================================
// PERSISTENCE LOAD (OPTIONAL)
// ========================================

// if (!isNil "RECONDO_PERSISTENCE_SETTINGS") then {
//     private _savedData = ["<TAG>_SaveKey", defaultValue] call Recondo_fnc_getSaveData;
//     // Apply saved data...
// };

// ========================================
// MAIN LOGIC
// ========================================

// Module-specific initialization here.

// ========================================
// PERSISTENCE SAVE LOOP (OPTIONAL)
// ========================================

// if (!isNil "RECONDO_PERSISTENCE_SETTINGS") then {
//     [{
//         // Save logic...
//         saveMissionProfileNamespace;
//     }, 300, []] call CBA_fnc_addPerFrameHandler;
// };

// ========================================
// FINAL LOG
// ========================================

diag_log format ["[RECONDO_<TAG>] Module initialized. <summary info>"];
```

## Rules

### Locality

| Module runs on... | Guard | When to use |
|---|---|---|
| Server only | `if (!isServer) exitWith {};` | AI logic, spawning, persistence, server-side tracking |
| All machines | Omit the guard | Weather, intro screens, client-side UI/UX |
| Owner of synced object | `if (!local _syncedObj) exitWith {};` | Rare — only when logic must run where the object is local |

Never run AI logic on all clients. Always handle locality explicitly.

### Singleton vs Multi-Instance

- **Singleton** (place once): Add the `RECONDO_<TAG>_INITIALIZED` guard. Examples: Persistence, Player Persistence, RW Radio.
- **Multi-instance** (place many): Use `RECONDO_<TAG>_INSTANCES` array. Each placement pushes its own settings hashmap. Examples: AI Tweaks, Bad Civi, Custom Site Spawn, Foot Patrols.

### Debug Logging

- Always read `debuglogging` attribute from the module.
- Always override with `RECONDO_MASTER_DEBUG` if it's true.
- Use the pattern: `if (_debugLogging) then { diag_log format ["[RECONDO_<TAG>] ..."]; };`
- Use `[RECONDO_<TAG>]` prefix for all log lines. Keep the tag short and consistent.

### Attribute Reading

- Use `_logic getVariable ["lowercasename", defaultValue]`.
- The variable name must match the `property` name in `CfgVehicles.hpp` (always lowercase).
- Parse comma/newline-separated classname strings with `Recondo_fnc_parseClassnames`.

### Global Variable Naming

- All globals: `RECONDO_<TAG>_<PURPOSE>`
- Settings hashmap: `RECONDO_<TAG>_SETTINGS`
- Instance array: `RECONDO_<TAG>_INSTANCES`
- Initialized flag: `RECONDO_<TAG>_INITIALIZED`
- Handler IDs (if you need to remove them later): `RECONDO_<TAG>_<HANDLER_NAME>_EH`
- Initialize globals in `fn_preInit.sqf` only if they are read before the module runs. Don't add write-only globals.

### CfgVehicles / Cfg3DEN / CfgFunctions Checklist

When creating a new module, update ALL of these:

1. **`CfgVehicles.hpp`** — Add `class Recondo_Module_<Name>: Module_F { ... }` with attributes.
2. **`Cfg3DEN.hpp`** — Add `class Recondo_Module_<Name> { class AttributeCategories { ... }; };` as a top-level block inside `class Cfg3DEN`. Do NOT nest inside another module's block.
3. **`CfgFunctions.hpp`** — Register the function class and files.
4. **`config.cpp`** — Add `Recondo_Module_<Name>` to the `units[]` array in `CfgPatches`.
5. **`fn_preInit.sqf`** — Add globals only if needed (read before module init).

### Header Comment

Always include: function name, description, priority with reasoning, and parameter list. See template above.
