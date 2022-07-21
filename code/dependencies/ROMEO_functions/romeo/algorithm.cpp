#define _USE_MATH_DEFINES // for windows
#include <math.h>
#include <iostream>
#include <vector>
#include "array.h"
#include "carray.h"
#include "seed.h"
#include "weights.h"
#include "algorithm.h"
#include "priorityqueue.h"

namespace ROMEO {
void getvoxelsfromedge(int64_t edge, array<uint8_t,3>& visited, 
                       carray<int64_t, 3>& stridelist, int64_t& oldvox, 
                       int64_t& newvox)
{
    int64_t dim = getdimfromedge(edge);
    int64_t vox = getfirstvoxfromedge(edge);
    int64_t neighbor = vox + stridelist[dim-1];//direct neigbor in dim
    if (visited[neighbor-1] == 0) {
        oldvox = vox; newvox = neighbor;
    } else {
        oldvox = neighbor; newvox = vox;
    }
}

inline float unwrapvoxel(float newp, float oldp) 
{
    return newp - 2*M_PI*round((newp - oldp) / (2*M_PI));
}


void unwrapedge(array<float, 3>& wrapped, int64_t oldvox, int64_t newvox, 
                array<uint8_t,3>& visited, float x)
{
    int64_t oo = 2*oldvox - newvox;
    float d = 0;
    if ((oo>0)&&(oo<=wrapped.numel())) {
        if (visited[oo-1] != 0) { 
            //neighbor behind is visited
            float v = wrapped[oldvox-1] - wrapped[oo-1];
            if (v < -x) {//threshold
                d = -x;
            } else if (v > x) {
                d = x;
            } else {
                d = v;
            }
        }
    }
    wrapped[newvox-1] = unwrapvoxel(wrapped[newvox-1], wrapped[oldvox-1] + d);
}
//visited=zeros(UInt8, size(wrapped)), pqueue=PQueue{Int}(NBINS);
//     maxseeds=1, merge_regions=false, correct_regions=false, wrap_addition=0, keyargs...

int grow_region_unwrap(array<float, 3>& wrapped,
                        array<uint8_t,4>& weights,
                        options_t& options)
{
    array<uint8_t,3> visited(wrapped.size());
    PQueue<int64_t> pqueue(NBINS);
    return grow_region_unwrap(wrapped, weights, visited, pqueue, options);
}

int grow_region_unwrap(array<float, 3>& wrapped,
                        array<uint8_t,4>& weights,
                        array<uint8_t,3>& visited,
                        PQueue<int64_t>& pqueue,
                        options_t& options) 
{
    // Init
    int64_t maxseeds = std::min((int64_t)255, options.maxseeds); //Hard Limit, Stored in UInt8
    carray<int64_t, 3> dimoffsets = getdimoffsets(wrapped.size());

    //notvisited(i) = checkbounds(Bool, visited, i) && (visited[i] == 0)
    std::vector<int64_t> seeds; 
    int64_t new_seed_thresh = 256;
    if (!pqueue.isempty()) { 
        PRINT("pqueue is not empty");
        return 1;
    } 
    // # no seed added yet
    seed_maker_t seed_maker(seeds, pqueue, visited, weights, wrapped, options);
    new_seed_thresh = seed_maker.addseed();
    // MST loop
    while (!pqueue.isempty()) {
        if ((seeds.size() < maxseeds) && (pqueue.min() > new_seed_thresh)) {
            new_seed_thresh = seed_maker.addseed();
        }
        int64_t edge = pqueue.dequeue();
        int64_t oldvox, newvox; 
        getvoxelsfromedge(edge, visited, dimoffsets, oldvox, newvox);
        if (visited[newvox-1] == 0) {
            unwrapedge(wrapped, oldvox, newvox, visited, options.wrap_addition);
            visited[newvox-1] = visited[oldvox-1];
            for (int i=1; i<=6; i++) {// 6 directions
                int64_t e = getnewedge(newvox, visited, dimoffsets, i);
                if ((e != 0) && (weights[e-1] > 0)) {
                    pqueue.enqueue(e, weights[e-1]);
                }
            }
        }
    }
    //## Region merging
    if (options.merge_regions) {
        // regions = merge_regions!(wrapped, visited, length(seeds), weights)
        std::cout << "merge_regions not implemented" << std::endl;
    }
    if (options.merge_regions && options.correct_regions) {
        // correct_regions!(wrapped, visited, regions)
        std::cout << "correct_regions not implement4d" << std::endl;
    }
    return 0;
}

} // namespace ROMEO
