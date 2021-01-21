/*
Author: Caleb Serafin
    Decimates most objects.
    Vehicles should survive but be extremely damaged.
    Plays relevant audio if applicable. (Hurt sounds, car horn)
    Deletes items and cargo inventory.

Arguments:
    <OBJECT> The targeted object. Is filtered within this function.
    <BOOL> If allowed to create particles and lights. Only set to true if this used on few objects at a time.

Return Value:
    <BOOL> true if normal operation. false if something is invalid.

Scope: Where _victim is local, Local Arguments, Global Effect
Environment: Any
Public: Yes. Can be called on objects independently, might make for an "interesting" punishment.
Dependencies:
    <BOOL> hasACEMedical

Example:
    [cursorObject, true] call A3A_fnc_napalmDamage;  // Burn whatever you are looking at.
*/
params [
    ["_victim",objNull,[objNull]],
    ["_particles",false,[false]]
];
private _filename = "functions\AI\fn_napalmDamage.sqf";

if (isNull _victim) exitWith {false};  // Silent, likely for script to find some null objects somehow.

if (isNil {
    if (!alive _victim || {(_victim getVariable ["A3A_napalm_processed",0]) < serverTime} || {!isDamageAllowed _victim}) exitWith {nil};
    _victim setVariable ["A3A_napalm_processed",serverTime + 60];    // For 60 seconds they will not be processed again. I doubt this exploit could do anything meaningful with _overKill elongating the punishment to 30 sec.
    1;
}) exitWith {true};
private _overKill = 5;  // In case the the unit starts getting healed.
private _timeToLive = 6;  // Higher number causes damage to be dealt more slowly.
private _totalTicks = 12;  // Higher number gives more detail.

private _timeBetweenTicks = _timeToLive/_totalTicks;
private _damagePerTick = 1/_totalTicks;
_totalTicks = _totalTicks * _overKill;

private _fnc_init = 'params ["_victim"];';                  // params ["_victim"] No return required
private _fnc_onTick = 'params ["_victim","_tickCount"];';   // params ["_victim","_tickCount"] No return required
private _fnc_final = 'params ["_victim"];';                 // params ["_victim"] No return required

private _invalidVictim = false;
switch (true) do {
    case (_victim isKindOf "CAManBase"): {  // Man includes everything biological, even animals such as goats ect...
        _fnc_onTick = _fnc_onTick +
            'if (alive _victim && {((_timeBetweenTicks*_tickCount) mod 1) isEqualTo 0}) then {'+  // Once per second
            '    playSound3D [selectRandom A3A_injuredSounds,vehicle _victim,nil, nil, 0.8, 0.75, 50];'+  // For `vehicle _victim` see https://community.bistudio.com/wiki/playSound3D Comment Posted on November 8, 2014 - 21:48 (UTC) By Killzone kid
            '};';
        if (hasACEMedical) then {
            _fnc_onTick = _fnc_onTick +'[ _victim, 1*' + str _damagePerTick + ' , "Body", "grenade"] call ace_medical_fnc_addDamageToUnit';  // Multiplier might need to be raised for ACE.
        } else {
            _fnc_onTick = _fnc_onTick +' _victim setDamage [(damage _victim + ' + str _damagePerTick + ') min 1, true];';
        };
        if (_particles) then {
            // WIP
        };
    };
    case (_victim isKindOf "Man"): {_invalidVictim = true;};  // Goats, Sneks, butterflies, Rabbits can be blessed by Petros himself.
    case (_victim isKindOf "AllVehicles" && {_victim isClass (configFile >> "cfgVehicles" >> typeOf _victim >> "HitPoints" >> "HitHull")}): {
        // Vehicles should be damaged as much as possible but salvageable. This would give napalm a unique tactic of clearing AI from vehicles allowing them to be repaired, refuelled and requestioned.
        _fnc_onTick = _fnc_onTick +
            '_victim setDamage [((damage _victim + ' + str _damagePerTick + ') min 0.8) max (getDammage _victim), true];
            _victim setHitPointDamage [HitHull,(((_victim getHitPointDamage HitHull) + ' + str _damagePerTick + ') min 0.8) max (_victim getHitPointDamage HitHull)];'+ // Limited to avoid vehicle being destroyed. Will not decrease vehicle damage if it was initially above 80%
            '{
                _victim setHitPointDamage [_x,((_victim getHitPointDamage _x) + ' + str _damagePerTick + ') min 1];
            } forEach ' + str ((getAllHitPointsDamage _victim) - ["hithull"]) + ';

            clearMagazineCargoGlobal _victim;
            clearWeaponCargoGlobal _victim;
            clearItemCargoGlobal _victim;
            clearBackpackCargoGlobal _victim;

            private _thermalHeat = 0.75*(_tickCount/'+ str _totalTicks +') + 0.25;'+  // The vehicles shouldn't snap to cold when the napalm effect starts begin.
            '_victim setVehicleTIPars [_thermalHeat, _thermalHeat, _thermalHeat];';

        if (_victim isKindOf "Car_F") then {
            _fnc_onTick = _fnc_onTick +
            'if (alive _victim && {((' + str _timeBetweenTicks + '*_tickCount) mod 1) isEqualTo 0}) then {'+  // Once per second
            '    playSound3D ["A3\Sounds_F\weapons\horns\MRAP_02_horn_2", _victim,nil, nil, 0.8, 1, 50];
            };'
        };
    };
    case (_victim isKindOf "ReammoBox_F"): {
        _fnc_onTick = _fnc_onTick + '_victim setDamage [(damage _victim + ' + str _damagePerTick + ') min 1, true];';
        _fnc_final = _fnc_final + 'deleteVehicle _victim';
    };
    case (_victim isKindOf "WeaponHolder"): {
        _totalTicks = 0;
        _fnc_final = _fnc_final + 'deleteVehicle _victim';  // Items would be burnt to ashes.
    };
    default {_invalidVictim = true;};  // Exclude everything else. Safest & least laggy option, gameplay comes before realism.
};

[_victim,_timeBetweenTicks,_totalTicks,compile _fnc_init,compile _fnc_onTick, compile _fnc_final] spawn {
    params ["_victim", "_timeBetweenTicks" ,"_totalTicks","_fnc_init", "_fnc_onTick", "_fnc_final"];
    uiSleep (random 2); // To ensure that damage and sound is not in-sync. Makes it more chaotic.
    if (isNull _victim) exitWith {};
    [_victim] call _fnc_init;
    for "_tickCount" from 1 to _totalTicks do {
        if (isNull _victim) exitWith {};
        [_victim, _tickCount] call _fnc_onTick;
        uiSleep _timeBetweenTicks;
    };
    if (isNull _victim) exitWith {};
    [_victim] call _fnc_final;
};

true;
