/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * msmv_types.h
 *
 * Code generation for function 'msmv'
 *
 */

#pragma once

/* Include files */
#include "rtwtypes.h"
#include "emlrt.h"

/* Type Definitions */
#ifndef struct_emxArray_real_T
#define struct_emxArray_real_T
struct emxArray_real_T {
  real_T *data;
  int32_T *size;
  int32_T allocatedSize;
  int32_T numDimensions;
  boolean_T canFreeData;
};
#endif /* struct_emxArray_real_T */
#ifndef typedef_emxArray_real_T
#define typedef_emxArray_real_T
typedef struct emxArray_real_T emxArray_real_T;
#endif /* typedef_emxArray_real_T */

#ifndef struct_emxArray_int32_T
#define struct_emxArray_int32_T
struct emxArray_int32_T {
  int32_T *data;
  int32_T *size;
  int32_T allocatedSize;
  int32_T numDimensions;
  boolean_T canFreeData;
};
#endif /* struct_emxArray_int32_T */
#ifndef typedef_emxArray_int32_T
#define typedef_emxArray_int32_T
typedef struct emxArray_int32_T emxArray_int32_T;
#endif /* typedef_emxArray_int32_T */

#ifndef typedef_c_ifftn
#define typedef_c_ifftn
typedef struct {
  creal_T acc[4849664];
  creal_T b_acc[4849664];
} c_ifftn;
#endif /* typedef_c_ifftn */

#ifndef typedef_b_fftn
#define typedef_b_fftn
typedef struct {
  creal_T acc[4849664];
  creal_T b_acc[4849664];
} b_fftn;
#endif /* typedef_b_fftn */

#ifndef typedef_b_imfilter
#define typedef_b_imfilter
typedef struct {
  real32_T a[5058864];
} b_imfilter;
#endif /* typedef_b_imfilter */

#ifndef typedef_d_ifftn
#define typedef_d_ifftn
typedef struct {
  creal32_T acc[4849664];
  creal32_T b_acc[4849664];
} d_ifftn;
#endif /* typedef_d_ifftn */

#ifndef typedef_b_sphere_kernel
#define typedef_b_sphere_kernel
typedef struct {
  real_T Sphere_mid[4849664];
  real32_T X[4849664];
  real32_T Y[4849664];
  real32_T Z[4849664];
  real32_T Sphere_out_tmp[4849664];
  real32_T maxval[4849664];
  real32_T b_Sphere_out_tmp[4849664];
  real32_T b_maxval[4849664];
  real32_T c_Sphere_out_tmp[4849664];
  real32_T c_maxval[4849664];
  int8_T b_X[4849664];
  int8_T b_Z[4849664];
  boolean_T Sphere_out[4849664];
  boolean_T Sphere_in[4849664];
  real_T X_v[8000];
  real_T Y_v[8000];
} b_sphere_kernel;
#endif /* typedef_b_sphere_kernel */

#ifndef typedef_b_imgradient3
#define typedef_b_imgradient3
typedef struct {
  real32_T Gx[4849664];
  real32_T Gy[4849664];
  real32_T Gz[4849664];
  real32_T y[4849664];
} b_imgradient3;
#endif /* typedef_b_imgradient3 */

#ifndef typedef_b_SMV
#define typedef_b_SMV
typedef struct {
  creal_T K[4849664];
  creal_T dcv[4849664];
} b_SMV;
#endif /* typedef_b_SMV */

#ifndef typedef_b_kernel_lim
#define typedef_b_kernel_lim
typedef struct {
  creal_T RDF_smv[4849664];
  real_T varargin_1[4849664];
} b_kernel_lim;
#endif /* typedef_b_kernel_lim */

#ifndef typedef_b_msmv
#define typedef_b_msmv
typedef struct {
  creal_T dcv[4849664];
  creal32_T SphereK[4849664];
  creal32_T fcv[4849664];
  real_T Me[4849664];
  real_T x[4849664];
  real32_T Mask[4849664];
  real32_T fv[4849664];
  boolean_T Mv[4849664];
  boolean_T Mb[4849664];
} b_msmv;
#endif /* typedef_b_msmv */

#ifndef typedef_msmvStackData
#define typedef_msmvStackData
typedef struct {
  union {
    c_ifftn f0;
    b_fftn f1;
    b_imfilter f2;
    d_ifftn f3;
  } u1;
  union {
    b_sphere_kernel f4;
    b_imgradient3 f5;
  } u2;
  b_SMV f6;
  b_kernel_lim f7;
  b_msmv f8;
} msmvStackData;
#endif /* typedef_msmvStackData */

/* End of code generation (msmv_types.h) */
