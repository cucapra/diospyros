#define SIZE 8

void fft(float real_in[SIZE], float img_in[SIZE],
    float real_twid_in[SIZE/2], float img_twid_in[SIZE/2],
    float real_out[SIZE], float img_out[SIZE]){
    int even = 0;
    int odd = 0;
    int log = 0;
    int rootindex = 0;
    int span = SIZE >> 1;
    float temp = 0;

    for (int i = 0; i < SIZE; i ++) {
        real_out[i] = real_in[i];
        img_out[i] = img_in[i];
    }

    while (span != 0){
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

            rootindex = (even<<log) & (SIZE - 1);
            if (rootindex > 0) {
                temp = real_twid_in[rootindex] * real_out[odd] -
                    img_twid_in[rootindex]  * img_out[odd];
                img_out[odd] = real_twid_in[rootindex]*img_out[odd] +
                    img_twid_in[rootindex]*real_out[odd];
                real_out[odd] = temp;
            }
            odd += 1;
        }
        span >>= 1;
        log += 1;
    }
}