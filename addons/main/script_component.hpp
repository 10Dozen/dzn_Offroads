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

#define SELF
#define QSELF              QUOTE(SELF)
#define __FFNC(FNAME)      fnc##_##FNAME
#define self_GET(VAR)      (SELF get VAR)
#define self_FUNC(FNAME)   (SELF get QUOTE(__FFNC(FNAME)))


#define ROAD_COEF_TRACK 0.01
#define ROAD_COEF_TRAIL 0.05

#define SLOWDOWN_THRESHOLD_COEF 15
#define SLOWDOWN_MASS_COEF 0.0005

#define EFFECTS_THRESHOLD_MIN 25
#define EFFECTS_THRESHOLD_MAX 50

#define EFFECTS_MASS_COEF 0.02
#define EFFECTS_SPEED_COEF 0.0012
