/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * msmv_initialize.c
 *
 * Code generation for function 'msmv_initialize'
 *
 */

/* Include files */
#include "msmv_initialize.h"
#include "_coder_msmv_mex.h"
#include "msmv_data.h"
#include "rt_nonfinite.h"

/* Function Declarations */
static void msmv_once(void);

/* Function Definitions */
static void msmv_once(void)
{
  mex_InitInfAndNan();
  /* Allocate instance data */
  covrtAllocateInstanceData(&emlrtCoverageInstance);
  /* Initialize Coverage Information */
  covrtScriptInit(&emlrtCoverageInstance,
                  "C:\\Users\\agr78\\MEDI_toolbox\\functions\\msmv.m", 0U, 1U,
                  12U, 5U, 0U, 0U, 0U, 0U, 1U, 0U, 0U);
  /* Initialize Function Information */
  covrtFcnInit(&emlrtCoverageInstance, 0U, 0U, "msmv", 211, -1, 1905);
  /* Initialize Basic Block Information */
  covrtBasicBlockInit(&emlrtCoverageInstance, 0U, 11U, 1888, -1, 1900);
  covrtBasicBlockInit(&emlrtCoverageInstance, 0U, 10U, 1825, -1, 1831);
  covrtBasicBlockInit(&emlrtCoverageInstance, 0U, 9U, 1632, -1, 1790);
  covrtBasicBlockInit(&emlrtCoverageInstance, 0U, 8U, 1045, -1, 1546);
  covrtBasicBlockInit(&emlrtCoverageInstance, 0U, 7U, 973, -1, 985);
  covrtBasicBlockInit(&emlrtCoverageInstance, 0U, 6U, 892, -1, 929);
  covrtBasicBlockInit(&emlrtCoverageInstance, 0U, 5U, 657, -1, 798);
  covrtBasicBlockInit(&emlrtCoverageInstance, 0U, 4U, 615, -1, 641);
  covrtBasicBlockInit(&emlrtCoverageInstance, 0U, 3U, 533, -1, 542);
  covrtBasicBlockInit(&emlrtCoverageInstance, 0U, 2U, 441, -1, 472);
  covrtBasicBlockInit(&emlrtCoverageInstance, 0U, 1U, 417, -1, 428);
  covrtBasicBlockInit(&emlrtCoverageInstance, 0U, 0U, 310, -1, 334);
  /* Initialize If Information */
  covrtIfInit(&emlrtCoverageInstance, 0U, 0U, 394, 408, -1, 436);
  covrtIfInit(&emlrtCoverageInstance, 0U, 1U, 510, 524, -1, 550);
  covrtIfInit(&emlrtCoverageInstance, 0U, 2U, 592, 606, -1, 649);
  covrtIfInit(&emlrtCoverageInstance, 0U, 3U, 869, 883, 959, 1040);
  covrtIfInit(&emlrtCoverageInstance, 0U, 4U, 1799, 1812, 1849, 1850);
  /* Initialize MCDC Information */
  /* Initialize For Information */
  /* Initialize While Information */
  covrtWhileInit(&emlrtCoverageInstance, 0U, 0U, 1551, 1623, 1850);
  /* Initialize Switch Information */
  /* Start callback for coverage engine */
  covrtScriptStart(&emlrtCoverageInstance, 0U);
  /* Allocate instance data */
  covrtAllocateInstanceData(&emlrtCoverageInstance);
  /* Initialize Coverage Information */
  covrtScriptInit(&emlrtCoverageInstance,
                  "C:\\Users\\agr78\\mSMV\\code\\dependencies\\MEDI_"
                  "functions\\sphere_kernel.m",
                  1U, 1U, 3U, 0U, 0U, 0U, 0U, 1U, 0U, 0U, 0U);
  /* Initialize Function Information */
  covrtFcnInit(&emlrtCoverageInstance, 1U, 0U, "sphere_kernel", 475, -1, 1993);
  /* Initialize Basic Block Information */
  covrtBasicBlockInit(&emlrtCoverageInstance, 1U, 2U, 1734, -1, 1863);
  covrtBasicBlockInit(&emlrtCoverageInstance, 1U, 1U, 1505, -1, 1728);
  covrtBasicBlockInit(&emlrtCoverageInstance, 1U, 0U, 535, -1, 1479);
  /* Initialize If Information */
  /* Initialize MCDC Information */
  /* Initialize For Information */
  covrtForInit(&emlrtCoverageInstance, 1U, 0U, 1481, 1500, 1732);
  /* Initialize While Information */
  /* Initialize Switch Information */
  /* Start callback for coverage engine */
  covrtScriptStart(&emlrtCoverageInstance, 1U);
  /* Allocate instance data */
  covrtAllocateInstanceData(&emlrtCoverageInstance);
  /* Initialize Coverage Information */
  covrtScriptInit(
      &emlrtCoverageInstance,
      "C:\\Users\\agr78\\mSMV\\code\\dependencies\\MEDI_functions\\SMV.m", 2U,
      1U, 6U, 2U, 0U, 0U, 0U, 0U, 0U, 0U, 0U);
  /* Initialize Function Information */
  covrtFcnInit(&emlrtCoverageInstance, 2U, 0U, "SMV", 373, -1, 761);
  /* Initialize Basic Block Information */
  covrtBasicBlockInit(&emlrtCoverageInstance, 2U, 5U, 734, -1, 761);
  covrtBasicBlockInit(&emlrtCoverageInstance, 2U, 4U, 680, -1, 728);
  covrtBasicBlockInit(&emlrtCoverageInstance, 2U, 3U, 648, -1, 667);
  covrtBasicBlockInit(&emlrtCoverageInstance, 2U, 2U, 552, -1, 602);
  covrtBasicBlockInit(&emlrtCoverageInstance, 2U, 1U, 463, -1, 515);
  covrtBasicBlockInit(&emlrtCoverageInstance, 2U, 0U, 439, -1, 453);
  /* Initialize If Information */
  covrtIfInit(&emlrtCoverageInstance, 2U, 0U, 412, 434, 454, 732);
  covrtIfInit(&emlrtCoverageInstance, 2U, 1U, 520, 543, 635, 675);
  /* Initialize MCDC Information */
  /* Initialize For Information */
  /* Initialize While Information */
  /* Initialize Switch Information */
  /* Start callback for coverage engine */
  covrtScriptStart(&emlrtCoverageInstance, 2U);
  /* Allocate instance data */
  covrtAllocateInstanceData(&emlrtCoverageInstance);
  /* Initialize Coverage Information */
  covrtScriptInit(&emlrtCoverageInstance,
                  "C:\\Users\\agr78\\MEDI_toolbox\\functions\\kernel_lim.m", 3U,
                  1U, 3U, 1U, 0U, 0U, 0U, 0U, 2U, 0U, 0U);
  /* Initialize Function Information */
  covrtFcnInit(&emlrtCoverageInstance, 3U, 0U, "kernel_lim", 178, -1, 931);
  /* Initialize Basic Block Information */
  covrtBasicBlockInit(&emlrtCoverageInstance, 3U, 2U, 708, -1, 918);
  covrtBasicBlockInit(&emlrtCoverageInstance, 3U, 1U, 373, -1, 583);
  covrtBasicBlockInit(&emlrtCoverageInstance, 3U, 0U, 243, -1, 319);
  /* Initialize If Information */
  covrtIfInit(&emlrtCoverageInstance, 3U, 0U, 320, 334, 676, 930);
  /* Initialize MCDC Information */
  /* Initialize For Information */
  /* Initialize While Information */
  covrtWhileInit(&emlrtCoverageInstance, 3U, 0U, 339, 364, 591);
  covrtWhileInit(&emlrtCoverageInstance, 3U, 1U, 685, 699, 926);
  /* Initialize Switch Information */
  /* Start callback for coverage engine */
  covrtScriptStart(&emlrtCoverageInstance, 3U);
  /* Allocate instance data */
  covrtAllocateInstanceData(&emlrtCoverageInstance);
  /* Initialize Coverage Information */
  covrtScriptInit(
      &emlrtCoverageInstance,
      "C:\\Users\\agr78\\mSMV\\code\\dependencies\\MEDI_functions\\MaskErode.m",
      4U, 1U, 1U, 0U, 0U, 0U, 0U, 0U, 0U, 0U, 0U);
  /* Initialize Function Information */
  covrtFcnInit(&emlrtCoverageInstance, 4U, 0U, "MaskErode", 0, -1, 249);
  /* Initialize Basic Block Information */
  covrtBasicBlockInit(&emlrtCoverageInstance, 4U, 0U, 157, -1, 206);
  /* Initialize If Information */
  /* Initialize MCDC Information */
  /* Initialize For Information */
  /* Initialize While Information */
  /* Initialize Switch Information */
  /* Start callback for coverage engine */
  covrtScriptStart(&emlrtCoverageInstance, 4U);
}

void msmv_initialize(void)
{
  emlrtStack st = {
      NULL, /* site */
      NULL, /* tls */
      NULL  /* prev */
  };
  mexFunctionCreateRootTLS();
  emlrtBreakCheckR2012bFlagVar = emlrtGetBreakCheckFlagAddressR2012b();
  st.tls = emlrtRootTLSGlobal;
  emlrtClearAllocCountR2012b(&st, false, 0U, NULL);
  emlrtEnterRtStackR2012b(&st);
  emlrtLicenseCheckR2012b(&st, (const char_T *)"image_toolbox", 2);
  if (emlrtFirstTimeR2012b(emlrtRootTLSGlobal)) {
    msmv_once();
  }
}

/* End of code generation (msmv_initialize.c) */
