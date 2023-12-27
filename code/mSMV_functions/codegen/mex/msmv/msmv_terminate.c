/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * msmv_terminate.c
 *
 * Code generation for function 'msmv_terminate'
 *
 */

/* Include files */
#include "msmv_terminate.h"
#include "_coder_msmv_mex.h"
#include "msmv_data.h"
#include "rt_nonfinite.h"

/* Function Definitions */
void msmv_atexit(void)
{
  emlrtStack st = {
      NULL, /* site */
      NULL, /* tls */
      NULL  /* prev */
  };
  mexFunctionCreateRootTLS();
  st.tls = emlrtRootTLSGlobal;
  emlrtEnterRtStackR2012b(&st);
  /* Free instance data */
  covrtFreeInstanceData(&emlrtCoverageInstance);
  /* Free instance data */
  covrtFreeInstanceData(&emlrtCoverageInstance);
  /* Free instance data */
  covrtFreeInstanceData(&emlrtCoverageInstance);
  /* Free instance data */
  covrtFreeInstanceData(&emlrtCoverageInstance);
  /* Free instance data */
  covrtFreeInstanceData(&emlrtCoverageInstance);
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
  emlrtExitTimeCleanup(&emlrtContextGlobal);
}

void msmv_terminate(void)
{
  emlrtStack st = {
      NULL, /* site */
      NULL, /* tls */
      NULL  /* prev */
  };
  st.tls = emlrtRootTLSGlobal;
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

/* End of code generation (msmv_terminate.c) */
