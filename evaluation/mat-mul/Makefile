OBJECT = matmul.o

NATURE_OBJS := matmmltf_pdx4.o

PARAMS := -DA_ROWS=$(A_ROWS) -DA_COLS=$(A_COLS)
PARAMS := $(PARAMS) -DB_ROWS=$(B_ROWS) -DB_COLS=$(B_COLS)

$(EGG_OBJ): $(EGG_SRC)
	$(XCC) $(XCC_FLAGS) -c $(EGG_SRC) -o $(EGG_OBJ)

include ../shared.mk
