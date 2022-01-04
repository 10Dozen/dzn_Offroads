#include "script_component.hpp"
/*
 * Author: 10Dozen
 * Returns True if at least 3 wheels are touching surface.
 *
 * Arguments:
 * 0: _vehicle -- vehicle (OBJECT)
 * 1: _wheels -- model space position of vehicle's wheels (ARRAY)
 *
 * Return Value:
 * _isTouching -- true, if at least 3 wheels are touching surface (BOOLEAN)
 *
 * Example:
 * _isTouching = [_vehicle, _wheels] call dzn_Offroads_main_fnc_isVehicleTouchingGround;
 *
 * Public: No
 */

params ["_vehicle", "_wheels"];

private _h = 0;
private _wheelsTouching = {
    _h = (_vehicle modelToWorld _x) # 2;
    LOG_2("[isVehicleTouchingGround] Wheel height: %1 (> 0.3 [%2])", _h, _h <= 0.3);
    _h <= 0.3
} count _wheels;

_wheelsTouching > 2
