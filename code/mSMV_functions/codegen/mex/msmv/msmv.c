/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * msmv.c
 *
 * Code generation for function 'msmv'
 *
 */

/* Include files */
#include "msmv.h"
#include "SMV.h"
#include "fftn.h"
#include "ifftn.h"
#include "imgradient3.h"
#include "kernel_lim.h"
#include "msmv_data.h"
#include "msmv_types.h"
#include "rt_nonfinite.h"
#include "sphere_kernel.h"
#include "sumMatrixIncludeNaN.h"
#include "mwmathutil.h"

/* Variable Definitions */
static emlrtRSInfo emlrtRSI = {
    32,                                                 /* lineNo */
    "msmv",                                             /* fcnName */
    "C:\\Users\\agr78\\MEDI_toolbox\\functions\\msmv.m" /* pathName */
};

static emlrtRSInfo b_emlrtRSI = {
    35,                                                 /* lineNo */
    "msmv",                                             /* fcnName */
    "C:\\Users\\agr78\\MEDI_toolbox\\functions\\msmv.m" /* pathName */
};

static emlrtRSInfo c_emlrtRSI = {
    49,                                                 /* lineNo */
    "msmv",                                             /* fcnName */
    "C:\\Users\\agr78\\MEDI_toolbox\\functions\\msmv.m" /* pathName */
};

static emlrtRSInfo d_emlrtRSI = {
    50,                                                 /* lineNo */
    "msmv",                                             /* fcnName */
    "C:\\Users\\agr78\\MEDI_toolbox\\functions\\msmv.m" /* pathName */
};

static emlrtRSInfo e_emlrtRSI = {
    57,                                                 /* lineNo */
    "msmv",                                             /* fcnName */
    "C:\\Users\\agr78\\MEDI_toolbox\\functions\\msmv.m" /* pathName */
};

static emlrtRSInfo f_emlrtRSI = {
    65,                                                 /* lineNo */
    "msmv",                                             /* fcnName */
    "C:\\Users\\agr78\\MEDI_toolbox\\functions\\msmv.m" /* pathName */
};

static emlrtRSInfo lb_emlrtRSI =
    {
        5,           /* lineNo */
        "MaskErode", /* fcnName */
        "C:\\Users\\agr78\\mSMV\\code\\dependencies\\MEDI_functions\\MaskErode."
        "m" /* pathName */
};

static emlrtMCInfo emlrtMCI = {
    44,                                                 /* lineNo */
    9,                                                  /* colNo */
    "msmv",                                             /* fName */
    "C:\\Users\\agr78\\MEDI_toolbox\\functions\\msmv.m" /* pName */
};

static emlrtRSInfo xb_emlrtRSI = {
    44,                                                 /* lineNo */
    "msmv",                                             /* fcnName */
    "C:\\Users\\agr78\\MEDI_toolbox\\functions\\msmv.m" /* pathName */
};

/* Function Declarations */
static void disp(const emlrtStack *sp, const mxArray *m, emlrtMCInfo *location);

/* Function Definitions */
static void disp(const emlrtStack *sp, const mxArray *m, emlrtMCInfo *location)
{
  const mxArray *pArray;
  pArray = m;
  emlrtCallMATLABR2012b((emlrtCTX)sp, 0, NULL, 1, &pArray,
                        (const char_T *)"disp", true, location);
}

