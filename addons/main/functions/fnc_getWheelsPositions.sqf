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

// --- Find
private _wheels = selectionNames _vehicle
          select {  "wheel_" in _x && ("_hide" in _x || "_unhide" in _x) }
          apply { _vehicle selectionPosition _x };

LOG_1("[getWheelPositions] Wheels in model: %1", _wheels);

private _wheelsToPick = [];
if (_wheels isEqualTo []) then {
    // Calculate from bounding box
    (boundingBoxReal _vehicle) params ["_bba", "_bbb", ""];
    LOG_2("[getWheelPositions] Bounding box: BBA: %1, BBB: %2", _bba, _bbb);

    _wheelsToPick = [
        [0.75 * _bba # 0, 0.75 * _bba # 1, 0.7 * _bba # 2],
        [0.75 * _bbb # 0, 0.75 * _bba # 1, 0.7 * _bba # 2],
        [0.75 * _bba # 0, 0.3 * _bbb # 1, 0.7 * _bba # 2],
        [0.75 * _bbb # 0, 0.3 * _bbb # 1, 0.7 * _bba # 2]
    ];

    LOG_1("[getWheelPositions] Calculated from Bounding Box: %1", _wheelsToPick);
} else {
    if (count _wheels > 4) then {
        LOG_1("[getWheelPositions] Too much wheels, selecting 4 of them: %1", _wheels);
        // Too much wheels - pick 4 most distant positions
        // --- Check front/rear groups
        private _com = getCenterOfMass _vehicle;
        {
            private _wheelsGroup = _wheels select _x;
            LOG_2("[getWheelPositions] .. Front/Rear group (%1): %2", str(_x), _wheelsGroup);
            // --- Check wheels in quadrants (FrontLeft/FrontRigh/RearLeft/RearRight)
            {
                private _wheelsInSegment = _wheelsGroup select _x;
                private _max = selectMax (_wheelsInSegment apply { abs(_x # 1) });
                _wheelsToPick pushBack ((_wheelsInSegment select { abs(_x # 1) == _max}) # 0);
                LOG_4("[getWheelPositions] .. .. Left/Right group (%4): %1 [Max distance: %2] => selected %3", _wheelsInSegment, _max, _wheelsToPick, str(_x));
            } forEach [
                {_x # 0 < _com # 0},
                {_x # 0 > _com # 0}
            ];
        } forEach [
            {_x # 1 > _com # 1},
            {_x # 1 < _com # 1}
        ];

        LOG("[getWheelPositions] Calculated from list of wheels");
    } else {
        _wheelsToPick = _wheels;
    };

    LOG_1("[getWheelPositions] Wheels: %1", _wheelsToPick);

    private _avgHeight = 0;
    { _avgHeight = _avgHeight + (_x # 2)/4; } forEach _wheelsToPick;

    private _avgModelToWorld = _wheelsToPick apply { (_vehicle modelToWorldVisual [_x # 0, _x # 1, _avgHeight]) # 2 };
    LOG_1("[getWheelPositions] AvgModelToWorld: %1", _avgModelToWorld);

    _avgModelToWorld = (selectMax _avgModelToWorld + selectMin _avgModelToWorld) / 2;
    LOG_2("[getWheelPositions] Average height: %1 | Average modelToWorldReal: %2", _avgHeight, _avgModelToWorld);
    if (_avgModelToWorld < 0.05) then {
        _avgHeight = _avgHeight + 0.35;
    };

    LOG_1("[getWheelPositions] Average valid wheel height: %1", _avgHeight);
    { _x set [2, _avgHeight] } forEach _wheelsToPick;

    LOG_1("[getWheelPositions] Aquired from model normalized wheels positions: %1", _wheelsToPick);
};

private _wheelsAxesAvgHeight = (_vehicle modelToWorldVisual (_wheelsToPick # 0)) # 2;
_wheelsData = [_wheelsToPick, _wheelsAxesAvgHeight];

LOG_1("[getWheelPositions] Average axes height: %1", _wheelsAxesAvgHeight);

_wheelsData
