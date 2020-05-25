SRC := *.c
OBJECT := dft.o
KERNEL_SRC := kernel.c

XCC := xt-xcc
XRUN := xt-run
XCC_FLAGS += -std=c99 -O3 -LNO:simd
XSIM_FLAGS := --summary --mem_model

NATURE_DIR := /data/Xplorer-8.0.11-workspaces/workspace/fusiong3_library
NATURE_SRC := $(NATURE_DIR)/cfftd_pdx4.c
NATURE_OBJ := cfftd_pdx4.o
NATURE_INC := -I $(NATURE_DIR)/include -I $(NATURE_DIR)/include_private -DXCHAL_HAVE_FUSIONG_SP_VFPU=1

PARAMS := -DN=$(N) -DOUTFILE='"$(OUTFILE)"'

default: $(OBJECT)

clean:
	rm -rf $(OBJECT) $(NATURE_OBJ)

$(NATURE_OBJ):
	$(XCC) $(XCC_FLAGS) $(NATURE_INC) -c $(NATURE_SRC) -o $(NATURE_OBJ)

$(OBJECT): $(NATURE_OBJ) $(SRC) $(KERNEL_SRC)
	$(XCC) $(PARAMS) $(XCC_FLAGS) $(NATURE_OBJ) $(SRC) $(KERNEL_SRC) -o $(OBJECT)

run: $(OBJECT)
	$(XRUN) $(OBJECT)

sim: $(OBJECT)
	$(XRUN) $(XSIM_FLAGS) $(OBJECT)
