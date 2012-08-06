%module AsmJit
%{
  #define ASMJIT_X86
  #define AsmJit_EXPORTS
  #include "AsmJit/Assembler.h"
  #include "AsmJit/Logger.h"
  #include "AsmJit/OperandX86X64.h"
  #include "stdio.h"
  using namespace AsmJit;
%}
%include "stdint.i"
%include "cpointer.i"

%pointer_class(uint8_t,  uint8_tp)
%pointer_class(uint16_t, uint16_tp)
%pointer_class(uint32_t, uint32_tp)
%pointer_class(sysint_t, sysint_tp)
#define ASMJIT_NOTHROW 
#define ASMJIT_API
#define ASMJIT_HIDDEN
typedef int32_t sysint_t;
#define ASMJIT_VAR extern ASMJIT_API

struct Mem;
Mem _MemPtrAbs(void* target, sysint_t disp, uint32_t segmentPrefix, uint32_t ptrSize) ASMJIT_NOTHROW;
static inline Mem ptr_abs(void* target, sysint_t disp = 0, uint32_t segmentPrefix = SEGMENT_NONE) ASMJIT_NOTHROW
{ return _MemPtrAbs(target, disp, segmentPrefix, 0); }

%inline %{
   Mem AbsPtr(intptr_t ptr) {
     return ptr_abs((void *)ptr);
  }
%}

struct Logger;
struct FileLogger : public Logger
{
  FileLogger(FILE* stream=stdout) ASMJIT_NOTHROW;
};

struct CodeGenerator;
struct ASMJIT_API AssemblerCore
{
  AssemblerCore(CodeGenerator* codeGenerator) ASMJIT_NOTHROW;
  virtual ~AssemblerCore() ASMJIT_NOTHROW;

  inline CodeGenerator* getCodeGenerator() const { return _codeGenerator; }
  inline Zone& getZone() ASMJIT_NOTHROW { return _zone; }
  inline Logger* getLogger() const ASMJIT_NOTHROW { return _logger; }
  virtual void setLogger(Logger* logger) ASMJIT_NOTHROW;
  inline uint32_t getError() const ASMJIT_NOTHROW { return _error; }
  virtual void setError(uint32_t error) ASMJIT_NOTHROW;
  uint32_t getProperty(uint32_t propertyId);
  void setProperty(uint32_t propertyId, uint32_t value);
  inline uint8_t* getCode() const ASMJIT_NOTHROW
  { return _buffer.getData(); }
  inline bool ensureSpace() ASMJIT_NOTHROW
  { return _buffer.ensureSpace(); }
  inline sysint_t getOffset() const ASMJIT_NOTHROW
  { return _buffer.getOffset(); }
  inline sysint_t getCodeSize() const ASMJIT_NOTHROW
  { return _buffer.getOffset() + getTrampolineSize(); }
  inline sysint_t getTrampolineSize() const ASMJIT_NOTHROW
  { return _trampolineSize; }
  inline sysint_t toOffset(sysint_t o) ASMJIT_NOTHROW
  { return _buffer.toOffset(o); }
  inline sysint_t getCapacity() const ASMJIT_NOTHROW
  { return _buffer.getCapacity(); }
  void clear() ASMJIT_NOTHROW;
  void free() ASMJIT_NOTHROW;
  uint8_t* takeCode() ASMJIT_NOTHROW;
  inline uint8_t getByteAt(sysint_t pos) const ASMJIT_NOTHROW
  { return _buffer.getByteAt(pos); }
  inline uint16_t getWordAt(sysint_t pos) const ASMJIT_NOTHROW
  { return _buffer.getWordAt(pos); }
  inline uint32_t getDWordAt(sysint_t pos) const ASMJIT_NOTHROW
  { return _buffer.getDWordAt(pos); }
  inline uint64_t getQWordAt(sysint_t pos) const ASMJIT_NOTHROW
  { return _buffer.getQWordAt(pos); }
  inline void setByteAt(sysint_t pos, uint8_t x) ASMJIT_NOTHROW
  { _buffer.setByteAt(pos, x); }
  inline void setWordAt(sysint_t pos, uint16_t x) ASMJIT_NOTHROW
  { _buffer.setWordAt(pos, x); }
  inline void setDWordAt(sysint_t pos, uint32_t x) ASMJIT_NOTHROW
  { _buffer.setDWordAt(pos, x); }
  inline void setQWordAt(sysint_t pos, uint64_t x) ASMJIT_NOTHROW
  { _buffer.setQWordAt(pos, x); }
  inline int32_t getInt32At(sysint_t pos) const ASMJIT_NOTHROW
  { return (int32_t)_buffer.getDWordAt(pos); }
  inline void setInt32At(sysint_t pos, int32_t x) ASMJIT_NOTHROW
  { _buffer.setDWordAt(pos, (int32_t)x); }
  void setVarAt(sysint_t pos, sysint_t i, uint8_t isUnsigned, uint32_t size) ASMJIT_NOTHROW;
  bool canEmit() ASMJIT_NOTHROW;
  inline void _emitByte(uint8_t x) ASMJIT_NOTHROW
  { _buffer.emitByte(x); }
  inline void _emitWord(uint16_t x) ASMJIT_NOTHROW
  { _buffer.emitWord(x); }
  inline void _emitDWord(uint32_t x) ASMJIT_NOTHROW
  { _buffer.emitDWord(x); }
  inline void _emitQWord(uint64_t x) ASMJIT_NOTHROW
  { _buffer.emitQWord(x); }
  inline void _emitInt32(int32_t x) ASMJIT_NOTHROW
  { _buffer.emitDWord((uint32_t)x); }
  inline void _emitSysInt(sysint_t x) ASMJIT_NOTHROW
  { _buffer.emitSysInt(x); }
  inline void _emitSysUInt(sysuint_t x) ASMJIT_NOTHROW
  { _buffer.emitSysUInt(x); }
  inline void _emitOpCode(uint32_t opCode) ASMJIT_NOTHROW
  {
    if (opCode & 0xFF000000) _emitByte((uint8_t)((opCode & 0xFF000000) >> 24));
    if (opCode & 0x00FF0000) _emitByte((uint8_t)((opCode & 0x00FF0000) >> 16));
    if (opCode & 0x0000FF00) _emitByte((uint8_t)((opCode & 0x0000FF00) >> 8));
    _emitByte((uint8_t)(opCode & 0x000000FF));
  }
  void _emitSegmentPrefix(const Operand& rm) ASMJIT_NOTHROW;
  inline void _emitMod(uint8_t m, uint8_t o, uint8_t r) ASMJIT_NOTHROW
  { _emitByte(((m & 0x03) << 6) | ((o & 0x07) << 3) | (r & 0x07)); }
  inline void _emitSib(uint8_t s, uint8_t i, uint8_t b) ASMJIT_NOTHROW
  { _emitByte(((s & 0x03) << 6) | ((i & 0x07) << 3) | (b & 0x07)); }
  inline void _emitRexR(uint8_t w, uint8_t opReg, uint8_t regCode, bool forceRexPrefix) ASMJIT_NOTHROW
  {
    ASMJIT_UNUSED(w);
    ASMJIT_UNUSED(opReg);
    ASMJIT_UNUSED(regCode);
    ASMJIT_UNUSED(forceRexPrefix);
  }
  inline void _emitRexRM(uint8_t w, uint8_t opReg, const Operand& rm, bool forceRexPrefix) ASMJIT_NOTHROW
  {
    ASMJIT_UNUSED(w);
    ASMJIT_UNUSED(opReg);
    ASMJIT_UNUSED(rm);
  }
  inline void _emitModR(uint8_t opReg, uint8_t r) ASMJIT_NOTHROW
  { _emitMod(3, opReg, r); }
  inline void _emitModR(uint8_t opReg, const BaseReg& r) ASMJIT_NOTHROW
  { _emitMod(3, opReg, r.getRegCode()); }
  void _emitModM(uint8_t opReg, const Mem& mem, sysint_t immSize) ASMJIT_NOTHROW;
  void _emitModRM(uint8_t opReg, const Operand& op, sysint_t immSize) ASMJIT_NOTHROW;
  void _emitX86Inl(uint32_t opCode, uint8_t i16bit, uint8_t rexw, uint8_t reg, bool forceRexPrefix) ASMJIT_NOTHROW;
  void _emitX86RM(uint32_t opCode, uint8_t i16bit, uint8_t rexw, uint8_t o,
    const Operand& op, sysint_t immSize, bool forceRexPrefix) ASMJIT_NOTHROW;
  void _emitFpu(uint32_t opCode) ASMJIT_NOTHROW;
  void _emitFpuSTI(uint32_t opCode, uint32_t sti) ASMJIT_NOTHROW;
  void _emitFpuMEM(uint32_t opCode, uint8_t opReg, const Mem& mem) ASMJIT_NOTHROW;
  void _emitMmu(uint32_t opCode, uint8_t rexw, uint8_t opReg, const Operand& src,
    sysint_t immSize) ASMJIT_NOTHROW;
  void _emitJmpOrCallReloc(uint32_t instruction, void* target) ASMJIT_NOTHROW;
  void _emitInstruction(uint32_t code) ASMJIT_NOTHROW;
  void _emitInstruction(uint32_t code, const Operand* o0) ASMJIT_NOTHROW;
  void _emitInstruction(uint32_t code, const Operand* o0, const Operand* o1) ASMJIT_NOTHROW;
  void _emitInstruction(uint32_t code, const Operand* o0, const Operand* o1, const Operand* o2) ASMJIT_NOTHROW;
  void _emitJcc(uint32_t code, const Label* label, uint32_t hint) ASMJIT_NOTHROW;
  inline void _emitShortJcc(uint32_t code, const Label* label, uint32_t hint)
  {
    _emitOptions |= EMIT_OPTION_SHORT_JUMP;
    _emitJcc(code, label, hint);
  }
  virtual sysuint_t relocCode(void* dst, sysuint_t addressBase) const ASMJIT_NOTHROW;
  inline sysuint_t relocCode(void* dst) const ASMJIT_NOTHROW
  {
    return relocCode(dst, (sysuint_t)dst);
  }
  void embed(const void* data, sysuint_t length) ASMJIT_NOTHROW;
  void embedLabel(const Label& label) ASMJIT_NOTHROW;
  void align(uint32_t m) ASMJIT_NOTHROW;
  Label newLabel() ASMJIT_NOTHROW;
  void registerLabels(sysuint_t count) ASMJIT_NOTHROW;
  void bind(const Label& label) ASMJIT_NOTHROW;
  virtual void* make() ASMJIT_NOTHROW;
};

