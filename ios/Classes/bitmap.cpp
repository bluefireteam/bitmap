#include <stdlib.h>
#include <stdint.h>


int clamp255_0(int before) {
    if(before > 255) return 255;
    if(before < 0) return 0;
    return before;
}

int clamp255_n255(int before) {
    if(before > 255) return 255;
    if(before < -255) return -255;
    return before;
}

/**
 * Receives a bitmap, its length and a brightness amount valuating between -255 and 255
 */
extern "C" __attribute__((visibility("default"))) __attribute__((used))
uint8_t *brightness(uint8_t *starting_pointer, int bitmap_length, int brightness_amount) {
    for (int i = 0; i < bitmap_length; i += 4) {
        uint8_t *r = starting_pointer + i;
        uint8_t *g = starting_pointer + i + 1;
        uint8_t *b = starting_pointer + i + 2;
        uint8_t *a = starting_pointer + i + 3;

        *r = clamp255_0(*r + brightness_amount);
        *g = clamp255_0(*g + brightness_amount);
        *b = clamp255_0(*b + brightness_amount);
    }
    return starting_pointer;
}
