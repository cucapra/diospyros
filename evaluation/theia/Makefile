# It's eigen-3 on Gorgonzola and eigen3 on macOS with Homebrew.
ifneq (,$(wildcard /usr/local/include/eigen3))
EIGEN_DIR := /usr/local/include/eigen3
else
EIGEN_DIR := /usr/local/include/eigen-3
endif

CXX := c++
CXXFLAGS := -O3 -std=c++11 -w -I $(EIGEN_DIR)

XT_CXX := xt-xc++

# Shorthand for building all targets (in one mode or the other).
.PHONY: all xt
all: eigen.native
xt: eigen.xt dios.xt

eigen.native: decompose-projection-matrix.cpp rq_decomposition.h
	$(CXX) $(CXXFLAGS) decompose-projection-matrix.cpp -o $@

eigen.xt: decompose-projection-matrix.cpp rq_decomposition.h
	$(XT_CXX) $(CXXFLAGS) decompose-projection-matrix.cpp -o $@

dios.xt: egg_kernel.c decompose-projection-matrix.cpp dios_rq_decomposition.h
	$(XT_CXX) $(CXXFLAGS) -DDIOS \
		egg_kernel.c decompose-projection-matrix.cpp -o $@

# Run the Xtensa versions. Use `make run-eigen`, `make run-dios`,
# or `make run` for both.
.PHONY: run-% run
run-%: %.xt
	xt-run $^
run: run-eigen run-dios

# Cleanup.
.PHONY: clean
clean:
	rm -f eigen.native eigen.xt dios.xt
