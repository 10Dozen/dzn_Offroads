#include "script_component.hpp"
/*
 * Author: 10Dozen
 * Returns vehicle's wheels positions, acquired from model or calculated from
 * bounding box sizes.
 *
 * Arguments:
 * 0: _vehicle -- vehicle (OBJECT)
 *
 * Return Value:
 * _wheelsPositions (ARRAY of model space coordinates for up to 4 wheels)
 *
 * Example:
 * _wheelsPositions = [_vehicle] call dzn_Offroads_main_fnc_getWheelsPositions;
 *
 * Public: No
 */

params ["_vehicle"];

private _vehicleClass = typeOf _vehicle;
private _wheelsData = GVAR(VehiclesCache) get _vehicleClass;

// --- Get from cache
if (!isNil "_wheelsData") exitWith { _wheelsData };

// --- Find and cache
private _wheels = selectionNames _vehicle
          select {  "wheel_" in _x && "_hide" in _x }
          apply { _vehicle selectionPosition _x };

private _wheelsToPick = [];
if (_wheels isEqualTo []) then {
    // Calculate from bounding box
    private _bb = _vehicle call BIS_fnc_boundingBoxDimensions;
    (_bb apply { 0.75 * _x / 2 }) params ["_oX", "_oY", "_oZ"];

    _wheelsToPick = [
        [_oX, _oY, _oZ],
        [_oX, _oY * -1, _oZ],
        [_oX * -1, _oY, _oZ],
        [_oX * -1, _oY * -1, _oZ]
    ];

    LOG("[getWheelPositions] Calculated from Bounding Box");
} else {
    if (count _wheels <= 4) exitWith {
        _wheelsToPick = _wheels;
        LOG("[getWheelPositions] Acquired from model wheels positions");
    };

    // Too much wheels - pick 4 most distant positions
    // --- Check front/rear groups
    {
        private _wheelsGroup = _wheels select _x;
        // --- Check wheels in quadrants (FrontLeft/FrontRigh/RearLeft/RearRight)
        {
            private _wheelsInSegment = _wheelsGroup select _x;
            private _max = selectMax (_wheelsInSegment apply { abs(_x # 1) });
            _wheelsToPick pushBack ((_wheelsInSegment select { abs(_x # 1) == _max}) # 0);
        } forEach [
            {_x # 0 < 0},
            {_x # 0 > 0}
        ];
    } forEach [
        {_x # 1 > 0},
        {_x # 1 < 0}
    ];

    LOG("[getWheelPositions] Calculated from list of wheels");
};

private _wheelsAxesHeight = _wheelsToPick apply { (_vehicle modelToWorldVisual _x) # 2 };
private _avgHeight = (selectMin _wheelsAxesHeight + selectMax _wheelsAxesHeight) / 2;
_wheelsData = [_wheelsToPick, _avgHeight];

LOG("[getWheelPositions] Caching...");
GVAR(VehiclesCache) set [_vehicleClass, _wheelsData];

_wheelsData
