#define COMPONENT main
#define COMPONENT_BEAUTIFIED Main
#include "\z\dzn_Offroads\addons\main\script_mod.hpp"

#define DEBUG_ENABLED_MAIN
#define DEBUG_MODE_FULL
#define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_MAIN
    #define DEBUG_MODE_FULL
#endif
    #ifdef DEBUG_SETTINGS_MAIN
    #define DEBUG_SETTINGS DEBUG_SETTINGS_MAIN
#endif

#include "\z\dzn_Offroads\addons\main\script_macros.hpp"

#define SLOWDOWN_MASS_COEF 0.0005
#define EFFECTS_MASS_COEF 0.0005
#define EFFECTS_SPEED_COEF 0.1
