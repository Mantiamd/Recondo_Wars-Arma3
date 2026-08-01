/*
    Recondo_fnc_moduleSmarterAAA
    Main initialization for Smarter AAA module

    Description:
        Makes AI anti-aircraft gun crews hear approaching aircraft, pre-aim at
        the sound, fire blind through jungle canopy with computed lead, and
        engage high loiterers the vanilla AI silently ignores.

        Whitelist-driven: the gun whitelist attribute is REQUIRED - only
        statics matching those classnames (inheritance-aware) are managed,
        whether editor-placed, SDR-spawned, or from any other spawner (a
        periodic rescan catches late spawns). Any AA gun not on the list
        stays fully vanilla. Per-gun overrides (RECONDO_SAAA_ignore /
        RECONDO_SAAA_noScriptFire / RECONDO_SAAA_noBlindfire /
        RECONDO_SAAA_manage) give per-placement control.

        All steering (doWatch/disableAI/fire) requires the crew local to the
        server: Recondo_fnc_transferGroupToHC refuses managed-gun crews while
        this module is active, and the gun scan only picks up server-local
        guns as a backstop.

        Behavior settings are plain globals - they can be tuned live from the
        debug console (e.g. RECONDO_SAAA_DEBUG = true).

    Priority: 1 (Infrastructure - must initialize before spawner modules at
        priority 5 so the HC transfer guard sees the system as active before
        any static-gun crews are spawned and offered to a Headless Client.)

    Parameters:
        _logic     - Module logic object
        _units     - Synchronized units (unused - detection is map-wide)
        _activated - Whether module is activated
*/

params ["_logic", "_units", "_activated"];

if (!isServer) exitWith {};

if (!_activated) exitWith {
    diag_log "[RECONDO_SAAA] Module not activated.";
};

if (!isNil "RECONDO_SAAA_INITIALIZED") exitWith {
    diag_log "[RECONDO_SAAA] WARNING: Module already initialized. Only one Smarter AAA module should be placed.";
};

// ========================================
// VALIDATE REQUIRED ATTRIBUTES
// ========================================

// Validate before setting the initialized flag: the HC transfer guard keys off
// that flag and would otherwise call the gun predicate with undefined globals.
private _gunWhitelistRaw = _logic getVariable ["gunwhitelist", ""];
private _gunWhitelist = [_gunWhitelistRaw] call Recondo_fnc_parseClassnames;

if (_gunWhitelist isEqualTo []) exitWith {
    diag_log "[RECONDO_SAAA] ERROR: Gun Whitelist not configured - no static weapon classnames to manage. Module disabled.";
    ["[RW Smarter AAA] Gun Whitelist is empty - module disabled. Add static weapon classnames in the module attributes."] remoteExec ["systemChat", 0];
};

RECONDO_SAAA_INITIALIZED = true;

// ========================================
// READ MODULE ATTRIBUTES
// ========================================

private _debugLogging = _logic getVariable ["debuglogging", false];
if (RECONDO_MASTER_DEBUG) then { _debugLogging = true; };

// Hearing
private _audibleHelo  = _logic getVariable ["audiblerangehelo", 2500];
private _audiblePlane = _logic getVariable ["audiblerangeplane", 2000];

// Script fire envelopes
private _blindfire      = _logic getVariable ["blindfire", true];
private _blindfireRange = _logic getVariable ["blindfirerange", 800];
private _aimedFire      = _logic getVariable ["aimedfire", true];
private _aimedRange     = _logic getVariable ["aimedrange", 1800];

// Target filters
private _fireHelos        = _logic getVariable ["scriptfirehelos", true];
private _firePlanes       = _logic getVariable ["scriptfireplanes", false];
private _fireBlacklistRaw = _logic getVariable ["scriptfireblacklist", ""];

// Accuracy / fear model
private _bfBaseError    = _logic getVariable ["bfbaseerror", 7];
private _bfErrorPerMs   = _logic getVariable ["bferrorperms", 0.5];
private _bfMaxError     = _logic getVariable ["bfmaxerror", 45];
private _bfRampTime     = _logic getVariable ["bframptime", 60];
private _bfRampStart    = _logic getVariable ["bframpstart", 1.5];
private _bfRampEnd      = _logic getVariable ["bframpend", 0.45];
private _aimedErrFactor = _logic getVariable ["aimederrfactor", 0.35];

// Fire rhythm
private _burstMin     = _logic getVariable ["bfburstmin", 6];
private _burstMax     = _logic getVariable ["bfburstmax", 12];
private _shotInterval = _logic getVariable ["bfshotinterval", 0.15];
private _pauseMin     = _logic getVariable ["bfpausemin", 3];
private _pauseMax     = _logic getVariable ["bfpausemax", 7];

// ========================================
// VALIDATE
// ========================================

_burstMax = _burstMax max _burstMin;
_pauseMax = _pauseMax max _pauseMin;
_blindfireRange = _blindfireRange max 100;
_aimedRange = _aimedRange max _blindfireRange;
_shotInterval = _shotInterval max 0.05;

// ========================================
// STORE SETTINGS (plain globals - live-tunable from the debug console)
// ========================================

RECONDO_SAAA_ENABLED = true;              // live kill switch (releases all guns)
RECONDO_SAAA_DEBUG   = _debugLogging;     // map markers + chat + RPT trace

