#include "script_component.hpp"
/*
 * Author: 10Dozen
 * Returns surface's data - resistance coef, sliding coef, sliding probability, bumping coef, bumping probability
 *
 * Arguments:
 * 0: _surface -- name of the surface (same as output of surfaceType command) (STRING)
 *
 * Return Value:
 * 0: _friction -- friction (slowdown) coefficient (NUMBER)
 * 1: _sliding -- sliding (X axis force) coefficient (NUMBER)
 * 2: _slidingProbability -- chance (or density) of sliding effect (NUMBER)
 * 3: _bumping -- bumping (Z axis force) coefficient (NUMBER)
 * 4: _bumpingProbability -- chance (or denisity) of bumping effect (NUMBER)
 *
 * Example:
 * _surfaceData = [surfaceType (getPos player)] call dzn_Offroads_main_fnc_getSurfaceData;
 *
 * Public: No
 */

params ["_surface"];

private _data = GVAR(SurfacesCache) get _surface;
if (!isNil "_data") exitWith {
    _data
};

LOG_1("[getSurfaceData] Not found in cache. Gathering data for %1", _surface);


// -- Get from custom/config settings
private _settings = GVAR(Surfaces) get _surface;
if (!isNil "_setting") then {
    LOG("[getSurfaceData] Found in Settings (or custom config)");
    _data = _settings;
} else {
    private _class = _surface select [1];
    LOG_1("[getSurfaceData] Read from class %1...", _class);

    private _config = configFile >> "CfgSurfaces" >> _class;
    private _maxSpeed = getNumber (_config >> "maxSpeedCoef"); // 1 - 100%, 0 - 0%
    private _friction = getNumber (_config >> "surfaceFriction"); // 2.5 - lower, 1.5 - bigger sliding
    private _rough = getNumber (_config >> "rough"); // 0.15 - bumpy, 0.05 - not bumpy

    private _resistance = 3 * linearConversion [0, 1, _maxSpeed, 150, 0];
    private _sliding = linearConversion [1.0, 2.5, _friction, 1600, 0];
    private _bumping = linearConversion [0.03, 0.15, _rough, 1600, 0];

    LOG_6("[getSurfaceData] MaxSpeed: %1 -> Resist: %2 | SurfFriction: %3 -> Sliding: %4 | Rough: %5 -> Bump: %6", _maxSpeed, _resistance, _friction, _sliding, _rough, _bumping);

    _data = [_resistance, _sliding, 0.5, _bumping, 0.5];
};

LOG_1("[getSurfaceData] Caching result: %1", _data);
GVAR(SurfacesCache) set [_surface, _data];

_data
