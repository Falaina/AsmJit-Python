# Test for python-specific extensions to asmjit
import sys
import ctypes
import array
from binascii import hexlify
from functools import wraps
import logging
import unittest
log = logging.getLogger('tests.extensions')

try: 
    sys.path.append('.')
    from asmjit import *
except ImportError:
    # Maybe we're being called directly from our own dir
    # append .. and give it one more shot
    sys.path.append('..')
    from asmjit import *

TYPE_JUMP = 0x25
TYPE_CALL = 0x15

class TestExtensions(unittest.TestCase):

    def assertEqual(self, actual, expected):
        try:
            super(TestExtensions, self).assertEqual(actual, expected)
        except AssertionError:
            raise AssertionError('0x%x != 0x%x' % (actual, expected))

    def _jmp_or_call(self, type_):
        assert type_ in [TYPE_JUMP, TYPE_CALL], 'Unknown type %s' %(type_,)
        a = Assembler()
        a.mov(eax, uimm(0xCCCCCCCC))
        a.ret()
        fn0_ptr = int(a.make())

        a.clear()
        [a.nop() for _ in range(10)]
        a.mov(eax, uimm(0xBAF))
        a.ret()

        a.clear()
        if type_ == TYPE_JUMP:
            a.py_jmp(fn0_ptr)
        else:
            raise NotImplementedError
        fn1_ptr = int(a.make())
        log.info('Generated %s' % (hexlify((ctypes.c_char * 12).from_address(fn1_ptr)),))
        fn1 = MakeFunction(fn1_ptr)
        ret = fn1()
        self.assertEqual(ret, 0xCCCCCCCC)                

    def testAbsJmp(self):
        """
        Test the emission of an Indirect Absolute Jump
        (currently is unsupported for x86 in asmjit)
        """
        self._jmp_or_call(TYPE_JUMP)

    def testCpy(self):
        """
        Test the copy of instructions from the assembler code buffer
        to an arbitrary location of memory
        """
        goal = 0xABCDEF00

        a = Assembler()
        a.mov(eax, uimm(goal))
        a.ret()

        code_sz = a.getCodeSize()
        dest = ctypes.create_string_buffer(code_sz)
        log.info('Allocated code buffer of size %d at %x' % 
                 (code_sz, ctypes.addressof(dest)))

        ctypes.memmove(dest, a.py_make(), code_sz)

        fn = a.py_make_cfunc()
        ret = fn()
        self.assertEqual(ret, goal)

if __name__ == '__main__':
    unittest.main()





