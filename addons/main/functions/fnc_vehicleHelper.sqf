#include "script_component.hpp"

#define SELF dzn_Offroads_VehiclesHelper

/*
 * Author: 10Dozen
 * Helper script to set up and export vehicles properties.
 *
 * Arguments:
 * nothing
 *
 * Return Value:
 * nothing
 *
 * Example:
 * [] call dzn_Offroads_main_fnc_vehicleHelper;
 *
 * Public: Yes
 */
closeDialog 2;

if (!isNil QSELF) exitWith {
    [] call self_FUNC(Show);
};

private _fnc_Show = {
    BIS_fnc_garage_center = vehicle player;
    player allowDamage false;
    ["Open", true] spawn BIS_fnc_garage;
};

private _fnc_onGarageOpened = {
    // --- Adds button to deploy vehicle
    private _display = uinamespace getvariable "RscDisplayGarage";
    private _ctrlBg = _display ctrlCreate ["RscStructuredText", -1];
    _ctrlBg ctrlEnable false;

    private _ctrlListClass = _display ctrlCreate ["RscCombo", -1];

    private _ctrlLabelOffroad = _display ctrlCreate ["RscStructuredText", -1];
    private _ctrlLabelSuspension = _display ctrlCreate ["RscStructuredText", -1];
    private _ctrlSliderOffroad = _display ctrlCreate ["RscXSliderH", -1];
    private _ctrlSliderSuspension = _display ctrlCreate ["RscXSliderH", -1];

    private _ctrlBtnSave = _display ctrlCreate ["RscButtonMenu", -1];
    private _ctrlBtnExportConfig = _display ctrlCreate ["RscButtonMenu", -1];
    private _ctrlBtnExportScript = _display ctrlCreate ["RscButtonMenu", -1];

    // Labels & sliders
    _ctrlBg ctrlSetPosition [0.1875,0.7,0.6,0.285];
    _ctrlBg ctrlSetBackgroundColor [0,0,0,0.75];

    _ctrlListClass ctrlSetPosition  [0.1875 + 0.005,0.7 + 0.005,0.6 - 0.007,0.05];

    _ctrlListClass ctrlAddEventHandler ["LBSelChanged", {
        _this call self_FUNC(Dialog_onClassSelected);
     }];

    _ctrlLabelOffroad ctrlSetPosition [0.1875 + 0.005, 0.7 + 0.1, 0.17, 0.1];
    _ctrlLabelOffroad ctrlSetText "Offroad";
    _ctrlSliderOffroad ctrlSetPosition [0.1875 + 0.2, 0.7 + 0.1, 0.4, 0.05];

    _ctrlLabelSuspension ctrlSetPosition [0.1875 + 0.005, 0.7 + 0.18, 0.17, 0.1];
    _ctrlLabelSuspension ctrlSetText "Suspension";
    _ctrlSliderSuspension ctrlSetPosition [0.1875 + 0.2, 0.7 + 0.18, 0.4, 0.05];

    {
        _x sliderSetRange [0.01, 3.00];
        _x sliderSetPosition 1.00;
        _x sliderSetSpeed [0.01, 0.1, 0.01];
        _x ctrlAddEventHandler ["SliderPosChanged", { [] call self_FUNC(Dialog_onSliderUpdate) }];
        _x ctrlCommit 0;
    } forEach [_ctrlSliderOffroad, _ctrlSliderSuspension];

    // Buttons
    _ctrlBtnSave ctrlSetText "SAVE";
    _ctrlBtnSave ctrlSetPosition [0.1875,1,0.6,0.045];
    _ctrlBtnExportConfig ctrlSetText "EXPORT AS CONFIG";
    _ctrlBtnExportConfig ctrlSetPosition [0.1875,1.05,0.3,0.045];
    _ctrlBtnExportScript ctrlSetText "EXPORT AS SCRIPT";
    _ctrlBtnExportScript ctrlSetPosition [0.5,1.05,0.287,0.045];

    _ctrlBtnSave ctrlAddEventHandler ["ButtonClick", {
        [] call self_FUNC(Dialog_onSave);
    }];
    _ctrlBtnExportConfig ctrlAddEventHandler ["ButtonClick", {
        [] call self_FUNC(Dialog_onExportConfig);
    }];
    _ctrlBtnExportScript ctrlAddEventHandler ["ButtonClick", {
        [] call self_FUNC(Dialog_onExportScript);
    }];


    { _x ctrlCommit 0 } forEach [
        _ctrlBg, _ctrlListClass, _ctrlBtnSave, _ctrlBtnExportConfig, _ctrlBtnExportScript
    ];

    // Store controls
    SELF set ["Dialog", createHashMapFromArray [
        ["ListClass", _ctrlListClass],
        ["LabelOffroad", _ctrlLabelOffroad],
        ["LabelSuspension", _ctrlLabelSuspension],
        ["SliderOffroad", _ctrlSliderOffroad],
        ["SliderSuspension", _ctrlSliderSuspension]
    ]];

    // On vehicle change event handler
    SELF set ["SelectedClass", ""];
    SELF set ["LoadedVehicle", objNull];
    SELF set ["VehicleChangePFH",
        [{
            if (self_GET("LoadedVehicle") == BIS_fnc_arsenal_center) exitWith {};
            [] call self_FUNC(Dialog_onVehicleSelected);
        }] call CBA_fnc_addPerFramehandler
    ];
};

