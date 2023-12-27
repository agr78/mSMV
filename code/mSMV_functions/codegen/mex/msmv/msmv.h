/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * msmv.h
 *
 * Code generation for function 'msmv'
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
void msmv(msmvStackData *SD, const emlrtStack *sp, real_T RDF[4849664],
          const real_T Mask[4849664], const real32_T R2s[4849664],
          const real32_T voxel_size[3], real32_T radius, real32_T maxk,
          real32_T vr, boolean_T pf);

/* End of code generation (msmv.h) */
