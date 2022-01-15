#include "script_component.hpp"
/*
 * Author: 10Dozen
 * Applies sliding & bouncing effects to vehicle depending on surface type.
 *
 * Arguments:
 * 0: _vehicle -- vehicle to apply effects (OBJECT)
 * 1: _vehicleProperties -- vehicle properties: _offroadCapability, _suspensionCapability, _wheelsPositions, _wheelsAvgHeight (ARRAY)
 * 2: _surfaceProperties -- surface properties: _resitance, _slidingForce, _bumpingForce (ARRAY)
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
_vehicleProperties params ["", "_vehicleSuspensionCoef", "_wheelsPositions", "_wheelsAxesAvgHeight"];
_surfaceProperties params ["", "_slidingForce", "_slidingProbability", "_bumpingForce", "_bumpingProbability"];

private _isTouching = [_vehicle, _wheelsPositions, _wheelsAxesAvgHeight] call FUNC(areWheelsTouchingGround);
if (!_isTouching) exitWith { LOG("[FX] X (not touching ground)"); };

// --- Calculate probability and basic force to apply
private _speedProbabiltyModifier = (speed _vehicle) / 100 - 0.3;
LOG_3("[FX] Probabilities: SPD_MOD: %1 -> X: %2 | Z: %3", _speedProbabiltyModifier, (_slidingProbability + _speedProbabiltyModifier), (_bumpingProbability + _speedProbabiltyModifier));

private _forceX = [0, random [0, _slidingForce/1.5, _slidingForce]] select (random 1 < (_slidingProbability + _speedProbabiltyModifier));
private _forceZ = [0, random [0, _bumpingForce/1.5, _bumpingForce]] select (random 1 < (_bumpingProbability + _speedProbabiltyModifier));

if (_forceX == 0 && _forceZ == 0) exitWith { LOG("[FX] X (no effects happened)");};

// -- Calculate final force to apply
private _position = selectRandom _wheelsPositions;
private _speedCoef = EFFECTS_SPEED_COEF * (speed _vehicle) ^ 2;
private _massCoef = (getMass _vehicle) / 3200; // EFFECTS_MASS_COEF * (getMass _vehicle) ^ 0.5;
private _finalMultiplier = GVAR(Effects_Multiplier) * _speedCoef * _massCoef * _effectsMultiplier;

private _force = [
    _forceX * selectRandom [-1,1] * _finalMultiplier,
    0,
    _forceZ * selectRandom [-1,1] * _finalMultiplier * 1 / _vehicleSuspensionCoef
];

systemChat format ["[FX] %1 | S(%2) M(%3) E(%4) Mx(%5) Susp(%6)", round(selectMax _force), _speedCoef, _massCoef, _effectsMultiplier, _finalMultiplier, 1 / _vehicleSuspensionCoef];

LOG_7("[FX] SPD: %1 | SPD_COEF: %2 | MASS: %3 | MASS_COEF: %4 | MULTIPLIER: %5 | SUSPENSION: %6 (%7)", speed _vehicle, _speedCoef, getMass _vehicle, _massCoef, _effectsMultiplier, _vehicleSuspensionCoef, 1/_vehicleSuspensionCoef);
LOG_3("[FX] Sliding: %1 x %2 = %3", _forceX, _finalMultiplier, _force # 0);
LOG_3("[FX] Bumping: %1 x %2 = %3", _forceZ, _finalMultiplier * 1 / _vehicleSuspensionCoef, _force # 2);


//LOG_8("[FX][Affecting] %1 | V[Susp: %2] | S[Slid: %3, Bounc: %4] | Pos(%5) Spd(%6) Mass(%7) => Final(%8)", _force, 1 / _vehicleSuspensionCoef, _forceX, _forceZ, _position, _speedCoef, _massCoef, _finalMultiplier);

[
    { (_this # 0) addForce [_this # 1, _this # 2] },
    [_vehicle, _force, _position]
] call CBA_fnc_execNextFrame;
