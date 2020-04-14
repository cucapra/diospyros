SRC := *.c
OBJECT = matmul.o
KERNEL_SRC := kernel.c

XCC := xt-xcc
XRUN := xt-run
XCC_FLAGS += -std=c99 -O3 -LNO:simd
XSIM_FLAGS := --summary --mem_model

EXPERT_SRC := ../../../diospyros-private/src/matrix_multiply_expert.c
EXPERT_OBJ := matrix_multiply_expert.o

NATURE_DIR := /data/Xplorer-8.0.11-workspaces/workspace/fusiong3_library
NATURE_SRC := $(NATURE_DIR)/matmmltf_pdx4.c
NATURE_OBJ := matmmltf_pdx4.o
NATURE_INC := -I $(NATURE_DIR)/include -I $(NATURE_DIR)/include_private -DXCHAL_HAVE_FUSIONG_SP_VFPU=1

A_ROWS := 2
A_COLS := 3
B_ROWS := 3
B_COLS := 3

PARAMS := -DA_ROWS=$(A_ROWS) -DA_COLS=$(A_COLS)
PARAMS := $(PARAMS) -DB_ROWS=$(B_ROWS) -DB_COLS=$(B_COLS)
PARAMS := $(PARAMS) -DOUTFILE='"$(OUTFILE)"'

default: $(OBJECT)

clean:
	rm -rf $(OBJECT) $(NATURE_OBJ)

$(EXPERT_OBJ): $(EXPERT_SRC)
	$(XCC) $(XCC_FLAGS) -c $(EXPERT_SRC) -o $(EXPERT_OBJ)

$(NATURE_OBJ):
	$(XCC) $(XCC_FLAGS) $(NATURE_INC) -c $(NATURE_SRC) -o $(NATURE_OBJ)

$(OBJECT): $(EXPERT_OBJ) $(NATURE_OBJ) $(SRC) $(KERNEL_SRC)
	$(XCC) $(PARAMS) $(XCC_FLAGS) $(EXPERT_OBJ) $(NATURE_OBJ) $(SRC) $(KERNEL_SRC) -o $(OBJECT)

run: $(OBJECT)
	$(XRUN) $(OBJECT)

sim: $(OBJECT)
	$(XRUN) $(XSIM_FLAGS) $(OBJECT)
