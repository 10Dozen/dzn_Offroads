#include "script_component.hpp"

#define SELF             GVAR(SurfaceConfigUpdater)

/*
 * Author: 10Dozen
 * Reads properties from config and from settings, then merge them into single hash map.
 *
 * Arguments:
 * 0: _configurationName -- name of configuration to update (STRING, expected: VEHICLES, SURFACES)
 *
 * Return Value:
 * nothing
 *
 * Example:
 * ["SURFACE"] call dzn_Offroads_main_fnc_updateConfiguration;
 *
 * Public: No
 */

params ["_configurationName"];

private _configurationName = toUpper _configurationName;
if !(_configurationName in ["SURFACES", "VEHICLES"]) exitWith {
    ERR_1("Wrong configuration name to update! Expected ['SURFACES', 'VEHICLES'], actual: %1", _configurationName)
};

private _cfgName = "Surfaces";
private _cfgEntriesKeyFormat = "#%1";
private _cbaSetting = GVAR(CustomSurfaceSetup);
private _map = QGVAR(Surfaces);

if (_configurationName isEqualTo "VEHICLES") then {
    _cfgName = "Vehicles";
    _cfgEntriesKeyFormat = "%1";
    _cbaSetting = GVAR(CustomVehiclesSetup);
    _map = QGVAR(VehicleCapabilities)
};

/* Read from config
 * format: config >> dzn_CfgOffroadSettings >> Vehicles >> VehicleClass[] = {1.1, 0.85};
 */
private _cfg = configFile >> "dzn_CfgOffroadSettings" >> _cfgName;
private _configEntries = (configProperties [_cfg]) apply {
    [format [_cfgEntriesKeyFormat, _x], getArray (_cfg >> _x)]
};

/* Read from Settings
 * format: "[""VehicleClass"", [1.1, 0.85]], ["""#GdtStratisDirt2"", [1, 2.1]]"
 */
private _customConfigsLine = _cbaSetting splitString " " joinString "";
private _entries = [];
private _entry = "";
private _startIdx = 0;
private _endIdx = 0;

while {
    _endIdx = _customConfigs find "],[";
    _entry = if (_endIdx > -1) then {
        _customConfigsLine select [_startIdx, _endIdx + 1];
    } else {
        _customConfigsLine
    };
    _entries pushBack _entry;

    _startIdx = _endIdx + 2;
    _customConfigsLine = _customConfigsLine select [_startIdx];

    _endIdx > 0
} do {};

private _settingsEntries = _entries apply { call compile _x };

/* Merge entries.
 * Custom enties overwrites config.
 */
missionNamespace setVariable [
    _map,
    (createHashMapFromArray _configEntries) merge (createHashMapFromArray _settingsEntries)
];
