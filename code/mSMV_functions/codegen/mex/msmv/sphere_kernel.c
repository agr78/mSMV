/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * sphere_kernel.c
 *
 * Code generation for function 'sphere_kernel'
 *
 */

/* Include files */
#include "sphere_kernel.h"
#include "fftn.h"
#include "fftshift.h"
#include "msmv_data.h"
#include "msmv_emxutil.h"
#include "msmv_types.h"
#include "rt_nonfinite.h"
#include "sumMatrixIncludeNaN.h"
#include "mwmathutil.h"

/* Variable Definitions */
static emlrtRSInfo j_emlrtRSI = {
    64,              /* lineNo */
    "sphere_kernel", /* fcnName */
    "C:\\Users\\agr78\\mSMV\\code\\dependencies\\MEDI_functions\\sphere_kernel."
    "m" /* pathName */
};

static emlrtBCInfo emlrtBCI = {
    -1,              /* iFirst */
    -1,              /* iLast */
    50,              /* lineNo */
    12,              /* colNo */
    "X",             /* aName */
    "sphere_kernel", /* fName */
    "C:\\Users\\agr78\\mSMV\\code\\dependencies\\MEDI_functions\\sphere_kernel."
    "m", /* pName */
    0    /* checkKind */
};

static emlrtBCInfo b_emlrtBCI = {
    -1,              /* iFirst */
    -1,              /* iLast */
    51,              /* lineNo */
    12,              /* colNo */
    "Y",             /* aName */
    "sphere_kernel", /* fName */
    "C:\\Users\\agr78\\mSMV\\code\\dependencies\\MEDI_functions\\sphere_kernel."
    "m", /* pName */
    0    /* checkKind */
};

static emlrtBCInfo c_emlrtBCI = {
    -1,              /* iFirst */
    -1,              /* iLast */
    52,              /* lineNo */
    12,              /* colNo */
    "Z",             /* aName */
    "sphere_kernel", /* fName */
    "C:\\Users\\agr78\\mSMV\\code\\dependencies\\MEDI_functions\\sphere_kernel."
    "m", /* pName */
    0    /* checkKind */
};

static emlrtECInfo emlrtECI = {
    -1,              /* nDims */
    60,              /* lineNo */
    1,               /* colNo */
    "sphere_kernel", /* fName */
    "C:\\Users\\agr78\\mSMV\\code\\dependencies\\MEDI_functions\\sphere_kernel."
    "m" /* pName */
};

static emlrtBCInfo d_emlrtBCI = {
    -1,              /* iFirst */
    -1,              /* iLast */
    57,              /* lineNo */
    15,              /* colNo */
    "shell_val",     /* aName */
    "sphere_kernel", /* fName */
    "C:\\Users\\agr78\\mSMV\\code\\dependencies\\MEDI_functions\\sphere_kernel."
    "m", /* pName */
    0    /* checkKind */
};

static emlrtRTEInfo c_emlrtRTEI = {
    47,              /* lineNo */
    1,               /* colNo */
    "sphere_kernel", /* fName */
    "C:\\Users\\agr78\\mSMV\\code\\dependencies\\MEDI_functions\\sphere_kernel."
    "m" /* pName */
};

static emlrtRTEInfo d_emlrtRTEI = {
    17,              /* lineNo */
    14,              /* colNo */
    "sphere_kernel", /* fName */
    "C:\\Users\\agr78\\mSMV\\code\\dependencies\\MEDI_functions\\sphere_kernel."
    "m" /* pName */
};

static emlrtRTEInfo e_emlrtRTEI = {
    44,              /* lineNo */
    7,               /* colNo */
    "sphere_kernel", /* fName */
    "C:\\Users\\agr78\\mSMV\\code\\dependencies\\MEDI_functions\\sphere_kernel."
    "m" /* pName */
};

static emlrtRTEInfo f_emlrtRTEI = {
    45,              /* lineNo */
    7,               /* colNo */
    "sphere_kernel", /* fName */
    "C:\\Users\\agr78\\mSMV\\code\\dependencies\\MEDI_functions\\sphere_kernel."
    "m" /* pName */
};

static emlrtRTEInfo g_emlrtRTEI = {
    46,              /* lineNo */
    7,               /* colNo */
    "sphere_kernel", /* fName */
    "C:\\Users\\agr78\\mSMV\\code\\dependencies\\MEDI_functions\\sphere_kernel."
    "m" /* pName */
};

