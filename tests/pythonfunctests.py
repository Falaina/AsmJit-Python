import ctypes
import array
from binascii import hexlify
import sys, os
import logging
import unittest

try: 
    sys.path.append('.')
    from asmjit import *
except ImportError:
    # Maybe we're being called directly from our own dir
    # append .. and give it one more shot
    sys.path.append('..')
    from asmjit import *


log = logging.getLogger('test.pythonfunction')
def _py_callback():
    return 0x512

def _py_trampoline_callback():
    print 'Original return was %x (trampoline %x)' % (orig_fn, trampoline_fn)
    return 0xBED

CALLBACK_FUNC = ctypes.CFUNCTYPE(ctypes.c_int)
_callback = CALLBACK_FUNC(_py_callback)
_trampoline_callback = CALLBACK_FUNC(_py_callback)

def CallbackAddr(func):
    addr = ctypes.addressof(func)
    start = ctypes.c_uint32.from_address(addr).value
    return start

class TestPythonFuncs(unittest.TestCase):

    def testPythonJit(self):
        """
        Calling a python function from a JIT generated function
        """
        a = Assembler()

        a.call(AbsPtr(ctypes.addressof(_callback)))
        a.ret()

        fn = MakeFunction(int(a.make()))

        ret = fn()
        self.assertEqual(ret, 0x512)

    def testPythonTrampoline(self):
        """
        Calling a python function from a trampoline
        """
        a = Assembler()

        # Generate Original function
        [a.nop() for _ in range(TRAMPOLINE_SIZE)]
        a.mov(eax, uimm(0xFFFF))
        a.ret()

        fn_ptr = int(a.make())
        fn = MakeFunction(fn_ptr)

        # Verify original function
        ret = fn()
        assert ret == 0xFFFF, '0x%x does not equal 0xFFFF' % (ret,)

        # Generate Trampoline 
        a.clear()

        trampoline_cb_addr = CallbackAddr(_trampoline_callback)
        log.info('Trampoline callback is located at %x' % (trampoline_cb_addr,))
        log.info('Original function at %x' % (fn_ptr,))

        (saved_buf, trampoline_fn_buf, trampoline_buf) = WriteTrampoline(fn_ptr, trampoline_cb_addr)
        log.info('Original %s\nTrampoline_fn %s\n Trampoline: %s' % \
                 (hexlify(saved_buf), hexlify(trampoline_fn_buf), hexlify(trampoline_buf)))
        ret = fn()
        assert ret == 0xBED, '0x%x does not equal 0xBED' % (ret,)


if __name__ == '__main__':
    unittest.main()
    
