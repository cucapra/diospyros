OBJECT = matmul.o

EXPERT_SRC := ../../../diospyros-private/src/matrix_multiply_expert.c
EXPERT_OBJ := matrix_multiply_expert.o

EGG_SRC := ../../../diospyros-private/src/egg_kernel.c
EGG_OBJ := egg_kernel.o

NATURE_OBJS := matmmltf_pdx4.o

A_ROWS := 2
A_COLS := 3
B_ROWS := 3
B_COLS := 3

PARAMS := -DA_ROWS=$(A_ROWS) -DA_COLS=$(A_COLS)
PARAMS := $(PARAMS) -DB_ROWS=$(B_ROWS) -DB_COLS=$(B_COLS)

$(EXPERT_OBJ): $(EXPERT_SRC)
	$(XCC) $(XCC_FLAGS) -c $(EXPERT_SRC) -o $(EXPERT_OBJ)

$(EGG_OBJ): $(EGG_SRC)
	$(XCC) $(XCC_FLAGS) -c $(EGG_SRC) -o $(EGG_OBJ)

include ../shared.mk
