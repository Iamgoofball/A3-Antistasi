/*
Maintainer: Caleb Serafin



    HEY YOU, READ THIS!   HEY DU, LIES DAS!
    STEP  0:    Run arma.
    STEP  1:    Make empty mp-mission with just one player.
    STEP  2:    Save and close editor.
    STEP  3:    Copy Everything in upper NavGridPP folder (includes: /Collections/; /function/; /description.ext; /functions.hpp)
    STEP  4:    Paste into the folder of the mp mission you created. Usually in `C:\Users\User\Documents\Arma 3 - Other Profiles\YOUR_USER_NAME\mpmissions\MISSION_NAME.MAP\`
    STEP  5:    Start host LAN multiplayer.
    STEP  6:    Run and join mission.
    STEP  7:    Press `Esc` on your keyboard to open debug console.
    STEP  8:    Paste `[] spawn A3A_fnc_NG_main` into big large debug window.
    STEP  9:    Click the button `Local Exec`.
    STEP 10:    Wait for hint to say `Done`&`navGridDB copied to clipboard!`
    STEP 11:    Open a new file.
    STEP 12:    Paste into the new file.
    STEP 13:    Save (Please ask the A3-Antistasi Development Team for this step).



    Technical Specifications:
    Main process that organises the creation of the navGrid.
    Calls many NavGridPP functions independently.
    Output navGRid string includes creation time and config;
    NavGridDB is copied to clipboard.

Arguments:
    <SCALAR> Max drift is how far the simplified line segment can stray from the road in metres. (Default = 50)
    <SCALAR> Junctions are only merged if within this distance from each other. (Default = 15)
    <BOOLEAN> True to start the drawing script automatically. (Default = false)

Return Value:
    <ANY> Undefined

Scope: Client, Global Arguments
Environment: Scheduled
Public: Yes

Example:
[] spawn A3A_fnc_NG_main;

    Or draw when finished and tweak parameters:
[] spawn {
    [50,15] call A3A_fnc_NG_main;
    [1,false,false,0.8,1.5] call A3A_fnc_NG_main_draw;
};

    To avoid regenerating the nev grid for drawing, you can omit A3A_fnc_NG_main after running it once. Or import from clipboard if this is a new map load.
    [] spawn A3A_fnc_NG_import_clipboard;
*/

params [
    ["_flatMaxDrift",50,[ 0 ]],
    ["_juncMergeDistance",15,[ 0 ]],
    ["_autoDraw",false,[ false ]]
];

if (!canSuspend) exitWith {
    throw ["NotScheduledEnvironment","Please execute NG_main in a scheduled environment as it is a long process: `[] spawn A3A_fnc_NG_main;`."];
};
[localNamespace,"A3A_NGPP","activeProcesses","NG_main",true] call Col_fnc_nestLoc_set;

private _diag_step_main = "";
private _diag_step_sub = "";
private _fnc_diag_render = { // call _fnc_diag_render;
    [
        "Nav Grid++",
        "<t align='left'>" +
        _diag_step_main+"<br/>"+
        _diag_step_sub+"<br/>"+
        "</t>",
        true
    ] remoteExec ["A3A_fnc_customHint",0];
};

_diag_step_main = "Extracting roads";
call _fnc_diag_render;
[4,"Extracting roads","fn_NG_main"] call A3A_fnc_log;

private _halfWorldSize = worldSize/2;
private _worldCentre = [_halfWorldSize,_halfWorldSize];
private _worldMaxRadius = sqrt(0.5 * (worldSize^2));

private _allRoadObjects = nearestTerrainObjects [_worldCentre, A3A_NG_const_roadTypeEnum, _worldMaxRadius, false, true];

private _diag_step_sub = "Applying connections and distances<br/>No progress report available, due to being too relatively expensive.";
call _fnc_diag_render;

