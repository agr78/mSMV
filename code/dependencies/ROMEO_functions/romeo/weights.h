#ifndef ROMEO_WEIGHTS_H__
#define ROMEO_WEIGHTS_H__
#include <stdint.h>
#include "array.h"
#include "romeo.h"
namespace ROMEO {

void calculateweights(array<float, 3>& wrapped, options_t options, array<uint8_t, 4>& weights);

}

#endif
