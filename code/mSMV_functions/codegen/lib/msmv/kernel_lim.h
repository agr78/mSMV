//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// kernel_lim.h
//
// Code generation for function 'kernel_lim'
//

#ifndef KERNEL_LIM_H
#define KERNEL_LIM_H

// Include files
#include "rtwtypes.h"
#include "omp.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
double kernel_lim(const double RDF[4849664], const float voxel_size[3],
                  const double Mask[4849664]);

#endif
// End of code generation (kernel_lim.h)
