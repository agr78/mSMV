/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * imgradientxyz.c
 *
 * Code generation for function 'imgradientxyz'
 *
 */

/* Include files */
#include "imgradientxyz.h"
#include "imfilter.h"
#include "msmv_data.h"
#include "msmv_types.h"
#include "rt_nonfinite.h"

/* Variable Definitions */
static emlrtRSInfo ob_emlrtRSI = {
    62,              /* lineNo */
    "imgradientxyz", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2021b\\toolbox\\images\\images\\eml\\imgradientxyz.m" /* pathName
                                                                            */
};

static emlrtRSInfo pb_emlrtRSI = {
    63,              /* lineNo */
    "imgradientxyz", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2021b\\toolbox\\images\\images\\eml\\imgradientxyz.m" /* pathName
                                                                            */
};

static emlrtRSInfo qb_emlrtRSI = {
    64,              /* lineNo */
    "imgradientxyz", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2021b\\toolbox\\images\\images\\eml\\imgradientxyz.m" /* pathName
                                                                            */
};

/* Function Definitions */
void imgradientxyz(msmvStackData *SD, const emlrtStack *sp,
                   const real32_T varargin_1[4849664], real32_T Gx[4849664],
                   real32_T Gy[4849664], real32_T Gz[4849664])
{
  static const int8_T b_iv[9] = {-1, -3, -1, 0, 0, 0, 1, 3, 1};
  static const int8_T iv1[9] = {-3, -6, -3, 0, 0, 0, 3, 6, 3};
  static const int8_T iv2[9] = {-1, 0, 1, -3, 0, 3, -1, 0, 1};
  static const int8_T iv3[9] = {-3, 0, 3, -6, 0, 6, -3, 0, 3};
  static const int8_T iv4[9] = {-1, -3, -1, -3, -6, -3, -1, -3, -1};
  static const int8_T iv5[9] = {1, 3, 1, 3, 6, 3, 1, 3, 1};
  emlrtStack st;
  real_T hx[27];
  real_T hy[27];
  real_T hz[27];
  int32_T b_hx_tmp;
  int32_T hx_tmp;
  int32_T i;
  int32_T i2;
  int8_T i1;
  st.prev = sp;
  st.tls = sp->tls;
  for (i = 0; i < 3; i++) {
    i1 = b_iv[3 * i];
    hx[3 * i] = i1;
    hx_tmp = 3 * i + 9;
    hx[hx_tmp] = iv1[3 * i];
    b_hx_tmp = 3 * i + 18;
    hx[b_hx_tmp] = i1;
    i1 = iv2[3 * i];
    hy[3 * i] = i1;
    hy[hx_tmp] = iv3[3 * i];
    hy[b_hx_tmp] = i1;
    hz[3 * i] = iv4[3 * i];
    hz[hx_tmp] = 0.0;
    hz[b_hx_tmp] = iv5[3 * i];
    i2 = 3 * i + 1;
    i1 = b_iv[i2];
    hx[i2] = i1;
    hx_tmp = 3 * i + 10;
    hx[hx_tmp] = iv1[i2];
    b_hx_tmp = 3 * i + 19;
    hx[b_hx_tmp] = i1;
    i1 = iv2[i2];
    hy[i2] = i1;
    hy[hx_tmp] = iv3[i2];
    hy[b_hx_tmp] = i1;
    hz[i2] = iv4[i2];
    hz[hx_tmp] = 0.0;
    hz[b_hx_tmp] = iv5[i2];
    i2 = 3 * i + 2;
    i1 = b_iv[i2];
    hx[i2] = i1;
    hx_tmp = 3 * i + 11;
    hx[hx_tmp] = iv1[i2];
    b_hx_tmp = 3 * i + 20;
    hx[b_hx_tmp] = i1;
    i1 = iv2[i2];
    hy[i2] = i1;
    hy[hx_tmp] = iv3[i2];
    hy[b_hx_tmp] = i1;
    hz[i2] = iv4[i2];
    hz[hx_tmp] = 0.0;
    hz[b_hx_tmp] = iv5[i2];
  }
  st.site = &ob_emlrtRSI;
  imfilter(SD, &st, varargin_1, hx, Gx);
  st.site = &pb_emlrtRSI;
  imfilter(SD, &st, varargin_1, hy, Gy);
  st.site = &qb_emlrtRSI;
  imfilter(SD, &st, varargin_1, hz, Gz);
}

/* End of code generation (imgradientxyz.c) */
