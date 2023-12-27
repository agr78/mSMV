//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// msmv.cpp
//
// Code generation for function 'msmv'
//

// Include files
#include "msmv.h"
#include "fftn.h"
#include "ifftn.h"
#include "imgradient3.h"
#include "kernel_lim.h"
#include "minOrMax.h"
#include "msmv_data.h"
#include "msmv_initialize.h"
#include "sphere_kernel.h"
#include <cmath>

// Function Definitions
void msmv(double RDF[4849664], const double Mask[4849664],
          const float R2s[4849664], const float voxel_size[3], float radius,
          float maxk, float, boolean_T)
{
  static creal_T K[4849664];
  static creal_T y_tmp[4849664];
  static creal32_T SphereK[4849664];
  static creal32_T b_y_tmp[4849664];
  static double Me[4849664];
  static double x[4849664];
  static float b_Mask[4849664];
  static float fv[4849664];
  static boolean_T Mb[4849664];
  static boolean_T Mv[4849664];
  double b_k;
  double b_re_tmp;
  double bsum;
  double c_re_tmp;
  double re_tmp;
  double t;
  float z;
  int k;
  int nz;
  if (!isInitialized_msmv) {
    msmv_initialize();
  }
  //  Maximum Spherical Mean Value (mSMV)
  //
  //  Samples and removes residual background field via the maximum value
  //  corollary of Green's theorem
  //
  //  Alexandra G. Roberts
  //  MRI Lab
  //  Cornell University
  //  03/31/2022
  //  Get matrix dimensions
  //  Generate kernel with default radius of 5 mm
  z = coder::internal::minimum(voxel_size) / 2.0F;
  //  Default iteration maximum
  //  Default vessel size parameter
  sphere_kernel(voxel_size, radius, y_tmp);
  for (nz = 0; nz < 4849664; nz++) {
    SphereK[nz].re = static_cast<float>(y_tmp[nz].re);
    SphereK[nz].im = static_cast<float>(y_tmp[nz].im);
  }

  coder::fftn(Mask, y_tmp);
  for (nz = 0; nz < 4849664; nz++) {
    float f;
    float f1;
    float y_tmp_im;
    float y_tmp_re;
    y_tmp_re = static_cast<float>(y_tmp[nz].re);
    y_tmp_im = static_cast<float>(y_tmp[nz].im);
    f = SphereK[nz].im;
    f1 = SphereK[nz].re;
    b_y_tmp[nz].re = y_tmp_re * f1 - y_tmp_im * f;
    b_y_tmp[nz].im = y_tmp_re * f + y_tmp_im * f1;
  }
  coder::ifftn(b_y_tmp, SphereK);
  for (nz = 0; nz < 4849664; nz++) {
    Me[nz] = Mask[nz] - static_cast<double>(SphereK[nz].re > 0.999);
  }
  //  Perform initial SMV, then address incorrect values at edge
  //  Calculate threshold using the maximum corollary and kernel limit
  t = kernel_lim(RDF, voxel_size, Mask);
  sphere_kernel(voxel_size, radius + 1.0F, K);
  //  erode the boundary by radius (mm)
  //  Create mask of known background field
  //  Impose minimum vessel radius (Larson et. al)
  for (k = 0; k < 4849664; k++) {
    x[k] = std::abs(Me[k] * RDF[k]);
    bsum = y_tmp[k].re;
    re_tmp = K[k].im;
    b_re_tmp = y_tmp[k].im;
    c_re_tmp = K[k].re;
    K[k].re = bsum * c_re_tmp - b_re_tmp * re_tmp;
    K[k].im = bsum * re_tmp + b_re_tmp * c_re_tmp;
  }
  coder::ifftn(K, y_tmp);
  for (nz = 0; nz < 4849664; nz++) {
    b_Mask[nz] = static_cast<float>(Mask[nz] -
                                    static_cast<double>(y_tmp[nz].re > 0.999)) *
                 R2s[nz];
  }
  coder::imgradient3(b_Mask, fv);
  for (nz = 0; nz < 4849664; nz++) {
    boolean_T b;
    b = (fv[nz] > 0.0F);
    Mv[nz] = b;
    Mb[nz] = ((x[nz] > t) && (!b));
  }
  //  Perform additional filtering on estimated background field
  b_k = 1.0;
  int exitg1;
  do {
    boolean_T guard1{false};
    exitg1 = 0;
    nz = Mb[0];
    for (k = 0; k < 4849663; k++) {
      nz += Mb[k + 1];
    }
    re_tmp = Mask[0];
    for (k = 0; k < 1023; k++) {
      re_tmp += Mask[k + 1];
    }
    for (int ib{0}; ib < 4735; ib++) {
      int xblockoffset;
      xblockoffset = (ib + 1) << 10;
      bsum = Mask[xblockoffset];
      for (k = 0; k < 1023; k++) {
        bsum += Mask[(xblockoffset + k) + 1];
      }
      re_tmp += bsum;
    }
    guard1 = false;
    if (static_cast<double>(nz) / re_tmp > 1.0E-6) {
      guard1 = true;
    } else {
      nz = Mb[0];
      for (k = 0; k < 4849663; k++) {
        nz += Mb[k + 1];
      }
      if (static_cast<double>(nz) / re_tmp == 0.0) {
        guard1 = true;
      } else {
        exitg1 = 1;
      }
    }
    if (guard1) {
      for (k = 0; k < 4849664; k++) {
        Mb[k] = ((std::abs(Me[k] * RDF[k]) > t) && (!Mv[k]));
      }
      sphere_kernel(voxel_size, z + 0.05F, K);
      for (nz = 0; nz < 4849664; nz++) {
        x[nz] = static_cast<double>(Mb[nz]) * RDF[nz];
      }
      coder::fftn(x, y_tmp);
      for (nz = 0; nz < 4849664; nz++) {
        bsum = y_tmp[nz].re;
        re_tmp = K[nz].im;
        b_re_tmp = y_tmp[nz].im;
        c_re_tmp = K[nz].re;
        K[nz].re = bsum * c_re_tmp - b_re_tmp * re_tmp;
        K[nz].im = bsum * re_tmp + b_re_tmp * c_re_tmp;
      }
      coder::ifftn(K, y_tmp);
      for (nz = 0; nz < 4849664; nz++) {
        RDF[nz] = Mask[nz] * (RDF[nz] - y_tmp[nz].re);
      }
      b_k++;
      if (b_k > maxk - 1.0F) {
        exitg1 = 1;
      }
    }
  } while (exitg1 == 0);
  //  Prepare for reconstruction
}

// End of code generation (msmv.cpp)
