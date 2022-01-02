#include "\z\dzn_Offroads\addons\main\script_component.hpp"

#define SELF
#define QSELF              QUOTE(SELF)
#define __FFNC(FNAME)      fnc##_##FNAME
#define self_GET(VAR)      (SELF get VAR)
#define self_FUNC(FNAME)   (SELF get QUOTE(__FFNC(FNAME)))


#define ROAD_COEF_TRACK 0.05
#define ROAD_COEF_TRAIL 0.3
