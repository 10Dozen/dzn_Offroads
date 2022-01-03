#include "script_component.hpp"
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
    ERROR_1("Wrong configuration name to update! Expected ['SURFACES', 'VEHICLES'], actual: %1", _configurationName);
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

LOG_4("Configuration to check: %1, %2, %3, %4", _cfgName, _cfgEntriesKeyFormat, _cbaSetting, _map);

/* Read from config
 * format: config >> dzn_CfgOffroadSettings >> Vehicles >> VehicleClass[] = {1.1, 0.85};
 */

private _cfg = configFile >> "dzn_CfgOffroadSettings" >> _cfgName;
private _configEntries = (configProperties [_cfg]) apply {
    private _class = configName _x;
    [format [_cfgEntriesKeyFormat, _class], getArray (_cfg >> _class)]
};

/* Read from Settings
 * format: "[""VehicleClass"", [1.1, 0.85]], ["""#GdtStratisDirt2"", [1, 2.1]]"
 */
private _customConfigsLine = _cbaSetting splitString " " joinString "";
private _entries = [];
private _entry = "";
private _startIdx = 0;
private _endIdx = 0;
LOG_5("[updateConfiguration] %1 [%2 : %3] => <%4>, Entries: %5", _customConfigsLine, _startIdx, _endIdx, _entry, _entries);

while {
    _endIdx = _customConfigsLine find "],[";
    _entry = if (_endIdx > -1) then {
        _customConfigsLine select [_startIdx, _endIdx + 1];
    } else {
        _customConfigsLine
    };
    _entries pushBack _entry;

    LOG_5("[updateConfiguration] %1 [%2 : %3] => <%4>, Entries: %5", _customConfigsLine, _startIdx, _endIdx, _entry, _entries);

    _startIdx = _endIdx + 2;
    _customConfigsLine = _customConfigsLine select [_startIdx];
    LOG_1("[updateConfiguration] Cut line to %1", _customConfigsLine);

    _endIdx > 0
} do {};

private _settingsEntries = _entries select { _x != "" } apply { call compile _x };
LOG_1("[updateConfiguration] Settings results: %1", _settingsEntries);

/* Merge entries.
 * Custom enties overwrites config.
 */
private _hashMap = createHashMapFromArray _configEntries;
_hashMap merge [createHashMapFromArray _settingsEntries, true];
LOG_3("Resulting map %1, merged by %2 and %3", _hashMap, _configEntries, _settingsEntries);

missionNamespace setVariable [_map, _hashMap];
