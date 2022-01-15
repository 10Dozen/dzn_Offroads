#include "script_component.hpp"
/*
 * Author: 10Dozen
 * Returns vehicle's offroad properties: offroad capabaility and suspension coefficient.
 *
 * Arguments:
 * 0: _vehicleClass -- vehicle class (STRING)
 * 1: _doCache -- flag to cache found result, if not cached (optional, default: true) (BOOLEAN)
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

params ["_vehicleClass", ["_doCache", true]];
LOG_1("[getOffroadCapabilities] Check for %1", _vehicleClass);

// --- Get from cache
private _capabilities = GVAR(VehicleCapabilities) get _vehicleClass;
if (!isNil "_capabilities") exitWith {
    LOG_1("[getOffroadCapabilities] Found in cache: %1", _capabilities);
    _capabilities
};

// --- Find closest parent with capabilities
private _parentClass = _vehicleClass;
while {
    _parentClass = configName (inheritsFrom (configFile >> "CfgVehicles" >> _parentClass));
    LOG_1("[getOffroadCapabilities] Searching for %1", _parentClass);
    _capabilities = GVAR(VehicleCapabilities) get _parentClass;
    _parentClass != "" && isNil "_capabilities"
} do {};

// --- If not found - assign something default
if (isNil "_capabilities") then {
    LOG("[getOffroadCapabilities] Return default [1,1]");
    _capabilities = [1, 1];
};

// --- Cache capabilities
if (_doCache) then {
    GVAR(VehicleCapabilities) set [_vehicleClass, _capabilities];
    LOG_1("[getOffroadCapabilities] Cached: %1", _capabilities);
};

_capabilities
