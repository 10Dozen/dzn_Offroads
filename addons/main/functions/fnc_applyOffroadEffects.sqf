#include "script_component.hpp"
/*
 * Author: 10Dozen
 * Applies sliding & bouncing effects to vehicle depending on surface type.
 *
 * Arguments:
 * 0: _vehicle -- vehicle to apply effects (OBJECT)
 * 1: _vehicleProperties -- vehicle properties (ARRAY)
 * 2: _surfaceProperties -- surface properties (ARRAY)
 * 3: _effectsMultiplier -- general multiplier of surface effects (NUMBER)
 *
 * Return Value:
 * nothing
 *
 * Example:
 * [_vehicle, [75, 1500, 100], [1,0.75], 1] call dzn_Offroads_main_fnc_applyOffroadEffects;
 *
 * Public: No
 */

params ["_vehicle", "_vehicleProperties", "_surfaceProperties", "_effectsMultiplier"];
_vehicleProperties params ["", "_vehicleSuspensionCoef"];
_surfaceProperties params ["", "_forceX", "_forceZ"];

private _wheels = [_vehicle] call FUNC(getWheelsPositions);
private _isTouching = [_vehicle, _wheels] call FUNC(isVehicleTouchingGround);
if (!_isTouching) exitWith {
    LOG("[FX] X (not touching ground)");
};
LOG("[FX] Is touching...");

private _position = selectRandom _wheels;
private _speedCoef = (EFFECTS_SPEED_COEF * (speed _vehicle) ^ 2) / 150;
private _massCoef = EFFECTS_MASS_COEF * getMass _vehicle;
private _finalMultiplier = GVAR(Effects_Multiplier) * _speedCoef * _massCoef * _effectsMultiplier;

private _force = [
    (random _forceX) * selectRandom [-1,1] * _finalMultiplier,
    0,
    (random _forceZ) * selectRandom [-1,1] * _finalMultiplier * 1 / _vehicleSuspensionCoef
];

systemChat format ["[FX] %1 | S(%2) M(%3) E(%4) Mx(%5)", round(selectMax _force), _speedCoef, _massCoef, _effectsMultiplier, _finalMultiplier];
LOG_5("[FX] %1 | Spd(%2) Mass(%3) Efx(%4) => Mx(%5)", round(selectMax _force), _speedCoef, _massCoef, _effectsMultiplier, _finalMultiplier);

[
    { (_this # 0) addForce [_this # 1, _this # 2] },
    [_vehicle, _force, _position]
] call CBA_fnc_execNextFrame;
