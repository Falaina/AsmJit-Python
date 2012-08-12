from elf import *
import logging
log = logging.getLogger('testelf')
CURRENT_TEST = None

def elf_test(fn):
    def new_fn(*args, **kwargs):
        log.info('Beginning *%s*', fn.__name__)
        res = fn(*args, **kwargs)
        log.info('Finished *%s*\n\n', fn.__name__)
        return res
    new_fn.__name__ = fn.__name__
    return new_fn


@elf_test
def testParse():
    e = ELFData('hello')

@elf_test
def testSymbols():
    e = ELFData('hello')
    symtab = e.symtabs['.symtab']
    for symbol in symtab:
        assert StringTable.get_string('.strtab', symbol.name) is not None, \
            'Unable to retrieve string for %s' %(symbol,)

    printf_symbol = symtab['printf']
    assert printf_symbol, 'unable to find reference to printf symbol'
    assert not printf_symbol.isDefined(), \
        'printf symbol should be undefined not %s' %(printf_symbol.isDefined(),)

@elf_test
def testRelocations():
    e = ELFData('hello')
    rel = e.relocations['.rel.text'].get_by_symbolname('printf')
    assert rel is not None, 'There is no relocation entry for printf'
    print(rel)
    assert rel.name == 'printf', 'Relocation symbol %s is not printf' %(rel.name,)
    
@elf_test
def testRun():
    e = ELFData('hello')
    print('Loading hello')
    e.load()
    print('Running hello')
    e.run()

@elf_test
def testmd5():
    e = ELFData('./md5sum')
    print('Loading hello')
    e.load()
    print('Running hello')
    e.run()
    
testParse()
testSymbols()
testRelocations()
testRun()
testmd5()

        