/* Function Definitions */
void sphere_kernel(msmvStackData *SD, const emlrtStack *sp,
                   const real32_T voxel_size[3], real32_T radius,
                   creal_T y[4849664])
{
  emlrtStack st;
  emxArray_int32_T *r;
  emxArray_int32_T *r1;
  emxArray_int32_T *r2;
  emxArray_real_T *shell_val;
  real_T Z_v[8000];
  real_T s;
  real_T *shell_val_data;
  int32_T i;
  int32_T j;
  int32_T k;
  int32_T nz;
  int32_T *r3;
  int32_T *r4;
  int32_T *r5;
  real32_T b_y[8000];
  real32_T c_y[8000];
  real32_T d_y[8000];
  real32_T Sphere_out_tmp;
  real32_T b_Sphere_out_tmp;
  real32_T c_Sphere_out_tmp;
  real32_T c_tmp;
  real32_T f;
  real32_T f1;
  real32_T f2;
  real32_T f3;
  real32_T f4;
  real32_T f5;
  real32_T f6;
  real32_T f7;
  boolean_T x[8000];
  boolean_T b;
  st.prev = sp;
  st.tls = sp->tls;
  emlrtHeapReferenceStackEnterFcnR2012b((emlrtCTX)sp);
  covrtLogFcn(&emlrtCoverageInstance, 1U, 0U);
  covrtLogBasicBlock(&emlrtCoverageInstance, 1U, 0U);
  /*  Generate a Spherical kernel with the sum normalized to one */
  /*    y = SMV_kernel(matrix_size,voxel_size, radius) */
  /*     */
  /*    output */
  /*    y - kernel */
  /*   */
  /*    input */
  /*    matrix_size - the dimension of the field of view */
  /*    voxel_size - the size of the voxel in mm */
  /*    radius - the raidus of the sphere in mm */
  /*  */
  /*    Created by Tian Liu in 2010 */
  /*    Modified by Tian on 2011.02.01 */
  /*    Modified by Tian on 2011.03.14 The sphere is now rendered. */
  /*    Last modified by Tian Liu on 2013.07.23 */
  for (k = 0; k < 74; k++) {
    for (j = 0; j < 256; j++) {
      for (i = 0; i < 256; i++) {
        nz = (i + (j << 8)) + (k << 16);
        SD->u2.f4.Sphere_mid[nz] = (((real_T)j + 1.0) - 1.0) + -128.0;
        SD->u2.f4.b_X[nz] = (int8_T)(i - 128);
        SD->u2.f4.b_Z[nz] = (int8_T)(k - 37);
      }
    }
  }
  Sphere_out_tmp = 0.5F * voxel_size[0];
  b_Sphere_out_tmp = 0.5F * voxel_size[1];
  c_Sphere_out_tmp = 0.5F * voxel_size[2];
  f = voxel_size[0];
  f1 = voxel_size[1];
  f2 = voxel_size[2];
  for (k = 0; k < 4849664; k++) {
    c_tmp = (real32_T)SD->u2.f4.b_X[k] * f;
    SD->u2.f4.X[k] = c_tmp;
    f3 = (real32_T)SD->u2.f4.Sphere_mid[k] * f1;
    SD->u2.f4.Y[k] = f3;
    f4 = (real32_T)SD->u2.f4.b_Z[k] * f2;
    SD->u2.f4.Z[k] = f4;
    c_tmp = muSingleScalarAbs(c_tmp);
    SD->u2.f4.Sphere_out_tmp[k] = c_tmp;
    f3 = muSingleScalarAbs(f3);
    SD->u2.f4.b_Sphere_out_tmp[k] = f3;
    f4 = muSingleScalarAbs(f4);
    SD->u2.f4.c_Sphere_out_tmp[k] = f4;
    SD->u2.f4.maxval[k] = muSingleScalarMax(c_tmp - Sphere_out_tmp, 0.0F);
    SD->u2.f4.b_maxval[k] = muSingleScalarMax(f3 - b_Sphere_out_tmp, 0.0F);
    SD->u2.f4.c_maxval[k] = muSingleScalarMax(f4 - c_Sphere_out_tmp, 0.0F);
  }
  c_tmp = radius * radius;
  for (k = 0; k < 4849664; k++) {
    f = SD->u2.f4.maxval[k];
    f1 = SD->u2.f4.b_maxval[k];
    f1 *= f1;
    SD->u2.f4.maxval[k] = f1;
    f2 = SD->u2.f4.c_maxval[k];
    SD->u2.f4.Sphere_out[k] = ((f * f + f1) + f2 * f2 > c_tmp);
  }
  for (k = 0; k < 4849664; k++) {
    f = SD->u2.f4.Sphere_out_tmp[k] + Sphere_out_tmp;
    SD->u2.f4.Sphere_out_tmp[k] = f;
    f1 = SD->u2.f4.b_Sphere_out_tmp[k] + b_Sphere_out_tmp;
    SD->u2.f4.b_Sphere_out_tmp[k] = f1;
    f2 = SD->u2.f4.c_Sphere_out_tmp[k] + c_Sphere_out_tmp;
    SD->u2.f4.c_Sphere_out_tmp[k] = f2;
    SD->u2.f4.Sphere_in[k] = ((f * f + f1 * f1) + f2 * f2 <= c_tmp);
    SD->u2.f4.Sphere_mid[k] = 0.0;
  }
  /* such that error is controlled at <1/(2*10) */
  for (k = 0; k < 20; k++) {
    for (j = 0; j < 20; j++) {
      for (i = 0; i < 20; i++) {
        nz = (i + 20 * j) + 400 * k;
        SD->u2.f4.X_v[nz] = (((real_T)j + 1.0) - 1.0) + -9.5;
        SD->u2.f4.Y_v[nz] = (((real_T)i + 1.0) - 1.0) + -9.5;
        Z_v[nz] = (((real_T)k + 1.0) - 1.0) + -9.5;
      }
    }
  }
  for (k = 0; k < 8000; k++) {
    SD->u2.f4.X_v[k] /= 20.0;
    SD->u2.f4.Y_v[k] /= 20.0;
    Z_v[k] /= 20.0;
  }
  j = 0;
  for (i = 0; i < 4849664; i++) {
    if (1 - (SD->u2.f4.Sphere_in[i] + SD->u2.f4.Sphere_out[i]) == 1) {
      j++;
    }
  }
  emxInit_real_T(sp, &shell_val, &c_emlrtRTEI);
  k = shell_val->size[0];
  shell_val->size[0] = j;
  emxEnsureCapacity_real_T(sp, shell_val, k, &c_emlrtRTEI);
  shell_val_data = shell_val->data;
  for (k = 0; k < j; k++) {
    shell_val_data[k] = 0.0;
  }
  j = -1;
  for (i = 0; i < 4849664; i++) {
    if (1 - (SD->u2.f4.Sphere_in[i] + SD->u2.f4.Sphere_out[i]) == 1) {
      j++;
    }
  }
  emxInit_int32_T(sp, &r, &e_emlrtRTEI);
  emxInit_int32_T(sp, &r1, &f_emlrtRTEI);
  emxInit_int32_T(sp, &r2, &g_emlrtRTEI);
  if (0 <= j) {
    f5 = voxel_size[0];
    f6 = voxel_size[1];
    f7 = voxel_size[2];
  }
  for (i = 0; i <= j; i++) {
    covrtLogFor(&emlrtCoverageInstance, 1U, 0U, 0, 1);
    covrtLogBasicBlock(&emlrtCoverageInstance, 1U, 1U);
    nz = 0;
    for (k = 0; k < 4849664; k++) {
      if (1 - (SD->u2.f4.Sphere_in[k] + SD->u2.f4.Sphere_out[k]) == 1) {
        nz++;
      }
    }
    k = r->size[0];
    r->size[0] = nz;
    emxEnsureCapacity_int32_T(sp, r, k, &d_emlrtRTEI);
    r3 = r->data;
    nz = 0;
    for (k = 0; k < 4849664; k++) {
      if (1 - (SD->u2.f4.Sphere_in[k] + SD->u2.f4.Sphere_out[k]) == 1) {
        r3[nz] = k + 1;
        nz++;
      }
    }
    if ((i + 1 < 1) || (i + 1 > r->size[0])) {
      emlrtDynamicBoundsCheckR2012b(i + 1, 1, r->size[0], &emlrtBCI,
                                    (emlrtCTX)sp);
    }
    nz = 0;
    for (k = 0; k < 4849664; k++) {
      if (1 - (SD->u2.f4.Sphere_in[k] + SD->u2.f4.Sphere_out[k]) == 1) {
        nz++;
      }
    }
    k = r1->size[0];
    r1->size[0] = nz;
    emxEnsureCapacity_int32_T(sp, r1, k, &d_emlrtRTEI);
    r4 = r1->data;
    nz = 0;
    for (k = 0; k < 4849664; k++) {
      if (1 - (SD->u2.f4.Sphere_in[k] + SD->u2.f4.Sphere_out[k]) == 1) {
        r4[nz] = k + 1;
        nz++;
      }
    }
    if ((i + 1 < 1) || (i + 1 > r1->size[0])) {
      emlrtDynamicBoundsCheckR2012b(i + 1, 1, r1->size[0], &b_emlrtBCI,
                                    (emlrtCTX)sp);
    }
    nz = 0;
    for (k = 0; k < 4849664; k++) {
      if (1 - (SD->u2.f4.Sphere_in[k] + SD->u2.f4.Sphere_out[k]) == 1) {
        nz++;
      }
    }
    k = r2->size[0];
    r2->size[0] = nz;
    emxEnsureCapacity_int32_T(sp, r2, k, &d_emlrtRTEI);
    r5 = r2->data;
    nz = 0;
    for (k = 0; k < 4849664; k++) {
      if (1 - (SD->u2.f4.Sphere_in[k] + SD->u2.f4.Sphere_out[k]) == 1) {
        r5[nz] = k + 1;
        nz++;
      }
    }
    if ((i + 1 < 1) || (i + 1 > r2->size[0])) {
      emlrtDynamicBoundsCheckR2012b(i + 1, 1, r2->size[0], &c_emlrtBCI,
                                    (emlrtCTX)sp);
    }
    for (k = 0; k < 8000; k++) {
      f = SD->u2.f4.X[r3[i] - 1] + (real32_T)SD->u2.f4.X_v[k] * f5;
      f1 = f * f;
      b_y[k] = f1;
      f = SD->u2.f4.Y[r4[i] - 1] + (real32_T)SD->u2.f4.Y_v[k] * f6;
      f2 = f * f;
      c_y[k] = f2;
      f = SD->u2.f4.Z[r5[i] - 1] + (real32_T)Z_v[k] * f7;
      f *= f;
      d_y[k] = f;
      x[k] = ((f1 + f2) + f <= c_tmp);
    }
    nz = ((b_y[0] + c_y[0]) + d_y[0] <= c_tmp);
    for (k = 0; k < 7999; k++) {
      nz += x[k + 1];
    }
    if (((int32_T)(i + 1U) < 1) || ((int32_T)(i + 1U) > shell_val->size[0])) {
      emlrtDynamicBoundsCheckR2012b((int32_T)(i + 1U), 1, shell_val->size[0],
                                    &d_emlrtBCI, (emlrtCTX)sp);
    }
    shell_val_data[i] = (real_T)nz / 8000.0;
    if (*emlrtBreakCheckR2012bFlagVar != 0) {
      emlrtBreakCheckR2012b((emlrtCTX)sp);
    }
  }
  emxFree_int32_T(sp, &r2);
  emxFree_int32_T(sp, &r1);
  emxFree_int32_T(sp, &r);
  covrtLogFor(&emlrtCoverageInstance, 1U, 0U, 0, 0);
  covrtLogBasicBlock(&emlrtCoverageInstance, 1U, 2U);
  j = 0;
  for (i = 0; i < 4849664; i++) {
    if (1 - (SD->u2.f4.Sphere_in[i] + SD->u2.f4.Sphere_out[i]) == 1) {
      j++;
    }
  }
  if (j != shell_val->size[0]) {
    emlrtSubAssignSizeCheck1dR2017a(j, shell_val->size[0], &emlrtECI,
                                    (emlrtCTX)sp);
  }
  nz = 0;
  for (i = 0; i < 4849664; i++) {
    b = SD->u2.f4.Sphere_in[i];
    if (1 - (b + SD->u2.f4.Sphere_out[i]) == 1) {
      SD->u2.f4.Sphere_mid[i] = shell_val_data[nz];
      nz++;
    }
    SD->u2.f4.Sphere_mid[i] += (real_T)b;
  }
  emxFree_real_T(sp, &shell_val);
  s = sumColumnB4(SD->u2.f4.Sphere_mid, 1);
  for (nz = 0; nz < 1183; nz++) {
    s += sumColumnB4(SD->u2.f4.Sphere_mid, ((nz + 1) << 12) + 1);
  }
  for (k = 0; k < 4849664; k++) {
    SD->u2.f4.Sphere_mid[k] /= s;
  }
  st.site = &j_emlrtRSI;
  fftshift(&st, SD->u2.f4.Sphere_mid);
  fftn(SD, SD->u2.f4.Sphere_mid, y);
  /*  y =y.*fftshift(fermi(matrix_size, voxel_size,
   * max(matrix_size(:).*voxel_size(:))/2,max(matrix_size(:).*voxel_size(:))/256*10));
   */
  emlrtHeapReferenceStackLeaveFcnR2012b((emlrtCTX)sp);
}

/* End of code generation (sphere_kernel.c) */
