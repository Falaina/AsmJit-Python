CMAKE_MINIMUM_REQUIRED(VERSION 2.6)
# We need SWIG
FIND_PACKAGE(SWIG REQUIRED)
INCLUDE(${SWIG_USE_FILE})

# Add Python
FIND_PACKAGE(PythonLibs)
INCLUDE_DIRECTORIES(${PYTHON_INCLUDE_PATH})

# Add AsmJit
SET(ASMJIT_BASE ${CMAKE_CURRENT_SOURCE_DIR}/deps/AsmJit-1.0-beta4)
SET(ASMJIT_DIR ${ASMJIT_BASE}/AsmJit)
# AsmJit sources
SET(ASMJIT_SOURCES
  ${ASMJIT_DIR}/AssemblerX86X64.cpp
  ${ASMJIT_DIR}/CodeGenerator.cpp
  ${ASMJIT_DIR}/Compiler.cpp
  ${ASMJIT_DIR}/CompilerX86X64.cpp
  ${ASMJIT_DIR}/CpuInfo.cpp
  ${ASMJIT_DIR}/Defs.cpp
  ${ASMJIT_DIR}/DefsX86X64.cpp
  ${ASMJIT_DIR}/Logger.cpp
  ${ASMJIT_DIR}/MemoryManager.cpp
  ${ASMJIT_DIR}/MemoryMarker.cpp
  ${ASMJIT_DIR}/OperandX86X64.cpp
  ${ASMJIT_DIR}/Platform.cpp
  ${ASMJIT_DIR}/Util.cpp
)

# AsmJit C++ headers
SET(ASMJIT_HEADERS
  ${ASMJIT_DIR}/ApiBegin.h
  ${ASMJIT_DIR}/ApiEnd.h
  ${ASMJIT_DIR}/AsmJit.h
  ${ASMJIT_DIR}/Assembler.h
  ${ASMJIT_DIR}/AssemblerX86X64.h
  ${ASMJIT_DIR}/Build.h
  ${ASMJIT_DIR}/CodeGenerator.h
  ${ASMJIT_DIR}/Compiler.h
  ${ASMJIT_DIR}/CompilerX86X64.h
  ${ASMJIT_DIR}/Config.h
  ${ASMJIT_DIR}/CpuInfo.h
  ${ASMJIT_DIR}/Defs.h
  ${ASMJIT_DIR}/DefsX86X64.h
  ${ASMJIT_DIR}/Logger.h
  ${ASMJIT_DIR}/MemoryManager.h
  ${ASMJIT_DIR}/MemoryMarker.h
  ${ASMJIT_DIR}/Operand.h
  ${ASMJIT_DIR}/OperandX86X64.h
  ${ASMJIT_DIR}/Platform.h
  ${ASMJIT_DIR}/Util.h
  ${ASMJIT_DIR}/Util_p.h
)
INCLUDE_DIRECTORIES(${ASMJIT_DIR})

# Setup output directories
SET(LIBRARY_OUTPUT_PATH ${CMAKE_CURRENT_SOURCE_DIR}/lib)
SET(EXECUTABLE_OUTPUT_PATH ${CMAKE_CURRENT_SOURCE_DIR}/bin)

SET(CMAKE_SWIG_FLAGS "")
SET(CMAKE_SWIG_OUTDIR "lib")
SET_SOURCE_FILES_PROPERTIES(swig/AsmJit.i PROPERTIES CPLUSPLUS ON)
SET_SOURCE_FILES_PROPERTIES(swig/AsmJit.i SWIG_FLAGS "-includeall")
SWIG_ADD_MODULE(AsmJit python swig/AsmJit.i ${ASMJIT_SOURCES})
SWIG_LINK_LIBRARIES(AsmJit ${PYTHON_LIBRARIES})   


