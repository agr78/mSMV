#include <stdlib.h>
#define _USE_MATH_DEFINES // for windows
#include <math.h>
#include <limits>
#include "romeo.h"
#include "seed.h"
#include "priorityqueue.h"
#include "array.h"
#include "utility.h"
#include "rem2pi.h"

namespace ROMEO {

PQueue<int64_t> getseedqueue(array<uint8_t,4> weights, PQueue<int64_t>& queue)
{
    queue.initialize(3*NBINS);
    int64_t numvox = weights.size()[1]*weights.size()[2]*weights.size()[3];
    for (int64_t i=0; i<numvox; i++) {
        int64_t w = 0;
        for (int64_t j=0; j<3; j++) {
            w += weights[3*i + j] == 0 ? uint8_t(255) : weights[3*i + j];
        }
        queue.enqueue(i+1,w);
    }
    return queue;
}

int64_t findseed(PQueue<int64_t>& queue, array<uint8_t,4> weights, array<uint8_t,3>& visited)
{
    while (!queue.isempty()) {
        int64_t ind = queue.dequeue();
        if (visited[ind-1] == 0) return ind;
    }
    return 0;
}


// returns a function that can repeatedly and efficiently create new seeds
seed_maker_t::seed_maker_t(std::vector<int64_t>& seeds, 
           PQueue<int64_t>& pqueue, 
           array<uint8_t,3>& visited, 
           array<uint8_t,4>& weights,
           array<float, 3>& wrapped,
           options_t& options)
           : weights(weights)
           , visited(visited)
           , pqueue(pqueue)
           , options(options)
           , wrapped(wrapped)
           , seeds(seeds) 
{
    getseedqueue(weights, seedqueue);
    stridelist = getdimoffsets(wrapped.size());
}






int64_t getnewedge(int64_t v, array<uint8_t,3>& visited, carray<int64_t, 3>& stridelist, int64_t i)
{
    int64_t iDim = (i+1)/2;
    int64_t n = stridelist[iDim-1]; // neigbor-offset in dimension iDim
    if (0==i%2) {
        if (notvisited(visited, v + n)) {
            return getedgeindex(v, iDim);
        } else {
            return 0;
        }
    } else {
        if (notvisited(visited, v - n)) {
            return getedgeindex(v-n, iDim);
        } else {
           return 0;
         }
    }
}

void seed_maker_t::seedcorrection(int64_t vox)
{
    if ((options.phase2.numel()>0) && (options.TEs.numel()>0)) {
        float best = std::numeric_limits<float>::max();
        int offset = 0;
        for (int off1=-2; off1<=2; off1++) {
            for (int off2=-1; off2<=1; off2++) {
                float diff = abs((wrapped[vox-1] + 2*M_PI*off1) / options.TEs[1-1]
                                 - (options.phase2[vox-1] + 2*M_PI*off2) / options.TEs[2-1]);
                diff += (abs(off1) + abs(off2)) / 100.; //small panelty for wraps (if TE1 == 2*TE2 wrong value is chosen otherwise)
                if (diff < best) {
                    best = diff;
                    offset = off1;
                }
            }    
        }
        wrapped[vox-1] += 2*M_PI * offset;
    } else {
        //PRINT(vox);
        //PRINT(wrapped.numel());
        wrapped[vox-1] = rem2pi(wrapped[vox-1]);
    }
}

uint8_t seed_maker_t::addseed()
{
    int64_t seed = findseed(seedqueue, weights, visited);
    if (0 == seed) return 255;
    for (int64_t i=1; i<=6; i++) {
        int64_t e = getnewedge(seed, visited, stridelist, i);
        if ((0 != e) && (weights[e-1]>0)) {
            pqueue.enqueue(e, weights[e-1]);
        }
    }
    seedcorrection(seed);
    seeds.push_back(seed);
    visited[seed-1] = seeds.size();
    // new seed thresh
    uint8_t tmp = weights[getedgeindex(seed, 1) - 1]
                  + weights[getedgeindex(seed, 2) - 1]
                  + weights[getedgeindex(seed, 3) - 1];
    return  NBINS - uint8_t(NBINS - tmp / 3.0)/2;
} 

/*
function getseedfunction(seeds, pqueue, visited, weights, wrapped, keyargs)
    seedqueue = getseedqueue(weights);
    notvisited(i) = checkbounds(Bool, visited, i) && (visited[i] == 0)
    stridelist = getdimoffsets(wrapped)
    function addseed!()
        seed = findseed!(seedqueue, weights, visited)
        if seed == 0
            return 255
        end
        for i in 1:6 # 6 directions
            e = getnewedge(seed, notvisited, stridelist, i)
            if e != 0 && weights[e] > 0
                enqueue!(pqueue, e, weights[e])
            end
        end
        seedcorrection!(wrapped, seed, keyargs)
        push!(seeds, seed)
        visited[seed] = length(seeds)
        # new seed thresh
        seed_weights = weights[getedgeindex.(seed, 1:3)]
        new_seed_thresh = NBINS - div(NBINS - sum(seed_weights)/3, 2)
        return new_seed_thresh
    end
    return addseed!
    */

/*


function findseed!(queue::PQueue, weights, visited)
    while !isempty(queue)
        ind = dequeue!(queue)
        if visited[ind] == 0
            return ind
        end
    end
    return 0
end

function seedcorrection!(wrapped, vox, keyargs)
    if haskey(keyargs, :phase2) && haskey(keyargs, :TEs) # requires multiecho
        phase2 = keyargs[:phase2]
        TEs = keyargs[:TEs]
        best = Inf
        offset = 0
        for off1 in -2:2, off2 in -1:1
            diff = abs((wrapped[vox] + 2π*off1) / TEs[1] - (phase2[vox] + 2π*off2) / TEs[2])
            diff += (abs(off1) + abs(off2)) / 100 # small panelty for wraps (if TE1 == 2*TE2 wrong value is chosen otherwise)
            if diff < best
                best = diff
                offset = off1
            end
        end
        wrapped[vox] += 2π * offset
    else
        wrapped[vox] = rem2pi(wrapped[vox], RoundNearest)
    end
end
*/
}
