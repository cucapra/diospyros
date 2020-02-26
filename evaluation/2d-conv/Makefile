SRC := *.c
OBJECT = conv2d.o

XCC := xt-xcc
XRUN := xt-run
XCC_FLAGS += -std=c99 -O3 -LNO:simd -clist
XSIM_FLAGS := --summary --mem_model

NATURE_DIR := /data/Xplorer-8.0.11-workspaces/workspace/fusiong3_library
NATURE_SRC := $(NATURE_DIR)/conv2df_pdx4.c
NATURE_OBJ := conv2df_pdx4.o
NATURE_INC := -I $(NATURE_DIR)/include -I $(NATURE_DIR)/include_private -DXCHAL_HAVE_FUSIONG_SP_VFPU=1


I_ROWS := 2
I_COLS := 2
F_ROWS := 2
F_COLS := 2

PARAMS := -DI_ROWS=$(I_ROWS) -DI_COLS=$(I_COLS) -DF_ROWS=$(F_ROWS) -DF_COLS=$(F_COLS)

all: $(OBJECT)

clean:
    rm -rf $(OBJECT) $(NATURE_OBJ)

$(NATURE_OBJ):
    $(XCC) $(XCC_FLAGS) $(NATURE_INC) -c $(NATURE_SRC) -o $(NATURE_OBJ)

$(OBJECT): $(NATURE_OBJ) $(SRC)
    $(XCC) $(PARAMS) $(XCC_FLAGS) $(NATURE_OBJ) $(SRC) -o $(OBJECT)

run: $(OBJECT)
    $(XRUN) $(OBJECT)

sim: $(OBJECT)
    $(XRUN) $(XSIM_FLAGS) $(OBJECT)