struct ASMJIT_HIDDEN AssemblerIntrinsics : public AssemblerCore
{
  inline AssemblerIntrinsics(CodeGenerator* codeGenerator) ASMJIT_NOTHROW :
    AssemblerCore(codeGenerator)
  {
  }
  inline void db(uint8_t x) ASMJIT_NOTHROW { embed(&x, 1); }
  inline void dw(uint16_t x) ASMJIT_NOTHROW { embed(&x, 2); }
  inline void dd(uint32_t x) ASMJIT_NOTHROW { embed(&x, 4); }
  inline void dq(uint64_t x) ASMJIT_NOTHROW { embed(&x, 8); }
  inline void dint8(int8_t x) ASMJIT_NOTHROW { embed(&x, sizeof(int8_t)); }
  inline void duint8(uint8_t x) ASMJIT_NOTHROW { embed(&x, sizeof(uint8_t)); }
  inline void dint16(int16_t x) ASMJIT_NOTHROW { embed(&x, sizeof(int16_t)); }
  inline void duint16(uint16_t x) ASMJIT_NOTHROW { embed(&x, sizeof(uint16_t)); }
  inline void dint32(int32_t x) ASMJIT_NOTHROW { embed(&x, sizeof(int32_t)); }
  inline void duint32(uint32_t x) ASMJIT_NOTHROW { embed(&x, sizeof(uint32_t)); }
  inline void dint64(int64_t x) ASMJIT_NOTHROW { embed(&x, sizeof(int64_t)); }
  inline void duint64(uint64_t x) ASMJIT_NOTHROW { embed(&x, sizeof(uint64_t)); }
  inline void dsysint(sysint_t x) ASMJIT_NOTHROW { embed(&x, sizeof(sysint_t)); }
  inline void dsysuint(sysuint_t x) ASMJIT_NOTHROW { embed(&x, sizeof(sysuint_t)); }
  inline void dfloat(float x) ASMJIT_NOTHROW { embed(&x, sizeof(float)); }
  inline void ddouble(double x) ASMJIT_NOTHROW { embed(&x, sizeof(double)); }
  inline void dptr(void* x) ASMJIT_NOTHROW { embed(&x, sizeof(void*)); }
  inline void dmm(const MMData& x) ASMJIT_NOTHROW { embed(&x, sizeof(MMData)); }
  inline void dxmm(const XMMData& x) ASMJIT_NOTHROW { embed(&x, sizeof(XMMData)); }
  inline void data(const void* data, sysuint_t size) ASMJIT_NOTHROW { embed(data, size); }
  inline void adc(const GPReg& dst, const GPReg& src)
  {
    _emitInstruction(INST_ADC, &dst, &src);
  }
  inline void adc(const GPReg& dst, const Mem& src)
  {
    _emitInstruction(INST_ADC, &dst, &src);
  }
  inline void adc(const GPReg& dst, const Imm& src)
  {
    _emitInstruction(INST_ADC, &dst, &src);
  }
  inline void adc(const Mem& dst, const GPReg& src)
  {
    _emitInstruction(INST_ADC, &dst, &src);
  }
  inline void adc(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_ADC, &dst, &src);
  }
  inline void add(const GPReg& dst, const GPReg& src)
  {
    _emitInstruction(INST_ADD, &dst, &src);
  }
  inline void add(const GPReg& dst, const Mem& src)
  {
    _emitInstruction(INST_ADD, &dst, &src);
  }
  inline void add(const GPReg& dst, const Imm& src)
  {
    _emitInstruction(INST_ADD, &dst, &src);
  }
  inline void add(const Mem& dst, const GPReg& src)
  {
    _emitInstruction(INST_ADD, &dst, &src);
  }
  inline void add(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_ADD, &dst, &src);
  }
  inline void and_(const GPReg& dst, const GPReg& src)
  {
    _emitInstruction(INST_AND, &dst, &src);
  }
  inline void and_(const GPReg& dst, const Mem& src)
  {
    _emitInstruction(INST_AND, &dst, &src);
  }
  inline void and_(const GPReg& dst, const Imm& src)
  {
    _emitInstruction(INST_AND, &dst, &src);
  }
  inline void and_(const Mem& dst, const GPReg& src)
  {
    _emitInstruction(INST_AND, &dst, &src);
  }
  inline void and_(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_AND, &dst, &src);
  }
  inline void bsf(const GPReg& dst, const GPReg& src)
  {
    ASMJIT_ASSERT(!dst.isGPB());
    _emitInstruction(INST_BSF, &dst, &src);
  }
  inline void bsf(const GPReg& dst, const Mem& src)
  {
    ASMJIT_ASSERT(!dst.isGPB());
    _emitInstruction(INST_BSF, &dst, &src);
  }
  inline void bsr(const GPReg& dst, const GPReg& src)
  {
    ASMJIT_ASSERT(!dst.isGPB());
    _emitInstruction(INST_BSR, &dst, &src);
  }
  inline void bsr(const GPReg& dst, const Mem& src)
  {
    ASMJIT_ASSERT(!dst.isGPB());
    _emitInstruction(INST_BSR, &dst, &src);
  }
  inline void bswap(const GPReg& dst)
  {
    ASMJIT_ASSERT(dst.getRegType() == REG_TYPE_GPD || dst.getRegType() == REG_TYPE_GPQ);
    _emitInstruction(INST_BSWAP, &dst);
  }
  inline void bt(const GPReg& dst, const GPReg& src)
  {
    _emitInstruction(INST_BT, &dst, &src);
  }
  inline void bt(const GPReg& dst, const Imm& src)
  {
    _emitInstruction(INST_BT, &dst, &src);
  }
  inline void bt(const Mem& dst, const GPReg& src)
  {
    _emitInstruction(INST_BT, &dst, &src);
  }
  inline void bt(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_BT, &dst, &src);
  }
  inline void btc(const GPReg& dst, const GPReg& src)
  {
    _emitInstruction(INST_BTC, &dst, &src);
  }
  inline void btc(const GPReg& dst, const Imm& src)
  {
    _emitInstruction(INST_BTC, &dst, &src);
  }
  inline void btc(const Mem& dst, const GPReg& src)
  {
    _emitInstruction(INST_BTC, &dst, &src);
  }
  inline void btc(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_BTC, &dst, &src);
  }
  inline void btr(const GPReg& dst, const GPReg& src)
  {
    _emitInstruction(INST_BTR, &dst, &src);
  }
  inline void btr(const GPReg& dst, const Imm& src)
  {
    _emitInstruction(INST_BTR, &dst, &src);
  }
  inline void btr(const Mem& dst, const GPReg& src)
  {
    _emitInstruction(INST_BTR, &dst, &src);
  }
  inline void btr(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_BTR, &dst, &src);
  }
  inline void bts(const GPReg& dst, const GPReg& src)
  {
    _emitInstruction(INST_BTS, &dst, &src);
  }
  inline void bts(const GPReg& dst, const Imm& src)
  {
    _emitInstruction(INST_BTS, &dst, &src);
  }
  inline void bts(const Mem& dst, const GPReg& src)
  {
    _emitInstruction(INST_BTS, &dst, &src);
  }
  inline void bts(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_BTS, &dst, &src);
  }
  inline void call(const GPReg& dst)
  {
    ASMJIT_ASSERT(dst.isRegType(REG_TYPE_GPN));
    _emitInstruction(INST_CALL, &dst);
  }
  inline void call(const Mem& dst)
  {
    _emitInstruction(INST_CALL, &dst);
  }
  inline void call(const Imm& dst)
  {
    _emitInstruction(INST_CALL, &dst);
  }
  inline void call(void* dst)
  {
    Imm imm((sysint_t)dst);
    _emitInstruction(INST_CALL, &imm);
  }
  inline void call(const Label& label)
  {
    _emitInstruction(INST_CALL, &label);
  }
  inline void cbw()
  {
    _emitInstruction(INST_CBW);
  }
  inline void cwde()
  {
    _emitInstruction(INST_CWDE);
  }
  inline void clc()
  {
    _emitInstruction(INST_CLC);
  }
  inline void cld()
  {
    _emitInstruction(INST_CLD);
  }
  inline void cmc()
  {
    _emitInstruction(INST_CMC);
  }
  inline void cmov(CONDITION cc, const GPReg& dst, const GPReg& src)
  {
    _emitInstruction(ConditionToInstruction::toCMovCC(cc), &dst, &src);
  }
  inline void cmov(CONDITION cc, const GPReg& dst, const Mem& src)
  {
    _emitInstruction(ConditionToInstruction::toCMovCC(cc), &dst, &src);
  }
  inline void cmova (const GPReg& dst, const GPReg& src) { _emitInstruction(INST_CMOVA , &dst, &src); }
  inline void cmova (const GPReg& dst, const Mem& src) { _emitInstruction(INST_CMOVA , &dst, &src); }
  inline void cmovae (const GPReg& dst, const GPReg& src) { _emitInstruction(INST_CMOVAE , &dst, &src); }
  inline void cmovae (const GPReg& dst, const Mem& src) { _emitInstruction(INST_CMOVAE , &dst, &src); }
  inline void cmovb (const GPReg& dst, const GPReg& src) { _emitInstruction(INST_CMOVB , &dst, &src); }
  inline void cmovb (const GPReg& dst, const Mem& src) { _emitInstruction(INST_CMOVB , &dst, &src); }
  inline void cmovbe (const GPReg& dst, const GPReg& src) { _emitInstruction(INST_CMOVBE , &dst, &src); }
  inline void cmovbe (const GPReg& dst, const Mem& src) { _emitInstruction(INST_CMOVBE , &dst, &src); }
  inline void cmovc (const GPReg& dst, const GPReg& src) { _emitInstruction(INST_CMOVC , &dst, &src); }
  inline void cmovc (const GPReg& dst, const Mem& src) { _emitInstruction(INST_CMOVC , &dst, &src); }
  inline void cmove (const GPReg& dst, const GPReg& src) { _emitInstruction(INST_CMOVE , &dst, &src); }
  inline void cmove (const GPReg& dst, const Mem& src) { _emitInstruction(INST_CMOVE , &dst, &src); }
  inline void cmovg (const GPReg& dst, const GPReg& src) { _emitInstruction(INST_CMOVG , &dst, &src); }
  inline void cmovg (const GPReg& dst, const Mem& src) { _emitInstruction(INST_CMOVG , &dst, &src); }
  inline void cmovge (const GPReg& dst, const GPReg& src) { _emitInstruction(INST_CMOVGE , &dst, &src); }
  inline void cmovge (const GPReg& dst, const Mem& src) { _emitInstruction(INST_CMOVGE , &dst, &src); }
  inline void cmovl (const GPReg& dst, const GPReg& src) { _emitInstruction(INST_CMOVL , &dst, &src); }
  inline void cmovl (const GPReg& dst, const Mem& src) { _emitInstruction(INST_CMOVL , &dst, &src); }
  inline void cmovle (const GPReg& dst, const GPReg& src) { _emitInstruction(INST_CMOVLE , &dst, &src); }
  inline void cmovle (const GPReg& dst, const Mem& src) { _emitInstruction(INST_CMOVLE , &dst, &src); }
  inline void cmovna (const GPReg& dst, const GPReg& src) { _emitInstruction(INST_CMOVNA , &dst, &src); }
  inline void cmovna (const GPReg& dst, const Mem& src) { _emitInstruction(INST_CMOVNA , &dst, &src); }
  inline void cmovnae(const GPReg& dst, const GPReg& src) { _emitInstruction(INST_CMOVNAE, &dst, &src); }
  inline void cmovnae(const GPReg& dst, const Mem& src) { _emitInstruction(INST_CMOVNAE, &dst, &src); }
  inline void cmovnb (const GPReg& dst, const GPReg& src) { _emitInstruction(INST_CMOVNB , &dst, &src); }
  inline void cmovnb (const GPReg& dst, const Mem& src) { _emitInstruction(INST_CMOVNB , &dst, &src); }
  inline void cmovnbe(const GPReg& dst, const GPReg& src) { _emitInstruction(INST_CMOVNBE, &dst, &src); }
  inline void cmovnbe(const GPReg& dst, const Mem& src) { _emitInstruction(INST_CMOVNBE, &dst, &src); }
  inline void cmovnc (const GPReg& dst, const GPReg& src) { _emitInstruction(INST_CMOVNC , &dst, &src); }
  inline void cmovnc (const GPReg& dst, const Mem& src) { _emitInstruction(INST_CMOVNC , &dst, &src); }
  inline void cmovne (const GPReg& dst, const GPReg& src) { _emitInstruction(INST_CMOVNE , &dst, &src); }
  inline void cmovne (const GPReg& dst, const Mem& src) { _emitInstruction(INST_CMOVNE , &dst, &src); }
  inline void cmovng (const GPReg& dst, const GPReg& src) { _emitInstruction(INST_CMOVNG , &dst, &src); }
  inline void cmovng (const GPReg& dst, const Mem& src) { _emitInstruction(INST_CMOVNG , &dst, &src); }
  inline void cmovnge(const GPReg& dst, const GPReg& src) { _emitInstruction(INST_CMOVNGE, &dst, &src); }
  inline void cmovnge(const GPReg& dst, const Mem& src) { _emitInstruction(INST_CMOVNGE, &dst, &src); }
  inline void cmovnl (const GPReg& dst, const GPReg& src) { _emitInstruction(INST_CMOVNL , &dst, &src); }
  inline void cmovnl (const GPReg& dst, const Mem& src) { _emitInstruction(INST_CMOVNL , &dst, &src); }
  inline void cmovnle(const GPReg& dst, const GPReg& src) { _emitInstruction(INST_CMOVNLE, &dst, &src); }
  inline void cmovnle(const GPReg& dst, const Mem& src) { _emitInstruction(INST_CMOVNLE, &dst, &src); }
  inline void cmovno (const GPReg& dst, const GPReg& src) { _emitInstruction(INST_CMOVNO , &dst, &src); }
  inline void cmovno (const GPReg& dst, const Mem& src) { _emitInstruction(INST_CMOVNO , &dst, &src); }
  inline void cmovnp (const GPReg& dst, const GPReg& src) { _emitInstruction(INST_CMOVNP , &dst, &src); }
  inline void cmovnp (const GPReg& dst, const Mem& src) { _emitInstruction(INST_CMOVNP , &dst, &src); }
  inline void cmovns (const GPReg& dst, const GPReg& src) { _emitInstruction(INST_CMOVNS , &dst, &src); }
  inline void cmovns (const GPReg& dst, const Mem& src) { _emitInstruction(INST_CMOVNS , &dst, &src); }
  inline void cmovnz (const GPReg& dst, const GPReg& src) { _emitInstruction(INST_CMOVNZ , &dst, &src); }
  inline void cmovnz (const GPReg& dst, const Mem& src) { _emitInstruction(INST_CMOVNZ , &dst, &src); }
  inline void cmovo (const GPReg& dst, const GPReg& src) { _emitInstruction(INST_CMOVO , &dst, &src); }
  inline void cmovo (const GPReg& dst, const Mem& src) { _emitInstruction(INST_CMOVO , &dst, &src); }
  inline void cmovp (const GPReg& dst, const GPReg& src) { _emitInstruction(INST_CMOVP , &dst, &src); }
  inline void cmovp (const GPReg& dst, const Mem& src) { _emitInstruction(INST_CMOVP , &dst, &src); }
  inline void cmovpe (const GPReg& dst, const GPReg& src) { _emitInstruction(INST_CMOVPE , &dst, &src); }
  inline void cmovpe (const GPReg& dst, const Mem& src) { _emitInstruction(INST_CMOVPE , &dst, &src); }
  inline void cmovpo (const GPReg& dst, const GPReg& src) { _emitInstruction(INST_CMOVPO , &dst, &src); }
  inline void cmovpo (const GPReg& dst, const Mem& src) { _emitInstruction(INST_CMOVPO , &dst, &src); }
  inline void cmovs (const GPReg& dst, const GPReg& src) { _emitInstruction(INST_CMOVS , &dst, &src); }
  inline void cmovs (const GPReg& dst, const Mem& src) { _emitInstruction(INST_CMOVS , &dst, &src); }
  inline void cmovz (const GPReg& dst, const GPReg& src) { _emitInstruction(INST_CMOVZ , &dst, &src); }
  inline void cmovz (const GPReg& dst, const Mem& src) { _emitInstruction(INST_CMOVZ , &dst, &src); }
  inline void cmp(const GPReg& dst, const GPReg& src)
  {
    _emitInstruction(INST_CMP, &dst, &src);
  }
  inline void cmp(const GPReg& dst, const Mem& src)
  {
    _emitInstruction(INST_CMP, &dst, &src);
  }
  inline void cmp(const GPReg& dst, const Imm& src)
  {
    _emitInstruction(INST_CMP, &dst, &src);
  }
  inline void cmp(const Mem& dst, const GPReg& src)
  {
    _emitInstruction(INST_CMP, &dst, &src);
  }
  inline void cmp(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_CMP, &dst, &src);
  }
  inline void cmpxchg(const GPReg& dst, const GPReg& src)
  {
    _emitInstruction(INST_CMPXCHG, &dst, &src);
  }
  inline void cmpxchg(const Mem& dst, const GPReg& src)
  {
    _emitInstruction(INST_CMPXCHG, &dst, &src);
  }
  inline void cmpxchg8b(const Mem& dst)
  {
    _emitInstruction(INST_CMPXCHG8B, &dst);
  }
  inline void cpuid()
  {
    _emitInstruction(INST_CPUID);
  }
  inline void daa()
  {
    _emitInstruction(INST_DAA);
  }
  inline void das()
  {
    _emitInstruction(INST_DAS);
  }
  inline void dec(const GPReg& dst)
  {
    _emitInstruction(INST_DEC, &dst);
  }
  inline void dec(const Mem& dst)
  {
    _emitInstruction(INST_DEC, &dst);
  }
  inline void div(const GPReg& src)
  {
    _emitInstruction(INST_DIV, &src);
  }
  inline void div(const Mem& src)
  {
    _emitInstruction(INST_DIV, &src);
  }
  inline void enter(const Imm& imm16, const Imm& imm8)
  {
    _emitInstruction(INST_ENTER, &imm16, &imm8);
  }
  inline void idiv(const GPReg& src)
  {
    _emitInstruction(INST_IDIV, &src);
  }
  inline void idiv(const Mem& src)
  {
    _emitInstruction(INST_IDIV, &src);
  }
  inline void imul(const GPReg& src)
  {
    _emitInstruction(INST_IMUL, &src);
  }
  inline void imul(const Mem& src)
  {
    _emitInstruction(INST_IMUL, &src);
  }
  inline void imul(const GPReg& dst, const GPReg& src)
  {
    _emitInstruction(INST_IMUL, &dst, &src);
  }
  inline void imul(const GPReg& dst, const Mem& src)
  {
    _emitInstruction(INST_IMUL, &dst, &src);
  }
  inline void imul(const GPReg& dst, const Imm& src)
  {
    _emitInstruction(INST_IMUL, &dst, &src);
  }
  inline void imul(const GPReg& dst, const GPReg& src, const Imm& imm)
  {
    _emitInstruction(INST_IMUL, &dst, &src, &imm);
  }
  inline void imul(const GPReg& dst, const Mem& src, const Imm& imm)
  {
    _emitInstruction(INST_IMUL, &dst, &src, &imm);
  }
  inline void inc(const GPReg& dst)
  {
    _emitInstruction(INST_INC, &dst);
  }
  inline void inc(const Mem& dst)
  {
    _emitInstruction(INST_INC, &dst);
  }
  inline void int3()
  {
    _emitInstruction(INST_INT3);
  }
  inline void j(CONDITION cc, const Label& label, uint32_t hint = HINT_NONE)
  {
    _emitJcc(ConditionToInstruction::toJCC(cc), &label, hint);
  }
  inline void ja (const Label& label, uint32_t hint = HINT_NONE) { _emitJcc(INST_JA , &label, hint); }
  inline void jae (const Label& label, uint32_t hint = HINT_NONE) { _emitJcc(INST_JAE , &label, hint); }
  inline void jb (const Label& label, uint32_t hint = HINT_NONE) { _emitJcc(INST_JB , &label, hint); }
  inline void jbe (const Label& label, uint32_t hint = HINT_NONE) { _emitJcc(INST_JBE , &label, hint); }
  inline void jc (const Label& label, uint32_t hint = HINT_NONE) { _emitJcc(INST_JC , &label, hint); }
  inline void je (const Label& label, uint32_t hint = HINT_NONE) { _emitJcc(INST_JE , &label, hint); }
  inline void jg (const Label& label, uint32_t hint = HINT_NONE) { _emitJcc(INST_JG , &label, hint); }
  inline void jge (const Label& label, uint32_t hint = HINT_NONE) { _emitJcc(INST_JGE , &label, hint); }
  inline void jl (const Label& label, uint32_t hint = HINT_NONE) { _emitJcc(INST_JL , &label, hint); }
  inline void jle (const Label& label, uint32_t hint = HINT_NONE) { _emitJcc(INST_JLE , &label, hint); }
  inline void jna (const Label& label, uint32_t hint = HINT_NONE) { _emitJcc(INST_JNA , &label, hint); }
  inline void jnae(const Label& label, uint32_t hint = HINT_NONE) { _emitJcc(INST_JNAE, &label, hint); }
  inline void jnb (const Label& label, uint32_t hint = HINT_NONE) { _emitJcc(INST_JNB , &label, hint); }
  inline void jnbe(const Label& label, uint32_t hint = HINT_NONE) { _emitJcc(INST_JNBE, &label, hint); }
  inline void jnc (const Label& label, uint32_t hint = HINT_NONE) { _emitJcc(INST_JNC , &label, hint); }
  inline void jne (const Label& label, uint32_t hint = HINT_NONE) { _emitJcc(INST_JNE , &label, hint); }
  inline void jng (const Label& label, uint32_t hint = HINT_NONE) { _emitJcc(INST_JNG , &label, hint); }
  inline void jnge(const Label& label, uint32_t hint = HINT_NONE) { _emitJcc(INST_JNGE, &label, hint); }
  inline void jnl (const Label& label, uint32_t hint = HINT_NONE) { _emitJcc(INST_JNL , &label, hint); }
  inline void jnle(const Label& label, uint32_t hint = HINT_NONE) { _emitJcc(INST_JNLE, &label, hint); }
  inline void jno (const Label& label, uint32_t hint = HINT_NONE) { _emitJcc(INST_JNO , &label, hint); }
  inline void jnp (const Label& label, uint32_t hint = HINT_NONE) { _emitJcc(INST_JNP , &label, hint); }
  inline void jns (const Label& label, uint32_t hint = HINT_NONE) { _emitJcc(INST_JNS , &label, hint); }
  inline void jnz (const Label& label, uint32_t hint = HINT_NONE) { _emitJcc(INST_JNZ , &label, hint); }
  inline void jo (const Label& label, uint32_t hint = HINT_NONE) { _emitJcc(INST_JO , &label, hint); }
  inline void jp (const Label& label, uint32_t hint = HINT_NONE) { _emitJcc(INST_JP , &label, hint); }
  inline void jpe (const Label& label, uint32_t hint = HINT_NONE) { _emitJcc(INST_JPE , &label, hint); }
  inline void jpo (const Label& label, uint32_t hint = HINT_NONE) { _emitJcc(INST_JPO , &label, hint); }
  inline void js (const Label& label, uint32_t hint = HINT_NONE) { _emitJcc(INST_JS , &label, hint); }
  inline void jz (const Label& label, uint32_t hint = HINT_NONE) { _emitJcc(INST_JZ , &label, hint); }
  inline void short_j(CONDITION cc, const Label& label, uint32_t hint = HINT_NONE)
  {
    _emitOptions |= EMIT_OPTION_SHORT_JUMP;
    j(cc, label, hint);
  }
  inline void short_ja (const Label& label, uint32_t hint = HINT_NONE) { _emitShortJcc(INST_JA , &label, hint); }
  inline void short_jae (const Label& label, uint32_t hint = HINT_NONE) { _emitShortJcc(INST_JAE , &label, hint); }
  inline void short_jb (const Label& label, uint32_t hint = HINT_NONE) { _emitShortJcc(INST_JB , &label, hint); }
  inline void short_jbe (const Label& label, uint32_t hint = HINT_NONE) { _emitShortJcc(INST_JBE , &label, hint); }
  inline void short_jc (const Label& label, uint32_t hint = HINT_NONE) { _emitShortJcc(INST_JC , &label, hint); }
  inline void short_je (const Label& label, uint32_t hint = HINT_NONE) { _emitShortJcc(INST_JE , &label, hint); }
  inline void short_jg (const Label& label, uint32_t hint = HINT_NONE) { _emitShortJcc(INST_JG , &label, hint); }
  inline void short_jge (const Label& label, uint32_t hint = HINT_NONE) { _emitShortJcc(INST_JGE , &label, hint); }
  inline void short_jl (const Label& label, uint32_t hint = HINT_NONE) { _emitShortJcc(INST_JL , &label, hint); }
  inline void short_jle (const Label& label, uint32_t hint = HINT_NONE) { _emitShortJcc(INST_JLE , &label, hint); }
  inline void short_jna (const Label& label, uint32_t hint = HINT_NONE) { _emitShortJcc(INST_JNA , &label, hint); }
  inline void short_jnae(const Label& label, uint32_t hint = HINT_NONE) { _emitShortJcc(INST_JNAE, &label, hint); }
  inline void short_jnb (const Label& label, uint32_t hint = HINT_NONE) { _emitShortJcc(INST_JNB , &label, hint); }
  inline void short_jnbe(const Label& label, uint32_t hint = HINT_NONE) { _emitShortJcc(INST_JNBE, &label, hint); }
  inline void short_jnc (const Label& label, uint32_t hint = HINT_NONE) { _emitShortJcc(INST_JNC , &label, hint); }
  inline void short_jne (const Label& label, uint32_t hint = HINT_NONE) { _emitShortJcc(INST_JNE , &label, hint); }
  inline void short_jng (const Label& label, uint32_t hint = HINT_NONE) { _emitShortJcc(INST_JNG , &label, hint); }
  inline void short_jnge(const Label& label, uint32_t hint = HINT_NONE) { _emitShortJcc(INST_JNGE, &label, hint); }
  inline void short_jnl (const Label& label, uint32_t hint = HINT_NONE) { _emitShortJcc(INST_JNL , &label, hint); }
  inline void short_jnle(const Label& label, uint32_t hint = HINT_NONE) { _emitShortJcc(INST_JNLE, &label, hint); }
  inline void short_jno (const Label& label, uint32_t hint = HINT_NONE) { _emitShortJcc(INST_JNO , &label, hint); }
  inline void short_jnp (const Label& label, uint32_t hint = HINT_NONE) { _emitShortJcc(INST_JNP , &label, hint); }
  inline void short_jns (const Label& label, uint32_t hint = HINT_NONE) { _emitShortJcc(INST_JNS , &label, hint); }
  inline void short_jnz (const Label& label, uint32_t hint = HINT_NONE) { _emitShortJcc(INST_JNZ , &label, hint); }
  inline void short_jo (const Label& label, uint32_t hint = HINT_NONE) { _emitShortJcc(INST_JO , &label, hint); }
  inline void short_jp (const Label& label, uint32_t hint = HINT_NONE) { _emitShortJcc(INST_JP , &label, hint); }
  inline void short_jpe (const Label& label, uint32_t hint = HINT_NONE) { _emitShortJcc(INST_JPE , &label, hint); }
  inline void short_jpo (const Label& label, uint32_t hint = HINT_NONE) { _emitShortJcc(INST_JPO , &label, hint); }
  inline void short_js (const Label& label, uint32_t hint = HINT_NONE) { _emitShortJcc(INST_JS , &label, hint); }
  inline void short_jz (const Label& label, uint32_t hint = HINT_NONE) { _emitShortJcc(INST_JZ , &label, hint); }
  inline void jmp(const GPReg& dst)
  {
    _emitInstruction(INST_JMP, &dst);
  }
  inline void jmp(const Mem& dst)
  {
    _emitInstruction(INST_JMP, &dst);
  }
  inline void jmp(const Imm& dst)
  {
    _emitInstruction(INST_JMP, &dst);
  }
  inline void jmp(void* dst)
  {
    Imm imm((sysint_t)dst);
    _emitInstruction(INST_JMP, &imm);
  }
  inline void jmp(const Label& label)
  {
    _emitInstruction(INST_JMP, &label);
  }
  inline void short_jmp(const Label& label)
  {
    _emitOptions |= EMIT_OPTION_SHORT_JUMP;
    _emitInstruction(INST_JMP, &label);
  }
  inline void lea(const GPReg& dst, const Mem& src)
  {
    _emitInstruction(INST_LEA, &dst, &src);
  }
  inline void leave()
  {
    _emitInstruction(INST_LEAVE);
  }
  inline void mov(const GPReg& dst, const GPReg& src)
  {
    _emitInstruction(INST_MOV, &dst, &src);
  }
  inline void mov(const GPReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MOV, &dst, &src);
  }
  inline void mov(const GPReg& dst, const Imm& src)
  {
    _emitInstruction(INST_MOV, &dst, &src);
  }
  inline void mov(const Mem& dst, const GPReg& src)
  {
    _emitInstruction(INST_MOV, &dst, &src);
  }
  inline void mov(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_MOV, &dst, &src);
  }
  inline void mov(const GPReg& dst, const SegmentReg& src)
  {
    _emitInstruction(INST_MOV, &dst, &src);
  }
  inline void mov(const Mem& dst, const SegmentReg& src)
  {
    _emitInstruction(INST_MOV, &dst, &src);
  }
  inline void mov(const SegmentReg& dst, const GPReg& src)
  {
    _emitInstruction(INST_MOV, &dst, &src);
  }
  inline void mov(const SegmentReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MOV, &dst, &src);
  }
  inline void mov_ptr(const GPReg& dst, void* src)
  {
    ASMJIT_ASSERT(dst.getRegIndex() == 0);
    Imm imm((sysint_t)src);
    _emitInstruction(INST_MOV_PTR, &dst, &imm);
  }
  inline void mov_ptr(void* dst, const GPReg& src)
  {
    ASMJIT_ASSERT(src.getRegIndex() == 0);
    Imm imm((sysint_t)dst);
    _emitInstruction(INST_MOV_PTR, &imm, &src);
  }
  void movsx(const GPReg& dst, const GPReg& src)
  {
    _emitInstruction(INST_MOVSX, &dst, &src);
  }
  void movsx(const GPReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVSX, &dst, &src);
  }
  inline void movzx(const GPReg& dst, const GPReg& src)
  {
    _emitInstruction(INST_MOVZX, &dst, &src);
  }
  inline void movzx(const GPReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVZX, &dst, &src);
  }
  inline void mul(const GPReg& src)
  {
    _emitInstruction(INST_MUL, &src);
  }
  inline void mul(const Mem& src)
  {
    _emitInstruction(INST_MUL, &src);
  }
  inline void neg(const GPReg& dst)
  {
    _emitInstruction(INST_NEG, &dst);
  }
  inline void neg(const Mem& dst)
  {
    _emitInstruction(INST_NEG, &dst);
  }
  inline void nop()
  {
    _emitInstruction(INST_NOP);
  }
  inline void not_(const GPReg& dst)
  {
    _emitInstruction(INST_NOT, &dst);
  }
  inline void not_(const Mem& dst)
  {
    _emitInstruction(INST_NOT, &dst);
  }
  inline void or_(const GPReg& dst, const GPReg& src)
  {
    _emitInstruction(INST_OR, &dst, &src);
  }
  inline void or_(const GPReg& dst, const Mem& src)
  {
    _emitInstruction(INST_OR, &dst, &src);
  }
  inline void or_(const GPReg& dst, const Imm& src)
  {
    _emitInstruction(INST_OR, &dst, &src);
  }
  inline void or_(const Mem& dst, const GPReg& src)
  {
    _emitInstruction(INST_OR, &dst, &src);
  }
  inline void or_(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_OR, &dst, &src);
  }
  inline void pop(const GPReg& dst)
  {
    ASMJIT_ASSERT(dst.isRegType(REG_TYPE_GPW) || dst.isRegType(REG_TYPE_GPN));
    _emitInstruction(INST_POP, &dst);
  }
  inline void pop(const Mem& dst)
  {
    ASMJIT_ASSERT(dst.getSize() == 2 || dst.getSize() == sizeof(sysint_t));
    _emitInstruction(INST_POP, &dst);
  }
  inline void popad()
  {
    _emitInstruction(INST_POPAD);
  }
  inline void popf()
  {
    popfd();
  }
  inline void popfd() { _emitInstruction(INST_POPFD); }
  inline void push(const GPReg& src)
  {
    ASMJIT_ASSERT(src.isRegType(REG_TYPE_GPW) || src.isRegType(REG_TYPE_GPN));
    _emitInstruction(INST_PUSH, &src);
  }
  inline void push(const Mem& src)
  {
    ASMJIT_ASSERT(src.getSize() == 2 || src.getSize() == sizeof(sysint_t));
    _emitInstruction(INST_PUSH, &src);
  }
  inline void push(const Imm& src)
  {
    _emitInstruction(INST_PUSH, &src);
  }
  inline void pushad()
  {
    _emitInstruction(INST_PUSHAD);
  }
  inline void pushf()
  {
    pushfd();
  }
  inline void pushfd() { _emitInstruction(INST_PUSHFD); }
  inline void rcl(const GPReg& dst, const GPReg& src)
  {
    _emitInstruction(INST_RCL, &dst, &src);
  }
  inline void rcl(const GPReg& dst, const Imm& src)
  {
    _emitInstruction(INST_RCL, &dst, &src);
  }
  inline void rcl(const Mem& dst, const GPReg& src)
  {
    _emitInstruction(INST_RCL, &dst, &src);
  }
  inline void rcl(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_RCL, &dst, &src);
  }
  inline void rcr(const GPReg& dst, const GPReg& src)
  {
    _emitInstruction(INST_RCR, &dst, &src);
  }
  inline void rcr(const GPReg& dst, const Imm& src)
  {
    _emitInstruction(INST_RCR, &dst, &src);
  }
  inline void rcr(const Mem& dst, const GPReg& src)
  {
    _emitInstruction(INST_RCR, &dst, &src);
  }
  inline void rcr(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_RCR, &dst, &src);
  }
  inline void rdtsc()
  {
    _emitInstruction(INST_RDTSC);
  }
  inline void rdtscp()
  {
    _emitInstruction(INST_RDTSCP);
  }
  inline void rep_lodsb()
  {
    _emitInstruction(INST_REP_LODSB);
  }
  inline void rep_lodsd()
  {
    _emitInstruction(INST_REP_LODSD);
  }
  inline void rep_lodsw()
  {
    _emitInstruction(INST_REP_LODSW);
  }
  inline void rep_movsb()
  {
    _emitInstruction(INST_REP_MOVSB);
  }
  inline void rep_movsd()
  {
    _emitInstruction(INST_REP_MOVSD);
  }
  inline void rep_movsw()
  {
    _emitInstruction(INST_REP_MOVSW);
  }
  inline void rep_stosb()
  {
    _emitInstruction(INST_REP_STOSB);
  }
  inline void rep_stosd()
  {
    _emitInstruction(INST_REP_STOSD);
  }
  inline void rep_stosw()
  {
    _emitInstruction(INST_REP_STOSW);
  }
  inline void repe_cmpsb()
  {
    _emitInstruction(INST_REPE_CMPSB);
  }
  inline void repe_cmpsd()
  {
    _emitInstruction(INST_REPE_CMPSD);
  }
  inline void repe_cmpsw()
  {
    _emitInstruction(INST_REPE_CMPSW);
  }
  inline void repe_scasb()
  {
    _emitInstruction(INST_REPE_SCASB);
  }
  inline void repe_scasd()
  {
    _emitInstruction(INST_REPE_SCASD);
  }
  inline void repe_scasw()
  {
    _emitInstruction(INST_REPE_SCASW);
  }
  inline void repne_cmpsb()
  {
    _emitInstruction(INST_REPNE_CMPSB);
  }
  inline void repne_cmpsd()
  {
    _emitInstruction(INST_REPNE_CMPSD);
  }
  inline void repne_cmpsw()
  {
    _emitInstruction(INST_REPNE_CMPSW);
  }
  inline void repne_scasb()
  {
    _emitInstruction(INST_REPNE_SCASB);
  }
  inline void repne_scasd()
  {
    _emitInstruction(INST_REPNE_SCASD);
  }
  inline void repne_scasw()
  {
    _emitInstruction(INST_REPNE_SCASW);
  }
  inline void ret()
  {
    _emitInstruction(INST_RET);
  }
  inline void ret(const Imm& imm16)
  {
    _emitInstruction(INST_RET, &imm16);
  }
  inline void rol(const GPReg& dst, const GPReg& src)
  {
    _emitInstruction(INST_ROL, &dst, &src);
  }
  inline void rol(const GPReg& dst, const Imm& src)
  {
    _emitInstruction(INST_ROL, &dst, &src);
  }
  inline void rol(const Mem& dst, const GPReg& src)
  {
    _emitInstruction(INST_ROL, &dst, &src);
  }
  inline void rol(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_ROL, &dst, &src);
  }
  inline void ror(const GPReg& dst, const GPReg& src)
  {
    _emitInstruction(INST_ROR, &dst, &src);
  }
  inline void ror(const GPReg& dst, const Imm& src)
  {
    _emitInstruction(INST_ROR, &dst, &src);
  }
  inline void ror(const Mem& dst, const GPReg& src)
  {
    _emitInstruction(INST_ROR, &dst, &src);
  }
  inline void ror(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_ROR, &dst, &src);
  }
  inline void sahf()
  {
    _emitInstruction(INST_SAHF);
  }
  inline void sbb(const GPReg& dst, const GPReg& src)
  {
    _emitInstruction(INST_SBB, &dst, &src);
  }
  inline void sbb(const GPReg& dst, const Mem& src)
  {
    _emitInstruction(INST_SBB, &dst, &src);
  }
  inline void sbb(const GPReg& dst, const Imm& src)
  {
    _emitInstruction(INST_SBB, &dst, &src);
  }
  inline void sbb(const Mem& dst, const GPReg& src)
  {
    _emitInstruction(INST_SBB, &dst, &src);
  }
  inline void sbb(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_SBB, &dst, &src);
  }
  inline void sal(const GPReg& dst, const GPReg& src)
  {
    _emitInstruction(INST_SAL, &dst, &src);
  }
  inline void sal(const GPReg& dst, const Imm& src)
  {
    _emitInstruction(INST_SAL, &dst, &src);
  }
  inline void sal(const Mem& dst, const GPReg& src)
  {
    _emitInstruction(INST_SAL, &dst, &src);
  }
  inline void sal(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_SAL, &dst, &src);
  }
  inline void sar(const GPReg& dst, const GPReg& src)
  {
    _emitInstruction(INST_SAR, &dst, &src);
  }
  inline void sar(const GPReg& dst, const Imm& src)
  {
    _emitInstruction(INST_SAR, &dst, &src);
  }
  inline void sar(const Mem& dst, const GPReg& src)
  {
    _emitInstruction(INST_SAR, &dst, &src);
  }
  inline void sar(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_SAR, &dst, &src);
  }
  inline void set(CONDITION cc, const GPReg& dst)
  {
    ASMJIT_ASSERT(dst.getSize() == 1);
    _emitInstruction(ConditionToInstruction::toSetCC(cc), &dst);
  }
  inline void set(CONDITION cc, const Mem& dst)
  {
    ASMJIT_ASSERT(dst.getSize() <= 1);
    _emitInstruction(ConditionToInstruction::toSetCC(cc), &dst);
  }
  inline void seta (const GPReg& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETA , &dst); }
  inline void seta (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETA , &dst); }
  inline void setae (const GPReg& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETAE , &dst); }
  inline void setae (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETAE , &dst); }
  inline void setb (const GPReg& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETB , &dst); }
  inline void setb (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETB , &dst); }
  inline void setbe (const GPReg& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETBE , &dst); }
  inline void setbe (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETBE , &dst); }
  inline void setc (const GPReg& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETC , &dst); }
  inline void setc (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETC , &dst); }
  inline void sete (const GPReg& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETE , &dst); }
  inline void sete (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETE , &dst); }
  inline void setg (const GPReg& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETG , &dst); }
  inline void setg (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETG , &dst); }
  inline void setge (const GPReg& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETGE , &dst); }
  inline void setge (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETGE , &dst); }
  inline void setl (const GPReg& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETL , &dst); }
  inline void setl (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETL , &dst); }
  inline void setle (const GPReg& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETLE , &dst); }
  inline void setle (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETLE , &dst); }
  inline void setna (const GPReg& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETNA , &dst); }
  inline void setna (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETNA , &dst); }
  inline void setnae(const GPReg& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETNAE, &dst); }
  inline void setnae(const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETNAE, &dst); }
  inline void setnb (const GPReg& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETNB , &dst); }
  inline void setnb (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETNB , &dst); }
  inline void setnbe(const GPReg& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETNBE, &dst); }
  inline void setnbe(const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETNBE, &dst); }
  inline void setnc (const GPReg& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETNC , &dst); }
  inline void setnc (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETNC , &dst); }
  inline void setne (const GPReg& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETNE , &dst); }
  inline void setne (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETNE , &dst); }
  inline void setng (const GPReg& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETNG , &dst); }
  inline void setng (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETNG , &dst); }
  inline void setnge(const GPReg& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETNGE, &dst); }
  inline void setnge(const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETNGE, &dst); }
  inline void setnl (const GPReg& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETNL , &dst); }
  inline void setnl (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETNL , &dst); }
  inline void setnle(const GPReg& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETNLE, &dst); }
  inline void setnle(const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETNLE, &dst); }
  inline void setno (const GPReg& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETNO , &dst); }
  inline void setno (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETNO , &dst); }
  inline void setnp (const GPReg& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETNP , &dst); }
  inline void setnp (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETNP , &dst); }
  inline void setns (const GPReg& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETNS , &dst); }
  inline void setns (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETNS , &dst); }
  inline void setnz (const GPReg& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETNZ , &dst); }
  inline void setnz (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETNZ , &dst); }
  inline void seto (const GPReg& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETO , &dst); }
  inline void seto (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETO , &dst); }
  inline void setp (const GPReg& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETP , &dst); }
  inline void setp (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETP , &dst); }
  inline void setpe (const GPReg& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETPE , &dst); }
  inline void setpe (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETPE , &dst); }
  inline void setpo (const GPReg& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETPO , &dst); }
  inline void setpo (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETPO , &dst); }
  inline void sets (const GPReg& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETS , &dst); }
  inline void sets (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETS , &dst); }
  inline void setz (const GPReg& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETZ , &dst); }
  inline void setz (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETZ , &dst); }
  inline void shl(const GPReg& dst, const GPReg& src)
  {
    _emitInstruction(INST_SHL, &dst, &src);
  }
  inline void shl(const GPReg& dst, const Imm& src)
  {
    _emitInstruction(INST_SHL, &dst, &src);
  }
  inline void shl(const Mem& dst, const GPReg& src)
  {
    _emitInstruction(INST_SHL, &dst, &src);
  }
  inline void shl(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_SHL, &dst, &src);
  }
  inline void shr(const GPReg& dst, const GPReg& src)
  {
    _emitInstruction(INST_SHR, &dst, &src);
  }
  inline void shr(const GPReg& dst, const Imm& src)
  {
    _emitInstruction(INST_SHR, &dst, &src);
  }
  inline void shr(const Mem& dst, const GPReg& src)
  {
    _emitInstruction(INST_SHR, &dst, &src);
  }
  inline void shr(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_SHR, &dst, &src);
  }
  inline void shld(const GPReg& dst, const GPReg& src1, const GPReg& src2)
  {
    _emitInstruction(INST_SHLD, &dst, &src1, &src2);
  }
  inline void shld(const GPReg& dst, const GPReg& src1, const Imm& src2)
  {
    _emitInstruction(INST_SHLD, &dst, &src1, &src2);
  }
  inline void shld(const Mem& dst, const GPReg& src1, const GPReg& src2)
  {
    _emitInstruction(INST_SHLD, &dst, &src1, &src2);
  }
  inline void shld(const Mem& dst, const GPReg& src1, const Imm& src2)
  {
    _emitInstruction(INST_SHLD, &dst, &src1, &src2);
  }
  inline void shrd(const GPReg& dst, const GPReg& src1, const GPReg& src2)
  {
    _emitInstruction(INST_SHRD, &dst, &src1, &src2);
  }
  inline void shrd(const GPReg& dst, const GPReg& src1, const Imm& src2)
  {
    _emitInstruction(INST_SHRD, &dst, &src1, &src2);
  }
  inline void shrd(const Mem& dst, const GPReg& src1, const GPReg& src2)
  {
    _emitInstruction(INST_SHRD, &dst, &src1, &src2);
  }
  inline void shrd(const Mem& dst, const GPReg& src1, const Imm& src2)
  {
    _emitInstruction(INST_SHRD, &dst, &src1, &src2);
  }
  inline void stc()
  {
    _emitInstruction(INST_STC);
  }
  inline void std()
  {
    _emitInstruction(INST_STD);
  }
  inline void sub(const GPReg& dst, const GPReg& src)
  {
    _emitInstruction(INST_SUB, &dst, &src);
  }
  inline void sub(const GPReg& dst, const Mem& src)
  {
    _emitInstruction(INST_SUB, &dst, &src);
  }
  inline void sub(const GPReg& dst, const Imm& src)
  {
    _emitInstruction(INST_SUB, &dst, &src);
  }
  inline void sub(const Mem& dst, const GPReg& src)
  {
    _emitInstruction(INST_SUB, &dst, &src);
  }
  inline void sub(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_SUB, &dst, &src);
  }
  inline void test(const GPReg& op1, const GPReg& op2)
  {
    _emitInstruction(INST_TEST, &op1, &op2);
  }
  inline void test(const GPReg& op1, const Imm& op2)
  {
    _emitInstruction(INST_TEST, &op1, &op2);
  }
  inline void test(const Mem& op1, const GPReg& op2)
  {
    _emitInstruction(INST_TEST, &op1, &op2);
  }
  inline void test(const Mem& op1, const Imm& op2)
  {
    _emitInstruction(INST_TEST, &op1, &op2);
  }
  inline void ud2()
  {
    _emitInstruction(INST_UD2);
  }
  inline void xadd(const GPReg& dst, const GPReg& src)
  {
    _emitInstruction(INST_XADD, &dst, &src);
  }
  inline void xadd(const Mem& dst, const GPReg& src)
  {
    _emitInstruction(INST_XADD, &dst, &src);
  }
  inline void xchg(const GPReg& dst, const GPReg& src)
  {
    _emitInstruction(INST_XCHG, &dst, &src);
  }
  inline void xchg(const Mem& dst, const GPReg& src)
  {
    _emitInstruction(INST_XCHG, &dst, &src);
  }
  inline void xchg(const GPReg& dst, const Mem& src)
  {
    _emitInstruction(INST_XCHG, &src, &dst);
  }
  inline void xor_(const GPReg& dst, const GPReg& src)
  {
    _emitInstruction(INST_XOR, &dst, &src);
  }
  inline void xor_(const GPReg& dst, const Mem& src)
  {
    _emitInstruction(INST_XOR, &dst, &src);
  }
  inline void xor_(const GPReg& dst, const Imm& src)
  {
    _emitInstruction(INST_XOR, &dst, &src);
  }
  inline void xor_(const Mem& dst, const GPReg& src)
  {
    _emitInstruction(INST_XOR, &dst, &src);
  }
  inline void xor_(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_XOR, &dst, &src);
  }
  inline void f2xm1()
  {
    _emitInstruction(INST_F2XM1);
  }
  inline void fabs()
  {
    _emitInstruction(INST_FABS);
  }
  inline void fadd(const X87Reg& dst, const X87Reg& src)
  {
    ASMJIT_ASSERT(dst.getRegIndex() == 0 || src.getRegIndex() == 0);
    _emitInstruction(INST_FADD, &dst, &src);
  }
  inline void fadd(const Mem& src)
  {
    _emitInstruction(INST_FADD, &src);
  }
  inline void faddp(const X87Reg& dst = st(1))
  {
    _emitInstruction(INST_FADDP, &dst);
  }
  inline void fbld(const Mem& src)
  {
    _emitInstruction(INST_FBLD, &src);
  }
  inline void fbstp(const Mem& dst)
  {
    _emitInstruction(INST_FBSTP, &dst);
  }
  inline void fchs()
  {
    _emitInstruction(INST_FCHS);
  }
  inline void fclex()
  {
    _emitInstruction(INST_FCLEX);
  }
  inline void fcmovb(const X87Reg& src)
  {
    _emitInstruction(INST_FCMOVB, &src);
  }
  inline void fcmovbe(const X87Reg& src)
  {
    _emitInstruction(INST_FCMOVBE, &src);
  }
  inline void fcmove(const X87Reg& src)
  {
    _emitInstruction(INST_FCMOVE, &src);
  }
  inline void fcmovnb(const X87Reg& src)
  {
    _emitInstruction(INST_FCMOVNB, &src);
  }
  inline void fcmovnbe(const X87Reg& src)
  {
    _emitInstruction(INST_FCMOVNBE, &src);
  }
  inline void fcmovne(const X87Reg& src)
  {
    _emitInstruction(INST_FCMOVNE, &src);
  }
  inline void fcmovnu(const X87Reg& src)
  {
    _emitInstruction(INST_FCMOVNU, &src);
  }
  inline void fcmovu(const X87Reg& src)
  {
    _emitInstruction(INST_FCMOVU, &src);
  }
  inline void fcom(const X87Reg& reg = st(1))
  {
    _emitInstruction(INST_FCOM, &reg);
  }
  inline void fcom(const Mem& src)
  {
    _emitInstruction(INST_FCOM, &src);
  }
  inline void fcomp(const X87Reg& reg = st(1))
  {
    _emitInstruction(INST_FCOMP, &reg);
  }
  inline void fcomp(const Mem& mem)
  {
    _emitInstruction(INST_FCOMP, &mem);
  }
  inline void fcompp()
  {
    _emitInstruction(INST_FCOMPP);
  }
  inline void fcomi(const X87Reg& reg)
  {
    _emitInstruction(INST_FCOMI, &reg);
  }
  inline void fcomip(const X87Reg& reg)
  {
    _emitInstruction(INST_FCOMIP, &reg);
  }
  inline void fcos()
  {
    _emitInstruction(INST_FCOS);
  }
  inline void fdecstp()
  {
    _emitInstruction(INST_FDECSTP);
  }
  inline void fdiv(const X87Reg& dst, const X87Reg& src)
  {
    ASMJIT_ASSERT(dst.getRegIndex() == 0 || src.getRegIndex() == 0);
    _emitInstruction(INST_FDIV, &dst, &src);
  }
  inline void fdiv(const Mem& src)
  {
    _emitInstruction(INST_FDIV, &src);
  }
  inline void fdivp(const X87Reg& reg = st(1))
  {
    _emitInstruction(INST_FDIVP, &reg);
  }
  inline void fdivr(const X87Reg& dst, const X87Reg& src)
  {
    ASMJIT_ASSERT(dst.getRegIndex() == 0 || src.getRegIndex() == 0);
    _emitInstruction(INST_FDIVR, &dst, &src);
  }
  inline void fdivr(const Mem& src)
  {
    _emitInstruction(INST_FDIVR, &src);
  }
  inline void fdivrp(const X87Reg& reg = st(1))
  {
    _emitInstruction(INST_FDIVRP, &reg);
  }
  inline void ffree(const X87Reg& reg)
  {
    _emitInstruction(INST_FFREE, &reg);
  }
  inline void fiadd(const Mem& src)
  {
    ASMJIT_ASSERT(src.getSize() == 2 || src.getSize() == 4);
    _emitInstruction(INST_FIADD, &src);
  }
  inline void ficom(const Mem& src)
  {
    ASMJIT_ASSERT(src.getSize() == 2 || src.getSize() == 4);
    _emitInstruction(INST_FICOM, &src);
  }
  inline void ficomp(const Mem& src)
  {
    ASMJIT_ASSERT(src.getSize() == 2 || src.getSize() == 4);
    _emitInstruction(INST_FICOMP, &src);
  }
  inline void fidiv(const Mem& src)
  {
    ASMJIT_ASSERT(src.getSize() == 2 || src.getSize() == 4);
    _emitInstruction(INST_FIDIV, &src);
  }
  inline void fidivr(const Mem& src)
  {
    ASMJIT_ASSERT(src.getSize() == 2 || src.getSize() == 4);
    _emitInstruction(INST_FIDIVR, &src);
  }
  inline void fild(const Mem& src)
  {
    ASMJIT_ASSERT(src.getSize() == 2 || src.getSize() == 4 || src.getSize() == 8);
    _emitInstruction(INST_FILD, &src);
  }
  inline void fimul(const Mem& src)
  {
    ASMJIT_ASSERT(src.getSize() == 2 || src.getSize() == 4);
    _emitInstruction(INST_FIMUL, &src);
  }
  inline void fincstp()
  {
    _emitInstruction(INST_FINCSTP);
  }
  inline void finit()
  {
    _emitInstruction(INST_FINIT);
  }
  inline void fisub(const Mem& src)
  {
    ASMJIT_ASSERT(src.getSize() == 2 || src.getSize() == 4);
    _emitInstruction(INST_FISUB, &src);
  }
  inline void fisubr(const Mem& src)
  {
    ASMJIT_ASSERT(src.getSize() == 2 || src.getSize() == 4);
    _emitInstruction(INST_FISUBR, &src);
  }
  inline void fninit()
  {
    _emitInstruction(INST_FNINIT);
  }
  inline void fist(const Mem& dst)
  {
    ASMJIT_ASSERT(dst.getSize() == 2 || dst.getSize() == 4);
    _emitInstruction(INST_FIST, &dst);
  }
  inline void fistp(const Mem& dst)
  {
    ASMJIT_ASSERT(dst.getSize() == 2 || dst.getSize() == 4 || dst.getSize() == 8);
    _emitInstruction(INST_FISTP, &dst);
  }
  inline void fld(const Mem& src)
  {
    ASMJIT_ASSERT(src.getSize() == 4 || src.getSize() == 8 || src.getSize() == 10);
    _emitInstruction(INST_FLD, &src);
  }
  inline void fld(const X87Reg& reg)
  {
    _emitInstruction(INST_FLD, &reg);
  }
  inline void fld1()
  {
    _emitInstruction(INST_FLD1);
  }
  inline void fldl2t()
  {
    _emitInstruction(INST_FLDL2T);
  }
  inline void fldl2e()
  {
    _emitInstruction(INST_FLDL2E);
  }
  inline void fldpi()
  {
    _emitInstruction(INST_FLDPI);
  }
  inline void fldlg2()
  {
    _emitInstruction(INST_FLDLG2);
  }
  inline void fldln2()
  {
    _emitInstruction(INST_FLDLN2);
  }
  inline void fldz()
  {
    _emitInstruction(INST_FLDZ);
  }
  inline void fldcw(const Mem& src)
  {
    _emitInstruction(INST_FLDCW, &src);
  }
  inline void fldenv(const Mem& src)
  {
    _emitInstruction(INST_FLDENV, &src);
  }
  inline void fmul(const X87Reg& dst, const X87Reg& src)
  {
    ASMJIT_ASSERT(dst.getRegIndex() == 0 || src.getRegIndex() == 0);
    _emitInstruction(INST_FMUL, &dst, &src);
  }
  inline void fmul(const Mem& src)
  {
    _emitInstruction(INST_FMUL, &src);
  }
  inline void fmulp(const X87Reg& dst = st(1))
  {
    _emitInstruction(INST_FMULP, &dst);
  }
  inline void fnclex()
  {
    _emitInstruction(INST_FNCLEX);
  }
  inline void fnop()
  {
    _emitInstruction(INST_FNOP);
  }
  inline void fnsave(const Mem& dst)
  {
    _emitInstruction(INST_FNSAVE, &dst);
  }
  inline void fnstenv(const Mem& dst)
  {
    _emitInstruction(INST_FNSTENV, &dst);
  }
  inline void fnstcw(const Mem& dst)
  {
    _emitInstruction(INST_FNSTCW, &dst);
  }
  inline void fnstsw(const GPReg& dst)
  {
    ASMJIT_ASSERT(dst.isRegCode(REG_AX));
    _emitInstruction(INST_FNSTSW, &dst);
  }
  inline void fnstsw(const Mem& dst)
  {
    _emitInstruction(INST_FNSTSW, &dst);
  }
  inline void fpatan()
  {
    _emitInstruction(INST_FPATAN);
  }
  inline void fprem()
  {
    _emitInstruction(INST_FPREM);
  }
  inline void fprem1()
  {
    _emitInstruction(INST_FPREM1);
  }
  inline void fptan()
  {
    _emitInstruction(INST_FPTAN);
  }
  inline void frndint()
  {
    _emitInstruction(INST_FRNDINT);
  }
  inline void frstor(const Mem& src)
  {
    _emitInstruction(INST_FRSTOR, &src);
  }
  inline void fsave(const Mem& dst)
  {
    _emitInstruction(INST_FSAVE, &dst);
  }
  inline void fscale()
  {
    _emitInstruction(INST_FSCALE);
  }
  inline void fsin()
  {
    _emitInstruction(INST_FSIN);
  }
  inline void fsincos()
  {
    _emitInstruction(INST_FSINCOS);
  }
  inline void fsqrt()
  {
    _emitInstruction(INST_FSQRT);
  }
  inline void fst(const Mem& dst)
  {
    ASMJIT_ASSERT(dst.getSize() == 4 || dst.getSize() == 8);
    _emitInstruction(INST_FST, &dst);
  }
  inline void fst(const X87Reg& reg)
  {
    _emitInstruction(INST_FST, &reg);
  }
  inline void fstp(const Mem& dst)
  {
    ASMJIT_ASSERT(dst.getSize() == 4 || dst.getSize() == 8 || dst.getSize() == 10);
    _emitInstruction(INST_FSTP, &dst);
  }
  inline void fstp(const X87Reg& reg)
  {
    _emitInstruction(INST_FSTP, &reg);
  }
  inline void fstcw(const Mem& dst)
  {
    _emitInstruction(INST_FSTCW, &dst);
  }
  inline void fstenv(const Mem& dst)
  {
    _emitInstruction(INST_FSTENV, &dst);
  }
  inline void fstsw(const GPReg& dst)
  {
    ASMJIT_ASSERT(dst.isRegCode(REG_AX));
    _emitInstruction(INST_FSTSW, &dst);
  }
  inline void fstsw(const Mem& dst)
  {
    _emitInstruction(INST_FSTSW, &dst);
  }
  inline void fsub(const X87Reg& dst, const X87Reg& src)
  {
    ASMJIT_ASSERT(dst.getRegIndex() == 0 || src.getRegIndex() == 0);
    _emitInstruction(INST_FSUB, &dst, &src);
  }
  inline void fsub(const Mem& src)
  {
    ASMJIT_ASSERT(src.getSize() == 4 || src.getSize() == 8);
    _emitInstruction(INST_FSUB, &src);
  }
  inline void fsubp(const X87Reg& dst = st(1))
  {
    _emitInstruction(INST_FSUBP, &dst);
  }
  inline void fsubr(const X87Reg& dst, const X87Reg& src)
  {
    ASMJIT_ASSERT(dst.getRegIndex() == 0 || src.getRegIndex() == 0);
    _emitInstruction(INST_FSUBR, &dst, &src);
  }
  inline void fsubr(const Mem& src)
  {
    ASMJIT_ASSERT(src.getSize() == 4 || src.getSize() == 8);
    _emitInstruction(INST_FSUBR, &src);
  }
  inline void fsubrp(const X87Reg& dst = st(1))
  {
    _emitInstruction(INST_FSUBRP, &dst);
  }
  inline void ftst()
  {
    _emitInstruction(INST_FTST);
  }
  inline void fucom(const X87Reg& reg = st(1))
  {
    _emitInstruction(INST_FUCOM, &reg);
  }
  inline void fucomi(const X87Reg& reg)
  {
    _emitInstruction(INST_FUCOMI, &reg);
  }
  inline void fucomip(const X87Reg& reg = st(1))
  {
    _emitInstruction(INST_FUCOMIP, &reg);
  }
  inline void fucomp(const X87Reg& reg = st(1))
  {
    _emitInstruction(INST_FUCOMP, &reg);
  }
  inline void fucompp()
  {
    _emitInstruction(INST_FUCOMPP);
  }
  inline void fwait()
  {
    _emitInstruction(INST_FWAIT);
  }
  inline void fxam()
  {
    _emitInstruction(INST_FXAM);
  }
  inline void fxch(const X87Reg& reg = st(1))
  {
    _emitInstruction(INST_FXCH, &reg);
  }
  inline void fxrstor(const Mem& src)
  {
    _emitInstruction(INST_FXRSTOR, &src);
  }
  inline void fxsave(const Mem& dst)
  {
    _emitInstruction(INST_FXSAVE, &dst);
  }
  inline void fxtract()
  {
    _emitInstruction(INST_FXTRACT);
  }
  inline void fyl2x()
  {
    _emitInstruction(INST_FYL2X);
  }
  inline void fyl2xp1()
  {
    _emitInstruction(INST_FYL2XP1);
  }
  inline void emms()
  {
    _emitInstruction(INST_EMMS);
  }
  inline void movd(const Mem& dst, const MMReg& src)
  {
    _emitInstruction(INST_MOVD, &dst, &src);
  }
  inline void movd(const GPReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_MOVD, &dst, &src);
  }
  inline void movd(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVD, &dst, &src);
  }
  inline void movd(const MMReg& dst, const GPReg& src)
  {
    _emitInstruction(INST_MOVD, &dst, &src);
  }
  inline void movq(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_MOVQ, &dst, &src);
  }
  inline void movq(const Mem& dst, const MMReg& src)
  {
    _emitInstruction(INST_MOVQ, &dst, &src);
  }
  inline void movq(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVQ, &dst, &src);
  }
  inline void packsswb(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PACKSSWB, &dst, &src);
  }
  inline void packsswb(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PACKSSWB, &dst, &src);
  }
  inline void packssdw(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PACKSSDW, &dst, &src);
  }
  inline void packssdw(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PACKSSDW, &dst, &src);
  }
  inline void packuswb(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PACKUSWB, &dst, &src);
  }
  inline void packuswb(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PACKUSWB, &dst, &src);
  }
  inline void paddb(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PADDB, &dst, &src);
  }
  inline void paddb(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PADDB, &dst, &src);
  }
  inline void paddw(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PADDW, &dst, &src);
  }
  inline void paddw(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PADDW, &dst, &src);
  }
  inline void paddd(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PADDD, &dst, &src);
  }
  inline void paddd(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PADDD, &dst, &src);
  }
  inline void paddsb(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PADDSB, &dst, &src);
  }
  inline void paddsb(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PADDSB, &dst, &src);
  }
  inline void paddsw(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PADDSW, &dst, &src);
  }
  inline void paddsw(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PADDSW, &dst, &src);
  }
  inline void paddusb(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PADDUSB, &dst, &src);
  }
  inline void paddusb(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PADDUSB, &dst, &src);
  }
  inline void paddusw(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PADDUSW, &dst, &src);
  }
  inline void paddusw(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PADDUSW, &dst, &src);
  }
  inline void pand(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PAND, &dst, &src);
  }
  inline void pand(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PAND, &dst, &src);
  }
  inline void pandn(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PANDN, &dst, &src);
  }
  inline void pandn(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PANDN, &dst, &src);
  }
  inline void pcmpeqb(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PCMPEQB, &dst, &src);
  }
  inline void pcmpeqb(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PCMPEQB, &dst, &src);
  }
  inline void pcmpeqw(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PCMPEQW, &dst, &src);
  }
  inline void pcmpeqw(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PCMPEQW, &dst, &src);
  }
  inline void pcmpeqd(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PCMPEQD, &dst, &src);
  }
  inline void pcmpeqd(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PCMPEQD, &dst, &src);
  }
  inline void pcmpgtb(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PCMPGTB, &dst, &src);
  }
  inline void pcmpgtb(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PCMPGTB, &dst, &src);
  }
  inline void pcmpgtw(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PCMPGTW, &dst, &src);
  }
  inline void pcmpgtw(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PCMPGTW, &dst, &src);
  }
  inline void pcmpgtd(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PCMPGTD, &dst, &src);
  }
  inline void pcmpgtd(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PCMPGTD, &dst, &src);
  }
  inline void pmulhw(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PMULHW, &dst, &src);
  }
  inline void pmulhw(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMULHW, &dst, &src);
  }
  inline void pmullw(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PMULLW, &dst, &src);
  }
  inline void pmullw(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMULLW, &dst, &src);
  }
  inline void por(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_POR, &dst, &src);
  }
  inline void por(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_POR, &dst, &src);
  }
  inline void pmaddwd(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PMADDWD, &dst, &src);
  }
  inline void pmaddwd(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMADDWD, &dst, &src);
  }
  inline void pslld(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PSLLD, &dst, &src);
  }
  inline void pslld(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSLLD, &dst, &src);
  }
  inline void pslld(const MMReg& dst, const Imm& src)
  {
    _emitInstruction(INST_PSLLD, &dst, &src);
  }
  inline void psllq(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PSLLQ, &dst, &src);
  }
  inline void psllq(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSLLQ, &dst, &src);
  }
  inline void psllq(const MMReg& dst, const Imm& src)
  {
    _emitInstruction(INST_PSLLQ, &dst, &src);
  }
  inline void psllw(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PSLLW, &dst, &src);
  }
  inline void psllw(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSLLW, &dst, &src);
  }
  inline void psllw(const MMReg& dst, const Imm& src)
  {
    _emitInstruction(INST_PSLLW, &dst, &src);
  }
  inline void psrad(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PSRAD, &dst, &src);
  }
  inline void psrad(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSRAD, &dst, &src);
  }
  inline void psrad(const MMReg& dst, const Imm& src)
  {
    _emitInstruction(INST_PSRAD, &dst, &src);
  }
  inline void psraw(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PSRAW, &dst, &src);
  }
  inline void psraw(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSRAW, &dst, &src);
  }
  inline void psraw(const MMReg& dst, const Imm& src)
  {
    _emitInstruction(INST_PSRAW, &dst, &src);
  }
  inline void psrld(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PSRLD, &dst, &src);
  }
  inline void psrld(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSRLD, &dst, &src);
  }
  inline void psrld(const MMReg& dst, const Imm& src)
  {
    _emitInstruction(INST_PSRLD, &dst, &src);
  }
  inline void psrlq(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PSRLQ, &dst, &src);
  }
  inline void psrlq(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSRLQ, &dst, &src);
  }
  inline void psrlq(const MMReg& dst, const Imm& src)
  {
    _emitInstruction(INST_PSRLQ, &dst, &src);
  }
  inline void psrlw(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PSRLW, &dst, &src);
  }
  inline void psrlw(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSRLW, &dst, &src);
  }
  inline void psrlw(const MMReg& dst, const Imm& src)
  {
    _emitInstruction(INST_PSRLW, &dst, &src);
  }
  inline void psubb(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PSUBB, &dst, &src);
  }
  inline void psubb(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSUBB, &dst, &src);
  }
  inline void psubw(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PSUBW, &dst, &src);
  }
  inline void psubw(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSUBW, &dst, &src);
  }
  inline void psubd(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PSUBD, &dst, &src);
  }
  inline void psubd(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSUBD, &dst, &src);
  }
  inline void psubsb(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PSUBSB, &dst, &src);
  }
  inline void psubsb(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSUBSB, &dst, &src);
  }
  inline void psubsw(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PSUBSW, &dst, &src);
  }
  inline void psubsw(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSUBSW, &dst, &src);
  }
  inline void psubusb(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PSUBUSB, &dst, &src);
  }
  inline void psubusb(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSUBUSB, &dst, &src);
  }
  inline void psubusw(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PSUBUSW, &dst, &src);
  }
  inline void psubusw(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSUBUSW, &dst, &src);
  }
  inline void punpckhbw(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PUNPCKHBW, &dst, &src);
  }
  inline void punpckhbw(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PUNPCKHBW, &dst, &src);
  }
  inline void punpckhwd(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PUNPCKHWD, &dst, &src);
  }
  inline void punpckhwd(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PUNPCKHWD, &dst, &src);
  }
  inline void punpckhdq(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PUNPCKHDQ, &dst, &src);
  }
  inline void punpckhdq(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PUNPCKHDQ, &dst, &src);
  }
  inline void punpcklbw(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PUNPCKLBW, &dst, &src);
  }
  inline void punpcklbw(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PUNPCKLBW, &dst, &src);
  }
  inline void punpcklwd(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PUNPCKLWD, &dst, &src);
  }
  inline void punpcklwd(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PUNPCKLWD, &dst, &src);
  }
  inline void punpckldq(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PUNPCKLDQ, &dst, &src);
  }
  inline void punpckldq(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PUNPCKLDQ, &dst, &src);
  }
  inline void pxor(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PXOR, &dst, &src);
  }
  inline void pxor(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PXOR, &dst, &src);
  }
  inline void femms()
  {
    _emitInstruction(INST_FEMMS);
  }
  inline void pf2id(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PF2ID, &dst, &src);
  }
  inline void pf2id(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PF2ID, &dst, &src);
  }
  inline void pf2iw(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PF2IW, &dst, &src);
  }
  inline void pf2iw(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PF2IW, &dst, &src);
  }
  inline void pfacc(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PFACC, &dst, &src);
  }
  inline void pfacc(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PFACC, &dst, &src);
  }
  inline void pfadd(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PFADD, &dst, &src);
  }
  inline void pfadd(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PFADD, &dst, &src);
  }
  inline void pfcmpeq(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PFCMPEQ, &dst, &src);
  }
  inline void pfcmpeq(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PFCMPEQ, &dst, &src);
  }
  inline void pfcmpge(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PFCMPGE, &dst, &src);
  }
  inline void pfcmpge(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PFCMPGE, &dst, &src);
  }
  inline void pfcmpgt(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PFCMPGT, &dst, &src);
  }
  inline void pfcmpgt(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PFCMPGT, &dst, &src);
  }
  inline void pfmax(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PFMAX, &dst, &src);
  }
  inline void pfmax(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PFMAX, &dst, &src);
  }
  inline void pfmin(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PFMIN, &dst, &src);
  }
  inline void pfmin(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PFMIN, &dst, &src);
  }
  inline void pfmul(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PFMUL, &dst, &src);
  }
  inline void pfmul(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PFMUL, &dst, &src);
  }
  inline void pfnacc(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PFNACC, &dst, &src);
  }
  inline void pfnacc(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PFNACC, &dst, &src);
  }
  inline void pfpnaxx(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PFPNACC, &dst, &src);
  }
  inline void pfpnacc(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PFPNACC, &dst, &src);
  }
  inline void pfrcp(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PFRCP, &dst, &src);
  }
  inline void pfrcp(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PFRCP, &dst, &src);
  }
  inline void pfrcpit1(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PFRCPIT1, &dst, &src);
  }
  inline void pfrcpit1(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PFRCPIT1, &dst, &src);
  }
  inline void pfrcpit2(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PFRCPIT2, &dst, &src);
  }
  inline void pfrcpit2(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PFRCPIT2, &dst, &src);
  }
  inline void pfrsqit1(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PFRSQIT1, &dst, &src);
  }
  inline void pfrsqit1(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PFRSQIT1, &dst, &src);
  }
  inline void pfrsqrt(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PFRSQRT, &dst, &src);
  }
  inline void pfrsqrt(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PFRSQRT, &dst, &src);
  }
  inline void pfsub(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PFSUB, &dst, &src);
  }
  inline void pfsub(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PFSUB, &dst, &src);
  }
  inline void pfsubr(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PFSUBR, &dst, &src);
  }
  inline void pfsubr(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PFSUBR, &dst, &src);
  }
  inline void pi2fd(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PI2FD, &dst, &src);
  }
  inline void pi2fd(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PI2FD, &dst, &src);
  }
  inline void pi2fw(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PI2FW, &dst, &src);
  }
  inline void pi2fw(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PI2FW, &dst, &src);
  }
  inline void pswapd(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PSWAPD, &dst, &src);
  }
  inline void pswapd(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSWAPD, &dst, &src);
  }
  inline void addps(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_ADDPS, &dst, &src);
  }
  inline void addps(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_ADDPS, &dst, &src);
  }
  inline void addss(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_ADDSS, &dst, &src);
  }
  inline void addss(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_ADDSS, &dst, &src);
  }
  inline void andnps(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_ANDNPS, &dst, &src);
  }
  inline void andnps(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_ANDNPS, &dst, &src);
  }
  inline void andps(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_ANDPS, &dst, &src);
  }
  inline void andps(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_ANDPS, &dst, &src);
  }
  inline void cmpps(const XMMReg& dst, const XMMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_CMPPS, &dst, &src, &imm8);
  }
  inline void cmpps(const XMMReg& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_CMPPS, &dst, &src, &imm8);
  }
  inline void cmpss(const XMMReg& dst, const XMMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_CMPSS, &dst, &src, &imm8);
  }
  inline void cmpss(const XMMReg& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_CMPSS, &dst, &src, &imm8);
  }
  inline void comiss(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_COMISS, &dst, &src);
  }
  inline void comiss(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_COMISS, &dst, &src);
  }
  inline void cvtpi2ps(const XMMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_CVTPI2PS, &dst, &src);
  }
  inline void cvtpi2ps(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTPI2PS, &dst, &src);
  }
  inline void cvtps2pi(const MMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_CVTPS2PI, &dst, &src);
  }
  inline void cvtps2pi(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTPS2PI, &dst, &src);
  }
  inline void cvtsi2ss(const XMMReg& dst, const GPReg& src)
  {
    _emitInstruction(INST_CVTSI2SS, &dst, &src);
  }
  inline void cvtsi2ss(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTSI2SS, &dst, &src);
  }
  inline void cvtss2si(const GPReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_CVTSS2SI, &dst, &src);
  }
  inline void cvtss2si(const GPReg& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTSS2SI, &dst, &src);
  }
  inline void cvttps2pi(const MMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_CVTTPS2PI, &dst, &src);
  }
  inline void cvttps2pi(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTTPS2PI, &dst, &src);
  }
  inline void cvttss2si(const GPReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_CVTTSS2SI, &dst, &src);
  }
  inline void cvttss2si(const GPReg& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTTSS2SI, &dst, &src);
  }
  inline void divps(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_DIVPS, &dst, &src);
  }
  inline void divps(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_DIVPS, &dst, &src);
  }
  inline void divss(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_DIVSS, &dst, &src);
  }
  inline void divss(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_DIVSS, &dst, &src);
  }
  inline void ldmxcsr(const Mem& src)
  {
    _emitInstruction(INST_LDMXCSR, &src);
  }
  inline void maskmovq(const MMReg& data, const MMReg& mask)
  {
    _emitInstruction(INST_MASKMOVQ, &data, &mask);
  }
  inline void maxps(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MAXPS, &dst, &src);
  }
  inline void maxps(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MAXPS, &dst, &src);
  }
  inline void maxss(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MAXSS, &dst, &src);
  }
  inline void maxss(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MAXSS, &dst, &src);
  }
  inline void minps(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MINPS, &dst, &src);
  }
  inline void minps(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MINPS, &dst, &src);
  }
  inline void minss(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MINSS, &dst, &src);
  }
  inline void minss(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MINSS, &dst, &src);
  }
  inline void movaps(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MOVAPS, &dst, &src);
  }
  inline void movaps(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVAPS, &dst, &src);
  }
  inline void movaps(const Mem& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MOVAPS, &dst, &src);
  }
  inline void movd(const Mem& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MOVD, &dst, &src);
  }
  inline void movd(const GPReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MOVD, &dst, &src);
  }
  inline void movd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVD, &dst, &src);
  }
  inline void movd(const XMMReg& dst, const GPReg& src)
  {
    _emitInstruction(INST_MOVD, &dst, &src);
  }
  inline void movq(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MOVQ, &dst, &src);
  }
  inline void movq(const Mem& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MOVQ, &dst, &src);
  }
  inline void movq(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVQ, &dst, &src);
  }
  inline void movntq(const Mem& dst, const MMReg& src)
  {
    _emitInstruction(INST_MOVNTQ, &dst, &src);
  }
  inline void movhlps(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MOVHLPS, &dst, &src);
  }
  inline void movhps(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVHPS, &dst, &src);
  }
  inline void movhps(const Mem& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MOVHPS, &dst, &src);
  }
  inline void movlhps(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MOVLHPS, &dst, &src);
  }
  inline void movlps(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVLPS, &dst, &src);
  }
  inline void movlps(const Mem& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MOVLPS, &dst, &src);
  }
  inline void movntps(const Mem& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MOVNTPS, &dst, &src);
  }
  inline void movss(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MOVSS, &dst, &src);
  }
  inline void movss(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVSS, &dst, &src);
  }
  inline void movss(const Mem& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MOVSS, &dst, &src);
  }
  inline void movups(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MOVUPS, &dst, &src);
  }
  inline void movups(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVUPS, &dst, &src);
  }
  inline void movups(const Mem& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MOVUPS, &dst, &src);
  }
  inline void mulps(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MULPS, &dst, &src);
  }
  inline void mulps(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MULPS, &dst, &src);
  }
  inline void mulss(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MULSS, &dst, &src);
  }
  inline void mulss(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MULSS, &dst, &src);
  }
  inline void orps(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_ORPS, &dst, &src);
  }
  inline void orps(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_ORPS, &dst, &src);
  }
  inline void pavgb(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PAVGB, &dst, &src);
  }
  inline void pavgb(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PAVGB, &dst, &src);
  }
  inline void pavgw(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PAVGW, &dst, &src);
  }
  inline void pavgw(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PAVGW, &dst, &src);
  }
  inline void pextrw(const GPReg& dst, const MMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_PEXTRW, &dst, &src, &imm8);
  }
  inline void pinsrw(const MMReg& dst, const GPReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_PINSRW, &dst, &src, &imm8);
  }
  inline void pinsrw(const MMReg& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_PINSRW, &dst, &src, &imm8);
  }
  inline void pmaxsw(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PMAXSW, &dst, &src);
  }
  inline void pmaxsw(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMAXSW, &dst, &src);
  }
  inline void pmaxub(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PMAXUB, &dst, &src);
  }
  inline void pmaxub(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMAXUB, &dst, &src);
  }
  inline void pminsw(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PMINSW, &dst, &src);
  }
  inline void pminsw(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMINSW, &dst, &src);
  }
  inline void pminub(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PMINUB, &dst, &src);
  }
  inline void pminub(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMINUB, &dst, &src);
  }
  inline void pmovmskb(const GPReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PMOVMSKB, &dst, &src);
  }
  inline void pmulhuw(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PMULHUW, &dst, &src);
  }
  inline void pmulhuw(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMULHUW, &dst, &src);
  }
  inline void psadbw(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PSADBW, &dst, &src);
  }
  inline void psadbw(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSADBW, &dst, &src);
  }
  inline void pshufw(const MMReg& dst, const MMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_PSHUFW, &dst, &src, &imm8);
  }
  inline void pshufw(const MMReg& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_PSHUFW, &dst, &src, &imm8);
  }
  inline void rcpps(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_RCPPS, &dst, &src);
  }
  inline void rcpps(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_RCPPS, &dst, &src);
  }
  inline void rcpss(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_RCPSS, &dst, &src);
  }
  inline void rcpss(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_RCPSS, &dst, &src);
  }
  inline void prefetch(const Mem& mem, const Imm& hint)
  {
    _emitInstruction(INST_PREFETCH, &mem, &hint);
  }
  inline void psadbw(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PSADBW, &dst, &src);
  }
  inline void psadbw(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSADBW, &dst, &src);
  }
  inline void rsqrtps(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_RSQRTPS, &dst, &src);
  }
  inline void rsqrtps(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_RSQRTPS, &dst, &src);
  }
  inline void rsqrtss(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_RSQRTSS, &dst, &src);
  }
  inline void rsqrtss(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_RSQRTSS, &dst, &src);
  }
  inline void sfence()
  {
    _emitInstruction(INST_SFENCE);
  }
  inline void shufps(const XMMReg& dst, const XMMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_SHUFPS, &dst, &src, &imm8);
  }
  inline void shufps(const XMMReg& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_SHUFPS, &dst, &src, &imm8);
  }
  inline void sqrtps(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_SQRTPS, &dst, &src);
  }
  inline void sqrtps(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_SQRTPS, &dst, &src);
  }
  inline void sqrtss(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_SQRTSS, &dst, &src);
  }
  inline void sqrtss(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_SQRTSS, &dst, &src);
  }
  inline void stmxcsr(const Mem& dst)
  {
    _emitInstruction(INST_STMXCSR, &dst);
  }
  inline void subps(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_SUBPS, &dst, &src);
  }
  inline void subps(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_SUBPS, &dst, &src);
  }
  inline void subss(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_SUBSS, &dst, &src);
  }
  inline void subss(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_SUBSS, &dst, &src);
  }
  inline void ucomiss(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_UCOMISS, &dst, &src);
  }
  inline void ucomiss(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_UCOMISS, &dst, &src);
  }
  inline void unpckhps(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_UNPCKHPS, &dst, &src);
  }
  inline void unpckhps(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_UNPCKHPS, &dst, &src);
  }
  inline void unpcklps(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_UNPCKLPS, &dst, &src);
  }
  inline void unpcklps(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_UNPCKLPS, &dst, &src);
  }
  inline void xorps(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_XORPS, &dst, &src);
  }
  inline void xorps(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_XORPS, &dst, &src);
  }
  inline void addpd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_ADDPD, &dst, &src);
  }
  inline void addpd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_ADDPD, &dst, &src);
  }
  inline void addsd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_ADDSD, &dst, &src);
  }
  inline void addsd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_ADDSD, &dst, &src);
  }
  inline void andnpd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_ANDNPD, &dst, &src);
  }
  inline void andnpd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_ANDNPD, &dst, &src);
  }
  inline void andpd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_ANDPD, &dst, &src);
  }
  inline void andpd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_ANDPD, &dst, &src);
  }
  inline void clflush(const Mem& mem)
  {
    _emitInstruction(INST_CLFLUSH, &mem);
  }
  inline void cmppd(const XMMReg& dst, const XMMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_CMPPD, &dst, &src, &imm8);
  }
  inline void cmppd(const XMMReg& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_CMPPD, &dst, &src, &imm8);
  }
  inline void cmpsd(const XMMReg& dst, const XMMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_CMPSD, &dst, &src, &imm8);
  }
  inline void cmpsd(const XMMReg& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_CMPSD, &dst, &src, &imm8);
  }
  inline void comisd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_COMISD, &dst, &src);
  }
  inline void comisd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_COMISD, &dst, &src);
  }
  inline void cvtdq2pd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_CVTDQ2PD, &dst, &src);
  }
  inline void cvtdq2pd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTDQ2PD, &dst, &src);
  }
  inline void cvtdq2ps(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_CVTDQ2PS, &dst, &src);
  }
  inline void cvtdq2ps(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTDQ2PS, &dst, &src);
  }
  inline void cvtpd2dq(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_CVTPD2DQ, &dst, &src);
  }
  inline void cvtpd2dq(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTPD2DQ, &dst, &src);
  }
  inline void cvtpd2pi(const MMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_CVTPD2PI, &dst, &src);
  }
  inline void cvtpd2pi(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTPD2PI, &dst, &src);
  }
  inline void cvtpd2ps(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_CVTPD2PS, &dst, &src);
  }
  inline void cvtpd2ps(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTPD2PS, &dst, &src);
  }
  inline void cvtpi2pd(const XMMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_CVTPI2PD, &dst, &src);
  }
  inline void cvtpi2pd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTPI2PD, &dst, &src);
  }
  inline void cvtps2dq(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_CVTPS2DQ, &dst, &src);
  }
  inline void cvtps2dq(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTPS2DQ, &dst, &src);
  }
  inline void cvtps2pd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_CVTPS2PD, &dst, &src);
  }
  inline void cvtps2pd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTPS2PD, &dst, &src);
  }
  inline void cvtsd2si(const GPReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_CVTSD2SI, &dst, &src);
  }
  inline void cvtsd2si(const GPReg& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTSD2SI, &dst, &src);
  }
  inline void cvtsd2ss(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_CVTSD2SS, &dst, &src);
  }
  inline void cvtsd2ss(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTSD2SS, &dst, &src);
  }
  inline void cvtsi2sd(const XMMReg& dst, const GPReg& src)
  {
    _emitInstruction(INST_CVTSI2SD, &dst, &src);
  }
  inline void cvtsi2sd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTSI2SD, &dst, &src);
  }
  inline void cvtss2sd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_CVTSS2SD, &dst, &src);
  }
  inline void cvtss2sd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTSS2SD, &dst, &src);
  }
  inline void cvttpd2pi(const MMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_CVTTPD2PI, &dst, &src);
  }
  inline void cvttpd2pi(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTTPD2PI, &dst, &src);
  }
  inline void cvttpd2dq(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_CVTTPD2DQ, &dst, &src);
  }
  inline void cvttpd2dq(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTTPD2DQ, &dst, &src);
  }
  inline void cvttps2dq(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_CVTTPS2DQ, &dst, &src);
  }
  inline void cvttps2dq(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTTPS2DQ, &dst, &src);
  }
  inline void cvttsd2si(const GPReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_CVTTSD2SI, &dst, &src);
  }
  inline void cvttsd2si(const GPReg& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTTSD2SI, &dst, &src);
  }
  inline void divpd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_DIVPD, &dst, &src);
  }
  inline void divpd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_DIVPD, &dst, &src);
  }
  inline void divsd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_DIVSD, &dst, &src);
  }
  inline void divsd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_DIVSD, &dst, &src);
  }
  inline void lfence()
  {
    _emitInstruction(INST_LFENCE);
  }
  inline void maskmovdqu(const XMMReg& src, const XMMReg& mask)
  {
    _emitInstruction(INST_MASKMOVDQU, &src, &mask);
  }
  inline void maxpd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MAXPD, &dst, &src);
  }
  inline void maxpd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MAXPD, &dst, &src);
  }
  inline void maxsd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MAXSD, &dst, &src);
  }
  inline void maxsd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MAXSD, &dst, &src);
  }
  inline void mfence()
  {
    _emitInstruction(INST_MFENCE);
  }
  inline void minpd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MINPD, &dst, &src);
  }
  inline void minpd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MINPD, &dst, &src);
  }
  inline void minsd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MINSD, &dst, &src);
  }
  inline void minsd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MINSD, &dst, &src);
  }
  inline void movdqa(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MOVDQA, &dst, &src);
  }
  inline void movdqa(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVDQA, &dst, &src);
  }
  inline void movdqa(const Mem& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MOVDQA, &dst, &src);
  }
  inline void movdqu(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MOVDQU, &dst, &src);
  }
  inline void movdqu(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVDQU, &dst, &src);
  }
  inline void movdqu(const Mem& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MOVDQU, &dst, &src);
  }
  inline void movmskps(const GPReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MOVMSKPS, &dst, &src);
  }
  inline void movmskpd(const GPReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MOVMSKPD, &dst, &src);
  }
  inline void movsd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MOVSD, &dst, &src);
  }
  inline void movsd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVSD, &dst, &src);
  }
  inline void movsd(const Mem& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MOVSD, &dst, &src);
  }
  inline void movapd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MOVAPD, &dst, &src);
  }
  inline void movapd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVAPD, &dst, &src);
  }
  inline void movapd(const Mem& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MOVAPD, &dst, &src);
  }
  inline void movdq2q(const MMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MOVDQ2Q, &dst, &src);
  }
  inline void movq2dq(const XMMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_MOVQ2DQ, &dst, &src);
  }
  inline void movhpd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVHPD, &dst, &src);
  }
  inline void movhpd(const Mem& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MOVHPD, &dst, &src);
  }
  inline void movlpd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVLPD, &dst, &src);
  }
  inline void movlpd(const Mem& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MOVLPD, &dst, &src);
  }
  inline void movntdq(const Mem& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MOVNTDQ, &dst, &src);
  }
  inline void movnti(const Mem& dst, const GPReg& src)
  {
    _emitInstruction(INST_MOVNTI, &dst, &src);
  }
  inline void movntpd(const Mem& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MOVNTPD, &dst, &src);
  }
  inline void movupd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MOVUPD, &dst, &src);
  }
  inline void movupd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVUPD, &dst, &src);
  }
  inline void movupd(const Mem& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MOVUPD, &dst, &src);
  }
  inline void mulpd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MULPD, &dst, &src);
  }
  inline void mulpd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MULPD, &dst, &src);
  }
  inline void mulsd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MULSD, &dst, &src);
  }
  inline void mulsd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MULSD, &dst, &src);
  }
  inline void orpd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_ORPD, &dst, &src);
  }
  inline void orpd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_ORPD, &dst, &src);
  }
  inline void packsswb(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PACKSSWB, &dst, &src);
  }
  inline void packsswb(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PACKSSWB, &dst, &src);
  }
  inline void packssdw(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PACKSSDW, &dst, &src);
  }
  inline void packssdw(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PACKSSDW, &dst, &src);
  }
  inline void packuswb(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PACKUSWB, &dst, &src);
  }
  inline void packuswb(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PACKUSWB, &dst, &src);
  }
  inline void paddb(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PADDB, &dst, &src);
  }
  inline void paddb(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PADDB, &dst, &src);
  }
  inline void paddw(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PADDW, &dst, &src);
  }
  inline void paddw(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PADDW, &dst, &src);
  }
  inline void paddd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PADDD, &dst, &src);
  }
  inline void paddd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PADDD, &dst, &src);
  }
  inline void paddq(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PADDQ, &dst, &src);
  }
  inline void paddq(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PADDQ, &dst, &src);
  }
  inline void paddq(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PADDQ, &dst, &src);
  }
  inline void paddq(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PADDQ, &dst, &src);
  }
  inline void paddsb(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PADDSB, &dst, &src);
  }
  inline void paddsb(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PADDSB, &dst, &src);
  }
  inline void paddsw(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PADDSW, &dst, &src);
  }
  inline void paddsw(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PADDSW, &dst, &src);
  }
  inline void paddusb(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PADDUSB, &dst, &src);
  }
  inline void paddusb(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PADDUSB, &dst, &src);
  }
  inline void paddusw(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PADDUSW, &dst, &src);
  }
  inline void paddusw(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PADDUSW, &dst, &src);
  }
  inline void pand(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PAND, &dst, &src);
  }
  inline void pand(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PAND, &dst, &src);
  }
  inline void pandn(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PANDN, &dst, &src);
  }
  inline void pandn(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PANDN, &dst, &src);
  }
  inline void pause()
  {
    _emitInstruction(INST_PAUSE);
  }
  inline void pavgb(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PAVGB, &dst, &src);
  }
  inline void pavgb(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PAVGB, &dst, &src);
  }
  inline void pavgw(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PAVGW, &dst, &src);
  }
  inline void pavgw(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PAVGW, &dst, &src);
  }
  inline void pcmpeqb(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PCMPEQB, &dst, &src);
  }
  inline void pcmpeqb(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PCMPEQB, &dst, &src);
  }
  inline void pcmpeqw(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PCMPEQW, &dst, &src);
  }
  inline void pcmpeqw(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PCMPEQW, &dst, &src);
  }
  inline void pcmpeqd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PCMPEQD, &dst, &src);
  }
  inline void pcmpeqd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PCMPEQD, &dst, &src);
  }
  inline void pcmpgtb(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PCMPGTB, &dst, &src);
  }
  inline void pcmpgtb(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PCMPGTB, &dst, &src);
  }
  inline void pcmpgtw(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PCMPGTW, &dst, &src);
  }
  inline void pcmpgtw(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PCMPGTW, &dst, &src);
  }
  inline void pcmpgtd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PCMPGTD, &dst, &src);
  }
  inline void pcmpgtd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PCMPGTD, &dst, &src);
  }
  inline void pmaxsw(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PMAXSW, &dst, &src);
  }
  inline void pmaxsw(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMAXSW, &dst, &src);
  }
  inline void pmaxub(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PMAXUB, &dst, &src);
  }
  inline void pmaxub(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMAXUB, &dst, &src);
  }
  inline void pminsw(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PMINSW, &dst, &src);
  }
  inline void pminsw(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMINSW, &dst, &src);
  }
  inline void pminub(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PMINUB, &dst, &src);
  }
  inline void pminub(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMINUB, &dst, &src);
  }
  inline void pmovmskb(const GPReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PMOVMSKB, &dst, &src);
  }
  inline void pmulhw(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PMULHW, &dst, &src);
  }
  inline void pmulhw(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMULHW, &dst, &src);
  }
  inline void pmulhuw(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PMULHUW, &dst, &src);
  }
  inline void pmulhuw(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMULHUW, &dst, &src);
  }
  inline void pmullw(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PMULLW, &dst, &src);
  }
  inline void pmullw(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMULLW, &dst, &src);
  }
  inline void pmuludq(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PMULUDQ, &dst, &src);
  }
  inline void pmuludq(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMULUDQ, &dst, &src);
  }
  inline void pmuludq(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PMULUDQ, &dst, &src);
  }
  inline void pmuludq(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMULUDQ, &dst, &src);
  }
  inline void por(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_POR, &dst, &src);
  }
  inline void por(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_POR, &dst, &src);
  }
  inline void pslld(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PSLLD, &dst, &src);
  }
  inline void pslld(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSLLD, &dst, &src);
  }
  inline void pslld(const XMMReg& dst, const Imm& src)
  {
    _emitInstruction(INST_PSLLD, &dst, &src);
  }
  inline void psllq(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PSLLQ, &dst, &src);
  }
  inline void psllq(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSLLQ, &dst, &src);
  }
  inline void psllq(const XMMReg& dst, const Imm& src)
  {
    _emitInstruction(INST_PSLLQ, &dst, &src);
  }
  inline void psllw(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PSLLW, &dst, &src);
  }
  inline void psllw(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSLLW, &dst, &src);
  }
  inline void psllw(const XMMReg& dst, const Imm& src)
  {
    _emitInstruction(INST_PSLLW, &dst, &src);
  }
  inline void pslldq(const XMMReg& dst, const Imm& src)
  {
    _emitInstruction(INST_PSLLDQ, &dst, &src);
  }
  inline void psrad(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PSRAD, &dst, &src);
  }
  inline void psrad(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSRAD, &dst, &src);
  }
  inline void psrad(const XMMReg& dst, const Imm& src)
  {
    _emitInstruction(INST_PSRAD, &dst, &src);
  }
  inline void psraw(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PSRAW, &dst, &src);
  }
  inline void psraw(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSRAW, &dst, &src);
  }
  inline void psraw(const XMMReg& dst, const Imm& src)
  {
    _emitInstruction(INST_PSRAW, &dst, &src);
  }
  inline void psubb(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PSUBB, &dst, &src);
  }
  inline void psubb(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSUBB, &dst, &src);
  }
  inline void psubw(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PSUBW, &dst, &src);
  }
  inline void psubw(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSUBW, &dst, &src);
  }
  inline void psubd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PSUBD, &dst, &src);
  }
  inline void psubd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSUBD, &dst, &src);
  }
  inline void psubq(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PSUBQ, &dst, &src);
  }
  inline void psubq(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSUBQ, &dst, &src);
  }
  inline void psubq(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PSUBQ, &dst, &src);
  }
  inline void psubq(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSUBQ, &dst, &src);
  }
  inline void pmaddwd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PMADDWD, &dst, &src);
  }
  inline void pmaddwd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMADDWD, &dst, &src);
  }
  inline void pshufd(const XMMReg& dst, const XMMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_PSHUFD, &dst, &src, &imm8);
  }
  inline void pshufd(const XMMReg& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_PSHUFD, &dst, &src, &imm8);
  }
  inline void pshufhw(const XMMReg& dst, const XMMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_PSHUFHW, &dst, &src, &imm8);
  }
  inline void pshufhw(const XMMReg& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_PSHUFHW, &dst, &src, &imm8);
  }
  inline void pshuflw(const XMMReg& dst, const XMMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_PSHUFLW, &dst, &src, &imm8);
  }
  inline void pshuflw(const XMMReg& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_PSHUFLW, &dst, &src, &imm8);
  }
  inline void psrld(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PSRLD, &dst, &src);
  }
  inline void psrld(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSRLD, &dst, &src);
  }
  inline void psrld(const XMMReg& dst, const Imm& src)
  {
    _emitInstruction(INST_PSRLD, &dst, &src);
  }
  inline void psrlq(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PSRLQ, &dst, &src);
  }
  inline void psrlq(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSRLQ, &dst, &src);
  }
  inline void psrlq(const XMMReg& dst, const Imm& src)
  {
    _emitInstruction(INST_PSRLQ, &dst, &src);
  }
  inline void psrldq(const XMMReg& dst, const Imm& src)
  {
    _emitInstruction(INST_PSRLDQ, &dst, &src);
  }
  inline void psrlw(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PSRLW, &dst, &src);
  }
  inline void psrlw(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSRLW, &dst, &src);
  }
  inline void psrlw(const XMMReg& dst, const Imm& src)
  {
    _emitInstruction(INST_PSRLW, &dst, &src);
  }
  inline void psubsb(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PSUBSB, &dst, &src);
  }
  inline void psubsb(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSUBSB, &dst, &src);
  }
  inline void psubsw(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PSUBSW, &dst, &src);
  }
  inline void psubsw(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSUBSW, &dst, &src);
  }
  inline void psubusb(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PSUBUSB, &dst, &src);
  }
  inline void psubusb(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSUBUSB, &dst, &src);
  }
  inline void psubusw(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PSUBUSW, &dst, &src);
  }
  inline void psubusw(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSUBUSW, &dst, &src);
  }
  inline void punpckhbw(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PUNPCKHBW, &dst, &src);
  }
  inline void punpckhbw(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PUNPCKHBW, &dst, &src);
  }
  inline void punpckhwd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PUNPCKHWD, &dst, &src);
  }
  inline void punpckhwd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PUNPCKHWD, &dst, &src);
  }
  inline void punpckhdq(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PUNPCKHDQ, &dst, &src);
  }
  inline void punpckhdq(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PUNPCKHDQ, &dst, &src);
  }
  inline void punpckhqdq(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PUNPCKHQDQ, &dst, &src);
  }
  inline void punpckhqdq(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PUNPCKHQDQ, &dst, &src);
  }
  inline void punpcklbw(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PUNPCKLBW, &dst, &src);
  }
  inline void punpcklbw(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PUNPCKLBW, &dst, &src);
  }
  inline void punpcklwd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PUNPCKLWD, &dst, &src);
  }
  inline void punpcklwd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PUNPCKLWD, &dst, &src);
  }
  inline void punpckldq(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PUNPCKLDQ, &dst, &src);
  }
  inline void punpckldq(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PUNPCKLDQ, &dst, &src);
  }
  inline void punpcklqdq(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PUNPCKLQDQ, &dst, &src);
  }
  inline void punpcklqdq(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PUNPCKLQDQ, &dst, &src);
  }
  inline void pxor(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PXOR, &dst, &src);
  }
  inline void pxor(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PXOR, &dst, &src);
  }
  inline void shufpd(const XMMReg& dst, const XMMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_SHUFPD, &dst, &src, &imm8);
  }
  inline void shufpd(const XMMReg& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_SHUFPD, &dst, &src, &imm8);
  }
  inline void sqrtpd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_SQRTPD, &dst, &src);
  }
  inline void sqrtpd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_SQRTPD, &dst, &src);
  }
  inline void sqrtsd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_SQRTSD, &dst, &src);
  }
  inline void sqrtsd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_SQRTSD, &dst, &src);
  }
  inline void subpd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_SUBPD, &dst, &src);
  }
  inline void subpd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_SUBPD, &dst, &src);
  }
  inline void subsd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_SUBSD, &dst, &src);
  }
  inline void subsd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_SUBSD, &dst, &src);
  }
  inline void ucomisd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_UCOMISD, &dst, &src);
  }
  inline void ucomisd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_UCOMISD, &dst, &src);
  }
  inline void unpckhpd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_UNPCKHPD, &dst, &src);
  }
  inline void unpckhpd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_UNPCKHPD, &dst, &src);
  }
  inline void unpcklpd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_UNPCKLPD, &dst, &src);
  }
  inline void unpcklpd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_UNPCKLPD, &dst, &src);
  }
  inline void xorpd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_XORPD, &dst, &src);
  }
  inline void xorpd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_XORPD, &dst, &src);
  }
  inline void addsubpd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_ADDSUBPD, &dst, &src);
  }
  inline void addsubpd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_ADDSUBPD, &dst, &src);
  }
  inline void addsubps(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_ADDSUBPS, &dst, &src);
  }
  inline void addsubps(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_ADDSUBPS, &dst, &src);
  }
  inline void fisttp(const Mem& dst)
  {
    _emitInstruction(INST_FISTTP, &dst);
  }
  inline void haddpd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_HADDPD, &dst, &src);
  }
  inline void haddpd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_HADDPD, &dst, &src);
  }
  inline void haddps(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_HADDPS, &dst, &src);
  }
  inline void haddps(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_HADDPS, &dst, &src);
  }
  inline void hsubpd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_HSUBPD, &dst, &src);
  }
  inline void hsubpd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_HSUBPD, &dst, &src);
  }
  inline void hsubps(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_HSUBPS, &dst, &src);
  }
  inline void hsubps(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_HSUBPS, &dst, &src);
  }
  inline void lddqu(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_LDDQU, &dst, &src);
  }
  inline void monitor()
  {
    _emitInstruction(INST_MONITOR);
  }
  inline void movddup(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MOVDDUP, &dst, &src);
  }
  inline void movddup(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVDDUP, &dst, &src);
  }
  inline void movshdup(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MOVSHDUP, &dst, &src);
  }
  inline void movshdup(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVSHDUP, &dst, &src);
  }
  inline void movsldup(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_MOVSLDUP, &dst, &src);
  }
  inline void movsldup(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVSLDUP, &dst, &src);
  }
  inline void mwait()
  {
    _emitInstruction(INST_MWAIT);
  }
  inline void psignb(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PSIGNB, &dst, &src);
  }
  inline void psignb(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSIGNB, &dst, &src);
  }
  inline void psignb(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PSIGNB, &dst, &src);
  }
  inline void psignb(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSIGNB, &dst, &src);
  }
  inline void psignw(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PSIGNW, &dst, &src);
  }
  inline void psignw(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSIGNW, &dst, &src);
  }
  inline void psignw(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PSIGNW, &dst, &src);
  }
  inline void psignw(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSIGNW, &dst, &src);
  }
  inline void psignd(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PSIGND, &dst, &src);
  }
  inline void psignd(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSIGND, &dst, &src);
  }
  inline void psignd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PSIGND, &dst, &src);
  }
  inline void psignd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSIGND, &dst, &src);
  }
  inline void phaddw(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PHADDW, &dst, &src);
  }
  inline void phaddw(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PHADDW, &dst, &src);
  }
  inline void phaddw(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PHADDW, &dst, &src);
  }
  inline void phaddw(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PHADDW, &dst, &src);
  }
  inline void phaddd(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PHADDD, &dst, &src);
  }
  inline void phaddd(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PHADDD, &dst, &src);
  }
  inline void phaddd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PHADDD, &dst, &src);
  }
  inline void phaddd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PHADDD, &dst, &src);
  }
  inline void phaddsw(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PHADDSW, &dst, &src);
  }
  inline void phaddsw(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PHADDSW, &dst, &src);
  }
  inline void phaddsw(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PHADDSW, &dst, &src);
  }
  inline void phaddsw(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PHADDSW, &dst, &src);
  }
  inline void phsubw(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PHSUBW, &dst, &src);
  }
  inline void phsubw(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PHSUBW, &dst, &src);
  }
  inline void phsubw(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PHSUBW, &dst, &src);
  }
  inline void phsubw(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PHSUBW, &dst, &src);
  }
  inline void phsubd(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PHSUBD, &dst, &src);
  }
  inline void phsubd(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PHSUBD, &dst, &src);
  }
  inline void phsubd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PHSUBD, &dst, &src);
  }
  inline void phsubd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PHSUBD, &dst, &src);
  }
  inline void phsubsw(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PHSUBSW, &dst, &src);
  }
  inline void phsubsw(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PHSUBSW, &dst, &src);
  }
  inline void phsubsw(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PHSUBSW, &dst, &src);
  }
  inline void phsubsw(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PHSUBSW, &dst, &src);
  }
  inline void pmaddubsw(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PMADDUBSW, &dst, &src);
  }
  inline void pmaddubsw(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMADDUBSW, &dst, &src);
  }
  inline void pmaddubsw(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PMADDUBSW, &dst, &src);
  }
  inline void pmaddubsw(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMADDUBSW, &dst, &src);
  }
  inline void pabsb(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PABSB, &dst, &src);
  }
  inline void pabsb(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PABSB, &dst, &src);
  }
  inline void pabsb(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PABSB, &dst, &src);
  }
  inline void pabsb(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PABSB, &dst, &src);
  }
  inline void pabsw(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PABSW, &dst, &src);
  }
  inline void pabsw(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PABSW, &dst, &src);
  }
  inline void pabsw(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PABSW, &dst, &src);
  }
  inline void pabsw(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PABSW, &dst, &src);
  }
  inline void pabsd(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PABSD, &dst, &src);
  }
  inline void pabsd(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PABSD, &dst, &src);
  }
  inline void pabsd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PABSD, &dst, &src);
  }
  inline void pabsd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PABSD, &dst, &src);
  }
  inline void pmulhrsw(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PMULHRSW, &dst, &src);
  }
  inline void pmulhrsw(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMULHRSW, &dst, &src);
  }
  inline void pmulhrsw(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PMULHRSW, &dst, &src);
  }
  inline void pmulhrsw(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMULHRSW, &dst, &src);
  }
  inline void pshufb(const MMReg& dst, const MMReg& src)
  {
    _emitInstruction(INST_PSHUFB, &dst, &src);
  }
  inline void pshufb(const MMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSHUFB, &dst, &src);
  }
  inline void pshufb(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PSHUFB, &dst, &src);
  }
  inline void pshufb(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PSHUFB, &dst, &src);
  }
  inline void palignr(const MMReg& dst, const MMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_PALIGNR, &dst, &src, &imm8);
  }
  inline void palignr(const MMReg& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_PALIGNR, &dst, &src, &imm8);
  }
  inline void palignr(const XMMReg& dst, const XMMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_PALIGNR, &dst, &src, &imm8);
  }
  inline void palignr(const XMMReg& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_PALIGNR, &dst, &src, &imm8);
  }
  inline void blendpd(const XMMReg& dst, const XMMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_BLENDPD, &dst, &src, &imm8);
  }
  inline void blendpd(const XMMReg& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_BLENDPD, &dst, &src, &imm8);
  }
  inline void blendps(const XMMReg& dst, const XMMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_BLENDPS, &dst, &src, &imm8);
  }
  inline void blendps(const XMMReg& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_BLENDPS, &dst, &src, &imm8);
  }
  inline void blendvpd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_BLENDVPD, &dst, &src);
  }
  inline void blendvpd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_BLENDVPD, &dst, &src);
  }
  inline void blendvps(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_BLENDVPS, &dst, &src);
  }
  inline void blendvps(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_BLENDVPS, &dst, &src);
  }
  inline void dppd(const XMMReg& dst, const XMMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_DPPD, &dst, &src, &imm8);
  }
  inline void dppd(const XMMReg& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_DPPD, &dst, &src, &imm8);
  }
  inline void dpps(const XMMReg& dst, const XMMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_DPPS, &dst, &src, &imm8);
  }
  inline void dpps(const XMMReg& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_DPPS, &dst, &src, &imm8);
  }
  inline void extractps(const XMMReg& dst, const XMMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_EXTRACTPS, &dst, &src, &imm8);
  }
  inline void extractps(const XMMReg& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_EXTRACTPS, &dst, &src, &imm8);
  }
  inline void movntdqa(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVNTDQA, &dst, &src);
  }
  inline void mpsadbw(const XMMReg& dst, const XMMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_MPSADBW, &dst, &src, &imm8);
  }
  inline void mpsadbw(const XMMReg& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_MPSADBW, &dst, &src, &imm8);
  }
  inline void packusdw(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PACKUSDW, &dst, &src);
  }
  inline void packusdw(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PACKUSDW, &dst, &src);
  }
  inline void pblendvb(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PBLENDVB, &dst, &src);
  }
  inline void pblendvb(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PBLENDVB, &dst, &src);
  }
  inline void pblendw(const XMMReg& dst, const XMMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_PBLENDW, &dst, &src, &imm8);
  }
  inline void pblendw(const XMMReg& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_PBLENDW, &dst, &src, &imm8);
  }
  inline void pcmpeqq(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PCMPEQQ, &dst, &src);
  }
  inline void pcmpeqq(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PCMPEQQ, &dst, &src);
  }
  inline void pextrb(const GPReg& dst, const XMMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_PEXTRB, &dst, &src, &imm8);
  }
  inline void pextrb(const Mem& dst, const XMMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_PEXTRB, &dst, &src, &imm8);
  }
  inline void pextrd(const GPReg& dst, const XMMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_PEXTRD, &dst, &src, &imm8);
  }
  inline void pextrd(const Mem& dst, const XMMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_PEXTRD, &dst, &src, &imm8);
  }
  inline void pextrq(const GPReg& dst, const XMMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_PEXTRQ, &dst, &src, &imm8);
  }
  inline void pextrq(const Mem& dst, const XMMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_PEXTRQ, &dst, &src, &imm8);
  }
  inline void pextrw(const GPReg& dst, const XMMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_PEXTRW, &dst, &src, &imm8);
  }
  inline void pextrw(const Mem& dst, const XMMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_PEXTRW, &dst, &src, &imm8);
  }
  inline void phminposuw(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PHMINPOSUW, &dst, &src);
  }
  inline void phminposuw(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PHMINPOSUW, &dst, &src);
  }
  inline void pinsrb(const XMMReg& dst, const GPReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_PINSRB, &dst, &src, &imm8);
  }
  inline void pinsrb(const XMMReg& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_PINSRB, &dst, &src, &imm8);
  }
  inline void pinsrd(const XMMReg& dst, const GPReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_PINSRD, &dst, &src, &imm8);
  }
  inline void pinsrd(const XMMReg& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_PINSRD, &dst, &src, &imm8);
  }
  inline void pinsrq(const XMMReg& dst, const GPReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_PINSRQ, &dst, &src, &imm8);
  }
  inline void pinsrq(const XMMReg& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_PINSRQ, &dst, &src, &imm8);
  }
  inline void pinsrw(const XMMReg& dst, const GPReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_PINSRW, &dst, &src, &imm8);
  }
  inline void pinsrw(const XMMReg& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_PINSRW, &dst, &src, &imm8);
  }
  inline void pmaxuw(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PMAXUW, &dst, &src);
  }
  inline void pmaxuw(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMAXUW, &dst, &src);
  }
  inline void pmaxsb(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PMAXSB, &dst, &src);
  }
  inline void pmaxsb(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMAXSB, &dst, &src);
  }
  inline void pmaxsd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PMAXSD, &dst, &src);
  }
  inline void pmaxsd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMAXSD, &dst, &src);
  }
  inline void pmaxud(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PMAXUD, &dst, &src);
  }
  inline void pmaxud(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMAXUD, &dst, &src);
  }
  inline void pminsb(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PMINSB, &dst, &src);
  }
  inline void pminsb(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMINSB, &dst, &src);
  }
  inline void pminuw(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PMINUW, &dst, &src);
  }
  inline void pminuw(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMINUW, &dst, &src);
  }
  inline void pminud(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PMINUD, &dst, &src);
  }
  inline void pminud(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMINUD, &dst, &src);
  }
  inline void pminsd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PMINSD, &dst, &src);
  }
  inline void pminsd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMINSD, &dst, &src);
  }
  inline void pmovsxbw(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PMOVSXBW, &dst, &src);
  }
  inline void pmovsxbw(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMOVSXBW, &dst, &src);
  }
  inline void pmovsxbd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PMOVSXBD, &dst, &src);
  }
  inline void pmovsxbd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMOVSXBD, &dst, &src);
  }
  inline void pmovsxbq(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PMOVSXBQ, &dst, &src);
  }
  inline void pmovsxbq(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMOVSXBQ, &dst, &src);
  }
  inline void pmovsxwd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PMOVSXWD, &dst, &src);
  }
  inline void pmovsxwd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMOVSXWD, &dst, &src);
  }
  inline void pmovsxwq(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PMOVSXWQ, &dst, &src);
  }
  inline void pmovsxwq(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMOVSXWQ, &dst, &src);
  }
  inline void pmovsxdq(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PMOVSXDQ, &dst, &src);
  }
  inline void pmovsxdq(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMOVSXDQ, &dst, &src);
  }
  inline void pmovzxbw(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PMOVZXBW, &dst, &src);
  }
  inline void pmovzxbw(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMOVZXBW, &dst, &src);
  }
  inline void pmovzxbd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PMOVZXBD, &dst, &src);
  }
  inline void pmovzxbd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMOVZXBD, &dst, &src);
  }
  inline void pmovzxbq(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PMOVZXBQ, &dst, &src);
  }
  inline void pmovzxbq(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMOVZXBQ, &dst, &src);
  }
  inline void pmovzxwd(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PMOVZXWD, &dst, &src);
  }
  inline void pmovzxwd(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMOVZXWD, &dst, &src);
  }
  inline void pmovzxwq(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PMOVZXWQ, &dst, &src);
  }
  inline void pmovzxwq(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMOVZXWQ, &dst, &src);
  }
  inline void pmovzxdq(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PMOVZXDQ, &dst, &src);
  }
  inline void pmovzxdq(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMOVZXDQ, &dst, &src);
  }
  inline void pmuldq(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PMULDQ, &dst, &src);
  }
  inline void pmuldq(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMULDQ, &dst, &src);
  }
  inline void pmulld(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PMULLD, &dst, &src);
  }
  inline void pmulld(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PMULLD, &dst, &src);
  }
  inline void ptest(const XMMReg& op1, const XMMReg& op2)
  {
    _emitInstruction(INST_PTEST, &op1, &op2);
  }
  inline void ptest(const XMMReg& op1, const Mem& op2)
  {
    _emitInstruction(INST_PTEST, &op1, &op2);
  }
  inline void roundps(const XMMReg& dst, const XMMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_ROUNDPS, &dst, &src, &imm8);
  }
  inline void roundps(const XMMReg& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_ROUNDPS, &dst, &src, &imm8);
  }
  inline void roundss(const XMMReg& dst, const XMMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_ROUNDSS, &dst, &src, &imm8);
  }
  inline void roundss(const XMMReg& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_ROUNDSS, &dst, &src, &imm8);
  }
  inline void roundpd(const XMMReg& dst, const XMMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_ROUNDPD, &dst, &src, &imm8);
  }
  inline void roundpd(const XMMReg& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_ROUNDPD, &dst, &src, &imm8);
  }
  inline void roundsd(const XMMReg& dst, const XMMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_ROUNDSD, &dst, &src, &imm8);
  }
  inline void roundsd(const XMMReg& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_ROUNDSD, &dst, &src, &imm8);
  }
  inline void crc32(const GPReg& dst, const GPReg& src)
  {
    ASMJIT_ASSERT(dst.isRegType(REG_TYPE_GPD) || dst.isRegType(REG_TYPE_GPQ));
    _emitInstruction(INST_CRC32, &dst, &src);
  }
  inline void crc32(const GPReg& dst, const Mem& src)
  {
    ASMJIT_ASSERT(dst.isRegType(REG_TYPE_GPD) || dst.isRegType(REG_TYPE_GPQ));
    _emitInstruction(INST_CRC32, &dst, &src);
  }
  inline void pcmpestri(const XMMReg& dst, const XMMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_PCMPESTRI, &dst, &src, &imm8);
  }
  inline void pcmpestri(const XMMReg& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_PCMPESTRI, &dst, &src, &imm8);
  }
  inline void pcmpestrm(const XMMReg& dst, const XMMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_PCMPESTRM, &dst, &src, &imm8);
  }
  inline void pcmpestrm(const XMMReg& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_PCMPESTRM, &dst, &src, &imm8);
  }
  inline void pcmpistri(const XMMReg& dst, const XMMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_PCMPISTRI, &dst, &src, &imm8);
  }
  inline void pcmpistri(const XMMReg& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_PCMPISTRI, &dst, &src, &imm8);
  }
  inline void pcmpistrm(const XMMReg& dst, const XMMReg& src, const Imm& imm8)
  {
    _emitInstruction(INST_PCMPISTRM, &dst, &src, &imm8);
  }
  inline void pcmpistrm(const XMMReg& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_PCMPISTRM, &dst, &src, &imm8);
  }
  inline void pcmpgtq(const XMMReg& dst, const XMMReg& src)
  {
    _emitInstruction(INST_PCMPGTQ, &dst, &src);
  }
  inline void pcmpgtq(const XMMReg& dst, const Mem& src)
  {
    _emitInstruction(INST_PCMPGTQ, &dst, &src);
  }
  inline void popcnt(const GPReg& dst, const GPReg& src)
  {
    ASMJIT_ASSERT(!dst.isGPB());
    ASMJIT_ASSERT(src.getRegType() == dst.getRegType());
    _emitInstruction(INST_POPCNT, &dst, &src);
  }
  inline void popcnt(const GPReg& dst, const Mem& src)
  {
    ASMJIT_ASSERT(!dst.isGPB());
    _emitInstruction(INST_POPCNT, &dst, &src);
  }
  inline void amd_prefetch(const Mem& mem)
  {
    _emitInstruction(INST_AMD_PREFETCH, &mem);
  }
  inline void amd_prefetchw(const Mem& mem)
  {
    _emitInstruction(INST_AMD_PREFETCHW, &mem);
  }
  inline void movbe(const GPReg& dst, const Mem& src)
  {
    ASMJIT_ASSERT(!dst.isGPB());
    _emitInstruction(INST_MOVBE, &dst, &src);
  }
  inline void movbe(const Mem& dst, const GPReg& src)
  {
    ASMJIT_ASSERT(!src.isGPB());
    _emitInstruction(INST_MOVBE, &dst, &src);
  }
  inline void lock()
  {
    _emitOptions |= EMIT_OPTION_LOCK_PREFIX;
  }
  inline void rex()
  {
    _emitOptions |= EMIT_OPTION_REX_PREFIX;
  }
};
struct ASMJIT_API Assembler : public AssemblerIntrinsics
{
  Assembler(CodeGenerator* codeGenerator = NULL) ASMJIT_NOTHROW;
  virtual ~Assembler() ASMJIT_NOTHROW;
};

