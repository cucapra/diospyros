#include <assert.h>
#include <float.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define SIZE 8
#define MAX_FLOAT 100.00f
#define DELTA 0.1f

#define MAX_FOR_LOOP_ITERATIONS 1000

void fft_for_loop_version(float real_in[SIZE], float img_in[SIZE],
                          float real_twid_in[SIZE / 2],
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

#pragma unroll
    for (int i = 0; i < MAX_FOR_LOOP_ITERATIONS; i++) {
        if (span == 0) {
            break;
        }
        odd = span;
#pragma unroll
        for (int j = 0; j < MAX_FOR_LOOP_ITERATIONS; j++) {
            if (odd >= SIZE) {
                break;
            }
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

// void fft(float real_in[SIZE], float img_in[SIZE], float real_twid_in[SIZE /
// 2],
//          float img_twid_in[SIZE / 2], float real_out[SIZE],
//          float img_out[SIZE]) {
//     int even = 0;
//     int odd = 0;
//     int log = 0;
//     int rootindex = 0;
//     int span = SIZE >> 1;
//     float temp = 0;

//     for (int i = 0; i < SIZE; i++) {
//         real_out[i] = real_in[i];
//         img_out[i] = img_in[i];
//     }

//     while (span != 0) {
//         odd = span;
//         while (odd < SIZE) {
//             odd = odd | span;
//             even = odd ^ span;

//             temp = real_out[even] + real_out[odd];
//             real_out[odd] = real_out[even] - real_out[odd];
//             real_out[even] = temp;

//             temp = img_out[even] + img_out[odd];
//             img_out[odd] = img_out[even] - img_out[odd];
//             img_out[even] = temp;

//             rootindex = (even << log) & (SIZE - 1);
//             if (rootindex > 0) {
//                 temp = real_twid_in[rootindex] * real_out[odd] -
//                        img_twid_in[rootindex] * img_out[odd];
//                 img_out[odd] = real_twid_in[rootindex] * img_out[odd] +
//                                img_twid_in[rootindex] * real_out[odd];
//                 real_out[odd] = temp;
//             }
//             odd += 1;
//         }
//         span >>= 1;
//         log += 1;
//     }
// }

void no_opt_fft(float real_in[SIZE], float img_in[SIZE],
                float real_twid_in[SIZE / 2], float img_twid_in[SIZE / 2],
                float real_out[SIZE], float img_out[SIZE]) {
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
    // time_t t = time(NULL);
    // srand((unsigned)time(&t));

    float real_in[SIZE] = {0.0f};
    float img_in[SIZE] = {0.0f};
    float real_twid_in[SIZE / 2] = {0.0f};
    float img_twid_in[SIZE / 2] = {0.0f};
    float real_out[SIZE] = {0.0f};
    float img_out[SIZE] = {0.0f};

    float expected_real_in[SIZE] = {0.0f};
    float expected_img_in[SIZE] = {0.0f};
    float expected_real_twid_in[SIZE / 2] = {0.0f};
    float expected_img_twid_in[SIZE / 2] = {0.0f};
    float expected_real_out[SIZE] = {0.0f};
    float expected_img_out[SIZE] = {0.0f};

    for (int i = 0; i < SIZE; i++) {
        float n = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
        real_in[i] = n;
        expected_real_in[i] = n;
    }
    for (int i = 0; i < SIZE; i++) {
        float n = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
        img_in[i] = n;
        expected_img_in[i] = n;
    }
    for (int i = 0; i < SIZE / 2; i++) {
        float n = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
        real_twid_in[i] = n;
        expected_real_twid_in[i] = n;
    }
    for (int i = 0; i < SIZE / 2; i++) {
        float n = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
        img_twid_in[i] = n;
        expected_img_twid_in[i] = n;
    }
    for (int i = 0; i < SIZE; i++) {
        float n = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
        real_out[i] = n;
        expected_real_out[i] = n;
    }
    for (int i = 0; i < SIZE; i++) {
        float n = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
        img_out[i] = n;
        expected_img_out[i] = n;
    }

    fft_for_loop_version(real_in, img_in, real_twid_in, img_twid_in, real_out,
                         img_out);
    no_opt_fft(expected_real_in, expected_img_in, expected_real_twid_in,
               expected_img_twid_in, expected_real_out, expected_img_out);

    for (int i = 0; i < SIZE; i++) {
        printf("Real Out Output: %f\n", real_out[i]);
        printf("Expected Real Out Output: %f\n", expected_real_out[i]);
        assert(fabs(real_out[i] - expected_real_out[i]) < DELTA);
    }
    for (int i = 0; i < SIZE; i++) {
        printf("Img Out Output: %f\n", img_out[i]);
        printf("Expected Img Out Output: %f\n", expected_img_out[i]);
        assert(fabs(img_out[i] - expected_img_out[i]) < DELTA);
    }
}
