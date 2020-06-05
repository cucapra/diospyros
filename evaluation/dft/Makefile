SRC := *.c
OBJECT := dft.o
KERNEL_SRC := kernel.c

XCC := xt-xcc
XRUN := xt-run
XCC_FLAGS += -std=c99 -O3
XSIM_FLAGS := --summary --mem_model

# Cosine and sine implementations
NATURE_OBJS := invpi_tbl.o sin_tbl.o cos_pdx4.o sin_pdx4.o
# FFT implementation
NATURE_OBJS += cfft_tab_pdx4.o L4n_n_inpl_pdx4.o bitrev32_pdx4.o cfft_pdx4.o

NATURE_DIR := /data/Xplorer-8.0.11-workspaces/workspace/fusiong3_library
NATURE_INC := -I $(NATURE_DIR)/include -I $(NATURE_DIR)/include_private -DXCHAL_HAVE_FUSIONG_SP_VFPU=1

PARAMS := -DN=$(N) -DOUTFILE='"$(OUTFILE)"'

# Make Nature objects individually
%.o: $(NATURE_DIR)/%.c
	$(XCC) $(XCC_FLAGS) $(NATURE_INC) -c $^ -o $@

default: $(OBJECT)

clean:
	rm -rf $(OBJECT) $(NATURE_OBJS)

$(OBJECT): $(NATURE_OBJS) $(KERNEL_SRC) $(SRC)
	$(XCC) $(PARAMS) $(XCC_FLAGS) $(NATURE_INC) $(NATURE_OBJS) $(KERNEL_SRC) $(SRC) -o $(OBJECT)

run: $(OBJECT)
	$(XRUN) $(OBJECT)

sim: $(OBJECT)
	$(XRUN) $(XSIM_FLAGS) $(OBJECT)
