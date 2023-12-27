//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// _coder_msmv_api.h
//
// Code generation for function 'msmv'
//

#ifndef _CODER_MSMV_API_H
#define _CODER_MSMV_API_H

// Include files
#include "emlrt.h"
#include "tmwtypes.h"
#include <algorithm>
#include <cstring>

// Variable Declarations
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

// Function Declarations
void msmv(real_T RDF[4849664], real_T Mask[4849664], real32_T R2s[4849664],
          real32_T voxel_size[3], real32_T radius, real32_T maxk, real32_T vr,
          boolean_T pf);

void msmv_api(const mxArray *const prhs[8], const mxArray **plhs);

void msmv_atexit();

void msmv_initialize();

void msmv_terminate();

void msmv_xil_shutdown();

void msmv_xil_terminate();

#endif
// End of code generation (_coder_msmv_api.h)
