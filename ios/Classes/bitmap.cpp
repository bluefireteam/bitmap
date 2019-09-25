#include <stdlib.h>
#include <stdint.h>

extern "C" __attribute__((visibility("default"))) __attribute__((used))
int32_t sum(int32_t x, int32_t y) {
    return x + y;
}
