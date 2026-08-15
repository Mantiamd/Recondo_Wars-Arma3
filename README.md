# What is Recondo Wars?

**Recondo Wars** is a modular Eden Editor framework for Arma 3 that creates persistent, replayable reconnaissance environments inspired by the MACV-SOG operations of the Vietnam War. Through a collection of custom modules, mission makers can populate an Area of Operations with randomized enemy positions, objectives, and intelligence, ensuring every mission unfolds differently.

Instead of following map markers or scripted objectives, players must locate enemy bivouacs, supply caches, POWs, high-value targets, and other objectives through reconnaissance, observation, and intelligence gathering. Wiretaps, captured enemy personnel, and recovered documents can all be turned in to headquarters, rewarding players with actionable intelligence that helps narrow the search for enemy activity.

Supporting these objectives are a variety of dynamic gameplay systems—including enemy tracking, reactive reinforcements, and other immersion mechanics—that create a living battlefield where planning, patience, and teamwork are essential. Recondo Wars is designed to recreate the uncertainty and tension of deep reconnaissance missions, where information is earned, not given.

# Recondo Wars - Arma 3 Mod

A comprehensive Arma 3 mod designed for SOG Prairie Fire operations, providing Eden Editor modules for mission makers to create immersive reconnaissance and special operations missions.

## Features

### AI Systems
- **AI Tweaks** - Configure AI skill levels, behavior, equipment removal, and mine knowledge per side (supports multiple instances for different sides). Force Walk is dynamic: units walk at a brisk pace (1.5x walk animation speed) until combat starts (shots, hits, or enemy detected), then run freely at the configured animation speed and return to walking 30 minutes after the release (deferred until the current fight ends). Headless Client safe
- **Player Options** - Configure player-specific settings and restrictions
- **Foot Patrols** - Spawn randomized foot patrol groups with configurable routes. Optional Headless Client transfer
- **Path Patrols** - Create patrols that follow specific marker paths. Configurable patrol behaviour (default SAFE); patrols automatically switch to COMBAT when they know about an enemy and resume relaxed patrolling once the contact is over. Optional Headless Client transfer
- **Add AI Crew** - Dynamically add crew members to player vehicles
- **Static Defense Randomized** - Spawn randomized static weapon positions. Optional Headless Client transfer
- **Smarter AAA** - AI anti-aircraft crews hear aircraft coming and pre-aim at the sound, fire blind through jungle canopy with computed lead, and engage high loiterers vanilla AI ignores. Manages only the static gun classnames you whitelist, editor-placed or spawned. Original script by Dexter
- **Eldest Son** - Sabotaged ammunition system that poisons enemy weapons over time
- **Bad Civi** - Sync to AI units to create concealed-weapon civilians that pull a weapon when a configured side gets close, with configurable chance, distance, and weapon type
- **Limit Static Weapon Movement** - Restrict ACE carry/drag on static weapons

