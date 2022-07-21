#ifndef REM2PI_H__
#define REM2PI_H__
// Compute the remainder of `x` after integer division by `2π`, with the quotient rounded
// to nearest. In other words, the quantity
//    x - 2π*round(x/(2π),r)
// without any intermediate rounding. This internally uses a high precision approximation of
// 2π, and so will give a more accurate result than `rem(x,2π,r)`
// the result is in the interval ``[-π, π]``. This will generally
//  be the most accurate result.
double rem2pi(double x);
float rem2pi(float x);

#endif