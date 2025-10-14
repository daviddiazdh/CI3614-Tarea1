CXX = clang++
CXXFLAGS = -std=c++17 -Wall -Wextra -g -fprofile-instr-generate -fcoverage-mapping
SRC = src/Vector3D.cpp
TEST = tests/test_vector3d.cpp
OUT = test_vector
PROFRAW = $(OUT).profraw
PROFDATA = $(OUT).profdata

all: run coverage

$(OUT): $(SRC) $(TEST)
	$(CXX) $(CXXFLAGS) $(SRC) $(TEST) -o $(OUT)

run: $(OUT)
	LLVM_PROFILE_FILE=$(PROFRAW) ./$(OUT)

coverage: $(OUT)
	@echo "Ejecutando tests..."
	LLVM_PROFILE_FILE=$(PROFRAW) ./$(OUT)
	@echo "Generando profdata..."
	llvm-profdata merge -sparse $(PROFRAW) -o $(PROFDATA)
	@echo "Mostrando cobertura..."
	llvm-cov report ./$(OUT) -instr-profile=$(PROFDATA)

clean:
	rm -f $(OUT) $(PROFRAW) $(PROFDATA)