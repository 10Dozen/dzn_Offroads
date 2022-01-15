#include "script_component.hpp"

if (!hasInterface) exitWith {};

[{
    [objectParent (call CBA_fnc_currentUnit)] call FUNC(handleDriving);
}, 0.2] call CBA_fnc_addPerFrameHandler;


[] spawn {
    sleep 3;
    // if (true) exitWith {};

[{
    private _vehicle = objectParent player;
    if (isNull _vehicle) exitWith {};
    ([_vehicle] call FUNC(getVehicleData)) params ["","","_wheels", "_avgWheelAxisHeight"];

    // LOG_1("%1", _wheels);
    _p1 = _vehicle modelToWorldVisual (_wheels # 0);
    _p2 = _vehicle modelToWorldVisual (_wheels # 1);
    _p3 = _vehicle modelToWorldVisual (_wheels # 2);
    _p4 = _vehicle modelToWorldVisual (_wheels # 3);

    drawLine3D [_p1, _p2, [1,0,0,1]];
    drawLine3D [_p2, _p3, [1,0,0,1]];
    drawLine3D [_p3, _p4, [1,0,0,1]];
    drawLine3D [_p4, _p1, [1,0,0,1]];

    drawLine3D [_p4, _p2, [1,0,0,1]];
    drawLine3D [_p1, _p3, [1,0,0,1]];
}] call CBA_fnc_addPerFrameHandler;

};
