from asmjit import *
import array

def testAbsJmp():
    a = Assembler()
    ptr = AbsPtr(0xFFEE)
    a.jmp(ptr)
    goal = array.array('B', [0xFF, 0x25, 0xEE, 0xFF, 0x00, 0x00])
    assert a.toarray() == goal, ('Absolute Jump assembly does not match expected (%s vs %s)' % 
           (a.toarray(), goal))

testAbsJmp()
     
            
