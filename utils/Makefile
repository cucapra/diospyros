TARGET=${XTENSA_CORE} # get the target device from the environment
DIOSPYROS_ROOT=~/diospyros

SRCS := $(wildcard src/*.cpp)
BENCHMARK_SRCS = $(wildcard bin/*.cpp)
TEST_SRCS = $(wildcard test/*.cpp)
HEADERS := $(wildcard include/*.h)
INCLUDES := -I include

XCC := xt-xcc
XCXX := xt-xc++ --xtensa-core=$(TARGET)
XRUN := xt-run --xtensa-core=$(TARGET)
XCC_FLAGS += -O3 -mlongcalls -mtext-section-literals -fvectorize
# for verbose: -LNO:SIMD_V
XCXX_FLAGS += -O3 -std=c++11
XSIM_FLAGS := --summary --mem_model

INCLUDES += -I $(DIOSPYROS_ROOT)/third-party/eigen/eigen/
INCLUDES += -I $(DIOSPYROS_ROOT)/third-party/gtest/gtest/googletest/include
# TODO: currently a hack for now pending better placement of utils.h
INCLUDES += -I $(DIOSPYROS_ROOT)/evaluation/src

PARAMS += -DOUTFILE='"$(OUTFILE)"'

OBJS=$(SRCS:.cpp=.o )
TEST_OBJS=$(TEST_SRCS:.cpp=.o)
BENCHMARK_OBJS=$(BENCHMARK_SRCS:.cpp=.o)

GTEST_LDFLAGS=-lgtest_main -lgtest

.PHONY: clean sim

default: benchmark

%.o : %.cpp $(HEADERS)
	$(XCXX) $(PARAMS) $(XCXX_FLAGS) $(INCLUDES) -c $< -o $@

test: $(OBJS) $(HEADERS) $(TEST_SRCS)
	@echo $(OBJS)
	@echo $(TEST_SRCS)
	$(XCXX) $(PARAMS) $(XCXX_FLAGS) $(TEST_SRCS) $(INCLUDES) -o test $(OBJS) $(GTEST_LDFLAGS)
	$(XRUN) $(PARAMS) $(XSIM_FLAGS) test

benchmark: $(OBJS) $(BENCHMARK_OBJS) # $(HEADERS)
	$(XCXX) $(PARAMS) $(XCXX_FLAGS) $(INCLUDES) -o benchmark $(OBJS) $(BENCHMARK_OBJS)

sim: benchmark
	$(XRUN) $(XSIM_FLAGS) benchmark

clean:
	rm -rf $(OBJS) $(BENCHMARK_OBJS) $(TEST_OBJS)
