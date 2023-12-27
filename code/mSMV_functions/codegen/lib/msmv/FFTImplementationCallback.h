//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// FFTImplementationCallback.h
//
// Code generation for function 'FFTImplementationCallback'
//

#ifndef FFTIMPLEMENTATIONCALLBACK_H
#define FFTIMPLEMENTATIONCALLBACK_H

// Include files
#include "rtwtypes.h"
#include "omp.h"
#include <cstddef>
#include <cstdlib>

// Type Definitions
namespace coder {
namespace internal {
class FFTImplementationCallback {
public:
  static void r2br_r2dit_trig(const double x[4849664], creal_T y[4849664]);
  static void r2br_r2dit_trig(const creal_T x[4849664],
                              const double costab[129],
                              const double sintab[129], creal_T y[4849664]);
  static void dobluesteinfft(const creal_T x[4849664], const double costab[129],
                             const double sintab[129],
                             const double sintabinv[129], creal_T y[4849664]);
  static void r2br_r2dit_trig(const creal32_T x[4849664],
                              const float costab[129], const float sintab[129],
                              creal32_T y[4849664]);
  static void dobluesteinfft(const creal32_T x[4849664],
                             const float costab[129], const float sintab[129],
                             const float sintabinv[129], creal32_T y[4849664]);
  static void d_r2br_r2dit_trig(const creal_T x[4849664],
                                const double costab[129],
                                const double sintab[129], creal_T y[4849664]);
  static void b_dobluesteinfft(const creal_T x[4849664],
                               const double costab[129],
                               const double sintab[129],
                               const double sintabinv[129], creal_T y[4849664]);

protected:
  static void r2br_r2dit_trig_impl(const creal_T x[4849664], int xoffInit,
                                   const double costab[129],
                                   const double sintab[129], creal_T y[256]);
  static void r2br_r2dit_trig_impl(const creal_T x[74],
                                   const double costab[129],
                                   const double sintab[129], creal_T y[256]);
  static void b_r2br_r2dit_trig(const creal_T x[147], const double costab[129],
                                const double sintab[129], creal_T y[256]);
  static void c_r2br_r2dit_trig(const creal_T x[256], const double costab[129],
                                const double sintab[129], creal_T y[256]);
  static void doHalfLengthRadix2(const double x[4849664], int xoffInit,
                                 creal_T y[256]);
};

} // namespace internal
} // namespace coder

#endif
// End of code generation (FFTImplementationCallback.h)