### Mission Objectives
- **Objective Destroy** - Destructible target objectives with composition support (6 cache + 10 bivouac compositions). Optional custom target inventory (comma-separated classnames replace the target object's default cargo)
- **Objective HVT** - High-Value Target capture/kill objectives with custom profiles, optional Bad Civi spawns at real HVT locations, wandering civilians, and roving sentries
- **Objective Hostages** - Hostage rescue objectives with AI guards, optional Bad Civi spawns at real hostage locations, and wandering civilians
- **Objective Photographs** - Reconnaissance photography objectives using the SOG PF camera system with configurable compositions, target validation, and Intel Board integration
- **Objective Jammer** - Radio jammer objectives that affect communications
- **Objective Hub & Subs** - Connected hub and sub-site objective systems. Optional custom hub target inventory (comma-separated classnames replace the target object's default cargo)
- **POO Site Hunt** - Randomized Point-of-Origin artillery hunt with configurable marker pools, proximity-triggered spawning, persistent destruction tracking, and terrain clearing

### Intel & Reconnaissance
- **Intel System** - Collectible intelligence items from enemies and locations
- **Intel Items** - Configure custom intel item classnames
- **Intel Board** - Visual tracking board for collected intelligence
- **Recon Points** - Award points for reconnaissance activities
- **Sensors** - Deployable ground sensors for foot/vehicle detection with persistent logging
- **Wiretap** - Telephone pole wiretapping system
- **Soil Sample** - Players collect soil samples via ACE self-interaction near roads, paths, or trails. Requires a configurable item (consumed on use), gives a sample item, and integrates with the Intel Board as a turn-in objective. Supports optional marker-based area restriction with per-location grid references on the Intel Board

### Radio & Communications
- **RW Radio** - Radio transmission system with battery management and triangulation
- **Survival Radio** - Triangulation for survival/emergency ACRE radios (no battery). Any transmission longer than a threshold (default 3s) spawns a hunter group (default 200m away, random direction) that moves to the triangulated position and relentlessly follows the individual transmitter's footprints. Whistle sounds only, per-player cooldown, and a concurrent group cap. Supports no-count safe zone markers (default `NO_RADIO_` prefix, shared with RW Radio so one marker silences both systems). Coexists with RW Radio via different radio classnames
- **Trackers** - Enemy tracker teams with dogs that follow player footprints. Dogs bark ambiently when a target player is within ~300m (audio only) and bark/harass on close-range detection. Optional signal shots: trackers fire rounds skyward every X footprints reached and on re-acquiring a lost trail, so players hear the pursuit closing in
- **Reinforcement Waves** - Dynamic enemy reinforcement spawning. Optional "Release Force Walk After Spawn" checkbox exempts spawned groups from AI Tweaks Force Walk 5 seconds after spawning, so they pursue at full speed (dog-led tracking groups are not released and keep walking pace). Optional "Spawn Tracker Team" (default on) spawns a Trackers-module tracker team 150m from the target group in a random direction with Wave 1 - requires a Trackers module in the mission. Optional "Enable Radio Chatter" plays quiet Vietnamese radio chatter (40 sound variations, audible to ~150m) from groups of any wave while they are within 100m of a player - first close contact chatters immediately, then repeats on the Sound Interval, alongside the other enabled sounds
- **Wave Attack** - Marker-triggered multi-wave assaults from configurable compass bearings, with whistle audio cues on all attacking waves. Optional "Enable Radio Chatter" plays quiet Vietnamese radio chatter (40 sound variations, audible to ~150m) from attacking groups while within 100m of a player - immediately on first close contact, then on a jittered ~60s cadence, alongside the whistles. Optional Headless Client transfer
- **Near Ambush** - OPFOR AI ambushes against BLUFOR players on foot. Invisible markers with a configurable prefix are candidate sites; a configurable percentage is randomly active each mission. When a BLUFOR player on foot enters the trigger radius, an OPFOR squad spawns at a **required staging marker** (default name `STAGING`; hide it in an unused map corner, on dry land), goes prone out of sight, then teleports into a hold-fire line - either across the players' path 50m ahead or parallel to it 35m off to one side - and springs (crouch + open fire) when players walk into the kill zone or make early contact. The spring is signaled: by day a random whistle from the ambush line 1 second before the volley, by night a trip flare (default `ACE_FlareTripMineRed`, configurable) popped at the feet of the ambushed group's leader 3 seconds before - as if he just tripped it. On early contact (players hit an ambusher or land rounds near the line first) the signal and volley happen together. Sprung sites are spent; if players leave first, the ambush despawns and the site re-arms. Group composition is built from a required OPFOR classname list; without the staging marker the module spawns no AI. Optional "Automatic Rifleman Classnames": when set, every ambush group includes one unit from that list who opens the spring with 5 seconds of full auto fixed 3m above the head of the ambushed group's leader - grazing fire over the kill zone - then joins the fight
- **QRF Mounted** - Vehicle-mounted quick reaction force that spawns at the nearest road when the QRF side detects the target side. Randomly selects vehicles from a pool (configurable min/max count), fills crew and cargo, moves to the detected target, and dismounts cargo passengers at a configurable distance while drivers and gunners remain mounted
- **SOG PF Tracker Group** - Defines marker areas where OPFOR tracker-stalker teams spawn and pursue BLUFOR groups using SOG Prairie Fire's tracking system. When a BLUFOR group enters a trigger zone, their tracks become visible and a 2-man stalker team spawns to hunt them. Configurable trigger radius, tracker side, and unit classnames. Requires S.O.G. Prairie Fire DLC

### Extraction & Movement
- **STABO Extraction** - Helicopter extraction via STABO rig with body/casualty attachment
- **Outpost Teleport** - Base-to-outpost teleportation with optional destroyable outposts and compositions. Optional custom inventory for the destroyable object (comma-separated classnames replace its default cargo)
- **Deployable Rally Point** - Player-deployable rally points with ACE interactions
- **JIP Area** - Join-In-Progress spawn areas

### Environment & Ambiance
- **Weather Control** - Dynamic weather and time control
- **Ambient Sound** - Configurable ambient sound zones
- **NPC Dialog** - Sync AI units to give them an ACE "Talk to" interaction. Each use shows the player the next line of a module-defined dialog (one line per row) on an intel card; the NPC stops and faces the player while talking. Each player progresses through the dialog independently
- **Kit Carson System** - Informant NPCs (named after the Kit Carson Scouts) that reveal intel targets. Sync AI units; the configurable ACE interaction ("Ask about enemy activity") reveals one target from the campaign's active intel pool to the player's group - same weighted pick, intel card, and Intel Board log as an intel item turn-in. Optional required item (classname - money, a rifle, water...) the player must hand over, consumed on success, with a configurable demand line when they don't have it. Optional translator restriction: only configured player classnames can talk to the informant, everyone else gets a refusal line. Each informant reveals ONCE per mission start (never saved), so a server restart makes every informant available again - revisits before restart get a depleted line. All lines are configurable
- **Civilians Working** - Working civilians in fields and villages
- **Civilian Traffic** - Ambient civilian vehicle traffic on roads with optional vehicle invincibility
- **River Traffic** - Marker-driven dynamic boat patrols (civilian/OPFOR/BLUFOR) that spawn near players and follow designer-placed river paths on **any** map. Fully dedicated-server safe. See [River Traffic (Marker-Driven)](#river-traffic-marker-driven)
- **Civilian POL** - Persistent civilian pattern-of-life system
- **Custom Site Spawn** - Spawn custom compositions at markers with garrison AI, patrols, and night lighting
- **Camps Random** - Randomized camp placement with composition support
- **Destroy Powergrid** - Sync to a world object to turn off or destroy all lights within a configurable radius via ACE interaction or object destruction, with optional persistence
- **Hanoi Hannah Loudspeakers** - Spawn propaganda loudspeakers at marker positions with configurable volume, distance, cooldown, and an ACE "Rip Out Wires" interaction that awards Recon Points. Extends the [Hanoi Hannah Loudspeakers Mod](https://steamcommunity.com/sharedfiles/filedetails/?id=3696734884) (required dependency for this module)
- **Village Uprising** - Civilians at village markers wander peacefully until a configured side enters the detection radius, then rally to a point, arm up, switch sides, and attack. Each village triggers independently. Supports multiple areas via paired village/rally markers

### Base & Outpost Management
- **Outpost System** - Defines an outpost location with multi-class supply tracking, AI garrison management, and dynamic map marker display. Class 1 (supply) drains over time and is replenished by delivering configurable objects. Class 3 (fuel) operates independently — when fuel hits 0%, a "Comms lost" state disables all outpost systems and changes the marker to red. Garrison AI are automatically detected, tracked, and tasked via LAMBS `taskGarrison`. Ammo resupply (Class 5) distributes compatible magazines from crates to garrison units. Garrison morale is tied to Class 1: when supply is above 0, garrison AI operate at "Normal" skill levels; when supply drops to 0, skills degrade to configurable "Low Morale" values. Supports QRF helicopter loading/dismounting with unit invincibility during transit. Map marker visibility is side-restricted via dropdown. All supply classes, garrison count, and fuel are persistent across mission restarts. Requires [LAMBS Danger](https://steamcommunity.com/sharedfiles/filedetails/?id=1858075458) for garrison behavior

### Utility Modules
- **Persistence** - Save/load mission state across sessions with campaign ID support
- **Player Persistence** - Save and restore player positions, directions, and full loadouts across sessions. Tracks specified playable units by Eden variable name with configurable restore delay. Saves immediately on disconnect. Resets saved position on respawn so players return to their default spawn
- **Vehicle Persistence** - Save and restore synchronized vehicle positions across sessions. Destroyed vehicles are removed on load
- **Inventory Persistence** - Save and restore full cargo contents (weapons, magazines, items, backpacks) of synchronized containers and vehicles across sessions
- **Terminal** - Admin terminal for mission control and persistence reset
- **Arsenal Area** - Configurable arsenal access zones with optional litter cleanup (dropped gear and player corpses removed every 10 minutes)
- **Disable Rations Area** - Zones where ACE rations are disabled
- **Chat Control** - Control chat channel availability
- **ACE Spectator Object** - Enter spectator mode from objects
- **Spectator Cam** - Dead (and optionally ACE-unconscious) players automatically enter the End Game Spectator camera after a configurable delay. Closes automatically on respawn or revive. Affects all players, no sync needed. Optionally sync objects to the module: living players get an ACE action on them to open the camera, closed with Esc. Camera options (spectatable sides, AI viewing, free camera, 3rd person) are configurable separately for the death cam and the object cam; defaults are the locked-down anti-scouting view (own side only, players only, follow cam, first person)
- **OPFOR Side Markers** - Marks active AI-occupied positions (Objective Destroy/Hub & Subs/Jammer/HVT/Hostages/Photographs sites, static defenses, outposts, camps, POO sites, custom sites) on the map, visible ONLY to players of the chosen viewing side (default OPFOR). Lets a small OPFOR player element know where their AI allies are without revealing anything to BLUFOR. Each system is toggled by checkbox; marker color, icon, and labels are configurable. Markers appear as sites become active (late spawns included) and remain until mission restart. HVT/hostage decoy sites share the real site's label so the true objective is not leaked. Place once per mission
- **Convoy System** - Automated convoy spawning and routing
- **Performance Monitor** - Mission performance monitoring
- **Roleplay SOF Source** - Grants synced playable units ACE self-actions for viewing objective status, player statistics, and mission-maker-defined roleplayer instructions. Supports an "Allow All Players" mode that places interactions on a synced world object. Includes a "Populate Nearby with Civilian Presence" self-action for roleplayers to spawn wandering civilians with configurable classnames, count, radius, cooldown, and auto-despawn. Roleplayers can be defined by syncing units or by unit classname
- **OPORD Generator** - Generates an AI-ready prompt for OPORD creation by automatically collecting data from all placed objective and mission modules. Exports a structured prompt for copy-paste into an AI assistant (e.g., ChatGPT). Configurable operation context, ROE, phases, support assets, and more. Optionally loads an imported OPORD from a mission-folder SQF file for in-game display to players
## Requirements

- Arma 3 (v2.10+)
- [CBA_A3](https://steamcommunity.com/sharedfiles/filedetails/?id=450814997)
- [ACE3](https://steamcommunity.com/sharedfiles/filedetails/?id=463939057)
- [SOG Prairie Fire](https://store.steampowered.com/app/1227700/Arma_3_Creator_DLC_SOG_Prairie_Fire/) (recommended)
- [LAMBS Danger](https://steamcommunity.com/sharedfiles/filedetails/?id=1858075458) (required for Outpost System module)
- [Hanoi Hannah Loudspeakers Mod](https://steamcommunity.com/sharedfiles/filedetails/?id=3696734884) (required for Hanoi Hannah module only)

## Installation

1. Download or clone this repository
2. Use Arma 3 Tools to build the PBO, or copy the `addons` folder to your Arma 3 mods directory
3. Enable the mod in Arma 3 launcher

## Persistence Data Storage

Persistence data (Persistence, Player Persistence, Vehicle Persistence, Inventory Persistence, and other modules with save/load support) is stored using Arma 3's `missionProfileNamespace` and written to disk via `saveMissionProfileNamespace`.

- **Dedicated server**: Data is saved in the server's profile directory, typically `Users\<user>\Documents\Arma 3 - Other Profiles\<serverProfile>\vars.Arma3Profile` (or wherever the `-profiles` startup parameter points)
- **Local/hosted**: Data is saved in your Arma 3 player profile directory
- Data is tied to the **mission filename** — renaming the mission file will effectively reset all persistence
- Use the **Terminal** module's "Reset All Persistence" action to clear saved data without changing the mission file

## Documentation

- **[Quick Start Guide](docs/QUICK_START.md)** - Step-by-step guide to setting up your first mission
- All module attributes have detailed tooltips with examples visible in Eden Editor
- Enable **Master Debug** on the Terminal module to turn on debug logging for all systems at once
- On mission start, any configuration issues (like missing markers) will be displayed via system chat

## Usage

All features are accessed through **Eden Editor modules**:

1. Open Eden Editor
2. Place modules from the organized categories: **RW - Main**, **RW - Objectives**, **RW - Misc**, and **RW - Tools**
3. Each module has a distinct icon for quick visual identification
4. Configure module attributes in the module's properties
5. Some modules require synchronization with objects or units
6. Hover over any attribute to see its tooltip with description and examples

## Custom Compositions

Several modules let you spawn your own custom composition (a saved arrangement of objects) instead of, or in addition to, the built-in ones. The composition is **pasted directly into the module** in Eden Editor — there is no need to ship a separate `.sqe` file with the mission.

Modules with a custom-composition paste box:

- Objective Destroy *(+ optional destroyed variant)*
- Objective Hub & Sub-Sites *(+ optional destroyed variant)*
- Objective Jammer *(+ optional destroyed variant)*
- Objective HVT
- Objective Hostages
- Objective Photographs
- Camps Random
- Outpost Teleport
- Custom Site Spawn

### How to create a composition

The mod uses Bohemia's built-in [`BIS_fnc_objectsGrabber`](https://community.bistudio.com/wiki/BIS_fnc_objectsGrabber) to turn placed objects into pasteable text.

1. In the Eden Editor (or in-game with the debug console available), **build your composition** out of map objects — buildings, walls, props, etc.
2. Place your player/character at the **centre** of the composition. Everything is captured relative to this point, so it becomes the module's anchor/spawn position.
3. Open the **debug console** (Esc → Debug Console) and run:

```sqf
[getPos player, 25, true] call BIS_fnc_objectsGrabber;
```

   - `25` is the grab radius in metres — increase it for larger compositions.
   - `true` captures object pitch/bank (orientation). Leave it as `true` for sloped or angled props.
   - The result is **automatically copied to your clipboard**.

4. Open the module, tick **CUSTOM – Enable Custom Composition**, and **paste** the clipboard text into the **CUSTOM – Composition** (or **Active Composition**) box.
5. For modules with a destroyed variant (Objective Destroy, Hub & Sub-Sites, Objective Jammer), repeat the grab for the wrecked/destroyed version and paste it into the **CUSTOM – Destroyed Composition** box. Leave it empty to spawn nothing after destruction.

### Notes

- The clipboard text may begin with a short `/* Grab data: ... */` header above the array. It is harmless (SQF ignores comments), but you can delete it so the text starts at `[` if you prefer a clean entry.
- The expected format is an array of `[classname, [relX, relY, relZ], dir]` entries — exactly what the grabber produces.
- Compositions are spawned at the module/marker position with the anchor point you chose in step 2 as their centre.
- Only the small reference to *which* composition spawned is persisted. The pasted text itself is re-read from the module on each mission load, so editing the box and reloading updates the composition.

## River Traffic (Marker-Driven)

The **River Traffic** module spawns dynamic boat patrols along rivers you define with **invisible map markers**, so it works on any map with no per-map code. Place the module anywhere; it reads the markers at mission start (JIP and save/load safe, dedicated-server safe).

### Marker naming contract

Name each marker:

```
<prefix><riverId>_<NNN>
```

- `<prefix>` — the module's **Marker Prefix** setting (default `river_`). Only markers starting with this prefix are read by that module instance, so you can run several River Traffic modules over different marker sets by giving each a unique prefix.
- `<NNN>` — a zero-padded sequence index of **at least 3 digits** (`001`, `002`, ...). The markers form the river's path from `001` to the highest number.
- `<riverId>` — any token identifying one river. All markers sharing the same `<riverId>` (under the same prefix) form one river.
- **Travel direction:** each boat spawns at a **random end** of the river (50/50) and runs straight through to the other end, then despawns. So a boat may travel `001 → highest` or `highest → 001`. Live boats always complete their full route regardless of player positions; only derelicts (wrecks, dead crews, beached-and-abandoned boats) are cleaned up by distance (**Wreck Cleanup Distance**, once no player is within it).
- Optional `<riverId>` prefix:
  - `big…` — a **big** river. The side's *Big-River Boat Classnames* are added to the spawn pool so larger boats can appear (e.g. `river_big00_012`).

### Rules & tips

- **Minimum 3 markers per river.** Rivers with fewer markers are skipped (a warning is logged with the `riverId`). Marker count doesn't limit river length — a 3-marker river can be kilometers long.
- **Place markers over water.** Markers do not create water — a marker over land will beach boats.
- **Spacing controls smoothness.** Put markers ~20–40 m apart on curves and space them out on straights. Make rivers well over ~550 m long so boats spawn off-screen.
- **Make them invisible:** set each marker's **Alpha to 0** in Eden (marker attributes). The builder reads markers regardless of alpha, so they stay hidden in-game with no scripting.

### Module settings (all in Eden)

- **Marker Prefix** — the marker name prefix this instance reads (default `river_`). Use a unique prefix per module to manage separate river sets.
- Spawn chances per side (Civilian / OPFOR / BLUFOR), max concurrent boats, boat speed.
- **Zone Radius** (which rivers/markers belong to this module) and **Activation Distance** — boats spawn only while a player is within Activation Distance of the **module's placement position**. Plus minimum spawn distance from players (so a boat won't pop in on a player standing at a river end) and an activation height limit (so aircraft overhead don't trigger spawns).
- Boat and crew classnames per side, plus **Big-River Boat Classnames** per side (used only on `big…` rivers).
- **Headgear Override** (Civilian / OPFOR, on by default) — replaces each spawned crew member's headgear with a random entry from a per-side headgear classname list (default conical hats + VC headwear). BLUFOR crew are unaffected.
- **Clear Bank Vegetation** (checkbox) + **Vegetation Clear Radius** — hides trees/bushes along a river's marker path the first time a boat spawns on it, so boats don't snag.

## Building

The mod ships as **two PBOs**, so build each one with Arma 3 Tools - Addon Builder into the same mod output directory:

1. **Core PBO** — point Addon Builder at the `addons/recondo_wars` folder and build.
2. **Objects PBO** — point Addon Builder at the `addons/rw_objects` folder and build (this packages the RW inventory objects: death cards, Eldest Son rounds, film rolls, intel items, PRC-77 batteries, etc.).

`addons/rw_objects` carries its own `$PBOPREFIX$` (`rw_objects`). Recondo Wars declares a hard dependency on `rw_objects`, so both PBOs must be present and `rw_objects` loads first.

## FAQ

**Q: Where is persistence data saved on a dedicated server?**
Persistence data is stored in the server's profile directory using `missionProfileNamespace`. The file is typically located at `<serverProfile>\vars.Arma3Profile`, where `<serverProfile>` is the path set by the `-profiles` startup parameter. See the [Persistence Data Storage](#persistence-data-storage) section above for full details.

**Q: How do I reset persistence data?**
There are two ways:
1. **In-game**: Use the Terminal module's ACE interaction and select "Reset All Persistence." This clears all saved data for every persistence system (mission state, player positions, vehicle positions, and container inventories).
2. **Manually**: Rename or delete the mission file. Since persistence data is tied to the mission filename, a new name starts fresh.

**Q: Which modules require mods beyond CBA and ACE?**
| Module | Required Mod | Notes |
|--------|-------------|-------|
| Hanoi Hannah Loudspeakers | [Hanoi Hannah Loudspeakers Mod](https://steamcommunity.com/sharedfiles/filedetails/?id=3696734884) | Hard dependency — module will not function without it |
| RW Radio | [ACRE2](https://steamcommunity.com/sharedfiles/filedetails/?id=751965892) | Hard dependency — radio system built on ACRE2 |
| Survival Radio | [ACRE2](https://steamcommunity.com/sharedfiles/filedetails/?id=751965892) | Hard dependency — transmission detection built on ACRE2 |
| AI Tweaks | [LAMBS Danger](https://steamcommunity.com/sharedfiles/filedetails/?id=1858075458) | Soft dependency — LAMBS features only apply if loaded |
| Outpost System | [LAMBS Danger](https://steamcommunity.com/sharedfiles/filedetails/?id=1858075458) | Hard dependency — garrison AI uses `lambs_wp_fnc_taskGarrison` |
| POO Site Hunt | [SOG Prairie Fire](https://store.steampowered.com/app/1227700/Arma_3_Creator_DLC_SOG_Prairie_Fire/) | Default classnames are SOG assets; replace in module attributes if not using SOG |
| Objective HVT / Hostages | [SOG Prairie Fire](https://store.steampowered.com/app/1227700/Arma_3_Creator_DLC_SOG_Prairie_Fire/) | Default compositions use SOG assets; fully configurable via module attributes |
| SOG PF Tracker Group | [SOG Prairie Fire](https://store.steampowered.com/app/1227700/Arma_3_Creator_DLC_SOG_Prairie_Fire/) | Hard dependency — uses SOG PF tracking functions |

All other modules work with only CBA and ACE.

**Q: My module isn't doing anything and there are no errors in the RPT.**
Common causes:
- **Missing sync**: Modules like Vehicle Persistence, Inventory Persistence, Terminal, and Convoy require objects to be **synchronized** (synced) to them in Eden Editor. Without synced objects, the module has nothing to act on.
- **Empty attribute fields**: Required fields like vehicle classnames, unit classnames, or marker prefixes left blank will silently disable the module.
- **Marker naming**: Modules that use markers (Convoy, Village Uprising, Path Patrols, etc.) require exact marker name formatting. Check the module tooltip for the expected naming convention (e.g., `CONVOY_1_1`, `CONVOY_1_2`, not `CONVOY1`).
- **Enable debug logging**: Check the module's Debug Logging checkbox, or enable **Master Debug** on the Terminal module to turn on logging for all modules at once. Then review the RPT for diagnostic messages.

**Q: Does this work on a dedicated server?**
Yes. All modules are designed for dedicated server use. AI logic runs on the server where the AI is local. Client-side features (ACE interactions, UI elements) are distributed via `remoteExec`. Persistence saves on the server and restores on reconnect/JIP.

**Q: Is there Headless Client support?**
Selected modules can offload their AI to a Headless Client: **Foot Patrols**, **Path Patrols**, **Wave Attack**, and **Static Defense Randomized** each have an "Enable Headless Client Transfer" checkbox. When enabled, newly spawned groups are handed to the least-loaded connected HC; if no HC is connected, they stay on the server as normal. A background sweep (every 30s) re-transfers eligible groups, so an HC that connects late or reconnects after a crash automatically picks the AI back up. Requirements:
- HC IP whitelisted in `server.cfg` (`headlessClients[]`, and `localClient[]` if on the same machine).
- A **Virtual Entity > Headless Client** slot placed in the mission.
- The HC launched with the same mods as the server (`-client -connect=...`).

Other modules intentionally keep their AI on the server — their behavior (trackers, hunters, objectives, QRF) is driven by server-side scripts and event handlers that do not survive a locality transfer. If you use ACE's `acex_headless` auto-distribution instead, be aware it will transfer *all* non-blacklisted AI, including groups from those systems, and can break them.

Note: when the **Smarter AAA** module is active, crews of whitelisted static guns are automatically kept on the server (the HC transfer helper refuses them) — the system steers those gunners with commands that require server locality. All other groups transfer normally.

**Q: How do I control which guns Smarter AAA manages?**
Place one module (RW - Main) and fill in the **Gun Whitelist** attribute (required) with the static weapon classnames that should use the system — any gun not on the list stays fully vanilla. Matching is inheritance-aware (a base class covers its variants) and applies to guns whether editor-placed or spawned by other modules (Static Defense Randomized, Custom Site Spawn, etc.). You can also set variables on individual guns (editor init field or composition, any time):
- `this setVariable ["RECONDO_SAAA_ignore", true];` — fully vanilla (good for A/B comparison)
- `this setVariable ["RECONDO_SAAA_noScriptFire", true];` — tracks and pre-aims, never script-fires
- `this setVariable ["RECONDO_SAAA_noBlindfire", true];` — no through-canopy fire only
- `this setVariable ["RECONDO_SAAA_manage", true];` — force-manage a specific gun without whitelisting its classname

Guns with low elevation limits (e.g. DShK tripods, 20-35°) physically cannot engage steep overhead targets — high-angle guns (ZGU-1, ZPU-4) are the real overhead threats. Jets are ignored entirely (they arrive faster than their sound).

**Q: Can I place multiple instances of the same module?**
Many modules support multiple instances:
- AI Tweaks (one per side), Foot Patrols, Path Patrols
- Objective Destroy, HVT, Hostages, Jammer, Photographs, Hub & Subs
- Camps Random, Custom Site Spawn, Bad Civi, POO Site Hunt
- Reinforcement Waves, QRF Mounted, SOG PF Tracker Group
- Ambient Sound, Civilians Working, Village Uprising, Hanoi Hannah
- Soil Sample, Destroy Powergrid, Outpost System

Single-instance modules (place only one):
- Terminal, Persistence, Player Persistence, Vehicle Persistence, Inventory Persistence
- Intel Board, Intel System, Intel Items, Recon Points
- Weather Control, Chat Control, Performance Monitor
- Convoy System, RW Radio, Survival Radio, Trackers, STABO, Sensors, OPORD Generator, Roleplay SOF Source

## Author

**GoonSix**

Want to support continued development? [Buy me a coffee or Baja Blast on Patreon!](https://patreon.com/GoonSix)

## Special Thanks

- The unnamed group of elite Arma 3 operators that have inspired so many of these modules, tested, and make playing Arma 3 enjoyable. Without them I wouldn't be taking the time to create any of this.
- **Dexter** - For the ideas and knowledge on so many of the tools used to create this, as well as bouncing ideas off of and brainstorming how to achieve things within Arma.
- **THEDUDE** - Contributing ideas for many of these modules but mostly for his contributions to the SOG PF community with his RTBF SOG Gear and Terrains. These modules were designed with the intent of using on his terrains — they truly change the way Arma plays. Huge thanks as well for creating the **RW inventory objects** (the `rw_objects` PBO) that ship with this mod, including all of the **intel items** now wired in as the default pickups and rewards across the mod — enemy maps, infiltration/death cards, officer ID cards, the ledger, journal pages, film rolls, Eldest Son rounds, PRC-77 batteries, cassettes, tin cans, and more.
- **RTBF** - Contributing a lot of ideas, feedback, and testing.
- **Moon** - Testing and troubleshooting from a mission maker's perspective using these modules within the Eden Editor.
- **Miller** - Contributing to some of the compositions used within the objective modules.

## License

This project is for personal/community use. Please contact the author for redistribution permissions.
