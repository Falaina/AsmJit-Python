# Test for python-specific extensions to asmjit
from asmjit import *
import ctypes
import array
from binascii import hexlify
import logging
log = logging.getLogger('tests.extensions')

def testAbsCall():
    assert False
    

def testAbsJmp():
    """
    Test the emission of an Indirect Absolute Jump
    (currently is unsupported for x86 in asmjit)
    """

    a = Assembler()
    a.mov(eax, uimm(0xCCCCCCCC))
    a.ret()
    fn0_ptr = int(a.make())

    a.clear()
    [a.nop() for _ in range(10)]
    a.mov(eax, uimm(0xBAF))
    a.ret()

    a.clear()
    a.py_jmp(fn0_ptr)
    a.ret()
    fn1_ptr = int(a.make())
    print 'Generated %s' % \
        (hexlify((ctypes.c_char * 12).from_address(fn1_ptr)),)
    fn1 = MakeFunction(fn1_ptr)
    ret = fn1()
    
    assert ret == 0xCCCCCCCC, \
        '0x%x does not equal 0xCCCCCCCC' % (ret,)

def testCpy():
    """
    Test the copy of instructions from the assembler code buffer
    to an arbitrary location of memory
    """
    assert False
    
testAbsJmp()
testCpy()

    
    

    
