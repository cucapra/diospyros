SRCS := src/example.c

COMPLETED_SRCS := src/completed_example.c src/transpose_and_multiply.h

XCXX := xt-clang++
XRUN := xt-run
XCC_FLAGS += -O3 -mlongcalls -mtext-section-literals -fvectorize
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

completed: $(COMPLETED_SRCS)
	$(XRUN) $(XSIM_FLAGS) $(COMPLETED_SRCS)

clean:
	rm -rf $(OBJ)