/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * ifftn.c
 *
 * Code generation for function 'ifftn'
 *
 */

/* Include files */
#include "ifftn.h"
#include "msmv_data.h"
#include "msmv_types.h"
#include "rt_nonfinite.h"

/* Function Definitions */
void b_ifftn(msmvStackData *SD, const creal_T x[4849664], creal_T y[4849664])
{
  emlrtFFTWSetNumThreads(8);
  emlrtFFTW_1D_C2C((real_T *)&x[0], (real_T *)&SD->u1.f0.acc[0], 1, 256, 256,
                   18944, 1);
  emlrtFFTWSetNumThreads(8);
  emlrtFFTW_1D_C2C((real_T *)&SD->u1.f0.acc[0], (real_T *)&SD->u1.f0.b_acc[0],
                   256, 256, 256, 18944, 1);
  emlrtFFTWSetNumThreads(8);
  emlrtFFTW_1D_C2C((real_T *)&SD->u1.f0.b_acc[0], (real_T *)&y[0], 65536, 74,
                   74, 65536, 1);
}

void ifftn(msmvStackData *SD, const creal32_T x[4849664], creal32_T y[4849664])
{
  emlrtFFTWSetNumThreads(8);
  emlrtFFTWF_1D_C2C((real32_T *)&x[0], (real32_T *)&SD->u1.f3.acc[0], 1, 256,
                    256, 18944, 1);
  emlrtFFTWSetNumThreads(8);
  emlrtFFTWF_1D_C2C((real32_T *)&SD->u1.f3.acc[0],
                    (real32_T *)&SD->u1.f3.b_acc[0], 256, 256, 256, 18944, 1);
  emlrtFFTWSetNumThreads(8);
  emlrtFFTWF_1D_C2C((real32_T *)&SD->u1.f3.b_acc[0], (real32_T *)&y[0], 65536,
                    74, 74, 65536, 1);
}

/* End of code generation (ifftn.c) */
