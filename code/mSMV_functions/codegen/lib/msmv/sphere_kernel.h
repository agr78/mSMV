//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// sphere_kernel.h
//
// Code generation for function 'sphere_kernel'
//

#ifndef SPHERE_KERNEL_H
#define SPHERE_KERNEL_H

// Include files
#include "rtwtypes.h"
#include "omp.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
void sphere_kernel(const float voxel_size[3], float radius, creal_T y[4849664]);

#endif
// End of code generation (sphere_kernel.h)
