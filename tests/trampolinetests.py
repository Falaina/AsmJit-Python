from asmjit import *
import unittest
import ctypes
import array

class TestTrampoline(unittest.TestCase):
    def testTrivialTrampoline(self):
        """
        Trivial Trampoline Test

        This creates two functions fn0 and fn1.
        fn0 simply returns
        fn1 simply calls fn0 and returns 0x15
        """
        a = Assembler()

        # fn0
        a.ret()
        # I'm already playing fast and loose with types too much in this
        # project, so i'll try and keep a distinction between python
        # numbers that hold a pointer and the swig objects that
        # represent a void pointer
        fn0_void_ptr = a.make()
        fn0_ptr = int(fn0_void_ptr)

        a.clear()

        # fn1
        a.call(fn0_void_ptr)
        a.mov(eax, imm(0x15))
        a.ret()
        fn1_ptr = int(a.make())

        # Make prototypes and functions
        fn0 = ctypes.CFUNCTYPE(ctypes.c_int)(fn0_ptr)
        fn1 = ctypes.CFUNCTYPE(ctypes.c_int)(fn1_ptr)

        # Call fn0 for shits and giggles
        fn0()

        ret = fn1()    
        self.assertEqual(ret, 0x14)

    def testNonReturningTrampoline(self):
        """ 
        Intercepting Trampoline (No return to API)

        Simple test for a Trampoline. The Trampoline
        does not return control to the original function
        """
        a = Assembler()

        # Let's write an original function that returns 0xDEADBEAF
        [a.nop() for _ in range(5)] # Room for the trampoline
        a.mov(eax, uimm(0xDEADBEEF))
        a.ret()
        orig_fn_void_ptr = a.make()
        orig_fn_ptr      = int(orig_fn_void_ptr)
        orig_fn = MakeFunction(orig_fn_ptr)

        # Let's write a hook function that returns 0xCAFEBABE
        a.clear()
        a.mov(eax, uimm(0xCAFEBABE))
        a.ret()
        new_fn_void_ptr = a.make()
        new_fn_ptr = int(new_fn_void_ptr)
        new_fn = MakeFunction(new_fn_ptr)

        # Test the old function
        ret = orig_fn()
        assert ret == 0xDEADBEEF, '0x%x does not = 0xDEADBEEF' %(ret,)

        # Write trampoline
        jmp_ptr = (ctypes.c_ubyte * 2).from_address(orig_fn_ptr)
        off_ptr = MakeIntPtr(orig_fn_ptr + 2)
        dst_ptr = MakeIntPtr(orig_fn_ptr + 6)

        # Absolute Indirect Jump
        jmp_ptr[0] = 0xFF
        jmp_ptr[1] = 0x25

        off_ptr[0] = ctypes.c_long(orig_fn_ptr + 6)
        dst_ptr[0] = new_fn_ptr

        trampoline_buf = (ctypes.c_ubyte * 10).from_address(orig_fn_ptr)

        # Call the old function (which is now hooked)
        ret = orig_fn()
        assert ret == 0xCAFEBABE, '0x%x hooked function did not return expected 0xCAFEBABE' %(ret)