private _fnc_onGarageClosed = {
    [self_GET("VehicleChangePFH")] call CBA_fnc_removePerFrameHandler;
    player allowDamage true;
};

private _fnc_onDialogVehicleSelected = {
    private _vehicleClass = typeof BIS_fnc_arsenal_center;

    SELF set ["LoadedVehicle", BIS_fnc_arsenal_center];
    SELF set ["SelectedClass", _vehicleClass];

    // --- Get all parents of the class
    private _hierarchy = [];
    while {
        _hierarchy pushBack _vehicleClass;
        _vehicleClass = configName (inheritsFrom (configFile >> "CfgVehicles" >> _vehicleClass));
        systemChat format ["Searching for %1", _vehicleClass];

        _vehicleClass != ""
    } do {};

    // --- Fulfill list with hierarchy of classes
    private _ctrlListClass = self_GET("Dialog") get "ListClass";
    lbClear _ctrlListClass;
    {
        _ctrlListClass lbAdd ([configFile >> "CfgVehicles" >> _x] call BIS_fnc_displayName);
        _ctrlListClass lbSetData [_forEachIndex, _x];
        _ctrlListClass lbSetTextRight [_forEachIndex, _x];
        _ctrlListClass lbSetColor [_forEachIndex, [0.21, 0.68, 0.88, 1]];
        _ctrlListClass lbSetColorRight [_forEachIndex, [0.87, 0.72, 0.21, 1]];
    } forEach _hierarchy;
    _ctrlListClass lbSetCurSel 0;
};

private _fnc_onDialogClassSelected = {
    params ["_control", "_selectedIndex"];
    private _class = _control lbData _selectedIndex;
    SELF set ["SelectedClass", _class];

    // --- Update sliders for new class
    ([_class, false] call FUNC(getOffroadCapabilities)) params ["_offroadCoef", "_suspensionCoef"];
    (self_GET("Dialog") get "SliderOffroad") sliderSetPosition _offroadCoef;
    (self_GET("Dialog") get "SliderSuspension") sliderSetPosition _suspensionCoef;
    [] call self_FUNC(Dialog_onSliderUpdate);
};

private _fnc_onDialogSliderUpdate = {
    private _ctrlLabelOffroad = self_GET("Dialog") get "LabelOffroad";
    private _ctrlLabelSuspension = self_GET("Dialog") get "LabelSuspension";
    private _ctrlSliderOffroad = self_GET("Dialog") get "SliderOffroad";
    private _ctrlSliderSuspension = self_GET("Dialog") get "SliderSuspension";

    ([
        sliderPosition _ctrlSliderOffroad,
        sliderPosition _ctrlSliderSuspension
    ] call self_FUNC(Dialog_FormatCoefs)) params ["_offroadText", "_suspensionText"];
    _ctrlLabelOffroad ctrlSetStructuredText _offroadText;
    _ctrlLabelSuspension ctrlSetStructuredText _suspensionText;

    { _x ctrlCommit 0 } forEach [_ctrlLabelOffroad, _ctrlLabelSuspension];
};

