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

/**
 * Brightness
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

/**
 * Contrast
 * Receives a bitmap, its length and a contrast rate greater than 0
 */
extern "C" __attribute__((visibility("default"))) __attribute__((used))
uint8_t *contrast(uint8_t *starting_pointer, int bitmap_length, double contrast_rate) {
    double contrast_sqare = contrast_rate * contrast_rate;
    uint8_t contrast_applier[256];
    for (int i = 0; i < 256; ++i) {
        contrast_applier[i] = clamp255_0(floor(((((i / 255.0) - 0.5) * contrast_sqare) + 0.5) * 255.0));
    }

    for (int i = 0; i < bitmap_length; i += 4) {
        uint8_t *r = starting_pointer + i;
        uint8_t *g = starting_pointer + i + 1;
        uint8_t *b = starting_pointer + i + 2;
        uint8_t *a = starting_pointer + i + 3;

        *r = contrast_applier[*r];
        *g = contrast_applier[*g];
        *b = contrast_applier[*b];
    }
    return starting_pointer;
}