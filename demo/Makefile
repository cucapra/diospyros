SRCS := src/example.c

XCXX := xt-clang++
XRUN := xt-run
XCC_FLAGS += -O3 -mlongcalls -mtext-section-literals -fvectorize
XSIM_FLAGS := --nosummary --mem_model

OBJ := example.o

.PHONY: clean sim

default: sim

$(OBJ): $(SRCS)
	$(XCXX) $(XCXX_FLAGS) $(SRCS) -o $(OBJ)

sim: $(OBJ)
	$(XRUN) $(XSIM_FLAGS) $(OBJ)

clean:
	rm -rf $(OBJ)