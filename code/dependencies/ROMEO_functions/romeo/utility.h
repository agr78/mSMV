#ifndef ROMEO_UTILITY_H__
#define ROMEO_UTILITY_H__
#include "carray.h"
#include <stddef.h>
#include <vector>

#define PRINT_stringize(y) #y
#define PRINT(a) (std::cout << __FILE__ << ":" << __LINE__ <<" " << PRINT_stringize(a) << " = " << (a) << std::endl)

template<class A1, class A2>
std::ostream& operator<<(std::ostream& s, std::vector<A1, A2> const& vec)
{
  std::cout << "[ ";
  for(typename std::vector<A1, A2>::const_iterator it = vec.begin(); it != vec.end(); ++it) {
    std::cout << (*it) << " ";
  }
  std::cout << "]";
  return s;
}

template<typename T>
float median_sorted(T* a, int n) {
  return (n%2==0) ? (float)(a[(n-1)/2]+a[n/2])/2.0 : (float)a[n/2];
}

namespace ROMEO {
    float g(float x);
    template <size_t N>
    carray<int64_t, N> getdimoffsets(carray<int64_t, N> size)
    {
        carray<int64_t,N> offs;
        offs[0] = 1;
        for (int64_t i=0; i<N-1; i++) {
            offs[i+1] = offs[i] * size[i];
        }
        return offs;
    }
}

#endif
