/*
    Recondo_fnc_rwCheckGiveUp
    Decides whether a reinforcement group should give up a cold trail

    Description:
        A group loses contact when it is neither in combat nor near a fresh
        footprint of its target group. The time of last contact is stored on
        the group; once it has gone without contact for longer than the
        module's give-up time, this returns true and the caller deletes the
        group in place. Combat always resets the timer so groups never
        disengage mid-firefight. Server-only.

    Parameters:
        0: GROUP - The reinforcement group
        1: HASHMAP - Module settings

    Returns:
        BOOL - true if the group should give up
*/

if (!isServer) exitWith { false };

params ["_group", "_moduleSettings"];

if (isNull _group) exitWith { false };

private _giveUpTime = _moduleSettings getOrDefault ["giveUpTime", 360];

// 0 (or less) disables give-up entirely
if (_giveUpTime <= 0) exitWith { false };

private _leader = leader _group;
if (isNull _leader) exitWith { false };

// In contact if fighting, or if a footprint of the target group is nearby
private _hasContact = behaviour _leader == "COMBAT";

if (!_hasContact) then {
    private _targetGroupId = _group getVariable ["RECONDO_RW_targetGroupId", ""];
    private _leaderPos = getPos _leader;
    {
        _x params ["_fPos", "_fTime", "_fGroupId"];
        if (_fGroupId == _targetGroupId && {_leaderPos distance _fPos < 150}) exitWith {
            _hasContact = true;
        };
    } forEach RECONDO_TRACKERS_FOOTPRINTS;
};

// Contact resets the cold-trail timer
if (_hasContact) exitWith {
    _group setVariable ["RECONDO_RW_lastContactTime", time];
    false
};

// No contact - begin the timer on first miss, then measure elapsed time
private _lastContact = _group getVariable ["RECONDO_RW_lastContactTime", -1];
if (_lastContact < 0) exitWith {
    _group setVariable ["RECONDO_RW_lastContactTime", time];
    false
};

(time - _lastContact) > _giveUpTime
