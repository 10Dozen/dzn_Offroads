#include "script_component.hpp"
/*
 * Author: 10Dozen
 * Returns vehicle's data - offroad capability, suspension and wheel positions data.
 *
 * Arguments:
 * 0: _vehicle -- vehicle (OBJECT)
 *
 * Return Value:
 * 0: _offroadCapability -- offroad coef. from config or settings (NUMBER)
 * 1: _suspensionCapability -- suspension effectivness coef from config or settings (NUMBER)
 * 2: _wheelsPositions -- list of wheel positions in model space (ARRAY of Pos3d)
 * 3: _wheelsAvgHeight -- some average height of wheels while on ground (NUMBER)
 *
 * Example:
 * _vehicleData = [_vehicle] call dzn_Offroads_main_fnc_getVehicleData;
 *
 * Public: No
 */

params ["_vehicle"];

private _class = typeOf _vehicle;
private _data = GVAR(VehiclesCache) get _class;
if (!isNil "_data") exitWith {
    _data
};

LOG_1("[getVehicleData] Not found in cache. Gathering data for class %1", _class);

([_class] call FUNC(getOffroadCapabilities)) params ["_offroadCapability", "_suspensionCapability"];
([_vehicle] call FUNC(getWheelsPositions)) params ["_wheelsPositions", "_wheelsAvgHeight"];

_data = [_offroadCapability, _suspensionCapability, _wheelsPositions, _wheelsAvgHeight];

LOG_1("[getVehicleData] Caching result: %1", _data);
GVAR(VehiclesCache) set [_class, _data];

_data
