/*
Author: Caleb Serafin
    Allows easy and efficient overwriting of default serialisers.
    localNamespace >> "Collections" >> "serialisation_builder" >> _uniqueID >> [...]

Arguments:
    <STRING> Unique string.

Return Value:
    <LOCATION> Serialisation builder;

Exceptions:
    ["uniqueIDAlreadyInUse",_details] If the desired uniqueIDAlreadyInUse of a new serialization builder already exists.
    ["notImplementedYet",_details] If _support_objects is true.

Scope: Local.
Environment: Scheduled, Recommended as it could add many of serialisers.
Public: Yes

Example:
    sb = ["123"] call Col_fnc_serialisation_builder;
    dsb = ["123"] call Col_fnc_deserialisation_builder;

    _a = ["hello", ["key",1], fireX, [player,resistance], 4, {hint "call me!";}];
    _as = [sb,_a] call Col_fnc_serialise;
    _a2 = [dsb,_as] call Col_fnc_deserialise;
    _a2; // ["hello",["key",1],any,[any,GUER],4,{hint "call me!";}]
*/
params [
    ["_uniqueID","",[""]],
    ["_support_objects",false,[false]]
];
if (locationNull isEqualType ([localNamespace,"Collections","serialisation_builder", _uniqueID, false] call Col_fnc_nestLoc_get)) exitWith {
    throw ["uniqueIDAlreadyInUse",["UniqueID '",_uniqueID,"' already exists for serialisation builder."] joinString ""];
};
col_anEmptyArray = [];  // required for isEqualType
private _serialisation_builder = [localNamespace,"Collections","serialisation_builder", _uniqueID,nil,nil] call Col_fnc_nestLoc_set;

{
    _serialisation_builder setVariable [_x#0,_x#1];
} forEach (call Col_fnc_serialisation_primitive_defaults);

if (_support_objects) then {
    throw ["notImplementedYet","Object serialisation is not supported yet."];
};
_serialisation_builder;