private _navRoadHM = createHashMapFromArray (_allRoadObjects apply {
    private _road = _x;
    private _connections = roadsConnectedTo [_road,true] select {getRoadInfo _x #0 in A3A_NG_const_roadTypeEnum};
    [str _road,[_road,_connections,_connections apply {_x distance2D _road}]]
});


try {
    _diag_step_main = "Fixing";
    _diag_step_sub = "One ways";
    call _fnc_diag_render;
    [4,"A3A_fnc_NG_fix_oneWays","fn_NG_main"] call A3A_fnc_log;
    [_navRoadHM] call A3A_fnc_NG_fix_oneWays;
//*
    _diag_step_sub = "Simplifying Connection Duplicates";
    call _fnc_diag_render;
    [4,"A3A_fnc_NG_simplify_conDupe","fn_NG_main"] call A3A_fnc_log;
    [_navRoadHM] call A3A_fnc_NG_simplify_conDupe;         // Some maps have duplicates even before simplification
//*/

    _diag_step_main = "Fixing";
    _diag_step_sub = "Dead Ends";
    call _fnc_diag_render;
    [4,"A3A_fnc_NG_fix_deadEnds","fn_NG_main"] call A3A_fnc_log;
    [_navRoadHM] call A3A_fnc_NG_fix_deadEnds;

    _diag_step_main = "Simplification";
    _diag_step_sub = "simplify_flat";
    call _fnc_diag_render;
    [4,"A3A_fnc_NG_simplify_flat","fn_NG_main"] call A3A_fnc_log;
    [4,"A3A_fnc_NG_simplify_flat on "+str count _navRoadHM+" road segments.","fn_NG_main"] call A3A_fnc_log;
    [_navRoadHM,_flatMaxDrift] call A3A_fnc_NG_simplify_flat;    // Gives less markers for junc to work on. (junc is far more expensive)
    [4,"A3A_fnc_NG_simplify_flat returned "+str count _navRoadHM+" road segments.","fn_NG_main"] call A3A_fnc_log;

/*
    _diag_step_sub = "Simplifying Connection Duplicates";
    call _fnc_diag_render;
    [4,"A3A_fnc_NG_simplify_conDupe","fn_NG_main"] call A3A_fnc_log;
    [_navRoadHM] call A3A_fnc_NG_simplify_conDupe;         // Some maps have duplicates even before simplification
//*/
/*
    _diag_step_main = "Fixing";
    _diag_step_sub = "One ways";
    call _fnc_diag_render;
    [4,"A3A_fnc_NG_fix_oneWays","fn_NG_main"] call A3A_fnc_log;
    [_navRoadHM] call A3A_fnc_NG_fix_oneWays;
//*/
/*
    _diag_step_main = "Check";
    _diag_step_sub = "One way check";
    call _fnc_diag_render;
    [4,"A3A_fnc_NG_check_oneWays","fn_NG_main"] call A3A_fnc_log;
    _navRoadHM = [_navRoadHM] call A3A_fnc_NG_check_oneWays;
//*/
/*
    _diag_step_main = "Check";
    _diag_step_sub = "Connected Roads Existence";
    call _fnc_diag_render;
    [4,"A3A_fnc_NG_check_conExists","fn_NG_main"] call A3A_fnc_log;
    _navRoadHM = [_navRoadHM] call A3A_fnc_NG_check_conExists;
//*/
    _diag_step_sub = "simplify_junc";
    call _fnc_diag_render;
    [4,"A3A_fnc_NG_simplify_junc","fn_NG_main"] call A3A_fnc_log;
    [4,"A3A_fnc_NG_simplify_junc on "+str count _navRoadHM+" road segments.","fn_NG_main"] call A3A_fnc_log;
    [_navRoadHM,_juncMergeDistance] call A3A_fnc_NG_simplify_junc;
    [4,"A3A_fnc_NG_simplify_junc returned "+str count _navRoadHM+" road segments.","fn_NG_main"] call A3A_fnc_log;
/*
    _diag_step_sub = "Simplifing Connection Duplicates";
    call _fnc_diag_render;
    [4,"A3A_fnc_NG_simplify_conDupe","fn_NG_main"] call A3A_fnc_log;
    _navRoadHM = [_navRoadHM] call A3A_fnc_NG_simplify_conDupe;         // Junc may cause duplicates

    _diag_step_sub = "simplify_flat";
    call _fnc_diag_render;
    [4,"A3A_fnc_NG_simplify_flat","fn_NG_main"] call A3A_fnc_log;
    [4,"A3A_fnc_NG_simplify_flat on "+str count _navRoadHM+" road segments.","fn_NG_main"] call A3A_fnc_log;
    _navRoadHM = [_navRoadHM,15] call A3A_fnc_NG_simplify_flat;    // Clean up after junc, much smaller tolerance
    [4,"A3A_fnc_NG_simplify_flat returned "+str count _navRoadHM+" road segments.","fn_NG_main"] call A3A_fnc_log;
//*/

    _diag_step_main = "Format Conversion";
    _diag_step_sub = "Converting navRoadHM to navGridHM";
    call _fnc_diag_render;
    [4,"A3A_fnc_NG_convert_navRoadHM_navGridHM","fn_NG_main"] call A3A_fnc_log;
    private _navGridHM = [_navRoadHM] call A3A_fnc_NG_convert_navRoadHM_navGridHM;

    _diag_step_sub = "Converting navGridHM to navGridDB";
    call _fnc_diag_render;
    [4,"A3A_fnc_NG_convert_navGridHM_navGridDB","fn_NG_main"] call A3A_fnc_log;
    private _navGridDB = [_navGridHM] call A3A_fnc_NG_convert_navGridHM_navGridDB;

    private _navGridDB_formatted = ("/*{""systemTimeUCT_G"":"""+(systemTimeUTC call A3A_fnc_systemTime_format_G)+""",""worldName"":"""+worldName+""",""NavGridPP_Config"":{""_flatMaxDrift"":"+str _flatMaxDrift+",""_juncMergeDistance"":"+str _juncMergeDistance+"}}*/
") + ([_navGridDB] call A3A_fnc_NG_format_navGridDB);

    [localNamespace,"A3A_NGPP","navGridDB_formatted",_navGridDB_formatted] call Col_fnc_nestLoc_set;

    _diag_step_main = "Done";
    _diag_step_sub = "navGridDB copied to clipboard!<br/><br/>If you have lost your clipboard, you can grab the navGridDB_formatted with<br/>`copyToClipboard ([localNamespace,'A3A_NGPP','navGridDB_formatted',''] call Col_fnc_nestLoc_get)`";
    call _fnc_diag_render;
    [4,"Done","fn_NG_main"] call A3A_fnc_log;
    copyToClipboard _navGridDB_formatted;
/*
    _diag_step_sub = "Unit Test Running<br/>navGridDB to navIsland";  // Serves as a self check
    call _fnc_diag_render;
    [4,"A3A_fnc_NG_convert_navGridDB_navIslands","fn_NG_main"] call A3A_fnc_log;
    _navIslands = [_navGridDB] call A3A_fnc_NG_convert_navGridDB_navIslands;
    [localNamespace,"A3A_NGPP","navIslands",_navIslands] call Col_fnc_nestLoc_set;
//*/

    [localNamespace,"A3A_NGPP","activeProcesses","NG_main",false] call Col_fnc_nestLoc_set;

    if (_autoDraw) then {
        [] call A3A_fnc_NG_main_draw;
    };
} catch {
    ["NavGrid Error",str _exception] call A3A_fnc_customHint;
    [localNamespace,"A3A_NGPP","activeProcesses","NG_main",false] call Col_fnc_nestLoc_set;
};
