void naive_fixed_qr_decomp(float A[SIZE], float Q[SIZE], float R[SIZE]) {
    memcpy(R, A, sizeof(float) * SIZE * SIZE);

    // Build identity matrix of size SIZE * SIZE
    float *I = (float *)calloc(sizeof(float), SIZE * SIZE);
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            I[i * SIZE + j] = (i == j);
        }
    }
