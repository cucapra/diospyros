SRCS := src/example.c

COMPLETED_SRCS := src-completed/completed_example.c src-completed/transpose_and_multiply.c

XCXX := xt-clang++
XRUN := xt-run
XCC_FLAGS += -O3 -mlongcalls -mtext-section-literals -fvectorize -Wno-deprecated
XSIM_FLAGS := --nosummary --mem_model

OBJ := example.o
COMPLETED_OBJ := completed_example.o

.PHONY: clean sim

default: sim

$(OBJ): $(SRCS)
	$(XCXX) $(XCC_FLAGS) $(SRCS) -o $(OBJ)

$(COMPLETED_OBJ): $(COMPLETED_SRCS)
	$(XCXX) $(XCC_FLAGS) $(COMPLETED_SRCS) -o $(COMPLETED_OBJ)

sim: $(OBJ)
	$(XRUN) $(XSIM_FLAGS) $(OBJ)

completed: $(COMPLETED_OBJ)
	$(XRUN) $(XSIM_FLAGS) $(COMPLETED_OBJ)

clean:
	rm -rf $(OBJ) $(COMPLETED_OBJ)