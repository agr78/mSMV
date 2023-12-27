/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * _coder_msmv_api.c
 *
 * Code generation for function '_coder_msmv_api'
 *
 */

/* Include files */
#include "_coder_msmv_api.h"
#include "msmv.h"
#include "msmv_data.h"
#include "msmv_types.h"
#include "rt_nonfinite.h"

/* Variable Definitions */
static const int32_T iv[3] = {256, 256, 74};

/* Function Declarations */
static real_T (
    *b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                        const emlrtMsgIdentifier *parentId))[4849664];

static real32_T (*c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *R2s,
                                     const char_T *identifier))[4849664];

static real32_T (
    *d_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                        const emlrtMsgIdentifier *parentId))[4849664];

static real32_T (*e_emlrt_marshallIn(const emlrtStack *sp,
                                     const mxArray *voxel_size,
                                     const char_T *identifier))[3];

static real_T (*emlrt_marshallIn(const emlrtStack *sp, const mxArray *RDF,
                                 const char_T *identifier))[4849664];

static void emlrt_marshallOut(const real_T u[4849664], const mxArray *y);

static real32_T (*f_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                                     const emlrtMsgIdentifier *parentId))[3];

static real32_T g_emlrt_marshallIn(const emlrtStack *sp, const mxArray *radius,
                                   const char_T *identifier);

static real32_T h_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                                   const emlrtMsgIdentifier *parentId);

static boolean_T i_emlrt_marshallIn(const emlrtStack *sp, const mxArray *pf,
                                    const char_T *identifier);

static boolean_T j_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                                    const emlrtMsgIdentifier *parentId);

static real_T (*k_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                                   const emlrtMsgIdentifier *msgId))[4849664];

static real32_T (*l_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                                     const emlrtMsgIdentifier *msgId))[4849664];

static real32_T (*m_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                                     const emlrtMsgIdentifier *msgId))[3];

static real32_T n_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                                   const emlrtMsgIdentifier *msgId);

static boolean_T o_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                                    const emlrtMsgIdentifier *msgId);

/* Function Definitions */
static real_T (*b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                                   const emlrtMsgIdentifier *parentId))[4849664]
{
  real_T(*y)[4849664];
  y = k_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

static real32_T (*c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *R2s,
                                     const char_T *identifier))[4849664]
{
  emlrtMsgIdentifier thisId;
  real32_T(*y)[4849664];
  thisId.fIdentifier = (const char_T *)identifier;
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  y = d_emlrt_marshallIn(sp, emlrtAlias(R2s), &thisId);
  emlrtDestroyArray(&R2s);
  return y;
}

static real32_T (
    *d_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                        const emlrtMsgIdentifier *parentId))[4849664]
{
  real32_T(*y)[4849664];
  y = l_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

static real32_T (*e_emlrt_marshallIn(const emlrtStack *sp,
                                     const mxArray *voxel_size,
                                     const char_T *identifier))[3]
{
  emlrtMsgIdentifier thisId;
  real32_T(*y)[3];
  thisId.fIdentifier = (const char_T *)identifier;
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  y = f_emlrt_marshallIn(sp, emlrtAlias(voxel_size), &thisId);
  emlrtDestroyArray(&voxel_size);
  return y;
}

static real_T (*emlrt_marshallIn(const emlrtStack *sp, const mxArray *RDF,
                                 const char_T *identifier))[4849664]
{
  emlrtMsgIdentifier thisId;
  real_T(*y)[4849664];
  thisId.fIdentifier = (const char_T *)identifier;
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  y = b_emlrt_marshallIn(sp, emlrtAlias(RDF), &thisId);
  emlrtDestroyArray(&RDF);
  return y;
}

static void emlrt_marshallOut(const real_T u[4849664], const mxArray *y)
{
  emlrtMxSetData((mxArray *)y, (void *)&u[0]);
  emlrtSetDimensions((mxArray *)y, &iv[0], 3);
}

static real32_T (*f_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                                     const emlrtMsgIdentifier *parentId))[3]
{
  real32_T(*y)[3];
  y = m_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

static real32_T g_emlrt_marshallIn(const emlrtStack *sp, const mxArray *radius,
                                   const char_T *identifier)
{
  emlrtMsgIdentifier thisId;
  real32_T y;
  thisId.fIdentifier = (const char_T *)identifier;
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  y = h_emlrt_marshallIn(sp, emlrtAlias(radius), &thisId);
  emlrtDestroyArray(&radius);
  return y;
}

static real32_T h_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                                   const emlrtMsgIdentifier *parentId)
{
  real32_T y;
  y = n_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

static boolean_T i_emlrt_marshallIn(const emlrtStack *sp, const mxArray *pf,
                                    const char_T *identifier)
{
  emlrtMsgIdentifier thisId;
  boolean_T y;
  thisId.fIdentifier = (const char_T *)identifier;
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  y = j_emlrt_marshallIn(sp, emlrtAlias(pf), &thisId);
  emlrtDestroyArray(&pf);
  return y;
}

static boolean_T j_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                                    const emlrtMsgIdentifier *parentId)
{
  boolean_T y;
  y = o_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

static real_T (*k_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                                   const emlrtMsgIdentifier *msgId))[4849664]
{
  real_T(*ret)[4849664];
  emlrtCheckBuiltInR2012b((emlrtCTX)sp, msgId, src, (const char_T *)"double",
                          false, 3U, (void *)&iv[0]);
  ret = (real_T(*)[4849664])emlrtMxGetData(src);
  emlrtDestroyArray(&src);
  return ret;
}

