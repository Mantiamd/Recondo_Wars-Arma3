RW OBJECTS — INVENTORY / GROUND OBJECT PACKAGE V2
=================================================

INSTALLATION
------------
Place these files in the source addon:

rw_objects\
    config.cpp
    functions\
        fn_initPickupObject.sqf
        fn_monitorDroppedItems.sqf

Repack the rw_objects PBO.

CLASSNAME SYSTEM
----------------
Inventory item: rw_inv_*
Physical object: rw_obj_*

Example:
    rw_inv_cassette_1
    rw_obj_cassette_1

AUTOMATIC DROP CONVERSION
-------------------------
The postInit function runs on the server and checks dropped weapon holders.
When it finds an RW inventory magazine, it removes that magazine from the
holder and creates its matching rw_obj_* object at the same location.

Other cargo in the holder is preserved. If the holder becomes completely
empty, it is deleted.

This works in single-player, hosted multiplayer, and dedicated-server games.
All clients and the server must load the addon so the physical classes and
pickup actions exist everywhere.

ADDING FUTURE ITEMS
-------------------
To add another pair, create the inventory class in CfgMagazines and a physical
CfgVehicles class derived from rw_obj_base. Set rw_inventoryClass to the
inventory classname. The automatic drop monitor discovers the mapping from
config, so no mapping array needs to be edited.

Example:

class rw_obj_example: rw_obj_base
{
    scope = 2;
    scopeCurator = 2;
    displayName = "[RW] Example";
    model = "\\rw_objects\\rw_example.p3d";
    rw_inventoryClass = "rw_inv_example";
};

NOTES
-----
The monitor interval is 0.25 seconds. A standard Arma weapon holder may be
visible very briefly before being replaced by the physical object.
