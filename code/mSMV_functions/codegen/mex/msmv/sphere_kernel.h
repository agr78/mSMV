/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * sphere_kernel.h
 *
 * Code generation for function 'sphere_kernel'
 *
 */

#pragma once

/* Include files */
#include "msmv_types.h"
#include "rtwtypes.h"
#include "covrt.h"
#include "emlrt.h"
#include "mex.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Function Declarations */
void sphere_kernel(msmvStackData *SD, const emlrtStack *sp,
                   const real32_T voxel_size[3], real32_T radius,
                   creal_T y[4849664]);

/* End of code generation (sphere_kernel.h) */
