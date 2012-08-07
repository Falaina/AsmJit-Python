# CROSS=i686-w64-mingw32-
RC=$(CROSS)windres
LD=$(CROSS)ld
AR=$(CROSS)ar
CC=$(CROSS)gcc
CXX=$(CROSS)g++
ASMJIT_DIR=AsmJit-1.0-beta4/AsmJit
INCLUDES=-I$(ASMJIT_DIR)/.. -I/usr/include/python2.7

_AsmJit.so: AsmJit_wrap.cxx
	cd build
	$(CXX) $(INCLUDES) $(ASMJIT_DIR)/*.cpp AsmJit_wrap.cxx -shared -fPIC -o _AsmJit.so

AsmJit_wrap.cxx: AsmJit.i
	swig -c++ -python -o AsmJit_wrap.cxx  AsmJit.i

# Forms the basis of the swig interface
preprocess: 
	clang -E -DASMJIT_X86 -DAsmJit_EXPORTS OperandX86X64.h > OperandX86X64.preprocessed.h
	clang -E -DASMJIT_X86 -DAsmJit_EXPORTS AssemblerX86X64.h > AssemblerX86X64.preprocessed.h