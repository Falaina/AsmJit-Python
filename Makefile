# CROSS=i686-w64-mingw32-
RC=$(CROSS)windres
LD=$(CROSS)ld
AR=$(CROSS)ar
CC=$(CROSS)gcc
CXX=$(CROSS)g++

ASMJIT_DIR=deps/AsmJit-1.0-beta4/AsmJit
INCLUDES=-I$(ASMJIT_DIR)/.. -I/usr/include/python2.7

TEST_NAMES := jittests.py compilertests.py
TEST_DIR   := tests/
TEST_FILES := $(addprefix $(TEST_DIR), $(TEST_NAMES))

all: lib/_AsmJit.so test

obj/AsmJit_wrap.cxx: swig/AsmJit.i swig/Compiler.i swig/Defs.i
	@echo "******* Generating SWIG wrapper *******\n"
	swig -c++ -python -o $@ swig/AsmJit.i
	mv obj/AsmJit.py lib/AsmJit.py

lib/_AsmJit.so: obj/AsmJit_wrap.cxx
	@echo "******* Building Python extension *******\n"
	cd build
	$(CXX) $(INCLUDES) $(ASMJIT_DIR)/*.cpp obj/AsmJit_wrap.cxx -shared -fPIC -o $@

test: lib/_AsmJit.so $(TEST_FILES)
	@echo "******* Running tests *******\n"
	nosetests -v $(TEST_FILES)

# Forms the basis of the swig interface
preprocess: 
#	clang -E -DASMJIT_X86 -DAsmJit_EXPORTS OperandX86X64.h > OperandX86X64.preprocessed.h
#	clang -E -DASMJIT_X86 -DAsmJit_EXPORTS AssemblerX86X64.h > AssemblerX86X64.preprocessed.h
	cp deps/AsmJit-1.0-beta4/AsmJit/CompilerX86X64.h CompilerX86X64.h
	cp deps/AsmJit-1.0-beta4/AsmJit/DefsX86X64.h DefsX86X64.h
	-clang -E -D_ASMJIT_COMPILER_H -DASMJIT_X86 -DAsmJit_EXPORTS CompilerX86X64.h > CompilerX86X64.preprocessed.h
	-clang -E -D_ASMJIT_DEFS_H -DASMJIT_X86 -DAsmJit_EXPORTS DefsX86X64.h > DefsX86X64.preprocessed.h
	perl -n scripts/clean_preprocessed.pl DefsX86X64.preprocessed.h > DefsX86X64.clean.h
