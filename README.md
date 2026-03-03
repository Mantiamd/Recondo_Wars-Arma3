# Recondo Wars - Arma 3 Mod

A comprehensive Arma 3 mod designed for SOG Prairie Fire operations, providing Eden Editor modules for mission makers to create immersive reconnaissance and special operations missions.

## Features

### AI Systems
- **AI Tweaks** - Configure AI skill levels, behavior, equipment removal, and mine knowledge per side (supports multiple instances for different sides)
- **Player Options** - Configure player-specific settings and restrictions
- **Foot Patrols** - Spawn randomized foot patrol groups with configurable routes
- **Path Patrols** - Create patrols that follow specific marker paths
- **Add AI Crew** - Dynamically add crew members to player vehicles
- **Static Defense Randomized** - Spawn randomized static weapon positions
- **Eldest Son** - Sabotaged ammunition system that poisons enemy weapons over time
- **Bad Civi** - Sync to AI units to create concealed-weapon civilians that pull a weapon when a configured side gets close, with configurable chance, distance, and weapon type
- **Limit Static Weapon Movement** - Restrict ACE carry/drag on static weapons

### Mission Objectives
- **Objective Destroy** - Destructible target objectives with composition support
- **Objective HVT** - High-Value Target capture/kill objectives with custom profiles, optional Bad Civi spawns at real HVT locations, wandering civilians, and roving sentries
- **Objective Hostages** - Hostage rescue objectives with AI guards, optional Bad Civi spawns at real hostage locations, and wandering civilians
- **Objective Jammer** - Radio jammer objectives that affect communications
- **Objective Hub & Subs** - Connected hub and sub-site objective systems
- **POO Site Hunt** - Randomized Point-of-Origin artillery hunt with configurable marker pools, proximity-triggered spawning, persistent destruction tracking, and terrain clearing

### Intel & Reconnaissance
- **Intel System** - Collectible intelligence items from enemies and locations
- **Intel Items** - Configure custom intel item classnames
- **Intel Board** - Visual tracking board for collected intelligence
- **Recon Points** - Award points for reconnaissance activities
- **Sensors** - Deployable ground sensors for foot/vehicle detection with persistent logging
- **Wiretap** - Telephone pole wiretapping system

### Radio & Communications
- **RW Radio** - Radio transmission system with battery management and triangulation
- **Trackers** - Enemy tracker teams with dogs that follow player footprints
- **Reinforcement Waves** - Dynamic enemy reinforcement spawning

### Extraction & Movement
- **STABO Extraction** - Helicopter extraction via STABO rig with body/casualty attachment
- **Outpost Teleport** - Base-to-outpost teleportation with optional destroyable outposts and compositions
- **Deployable Rally Point** - Player-deployable rally points with ACE interactions
- **JIP Area** - Join-In-Progress spawn areas

### Environment & Ambiance
- **Weather Control** - Dynamic weather and time control
- **Ambient Sound** - Configurable ambient sound zones
- **Civilians Working** - Working civilians in fields and villages
- **Civilian Traffic** - Ambient civilian vehicle traffic
- **Civilian POL** - Persistent civilian pattern-of-life system
- **Custom Site Spawn** - Spawn custom compositions at markers with garrison AI, patrols, and night lighting
- **Camps Random** - Randomized camp placement with composition support
- **Destroy Powergrid** - Sync to a world object to turn off or destroy all lights within a configurable radius via ACE interaction or object destruction, with optional persistence

### Utility Modules
- **Persistence** - Save/load mission state across sessions with campaign ID support
- **Intro Screen** - Mission introduction screens
- **Terminal** - Admin terminal for mission control and persistence reset
- **Arsenal Area** - Configurable arsenal access zones
- **Disable Rations Area** - Zones where ACE rations are disabled
- **Chat Control** - Control chat channel availability
- **ACE Spectator Object** - Enter spectator mode from objects
- **Convoy System** - Automated convoy spawning and routing
- **Performance Monitor** - Mission performance monitoring

## Requirements

- Arma 3 (v2.10+)
- [CBA_A3](https://steamcommunity.com/sharedfiles/filedetails/?id=450814997)
- [ACE3](https://steamcommunity.com/sharedfiles/filedetails/?id=463939057)
- [SOG Prairie Fire](https://store.steampowered.com/app/1227700/Arma_3_Creator_DLC_SOG_Prairie_Fire/) (recommended)

## Installation

1. Download or clone this repository
2. Use Arma 3 Tools to build the PBO, or copy the `addons` folder to your Arma 3 mods directory
3. Enable the mod in Arma 3 launcher

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

## Building

To build the PBO:
1. Use Arma 3 Tools - Addon Builder
2. Point to the `addons/recondo_wars` folder
3. Build to your mod output directory

## Author

**GoonSix**

## License

This project is for personal/community use. Please contact the author for redistribution permissions.
