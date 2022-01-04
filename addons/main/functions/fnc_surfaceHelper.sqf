#include "script_component.hpp"

#define SELF dzn_Offroads_SurfaceHelper

/*
 * Author: 10Dozen
 * Helper script to find, set up and export surface properties on the map.
 *
 * Arguments:
 * nothing
 *
 * Return Value:
 * nothing
 *
 * Example:
 * [] call dzn_Offroads_main_fnc_surfaceHelper;
 *
 * Public: Yes
 */

closeDialog 2;
if (!isNil QSELF) exitWith {
    [] call self_FUNC(Show);
};

#define DISPLAY_ID -1
#define GET_CTRL(X)	((findDisplay DISPLAY_ID) displayCtrl X)

// Init menu
#define DISPLAY_ID 134810
#define BUTTON_MAPSCAN 1000
#define BUTTON_MANUAL 1002
#define EDIT_MAPSCAN 1001

private _fnc_showInitMenu = {
    createDialog "dzn_Offroads_HelperInitGroup";

    GET_CTRL(EDIT_MAPSCAN) ctrlSetText "100";

    GET_CTRL(BUTTON_MAPSCAN) ctrlAddEventHandler ["ButtonClick", { ["SCAN"] call self_FUNC(startHelper)}];
    GET_CTRL(BUTTON_MANUAL) ctrlAddEventHandler ["ButtonClick", { ["MANUAL"] call self_FUNC(startHelper)}];
};

private _fnc_startHelper = {
    params ["_mode"];

    closeDialog 2;
    SELF set ["Mode", toUpper _mode];

    private _handler = scriptNull;
    if (_mode == "SCAN") exitWith {
        SELF set ["SurfacePFHEnabled", false];

        private _scanSize = parseNumber ctrlText GET_CTRL(EDIT_MAPSCAN);
        _handler = [_scanSize] spawn self_FUNC(scanMap);
        [
            { scriptDone _this },
            { [] call self_FUNC(Show) },
            _handler
        ] call CBA_fnc_waitUntilAndExecute;

        hint "Press [CTRL] + [SPACE] to open Helper menu again";
    };

    if (_mode == "MANUAL") then {
        SELF set ["SurfacePFHEnabled", true];

        if (self_GET("SurfacePFH") == -1) then {
            // Create PFH to show current surface info
            private _pfh = [{
                [] call self_FUNC(onManualModePFH)
            }] call CBA_fnc_addPerFramehandler;
            SELF set ["SurfacePFH", _pfh];
        };

        hintC "Use [CTRL] + [SPACE] to open scan current position and open Helper menu";
    };
};

private _fnc_scanMap = {
    params [["_step", 100]];

    startLoadingScreen ["Map Scanning in progress. Please, wait..."];

    private _mapSize = getNumber (configFile >> "CfgWorlds" >> worldname >> "mapsize");
    private _pos = [0,0,0];
    private _posX = 0;
    private _posY = 0;
    private _surface = "";

    private _maxPositionsPerSurface = 100;

    private _plannedPoints = _mapSize / _step;
    private _totalPointsPlanned = _plannedPoints ^ 2;
    private _progressStep = 1 / _totalPointsPlanned;
    private _progress = 0;

    for "_i" from 0 to _plannedPoints do {
        _posY = _step * _i;

        for "_j" from 0 to _plannedPoints do {
            _posX = _step * _j;
            _pos = [_posX, _posY, 0];

            [_pos, true, _maxPositionsPerSurface] call self_FUNC(scanAtPoint);

            _progress = _progress + _progressStep;
            progressLoadingScreen _progress;
        };
    };

    private _posCount = 0;
    {
        _posCount = _posCount + count(_y);
    } forEach self_GET("MapScan");

    endLoadingScreen;

    systemChat format [
        "[ Map scanned! ] %1 surfaces found at %2 positions",
        count (keys self_GET("MapScan")),
        _posCount
    ];
};

private _fnc_scanAtPoint = {
    params [["_pos", getPos player], ["_limitPositions", false], ["_limit", 100]];

    if (surfaceIsWater _pos) exitWith {};

    private _surface = surfaceType _pos;
    private _dict = self_GET("MapScan") get _surface;

    if (isNil "_dict") then {
        _dict = [];
        self_GET("MapScan") set [_surface, _dict];
    };

    if (_limitPositions && {count _dict > _limit}) exitWith {};
    _dict pushBackUnique _pos;
};

private _fnc_onKeyPress = {
    params ["_displayOrControl", "_key", "_shift", "_ctrl", "_alt"];

    if (!_ctrl) exitWith { false };
    if (_key != 57) exitWith { false };

    if self_GET("Mode" == "MANUAL") then {
        [getPos player] call self_FUNC(scanAtPoint);
    };

    [] call self_FUNC(Show);

    true
};

