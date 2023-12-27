//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// imgradientxyz.cpp
//
// Code generation for function 'imgradientxyz'
//

// Include files
#include "imgradientxyz.h"
#include "imfilter.h"

// Function Definitions
namespace coder {
void imgradientxyz(const float varargin_1[4849664], float Gx[4849664],
                   float Gy[4849664], float Gz[4849664])
{
  static const signed char iv[9]{-1, -3, -1, 0, 0, 0, 1, 3, 1};
  static const signed char iv1[9]{-3, -6, -3, 0, 0, 0, 3, 6, 3};
  static const signed char iv2[9]{-1, 0, 1, -3, 0, 3, -1, 0, 1};
  static const signed char iv3[9]{-3, 0, 3, -6, 0, 6, -3, 0, 3};
  static const signed char iv4[9]{-1, -3, -1, -3, -6, -3, -1, -3, -1};
  static const signed char iv5[9]{1, 3, 1, 3, 6, 3, 1, 3, 1};
  double hx[27];
  double hy[27];
  double hz[27];
  for (int i{0}; i < 3; i++) {
    int b_hx_tmp;
    int hx_tmp;
    int i2;
    signed char i1;
    i1 = iv[3 * i];
    hx[3 * i] = i1;
    hx_tmp = 3 * i + 9;
    hx[hx_tmp] = iv1[3 * i];
    b_hx_tmp = 3 * i + 18;
    hx[b_hx_tmp] = i1;
    i1 = iv2[3 * i];
    hy[3 * i] = i1;
    hy[hx_tmp] = iv3[3 * i];
    hy[b_hx_tmp] = i1;
    hz[3 * i] = iv4[3 * i];
    hz[hx_tmp] = 0.0;
    hz[b_hx_tmp] = iv5[3 * i];
    i2 = 3 * i + 1;
    i1 = iv[i2];
    hx[i2] = i1;
    hx_tmp = 3 * i + 10;
    hx[hx_tmp] = iv1[i2];
    b_hx_tmp = 3 * i + 19;
    hx[b_hx_tmp] = i1;
    i1 = iv2[i2];
    hy[i2] = i1;
    hy[hx_tmp] = iv3[i2];
    hy[b_hx_tmp] = i1;
    hz[i2] = iv4[i2];
    hz[hx_tmp] = 0.0;
    hz[b_hx_tmp] = iv5[i2];
    i2 = 3 * i + 2;
    i1 = iv[i2];
    hx[i2] = i1;
    hx_tmp = 3 * i + 11;
    hx[hx_tmp] = iv1[i2];
    b_hx_tmp = 3 * i + 20;
    hx[b_hx_tmp] = i1;
    i1 = iv2[i2];
    hy[i2] = i1;
    hy[hx_tmp] = iv3[i2];
    hy[b_hx_tmp] = i1;
    hz[i2] = iv4[i2];
    hz[hx_tmp] = 0.0;
    hz[b_hx_tmp] = iv5[i2];
  }
  imfilter(varargin_1, hx, Gx);
  imfilter(varargin_1, hy, Gy);
  imfilter(varargin_1, hz, Gz);
}

} // namespace coder

// End of code generation (imgradientxyz.cpp)
