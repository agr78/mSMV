//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// sphere_kernel.cpp
//
// Code generation for function 'sphere_kernel'
//

// Include files
#include "sphere_kernel.h"
#include "fftn.h"
#include "coder_array.h"
#include <cmath>

// Function Definitions
void sphere_kernel(const float voxel_size[3], float radius, creal_T y[4849664])
{
  static double Sphere_mid[4849664];
  static double X_v[8000];
  static double Y_v[8000];
  static float Y[4849664];
  static float b_X[4849664];
  static float b_Z[4849664];
  static const short iv[3]{256, 256, 74};
  static signed char X[4849664];
  static signed char Z[4849664];
  static boolean_T Sphere_in[4849664];
  static boolean_T Sphere_out[4849664];
  coder::array<double, 1U> shell_val;
  coder::array<int, 1U> r;
  coder::array<int, 1U> r1;
  coder::array<int, 1U> r2;
  double Z_v[8000];
  double b_y;
  double bsum;
  float c_y[8000];
  float d_y[8000];
  float e_y[8000];
  float Sphere_out_tmp;
  float b_Sphere_out_tmp;
  float c_Sphere_out_tmp;
  float c_tmp;
  float f;
  float f1;
  float f10;
  float f11;
  float f2;
  float f9;
  int Sphere_mid_tmp;
  int i;
  int ib;
  int j;
  int k;
  int nz;
  int partialTrueCount;
  int vspread;
  boolean_T x[8000];
  //  Generate a Spherical kernel with the sum normalized to one
  //    y = SMV_kernel(matrix_size,voxel_size, radius)
  //
  //    output
  //    y - kernel
  //
  //    input
  //    matrix_size - the dimension of the field of view
  //    voxel_size - the size of the voxel in mm
  //    radius - the raidus of the sphere in mm
  //
  //    Created by Tian Liu in 2010
  //    Modified by Tian on 2011.02.01
  //    Modified by Tian on 2011.03.14 The sphere is now rendered.
  //    Last modified by Tian Liu on 2013.07.23
  for (k = 0; k < 74; k++) {
    for (j = 0; j < 256; j++) {
      for (i = 0; i < 256; i++) {
        Sphere_mid_tmp = (i + (j << 8)) + (k << 16);
        Sphere_mid[Sphere_mid_tmp] =
            ((static_cast<double>(j) + 1.0) - 1.0) + -128.0;
        X[Sphere_mid_tmp] = static_cast<signed char>(i - 128);
        Z[Sphere_mid_tmp] = static_cast<signed char>(k - 37);
      }
    }
  }
  Sphere_out_tmp = 0.5F * voxel_size[0];
  b_Sphere_out_tmp = 0.5F * voxel_size[1];
  c_Sphere_out_tmp = 0.5F * voxel_size[2];
  c_tmp = radius * radius;
  f = voxel_size[0];
  f1 = voxel_size[1];
  f2 = voxel_size[2];
  for (k = 0; k < 4849664; k++) {
    float f3;
    float f4;
    float f5;
    float f6;
    float f7;
    float f8;
    f3 = static_cast<float>(X[k]) * f;
    b_X[k] = f3;
    f4 = static_cast<float>(Sphere_mid[k]) * f1;
    Y[k] = f4;
    f5 = static_cast<float>(Z[k]) * f2;
    b_Z[k] = f5;
    f3 = std::abs(f3);
    f4 = std::abs(f4);
    f5 = std::abs(f5);
    f6 = std::fmax(f3 - Sphere_out_tmp, 0.0F);
    f7 = std::fmax(f4 - b_Sphere_out_tmp, 0.0F);
    f8 = std::fmax(f5 - c_Sphere_out_tmp, 0.0F);
    Sphere_out[k] = ((f6 * f6 + f7 * f7) + f8 * f8 > c_tmp);
    f3 += Sphere_out_tmp;
    f4 += b_Sphere_out_tmp;
    f5 += c_Sphere_out_tmp;
    Sphere_in[k] = ((f3 * f3 + f4 * f4) + f5 * f5 <= c_tmp);
    Sphere_mid[k] = 0.0;
  }
  // such that error is controlled at <1/(2*10)
  for (k = 0; k < 20; k++) {
    for (j = 0; j < 20; j++) {
      for (i = 0; i < 20; i++) {
        nz = (i + 20 * j) + 400 * k;
        X_v[nz] = ((static_cast<double>(j) + 1.0) - 1.0) + -9.5;
        Y_v[nz] = ((static_cast<double>(i) + 1.0) - 1.0) + -9.5;
        Z_v[nz] = ((static_cast<double>(k) + 1.0) - 1.0) + -9.5;
      }
    }
  }
  for (nz = 0; nz < 8000; nz++) {
    X_v[nz] /= 20.0;
    Y_v[nz] /= 20.0;
    Z_v[nz] /= 20.0;
  }
  vspread = 0;
  for (i = 0; i < 4849664; i++) {
    if (1 - (Sphere_in[i] + Sphere_out[i]) == 1) {
      vspread++;
    }
  }
  shell_val.set_size(vspread);
  for (nz = 0; nz < vspread; nz++) {
    shell_val[nz] = 0.0;
  }
  vspread = -1;
  for (i = 0; i < 4849664; i++) {
    if (1 - (Sphere_in[i] + Sphere_out[i]) == 1) {
      vspread++;
    }
  }
  if (0 <= vspread) {
    f9 = voxel_size[0];
    f10 = voxel_size[1];
    f11 = voxel_size[2];
  }
  for (i = 0; i <= vspread; i++) {
    nz = 0;
    for (Sphere_mid_tmp = 0; Sphere_mid_tmp < 4849664; Sphere_mid_tmp++) {
      if (1 - (Sphere_in[Sphere_mid_tmp] + Sphere_out[Sphere_mid_tmp]) == 1) {
        nz++;
      }
    }
    r.set_size(nz);
    partialTrueCount = 0;
    nz = 0;
    for (Sphere_mid_tmp = 0; Sphere_mid_tmp < 4849664; Sphere_mid_tmp++) {
      if (1 - (Sphere_in[Sphere_mid_tmp] + Sphere_out[Sphere_mid_tmp]) == 1) {
        r[partialTrueCount] = Sphere_mid_tmp + 1;
        partialTrueCount++;
        nz++;
      }
    }
    r1.set_size(nz);
    partialTrueCount = 0;
    nz = 0;
    for (Sphere_mid_tmp = 0; Sphere_mid_tmp < 4849664; Sphere_mid_tmp++) {
      if (1 - (Sphere_in[Sphere_mid_tmp] + Sphere_out[Sphere_mid_tmp]) == 1) {
        r1[partialTrueCount] = Sphere_mid_tmp + 1;
        partialTrueCount++;
        nz++;
      }
    }
    r2.set_size(nz);
    partialTrueCount = 0;
    for (Sphere_mid_tmp = 0; Sphere_mid_tmp < 4849664; Sphere_mid_tmp++) {
      if (1 - (Sphere_in[Sphere_mid_tmp] + Sphere_out[Sphere_mid_tmp]) == 1) {
        r2[partialTrueCount] = Sphere_mid_tmp + 1;
        partialTrueCount++;
      }
    }
    for (k = 0; k < 8000; k++) {
      f = b_X[r[i] - 1] + static_cast<float>(X_v[k]) * f9;
      f1 = f * f;
      c_y[k] = f1;
      f = Y[r1[i] - 1] + static_cast<float>(Y_v[k]) * f10;
      f2 = f * f;
      d_y[k] = f2;
      f = b_Z[r2[i] - 1] + static_cast<float>(Z_v[k]) * f11;
      f *= f;
      e_y[k] = f;
      x[k] = ((f1 + f2) + f <= c_tmp);
    }
    nz = ((c_y[0] + d_y[0]) + e_y[0] <= c_tmp);
    for (k = 0; k < 7999; k++) {
      nz += x[k + 1];
    }
    shell_val[i] = static_cast<double>(nz) / 8000.0;
  }
  partialTrueCount = 0;
  for (i = 0; i < 4849664; i++) {
    boolean_T b;
    b = Sphere_in[i];
    if (1 - (b + Sphere_out[i]) == 1) {
      Sphere_mid[i] = shell_val[partialTrueCount];
      partialTrueCount++;
    }
    Sphere_mid[i] += static_cast<double>(b);
  }
  b_y = Sphere_mid[0];
  for (k = 0; k < 1023; k++) {
    b_y += Sphere_mid[k + 1];
  }
  for (ib = 0; ib < 4735; ib++) {
    nz = (ib + 1) << 10;
    bsum = Sphere_mid[nz];
    for (k = 0; k < 1023; k++) {
      bsum += Sphere_mid[(nz + k) + 1];
    }
    b_y += bsum;
  }
  for (nz = 0; nz < 4849664; nz++) {
    Sphere_mid[nz] /= b_y;
  }
  for (int dim{0}; dim < 3; dim++) {
    int midoffset;
    int npages;
    int vlend2;
    int vstride;
    short b_i;
    vlend2 = iv[dim] / 2;
    vstride = 1;
    for (k = 0; k < dim; k++) {
      vstride <<= 8;
    }
    npages = 1;
    nz = dim + 2;
    for (k = nz; k < 4; k++) {
      npages *= iv[k - 1];
    }
    b_i = iv[dim];
    vspread = (b_i - 1) * vstride;
    midoffset = vlend2 * vstride - 1;
    if (vlend2 << 1 == b_i) {
      int i2;
      i2 = 0;
      for (i = 0; i < npages; i++) {
        int i1;
        i1 = i2;
        i2 += vspread;
        for (j = 0; j < vstride; j++) {
          i1++;
          i2++;
          ib = i1 + midoffset;
          for (k = 0; k < vlend2; k++) {
            nz = k * vstride;
            partialTrueCount = (i1 + nz) - 1;
            bsum = Sphere_mid[partialTrueCount];
            Sphere_mid_tmp = ib + nz;
            Sphere_mid[partialTrueCount] = Sphere_mid[Sphere_mid_tmp];
            Sphere_mid[Sphere_mid_tmp] = bsum;
          }
        }
      }
    } else {
      int i2;
      i2 = 0;
      for (i = 0; i < npages; i++) {
        int i1;
        i1 = i2;
        i2 += vspread;
        for (j = 0; j < vstride; j++) {
          i1++;
          i2++;
          ib = i1 + midoffset;
          bsum = Sphere_mid[ib];
          for (k = 0; k < vlend2; k++) {
            nz = ib + vstride;
            Sphere_mid_tmp = (i1 + k * vstride) - 1;
            Sphere_mid[ib] = Sphere_mid[Sphere_mid_tmp];
            Sphere_mid[Sphere_mid_tmp] = Sphere_mid[nz];
            ib = nz;
          }
          Sphere_mid[ib] = bsum;
        }
      }
    }
  }
  coder::fftn(Sphere_mid, y);
  //  y =y.*fftshift(fermi(matrix_size, voxel_size,
  //  max(matrix_size(:).*voxel_size(:))/2,max(matrix_size(:).*voxel_size(:))/256*10));
}

// End of code generation (sphere_kernel.cpp)
