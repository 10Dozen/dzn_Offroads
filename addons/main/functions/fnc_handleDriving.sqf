#include "script_component.hpp"
/*
 * Author: 10Dozen
 * Tracks and applies slowdown and effects when vehicle goes offroad.
 * bounding box sizes.
 *
 * Arguments:
 * 0: _vehicle -- vehicle (OBJECT)
 *
 * Return Value:
 * nothing
 *
 * Example:
 * _wheelsPositions = [_vehicle] call dzn_Offroads_main_fnc_handleDriving;
 *
 * Public: No
 */
params ["_vehicle"];

if (!GVAR(Slowdown_Enabled)) exitWith {};
if (isNull _vehicle) exitWith { LOG("No vehicle"); };
if (isGamePaused) exitWith { LOG("Game paused") };
if (not local _vehicle) exitWith { LOG("Vehicle is not local"); };
if (speed _vehicle < 3) exitWith { LOG("Vehicle is stopped"); };
if (not isTouchingGround _vehicle) exitWith { LOG("Vehicle is in the air"); };
if ((["Tank", "Air", "Ship"] select { _vehicle isKindOf _x }) isNotEqualTo []) exitWith { LOG("Vehicle is not wheeled one"); };

private _vehiclePos = getPosATL _vehicle;
private _surface = surfaceType _vehiclePos;

// --- Effects of the road
private _roadMultiplier = 1;
private _road = roadAt _vehiclePos;
if (!isNull _road) then {
    _roadMultiplier = switch ((getRoadInfo _road) # 0) do {
        case "TRACK": { ROAD_COEF_TRACK };
        case "TRAIL": { ROAD_COEF_TRAIL };
        default { 0 };
    };
};
if (_roadMultiplier == 0) exitWith { LOG("Is on a good road!"); };

// --- Effects of the surface
private _surfaceProperties = GVAR(Surfaces) getOrDefault [_surface, [0, 0, 0]];
private _surfaceResistanceCoef = _surfaceProperties # 0;
if (_surfaceResistanceCoef == 0) exitWith { LOG_1("Unknown surface %1", _surface); };

// --- Effects of the vehicle's capabilities and mass
private _vehicleProperties = [_vehicle] call FUNC(getOffroadCapabilities);
private _massCoef = SLOWDOWN_MASS_COEF * getMass _vehicle;
private _vehicleMultiplier = _massCoef * (1 / _vehicleProperties # 0);

// --- Calculations
private _finalResistanceCoef = GVAR(Slowdown_Multiplier) * _surfaceResistanceCoef * _roadMultiplier * _vehicleMultiplier;
if (_finalResistanceCoef <= 1) exitWith {
    LOG_4("[X] No resistance %4 | S(%1) *R(%2) *V(%3)",_surfaceResistanceCoef, _roadMultiplier, _vehicleMultiplier, _finalResistanceCoef);
};

_vehicle addForce [
    (velocity _vehicle) vectorMultiply (-1 * _finalResistanceCoef),
    [0,0,0]
];

LOG_5("[>] %4 | S(%1) *R(%2) *V(%3) | %5", _surfaceResistanceCoef, _roadMultiplier, _vehicleMultiplier, _finalResistanceCoef, _velocity);

// --- Apply offroad effects (bouncing and sliding)
if (!GVAR(Effects_Enabled)) exitWith {};

// --- Effects threshold to avoid effects while on road/good surface
if (_finalResistanceCoef <= 5) exitWith {};
private _effectsMultiplier = [0.5, 1] select (_finalResistanceCoef > 10);

[_vehicle, _vehicleProperties, _surfaceProperties, _effectsMultiplier] call FUNC(applyOffroadEffects);
