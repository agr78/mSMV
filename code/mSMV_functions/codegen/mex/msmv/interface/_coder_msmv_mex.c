/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * _coder_msmv_mex.c
 *
 * Code generation for function '_coder_msmv_mex'
 *
 */

/* Include files */
#include "_coder_msmv_mex.h"
#include "_coder_msmv_api.h"
#include "msmv_data.h"
#include "msmv_initialize.h"
#include "msmv_terminate.h"
#include "msmv_types.h"
#include "rt_nonfinite.h"

/* Function Definitions */
void mexFunction(int32_T nlhs, mxArray *plhs[], int32_T nrhs,
                 const mxArray *prhs[])
{
  msmvStackData *msmvStackDataGlobal = NULL;
  msmvStackDataGlobal = (msmvStackData *)emlrtMxCalloc(
      (size_t)1, (size_t)1U * sizeof(msmvStackData));
  mexAtExit(&msmv_atexit);
  /* Module initialization. */
  msmv_initialize();
  /* Dispatch the entry-point. */
  msmv_mexFunction(msmvStackDataGlobal, nlhs, plhs, nrhs, prhs);
  /* Module termination. */
  msmv_terminate();
  emlrtMxFree(msmvStackDataGlobal);
}

emlrtCTX mexFunctionCreateRootTLS(void)
{
  emlrtCreateRootTLSR2021a(&emlrtRootTLSGlobal, &emlrtContextGlobal, NULL, 1,
                           NULL);
  return emlrtRootTLSGlobal;
}

void msmv_mexFunction(msmvStackData *SD, int32_T nlhs, mxArray *plhs[1],
                      int32_T nrhs, const mxArray *prhs[8])
{
  emlrtStack st = {
      NULL, /* site */
      NULL, /* tls */
      NULL  /* prev */
  };
  const mxArray *outputs;
  st.tls = emlrtRootTLSGlobal;
  /* Check for proper number of arguments. */
  if (nrhs != 8) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:WrongNumberOfInputs", 5, 12, 8, 4,
                        4, "msmv");
  }
  if (nlhs > 1) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:TooManyOutputArguments", 3, 4, 4,
                        "msmv");
  }
  /* Call the function. */
  msmv_api(SD, prhs, &outputs);
  /* Copy over outputs to the caller. */
  emlrtReturnArrays(1, &plhs[0], &outputs);
}

/* End of code generation (_coder_msmv_mex.c) */
