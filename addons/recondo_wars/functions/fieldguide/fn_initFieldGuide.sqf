/*
    Recondo_fnc_initFieldGuide
    Builds the in-game Field Guide in the map's diary/notes tabs (client-side)

    Description:
        Populates the player's map diary with a set of help sections describing the
        player-facing systems in Recondo Wars. Uses the vanilla diary system
        (createDiarySubject / createDiaryRecord), so it is entirely local to the
        player - no locality handling or remoteExec needed, and it is JIP-safe
        because postInit runs for late joiners too.

        Content is data-driven: each section is [subjectId, title, [[header, text], ...]].
        Not every system listed will be present in a given mission (features are
        mission-maker modules), so entries are written as general guidance.

    Parameters:
        None

    Returns:
        Nothing
*/

if (!hasInterface) exitWith {};

waitUntil { !isNull player };

// Guard against a double-call adding duplicate records this session.
if (missionNamespace getVariable ["RECONDO_FIELDGUIDE_DONE", false]) exitWith {};
missionNamespace setVariable ["RECONDO_FIELDGUIDE_DONE", true];

// [subjectId, title, [[entryHeader, entryText], ...]] - entries read top-to-bottom.
private _guide = [
    ["RW_Overview", "Recondo Wars Intro", [
        ["What is RW?", "What is Recondo Wars?<br/><br/>Recondo Wars is a collection of custom Eden Editor modules for Arma 3 that transforms any mission into a persistent Vietnam War reconnaissance environment inspired by the operations of MACV-SOG. Rather than following scripted objectives or map markers, players are placed into a living battlefield where enemy positions, objectives, and intelligence are dynamically generated, ensuring that no two operations play out the same.<br/><br/>Reconnaissance is the heart of the experience. Players must locate enemy bivouac sites, supply caches, high-value targets, POWs, and other strategic objectives using observation, navigation, and fieldcraft instead of relying on GPS markers or mission guidance. Success depends on gathering and exploiting intelligence through methods such as conducting wiretaps, capturing enemy personnel, recovering documents, and returning valuable intelligence to base. In return, headquarters analyzes the information and provides new leads, narrowing the search for enemy activity while preserving the uncertainty and tension of real reconnaissance operations.<br/><br/>To further immerse players, Recondo Wars features a variety of dynamic systems, including enemy tracking, intelligent reinforcement mechanics, and other custom gameplay features that create a reactive and evolving battlefield. The result is a mission framework that rewards patience, teamwork, and careful reconnaissance, recreating the clandestine nature of long-range reconnaissance missions conducted during the Vietnam War."]
    ]],
    ["RW_Intel", "Intel & Recon", [
        ["Collecting Intel", "Intel items are found in a few different ways.<br/><br/>1. Enemy battle plans, maps, ID cards, etc can be found on dead enemy units within their inventory. Collect these and turn them into the agency asset back at base.<br/><br/>2. Specific intel missions such as conducting wiretaps on NVA communication poles, or turning in photographs of photo objectives.<br/><br/>Turning in intel results in the agency supplying 4 digit grids where they believe some of these objectives may be within, allowing you to more zero in on active enemy locations."],
        ["Intel Board", "The Intel Board tracks collected intelligence and turn-in objectives. Some reveals give you a grid reference you must still locate yourself."],
        ["Recon Points", "Reconnaissance activities award Recon Points where the mission enables them."]
    ]],
    ["RW_Objectives", "Objectives", [
        ["Destroy", "Locate and destroy the target objective (often a cache or camp)."],
        ["HVT", "Capture or kill the High-Value Target. Beware wandering civilians and roving sentries near the real location."],
        ["Hostages", "Rescue the hostages, defeating their AI guards. Watch for concealed-weapon civilians."],
        ["Photographs", "Photograph the target using the SOG Prairie Fire camera, then turn the film in at the Intel Board."],
        ["Jammer", "Destroy the radio jammer to restore communications."],
        ["POO Site Hunt", "Find and destroy enemy Point-of-Origin artillery sites. Some are defended by patrols. Destroyed sites stay destroyed across restarts."],
        ["Soil Sample", "Some operations task you with recovering soil samples for analysis back at base.<br/><br/>To collect one, you must be standing near a road, path, or trail and carry the required collection item (for example an empty container). Use the <t color='#ffcc00'>ACE self-interaction</t> to take the sample: the required item is consumed and you receive a sample item in return.<br/><br/>Return the sample to the Intel Board turn-in at base to complete the objective. If the mission limits sampling to specific areas, those areas are not marked for you - use your map and terrain reading to work out likely collection sites."]
    ]],
    ["RW_Threats", "Threats", [
        ["NVA Tracker System", "NVA Trackers can often find your footprints if you move faster than an Arma walking pace. They may also have tracker dogs with them as well. Avoid these trackers by constantly changing direction, J-hook ambushes, or leaving toe poppers/tripwires to slow them down. If the trackers spot you they will often call in large numbers of reinforcements!"],
        ["Reinforcements & QRF", "Detected activity can trigger reinforcement waves and a mounted Quick Reaction Force that drives to your last known position and dismounts nearby."],
        ["Radio & Triangulation System", "The RW Radio system adds the need to change radio batteries (found in the arsenal) while also adding two ways player elements' communications can be triangulated.<br/><br/>1. The element RTO transmits too much radio traffic which results in an AI team moving to and searching that area.<br/><br/>2. Too much radio traffic gives OPFOR players a general area marker of your location, the more this is triggered the more accurate that area is informing the opfor players."]
    ]],
    ["RW_Equipment", "Equipment Needed", [
        ["Wiretap", "Objectives that require wiretapping need a wiretap item, found in the arsenal.<br/><br/>Move to the target telephone/communication pole and use the <t color='#ffcc00'>ACE interaction</t> to place the wiretap. Wait roughly 10 minutes for it to record, then return and interact with the pole again to retrieve it.<br/><br/>You receive a cassette tape to turn in back at base."],
        ["Photograph Objectives", "Photo objectives require the SOG camera.<br/><br/>When you successfully photograph an objective you will get a confirmation, and a film item will be added to your inventory. Turn the film in back at base."],
        ["Destroy Objectives", "Destroy objectives can be taken out with any type of demolition charge or explosive of your choosing."],
        ["Soil Samples", "Soil sampling requires an empty tin can, found in the arsenal.<br/><br/>Move to a main road and use the <t color='#ffcc00'>ACE interaction</t> to collect a sample. The empty tin can is consumed and you receive a full tin can. Turn it in back at base."]
    ]],
    ["RW_Movement", "Insert & Extract", [
        ["Transportation", "Getting to and from the objective is up to you - there are no scripted taxis.<br/><br/>Coordinate with a player pilot to insert and extract by helicopter or fixed-wing aircraft, or use boats for waterborne movement along rivers and coastline.<br/><br/>Where the mission provides it, Simplex Support Services can also be used to request transport and other support assets."]
    ]],
    ["RW_Persistence", "Persistence", [
        ["Saved Progress", "Mission progress, and where enabled your position and loadout, are saved across sessions and restored when you rejoin."],
        ["Resets", "An admin can clear saved data with the Terminal module's 'Reset All Persistence' action."]
    ]],
    ["RW_Credits", "Credits", [
        ["GoonSix", "Creator of Recondo Wars."],
        ["Dexter", "Contributing to many of the RW systems and ideas."],
        ["THEDUDE", "Contributing the custom intel objects."],
        ["Moon", "Testing of modules and composition contribution."],
        ["Miller/Gather", "Composition contribution."],
        ["The Recon Weirdos", "And all of the other recon weirdos out there that have put hundreds of hours into testing, providing feedback, and reporting bugs."]
    ]]
];

{
    _x params ["_id", "_title", "_entries"];
    player createDiarySubject [_id, _title];
    // Records prepend (newest on top), so add in reverse to keep reading order.
    private _ordered = +_entries;
    reverse _ordered;
    {
        _x params ["_header", "_text"];
        player createDiaryRecord [_id, [_header, _text]];
    } forEach _ordered;
} forEach _guide;

diag_log "[RECONDO_FIELDGUIDE] Field Guide diary entries created.";
