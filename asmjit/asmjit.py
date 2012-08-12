import AsmJit
import array
from ctypes import POINTER, pointer, c_uint8, c_uint32, create_string_buffer, cast, addressof, CFUNCTYPE, c_int, c_char, memmove
from binascii import hexlify
import sys
import logging
logging.basicConfig(format='%(asctime)-15s %(message)s')
log = logging.getLogger('asmjit')
logging.getLogger().setLevel(logging.INFO)
log.setLevel(logging.INFO)
__pychecker__ = 'unusednames=_ALL_'

try:
    import platform
    arch = platform.architecture()
    assert arch[0] == '32bit', 'asmjit Python bindings only work on 32-bit x86'
except ImportError:
    sys.stderr.write('Unable to determine system platform\n')
    raise

# TODO: x86-64
TRAMPOLINE_SIZE = 2 + 4 + 4 # JMP Instruction(2), Indirect Address(4), Direct Address(4)

# Some private globals
_JMP_INSTN  = 'JMP'
_CALL_INSTN = 'CALL'

# Bring reg names into global namespace 
_REGS_   = ['eax', 'ecx', 'edx', 'ebx', 'esp', 'ebp', 'edi', 'esi']
# Functions worth exporting directly to importers
_FUNCS_ = ['AbsPtr', 'imm', 'uimm', 'GPVar', 'UIntFunctionBuilder0']
_GLOBALS_ = ['CALL_CONV_DEFAULT']
_MODULE_ = sys.modules[__name__]
for reg in (_REGS_ + _FUNCS_ + _GLOBALS_):
    setattr(_MODULE_, reg, getattr(AsmJit, reg))

def MakeIntPtr(num):
    return (c_int * 1).from_address(num)

def MakeInt(num):
    return c_int(num)

def MakeIntFromPtr(var):
    return c_int(addressof(var))

def MakeFunction(ptr, *args):
    """ 
    Takes an integer that points to a function
    and creates a callable for that function.
    args contains the arguments types for the function.
    All functions return c_uint
    """
    return CFUNCTYPE(c_uint32, *args)(ptr)
    
class Code(object):
    """    
    Wrapper around the byte buffer that represents
    code generated by AsmJit
    """
    def __init__(self, code, code_size, code_maxlen=20): 
        self.ptr  = int(code)
        self.size = code_size
        self.code_maxlen = code_maxlen

        # Create ctypes to represent the code
        self.code_reprtype = (c_uint8 * min(code_maxlen, code_size))
        self.code_type = (c_uint8 * code_size)

    def toarray(self):
        code = self.code_type.from_address(self.ptr)
        return array.array('B', code)

    def tohex(self):
        return hex(self)

    def __hex__(self):
        return hexlify(self.toarray())

    def __repr__(self):
        postfix = ''
        if self.size > self.code_maxlen:
            postfix = '...'
        code = self.code_reprtype.from_address(self.ptr)
        return 'Code - ' + repr(array.array('B', code)) + postfix

class LibWrapper(object):       
    def __init__(self, base):
        self.base = base

    def __getattr__(self, attr):
        if attr not in self.__dict__:
            return getattr(self.base, attr)
        return self.__dict__[attr]
     
class Assembler(LibWrapper):
    """ 
    Wrapper around AsmJit.Assembler
    """
    def __init__(self): 
        self.assembler = AsmJit.Assembler()
        super(Assembler, self).__init__(self.assembler)

    def __repr__(self):
        return 'Assembler - ' + repr(self.code)

    def __hex__(self):
        return hex(self.code)

    def toarray(self):
        return self.code.toarray()

    def _py_emit_call_or_jmp(self, dest, instn):
        __pychecker__ = 'no-classattr'

        if instn   == _JMP_INSTN:
            opcode2 = 0x15
        elif instn == _CALL_INSTN:
            opcode2 = 0x25
        else:
            raise ValueError, 'Unsupported instn %x' % (instn,)

        self._emitByte(0xFF)
        self._emitByte(opcode2)
        self._emitDWord(int(self.getCode()) + 6)
        self._emitDWord(dest)


    def py_call(self, dest):
        return self._py_emit_call_or_jmp(dest, _CALL_INSTN)

    def py_jmp(self, dest):
        return self._py_emit_call_or_jmp(dest, _JMP_INSTN)

    def py_copy(self, dest, src, count):
        raise NotImplementedError

    @property
    def code(self):
        c = Code(self.getCode(), self.getCodeSize())
        return c

class Compiler(LibWrapper):
    """
    Wrapper around AsmJit.Compiler
    """
    def __init__(self):
        self.compiler = AsmJit.Compiler()
        super(Compiler, self).__init__(self.compiler)
def DerefUInt32(p):
    return c_uint32.from_address(p).value

# Exports from this module
_EXPORTS_ = ['AsmJit', 'DerefUInt32', 'MakeFunction', 'MakeIntPtr', 'TRAMPOLINE_SIZE']

# Give importers a direct reference to underlying AsmJit
_ALL_ = _EXPORTS_ + _REGS_ + _FUNCS_
