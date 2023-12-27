//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// ifftn.h
//
// Code generation for function 'ifftn'
//

#ifndef IFFTN_H
#define IFFTN_H

// Include files
#include "rtwtypes.h"
#include "omp.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
namespace coder {
void ifftn(const creal32_T x[4849664], creal32_T y[4849664]);

void ifftn(const creal_T x[4849664], creal_T y[4849664]);

} // namespace coder

#endif
// End of code generation (ifftn.h)
