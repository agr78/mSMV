//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// msmv_initialize.cpp
//
// Code generation for function 'msmv_initialize'
//

// Include files
#include "msmv_initialize.h"
#include "msmv_data.h"

// Function Definitions
void msmv_initialize()
{
  omp_init_nest_lock(&msmv_nestLockGlobal);
  isInitialized_msmv = true;
}

// End of code generation (msmv_initialize.cpp)
