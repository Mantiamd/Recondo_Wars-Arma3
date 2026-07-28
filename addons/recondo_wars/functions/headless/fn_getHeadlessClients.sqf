/*
    Recondo_fnc_getHeadlessClients
    Returns all connected Headless Clients

    Description:
        Finds Headless Client virtual entities that are actually occupied
        by a connected HC. An unoccupied HC slot stays local to the server,
        so filtering on locality leaves only live, usable HCs.
        Server-only.

    Parameters:
        None

    Returns:
        ARRAY - Connected HC entities (empty if none)
*/

if (!isServer) exitWith { [] };

(entities "HeadlessClient_F") select { !isNull _x && {!local _x} }
