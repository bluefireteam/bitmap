#include <stdlib.h>
#include <stdint.h>
#include <math.h>


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


extern "C" __attribute__((visibility("default"))) __attribute__((used))
int32_t sum(int32_t x, int32_t y) {
    return x + y;
}
/**
 * Receives a bitmap, its length and a brightness amount variating between 0 and 255
 */
extern "C" __attribute__((visibility("default"))) __attribute__((used))
int8_t *brightness(int8_t *starting_pointer, int bitmap_length, double brightness_amount) {
    int brightness_amount_c = clamp255_n255(floor(brightness_amount));
    for (int i = 0; i < bitmap_length; i += 4) {
        int8_t *r = starting_pointer + i;
        int8_t *g = starting_pointer + i + 1;
        int8_t *b = starting_pointer + i + 2;
        int8_t *a = starting_pointer + i + 3;

        *r = clamp255_0(*r + brightness_amount_c);
        *g = clamp255_0(*g + brightness_amount_c);
        *b = clamp255_0(*b + brightness_amount_c);
    }
    return starting_pointer;
}
