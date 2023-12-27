/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * kernel_lim.h
 *
 * Code generation for function 'kernel_lim'
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
real_T kernel_lim(msmvStackData *SD, const emlrtStack *sp,
                  const real_T RDF[4849664], const real32_T voxel_size[3],
                  const real_T Mask[4849664]);

/* End of code generation (kernel_lim.h) */
