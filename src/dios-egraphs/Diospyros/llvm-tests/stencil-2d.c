#define ROW_SIZE 8
#define COL_SIZE 4
#define F_SIZE 9

void stencil(float orig_in[ROW_SIZE * COL_SIZE],
             float sol_out[ROW_SIZE * COL_SIZE], float filter_in[F_SIZE]) {
    for (int r = 0; r < ROW_SIZE - 2; r++) {
        for (int c = 0; c < COL_SIZE - 2; c++) {
            float temp = 0;
            for (int k1 = 0; k1 < 3; k1++) {
                for (int k2 = 0; k2 < 3; k2++) {
                    float mul = filter_in[k1 * 3 + k2] *
                                orig_in[(r + k1) * COL_SIZE + c + k2];
                    temp += mul;
                }
            }
            sol_out[(r * COL_SIZE) + c] = temp;
        }
    }
}

int main(void) {}