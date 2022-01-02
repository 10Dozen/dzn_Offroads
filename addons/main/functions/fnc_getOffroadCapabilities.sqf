#include "script_component.hpp"
/*
 * Author: 10Dozen
 * Returns vehicle's offroad properties: offroad capabaility and suspension coefficient.
 *
 * Arguments:
 * 0: _vehicleClass -- vehicle class (STRING)
 *
 * Return Value:
 * _capabilities (ARRAY):
 *    0: Offroad coef (NUMBER)
 *    1: Suspension coef (NUMBER)
 *
 * Example:
 * _capabilities = [typeOf _vehicle] call dzn_Offroads_main_fnc_getOffroadCapabilities; // [1, 0.85]
 *
 * Public: No
 */

params ["_vehicleClass"];

// --- Get from cache
private _capabilities = GVAR(VehicleCapabilities) get _class;
if (!isNil "_capabilities") exitWith {
    _capabilities
};

// --- Find closest parent with capabilities
private _parentClass = _vehicleClass;
while {
    _parentClass = configName (inheritsFrom (configFile >> "CfgVehicles" >> _parentClass));
    _capabilities = GVAR(VehicleCapabilities) get _parentClass;
    _parentClass != "" && isNil "_capabilities"
} do {};

// --- If not found - assign something default
if (isNil "_capabilities") then {
    _capabilities = [1, 1];
};

// --- Cache capabilities
GVAR(VehicleCapabilities) set [_vehicleClass, _capabilities];

_capabilities