private _fnc_formatDialogCoefs = {
    params ["_offroad", "_suspension"];
    [
        parseText format ["<t align='left'>Offroad</t><t align='right'>%1</t>", _offroad],
        parseText format ["<t align='left'>Suspension</t><t align='right'>%1</t>", _suspension]
    ]
};

private _fnc_onDialogSave = {
    private _class = self_GET("SelectedClass");
    private _offroadCoef = sliderPosition (self_GET("Dialog") get "SliderOffroad");
    private _suspensionCoef = sliderPosition (self_GET("Dialog") get "SliderSuspension");

    GVAR(VehicleCapabilities) set [_class, [_offroadCoef, _suspensionCoef]];

    [parseText "<t shadow='2'color='#2cb20e' align='center' font='PuristaBold' size='1.1'>Vehicle data saved!</t>", [0,.6,1,1], nil, 7, 0.2, 0] spawn BIS_fnc_textTiles;
};

private _fnc_onDialogExportConfig = {
    private _export = [];
    {
        private _class = _x;
        _y params ["_offroad", "_suspension"];
        _export pushBack format ["%1[] = {%2, %3};", _class, _offroad, _suspension];
    } forEach GVAR(VehicleCapabilities);

    private _line = _export joinString endl;

    copyToClipboard _line;
    [parseText "<t shadow='2'color='#2cb20e' align='center' font='PuristaBold' size='1.1'>Config Copied!</t>", [0,.6,1,1], nil, 7, 0.2, 0] spawn BIS_fnc_textTiles;
};

private _fnc_onDialogExportScript = {
    private _export = [];
    {
        private _class = _x;
        _y params ["_offroad", "_suspension"];
        _export pushBack format ['["%1", [%2, %3]]', _class, _offroad, _suspension];
    } forEach GVAR(VehicleCapabilities);

    private _line = _export joinString ("," + endl);

    copyToClipboard _line;
    [parseText "<t shadow='2'color='#2cb20e' align='center' font='PuristaBold' size='1.1'>Settings Copied!</t>", [0,.6,1,1], nil, 7, 0.2, 0] spawn BIS_fnc_textTiles;
};

SELF = createHashMapFromArray [
    ["fnc_Show", _fnc_Show],
    ["fnc_onGarageOpened", _fnc_onGarageOpened],
    ["fnc_onGarageClosed", _fnc_onGarageClosed],
    ["GarageOpenedEH", [missionNamespace, "garageOpened", { [] call self_FUNC(onGarageOpened) }] call BIS_fnc_addScriptedEventHandler],
    ["GarageClosedEH", [missionNamespace, "garageClosed", { [] call self_FUNC(onGarageClosed) }] call BIS_fnc_addScriptedEventHandler],

    ["fnc_Dialog_onVehicleSelected", _fnc_onDialogVehicleSelected],
    ["fnc_Dialog_FormatCoefs", _fnc_formatDialogCoefs],
    ["fnc_Dialog_onClassSelected", _fnc_onDialogClassSelected],
    ["fnc_Dialog_onSliderUpdate", _fnc_onDialogSliderUpdate],
    ["fnc_Dialog_onSave", _fnc_onDialogSave],
    ["fnc_Dialog_onExportConfig", _fnc_onDialogExportConfig],
    ["fnc_Dialog_onExportScript", _fnc_onDialogExportScript],

    ["SelectedClass", ""],
    ["LoadedVehicle", objNull],
    ["VehicleChangePFH", -1]
];

systemChat "[Vehicle Helper Initialized]";

// First time launch
[] spawn self_FUNC(Show);
