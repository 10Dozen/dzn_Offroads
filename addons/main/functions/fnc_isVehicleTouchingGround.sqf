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

private ["_vehicle", "_wheels"];

private _wheelsTouching = { 0.6 < (_vehicle modelToWorld _wheels) # 2 } count _wheels;

_wheelsTouching > 2
