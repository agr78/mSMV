#define _USE_MATH_DEFINES // for windows
#include <math.h>
#include <stdint.h>
#include <vector>
#include "romeo.h"
#include "utility.h"
#include "rem2pi.h"
#include "array.h"
#include "weights.h"

namespace ROMEO
{

float phasecoherence(array<float,3>& P, int64_t i, int64_t j)
{
    return 1.0 - abs(g(P[i - 1] - P[j - 1]) / M_PI);
}

float phasegradientcoherence(array<float,3>& P,
                             array<float,3>& P2,
                             array<float,1>  &TEs,
                             int64_t i, int64_t j)
{
    return std::max(0.0, 1.0 - abs(g(P[i - 1] - P[j - 1]) - g(P2[ i - 1] - P2[ j - 1]) * TEs[ 1 - 1] / TEs[ 2 - 1]));
}

float magcoherence(float small, float big)
{
    return powf(small / big, 2);
}

float phaselinearity(array<float,3>& P, int64_t i, int64_t j, int64_t k)
{
    return std::max(0.0, 1.0 - abs(rem2pi(P[i - 1] - 2 * P[j - 1] + P[k - 1]) / 2));
}

float phaselinearity(array<float,3>& P, int64_t i, int64_t j)
{
    int64_t neighbor = j - i;
    int64_t h = i - neighbor;
    int64_t k = j + neighbor;
    if ((0 < h) && (k <= P.numel())) {
        return phaselinearity(P, h, i, j) * phaselinearity(P, i, j, k);
    } else {
        return 0.9;
    }
}

// Phase, index, neighbor, ...
float getweight(array<float,3>&  P, int64_t i, int64_t j, 
                array<float,3>&  P2, array<float,1>& TEs,
                array<float,3>&  M,  flags_t flags)
{
    float weight = 1.0;
    //W_PHASECOHERENCE          = 1 << 0, 
    //W_PHASEGRADIENTCOHERENCE  = 1 << 1,
    //W_PHASELINEARITY          = 1 << 2, 
    //W_MAGCOHERENCE            = 1 << 3, 
    if (flags & W_PHASECOHERENCE) weight *= (0.1 + 0.9 * phasecoherence(P, i, j));
    if (flags & W_PHASEGRADIENTCOHERENCE) weight *= (0.1 + 0.9 * phasegradientcoherence(P, P2, TEs, i, j));
    if (flags & W_PHASELINEARITY) weight *= (0.1 + 0.9 * phaselinearity(P, i, j));
    if (M.numel()>0) {
        float small = std::min(M[ i - 1], M[ j - 1]);
        float big = std::max(M[ i - 1], M[ j - 1]);
        if (flags & W_MAGCOHERENCE) weight *= (0.1 + 0.9 * magcoherence(small, big));
    }
    return weight;
}

/*
"""
    calculateweights(wrapped; weights=:romeo, kwargs...)

Calculates weights for all edges.
size(weights) == [3, size(wrapped)...]

###  Optional keyword arguments:

- `weights`: Options are [`:romeo`] | `:romeo2` | `:romeo3` | `:bestpath`.
- `mag`: Additional mag weights are used.
- `mask`: Unwrapping is only performed inside the mask.
- `phase2`: A second reference phase image (possibly with different echo time).
   It is used for calculating the phasecoherence weight.
- `TEs`: The echo times of the phase and the phase2 images as a tuple (eg. (5, 10) or [5, 10]).

"""
*/

void calculateweights_bestpath(array<float, 3>& wrapped, options_t options, array<uint8_t, 4>& weights)
{

}

void update_options(options_t& options, array<float, 3>& wrapped)
{
    if (0==options.mag.numel()) options.flags = (flags_t)(options.flags & ~W_MAGCOHERENCE);
    if (0==options.phase2.numel()) options.flags = (flags_t)(options.flags & ~W_PHASEGRADIENTCOHERENCE);
    int64_t numvox =  options.mask.numel();
    if (numvox>0) {
        if (options.mag.numel()>0) {
            for (int64_t v = 0; v < numvox; v++)
                options.mag[v] *= options.mask[v];
        }
    } else {
        options.mask.resize(wrapped.size());
        for (int64_t v=0; v<options.mask.numel(); v++) options.mask[v] = 1;
        //PRINT(options.mask[1000]);
    }
}

// from: 1 is best and 0 worst
// to: 1 is best, NBINS is worst, 0 is not valid (not added to queue)
uint8_t rescale(float w) 
{
    uint8_t y = 0;
    if ((0 <= w) && (w <= 1)) {
        y = std::max((uint8_t)round((1 - w) * (NBINS - 1)), (uint8_t)1);
    }
    return y;
}

void calculateweights_romeo(array<float, 3>& wrapped, options_t options, array<uint8_t, 4>& weights)
{
    update_options(options, wrapped);
    carray<int64_t, 3> stridelist = getdimoffsets(wrapped.size());
    //weights = zeros(T, 3, size(wrapped)...)
    int64_t N = wrapped.numel();
    for(int64_t dim=1; dim<=3; dim++) {
        int64_t neighbor = stridelist[dim-1];
        for (int64_t I=1; I<=N; I++) {
            int64_t J = I + neighbor;
            //PRINT(options.mask[I-1]);
            if (options.mask[I-1] && (J>0) && (J<=N) ) {
                float w = getweight(wrapped, I, J, options.phase2, options.TEs, options.mag, options.flags);
                weights[dim + (I - 1) * 3 - 1] = rescale(w);
            }
        }
    }
    //for dim in 1:3
    //    neighbor = stridelist[dim]
    //    for I in LinearIndices(wrapped)
    //        J = I + neighbor
    //        if mask[I] && checkbounds(Bool, wrapped, J)
    //            w = getweight(wrapped, I, J, P2, TEs, M, maxmag, flags)
    //            weights[dim + (I-1)*3] = rescale(w)
    //        end
    //    end
    //end
}


void calculateweights(array<float, 3>& wrapped, options_t options, array<uint8_t, 4>& weights)
{
    if (options.flags & W_BESTPATH) {
        calculateweights_bestpath(wrapped, options, weights);
    } else {
        calculateweights_romeo(wrapped, options, weights);
    }
    //these edges do not exist
    carray<int64_t, 4> strides = getdimoffsets(weights.size());
#define OFFS(t,x,y,z) (strides[3]*(z)+strides[2]*(y)+strides[1]*(x)+strides[0]*(t))

    for (int64_t z = 0; z < weights.size(3); z++) {
        for (int64_t y = 0; y < weights.size(2); y++) {
                for (int64_t t = 0; t < weights.size(0); t++) {
                    weights[OFFS(t,weights.size(1)-1,y,z)] = 0.0;
                }
        }
    }
    for (int64_t z = 0; z < weights.size(3); z++) {
            for (int64_t x = 0; x < weights.size(1); x++) {
                for (int64_t t = 0; t < weights.size(0); t++) {
                    weights[OFFS(t,x,weights.size(2)-1,z)] = 0.0;
                }
            }
    }
        for (int64_t y = 0; y < weights.size(2); y++) {
            for (int64_t x = 0; x < weights.size(1); x++) {
                for (int64_t t = 0; t < weights.size(0); t++) {
                    weights[OFFS(t,x,y,weights.size(3)-1)] = 0.0;
                }
            }
        }
}

}
