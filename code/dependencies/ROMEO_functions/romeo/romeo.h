#ifndef ROMEO_ROMEO_H__
#define ROMEO_ROMEO_H__
#include <stddef.h>
#include "array.h"

namespace ROMEO {

const int64_t NBINS = 256;

enum flags_t
{
    W_INVALID                 = 0,
    W_PHASECOHERENCE          = 1 << 0, 
    W_PHASEGRADIENTCOHERENCE  = 1 << 1,
    W_PHASELINEARITY          = 1 << 2, 
    W_MAGCOHERENCE            = 1 << 3, 
    W_BESTPATH                = 1 << 4,
    W_ROMEO = W_PHASECOHERENCE,
    W_ROMEO2 = W_PHASECOHERENCE | W_MAGCOHERENCE,
    W_ROMEO3 = W_PHASECOHERENCE | W_PHASEGRADIENTCOHERENCE | W_MAGCOHERENCE,
    W_ROMEO4 = W_PHASECOHERENCE | W_PHASEGRADIENTCOHERENCE | W_PHASELINEARITY | W_MAGCOHERENCE
};

/*- `weights`: Options are [`:romeo`] | `:romeo2` | `:romeo3` | `:bestpath`.
- `mag`: Additional mag weights are used.
- `mask`: Unwrapping is only performed inside the mask.
- `phase2`: A second reference phase image (possibly with different echo time).
   It is used for calculating the phasecoherence weight.
- `TEs`: The echo times of the phase and the phase2 images as a tuple (eg. (5, 10) or [5, 10]).
*/

typedef struct options_t {
    options_t ()
    : flags(W_ROMEO2)
    , maxseeds(1)
    , merge_regions(false)
    , correct_regions(false)
    , wrap_addition(0)
    , correctglobal(true) {}
    array<float, 3> mag;
    array<int, 3> mask;
    array<float, 3> phase2;
    array<float, 1> TEs;
    flags_t flags;
    int64_t maxseeds;
    bool merge_regions;
    bool correct_regions;
    float wrap_addition;
    bool correctglobal;
} options_t;

int unwrap(array<float, 3>& wrapped,  options_t& options);

}
#endif