private _fnc_onManualModePFH = {
    if !self_GET("SurfacePFHEnabled") exitWith {};

    private _surface = surfaceType (getPos player);
    private _savedPoses = self_GET("MapScan") getOrDefault [_surface, []];
    private _props = GVAR(Surfaces) getOrDefault [_surface, [0,0,0]];
    private _isNew = _savedPoses isEqualTo [] && _props isEqualTo [0,0,0];

    SELF set ["Surface_Current", _surface];

    hintSilent parseText format [
        "<t size='1.5' color='#%1'>%2</t><br/><br/>%3<br/>-----<br/>"
        + "<t align='left'>Resistance</t><t align='right'>%4</t><br/>"
        + "<t align='left'>Sliding force</t><t align='right'>%5</t><br/>"
        + "<t align='left'>Bouncing force</t><t align='right'>%6</t>",
        ['ffffff', '6fa832'] select _isNew,
        ['Surface already added', 'New Surface!'] select _isNew,
        _surface,
        _props # 0, _props # 1, _props # 2
    ];
};

// Main menu
#define DISPLAY_ID 134811
#define LIST_POSITIONS 2201
#define DROPDOWN_SURFACES 2202
#define BUTTON_SAVE 2220
#define BUTTON_EXPORT 2221
#define BUTTON_GOTO 2222
#define BUTTON_MODE 2223
#define EDIT_RESISTANCE 2210
#define EDIT_SLIDING 2211
#define EDIT_BOUNCING 2212

private _fnc_showMenu = {
    createDialog "dzn_Offroads_HelperGroup";

    // Update list of surfaces
    private _list = GET_CTRL(DROPDOWN_SURFACES);
    (keys self_GET("MapScan")) apply { _list lbAdd _x };

    // Disable buttons
    [GET_CTRL(BUTTON_GOTO), GET_CTRL(BUTTON_SAVE)] apply { _x ctrlEnable false };

    // Add EH to buttons
    GET_CTRL(BUTTON_GOTO) ctrlAddEventHandler ["ButtonClick", { [] call self_FUNC(GoTo)}];
    GET_CTRL(BUTTON_SAVE) ctrlAddEventHandler ["ButtonClick", { [] call self_FUNC(Save)}];
    GET_CTRL(BUTTON_EXPORT) ctrlAddEventHandler ["ButtonClick", { [] call self_FUNC(Export)}];
    GET_CTRL(BUTTON_MODE) ctrlAddEventHandler ["ButtonClick", {
        closeDialog 2;
        private _mode = SELF get "Mode";
        SELF set ["Mode", ""];

        [{ [] call self_FUNC(showInitMenu) }] call CBA_fnc_execNextFrame;
    }];

    // Add EH to lists
    GET_CTRL(DROPDOWN_SURFACES) ctrlAddEventHandler ["LBSelChanged", { _this call self_FUNC(onSurfaceSelect)}];
    GET_CTRL(LIST_POSITIONS) ctrlAddEventHandler ["LBSelChanged", { _this call self_FUNC(onPositionSelect)}];

    // Restore previous selection or scanned one
    private _currentSurface = SELF getOrDefault ["Surface_Current", ""];
    private _currentSurfaceId = -1;
    if (_currentSurface != "") then {
        for "_i" from 0 to (lbSize _list) do {
            if (_currentSurface == (_list lbText _i)) exitWith {
                _currentSurfaceId = _i;
                _list lbSetCurSel _i;
                SELF set ["Surface_CurrentId", _i];
            };
        };
    };
};

private _fnc_onSurfaceSelect = {
    params ["_control", "_selectedIndex"];

    private _prevIdx = self_GET("Surface_CurrentId");

    private _surfaceName = _control lbText _selectedIndex;
    SELF set ["Surface_CurrentId", _selectedIndex];
    SELF set ["Surface_Current", _surfaceName];

    // Update positions
    private _positions = self_GET("MapScan") get _surfaceName;
    private _list = GET_CTRL(LIST_POSITIONS);
    _list lbSetCurSel -1;
    lbClear _list;
    _positions apply { _list lbAdd str _x };

    // Restore previous position (if teleport was used) selection on reopen
    private _curPositionIdx = self_GET("Position_CurrentId");
    if (_prevIdx == _selectedIndex && _curPositionIdx > -1) then {
        [{ GET_CTRL(LIST_POSITIONS) lbSetCurSel _this }, _curPositionIdx] call CBA_fnc_execNextFrame;
        GET_CTRL(BUTTON_GOTO) ctrlEnable true;
    };

    // Update parameters
    private _properties = GVAR(Surfaces) getOrDefault [_surfaceName, [0,0,0]];
    _properties params ["_resistance", "_sliding", "_bouncing"];

    GET_CTRL(EDIT_RESISTANCE) ctrlSetText str _resistance;
    GET_CTRL(EDIT_SLIDING) ctrlSetText str _sliding;
    GET_CTRL(EDIT_BOUNCING) ctrlSetText str _bouncing;

    GET_CTRL(BUTTON_SAVE) ctrlEnable true;
};

