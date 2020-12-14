OBJECT = matmul.o

NATURE_OBJS := matmmltf_pdx4.o

SRC := harness.c

XCC := xt-xcc
XCXX := xt-xc++
XRUN := xt-run
XCC_FLAGS += -O3 -mlongcalls -mtext-section-literals
# for verbose: -LNO:SIMD_V
XCXX_FLAGS += -std=c++11 -O3 -LNO:SIMD -w
XCXX_FLAGS += -I /usr/local/include/eigen-3
XSIM_FLAGS := --summary --mem_model

NATURE_DIR := /data/Xplorer-8.0.11-workspaces/workspace/fusiong3_library
NATURE_INC := -I $(NATURE_DIR)/include -I $(NATURE_DIR)/include_private -DXCHAL_HAVE_FUSIONG_SP_VFPU=1

PARAMS := -DA_ROWS=$(A_ROWS) -DA_COLS=$(A_COLS)
PARAMS := $(PARAMS) -DB_ROWS=$(B_ROWS) -DB_COLS=$(B_COLS)

PARAMS += -DOUTFILE='"$(OUTFILE)"'

ALL_OBJS := $(NATURE_OBJS)

# Make Nature objects individually
%.o: $(NATURE_DIR)/%.c
	$(XCC) $(XCC_FLAGS) $(NATURE_INC) -c $^ -o $@

default: $(OBJECT)

clean:
	rm -rf $(OBJECT) $(ALL_OBJS)

$(OBJECT): $(ALL_OBJS) $(SRC)
	$(XCXX) $(PARAMS) $(XCXX_FLAGS) $(NATURE_INC) $(ALL_OBJS) $(SRC) -o $(OBJECT)

run: $(OBJECT)
	$(XRUN) $(OBJECT)
