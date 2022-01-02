
#define ADDON_BEAUTIFIED "dzn Offroads"

[
    QGVAR(Slowdown_Enabled),
    "CHECKBOX",
    [LLSTRING(Slowdown_Enabled), LLSTRING(Slowdown_Enabled_Desc)],
    ADDON_BEAUTIFIED,
    true,
    1,
    nil,
    true
] call CBA_fnc_addSetting;

[
    QGVAR(Slowdown_Multiplier),
    "SLIDER",
    [LLSTRING(Slowdown_Multiplier), LLSTRING(Slowdown_Enabled_Desc)],
    ADDON_BEAUTIFIED,
    [0, 5, 1, 2],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(Effects_Enabled),
    "CHECKBOX",
    [LLSTRING(Effects_Enabled), LLSTRING(Effects_Enabled_Desc)],
    ADDON_BEAUTIFIED,
    true,
    1
] call CBA_fnc_addSetting;

[
    QGVAR(Effects_Multiplier),
    "SLIDER",
    [LLSTRING(Effects_Multiplier), LLSTRING(Effects_Multiplier_Desc)],
    ADDON_BEAUTIFIED,
    [0, 5, 1, 2],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(CustomVehiclesSetup),
    "EDITBOX",
    [LLSTRING(CustomVehiclesSetup), LLSTRING(CustomVehiclesSetup_Desc)],
    ADDON_BEAUTIFIED,
    "",
    1,
    { ["VEHICLES"] call FUNC(updateConfiguration) }
] call CBA_fnc_addSetting;

[
    QGVAR(CustomSurfaceSetup),
    "EDITBOX",
    [LLSTRING(CustomSurfaceSetup), LLSTRING(CustomSurfaceSetup_Desc)],
    ADDON_BEAUTIFIED,
    "",
    1,
    { ["SURFACES"] call FUNC(updateConfiguration) }
] call CBA_fnc_addSetting;
