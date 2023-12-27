//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// imgradient3.cpp
//
// Code generation for function 'imgradient3'
//

// Include files
#include "imgradient3.h"
#include "imgradientxyz.h"
#include <cmath>

// Function Definitions
namespace coder {
void imgradient3(const float varargin_1[4849664], float Gmag[4849664])
{
  static float Gx[4849664];
  static float Gy[4849664];
  static float Gz[4849664];
  imgradientxyz(varargin_1, Gx, Gy, Gz);
  for (int k{0}; k < 4849664; k++) {
    float f;
    float f1;
    float f2;
    f = Gx[k];
    f1 = Gz[k];
    f1 *= f1;
    Gx[k] = f1;
    f2 = Gy[k];
    Gmag[k] = std::sqrt((f * f + f2 * f2) + f1);
  }
}

} // namespace coder

// End of code generation (imgradient3.cpp)
