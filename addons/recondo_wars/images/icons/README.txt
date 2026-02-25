RECONDO WARS - MODULE ICONS
===========================

This folder contains icons displayed for Eden Editor modules.

Icon Specifications:
-------------------
- Format: PAA (converted from PNG)
- Size: 64x64 or 128x128 pixels recommended
- Background: Transparent recommended
- Style: Simple, recognizable silhouettes work best

Workflow:
---------
1. Create icon as PNG file (64x64 or 128x128)
2. Convert to PAA using Arma 3 Tools:
   - TexView2: Open PNG, Save As .paa
   - Or use ImageToPAA command-line tool
3. Place the .paa file in this folder
4. Reference in CfgVehicles.hpp:
   
   icon = "\recondo_wars\images\icons\icon_modulename.paa";
   picture = "\recondo_wars\images\icons\icon_modulename.paa";

Naming Convention:
-----------------
icon_[modulename].paa

Examples:
- icon_aitweaks.paa
- icon_ambientsound.paa
- icon_objectivehvt.paa
- icon_persistence.paa

Notes:
------
- Both 'icon' and 'picture' properties can use the same file
- Icons appear in Eden Editor module list and when placed
- Keep designs simple for clarity at small sizes
