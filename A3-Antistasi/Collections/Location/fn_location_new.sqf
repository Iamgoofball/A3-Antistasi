/*
Author: Caleb Serafin
    WORK IN PROGRESS
    Attempts to grab location from location pool. Otherwise it creates one on demand.
    Optionally specify it's given parents.
    Optionally specify it's 1e14 ID.

Arguments:
    <ARRAY>|<STRING> parents to location (Include own name).
    <ARRAY> 1e14 ID. If nil will auto gen. Only fill in locations are being loaded from a serialisation and the global location counter has been advanced! (default=nil).

Return Value:
    <LOCATION> *new* location; locationNull if issue.

Scope: Local return. Local arguments.
Environment: Any.
Public: Yes

Example:
    [[localNamespace,"Collections","TestBucket","NewLocation"]] call Col_fnc_location_new;
*/
#include "..\ID\ID_defines.hpp"
params [
    ["_parents",[],[ [],"" ]],
    ["_id",[],[ [] ],[2]]
];

if (_parents isEqualType []) then {
    _parents = str _parents;
};
if (_id isEqualTo []) then {isNil {
    _id = Col_mac_ID_G1e14_inc(varName,outVar)
}};
private _location = createLocation ["Invisible", [-(_id#0) / 1e6, -(_id#1) / 1e6, 0], 0, 0];
_location setText _parents;
_location;