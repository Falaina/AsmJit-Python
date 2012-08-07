import sys
import os, os.path as path

# Setup the path to the lib while developing
MODULE_DIR  = path.dirname(__file__)
AsmJit_path = path.join(MODULE_DIR, '..',  'lib')
__path__.append(AsmJit_path)
from asmjit import *

_ALL_ = asmjit._ALL_

