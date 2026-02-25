---
name: edenrules
description: Rules and guidelines for creating Eden Editor modules in the Recondo Wars mod
---

# Overview

- All Eden modules must inherit from Module_F.
- Modules execute via the function attribute.
- Modules execute on mission start, not placement time.
- Affect ONLY synchronized objects unless explicitly stated.
- Modules must be safe for JIP and save/load.

# Module Execution Priority (functionPriority)

In Arma 3 Eden modules, `functionPriority` determines execution order:
- **Lower number = Higher priority = Runs FIRST**
- **Higher number = Lower priority = Runs LATER**

## Priority Tiers

| Priority | Category | Purpose | Examples |
|----------|----------|---------|----------|
| 0 | Core/Foundation | Load saved data, initialize systems others depend on | Persistence |
| 1-4 | Infrastructure | Set global settings, configure AI behavior | AI Tweaks, Player Options |
| 5-9 | Feature Modules | Spawn entities, create triggers, consume saved data | Static Defense Randomized, Foot Patrols, Add AI Crew |
| 10+ | UI/Presentation | Visual-only, no dependencies | Spectator, cosmetic modules |

## Current Module Priorities

- `Recondo_Module_Persistence`: **0** (loads saved data first)
- `Recondo_Module_AITweaks`: **1** (configures AI settings)
- `Recondo_Module_PlayerOptions`: **1** (configures player settings)
- `Recondo_Module_StaticDefenseRandomized`: **5** (depends on persistence)
- `Recondo_Module_FootPatrols`: **5** (depends on persistence)
- `Recondo_Module_AddAICrew`: **5** (depends on persistence settings)
- `Recondo_Module_STABO`: **5** (feature module, no dependencies)

## Rules

1. **Modules that LOAD data** others depend on must have priority **0**.
2. **Modules that SET global settings** should have priority **1-4**.
3. **Modules that CONSUME data/settings** from other modules should have priority **5+**.
4. **Modules with NO dependencies** can use any priority (default to **1**).
5. When checking for persistence data, verify `!isNil "RECONDO_PERSISTENCE_SETTINGS"` before calling `Recondo_fnc_getSaveData`.
6. Always document the chosen priority and reasoning in the module's header comment.