/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * SMV.c
 *
 * Code generation for function 'SMV'
 *
 */

/* Include files */
#include "SMV.h"
#include "fftn.h"
#include "ifftn.h"
#include "msmv_data.h"
#include "msmv_types.h"
#include "rt_nonfinite.h"
#include "sphere_kernel.h"

/* Variable Definitions */
static emlrtRSInfo kb_emlrtRSI = {
    28,    /* lineNo */
    "SMV", /* fcnName */
    "C:\\Users\\agr78\\mSMV\\code\\dependencies\\MEDI_functions\\SMV.m" /* pathName
                                                                         */
};

/* Function Definitions */
void SMV(msmvStackData *SD, const emlrtStack *sp, const real_T iFreq[4849664],
         const real32_T varargin_2[3], real32_T varargin_3, creal_T y[4849664])
{
  emlrtStack st;
  real_T b_re_tmp;
  real_T d;
  real_T d1;
  real_T re_tmp;
  int32_T i;
  st.prev = sp;
  st.tls = sp->tls;
  covrtLogFcn(&emlrtCoverageInstance, 2U, 0U);
  /*  Spherical Mean Value operator */
  /*    y=SMV(iFreq,matrix_size,voxel_size,radius) */
  /*     */
  /*    output */
  /*    y - resultant image after SMV */
  /*   */
  /*    input */
  /*    iFreq - input image */
  /*    matrix_size - dimension of the field of view */
  /*    voxel_size - the size of the voxel */
  /*    radius - radius of the sphere in mm */
  /*  */
  /*    Created by Tian Liu in 2010 */
  /*    Last modified by Tian Liu on 2013.07.24 */
  covrtLogIf(&emlrtCoverageInstance, 2U, 0U, 0, false);
  covrtLogBasicBlock(&emlrtCoverageInstance, 2U, 1U);
  covrtLogIf(&emlrtCoverageInstance, 2U, 0U, 1, false);
  covrtLogBasicBlock(&emlrtCoverageInstance, 2U, 3U);
  covrtLogBasicBlock(&emlrtCoverageInstance, 2U, 4U);
  st.site = &kb_emlrtRSI;
  sphere_kernel(SD, &st, varargin_2, varargin_3, SD->f6.K);
  covrtLogBasicBlock(&emlrtCoverageInstance, 2U, 5U);
  fftn(SD, iFreq, SD->f6.dcv);
  for (i = 0; i < 4849664; i++) {
    re_tmp = SD->f6.dcv[i].re;
    b_re_tmp = SD->f6.dcv[i].im;
    d = SD->f6.K[i].re;
    d1 = SD->f6.K[i].im;
    SD->f6.dcv[i].re = re_tmp * d - b_re_tmp * d1;
    SD->f6.dcv[i].im = re_tmp * d1 + b_re_tmp * d;
  }
  b_ifftn(SD, SD->f6.dcv, y);
}

/* End of code generation (SMV.c) */