struct BaseReg;
struct BaseVar;
struct Compiler;
struct GPReg;
struct GPVar;
struct Imm;
struct Label;
struct Mem;
struct MMReg;
struct MMVar;
struct Operand;
struct X87Reg;
struct X87Var;
struct XMMReg;
struct XMMVar;
struct Operand;
ASMJIT_VAR const GPReg no_reg;
ASMJIT_VAR const GPReg al;
ASMJIT_VAR const GPReg cl;
ASMJIT_VAR const GPReg dl;
ASMJIT_VAR const GPReg bl;
ASMJIT_VAR const GPReg ah;
ASMJIT_VAR const GPReg ch;
ASMJIT_VAR const GPReg dh;
ASMJIT_VAR const GPReg bh;
ASMJIT_VAR const GPReg ax;
ASMJIT_VAR const GPReg cx;
ASMJIT_VAR const GPReg dx;
ASMJIT_VAR const GPReg bx;
ASMJIT_VAR const GPReg sp;
ASMJIT_VAR const GPReg bp;
ASMJIT_VAR const GPReg si;
ASMJIT_VAR const GPReg di;
ASMJIT_VAR const GPReg eax;
ASMJIT_VAR const GPReg ecx;
ASMJIT_VAR const GPReg edx;
ASMJIT_VAR const GPReg ebx;
ASMJIT_VAR const GPReg esp;
ASMJIT_VAR const GPReg ebp;
ASMJIT_VAR const GPReg esi;
ASMJIT_VAR const GPReg edi;
ASMJIT_VAR const GPReg nax;
ASMJIT_VAR const GPReg ncx;
ASMJIT_VAR const GPReg ndx;
ASMJIT_VAR const GPReg nbx;
ASMJIT_VAR const GPReg nsp;
ASMJIT_VAR const GPReg nbp;
ASMJIT_VAR const GPReg nsi;
ASMJIT_VAR const GPReg ndi;
ASMJIT_VAR const MMReg mm0;
ASMJIT_VAR const MMReg mm1;
ASMJIT_VAR const MMReg mm2;
ASMJIT_VAR const MMReg mm3;
ASMJIT_VAR const MMReg mm4;
ASMJIT_VAR const MMReg mm5;
ASMJIT_VAR const MMReg mm6;
ASMJIT_VAR const MMReg mm7;
ASMJIT_VAR const XMMReg xmm0;
ASMJIT_VAR const XMMReg xmm1;
ASMJIT_VAR const XMMReg xmm2;
ASMJIT_VAR const XMMReg xmm3;
ASMJIT_VAR const XMMReg xmm4;
ASMJIT_VAR const XMMReg xmm5;
ASMJIT_VAR const XMMReg xmm6;
ASMJIT_VAR const XMMReg xmm7;
ASMJIT_VAR const SegmentReg cs;
ASMJIT_VAR const SegmentReg ss;
ASMJIT_VAR const SegmentReg ds;
ASMJIT_VAR const SegmentReg es;
ASMJIT_VAR const SegmentReg fs;
ASMJIT_VAR const SegmentReg gs;

