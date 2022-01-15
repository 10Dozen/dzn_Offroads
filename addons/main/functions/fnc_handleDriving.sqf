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

if (isGamePaused) exitWith {};
if (!GVAR(Slowdown_Enabled)) exitWith {};
if (isNull _vehicle) exitWith {};
if (not local _vehicle) exitWith {};
if (speed _vehicle < 3) exitWith {};
if (not isTouchingGround _vehicle) exitWith { LOG("[SLWDN] Vehicle is in the air"); };
if ((["Tank", "Air", "Ship"] select { _vehicle isKindOf _x }) isNotEqualTo []) exitWith { LOG("[SLWDN] Vehicle is not wheeled one"); };

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
if (_roadMultiplier == 0) exitWith { LOG("[SLWDN] Is on a good road!"); };

// --- Effects of the surface
private _surfaceProperties = [_surface] call FUNC(getSurfaceData);
private _surfaceResistanceCoef = _surfaceProperties # 0;
if (_surfaceResistanceCoef == 0) exitWith { LOG_1("[SLWDN] Unknown surface %1", _surface); };

// --- Effects of the vehicle's capabilities and mass
private _vehicleProperties = [_vehicle] call FUNC(getVehicleData);
private _offroadCapability = _vehicleProperties # 0;
private _massCoef = SLOWDOWN_MASS_COEF * getMass _vehicle;
private _vehicleMultiplier = _massCoef * (1 / _offroadCapability);

// --- Calculations
private _finalResistanceCoef = GVAR(Slowdown_Multiplier) * _surfaceResistanceCoef * _roadMultiplier * _vehicleMultiplier;
if (_finalResistanceCoef <= SURFACE_THRESHOLD_MIN) exitWith {
    LOG_4("[SLWDN] [X] No resistance %4 | S(%1) *R(%2) *V(%3)",_surfaceResistanceCoef, _roadMultiplier, _vehicleMultiplier, _finalResistanceCoef);
};

_vehicle addForce [
    (velocity _vehicle) vectorMultiply (-1 * _finalResistanceCoef),
    getCenterOfMass _vehicle
];

systemChat format ["[SLWDN] %4 | S(%1) *R(%2) *V(%3)", _surfaceResistanceCoef, _roadMultiplier, _vehicleMultiplier, _finalResistanceCoef];
LOG_4("[SLWDN]  %1 | S(%2) *Road(%3) *Veh(%4) *Mass(%5)", _finalResistanceCoef, _surfaceResistanceCoef, _roadMultiplier, (1 / _offroadCapability), _massCoef);

// --- Apply offroad effects (bouncing and sliding)
if (!GVAR(Effects_Enabled)) exitWith {};

// --- Effects threshold to avoid effects while on road/good surface
if (_finalResistanceCoef <= EFFECTS_THRESHOLD_MIN) exitWith {};
private _effectsMultiplier = [0.5, 1] select (_finalResistanceCoef > EFFECTS_THRESHOLD_MAX);

[_vehicle, _vehicleProperties, _surfaceProperties, _effectsMultiplier] call FUNC(applyOffroadEffects);
