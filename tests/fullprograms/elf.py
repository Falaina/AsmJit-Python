from __future__ import print_function
from pprint import pprint
import distorm3
from elftools.elf.elffile import ELFFile 
from binascii import hexlify
import ctypes, os
libc = ctypes.cdll.LoadLibrary('libc.so.6')
from numbers import Number
from collections import OrderedDict

import logging
logging.basicConfig(format='%(asctime)-15s %(message)s')
log = logging.getLogger('elf_parser')
logging.getLogger().setLevel(logging.DEBUG)
log.setLevel(logging.DEBUG)

PROT_READ = 0x1
PROT_WRITE = 0x2
PROT_EXEC = 0x4
PROT_RWE = PROT_READ | PROT_WRITE | PROT_EXEC
MAP_PRIVATE = 0x02
MAP_FIXED = 0x100

# RELOCATION TYPES
R_386_NONE = 0
R_386_32   = 1
R_386_PC32 = 2

# GLOBAL CONSTANTS
SHT_NOBITS = 'SHT_NOBITS'
SHT_PROGBITS   = 'SHT_PROGBITS'
SHT_STRTAB = 'SHT_STRTAB'
SHT_SYMTAB = 'SHT_SYMTAB'
SHT_REL    = 'SHT_REL'
SHN_UNDEF  = 'SHN_UNDEF'

def decode(addr, buf):
    return distorm3.Decode(addr, buf, distorm3.Decode32Bits)

def mmap(addr, sz, flags=MAP_PRIVATE):
    fd = os.open('/dev/zero', os.O_RDWR)
    return     libc.mmap(addr, sz, PROT_RWE, flags, fd, 0)

class StringTable(object):
    """
    This class represents an ELF StringTable.
    """

    # Dictionary of known strtables
    _strtables = OrderedDict()

    def __init__(self, section):
        assert section.header.sh_type == SHT_STRTAB, \
            '%s is not a STRTAB' % (section,)
        
        self._section = section
        self._data    = section.data()
        self.name     = section.name

        StringTable._strtables[self.name] = self

    def __getitem__(self, idx):
        # The section data is just a long character array
        # of NUL-terminated strings
        return self._data[idx:self._data.find('\x00', idx)]

    @staticmethod
    def get_string(strtable_name, idx):
        """
        Gets the string at `idx` from `strtable_name`
        """
        return StringTable._strtables[strtable_name][idx]

class SymbolTableEntry(object):
    """
    An entry within an ELF SymbolTable
    """

    def __init__(self, symbol):
        symtab_entry = symbol.entry
        self._entry     = symtab_entry
        self._info      = symtab_entry.st_info
        self._other     = symtab_entry.st_other
        self.name       = symtab_entry.st_name
        self.shndx      = symtab_entry.st_shndx
        self.size       = symtab_entry.st_size
        self.value      = symtab_entry.st_value
        self.type       = symtab_entry.st_info.type
        self.bind       = symtab_entry.st_info.bind 
        self.visibility = symtab_entry.st_other.visibility

    @property 
    def symbolname(self):
        return StringTable.get_string('.strtab', self.name)

    def isDefined(self):
        return self.shndx != SHN_UNDEF

    def __repr__(self):
        return 'SymbolTableEntry(%s)' % (str(self.__dict__),)

class SymbolTable(object):
    """
    The SymbolTable class represents an ELF SymbolTable.
    """
    _symtables = OrderedDict()

    def __init__(self, section):
        assert section.header.sh_type == SHT_SYMTAB, \
            'section parser passed section of wrong type'

        
        self._section = section
        self.symbols  = []
        for symbol in section.iter_symbols():
            self.symbols.append(SymbolTableEntry(symbol))

        SymbolTable._symtables[section.name] = self

    def __getitem__(self, item):
        """
        if `item` is a number, returns the symbol indexed by `item`
        else `item` is looked up via StringTable 
        """
        if isinstance(item, Number):
            return self.symbols[item]
        else:
            for symbol in self.symbols:
                symbol_name = StringTable.get_string('.strtab', symbol.name)
                if symbol_name == item:
                    return symbol
        raise KeyError(item)

    @staticmethod
    def get_symbol(symtable_name, idx):
        return SymbolTable._symtables[symtable_name][idx]

class Relocation(object):
    """
    Represents a single relocation
    """

    def __init__(self, relocation):
        self._relocation = relocation
        self.type        = relocation['r_info_type']
        self.sym         = relocation['r_info_sym']
        self.offset      = relocation['r_offset']

    @property
    def name(self):
        return self.get_symbol().symbolname

    def get_symbol(self):
        return SymbolTable.get_symbol('.symtab', self.sym)

    def __repr__(self):
        return 'Relocation(type=%s, sym=%s, offset=%s) #name=%s' % \
            (self.type, self.sym, self.offset, self.name)
    

class Relocations(object):
    """
    Represents Relocations in an ELF file
    """
    def __init__(self, section):
        self._section = section
        self.name = section.name
        self.relocations = []
        for relocation in section.iter_relocations():
            self.relocations.append(Relocation(relocation))
        
        
    def __getitem__(self, idx):
        return self.relocations[idx]

    def get_by_symbolname(self, symbolname):
        for relocation in self.relocations:
            if relocation.name == symbolname:
                return relocation
        return None
        
        
