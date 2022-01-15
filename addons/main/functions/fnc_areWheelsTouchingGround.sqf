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

params ["_vehicle", "_wheels", "_avgWheelAxisHeight"];

private _h = 0;
private _avgWheelAxisHeight = _avgWheelAxisHeight * 1.2;  // 20% of suspension movement

private _wheelsTouching = {
    _h = (_vehicle modelToWorldVisual _x) # 2;
    LOG_3("[isVehicleTouchingGround] Wheel height: %1 (<= %2 [%3])", _h, _avgWheelAxisHeight, _h <= _avgWheelAxisHeight);

    _h <= _avgWheelAxisHeight
} count _wheels;

_wheelsTouching > 2
