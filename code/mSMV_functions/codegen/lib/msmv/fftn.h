//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// fftn.h
//
// Code generation for function 'fftn'
//

#ifndef FFTN_H
#define FFTN_H

// Include files
#include "rtwtypes.h"
#include "omp.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
namespace coder {
void fftn(const double x[4849664], creal_T y[4849664]);

}

#endif
// End of code generation (fftn.h)
