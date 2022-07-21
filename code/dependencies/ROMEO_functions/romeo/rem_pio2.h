#ifndef REM_PIO2_H__
#define REM_PIO2_H__
#include <sys/types.h>

#if defined (_WIN32)
typedef unsigned __int32 u_int32_t;
typedef unsigned __int64 u_int64_t;
#endif

typedef union
{
  double value;
  struct
  {
    u_int32_t lsw;
    u_int32_t msw;
  } parts;
  struct
  {
    u_int64_t w;
  } xparts;
} ieee_double_shape_type;

/* Get the more significant 32 bit int from a double.  */

#define GET_HIGH_WORD(i,d)			\
do {								\
  ieee_double_shape_type gh_u;		\
  gh_u.value = (d);					\
  (i) = gh_u.parts.msw;				\
} while (0)

#define GET_LOW_WORD(i,d)			\
do {								\
  ieee_double_shape_type gl_u;		\
  gl_u.value = (d);					\
  (i) = gl_u.parts.lsw;				\
} while (0)

#define INSERT_WORDS(d,ix0,ix1)					\
do {								\
  ieee_double_shape_type iw_u;					\
  iw_u.parts.msw = (ix0);					\
  iw_u.parts.lsw = (ix1);					\
  (d) = iw_u.value;						\
} while (0)

/* Set a double from a 64-bit int. */
#define INSERT_WORD64(d,ix)					\
do {								\
  ieee_double_shape_type iw_u;					\
  iw_u.xparts.w = (ix);						\
  (d) = iw_u.value;						\
} while (0)

//VBS
#define	STRICT_ASSIGN(type, lval, rval)	((lval) = (rval))

#endif
