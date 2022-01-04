#include "script_component.hpp"

if (!hasInterface) exitWith {};

[{
    [objectParent (call CBA_fnc_currentUnit)] call FUNC(handleDriving);
}, 0.2] call CBA_fnc_addPerFrameHandler;
