#ifndef ROMEO_SEED_H__
#define ROMEO_SEED_H__
#include <stdint.h>
#include <vector>
#include "priorityqueue.h"
#include "array.h"
#include "romeo.h"

namespace ROMEO {

int64_t getnewedge(int64_t v, array<uint8_t,3>& visited, carray<int64_t, 3>& stridelist, int64_t i);


// edge calculations

inline int64_t getedgeindex(int64_t leftvoxel, int64_t dim)
{
    return dim + 3*(leftvoxel-1);
}

inline int64_t getdimfromedge(int64_t edge)
{
    return (edge - 1) % 3 + 1;
}

inline int64_t getfirstvoxfromedge(int64_t edge) 
{
    return (edge - 1)/3 + 1;
}

inline bool notvisited(array<uint8_t,3>& visited, int64_t i)
{
    if ((i>0)&&(i<=visited.numel())) {
        return 0 == visited[i-1];
    } else {
        return false;
    }
}

class seed_maker_t {
    public:
        seed_maker_t(std::vector<int64_t>& seeds, 
           PQueue<int64_t>& pqueue, 
           array<uint8_t,3>& visited, 
           array<uint8_t,4>& weights,
           array<float, 3>& wrapped,
           options_t& options);

        void seedcorrection(int64_t vox);
        uint8_t addseed();

    private:
        PQueue<int64_t> seedqueue;
        carray<int64_t, 3> stridelist;
        array<uint8_t,4>& weights;
        array<uint8_t,3>& visited;
        PQueue<int64_t>& pqueue; 
        options_t& options;
        array<float, 3>& wrapped;
        std::vector<int64_t>& seeds;


};

}

#endif