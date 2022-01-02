#include "script_component.hpp"

ADDON = false;
#include "XEH_PREP.hpp"
#include "initSettings.sqf"
ADDON = true;

GVAR(Surfaces) = nil;
GVAR(VehicleCapabilities) = nil;

GVAR(VehiclesCache) = createHashMap;
