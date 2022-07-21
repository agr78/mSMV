#define _USE_MATH_DEFINES // for windows
#include <math.h>
#include <vector>
namespace ROMEO {
float g(float x) // faster if only one wrap can occur
{
    float y = x;
    if (x < -M_PI) {
        y = x + 2 * M_PI;
    } else if (x > M_PI) {
        y = x - 2 * M_PI;
    }
    return y;
}
}
