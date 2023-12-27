//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// msmv_terminate.cpp
//
// Code generation for function 'msmv_terminate'
//

// Include files
#include "msmv_terminate.h"
#include "msmv_data.h"

// Function Definitions
void msmv_terminate()
{
  omp_destroy_nest_lock(&msmv_nestLockGlobal);
  isInitialized_msmv = false;
}

// End of code generation (msmv_terminate.cpp)
