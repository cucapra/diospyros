#include <stdio.h>
#define SIZE 8

void fft(float real_in[SIZE], float img_in[SIZE], float real_twid_in[SIZE / 2],
         float img_twid_in[SIZE / 2], float real_out[SIZE],
         float img_out[SIZE]) {
    int even = 0;
    int odd = 0;
    int log = 0;
    int rootindex = 0;
    int span = SIZE >> 1;
    float temp = 0;

    for (int i = 0; i < SIZE; i++) {
        real_out[i] = real_in[i];
        img_out[i] = img_in[i];
    }

    while (span != 0) {
        odd = span;
        while (odd < SIZE) {
            odd = odd | span;
            even = odd ^ span;

            temp = real_out[even] + real_out[odd];
            real_out[odd] = real_out[even] - real_out[odd];
            real_out[even] = temp;

            temp = img_out[even] + img_out[odd];
            img_out[odd] = img_out[even] - img_out[odd];
            img_out[even] = temp;

            rootindex = (even << log) & (SIZE - 1);
            if (rootindex > 0) {
                temp = real_twid_in[rootindex] * real_out[odd] -
                       img_twid_in[rootindex] * img_out[odd];
                img_out[odd] = real_twid_in[rootindex] * img_out[odd] +
                               img_twid_in[rootindex] * real_out[odd];
                real_out[odd] = temp;
            }
            odd += 1;
        }
        span >>= 1;
        log += 1;
    }
}

int main(void) {
    float real_in[SIZE] = {1, 2, 3, 4, 5, 6, 7, 8};
    float img_in[SIZE] = {0, 1, 2, 3, 4, 5, 6, 7};
    float real_twid_in[SIZE / 2] = {4, 3, 2, 1};
    float img_twid_in[SIZE / 2] = {8, 7, 6, 5};
    float real_out[SIZE] = {1, 1, 1, 1, 1, 1, 1, 1};
    float img_out[SIZE] = {2, 3, 4, 5, 6, 7, 8, 9};
    fft(real_in, img_in, real_twid_in, img_twid_in, real_out, img_out);
    for (int i = 0; i < SIZE; i++) {
        printf("%f\n", real_out[i]);
    }
    for (int i = 0; i < SIZE; i++) {
        printf("%f\n", img_out[i]);
    }
    // 36.000000
    // -4.000000
    // 12.000000
    // -20.000000
    // 44.000000
    // -20.000000
    // 76.000000
    // -116.000000
    // 28.000000
    // -4.000000
    // -36.000000
    // 28.000000
    // -100.000000
    // 28.000000
    // -4.000000
    // 60.000000
}