static real32_T (*l_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                                     const emlrtMsgIdentifier *msgId))[4849664]
{
  real32_T(*ret)[4849664];
  emlrtCheckBuiltInR2012b((emlrtCTX)sp, msgId, src, (const char_T *)"single",
                          false, 3U, (void *)&iv[0]);
  ret = (real32_T(*)[4849664])emlrtMxGetData(src);
  emlrtDestroyArray(&src);
  return ret;
}

static real32_T (*m_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                                     const emlrtMsgIdentifier *msgId))[3]
{
  static const int32_T dims = 3;
  real32_T(*ret)[3];
  emlrtCheckBuiltInR2012b((emlrtCTX)sp, msgId, src, (const char_T *)"single",
                          false, 1U, (void *)&dims);
  ret = (real32_T(*)[3])emlrtMxGetData(src);
  emlrtDestroyArray(&src);
  return ret;
}

static real32_T n_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                                   const emlrtMsgIdentifier *msgId)
{
  static const int32_T dims = 0;
  real32_T ret;
  emlrtCheckBuiltInR2012b((emlrtCTX)sp, msgId, src, (const char_T *)"single",
                          false, 0U, (void *)&dims);
  ret = *(real32_T *)emlrtMxGetData(src);
  emlrtDestroyArray(&src);
  return ret;
}

static boolean_T o_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                                    const emlrtMsgIdentifier *msgId)
{
  static const int32_T dims = 0;
  boolean_T ret;
  emlrtCheckBuiltInR2012b((emlrtCTX)sp, msgId, src, (const char_T *)"logical",
                          false, 0U, (void *)&dims);
  ret = *emlrtMxGetLogicals(src);
  emlrtDestroyArray(&src);
  return ret;
}

void msmv_api(msmvStackData *SD, const mxArray *const prhs[8],
              const mxArray **plhs)
{
  emlrtStack st = {
      NULL, /* site */
      NULL, /* tls */
      NULL  /* prev */
  };
  const mxArray *prhs_copy_idx_0;
  real_T(*Mask)[4849664];
  real_T(*RDF)[4849664];
  real32_T(*R2s)[4849664];
  real32_T(*voxel_size)[3];
  real32_T maxk;
  real32_T radius;
  real32_T vr;
  boolean_T pf;
  st.tls = emlrtRootTLSGlobal;
  prhs_copy_idx_0 = emlrtProtectR2012b(prhs[0], 0, true, -1);
  /* Marshall function inputs */
  RDF = emlrt_marshallIn(&st, emlrtAlias(prhs_copy_idx_0), "RDF");
  Mask = emlrt_marshallIn(&st, emlrtAlias(prhs[1]), "Mask");
  R2s = c_emlrt_marshallIn(&st, emlrtAlias(prhs[2]), "R2s");
  voxel_size = e_emlrt_marshallIn(&st, emlrtAlias(prhs[3]), "voxel_size");
  radius = g_emlrt_marshallIn(&st, emlrtAliasP(prhs[4]), "radius");
  maxk = g_emlrt_marshallIn(&st, emlrtAliasP(prhs[5]), "maxk");
  vr = g_emlrt_marshallIn(&st, emlrtAliasP(prhs[6]), "vr");
  pf = i_emlrt_marshallIn(&st, emlrtAliasP(prhs[7]), "pf");
  /* Invoke the target function */
  msmv(SD, &st, *RDF, *Mask, *R2s, *voxel_size, radius, maxk, vr, pf);
  /* Marshall function outputs */
  emlrt_marshallOut(*RDF, prhs_copy_idx_0);
  *plhs = prhs_copy_idx_0;
}

/* End of code generation (_coder_msmv_api.c) */
