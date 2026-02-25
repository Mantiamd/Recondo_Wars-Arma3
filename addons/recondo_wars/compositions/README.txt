RECONDO WARS - DEFAULT COMPOSITIONS
====================================

This folder contains default composition files (.sqe) that ship with the mod.
These compositions are used by the HVT and Hostages objective systems.

DEFAULT COMPOSITIONS:
---------------------
- HVTBASE_comp_1.sqe  - Basic compound layout
- HVTBASE_comp_2.sqe  - Medium compound layout
- HVTBASE_comp_3.sqe  - Large compound layout

FILE FORMAT:
------------
Composition files use the .sqe format, which is an array of object definitions:

[
    ["Classname1", [relX, relY, relZ], direction],
    ["Classname2", [relX, relY, relZ], direction],
    ...
]

- Classname: The CfgVehicles class of the object
- relX/relY/relZ: Position relative to composition center
- direction: Object rotation in degrees

CREATING CUSTOM COMPOSITIONS:
-----------------------------
1. Build your composition in Eden Editor
2. Export using a composition export script
3. Save as .sqe file in your mission's compositions folder
4. Reference in the module's Composition List attribute

USING DEFAULT VS CUSTOM:
------------------------
In the HVT/Hostages module attributes:
- "Use Default Compositions": Enable to use mod's built-in compositions
- "Composition Source": Choose Default/Custom/Both
- "Custom Composition Path": Path to your mission's composition folder
- "Composition List": Comma-separated list of .sqe filenames to use

Example Composition List:
  HVTBASE_comp_1.sqe, HVTBASE_comp_2.sqe, my_custom_camp.sqe
