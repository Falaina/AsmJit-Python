from __future__ import print_function
from pprint import pprint
import elftools
import distorm3
from elftools.elf.elffile import ELFFile 
from binascii import hexlify
import ctypes, os
libc = ctypes.cdll.LoadLibrary('libc.so.6')


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

def decode(addr, buf):
    return distorm3.Decode(addr, buf, distorm3.Decode32Bits)

def mmap(addr, sz, flags=MAP_PRIVATE):
    fd = os.open('/dev/zero', os.O_RDWR)
    return     libc.mmap(addr, sz, PROT_RWE, flags, fd, 0)
g_sections = {}
g_sections_arr = []
g_symbols = []
g_strtable = ''

def section_handler(fn):
    def new_fn(section):
        name = elf._get_section_name(section)
        g_sections[name] = section
        g_sections_arr.append(section)
        return fn(section)
    new_fn.__name__ = fn.__name__
    return new_fn

def get_c_string_at(idx):
    return g_strtable[idx:g_strtable.find('\x00', idx)]

@section_handler
def handle_progbits(section):
    pass

@section_handler
def handle_str(section): 
    global g_strtable
    g_strtable = section.data()

@section_handler
def handle_sym(section):
    for symbol in section.iter_symbols():
        g_symbols.append(symbol)


def handle_rel(section):
    name = elf._get_section_name(section)
    g_sections[name] = section

def resolve_symbol(symtab_entry):
    sym_name = get_c_string_at(symtab_entry.st_name)
    print('\n\n\nResolving %s' % (sym_name,))
    resolved_symbol = libc[sym_name]
    resolved_addr = (ctypes.c_uint32 * 1).from_address(ctypes.addressof(resolved_symbol))[0]
    print('Symbol %s is located at %x' %(sym_name, resolved_addr))
    return resolved_addr

def get_symbol_name(symbol_entry):
    return get_c_string_at(symbol_entry.st_name)

relocation_info = []
data_relocations = []


def relocate():
    section = g_sections['.rel.text']
    for relocation in section.iter_relocations():
        info_type = relocation['r_info_type']
        info_sym  = relocation['r_info_sym']
        offset    = relocation['r_offset']
        print(relocation)
        symbol_entry = g_symbols[info_sym].entry
        print(symbol_entry)
        shndx = symbol_entry.st_shndx
        if shndx == 'SHN_UNDEF':
            symbol_addr = resolve_symbol(symbol_entry)
            print('Inserting address %x at offset %x' % (symbol_addr, offset))
            relocation_info.append((offset, symbol_addr))
        else:
            sz = symbol_entry.st_size
            print('Processing internal relocation at offset %x [section %d, bytes %d]', (offset, shndx, sz))
            section = g_sections_arr[shndx]
            print('Section containing data: %s' % (section.header,))
            addr = symbol_entry.st_value
            print('Data being relocated %s' % (section.data()[addr:addr+sz],))
            data_relocations.append((offset, addr, sz))
            

def load_elf(elf):
    sections = elf.iter_sections()
    segments = elf.iter_segments()
    for section in sections:
        header = section.header
        print('Section %s' % (section.name,))
        print(section.header)
        if header.sh_type == 'SHT_PROGBITS':
            handle_progbits(section)
        elif header.sh_type == 'SHT_REL':
            handle_rel(section)
        elif header.sh_type == 'SHT_SYMTAB':
            handle_sym(section)
        elif header.sh_type == 'SHT_STRTAB' and \
             section.name == '.strtab':
            handle_str(section)

    for segment in segments:
        header = segment.header
        vaddr = header.p_vaddr
        file_sz = header.p_filesz
        mem_sz  = header.p_memsz
        assert mem_sz >= file_sz, \
            'ELF segment file_sz[%d] > mem_sz[%d]' % (file_sz, mem_sz)

        print('Mapping %d bytes at %x' % (mem_sz, vaddr))

def load():
    to_load = ['.text', '.bss']
    section_mapping = {}
    print('Loading data section')
    data_section = g_sections['.data']
    data_sz      = data_section.header.sh_size
    data_addr    = mmap(0, data_sz) & 0xFFFFFFFF
    print('Mapping data section at 0x%x [%d bytes]' % (data_addr, data_sz))
    section_mapping[2] = data_addr
    ctypes.memmove(data_addr, data_section.data(), data_sz)

    for section_name in to_load:
        section = g_sections[section_name]
        print('Loading section %s into memory' % (section_name,))
        sz = section.header.sh_size
        print('Section size of %x' %(sz))
        addr = mmap(0, sz) & 0xFFFFFFFF
        print('moving code to %x' % (addr,))
        ctypes.memmove(addr, section.data(), len(section.data()))
        main_arr = (ctypes.c_char * sz).from_address(addr)
# subtract the location of the next instruction (5 + current instruction) from the target 
        for (offset, data) in relocation_info:
            print('performing relocation', offset, data)
            (ctypes.c_uint32 * 1).from_address((addr + offset))[0] = (data - (addr + offset + 4))

        for (offset, data_offset, sz) in data_relocations:
            print('Performing data relocation', offset, data_offset, sz)
            (ctypes.c_uint32 * 1).from_address((addr + offset))[0] = (data_addr + data_offset)
        
        print('Text section is %s' %(hexlify(section.data()),))
        dis = decode(0, section.data())
        dis = [(hex(tup[0]), tup[1], tup[2]) + tup[3:] for tup in dis]
        pprint(dis)
        
        print('Relocated buffer is  %s' % (hexlify(main_arr),))
        dis = decode(addr, main_arr.raw)
        dis = [(hex(tup[0]), tup[1], tup[2]) + tup[3:] for tup in dis]
        pprint(dis)
        main_proto = ctypes.CFUNCTYPE(ctypes.c_int)
        main = main_proto(addr)

        main()
        


              
        

elf = ELFFile(open('hello', 'rb'))
load_elf(elf)
relocate()
load()
pprint(decode(0x0, progbits['.text'].data()))
    
#load_elf(elf)
