#define _USE_MATH_DEFINES // for windows
#include <math.h>
#include "e_rem_pio2.h"

// multiples of pi/2, as double-double (ie with "tail")
const double pi1o2_h  = 1.5707963267948966;     // convert(Float64, pi * BigFloat(1/2))
const double pi1o2_l  = 6.123233995736766e-17;  // convert(Float64, pi * BigFloat(1/2) - pi1o2_h)

const double pi2o2_h  = 3.141592653589793;      // convert(Float64, pi * BigFloat(1))
const double pi2o2_l  = 1.2246467991473532e-16 ;// convert(Float64, pi * BigFloat(1) - pi2o2_h)

const double pi3o2_h  = 4.71238898038469;       // convert(Float64, pi * BigFloat(3/2))
const double pi3o2_l  = 1.8369701987210297e-16; // convert(Float64, pi * BigFloat(3/2) - pi3o2_h)

const double pi4o2_h  = 6.283185307179586;      // convert(Float64, pi * BigFloat(2))
const double pi4o2_l  = 2.4492935982947064e-16; // convert(Float64, pi * BigFloat(2) - pi4o2_h)

double add22condh(double xh, double xl, double yh, double yl)
{
    // This algorithm, due to Dekker, computes the sum of two
    // double-double numbers and returns the high double. References:
    // [1] http://www.digizeitschriften.de/en/dms/img/?PID=GDZPPN001170007
    // [2] https://doi.org/10.1007/BF01397083
    double r = xh+yh;
    double s = (fabs(xh) > fabs(yh)) ? (xh-r+yh+yl+xl) : (yh-r+xh+xl+yl);
    return r + s;
}

// RoundNearest only
double rem2pi(double x) 
{
    if (fabs(x) < M_PI) { return x; }
    double y[2];
    int n;
    n = e_rem_pio2(x, y);

    if (0==n%2) {
        if (n%4==2) {
            // add/subtract pi
            if (y[0] <= 0 ) {
                return add22condh(y[0],y[1],pi2o2_h,pi2o2_l);
            } else {
                return add22condh(y[0],y[1],-pi2o2_h,-pi2o2_l);
            }
        } else {
            // n % 4 == 0: add 0
            return y[0]+y[1];
        }
    } else {
        if (n % 4 == 3) {
            //subtract pi/2
            return add22condh(y[0],y[1],-pi1o2_h,-pi1o2_l);
        } else {
            // n % 4 == 1: add pi/2
            return add22condh(y[0],y[1],pi1o2_h,pi1o2_l);
        }
    }
}

float rem2pi(float x) {
    return (float)rem2pi((double)x);
}
