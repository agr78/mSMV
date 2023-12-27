/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * kernel_lim.c
 *
 * Code generation for function 'kernel_lim'
 *
 */

/* Include files */
#include "kernel_lim.h"
#include "SMV.h"
#include "msmv_data.h"
#include "msmv_types.h"
#include "rt_nonfinite.h"
#include "mwmathutil.h"

/* Variable Definitions */
static emlrtRSInfo ib_emlrtRSI = {
    31,                                                       /* lineNo */
    "kernel_lim",                                             /* fcnName */
    "C:\\Users\\agr78\\MEDI_toolbox\\functions\\kernel_lim.m" /* pathName */
};

static emlrtRSInfo jb_emlrtRSI = {
    32,                                                       /* lineNo */
    "kernel_lim",                                             /* fcnName */
    "C:\\Users\\agr78\\MEDI_toolbox\\functions\\kernel_lim.m" /* pathName */
};

/* Function Definitions */
real_T kernel_lim(msmvStackData *SD, const emlrtStack *sp,
                  const real_T RDF[4849664], const real32_T voxel_size[3],
                  const real_T Mask[4849664])
{
  emlrtStack st;
  real_T im;
  real_T re;
  real_T t;
  int32_T idx;
  int32_T k;
  real32_T K;
  real32_T f;
  boolean_T exitg1;
  st.prev = sp;
  st.tls = sp->tls;
  covrtLogFcn(&emlrtCoverageInstance, 3U, 0U);
  covrtLogBasicBlock(&emlrtCoverageInstance, 3U, 0U);
  /*  Kernel limit */
  /*  */
  /*  Approximates the limit of the maximum field value as the kernel radius */
  /*  approaches zero */
  /*  */
  /*  Alexandra G. Roberts */
  /*  MRI Lab */
  /*  Cornell University */
  /*  11/09/2022 */
  if (!muSingleScalarIsNaN(voxel_size[0])) {
    idx = 1;
  } else {
    idx = 0;
    k = 2;
    exitg1 = false;
    while ((!exitg1) && (k < 4)) {
      if (!muSingleScalarIsNaN(voxel_size[k - 1])) {
        idx = k;
        exitg1 = true;
      } else {
        k++;
      }
    }
  }
  if (idx == 0) {
    K = voxel_size[0];
  } else {
    K = voxel_size[idx - 1];
    idx++;
    for (k = idx; k < 4; k++) {
      f = voxel_size[k - 1];
      if (K > f) {
        K = f;
      }
    }
  }
  K *= 0.5F;
  t = 0.001;
  covrtLogIf(&emlrtCoverageInstance, 3U, 0U, 0, false);
  while (covrtLogWhile(&emlrtCoverageInstance, 3U, 0U, 1, t < 0.01)) {
    covrtLogBasicBlock(&emlrtCoverageInstance, 3U, 2U);
    st.site = &ib_emlrtRSI;
    SMV(SD, &st, RDF, voxel_size, K, SD->f7.RDF_smv);
    st.site = &jb_emlrtRSI;
    SMV(SD, &st, RDF, voxel_size, K, SD->f7.RDF_smv);
    for (k = 0; k < 4849664; k++) {
      im = Mask[k];
      re = im * (RDF[k] - SD->f7.RDF_smv[k].re);
      im *= 0.0 - SD->f7.RDF_smv[k].im;
      SD->f7.RDF_smv[k].re = re;
      SD->f7.RDF_smv[k].im = im;
      SD->f7.varargin_1[k] = muDoubleScalarHypot(re, im);
    }
    if (!muDoubleScalarIsNaN(SD->f7.varargin_1[0])) {
      idx = 1;
    } else {
      idx = 0;
      k = 2;
      exitg1 = false;
      while ((!exitg1) && (k < 4849665)) {
        if (!muDoubleScalarIsNaN(SD->f7.varargin_1[k - 1])) {
          idx = k;
          exitg1 = true;
        } else {
          k++;
        }
      }
    }
    if (idx == 0) {
      t = SD->f7.varargin_1[0];
    } else {
      t = SD->f7.varargin_1[idx - 1];
      idx++;
      for (k = idx; k < 4849665; k++) {
        im = SD->f7.varargin_1[k - 1];
        if (t < im) {
          t = im;
        }
      }
    }
    K += 0.001F;
    if (*emlrtBreakCheckR2012bFlagVar != 0) {
      emlrtBreakCheckR2012b((emlrtCTX)sp);
    }
  }
  return t;
}

/* End of code generation (kernel_lim.c) */