class ELFData(object):
    """
    The ELFData class is responsible for doing the first pass 
    over the ELF file and aggregating the data into an easier
    to use format
    """

    __slots__ = ['file_path', '_elf', 'symtabs', 'strtabs', 'sections', 'relocations',
                 'section_locations', 'section_addrmap']

    def __init__(self, path):
        self.file_path = path
        self._elf = ELFFile(open(path, 'rb'))
        self.symtabs = {}
        self.strtabs = {}
        self.section_locations = {}
        self.section_addrmap = {}
        self.relocations = {}
        for header in self._elf.header.iteritems():
            print(header)

        for segment in self._elf.iter_segments():
            print(segment.header)
            print(segment.data())
            print(segment.stream)
        self._parse()
        
    def _parse_section_SHT_REL(self, section):
        self.relocations[section.name] = Relocations(section)

    def _parse_section_SHT_SYMTAB(self, section):
        self.symtabs[section.name] = SymbolTable(section)

    def _parse_section_SHT_STRTAB(self, section):
        self.strtabs[section.name] = StringTable(section)

    def section_by_idx(self, idx):
        for i, (section_name, section) in enumerate(self.sections.iteritems()):
            if i >= idx:
                return section
        return None

    # Default section parser
    # It will call any specialized handlers
    # if found
    def _parse_section(self, section):
        log.info('Parsing ELF section %s' % (section.name,))
        header = section.header
        self.sections[section.name] = section
        
        handler = '_parse_section_%s' % (header.sh_type,)
        if hasattr(self, handler):
            log.debug('Dispatching to specialized handler %s' % (handler,))
            getattr(self, handler)(section)
        else:
            log.debug('No specialized handler %s' % (handler,))

    def _parse_sections(self):
        self.sections = OrderedDict()
        for section in self._elf.iter_sections():
            self._parse_section(section)

    def _parse(self):
        self._parse_sections()

    def load(self):
        for (section_name, section) in self.sections.iteritems():
            header  = section.header
            if header.sh_type not in [SHT_PROGBITS, SHT_NOBITS]:
                continue

            log.debug('Loading *BITS section %s' %(section_name,))
            sz      = section.header.sh_size
            addr    = mmap(0, sz) & 0xFFFFFFFF
            self.section_addrmap[section_name] = addr
            log.debug('Mapping data section at 0x%x [%d bytes]' % (addr, sz))

            if header.sh_type == SHT_PROGBITS:
                log.debug('Handling progbits')
                ctypes.memmove(addr, section.data(), sz)
            elif header.sh_type == SHT_NOBITS:
                ctypes.memset(addr, 0, sz)
            else:
                log.error('Don\'t know how to handle section of type %s' % (header.sh_type))
                log.error(section)
                raise TypeError, 'Unknown section'
        self.do_relocations()

    def resolve_undefined(self, symbol):
        resolved_symbol = libc[symbol.symbolname]
        resolved_addr   = (ctypes.c_uint32 * 1).from_address(ctypes.addressof(resolved_symbol))[0]
        log.debug('Symbol %s is located at %x' %(symbol.symbolname, resolved_addr))
        return resolved_addr

    def resolve_symbol(self, symbol):
        if symbol.isDefined():
            log.debug('Using value %s for symbol %s' % (symbol.value, symbol.symbolname))
            shndx = symbol.shndx
            if shndx < len(self.sections):
                section = self.section_by_idx(shndx)
                value = self.section_addrmap[section.name] + symbol.value
                return value
            return symbol.value
        else:
            log.debug('Performing lookup for symbol %s' % (symbol.symbolname,))
            return self.resolve_undefined(symbol)

    def do_relocations(self):
        for (section_name, relocations) in self.relocations.iteritems():
            log.debug('Processing relocations for %s' % (section_name,))
            for relocation in relocations:
                r_type = relocation.type
                r_sym  = relocation.sym
                r_off  = relocation.offset
                section_addr = self.section_addrmap['.text']
                symbol = SymbolTable.get_symbol('.symtab', r_sym)
                log.debug('Resolving symbol %s' %(symbol,))
                symbol_val = self.resolve_symbol(symbol)
                ptr = (ctypes.c_uint32 * 1).from_address((section_addr + r_off))
                if r_type == R_386_NONE:
                    log.debug('Ignoring relocation of type R_386_NONE')
                elif r_type == R_386_32: 
                    log.debug('Performing R_386_32 relocation %s' % (relocation,))
                    ptr[0] = symbol_val
                elif r_type == R_386_PC32: 
                    # subtract the location of the next instruction (5 + current instruction) from the target
                    log.debug('Performing R_386_PC32 relocation %s' % (relocation,))
                    ptr[0] = (symbol_val - (section_addr + r_off + 4))


    def run(self):
        section = self.sections['.text']
        import time
        data_arr = (ctypes.c_char * section.header.sh_size).from_address(self.section_addrmap['.text'])
        log.info('Preparing to run program at %x' % (self.section_addrmap['.text'],))
        main_proto = ctypes.CFUNCTYPE(ctypes.c_int, ctypes.c_int, 
                                      ctypes.POINTER(ctypes.POINTER(ctypes.c_char)))
        prog_name = ctypes.create_string_buffer('elf.py')
        prog_arg  = ctypes.create_string_buffer('a.txt')

        main_addr = SymbolTable.get_symbol('.symtab', 'main')
        main = main_proto(main_addr)
        pprint(decode(self.section_addrmap['.text'], data_arr.raw))
        argv = (ctypes.POINTER(ctypes.c_char) * 2)()
        argv[0] = ctypes.cast(prog_name, ctypes.POINTER(ctypes.c_char))
        argv[1] = ctypes.cast(prog_arg, ctypes.POINTER(ctypes.c_char))
        argv_p = ctypes.cast(argv, ctypes.POINTER(ctypes.c_char))
        time.sleep(5)
        main(2, argv)


#load_elf(elf)
#relocate()
#load()
#pprint(decode(0x0, progbits['.text'].data()))
    
#load_elf(elf)
