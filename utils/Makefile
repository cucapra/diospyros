TARGET=${XTENSA_CORE} # get the target device from the environment
DIOSPYROS_ROOT=~/diospyros

SRCS := $(wildcard src/*.cpp)
BENCHMARK_SRCS = $(wildcard bin/*.cpp)
TEST_SRCS = $(wildcard test/*.cpp)
HEADERS := $(wildcard include/*.h)
INCLUDES := -I include

XCC := xt-xcc
XCXX := xt-clang++ --xtensa-core=$(TARGET)
XRUN := xt-run --xtensa-core=$(TARGET)
XCC_FLAGS += -O3 -mlongcalls -mtext-section-literals -fvectorize
# for verbose: -LNO:SIMD_V
XCXX_FLAGS += -O3 -std=c++11 -mtext-section-literals -mcoproc -LNO:SIMD -w -O3 -mcoproc -g -mlongcalls -DNDEBUG -ffunction-sections -fdata-sections -DEIGEN_STRONG_INLINE=inline -fvectorize -std=c++17
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
TEST_BINARY=test_bin
BENCHMARK_BINARY=benchmark_bin

.PHONY: clean sim

default: $(BENCHMARK_BINARY)

%.o : %.cpp $(HEADERS)
	$(XCXX) $(PARAMS) $(XCXX_FLAGS) $(INCLUDES) -c $< -o $@

$(TEST_BINARY): $(OBJS) $(HEADERS) $(TEST_SRCS)
	$(XCXX) $(PARAMS) $(XCXX_FLAGS) $(TEST_SRCS) $(INCLUDES) -o $(TEST_BINARY) $(OBJS) $(GTEST_LDFLAGS)
	$(XRUN) $(PARAMS) $(XSIM_FLAGS) $(TEST_BINARY)

$(BENCHMARK_BINARY): $(OBJS) $(BENCHMARK_OBJS) # $(HEADERS)
	$(XCXX) $(PARAMS) $(XCXX_FLAGS) $(INCLUDES) -o $(BENCHMARK_BINARY) $(OBJS) $(BENCHMARK_OBJS)

sim: $(BENCHMARK_BINARY)
	$(XRUN) $(XSIM_FLAGS) $(BENCHMARK_BINARY)

clean:
	rm -rf $(OBJS) $(BENCHMARK_OBJS) $(TEST_OBJS) $(BENCHMARK_BINARY) $(TEST_BINARY)
