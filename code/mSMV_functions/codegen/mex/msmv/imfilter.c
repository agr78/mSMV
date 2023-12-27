/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * imfilter.c
 *
 * Code generation for function 'imfilter'
 *
 */

/* Include files */
#include "imfilter.h"
#include "msmv_data.h"
#include "msmv_types.h"
#include "rt_nonfinite.h"
#include "libmwimfilter.h"

/* Variable Definitions */
static emlrtRSInfo rb_emlrtRSI = {
    106,        /* lineNo */
    "imfilter", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2021b\\toolbox\\images\\images\\eml\\imfilter.m" /* pathName
                                                                       */
};

static emlrtRSInfo sb_emlrtRSI = {
    110,        /* lineNo */
    "imfilter", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2021b\\toolbox\\images\\images\\eml\\imfilter.m" /* pathName
                                                                       */
};

static emlrtRSInfo tb_emlrtRSI = {
    854,        /* lineNo */
    "padImage", /* fcnName */
    "C:\\Program "
    "Files\\MATLAB\\R2021b\\toolbox\\images\\images\\eml\\imfilter.m" /* pathName
                                                                       */
};

static emlrtBCInfo e_emlrtBCI = {
    1,          /* iFirst */
    256,        /* iLast */
    93,         /* lineNo */
    38,         /* colNo */
    "",         /* aName */
    "padarray", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2021b\\toolbox\\images\\images\\eml\\padarray.m", /* pName
                                                                        */
    0 /* checkKind */
};

static emlrtBCInfo f_emlrtBCI = {
    1,          /* iFirst */
    256,        /* iLast */
    93,         /* lineNo */
    48,         /* colNo */
    "",         /* aName */
    "padarray", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2021b\\toolbox\\images\\images\\eml\\padarray.m", /* pName
                                                                        */
    0 /* checkKind */
};

static emlrtBCInfo g_emlrtBCI = {
    1,          /* iFirst */
    74,         /* iLast */
    93,         /* lineNo */
    59,         /* colNo */
    "",         /* aName */
    "padarray", /* fName */
    "C:\\Program "
    "Files\\MATLAB\\R2021b\\toolbox\\images\\images\\eml\\padarray.m", /* pName
                                                                        */
    0 /* checkKind */
};

/* Function Definitions */
void imfilter(msmvStackData *SD, const emlrtStack *sp,
              const real32_T varargin_1[4849664], const real_T varargin_2[27],
              real32_T b[4849664])
{
  static const real_T outSizeT[3] = {256.0, 256.0, 74.0};
  static const real_T padSizeT[3] = {258.0, 258.0, 76.0};
  static const int16_T idxA[774] = {
      1,   1,   2,   3,   4,   5,   6,   7,   8,   9,   10,  11,  12,  13,  14,
      15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,  27,  28,  29,
      30,  31,  32,  33,  34,  35,  36,  37,  38,  39,  40,  41,  42,  43,  44,
      45,  46,  47,  48,  49,  50,  51,  52,  53,  54,  55,  56,  57,  58,  59,
      60,  61,  62,  63,  64,  65,  66,  67,  68,  69,  70,  71,  72,  73,  74,
      75,  76,  77,  78,  79,  80,  81,  82,  83,  84,  85,  86,  87,  88,  89,
      90,  91,  92,  93,  94,  95,  96,  97,  98,  99,  100, 101, 102, 103, 104,
      105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119,
      120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134,
      135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149,
      150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164,
      165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179,
      180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194,
      195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209,
      210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224,
      225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239,
      240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254,
      255, 256, 256, 1,   1,   2,   3,   4,   5,   6,   7,   8,   9,   10,  11,
      12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,
      27,  28,  29,  30,  31,  32,  33,  34,  35,  36,  37,  38,  39,  40,  41,
      42,  43,  44,  45,  46,  47,  48,  49,  50,  51,  52,  53,  54,  55,  56,
      57,  58,  59,  60,  61,  62,  63,  64,  65,  66,  67,  68,  69,  70,  71,
      72,  73,  74,  75,  76,  77,  78,  79,  80,  81,  82,  83,  84,  85,  86,
      87,  88,  89,  90,  91,  92,  93,  94,  95,  96,  97,  98,  99,  100, 101,
      102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116,
      117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131,
      132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146,
      147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161,
      162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176,
      177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191,
      192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206,
      207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221,
      222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236,
      237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251,
      252, 253, 254, 255, 256, 256, 1,   1,   2,   3,   4,   5,   6,   7,   8,
      9,   10,  11,  12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  23,
      24,  25,  26,  27,  28,  29,  30,  31,  32,  33,  34,  35,  36,  37,  38,
      39,  40,  41,  42,  43,  44,  45,  46,  47,  48,  49,  50,  51,  52,  53,
      54,  55,  56,  57,  58,  59,  60,  61,  62,  63,  64,  65,  66,  67,  68,
      69,  70,  71,  72,  73,  74,  74,  0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0};
  emlrtStack b_st;
  emlrtStack st;
  real_T nonzero_h_data[27];
  real_T connDimsT[3];
  real_T startT[3];
  int32_T b_i;
  int32_T i;
  int32_T j;
  int32_T k;
  int32_T partialTrueCount;
  int16_T i1;
  int8_T tmp_data[27];
  boolean_T connb[27];
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &rb_emlrtRSI;
  b_st.prev = &st;
  b_st.tls = st.tls;
  b_st.site = &tb_emlrtRSI;
  for (k = 0; k < 76; k++) {
    i = idxA[k + 516];
    for (j = 0; j < 258; j++) {
      partialTrueCount = idxA[j + 258];
      for (b_i = 0; b_i < 258; b_i++) {
        i1 = idxA[b_i];
        if (i1 < 1) {
          emlrtDynamicBoundsCheckR2012b(0, 1, 256, &e_emlrtBCI, &b_st);
        }
        if (partialTrueCount < 1) {
          emlrtDynamicBoundsCheckR2012b(0, 1, 256, &f_emlrtBCI, &b_st);
        }
        if ((i < 1) || (i > 74)) {
          emlrtDynamicBoundsCheckR2012b(i, 1, 74, &g_emlrtBCI, &b_st);
        }
        SD->u1.f2.a[(b_i + 258 * j) + 66564 * k] = varargin_1
            [((i1 + ((partialTrueCount - 1) << 8)) + ((i - 1) << 16)) - 1];
      }
    }
  }
  st.site = &sb_emlrtRSI;
  k = 0;
  partialTrueCount = 0;
  for (b_i = 0; b_i < 27; b_i++) {
    if (varargin_2[b_i] != 0.0) {
      k++;
      tmp_data[partialTrueCount] = (int8_T)(b_i + 1);
      partialTrueCount++;
    }
  }
  for (i = 0; i < k; i++) {
    nonzero_h_data[i] = varargin_2[tmp_data[i] - 1];
  }
  for (i = 0; i < 27; i++) {
    connb[i] = (varargin_2[i] != 0.0);
  }
  connDimsT[0] = 3.0;
  startT[0] = 1.0;
  connDimsT[1] = 3.0;
  startT[1] = 1.0;
  connDimsT[2] = 3.0;
  startT[2] = 1.0;
  imfilter_real32(&SD->u1.f2.a[0], &b[0], 3.0, &outSizeT[0], 3.0, &padSizeT[0],
                  &nonzero_h_data[0], (real_T)k, &connb[0], 3.0, &connDimsT[0],
                  &startT[0], 3.0, true, false);
}

/* End of code generation (imfilter.c) */