RECONDO_SAAA_AUDIBLE_HELO  = _audibleHelo;
RECONDO_SAAA_AUDIBLE_PLANE = _audiblePlane;

RECONDO_SAAA_BLINDFIRE       = _blindfire;
RECONDO_SAAA_BLINDFIRE_RANGE = _blindfireRange;
RECONDO_SAAA_AIMEDFIRE       = _aimedFire;
RECONDO_SAAA_AIMED_RANGE     = _aimedRange;

RECONDO_SAAA_FIRE_HELOS     = _fireHelos;
RECONDO_SAAA_FIRE_PLANES    = _firePlanes;
RECONDO_SAAA_FIRE_BLACKLIST = [_fireBlacklistRaw] call Recondo_fnc_parseClassnames;

RECONDO_SAAA_GUN_WHITELIST = _gunWhitelist;

RECONDO_SAAA_BF_BASE_ERROR    = _bfBaseError;
RECONDO_SAAA_BF_ERROR_PER_MS  = _bfErrorPerMs;
RECONDO_SAAA_BF_MAX_ERROR     = _bfMaxError;
RECONDO_SAAA_BF_RAMP_TIME     = _bfRampTime;
RECONDO_SAAA_BF_RAMP_START    = _bfRampStart;
RECONDO_SAAA_BF_RAMP_END      = _bfRampEnd;
RECONDO_SAAA_AIMED_ERR_FACTOR = _aimedErrFactor;

RECONDO_SAAA_BURST_MIN     = _burstMin;
RECONDO_SAAA_BURST_MAX     = _burstMax;
RECONDO_SAAA_SHOT_INTERVAL = _shotInterval;
RECONDO_SAAA_PAUSE_MIN     = _pauseMin;
RECONDO_SAAA_PAUSE_MAX     = _pauseMax;

// Advanced tuning (deliberately not exposed as attributes - proven defaults;
// still overridable live from the debug console)
RECONDO_SAAA_PROP_MAX_SPEED = 700;   // km/h config maxSpeed <= this = prop; jets ignored
RECONDO_SAAA_ENGAGE_KNOWS   = 2.5;   // knowsAbout threshold for vanilla-engagement detection
RECONDO_SAAA_ENGAGE_HOLD    = 15;    // s: a self-decided shot marks the gun engaging this long
RECONDO_SAAA_ENGAGE_GRACE   = 10;    // s guaranteed vanilla-engagement window after handoff
RECONDO_SAAA_LOST_KNOWS     = 1.0;   // knowledge decay floor before leaving ENGAGING
RECONDO_SAAA_REVEAL_VALUE   = 1.5;   // reveal accuracy while tracking by sound
RECONDO_SAAA_BF_EXIT_FACTOR = 1.15;  // blind-fire range exit hysteresis
RECONDO_SAAA_VIS_THRESHOLD  = 0.3;   // checkVisibility >= this counts as "crew can see it"
RECONDO_SAAA_ALIGN_TOL      = 2;     // deg barrel-on-solution tolerance before firing clean
RECONDO_SAAA_ALIGN_TIMEOUT  = 6;     // s alignment wait; within 3x tolerance fires rushed
RECONDO_SAAA_SPEED_FACTOR   = 0.6;   // drag-averaged shell speed factor for lead
RECONDO_SAAA_AIMED_DELAY    = 4;     // s the vanilla AI gets first refusal on a visible target
RECONDO_SAAA_WILLING_FACTOR = 0.55;  // fraction of AI max fire-mode range where it will fight
RECONDO_SAAA_TICK_INTERVAL  = 1;     // s between main loop ticks
RECONDO_SAAA_SCAN_EVERY     = 10;    // rescan for guns every N ticks (catches spawns)

// ========================================
// STATE
// ========================================

RECONDO_SAAA_GUNS         = [];
RECONDO_SAAA_DBG_MARKERS  = [];
RECONDO_SAAA_CLASS_CACHE  = createHashMap;  // typeOf gun -> 0/1 managed verdict
RECONDO_SAAA_AIR_CACHE    = createHashMap;  // typeOf air -> "HELO" / "PROP" / "NONE"
RECONDO_SAAA_ELEV_CACHE   = createHashMap;  // typeOf gun -> [minElev, maxElev]
RECONDO_SAAA_BALL_CACHE   = createHashMap;  // typeOf gun -> shell typicalSpeed
RECONDO_SAAA_RANGE_CACHE  = createHashMap;  // typeOf gun -> engine AI max fire-mode range
RECONDO_SAAA_SCAN_COUNTER = RECONDO_SAAA_SCAN_EVERY;  // force a gun scan on the first tick

// ========================================
// MAIN LOOP
// ========================================

RECONDO_SAAA_PFH = [{ call Recondo_fnc_saaaMainTick }, RECONDO_SAAA_TICK_INTERVAL, []] call CBA_fnc_addPerFrameHandler;

// ========================================
// FINAL LOG
// ========================================

diag_log format ["[RECONDO_SAAA] Module initialized. Blindfire: %1 (%2m), Aimed fire: %3 (%4m), Helos: %5, Planes: %6, Gun whitelist: %7",
    _blindfire, _blindfireRange, _aimedFire, _aimedRange, _fireHelos, _firePlanes,
    count RECONDO_SAAA_GUN_WHITELIST];
