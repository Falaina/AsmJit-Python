from asmjit import *
import ctypes
import array

def testAbsJmp():
    a = Assembler()
    ptr = AbsPtr(0xFFEE)
    a.jmp(ptr)
    goal = array.array('B', [0xFF, 0x25, 0xEE, 0xFF, 0x00, 0x00])
    assert a.toarray() == goal, ('Absolute Jump assembly does not match expected (%s vs %s)' % 
           (a.toarray(), goal))

# Converted from testjit.cpp
def testFunction():
    a = Assembler()

    # Prologue
    a.push(ebp)
    a.mov(ebp, esp)

    # return 1024
    a.mov(eax, imm(1024))
    
    # Epilogue
    a.mov(esp, ebp)
    a.pop(ebp)
    a.ret()
    
    raw_ptr  = int(a.make())

    print 'Generated function at %x' % (raw_ptr,), hex(a)
    
    restype = ctypes.c_int
    argtypes = []
    functype = ctypes.CFUNCTYPE(restype, *argtypes)
    func = functype(raw_ptr)
    ret = func()
    assert ret == 1024, 'JIT function did not return 1024 [actual: %d]' % (ret,)

testAbsJmp()
testFunction()


            
