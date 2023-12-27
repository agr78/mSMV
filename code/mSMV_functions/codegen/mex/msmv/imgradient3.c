/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * imgradient3.c
 *
 * Code generation for function 'imgradient3'
 *
 */

/* Include files */
#include "imgradient3.h"
#include "imgradientxyz.h"
#include "msmv_data.h"
#include "msmv_types.h"
#include "rt_nonfinite.h"
#include "mwmathutil.h"

/* Variable Definitions */
static emlrtRSInfo mb_emlrtRSI = {
    23,            /* lineNo */
    "imgradient3", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2021b\\toolbox\\images\\images\\eml\\imgradient3.m" /* pathName
                                                                          */
};

static emlrtRSInfo nb_emlrtRSI = {
    88,            /* lineNo */
    "imgradient3", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2021b\\toolbox\\images\\images\\eml\\imgradient3.m" /* pathName
                                                                          */
};

static emlrtRTEInfo emlrtRTEI = {
    13,     /* lineNo */
    9,      /* colNo */
    "sqrt", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2021b\\toolbox\\eml\\lib\\matlab\\elfun\\sqrt.m" /* pName
                                                                       */
};

/* Function Definitions */
void imgradient3(msmvStackData *SD, const emlrtStack *sp,
                 const real32_T varargin_1[4849664], real32_T Gmag[4849664])
{
  emlrtStack st;
  int32_T k;
  real32_T f;
  boolean_T p;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &mb_emlrtRSI;
  imgradientxyz(SD, &st, varargin_1, SD->u2.f5.Gx, SD->u2.f5.Gy, SD->u2.f5.Gz);
  for (k = 0; k < 4849664; k++) {
    f = SD->u2.f5.Gx[k];
    Gmag[k] = f * f;
    f = SD->u2.f5.Gy[k];
    SD->u2.f5.y[k] = f * f;
    f = SD->u2.f5.Gz[k];
    SD->u2.f5.Gx[k] = f * f;
  }
  st.site = &nb_emlrtRSI;
  p = false;
  for (k = 0; k < 4849664; k++) {
    f = (Gmag[k] + SD->u2.f5.y[k]) + SD->u2.f5.Gx[k];
    Gmag[k] = f;
    if (p || (f < 0.0F)) {
      p = true;
    }
  }
  if (p) {
    emlrtErrorWithMessageIdR2018a(
        &st, &emlrtRTEI, "Coder:toolbox:ElFunDomainError",
        "Coder:toolbox:ElFunDomainError", 3, 4, 4, "sqrt");
  }
  for (k = 0; k < 4849664; k++) {
    Gmag[k] = muSingleScalarSqrt(Gmag[k]);
  }
}

/* End of code generation (imgradient3.c) */
