//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// fftn.cpp
//
// Code generation for function 'fftn'
//

// Include files
#include "fftn.h"
#include "FFTImplementationCallback.h"
#include "msmv_data.h"

// Function Definitions
namespace coder {
void fftn(const double x[4849664], creal_T y[4849664])
{
  static creal_T a[4849664];
  static creal_T b[4849664];
  static creal_T b_b[4849664];
  int b_k;
  int b_tmp;
  int c_k;
  int k;
  internal::FFTImplementationCallback::r2br_r2dit_trig(x, a);
  for (k = 0; k < 74; k++) {
    b_tmp = k << 16;
    for (b_k = 0; b_k < 256; b_k++) {
      for (c_k = 0; c_k < 256; c_k++) {
        b[(b_k + (c_k << 8)) + b_tmp] = a[(c_k + (b_k << 8)) + b_tmp];
      }
    }
  }
  internal::FFTImplementationCallback::r2br_r2dit_trig(b, dv, dv1, b_b);
  for (k = 0; k < 74; k++) {
    b_tmp = k << 16;
    for (b_k = 0; b_k < 256; b_k++) {
      for (c_k = 0; c_k < 256; c_k++) {
        a[(b_k + (c_k << 8)) + b_tmp] = b_b[(c_k + (b_k << 8)) + b_tmp];
      }
    }
  }
  for (k = 0; k < 74; k++) {
    for (b_k = 0; b_k < 256; b_k++) {
      for (c_k = 0; c_k < 256; c_k++) {
        b[(k + 74 * c_k) + 18944 * b_k] = a[(c_k + (b_k << 8)) + (k << 16)];
      }
    }
  }
  internal::FFTImplementationCallback::dobluesteinfft(b, dv, dv1, dv2, b_b);
  for (k = 0; k < 256; k++) {
    for (b_k = 0; b_k < 256; b_k++) {
      for (c_k = 0; c_k < 74; c_k++) {
        y[(b_k + (k << 8)) + (c_k << 16)] = b_b[(c_k + 74 * b_k) + 18944 * k];
      }
    }
  }
}

} // namespace coder

// End of code generation (fftn.cpp)
