OBJECT := dft.o

# Cosine and sine implementations
NATURE_OBJS := invpi_tbl.o sin_tbl.o cos_pdx4.o sin_pdx4.o
# FFT implementation
NATURE_OBJS += cfft_tab_pdx4.o L4n_n_inpl_pdx4.o bitrev32_pdx4.o cfft_pdx4.o

PARAMS := -DN=$(N)

include ../shared.mk
