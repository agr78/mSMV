//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// msmv.h
//
// Code generation for function 'msmv'
//

#ifndef MSMV_H
#define MSMV_H

// Include files
#include "rtwtypes.h"
#include "omp.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
extern void msmv(double RDF[4849664], const double Mask[4849664],
                 const float R2s[4849664], const float voxel_size[3],
                 float radius, float maxk, float vr, boolean_T pf);

#endif
// End of code generation (msmv.h)
