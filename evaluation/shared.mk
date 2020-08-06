SRC := harness.c
KERNEL_SRC := kernel.c

XCC := xt-xc++
XRUN := xt-run
XCC_FLAGS += -std=c++11 -O3 -mlongcalls -mtext-section-literals
XSIM_FLAGS := --summary --mem_model

NATURE_DIR := /data/Xplorer-8.0.11-workspaces/workspace/fusiong3_library
NATURE_INC := -I $(NATURE_DIR)/include -I $(NATURE_DIR)/include_private -DXCHAL_HAVE_FUSIONG_SP_VFPU=1

PARAMS += -DOUTFILE='"$(OUTFILE)"'

ALL_OBJS := $(NATURE_OBJS) $(EXPERT_OBJ)

# Make Nature objects individually
%.o: $(NATURE_DIR)/%.c
	$(XCC) $(XCC_FLAGS) $(NATURE_INC) -c $^ -o $@

default: $(OBJECT)

clean:
	rm -rf $(OBJECT) $(ALL_OBJS)

$(OBJECT): $(ALL_OBJS) $(KERNEL_SRC) $(SRC)
	$(XCC) $(PARAMS) $(XCC_FLAGS) $(NATURE_INC) $(ALL_OBJS) $(KERNEL_SRC) $(SRC) -o $(OBJECT)

run: $(OBJECT)
	$(XRUN) $(OBJECT)

sim: $(OBJECT)
	$(XRUN) $(XSIM_FLAGS) $(OBJECT)
