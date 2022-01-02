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
    ["Open", true] call BIS_fnc_garage;
};

private _fnc_onGarageOpened = {
    // --- Adds button to deploy vehicle
    private _display = uinamespace getvariable "RscDisplayGarage";
    private _ctrlBg = _display ctrlCreate ["RscStructuredText", -1];
    private _ctrlLabelClass = _display ctrlCreate ["RscStructuredText", -1];
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

    _ctrlLabelClass ctrlSetPosition  [0.1875 + 0.005,0.7 + 0.005,0.6 - 0.007,0.285];

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
        _ctrlBg, _ctrlBtnSave, _ctrlBtnExportConfig, _ctrlBtnExportScript
    ];

    // Store controls
    SELF set ["Dialog", createHashMapFromArray [
        ["LabelClass", _ctrlLabelClass],
        ["LabelOffroad", _ctrlLabelOffroad],
        ["LabelSuspension", _ctrlLabelSuspension],
        ["SliderOffroad", _ctrlSliderOffroad],
        ["SliderSuspension", _ctrlSliderSuspension]
    ]];

    // On vehicle change event handler
    SELF set ["SelectedVehicle", objNull];
    SELF set ["VehicleChangePFH",
        [{
            if (self_GET("SelectedVehicle") == BIS_fnc_arsenal_center) exitWith {};
            SELF set ["SelectedVehicle", BIS_fnc_arsenal_center];
            [] call self_FUNC(Dialog_Update);
        }] call CBA_fnc_addPerFramehandler
    ];
};

private _fnc_onGarageClosed = {
    [self_GET("VehicleChangePFH")] call CBA_fnc_removePerFrameHandler;
};

private _fnc_updateDialog = {
    systemChat "[Updated]";
    private _vehicleClass = typeOf BIS_fnc_arsenal_center;
    private _title = [_vehicleClass] call self_FUNC(Dialog_FormatTitle);
    ([BIS_fnc_arsenal_center] call FUNC(getOffroadCapabilities)) params ["_offroadCoef", "_suspensionCoef"];

    private _ctrlLabelClass = self_GET("Dialog") get "LabelClass";
    _ctrlLabelClass ctrlSetStructuredText _title;
    _ctrlLabelClass ctrlCommit 0;

    (self_GET("Dialog") get "SliderOffroad") sliderSetPosition _offroadCoef;
    (self_GET("Dialog") get "SliderSuspension") sliderSetPosition _suspensionCoef;
    [] call self_FUNC(Dialog_onSliderUpdate);
};

private _fnc_onDialogSliderUpdate = {
    systemChat "OnSliderUpdate!";
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

private _fnc_formatDialogTitle = {
    params ["_class"];
    private _name = [configFile >> "CfgVehicles" >> _class] call BIS_fnc_displayName;

    parseText format [
        "<t size='1.2' color='#3277a8' align='left'>%1</t> <t size='1' color='#879199' align='right'>%2</t>",
        _name,
        _class
    ]
};

private _fnc_formatDialogCoefs = {
    params ["_offroad", "_suspension"];
    [
        parseText format ["<t align='left'>Offroad</t><t align='right'>%1</t>", _offroad],
        parseText format ["<t align='left'>Suspension</t><t align='right'>%1</t>", _suspension]
    ]
};

private _fnc_onDialogSave = {
    private _class = typeOf BIS_fnc_arsenal_center;
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

    ["fnc_Dialog_Update", _fnc_updateDialog],
    ["fnc_Dialog_FormatTitle", _fnc_formatDialogTitle],
    ["fnc_Dialog_FormatCoefs", _fnc_formatDialogCoefs],
    ["fnc_Dialog_onSliderUpdate", _fnc_onDialogSliderUpdate],
    ["fnc_Dialog_onSave", _fnc_onDialogSave],
    ["fnc_Dialog_onExportConfig", _fnc_onDialogExportConfig],
    ["fnc_Dialog_onExportScript", _fnc_onDialogExportScript]
];

systemChat "[Helper Initialized]";

// First time launch
[] spawn self_FUNC(Show);