private _fnc_onPositionSelect = {
    params ["_control", "_selectedIndex"];
    SELF set ["Position_CurrentId", _selectedIndex];
    GET_CTRL(BUTTON_GOTO) ctrlEnable (_selectedIndex > -1);
};

private _fnc_save = {
    private _surface = self_GET("Surface_Current");
    if (_surface == "") exitWith {
        systemChat "[onSave] No surface selected!";
    };

    private _resistance = ctrlText GET_CTRL(EDIT_RESISTANCE);
    private _sliding = ctrlText GET_CTRL(EDIT_SLIDING);
    private _bouncing = ctrlText GET_CTRL(EDIT_BOUNCING);

    GVAR(Surfaces) set [_surface, [parseNumber _resistance, parseNumber _sliding, parseNumber _bouncing]];
    hint format ["[%1]\nSurface updated!", _surface];
};

private _fnc_export = {
    closeDialog 2;
    [{[] call self_FUNC(ShowExportMenu)}] call CBA_fnc_execNextFrame;
};

private _fnc_goTo = {
    private _idx = lbCurSel GET_CTRL(LIST_POSITIONS);
    if (_idx < 0) exitWith {
        systemChat "[goTo] No positions selected";
    };

    player allowDamage false;
    private _position = parseSimpleArray (GET_CTRL(LIST_POSITIONS) lbText _idx);
    systemChat format ["[goTo] Index: %1 @ %2", _idx, _position];
    player setPos _position;

    hint "Teleported!";
};

// Export menu
#define DISPLAY_ID 134812
#define EXPORT_AS_SQF 2901
#define EXPORT_AS_CPP 2902

private _fnc_showExportMenu = {
    createDialog "dzn_Offroads_HelperExportGroup";

    GET_CTRL(EXPORT_AS_SQF) ctrlAddEventHandler ["ButtonClick", { [] call self_FUNC(exportAsSQF) }];
    GET_CTRL(EXPORT_AS_CPP) ctrlAddEventHandler ["ButtonClick", { [] call self_FUNC(exportAsCPP) }];
};

private _fnc_exportAsSQF = {
    private _export = [];
    {
        private _srf = _x;
        _y params ["_resist", "_slide", "_bounce"];
        _export pushBack format ['["%1", [%2, %3, %4]]', _srf, _resist, _slide, _bounce];
    } forEach GVAR(Surfaces);

    private _line = _export joinString ("," + endl);

    copyToClipboard _line;
    hint format ["Copied %1 lines", count _export];
};

private _fnc_exportAsCPP = {
    private _export = [];
    {
        private _srf = _x select [1];
        _y params ["_resist", "_slide", "_bounce"];
        _export pushBack format ["%1[] = {%2, %3, %4};", _srf, _resist, _slide, _bounce];
    } forEach GVAR(Surfaces);

    private _line = _export joinString endl;

    copyToClipboard _line;
    hint format ["Copied %1 lines", count _export];
};

// Init helper objects
SELF = createHashMapFromArray [
    ["fnc_showInitMenu", _fnc_showInitMenu],
    ["fnc_onKeyPress", _fnc_onKeyPress],
    ["fnc_onManualModePFH", _fnc_onManualModePFH],
    ["fnc_startHelper", _fnc_startHelper],

    ["fnc_scanMap", _fnc_scanMap],
    ["fnc_scanAtPoint", _fnc_scanAtPoint],

    ["fnc_Show", _fnc_showMenu],
    ["fnc_Save", _fnc_save],
    ["fnc_Export", _fnc_export],
    ["fnc_GoTo", _fnc_goTo],
    ["fnc_onSurfaceSelect", _fnc_onSurfaceSelect],
    ["fnc_onPositionSelect", _fnc_onPositionSelect],
    ["fnc_ShowExportMenu", _fnc_showExportMenu],
    ["fnc_exportAsSQF", _fnc_exportAsSQF],
    ["fnc_exportAsCPP", _fnc_exportAsCPP],

    ["Surface_CurrentId", -1],
    ["Surface_Current", ""],
    ["Position_CurrentId", -1],
    ["Mode", ""],
    ["MapScan", createHashMap],
    ["SurfacePFH", -1],
    ["SurfacePFHEnabled", false]
];

// Add already known surfcaces to list
GVAR(Surfaces) apply {
    self_GET("MapScan") set [_x, []];
};

(findDisplay 46) displayAddEventHandler [
    "KeyUp",
    { _this call self_FUNC(onKeyPress) }
];

systemChat "[Surface Helper Initialized]";

// First time launch - show init menu
[] spawn self_FUNC(showInitMenu);
