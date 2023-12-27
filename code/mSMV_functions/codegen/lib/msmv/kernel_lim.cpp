//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// kernel_lim.cpp
//
// Code generation for function 'kernel_lim'
//

// Include files
#include "kernel_lim.h"
#include "fftn.h"
#include "ifftn.h"
#include "minOrMax.h"
#include "sphere_kernel.h"
#include <cmath>

// Function Declarations
static double rt_hypotd_snf(double u0, double u1);

// Function Definitions
static double rt_hypotd_snf(double u0, double u1)
{
  double a;
  double y;
  a = std::abs(u0);
  y = std::abs(u1);
  if (a < y) {
    a /= y;
    y *= std::sqrt(a * a + 1.0);
  } else if (a > y) {
    y /= a;
    y = a * std::sqrt(y * y + 1.0);
  } else if (!std::isnan(y)) {
    y = a * 1.4142135623730951;
  }
  return y;
}

double kernel_lim(const double RDF[4849664], const float voxel_size[3],
                  const double Mask[4849664])
{
  static creal_T b_K[4849664];
  static creal_T dcv[4849664];
  static double varargin_1[4849664];
  double t;
  float K;
  //  Kernel limit
  //
  //  Approximates the limit of the maximum field value as the kernel radius
  //  approaches zero
  //
  //  Alexandra G. Roberts
  //  MRI Lab
  //  Cornell University
  //  11/09/2022
  K = 0.5F * coder::internal::minimum(voxel_size);
  t = 0.001;
  while (t < 0.01) {
    double b_re_tmp;
    double re_tmp;
    int idx;
    int k;
    //  Spherical Mean Value operator
    //    y=SMV(iFreq,matrix_size,voxel_size,radius)
    //
    //    output
    //    y - resultant image after SMV
    //
    //    input
    //    iFreq - input image
    //    matrix_size - dimension of the field of view
    //    voxel_size - the size of the voxel
    //    radius - radius of the sphere in mm
    //
    //    Created by Tian Liu in 2010
    //    Last modified by Tian Liu on 2013.07.24
    sphere_kernel(voxel_size, K, b_K);
    //  Spherical Mean Value operator
    //    y=SMV(iFreq,matrix_size,voxel_size,radius)
    //
    //    output
    //    y - resultant image after SMV
    //
    //    input
    //    iFreq - input image
    //    matrix_size - dimension of the field of view
    //    voxel_size - the size of the voxel
    //    radius - radius of the sphere in mm
    //
    //    Created by Tian Liu in 2010
    //    Last modified by Tian Liu on 2013.07.24
    sphere_kernel(voxel_size, K, b_K);
    coder::fftn(RDF, dcv);
    for (idx = 0; idx < 4849664; idx++) {
      double c_re_tmp;
      double d_re_tmp;
      re_tmp = dcv[idx].re;
      b_re_tmp = b_K[idx].im;
      c_re_tmp = dcv[idx].im;
      d_re_tmp = b_K[idx].re;
      dcv[idx].re = re_tmp * d_re_tmp - c_re_tmp * b_re_tmp;
      dcv[idx].im = re_tmp * b_re_tmp + c_re_tmp * d_re_tmp;
    }
    coder::ifftn(dcv, b_K);
    for (k = 0; k < 4849664; k++) {
      re_tmp = Mask[k];
      b_re_tmp = re_tmp * (RDF[k] - b_K[k].re);
      re_tmp *= 0.0 - b_K[k].im;
      b_K[k].re = b_re_tmp;
      b_K[k].im = re_tmp;
      varargin_1[k] = rt_hypotd_snf(b_re_tmp, re_tmp);
    }
    if (!std::isnan(varargin_1[0])) {
      idx = 1;
    } else {
      boolean_T exitg1;
      idx = 0;
      k = 2;
      exitg1 = false;
      while ((!exitg1) && (k < 4849665)) {
        if (!std::isnan(varargin_1[k - 1])) {
          idx = k;
          exitg1 = true;
        } else {
          k++;
        }
      }
    }
    if (idx == 0) {
      t = varargin_1[0];
    } else {
      t = varargin_1[idx - 1];
      idx++;
      for (k = idx; k < 4849665; k++) {
        re_tmp = varargin_1[k - 1];
        if (t < re_tmp) {
          t = re_tmp;
        }
      }
    }
    K += 0.001F;
  }
  return t;
}

// End of code generation (kernel_lim.cpp)
