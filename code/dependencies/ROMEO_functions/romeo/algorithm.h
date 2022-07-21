#ifndef ROMEO_ALGORITHM_H__
#define  ROMEO_ALGORITHM_H__
#include <stdint.h>
#include "romeo.h"
#include "priorityqueue.h"
/*#include <math.h>
#include <iostream>
#include <vector>
#include "array.h"
#include "carray.h"
#include "seed.h"
#include "weights.h"*/

namespace ROMEO {

//void getvoxelsfromedge(int64_t edge, array<uint8_t,3>& visited, 
//                       carray<int64_t, 3>& stridelist, int64_t& oldvox, 
//                       int64_t& newvox);
//inline float unwrapvoxel(float newp, float oldp) 
//{
//    return newp - 2*M_PI*round((newp - oldp) / (2*M_PI));
//}
//void unwrapedge(array<float, 3>& wrapped, int64_t oldvox, int64_t newvox, 
//                array<uint8_t,3>& visited, float x);
int grow_region_unwrap(array<float, 3>& wrapped,
                        array<uint8_t,4>& weights,
                        options_t& options);
int grow_region_unwrap(array<float, 3>& wrapped,
                        array<uint8_t,4>& weights,
                        array<uint8_t,3>& visited,
                        PQueue<int64_t>& pqueue,
                        options_t& options); 

} // namespace ROMEO

#endif
