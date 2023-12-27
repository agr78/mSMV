/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * fftshift.c
 *
 * Code generation for function 'fftshift'
 *
 */

/* Include files */
#include "fftshift.h"
#include "eml_int_forloop_overflow_check.h"
#include "msmv_data.h"
#include "rt_nonfinite.h"

/* Variable Definitions */
static emlrtRSInfo
    m_emlrtRSI =
        {
            12,         /* lineNo */
            "fftshift", /* fcnName */
            "C:\\Program "
            "Files\\MATLAB\\R2021b\\toolbox\\eml\\lib\\matlab\\datafun\\fftshif"
            "t.m" /* pathName */
};

static emlrtRSInfo n_emlrtRSI = {
    166,            /* lineNo */
    "eml_fftshift", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2021b\\toolbox\\eml\\lib\\matlab\\datafun\\private\\eml_"
    "fftshift.m" /* pathName */
};

static emlrtRSInfo o_emlrtRSI = {
    159,            /* lineNo */
    "eml_fftshift", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2021b\\toolbox\\eml\\lib\\matlab\\datafun\\private\\eml_"
    "fftshift.m" /* pathName */
};

static emlrtRSInfo p_emlrtRSI = {
    156,            /* lineNo */
    "eml_fftshift", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2021b\\toolbox\\eml\\lib\\matlab\\datafun\\private\\eml_"
    "fftshift.m" /* pathName */
};

static emlrtRSInfo q_emlrtRSI = {
    144,            /* lineNo */
    "eml_fftshift", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2021b\\toolbox\\eml\\lib\\matlab\\datafun\\private\\eml_"
    "fftshift.m" /* pathName */
};

static emlrtRSInfo r_emlrtRSI = {
    138,            /* lineNo */
    "eml_fftshift", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2021b\\toolbox\\eml\\lib\\matlab\\datafun\\private\\eml_"
    "fftshift.m" /* pathName */
};

static emlrtRSInfo s_emlrtRSI = {
    135,            /* lineNo */
    "eml_fftshift", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2021b\\toolbox\\eml\\lib\\matlab\\datafun\\private\\eml_"
    "fftshift.m" /* pathName */
};

static emlrtRSInfo t_emlrtRSI = {
    35,             /* lineNo */
    "eml_fftshift", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2021b\\toolbox\\eml\\lib\\matlab\\datafun\\private\\eml_"
    "fftshift.m" /* pathName */
};

static emlrtRSInfo v_emlrtRSI = {
    21,                               /* lineNo */
    "eml_int_forloop_overflow_check", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2021b\\toolbox\\eml\\lib\\matlab\\eml\\eml_int_forloop_"
    "overflow_check.m" /* pathName */
};

/* Function Definitions */
void fftshift(const emlrtStack *sp, real_T x[4849664])
{
  static const int16_T b_iv[3] = {256, 256, 74};
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack st;
  real_T xtmp;
  int32_T b_i;
  int32_T b_i1;
  int32_T dim;
  int32_T i;
  int32_T i2;
  int32_T ib;
  int32_T ic;
  int32_T j;
  int32_T k;
  int32_T midoffset;
  int32_T npages;
  int32_T tmp_tmp;
  int32_T vlend2;
  int32_T vspread;
  int32_T vstride;
  int16_T i1;
  boolean_T b_overflow;
  boolean_T c_overflow;
  boolean_T overflow;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  for (dim = 0; dim < 3; dim++) {
    st.site = &m_emlrtRSI;
    vlend2 = b_iv[dim] / 2;
    b_st.site = &t_emlrtRSI;
    vstride = 1;
    for (k = 0; k < dim; k++) {
      vstride <<= 8;
    }
    npages = 1;
    i = dim + 2;
    for (k = i; k < 4; k++) {
      npages *= b_iv[k - 1];
    }
    i1 = b_iv[dim];
    vspread = (i1 - 1) * vstride;
    midoffset = vlend2 * vstride - 1;
    if (vlend2 << 1 == i1) {
      i2 = 0;
      b_st.site = &s_emlrtRSI;
      overflow = ((1 <= npages) && (npages > 2147483646));
      if (overflow) {
        c_st.site = &v_emlrtRSI;
        check_forloop_overflow_error(&c_st);
      }
      if (0 <= npages - 1) {
        c_overflow = ((1 <= vstride) && (vstride > 2147483646));
      }
      for (b_i = 0; b_i < npages; b_i++) {
        b_i1 = i2;
        i2 += vspread;
        b_st.site = &r_emlrtRSI;
        if (c_overflow) {
          c_st.site = &v_emlrtRSI;
          check_forloop_overflow_error(&c_st);
        }
        for (j = 0; j < vstride; j++) {
          b_i1++;
          i2++;
          ib = b_i1 + midoffset;
          b_st.site = &q_emlrtRSI;
          for (k = 0; k < vlend2; k++) {
            ic = k * vstride;
            tmp_tmp = (b_i1 + ic) - 1;
            xtmp = x[tmp_tmp];
            i = ib + ic;
            x[tmp_tmp] = x[i];
            x[i] = xtmp;
          }
        }
      }
    } else {
      i2 = 0;
      b_st.site = &p_emlrtRSI;
      overflow = ((1 <= npages) && (npages > 2147483646));
      if (overflow) {
        c_st.site = &v_emlrtRSI;
        check_forloop_overflow_error(&c_st);
      }
      if (0 <= npages - 1) {
        b_overflow = ((1 <= vstride) && (vstride > 2147483646));
      }
      for (b_i = 0; b_i < npages; b_i++) {
        b_i1 = i2;
        i2 += vspread;
        b_st.site = &o_emlrtRSI;
        if (b_overflow) {
          c_st.site = &v_emlrtRSI;
          check_forloop_overflow_error(&c_st);
        }
        for (j = 0; j < vstride; j++) {
          b_i1++;
          i2++;
          ib = b_i1 + midoffset;
          xtmp = x[ib];
          b_st.site = &n_emlrtRSI;
          for (k = 0; k < vlend2; k++) {
            ic = ib + vstride;
            i = (b_i1 + k * vstride) - 1;
            x[ib] = x[i];
            x[i] = x[ic];
            ib = ic;
          }
          x[ib] = xtmp;
        }
      }
    }
  }
}

/* End of code generation (fftshift.c) */