void msmv(msmvStackData *SD, const emlrtStack *sp, real_T RDF[4849664],
          const real_T Mask[4849664], const real32_T R2s[4849664],
          const real32_T voxel_size[3], real32_T radius, real32_T maxk,
          real32_T vr, boolean_T pf)
{
  static const int32_T b_iv[2] = {1, 30};
  static const char_T u[30] = {'S', 'k', 'i', 'p', 'p', 'i', 'n', 'g',
                               ' ', 'i', 'n', 'i', 't', 'i', 'a', 'l',
                               ' ', 'S', 'M', 'V', ' ', 'f', 'i', 'l',
                               't', 'e', 'r', 'i', 'n', 'g'};
  emlrtStack b_st;
  emlrtStack st;
  const mxArray *m;
  const mxArray *y;
  real_T b_k;
  real_T b_s;
  real_T s;
  real_T t;
  int32_T exitg2;
  int32_T idx;
  int32_T k;
  real32_T ex;
  real32_T f;
  real32_T f1;
  real32_T im;
  real32_T re;
  boolean_T b;
  boolean_T exitg1;
  boolean_T guard1 = false;
  (void)vr;
  (void)pf;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  covrtLogFcn(&emlrtCoverageInstance, 0U, 0U);
  covrtLogBasicBlock(&emlrtCoverageInstance, 0U, 0U);
  /*  Maximum Spherical Mean Value (mSMV) */
  /*  */
  /*  Samples and removes residual background field via the maximum value */
  /*  corollary of Green's theorem */
  /*  */
  /*  Alexandra G. Roberts */
  /*  MRI Lab */
  /*  Cornell University */
  /*  03/31/2022 */
  /*  Get matrix dimensions */
  /*  Generate kernel with default radius of 5 mm */
  covrtLogIf(&emlrtCoverageInstance, 0U, 0U, 0, false);
  covrtLogBasicBlock(&emlrtCoverageInstance, 0U, 2U);
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
    ex = voxel_size[0];
  } else {
    ex = voxel_size[idx - 1];
    idx++;
    for (k = idx; k < 4; k++) {
      f = voxel_size[k - 1];
      if (ex > f) {
        ex = f;
      }
    }
  }
  ex /= 2.0F;
  /*  Default iteration maximum */
  covrtLogIf(&emlrtCoverageInstance, 0U, 0U, 1, false);
  /*  Default vessel size parameter */
  covrtLogIf(&emlrtCoverageInstance, 0U, 0U, 2, false);
  covrtLogBasicBlock(&emlrtCoverageInstance, 0U, 5U);
  st.site = &emlrtRSI;
  sphere_kernel(SD, &st, voxel_size, radius, SD->f8.dcv);
  for (idx = 0; idx < 4849664; idx++) {
    SD->f8.SphereK[idx].re = (real32_T)SD->f8.dcv[idx].re;
    SD->f8.SphereK[idx].im = (real32_T)SD->f8.dcv[idx].im;
  }
  /*  Partition mask */
  st.site = &b_emlrtRSI;
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
  covrtLogIf(&emlrtCoverageInstance, 2U, 0U, 0, true);
  covrtLogBasicBlock(&emlrtCoverageInstance, 2U, 0U);
  covrtLogBasicBlock(&emlrtCoverageInstance, 2U, 5U);
  fftn(SD, Mask, SD->f8.dcv);
  for (idx = 0; idx < 4849664; idx++) {
    re = (real32_T)SD->f8.dcv[idx].re;
    im = (real32_T)SD->f8.dcv[idx].im;
    f = SD->f8.SphereK[idx].im;
    f1 = SD->f8.SphereK[idx].re;
    SD->f8.fcv[idx].re = re * f1 - im * f;
    SD->f8.fcv[idx].im = re * f + im * f1;
  }
  ifftn(SD, SD->f8.fcv, SD->f8.SphereK);
  for (idx = 0; idx < 4849664; idx++) {
    SD->f8.Me[idx] = Mask[idx] - (real_T)(SD->f8.SphereK[idx].re > 0.999);
  }
  /*  Perform initial SMV, then address incorrect values at edge */
  covrtLogIf(&emlrtCoverageInstance, 0U, 0U, 3, false);
  covrtLogBasicBlock(&emlrtCoverageInstance, 0U, 7U);
  y = NULL;
  m = emlrtCreateCharArray(2, &b_iv[0]);
  emlrtInitCharArrayR2013a((emlrtCTX)sp, 30, m, &u[0]);
  emlrtAssign(&y, m);
  st.site = &xb_emlrtRSI;
  disp(&st, y, &emlrtMCI);
  covrtLogBasicBlock(&emlrtCoverageInstance, 0U, 8U);
  /*  Calculate threshold using the maximum corollary and kernel limit */
  st.site = &c_emlrtRSI;
  t = kernel_lim(SD, &st, RDF, voxel_size, Mask);
  st.site = &d_emlrtRSI;
  covrtLogFcn(&emlrtCoverageInstance, 4U, 0U);
  covrtLogBasicBlock(&emlrtCoverageInstance, 4U, 0U);
  /* MASKERODE  */
  /*  y = MaskErode( m,matrix_size,voxel_size, radius) */
  /*  erode the boundary by radius (mm) */
  b_st.site = &lb_emlrtRSI;
  SMV(SD, &b_st, Mask, voxel_size, radius + 1.0F, SD->f8.dcv);
  for (idx = 0; idx < 4849664; idx++) {
    SD->f8.Mv[idx] = (SD->f8.dcv[idx].re > 0.999);
  }
  /*  erode the boundary by radius (mm) */
  /*  Create mask of known background field */
  /*  Impose minimum vessel radius (Larson et. al) */
  for (k = 0; k < 4849664; k++) {
    SD->f8.x[k] = muDoubleScalarAbs(SD->f8.Me[k] * RDF[k]);
    SD->f8.Mask[k] = (real32_T)(Mask[k] - (real_T)SD->f8.Mv[k]) * R2s[k];
  }
  st.site = &e_emlrtRSI;
  imgradient3(SD, &st, SD->f8.Mask, SD->f8.fv);
  for (idx = 0; idx < 4849664; idx++) {
    b = (SD->f8.fv[idx] > 0.0F);
    SD->f8.Mv[idx] = b;
    SD->f8.Mb[idx] = ((SD->f8.x[idx] > t) && (!b));
  }
  /*  Perform additional filtering on estimated background field */
  b_k = 1.0;
  do {
    exitg2 = 0;
    idx = SD->f8.Mb[0];
    for (k = 0; k < 4849663; k++) {
      idx += SD->f8.Mb[k + 1];
    }
    s = sumColumnB4(Mask, 1);
    b_s = s;
    for (k = 0; k < 1183; k++) {
      b_s += sumColumnB4(Mask, ((k + 1) << 12) + 1);
    }
    guard1 = false;
    if ((real_T)idx / b_s > 1.0E-6) {
      guard1 = true;
    } else {
      idx = SD->f8.Mb[0];
      for (k = 0; k < 4849663; k++) {
        idx += SD->f8.Mb[k + 1];
      }
      for (k = 0; k < 1183; k++) {
        s += sumColumnB4(Mask, ((k + 1) << 12) + 1);
      }
      if ((real_T)idx / s == 0.0) {
        guard1 = true;
      } else {
        covrtLogWhile(&emlrtCoverageInstance, 0U, 0U, 0, false);
        exitg2 = 1;
      }
    }
    if (guard1) {
      covrtLogWhile(&emlrtCoverageInstance, 0U, 0U, 0, true);
      covrtLogBasicBlock(&emlrtCoverageInstance, 0U, 9U);
      for (k = 0; k < 4849664; k++) {
        b = ((muDoubleScalarAbs(SD->f8.Me[k] * RDF[k]) > t) && (!SD->f8.Mv[k]));
        SD->f8.Mb[k] = b;
        SD->f8.x[k] = (real_T)b * RDF[k];
      }
      st.site = &f_emlrtRSI;
      SMV(SD, &st, SD->f8.x, voxel_size, ex + 0.05F, SD->f8.dcv);
      for (idx = 0; idx < 4849664; idx++) {
        RDF[idx] = Mask[idx] * (RDF[idx] - SD->f8.dcv[idx].re);
      }
      b_k++;
      if (*emlrtBreakCheckR2012bFlagVar != 0) {
        emlrtBreakCheckR2012b((emlrtCTX)sp);
      }
      if (covrtLogIf(&emlrtCoverageInstance, 0U, 0U, 4, b_k > maxk - 1.0F)) {
        covrtLogBasicBlock(&emlrtCoverageInstance, 0U, 10U);
        exitg2 = 1;
      }
    }
  } while (exitg2 == 0);
  covrtLogBasicBlock(&emlrtCoverageInstance, 0U, 11U);
  /*  Prepare for reconstruction */
}

/* End of code generation (msmv.c) */
