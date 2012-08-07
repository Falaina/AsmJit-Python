/* This should only be included from AsmJit.i */
struct EFunction;
struct CodeGenerator;
struct CompilerIntrinsics;

struct FunctionDefinition
{
  inline const uint32_t* getArguments() const
  {
    return _arguments;
  }
  inline uint32_t getArgumentsCount() const
  {
    return _argumentsCount;
  }

  inline uint32_t getArgument(uint32_t id) const
  {
    ASMJIT_ASSERT(id < _argumentsCount);
    return _arguments[id];
  }
  inline uint32_t getReturnValue() const
  {
    return _returnValue;
  }
protected:
    inline void _setDefinition(const uint32_t* arguments, uint32_t argumentsCount, uint32_t returnValue);
};

template<typename RET>
struct FunctionBuilder0 : public FunctionDefinition
{
  inline FunctionBuilder0()
  {
    _setDefinition(NULL, 0, TypeToId<RET>::Id);
  }
};

%template(UIntFunctionBuilder0) FunctionBuilder0<uint32_t>;


struct ASMJIT_API CompilerCore
{
  CompilerCore(CodeGenerator* codeGenerator) ASMJIT_NOTHROW;
  virtual ~CompilerCore() ASMJIT_NOTHROW;
  inline EFunction* newFunction(uint32_t cconv, const FunctionDefinition& def) ASMJIT_NOTHROW
  {
    return newFunction_(
      cconv,
      def.getArguments(),
      def.getArgumentsCount(),
      def.getReturnValue());
  }
  EFunction* newFunction_(
    uint32_t cconv,
    const uint32_t* arguments,
    uint32_t argumentsCount,
    uint32_t returnValue) ASMJIT_NOTHROW;
  inline EFunction* getFunction() const ASMJIT_NOTHROW { return _function; }
  EFunction* endFunction() ASMJIT_NOTHROW;
  GPVar newGP(uint32_t variableType = VARIABLE_TYPE_GPN, const char* name = ((void*)0)) ASMJIT_NOTHROW;
  GPVar argGP(uint32_t index) ASMJIT_NOTHROW;
};

struct ASMJIT_HIDDEN CompilerIntrinsics : public CompilerCore
{
  inline CompilerIntrinsics(CodeGenerator* codeGenerator) ASMJIT_NOTHROW :
    CompilerCore(codeGenerator)
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
  template<typename T>
  inline void dstruct(const T& x) ASMJIT_NOTHROW { embed(&x, sizeof(T)); }
  inline void emit(uint32_t code) ASMJIT_NOTHROW
  {
    _emitInstruction(code);
  }
  inline void emit(uint32_t code, const Operand& o0) ASMJIT_NOTHROW
  {
    _emitInstruction(code, &o0);
  }
  inline void emit(uint32_t code, const Operand& o0, const Operand& o1) ASMJIT_NOTHROW
  {
    _emitInstruction(code, &o0, &o1);
  }
  inline void emit(uint32_t code, const Operand& o0, const Operand& o1, const Operand& o2) ASMJIT_NOTHROW
  {
    _emitInstruction(code, &o0, &o1, &o2);
  }
  inline void adc(const GPVar& dst, const GPVar& src)
  {
    _emitInstruction(INST_ADC, &dst, &src);
  }
  inline void adc(const GPVar& dst, const Mem& src)
  {
    _emitInstruction(INST_ADC, &dst, &src);
  }
  inline void adc(const GPVar& dst, const Imm& src)
  {
    _emitInstruction(INST_ADC, &dst, &src);
  }
  inline void adc(const Mem& dst, const GPVar& src)
  {
    _emitInstruction(INST_ADC, &dst, &src);
  }
  inline void adc(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_ADC, &dst, &src);
  }
  inline void add(const GPVar& dst, const GPVar& src)
  {
    _emitInstruction(INST_ADD, &dst, &src);
  }
  inline void add(const GPVar& dst, const Mem& src)
  {
    _emitInstruction(INST_ADD, &dst, &src);
  }
  inline void add(const GPVar& dst, const Imm& src)
  {
    _emitInstruction(INST_ADD, &dst, &src);
  }
  inline void add(const Mem& dst, const GPVar& src)
  {
    _emitInstruction(INST_ADD, &dst, &src);
  }
  inline void add(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_ADD, &dst, &src);
  }
  inline void and_(const GPVar& dst, const GPVar& src)
  {
    _emitInstruction(INST_AND, &dst, &src);
  }
  inline void and_(const GPVar& dst, const Mem& src)
  {
    _emitInstruction(INST_AND, &dst, &src);
  }
  inline void and_(const GPVar& dst, const Imm& src)
  {
    _emitInstruction(INST_AND, &dst, &src);
  }
  inline void and_(const Mem& dst, const GPVar& src)
  {
    _emitInstruction(INST_AND, &dst, &src);
  }
  inline void and_(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_AND, &dst, &src);
  }
  inline void bsf(const GPVar& dst, const GPVar& src)
  {
    ASMJIT_ASSERT(!dst.isGPB());
    _emitInstruction(INST_BSF, &dst, &src);
  }
  inline void bsf(const GPVar& dst, const Mem& src)
  {
    ASMJIT_ASSERT(!dst.isGPB());
    _emitInstruction(INST_BSF, &dst, &src);
  }
  inline void bsr(const GPVar& dst, const GPVar& src)
  {
    ASMJIT_ASSERT(!dst.isGPB());
    _emitInstruction(INST_BSR, &dst, &src);
  }
  inline void bsr(const GPVar& dst, const Mem& src)
  {
    ASMJIT_ASSERT(!dst.isGPB());
    _emitInstruction(INST_BSR, &dst, &src);
  }
  inline void bswap(const GPVar& dst)
  {
    _emitInstruction(INST_BSWAP, &dst);
  }
  inline void bt(const GPVar& dst, const GPVar& src)
  {
    _emitInstruction(INST_BT, &dst, &src);
  }
  inline void bt(const GPVar& dst, const Imm& src)
  {
    _emitInstruction(INST_BT, &dst, &src);
  }
  inline void bt(const Mem& dst, const GPVar& src)
  {
    _emitInstruction(INST_BT, &dst, &src);
  }
  inline void bt(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_BT, &dst, &src);
  }
  inline void btc(const GPVar& dst, const GPVar& src)
  {
    _emitInstruction(INST_BTC, &dst, &src);
  }
  inline void btc(const GPVar& dst, const Imm& src)
  {
    _emitInstruction(INST_BTC, &dst, &src);
  }
  inline void btc(const Mem& dst, const GPVar& src)
  {
    _emitInstruction(INST_BTC, &dst, &src);
  }
  inline void btc(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_BTC, &dst, &src);
  }
  inline void btr(const GPVar& dst, const GPVar& src)
  {
    _emitInstruction(INST_BTR, &dst, &src);
  }
  inline void btr(const GPVar& dst, const Imm& src)
  {
    _emitInstruction(INST_BTR, &dst, &src);
  }
  inline void btr(const Mem& dst, const GPVar& src)
  {
    _emitInstruction(INST_BTR, &dst, &src);
  }
  inline void btr(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_BTR, &dst, &src);
  }
  inline void bts(const GPVar& dst, const GPVar& src)
  {
    _emitInstruction(INST_BTS, &dst, &src);
  }
  inline void bts(const GPVar& dst, const Imm& src)
  {
    _emitInstruction(INST_BTS, &dst, &src);
  }
  inline void bts(const Mem& dst, const GPVar& src)
  {
    _emitInstruction(INST_BTS, &dst, &src);
  }
  inline void bts(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_BTS, &dst, &src);
  }
  inline ECall* call(const GPVar& dst)
  {
    return _emitCall(&dst);
  }
  inline ECall* call(const Mem& dst)
  {
    return _emitCall(&dst);
  }
  inline ECall* call(const Imm& dst)
  {
    return _emitCall(&dst);
  }
  inline ECall* call(void* dst)
  {
    Imm imm((sysint_t)dst);
    return _emitCall(&imm);
  }
  inline ECall* call(const Label& label)
  {
    return _emitCall(&label);
  }
  inline void cbw(const GPVar& dst)
  {
    _emitInstruction(INST_CBW, &dst);
  }
  inline void cwde(const GPVar& dst)
  {
    _emitInstruction(INST_CWDE, &dst);
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
  inline void cmov(CONDITION cc, const GPVar& dst, const GPVar& src)
  {
    _emitInstruction(ConditionToInstruction::toCMovCC(cc), &dst, &src);
  }
  inline void cmov(CONDITION cc, const GPVar& dst, const Mem& src)
  {
    _emitInstruction(ConditionToInstruction::toCMovCC(cc), &dst, &src);
  }
  inline void cmova (const GPVar& dst, const GPVar& src) { _emitInstruction(INST_CMOVA , &dst, &src); }
  inline void cmova (const GPVar& dst, const Mem& src) { _emitInstruction(INST_CMOVA , &dst, &src); }
  inline void cmovae (const GPVar& dst, const GPVar& src) { _emitInstruction(INST_CMOVAE , &dst, &src); }
  inline void cmovae (const GPVar& dst, const Mem& src) { _emitInstruction(INST_CMOVAE , &dst, &src); }
  inline void cmovb (const GPVar& dst, const GPVar& src) { _emitInstruction(INST_CMOVB , &dst, &src); }
  inline void cmovb (const GPVar& dst, const Mem& src) { _emitInstruction(INST_CMOVB , &dst, &src); }
  inline void cmovbe (const GPVar& dst, const GPVar& src) { _emitInstruction(INST_CMOVBE , &dst, &src); }
  inline void cmovbe (const GPVar& dst, const Mem& src) { _emitInstruction(INST_CMOVBE , &dst, &src); }
  inline void cmovc (const GPVar& dst, const GPVar& src) { _emitInstruction(INST_CMOVC , &dst, &src); }
  inline void cmovc (const GPVar& dst, const Mem& src) { _emitInstruction(INST_CMOVC , &dst, &src); }
  inline void cmove (const GPVar& dst, const GPVar& src) { _emitInstruction(INST_CMOVE , &dst, &src); }
  inline void cmove (const GPVar& dst, const Mem& src) { _emitInstruction(INST_CMOVE , &dst, &src); }
  inline void cmovg (const GPVar& dst, const GPVar& src) { _emitInstruction(INST_CMOVG , &dst, &src); }
  inline void cmovg (const GPVar& dst, const Mem& src) { _emitInstruction(INST_CMOVG , &dst, &src); }
  inline void cmovge (const GPVar& dst, const GPVar& src) { _emitInstruction(INST_CMOVGE , &dst, &src); }
  inline void cmovge (const GPVar& dst, const Mem& src) { _emitInstruction(INST_CMOVGE , &dst, &src); }
  inline void cmovl (const GPVar& dst, const GPVar& src) { _emitInstruction(INST_CMOVL , &dst, &src); }
  inline void cmovl (const GPVar& dst, const Mem& src) { _emitInstruction(INST_CMOVL , &dst, &src); }
  inline void cmovle (const GPVar& dst, const GPVar& src) { _emitInstruction(INST_CMOVLE , &dst, &src); }
  inline void cmovle (const GPVar& dst, const Mem& src) { _emitInstruction(INST_CMOVLE , &dst, &src); }
  inline void cmovna (const GPVar& dst, const GPVar& src) { _emitInstruction(INST_CMOVNA , &dst, &src); }
  inline void cmovna (const GPVar& dst, const Mem& src) { _emitInstruction(INST_CMOVNA , &dst, &src); }
  inline void cmovnae(const GPVar& dst, const GPVar& src) { _emitInstruction(INST_CMOVNAE, &dst, &src); }
  inline void cmovnae(const GPVar& dst, const Mem& src) { _emitInstruction(INST_CMOVNAE, &dst, &src); }
  inline void cmovnb (const GPVar& dst, const GPVar& src) { _emitInstruction(INST_CMOVNB , &dst, &src); }
  inline void cmovnb (const GPVar& dst, const Mem& src) { _emitInstruction(INST_CMOVNB , &dst, &src); }
  inline void cmovnbe(const GPVar& dst, const GPVar& src) { _emitInstruction(INST_CMOVNBE, &dst, &src); }
  inline void cmovnbe(const GPVar& dst, const Mem& src) { _emitInstruction(INST_CMOVNBE, &dst, &src); }
  inline void cmovnc (const GPVar& dst, const GPVar& src) { _emitInstruction(INST_CMOVNC , &dst, &src); }
  inline void cmovnc (const GPVar& dst, const Mem& src) { _emitInstruction(INST_CMOVNC , &dst, &src); }
  inline void cmovne (const GPVar& dst, const GPVar& src) { _emitInstruction(INST_CMOVNE , &dst, &src); }
  inline void cmovne (const GPVar& dst, const Mem& src) { _emitInstruction(INST_CMOVNE , &dst, &src); }
  inline void cmovng (const GPVar& dst, const GPVar& src) { _emitInstruction(INST_CMOVNG , &dst, &src); }
  inline void cmovng (const GPVar& dst, const Mem& src) { _emitInstruction(INST_CMOVNG , &dst, &src); }
  inline void cmovnge(const GPVar& dst, const GPVar& src) { _emitInstruction(INST_CMOVNGE, &dst, &src); }
  inline void cmovnge(const GPVar& dst, const Mem& src) { _emitInstruction(INST_CMOVNGE, &dst, &src); }
  inline void cmovnl (const GPVar& dst, const GPVar& src) { _emitInstruction(INST_CMOVNL , &dst, &src); }
  inline void cmovnl (const GPVar& dst, const Mem& src) { _emitInstruction(INST_CMOVNL , &dst, &src); }
  inline void cmovnle(const GPVar& dst, const GPVar& src) { _emitInstruction(INST_CMOVNLE, &dst, &src); }
  inline void cmovnle(const GPVar& dst, const Mem& src) { _emitInstruction(INST_CMOVNLE, &dst, &src); }
  inline void cmovno (const GPVar& dst, const GPVar& src) { _emitInstruction(INST_CMOVNO , &dst, &src); }
  inline void cmovno (const GPVar& dst, const Mem& src) { _emitInstruction(INST_CMOVNO , &dst, &src); }
  inline void cmovnp (const GPVar& dst, const GPVar& src) { _emitInstruction(INST_CMOVNP , &dst, &src); }
  inline void cmovnp (const GPVar& dst, const Mem& src) { _emitInstruction(INST_CMOVNP , &dst, &src); }
  inline void cmovns (const GPVar& dst, const GPVar& src) { _emitInstruction(INST_CMOVNS , &dst, &src); }
  inline void cmovns (const GPVar& dst, const Mem& src) { _emitInstruction(INST_CMOVNS , &dst, &src); }
  inline void cmovnz (const GPVar& dst, const GPVar& src) { _emitInstruction(INST_CMOVNZ , &dst, &src); }
  inline void cmovnz (const GPVar& dst, const Mem& src) { _emitInstruction(INST_CMOVNZ , &dst, &src); }
  inline void cmovo (const GPVar& dst, const GPVar& src) { _emitInstruction(INST_CMOVO , &dst, &src); }
  inline void cmovo (const GPVar& dst, const Mem& src) { _emitInstruction(INST_CMOVO , &dst, &src); }
  inline void cmovp (const GPVar& dst, const GPVar& src) { _emitInstruction(INST_CMOVP , &dst, &src); }
  inline void cmovp (const GPVar& dst, const Mem& src) { _emitInstruction(INST_CMOVP , &dst, &src); }
  inline void cmovpe (const GPVar& dst, const GPVar& src) { _emitInstruction(INST_CMOVPE , &dst, &src); }
  inline void cmovpe (const GPVar& dst, const Mem& src) { _emitInstruction(INST_CMOVPE , &dst, &src); }
  inline void cmovpo (const GPVar& dst, const GPVar& src) { _emitInstruction(INST_CMOVPO , &dst, &src); }
  inline void cmovpo (const GPVar& dst, const Mem& src) { _emitInstruction(INST_CMOVPO , &dst, &src); }
  inline void cmovs (const GPVar& dst, const GPVar& src) { _emitInstruction(INST_CMOVS , &dst, &src); }
  inline void cmovs (const GPVar& dst, const Mem& src) { _emitInstruction(INST_CMOVS , &dst, &src); }
  inline void cmovz (const GPVar& dst, const GPVar& src) { _emitInstruction(INST_CMOVZ , &dst, &src); }
  inline void cmovz (const GPVar& dst, const Mem& src) { _emitInstruction(INST_CMOVZ , &dst, &src); }
  inline void cmp(const GPVar& dst, const GPVar& src)
  {
    _emitInstruction(INST_CMP, &dst, &src);
  }
  inline void cmp(const GPVar& dst, const Mem& src)
  {
    _emitInstruction(INST_CMP, &dst, &src);
  }
  inline void cmp(const GPVar& dst, const Imm& src)
  {
    _emitInstruction(INST_CMP, &dst, &src);
  }
  inline void cmp(const Mem& dst, const GPVar& src)
  {
    _emitInstruction(INST_CMP, &dst, &src);
  }
  inline void cmp(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_CMP, &dst, &src);
  }
  inline void cmpxchg(const GPVar cmp_1_eax, const GPVar& cmp_2, const GPVar& src)
  {
    ASMJIT_ASSERT(cmp_1_eax.getId() != src.getId());
    _emitInstruction(INST_CMPXCHG, &cmp_1_eax, &cmp_2, &src);
  }
  inline void cmpxchg(const GPVar cmp_1_eax, const Mem& cmp_2, const GPVar& src)
  {
    ASMJIT_ASSERT(cmp_1_eax.getId() != src.getId());
    _emitInstruction(INST_CMPXCHG, &cmp_1_eax, &cmp_2, &src);
  }
  inline void cmpxchg8b(
    const GPVar& cmp_edx, const GPVar& cmp_eax,
    const GPVar& cmp_ecx, const GPVar& cmp_ebx,
    const Mem& dst)
  {
    ASMJIT_ASSERT(cmp_edx.getId() != cmp_eax.getId() &&
                  cmp_eax.getId() != cmp_ecx.getId() &&
                  cmp_ecx.getId() != cmp_ebx.getId());
    _emitInstruction(INST_CMPXCHG8B, &cmp_edx, &cmp_eax, &cmp_ecx, &cmp_ebx, &dst);
  }
  inline void cpuid(
    const GPVar& inout_eax,
    const GPVar& out_ebx,
    const GPVar& out_ecx,
    const GPVar& out_edx)
  {
    ASMJIT_ASSERT(inout_eax.getId() != out_ebx.getId() &&
                  out_ebx.getId() != out_ecx.getId() &&
                  out_ecx.getId() != out_edx.getId());
    _emitInstruction(INST_CPUID, &inout_eax, &out_ebx, &out_ecx, &out_edx);
  }
  inline void daa(const GPVar& dst)
  {
    _emitInstruction(INST_DAA, &dst);
  }
  inline void das(const GPVar& dst)
  {
    _emitInstruction(INST_DAS, &dst);
  }
  inline void dec(const GPVar& dst)
  {
    _emitInstruction(INST_DEC, &dst);
  }
  inline void dec(const Mem& dst)
  {
    _emitInstruction(INST_DEC, &dst);
  }
  inline void div(const GPVar& dst_rem, const GPVar& dst_quot, const GPVar& src)
  {
    ASMJIT_ASSERT(dst_rem.getId() != dst_quot.getId());
    _emitInstruction(INST_DIV, &dst_rem, &dst_quot, &src);
  }
  inline void div(const GPVar& dst_rem, const GPVar& dst_quot, const Mem& src)
  {
    ASMJIT_ASSERT(dst_rem.getId() != dst_quot.getId());
    _emitInstruction(INST_DIV, &dst_rem, &dst_quot, &src);
  }
  inline void idiv(const GPVar& dst_rem, const GPVar& dst_quot, const GPVar& src)
  {
    ASMJIT_ASSERT(dst_rem.getId() != dst_quot.getId());
    _emitInstruction(INST_IDIV, &dst_rem, &dst_quot, &src);
  }
  inline void idiv(const GPVar& dst_rem, const GPVar& dst_quot, const Mem& src)
  {
    ASMJIT_ASSERT(dst_rem.getId() != dst_quot.getId());
    _emitInstruction(INST_IDIV, &dst_rem, &dst_quot, &src);
  }
  inline void imul(const GPVar& dst_hi, const GPVar& dst_lo, const GPVar& src)
  {
    ASMJIT_ASSERT(dst_hi.getId() != dst_lo.getId());
    _emitInstruction(INST_IMUL, &dst_hi, &dst_lo, &src);
  }
  inline void imul(const GPVar& dst_hi, const GPVar& dst_lo, const Mem& src)
  {
    ASMJIT_ASSERT(dst_hi.getId() != dst_lo.getId());
    _emitInstruction(INST_IMUL, &dst_hi, &dst_lo, &src);
  }
  inline void imul(const GPVar& dst, const GPVar& src)
  {
    _emitInstruction(INST_IMUL, &dst, &src);
  }
  inline void imul(const GPVar& dst, const Mem& src)
  {
    _emitInstruction(INST_IMUL, &dst, &src);
  }
  inline void imul(const GPVar& dst, const Imm& src)
  {
    _emitInstruction(INST_IMUL, &dst, &src);
  }
  inline void imul(const GPVar& dst, const GPVar& src, const Imm& imm)
  {
    _emitInstruction(INST_IMUL, &dst, &src, &imm);
  }
  inline void imul(const GPVar& dst, const Mem& src, const Imm& imm)
  {
    _emitInstruction(INST_IMUL, &dst, &src, &imm);
  }
  inline void inc(const GPVar& dst)
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
  inline void jmp(const GPVar& dst)
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
  inline void lea(const GPVar& dst, const Mem& src)
  {
    _emitInstruction(INST_LEA, &dst, &src);
  }
  inline void mov(const GPVar& dst, const GPVar& src)
  {
    _emitInstruction(INST_MOV, &dst, &src);
  }
  inline void mov(const GPVar& dst, const Mem& src)
  {
    _emitInstruction(INST_MOV, &dst, &src);
  }
  inline void mov(const GPVar& dst, const Imm& src)
  {
    _emitInstruction(INST_MOV, &dst, &src);
  }
  inline void mov(const Mem& dst, const GPVar& src)
  {
    _emitInstruction(INST_MOV, &dst, &src);
  }
  inline void mov(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_MOV, &dst, &src);
  }
  inline void mov(const GPVar& dst, const SegmentReg& src)
  {
    _emitInstruction(INST_MOV, &dst, &src);
  }
  inline void mov(const Mem& dst, const SegmentReg& src)
  {
    _emitInstruction(INST_MOV, &dst, &src);
  }
  inline void mov(const SegmentReg& dst, const GPVar& src)
  {
    _emitInstruction(INST_MOV, &dst, &src);
  }
  inline void mov(const SegmentReg& dst, const Mem& src)
  {
    _emitInstruction(INST_MOV, &dst, &src);
  }
  inline void mov_ptr(const GPVar& dst, void* src)
  {
    Imm imm((sysint_t)src);
    _emitInstruction(INST_MOV_PTR, &dst, &imm);
  }
  inline void mov_ptr(void* dst, const GPVar& src)
  {
    Imm imm((sysint_t)dst);
    _emitInstruction(INST_MOV_PTR, &imm, &src);
  }
  void movsx(const GPVar& dst, const GPVar& src)
  {
    _emitInstruction(INST_MOVSX, &dst, &src);
  }
  void movsx(const GPVar& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVSX, &dst, &src);
  }
  inline void movzx(const GPVar& dst, const GPVar& src)
  {
    _emitInstruction(INST_MOVZX, &dst, &src);
  }
  inline void movzx(const GPVar& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVZX, &dst, &src);
  }
  inline void mul(const GPVar& dst_hi, const GPVar& dst_lo, const GPVar& src)
  {
    ASMJIT_ASSERT(dst_hi.getId() != dst_lo.getId());
    _emitInstruction(INST_MUL, &dst_hi, &dst_lo, &src);
  }
  inline void mul(const GPVar& dst_hi, const GPVar& dst_lo, const Mem& src)
  {
    ASMJIT_ASSERT(dst_hi.getId() != dst_lo.getId());
    _emitInstruction(INST_MUL, &dst_hi, &dst_lo, &src);
  }
  inline void neg(const GPVar& dst)
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
  inline void not_(const GPVar& dst)
  {
    _emitInstruction(INST_NOT, &dst);
  }
  inline void not_(const Mem& dst)
  {
    _emitInstruction(INST_NOT, &dst);
  }
  inline void or_(const GPVar& dst, const GPVar& src)
  {
    _emitInstruction(INST_OR, &dst, &src);
  }
  inline void or_(const GPVar& dst, const Mem& src)
  {
    _emitInstruction(INST_OR, &dst, &src);
  }
  inline void or_(const GPVar& dst, const Imm& src)
  {
    _emitInstruction(INST_OR, &dst, &src);
  }
  inline void or_(const Mem& dst, const GPVar& src)
  {
    _emitInstruction(INST_OR, &dst, &src);
  }
  inline void or_(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_OR, &dst, &src);
  }
  inline void pop(const GPVar& dst)
  {
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
  inline void push(const GPVar& src)
  {
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
  inline void rcl(const GPVar& dst, const GPVar& src)
  {
    _emitInstruction(INST_RCL, &dst, &src);
  }
  inline void rcl(const GPVar& dst, const Imm& src)
  {
    _emitInstruction(INST_RCL, &dst, &src);
  }
  inline void rcl(const Mem& dst, const GPVar& src)
  {
    _emitInstruction(INST_RCL, &dst, &src);
  }
  inline void rcl(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_RCL, &dst, &src);
  }
  inline void rcr(const GPVar& dst, const GPVar& src)
  {
    _emitInstruction(INST_RCR, &dst, &src);
  }
  inline void rcr(const GPVar& dst, const Imm& src)
  {
    _emitInstruction(INST_RCR, &dst, &src);
  }
  inline void rcr(const Mem& dst, const GPVar& src)
  {
    _emitInstruction(INST_RCR, &dst, &src);
  }
  inline void rcr(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_RCR, &dst, &src);
  }
  inline void rdtsc(const GPVar& dst_edx, const GPVar& dst_eax)
  {
    ASMJIT_ASSERT(dst_edx.getId() != dst_eax.getId());
    _emitInstruction(INST_RDTSC, &dst_edx, &dst_eax);
  }
  inline void rdtscp(const GPVar& dst_edx, const GPVar& dst_eax, const GPVar& dst_ecx)
  {
    ASMJIT_ASSERT(dst_edx.getId() != dst_eax.getId() &&
                  dst_eax.getId() != dst_ecx.getId());
    _emitInstruction(INST_RDTSCP, &dst_edx, &dst_eax, &dst_ecx);
  }
  inline void rep_lodsb(const GPVar& dst_val, const GPVar& src_addr, const GPVar& cnt_ecx)
  {
    ASMJIT_ASSERT(dst_val.getId() != src_addr.getId() && src_addr.getId() != cnt_ecx.getId());
    _emitInstruction(INST_REP_LODSB, &dst_val, &src_addr, &cnt_ecx);
  }
  inline void rep_lodsd(const GPVar& dst_val, const GPVar& src_addr, const GPVar& cnt_ecx)
  {
    ASMJIT_ASSERT(dst_val.getId() != src_addr.getId() && src_addr.getId() != cnt_ecx.getId());
    _emitInstruction(INST_REP_LODSD, &dst_val, &src_addr, &cnt_ecx);
  }
  inline void rep_lodsw(const GPVar& dst_val, const GPVar& src_addr, const GPVar& cnt_ecx)
  {
    ASMJIT_ASSERT(dst_val.getId() != src_addr.getId() && src_addr.getId() != cnt_ecx.getId());
    _emitInstruction(INST_REP_LODSW, &dst_val, &src_addr, &cnt_ecx);
  }
  inline void rep_movsb(const GPVar& dst_addr, const GPVar& src_addr, const GPVar& cnt_ecx)
  {
    ASMJIT_ASSERT(dst_addr.getId() != src_addr.getId() && src_addr.getId() != cnt_ecx.getId());
    _emitInstruction(INST_REP_MOVSB, &dst_addr, &src_addr, &cnt_ecx);
  }
  inline void rep_movsd(const GPVar& dst_addr, const GPVar& src_addr, const GPVar& cnt_ecx)
  {
    ASMJIT_ASSERT(dst_addr.getId() != src_addr.getId() && src_addr.getId() != cnt_ecx.getId());
    _emitInstruction(INST_REP_MOVSD, &dst_addr, &src_addr, &cnt_ecx);
  }
  inline void rep_movsw(const GPVar& dst_addr, const GPVar& src_addr, const GPVar& cnt_ecx)
  {
    ASMJIT_ASSERT(dst_addr.getId() != src_addr.getId() && src_addr.getId() != cnt_ecx.getId());
    _emitInstruction(INST_REP_MOVSW, &dst_addr, &src_addr, &cnt_ecx);
  }
  inline void rep_stosb(const GPVar& dst_addr, const GPVar& src_val, const GPVar& cnt_ecx)
  {
    ASMJIT_ASSERT(dst_addr.getId() != src_val.getId() && src_val.getId() != cnt_ecx.getId());
    _emitInstruction(INST_REP_STOSB, &dst_addr, &src_val, &cnt_ecx);
  }
  inline void rep_stosd(const GPVar& dst_addr, const GPVar& src_val, const GPVar& cnt_ecx)
  {
    ASMJIT_ASSERT(dst_addr.getId() != src_val.getId() && src_val.getId() != cnt_ecx.getId());
    _emitInstruction(INST_REP_STOSD, &dst_addr, &src_val, &cnt_ecx);
  }
  inline void rep_stosw(const GPVar& dst_addr, const GPVar& src_val, const GPVar& cnt_ecx)
  {
    ASMJIT_ASSERT(dst_addr.getId() != src_val.getId() && src_val.getId() != cnt_ecx.getId());
    _emitInstruction(INST_REP_STOSW, &dst_addr, &src_val, &cnt_ecx);
  }
  inline void repe_cmpsb(const GPVar& cmp1_addr, const GPVar& cmp2_addr, const GPVar& cnt_ecx)
  {
    ASMJIT_ASSERT(cmp1_addr.getId() != cmp2_addr.getId() && cmp2_addr.getId() != cnt_ecx.getId());
    _emitInstruction(INST_REPE_CMPSB, &cmp1_addr, &cmp2_addr, &cnt_ecx);
  }
  inline void repe_cmpsd(const GPVar& cmp1_addr, const GPVar& cmp2_addr, const GPVar& cnt_ecx)
  {
    ASMJIT_ASSERT(cmp1_addr.getId() != cmp2_addr.getId() && cmp2_addr.getId() != cnt_ecx.getId());
    _emitInstruction(INST_REPE_CMPSD, &cmp1_addr, &cmp2_addr, &cnt_ecx);
  }
  inline void repe_cmpsw(const GPVar& cmp1_addr, const GPVar& cmp2_addr, const GPVar& cnt_ecx)
  {
    ASMJIT_ASSERT(cmp1_addr.getId() != cmp2_addr.getId() && cmp2_addr.getId() != cnt_ecx.getId());
    _emitInstruction(INST_REPE_CMPSW, &cmp1_addr, &cmp2_addr, &cnt_ecx);
  }
  inline void repe_scasb(const GPVar& cmp1_addr, const GPVar& cmp2_val, const GPVar& cnt_ecx)
  {
    ASMJIT_ASSERT(cmp1_addr.getId() != cmp2_val.getId() && cmp2_val.getId() != cnt_ecx.getId());
    _emitInstruction(INST_REPE_SCASB, &cmp1_addr, &cmp2_val, &cnt_ecx);
  }
  inline void repe_scasd(const GPVar& cmp1_addr, const GPVar& cmp2_val, const GPVar& cnt_ecx)
  {
    ASMJIT_ASSERT(cmp1_addr.getId() != cmp2_val.getId() && cmp2_val.getId() != cnt_ecx.getId());
    _emitInstruction(INST_REPE_SCASD, &cmp1_addr, &cmp2_val, &cnt_ecx);
  }
  inline void repe_scasw(const GPVar& cmp1_addr, const GPVar& cmp2_val, const GPVar& cnt_ecx)
  {
    ASMJIT_ASSERT(cmp1_addr.getId() != cmp2_val.getId() && cmp2_val.getId() != cnt_ecx.getId());
    _emitInstruction(INST_REPE_SCASW, &cmp1_addr, &cmp2_val, &cnt_ecx);
  }
  inline void repne_cmpsb(const GPVar& cmp1_addr, const GPVar& cmp2_addr, const GPVar& cnt_ecx)
  {
    ASMJIT_ASSERT(cmp1_addr.getId() != cmp2_addr.getId() && cmp2_addr.getId() != cnt_ecx.getId());
    _emitInstruction(INST_REPNE_CMPSB, &cmp1_addr, &cmp2_addr, &cnt_ecx);
  }
  inline void repne_cmpsd(const GPVar& cmp1_addr, const GPVar& cmp2_addr, const GPVar& cnt_ecx)
  {
    ASMJIT_ASSERT(cmp1_addr.getId() != cmp2_addr.getId() && cmp2_addr.getId() != cnt_ecx.getId());
    _emitInstruction(INST_REPNE_CMPSD, &cmp1_addr, &cmp2_addr, &cnt_ecx);
  }
  inline void repne_cmpsw(const GPVar& cmp1_addr, const GPVar& cmp2_addr, const GPVar& cnt_ecx)
  {
    ASMJIT_ASSERT(cmp1_addr.getId() != cmp2_addr.getId() && cmp2_addr.getId() != cnt_ecx.getId());
    _emitInstruction(INST_REPNE_CMPSW, &cmp1_addr, &cmp2_addr, &cnt_ecx);
  }
  inline void repne_scasb(const GPVar& cmp1_addr, const GPVar& cmp2_val, const GPVar& cnt_ecx)
  {
    ASMJIT_ASSERT(cmp1_addr.getId() != cmp2_val.getId() && cmp2_val.getId() != cnt_ecx.getId());
    _emitInstruction(INST_REPNE_SCASB, &cmp1_addr, &cmp2_val, &cnt_ecx);
  }
  inline void repne_scasd(const GPVar& cmp1_addr, const GPVar& cmp2_val, const GPVar& cnt_ecx)
  {
    ASMJIT_ASSERT(cmp1_addr.getId() != cmp2_val.getId() && cmp2_val.getId() != cnt_ecx.getId());
    _emitInstruction(INST_REPNE_SCASD, &cmp1_addr, &cmp2_val, &cnt_ecx);
  }
  inline void repne_scasw(const GPVar& cmp1_addr, const GPVar& cmp2_val, const GPVar& cnt_ecx)
  {
    ASMJIT_ASSERT(cmp1_addr.getId() != cmp2_val.getId() && cmp2_val.getId() != cnt_ecx.getId());
    _emitInstruction(INST_REPNE_SCASW, &cmp1_addr, &cmp2_val, &cnt_ecx);
  }
  inline void ret()
  {
    _emitReturn(((void*)0), ((void*)0));
  }
  inline void ret(const GPVar& first)
  {
    _emitReturn(&first, ((void*)0));
  }
  inline void ret(const GPVar& first, const GPVar& second)
  {
    _emitReturn(&first, &second);
  }
  inline void ret(const XMMVar& first)
  {
    _emitReturn(&first, ((void*)0));
  }
  inline void ret(const XMMVar& first, const XMMVar& second)
  {
    _emitReturn(&first, &second);
  }
  inline void rol(const GPVar& dst, const GPVar& src)
  {
    _emitInstruction(INST_ROL, &dst, &src);
  }
  inline void rol(const GPVar& dst, const Imm& src)
  {
    _emitInstruction(INST_ROL, &dst, &src);
  }
  inline void rol(const Mem& dst, const GPVar& src)
  {
    _emitInstruction(INST_ROL, &dst, &src);
  }
  inline void rol(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_ROL, &dst, &src);
  }
  inline void ror(const GPVar& dst, const GPVar& src)
  {
    _emitInstruction(INST_ROR, &dst, &src);
  }
  inline void ror(const GPVar& dst, const Imm& src)
  {
    _emitInstruction(INST_ROR, &dst, &src);
  }
  inline void ror(const Mem& dst, const GPVar& src)
  {
    _emitInstruction(INST_ROR, &dst, &src);
  }
  inline void ror(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_ROR, &dst, &src);
  }
  inline void sahf(const GPVar& var)
  {
    _emitInstruction(INST_SAHF, &var);
  }
  inline void sbb(const GPVar& dst, const GPVar& src)
  {
    _emitInstruction(INST_SBB, &dst, &src);
  }
  inline void sbb(const GPVar& dst, const Mem& src)
  {
    _emitInstruction(INST_SBB, &dst, &src);
  }
  inline void sbb(const GPVar& dst, const Imm& src)
  {
    _emitInstruction(INST_SBB, &dst, &src);
  }
  inline void sbb(const Mem& dst, const GPVar& src)
  {
    _emitInstruction(INST_SBB, &dst, &src);
  }
  inline void sbb(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_SBB, &dst, &src);
  }
  inline void sal(const GPVar& dst, const GPVar& src)
  {
    _emitInstruction(INST_SAL, &dst, &src);
  }
  inline void sal(const GPVar& dst, const Imm& src)
  {
    _emitInstruction(INST_SAL, &dst, &src);
  }
  inline void sal(const Mem& dst, const GPVar& src)
  {
    _emitInstruction(INST_SAL, &dst, &src);
  }
  inline void sal(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_SAL, &dst, &src);
  }
  inline void sar(const GPVar& dst, const GPVar& src)
  {
    _emitInstruction(INST_SAR, &dst, &src);
  }
  inline void sar(const GPVar& dst, const Imm& src)
  {
    _emitInstruction(INST_SAR, &dst, &src);
  }
  inline void sar(const Mem& dst, const GPVar& src)
  {
    _emitInstruction(INST_SAR, &dst, &src);
  }
  inline void sar(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_SAR, &dst, &src);
  }
  inline void set(CONDITION cc, const GPVar& dst)
  {
    ASMJIT_ASSERT(dst.getSize() == 1);
    _emitInstruction(ConditionToInstruction::toSetCC(cc), &dst);
  }
  inline void set(CONDITION cc, const Mem& dst)
  {
    ASMJIT_ASSERT(dst.getSize() <= 1);
    _emitInstruction(ConditionToInstruction::toSetCC(cc), &dst);
  }
  inline void seta (const GPVar& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETA , &dst); }
  inline void seta (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETA , &dst); }
  inline void setae (const GPVar& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETAE , &dst); }
  inline void setae (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETAE , &dst); }
  inline void setb (const GPVar& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETB , &dst); }
  inline void setb (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETB , &dst); }
  inline void setbe (const GPVar& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETBE , &dst); }
  inline void setbe (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETBE , &dst); }
  inline void setc (const GPVar& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETC , &dst); }
  inline void setc (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETC , &dst); }
  inline void sete (const GPVar& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETE , &dst); }
  inline void sete (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETE , &dst); }
  inline void setg (const GPVar& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETG , &dst); }
  inline void setg (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETG , &dst); }
  inline void setge (const GPVar& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETGE , &dst); }
  inline void setge (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETGE , &dst); }
  inline void setl (const GPVar& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETL , &dst); }
  inline void setl (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETL , &dst); }
  inline void setle (const GPVar& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETLE , &dst); }
  inline void setle (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETLE , &dst); }
  inline void setna (const GPVar& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETNA , &dst); }
  inline void setna (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETNA , &dst); }
  inline void setnae(const GPVar& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETNAE, &dst); }
  inline void setnae(const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETNAE, &dst); }
  inline void setnb (const GPVar& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETNB , &dst); }
  inline void setnb (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETNB , &dst); }
  inline void setnbe(const GPVar& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETNBE, &dst); }
  inline void setnbe(const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETNBE, &dst); }
  inline void setnc (const GPVar& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETNC , &dst); }
  inline void setnc (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETNC , &dst); }
  inline void setne (const GPVar& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETNE , &dst); }
  inline void setne (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETNE , &dst); }
  inline void setng (const GPVar& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETNG , &dst); }
  inline void setng (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETNG , &dst); }
  inline void setnge(const GPVar& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETNGE, &dst); }
  inline void setnge(const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETNGE, &dst); }
  inline void setnl (const GPVar& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETNL , &dst); }
  inline void setnl (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETNL , &dst); }
  inline void setnle(const GPVar& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETNLE, &dst); }
  inline void setnle(const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETNLE, &dst); }
  inline void setno (const GPVar& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETNO , &dst); }
  inline void setno (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETNO , &dst); }
  inline void setnp (const GPVar& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETNP , &dst); }
  inline void setnp (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETNP , &dst); }
  inline void setns (const GPVar& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETNS , &dst); }
  inline void setns (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETNS , &dst); }
  inline void setnz (const GPVar& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETNZ , &dst); }
  inline void setnz (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETNZ , &dst); }
  inline void seto (const GPVar& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETO , &dst); }
  inline void seto (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETO , &dst); }
  inline void setp (const GPVar& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETP , &dst); }
  inline void setp (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETP , &dst); }
  inline void setpe (const GPVar& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETPE , &dst); }
  inline void setpe (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETPE , &dst); }
  inline void setpo (const GPVar& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETPO , &dst); }
  inline void setpo (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETPO , &dst); }
  inline void sets (const GPVar& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETS , &dst); }
  inline void sets (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETS , &dst); }
  inline void setz (const GPVar& dst) { ASMJIT_ASSERT(dst.getSize() == 1); _emitInstruction(INST_SETZ , &dst); }
  inline void setz (const Mem& dst) { ASMJIT_ASSERT(dst.getSize() <= 1); _emitInstruction(INST_SETZ , &dst); }
  inline void shl(const GPVar& dst, const GPVar& src)
  {
    _emitInstruction(INST_SHL, &dst, &src);
  }
  inline void shl(const GPVar& dst, const Imm& src)
  {
    _emitInstruction(INST_SHL, &dst, &src);
  }
  inline void shl(const Mem& dst, const GPVar& src)
  {
    _emitInstruction(INST_SHL, &dst, &src);
  }
  inline void shl(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_SHL, &dst, &src);
  }
  inline void shr(const GPVar& dst, const GPVar& src)
  {
    _emitInstruction(INST_SHR, &dst, &src);
  }
  inline void shr(const GPVar& dst, const Imm& src)
  {
    _emitInstruction(INST_SHR, &dst, &src);
  }
  inline void shr(const Mem& dst, const GPVar& src)
  {
    _emitInstruction(INST_SHR, &dst, &src);
  }
  inline void shr(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_SHR, &dst, &src);
  }
  inline void shld(const GPVar& dst, const GPVar& src1, const GPVar& src2)
  {
    _emitInstruction(INST_SHLD, &dst, &src1, &src2);
  }
  inline void shld(const GPVar& dst, const GPVar& src1, const Imm& src2)
  {
    _emitInstruction(INST_SHLD, &dst, &src1, &src2);
  }
  inline void shld(const Mem& dst, const GPVar& src1, const GPVar& src2)
  {
    _emitInstruction(INST_SHLD, &dst, &src1, &src2);
  }
  inline void shld(const Mem& dst, const GPVar& src1, const Imm& src2)
  {
    _emitInstruction(INST_SHLD, &dst, &src1, &src2);
  }
  inline void shrd(const GPVar& dst, const GPVar& src1, const GPVar& src2)
  {
    _emitInstruction(INST_SHRD, &dst, &src1, &src2);
  }
  inline void shrd(const GPVar& dst, const GPVar& src1, const Imm& src2)
  {
    _emitInstruction(INST_SHRD, &dst, &src1, &src2);
  }
  inline void shrd(const Mem& dst, const GPVar& src1, const GPVar& src2)
  {
    _emitInstruction(INST_SHRD, &dst, &src1, &src2);
  }
  inline void shrd(const Mem& dst, const GPVar& src1, const Imm& src2)
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
  inline void sub(const GPVar& dst, const GPVar& src)
  {
    _emitInstruction(INST_SUB, &dst, &src);
  }
  inline void sub(const GPVar& dst, const Mem& src)
  {
    _emitInstruction(INST_SUB, &dst, &src);
  }
  inline void sub(const GPVar& dst, const Imm& src)
  {
    _emitInstruction(INST_SUB, &dst, &src);
  }
  inline void sub(const Mem& dst, const GPVar& src)
  {
    _emitInstruction(INST_SUB, &dst, &src);
  }
  inline void sub(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_SUB, &dst, &src);
  }
  inline void test(const GPVar& op1, const GPVar& op2)
  {
    _emitInstruction(INST_TEST, &op1, &op2);
  }
  inline void test(const GPVar& op1, const Imm& op2)
  {
    _emitInstruction(INST_TEST, &op1, &op2);
  }
  inline void test(const Mem& op1, const GPVar& op2)
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
  inline void xadd(const GPVar& dst, const GPVar& src)
  {
    _emitInstruction(INST_XADD, &dst, &src);
  }
  inline void xadd(const Mem& dst, const GPVar& src)
  {
    _emitInstruction(INST_XADD, &dst, &src);
  }
  inline void xchg(const GPVar& dst, const GPVar& src)
  {
    _emitInstruction(INST_XCHG, &dst, &src);
  }
  inline void xchg(const Mem& dst, const GPVar& src)
  {
    _emitInstruction(INST_XCHG, &dst, &src);
  }
  inline void xchg(const GPVar& dst, const Mem& src)
  {
    _emitInstruction(INST_XCHG, &src, &dst);
  }
  inline void xor_(const GPVar& dst, const GPVar& src)
  {
    _emitInstruction(INST_XOR, &dst, &src);
  }
  inline void xor_(const GPVar& dst, const Mem& src)
  {
    _emitInstruction(INST_XOR, &dst, &src);
  }
  inline void xor_(const GPVar& dst, const Imm& src)
  {
    _emitInstruction(INST_XOR, &dst, &src);
  }
  inline void xor_(const Mem& dst, const GPVar& src)
  {
    _emitInstruction(INST_XOR, &dst, &src);
  }
  inline void xor_(const Mem& dst, const Imm& src)
  {
    _emitInstruction(INST_XOR, &dst, &src);
  }
  inline void emms()
  {
    _emitInstruction(INST_EMMS);
  }
  inline void movd(const Mem& dst, const MMVar& src)
  {
    _emitInstruction(INST_MOVD, &dst, &src);
  }
  inline void movd(const GPVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_MOVD, &dst, &src);
  }
  inline void movd(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVD, &dst, &src);
  }
  inline void movd(const MMVar& dst, const GPVar& src)
  {
    _emitInstruction(INST_MOVD, &dst, &src);
  }
  inline void movq(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_MOVQ, &dst, &src);
  }
  inline void movq(const Mem& dst, const MMVar& src)
  {
    _emitInstruction(INST_MOVQ, &dst, &src);
  }
  inline void movq(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVQ, &dst, &src);
  }
  inline void packsswb(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PACKSSWB, &dst, &src);
  }
  inline void packsswb(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PACKSSWB, &dst, &src);
  }
  inline void packssdw(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PACKSSDW, &dst, &src);
  }
  inline void packssdw(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PACKSSDW, &dst, &src);
  }
  inline void packuswb(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PACKUSWB, &dst, &src);
  }
  inline void packuswb(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PACKUSWB, &dst, &src);
  }
  inline void paddb(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PADDB, &dst, &src);
  }
  inline void paddb(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PADDB, &dst, &src);
  }
  inline void paddw(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PADDW, &dst, &src);
  }
  inline void paddw(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PADDW, &dst, &src);
  }
  inline void paddd(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PADDD, &dst, &src);
  }
  inline void paddd(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PADDD, &dst, &src);
  }
  inline void paddsb(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PADDSB, &dst, &src);
  }
  inline void paddsb(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PADDSB, &dst, &src);
  }
  inline void paddsw(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PADDSW, &dst, &src);
  }
  inline void paddsw(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PADDSW, &dst, &src);
  }
  inline void paddusb(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PADDUSB, &dst, &src);
  }
  inline void paddusb(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PADDUSB, &dst, &src);
  }
  inline void paddusw(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PADDUSW, &dst, &src);
  }
  inline void paddusw(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PADDUSW, &dst, &src);
  }
  inline void pand(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PAND, &dst, &src);
  }
  inline void pand(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PAND, &dst, &src);
  }
  inline void pandn(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PANDN, &dst, &src);
  }
  inline void pandn(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PANDN, &dst, &src);
  }
  inline void pcmpeqb(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PCMPEQB, &dst, &src);
  }
  inline void pcmpeqb(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PCMPEQB, &dst, &src);
  }
  inline void pcmpeqw(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PCMPEQW, &dst, &src);
  }
  inline void pcmpeqw(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PCMPEQW, &dst, &src);
  }
  inline void pcmpeqd(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PCMPEQD, &dst, &src);
  }
  inline void pcmpeqd(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PCMPEQD, &dst, &src);
  }
  inline void pcmpgtb(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PCMPGTB, &dst, &src);
  }
  inline void pcmpgtb(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PCMPGTB, &dst, &src);
  }
  inline void pcmpgtw(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PCMPGTW, &dst, &src);
  }
  inline void pcmpgtw(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PCMPGTW, &dst, &src);
  }
  inline void pcmpgtd(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PCMPGTD, &dst, &src);
  }
  inline void pcmpgtd(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PCMPGTD, &dst, &src);
  }
  inline void pmulhw(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PMULHW, &dst, &src);
  }
  inline void pmulhw(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMULHW, &dst, &src);
  }
  inline void pmullw(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PMULLW, &dst, &src);
  }
  inline void pmullw(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMULLW, &dst, &src);
  }
  inline void por(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_POR, &dst, &src);
  }
  inline void por(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_POR, &dst, &src);
  }
  inline void pmaddwd(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PMADDWD, &dst, &src);
  }
  inline void pmaddwd(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMADDWD, &dst, &src);
  }
  inline void pslld(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PSLLD, &dst, &src);
  }
  inline void pslld(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSLLD, &dst, &src);
  }
  inline void pslld(const MMVar& dst, const Imm& src)
  {
    _emitInstruction(INST_PSLLD, &dst, &src);
  }
  inline void psllq(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PSLLQ, &dst, &src);
  }
  inline void psllq(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSLLQ, &dst, &src);
  }
  inline void psllq(const MMVar& dst, const Imm& src)
  {
    _emitInstruction(INST_PSLLQ, &dst, &src);
  }
  inline void psllw(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PSLLW, &dst, &src);
  }
  inline void psllw(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSLLW, &dst, &src);
  }
  inline void psllw(const MMVar& dst, const Imm& src)
  {
    _emitInstruction(INST_PSLLW, &dst, &src);
  }
  inline void psrad(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PSRAD, &dst, &src);
  }
  inline void psrad(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSRAD, &dst, &src);
  }
  inline void psrad(const MMVar& dst, const Imm& src)
  {
    _emitInstruction(INST_PSRAD, &dst, &src);
  }
  inline void psraw(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PSRAW, &dst, &src);
  }
  inline void psraw(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSRAW, &dst, &src);
  }
  inline void psraw(const MMVar& dst, const Imm& src)
  {
    _emitInstruction(INST_PSRAW, &dst, &src);
  }
  inline void psrld(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PSRLD, &dst, &src);
  }
  inline void psrld(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSRLD, &dst, &src);
  }
  inline void psrld(const MMVar& dst, const Imm& src)
  {
    _emitInstruction(INST_PSRLD, &dst, &src);
  }
  inline void psrlq(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PSRLQ, &dst, &src);
  }
  inline void psrlq(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSRLQ, &dst, &src);
  }
  inline void psrlq(const MMVar& dst, const Imm& src)
  {
    _emitInstruction(INST_PSRLQ, &dst, &src);
  }
  inline void psrlw(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PSRLW, &dst, &src);
  }
  inline void psrlw(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSRLW, &dst, &src);
  }
  inline void psrlw(const MMVar& dst, const Imm& src)
  {
    _emitInstruction(INST_PSRLW, &dst, &src);
  }
  inline void psubb(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PSUBB, &dst, &src);
  }
  inline void psubb(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSUBB, &dst, &src);
  }
  inline void psubw(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PSUBW, &dst, &src);
  }
  inline void psubw(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSUBW, &dst, &src);
  }
  inline void psubd(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PSUBD, &dst, &src);
  }
  inline void psubd(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSUBD, &dst, &src);
  }
  inline void psubsb(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PSUBSB, &dst, &src);
  }
  inline void psubsb(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSUBSB, &dst, &src);
  }
  inline void psubsw(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PSUBSW, &dst, &src);
  }
  inline void psubsw(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSUBSW, &dst, &src);
  }
  inline void psubusb(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PSUBUSB, &dst, &src);
  }
  inline void psubusb(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSUBUSB, &dst, &src);
  }
  inline void psubusw(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PSUBUSW, &dst, &src);
  }
  inline void psubusw(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSUBUSW, &dst, &src);
  }
  inline void punpckhbw(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PUNPCKHBW, &dst, &src);
  }
  inline void punpckhbw(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PUNPCKHBW, &dst, &src);
  }
  inline void punpckhwd(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PUNPCKHWD, &dst, &src);
  }
  inline void punpckhwd(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PUNPCKHWD, &dst, &src);
  }
  inline void punpckhdq(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PUNPCKHDQ, &dst, &src);
  }
  inline void punpckhdq(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PUNPCKHDQ, &dst, &src);
  }
  inline void punpcklbw(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PUNPCKLBW, &dst, &src);
  }
  inline void punpcklbw(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PUNPCKLBW, &dst, &src);
  }
  inline void punpcklwd(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PUNPCKLWD, &dst, &src);
  }
  inline void punpcklwd(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PUNPCKLWD, &dst, &src);
  }
  inline void punpckldq(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PUNPCKLDQ, &dst, &src);
  }
  inline void punpckldq(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PUNPCKLDQ, &dst, &src);
  }
  inline void pxor(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PXOR, &dst, &src);
  }
  inline void pxor(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PXOR, &dst, &src);
  }
  inline void femms()
  {
    _emitInstruction(INST_FEMMS);
  }
  inline void pf2id(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PF2ID, &dst, &src);
  }
  inline void pf2id(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PF2ID, &dst, &src);
  }
  inline void pf2iw(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PF2IW, &dst, &src);
  }
  inline void pf2iw(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PF2IW, &dst, &src);
  }
  inline void pfacc(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PFACC, &dst, &src);
  }
  inline void pfacc(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PFACC, &dst, &src);
  }
  inline void pfadd(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PFADD, &dst, &src);
  }
  inline void pfadd(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PFADD, &dst, &src);
  }
  inline void pfcmpeq(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PFCMPEQ, &dst, &src);
  }
  inline void pfcmpeq(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PFCMPEQ, &dst, &src);
  }
  inline void pfcmpge(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PFCMPGE, &dst, &src);
  }
  inline void pfcmpge(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PFCMPGE, &dst, &src);
  }
  inline void pfcmpgt(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PFCMPGT, &dst, &src);
  }
  inline void pfcmpgt(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PFCMPGT, &dst, &src);
  }
  inline void pfmax(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PFMAX, &dst, &src);
  }
  inline void pfmax(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PFMAX, &dst, &src);
  }
  inline void pfmin(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PFMIN, &dst, &src);
  }
  inline void pfmin(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PFMIN, &dst, &src);
  }
  inline void pfmul(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PFMUL, &dst, &src);
  }
  inline void pfmul(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PFMUL, &dst, &src);
  }
  inline void pfnacc(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PFNACC, &dst, &src);
  }
  inline void pfnacc(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PFNACC, &dst, &src);
  }
  inline void pfpnaxx(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PFPNACC, &dst, &src);
  }
  inline void pfpnacc(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PFPNACC, &dst, &src);
  }
  inline void pfrcp(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PFRCP, &dst, &src);
  }
  inline void pfrcp(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PFRCP, &dst, &src);
  }
  inline void pfrcpit1(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PFRCPIT1, &dst, &src);
  }
  inline void pfrcpit1(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PFRCPIT1, &dst, &src);
  }
  inline void pfrcpit2(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PFRCPIT2, &dst, &src);
  }
  inline void pfrcpit2(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PFRCPIT2, &dst, &src);
  }
  inline void pfrsqit1(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PFRSQIT1, &dst, &src);
  }
  inline void pfrsqit1(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PFRSQIT1, &dst, &src);
  }
  inline void pfrsqrt(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PFRSQRT, &dst, &src);
  }
  inline void pfrsqrt(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PFRSQRT, &dst, &src);
  }
  inline void pfsub(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PFSUB, &dst, &src);
  }
  inline void pfsub(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PFSUB, &dst, &src);
  }
  inline void pfsubr(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PFSUBR, &dst, &src);
  }
  inline void pfsubr(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PFSUBR, &dst, &src);
  }
  inline void pi2fd(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PI2FD, &dst, &src);
  }
  inline void pi2fd(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PI2FD, &dst, &src);
  }
  inline void pi2fw(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PI2FW, &dst, &src);
  }
  inline void pi2fw(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PI2FW, &dst, &src);
  }
  inline void pswapd(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PSWAPD, &dst, &src);
  }
  inline void pswapd(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSWAPD, &dst, &src);
  }
  inline void addps(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_ADDPS, &dst, &src);
  }
  inline void addps(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_ADDPS, &dst, &src);
  }
  inline void addss(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_ADDSS, &dst, &src);
  }
  inline void addss(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_ADDSS, &dst, &src);
  }
  inline void andnps(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_ANDNPS, &dst, &src);
  }
  inline void andnps(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_ANDNPS, &dst, &src);
  }
  inline void andps(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_ANDPS, &dst, &src);
  }
  inline void andps(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_ANDPS, &dst, &src);
  }
  inline void cmpps(const XMMVar& dst, const XMMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_CMPPS, &dst, &src, &imm8);
  }
  inline void cmpps(const XMMVar& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_CMPPS, &dst, &src, &imm8);
  }
  inline void cmpss(const XMMVar& dst, const XMMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_CMPSS, &dst, &src, &imm8);
  }
  inline void cmpss(const XMMVar& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_CMPSS, &dst, &src, &imm8);
  }
  inline void comiss(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_COMISS, &dst, &src);
  }
  inline void comiss(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_COMISS, &dst, &src);
  }
  inline void cvtpi2ps(const XMMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_CVTPI2PS, &dst, &src);
  }
  inline void cvtpi2ps(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTPI2PS, &dst, &src);
  }
  inline void cvtps2pi(const MMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_CVTPS2PI, &dst, &src);
  }
  inline void cvtps2pi(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTPS2PI, &dst, &src);
  }
  inline void cvtsi2ss(const XMMVar& dst, const GPVar& src)
  {
    _emitInstruction(INST_CVTSI2SS, &dst, &src);
  }
  inline void cvtsi2ss(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTSI2SS, &dst, &src);
  }
  inline void cvtss2si(const GPVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_CVTSS2SI, &dst, &src);
  }
  inline void cvtss2si(const GPVar& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTSS2SI, &dst, &src);
  }
  inline void cvttps2pi(const MMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_CVTTPS2PI, &dst, &src);
  }
  inline void cvttps2pi(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTTPS2PI, &dst, &src);
  }
  inline void cvttss2si(const GPVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_CVTTSS2SI, &dst, &src);
  }
  inline void cvttss2si(const GPVar& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTTSS2SI, &dst, &src);
  }
  inline void divps(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_DIVPS, &dst, &src);
  }
  inline void divps(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_DIVPS, &dst, &src);
  }
  inline void divss(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_DIVSS, &dst, &src);
  }
  inline void divss(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_DIVSS, &dst, &src);
  }
  inline void ldmxcsr(const Mem& src)
  {
    _emitInstruction(INST_LDMXCSR, &src);
  }
  inline void maskmovq(const GPVar& dst_ptr, const MMVar& data, const MMVar& mask)
  {
    _emitInstruction(INST_MASKMOVQ, &dst_ptr, &data, &mask);
  }
  inline void maxps(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MAXPS, &dst, &src);
  }
  inline void maxps(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_MAXPS, &dst, &src);
  }
  inline void maxss(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MAXSS, &dst, &src);
  }
  inline void maxss(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_MAXSS, &dst, &src);
  }
  inline void minps(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MINPS, &dst, &src);
  }
  inline void minps(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_MINPS, &dst, &src);
  }
  inline void minss(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MINSS, &dst, &src);
  }
  inline void minss(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_MINSS, &dst, &src);
  }
  inline void movaps(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MOVAPS, &dst, &src);
  }
  inline void movaps(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVAPS, &dst, &src);
  }
  inline void movaps(const Mem& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MOVAPS, &dst, &src);
  }
  inline void movd(const Mem& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MOVD, &dst, &src);
  }
  inline void movd(const GPVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MOVD, &dst, &src);
  }
  inline void movd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVD, &dst, &src);
  }
  inline void movd(const XMMVar& dst, const GPVar& src)
  {
    _emitInstruction(INST_MOVD, &dst, &src);
  }
  inline void movq(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MOVQ, &dst, &src);
  }
  inline void movq(const Mem& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MOVQ, &dst, &src);
  }
  inline void movq(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVQ, &dst, &src);
  }
  inline void movntq(const Mem& dst, const MMVar& src)
  {
    _emitInstruction(INST_MOVNTQ, &dst, &src);
  }
  inline void movhlps(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MOVHLPS, &dst, &src);
  }
  inline void movhps(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVHPS, &dst, &src);
  }
  inline void movhps(const Mem& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MOVHPS, &dst, &src);
  }
  inline void movlhps(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MOVLHPS, &dst, &src);
  }
  inline void movlps(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVLPS, &dst, &src);
  }
  inline void movlps(const Mem& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MOVLPS, &dst, &src);
  }
  inline void movntps(const Mem& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MOVNTPS, &dst, &src);
  }
  inline void movss(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MOVSS, &dst, &src);
  }
  inline void movss(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVSS, &dst, &src);
  }
  inline void movss(const Mem& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MOVSS, &dst, &src);
  }
  inline void movups(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MOVUPS, &dst, &src);
  }
  inline void movups(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVUPS, &dst, &src);
  }
  inline void movups(const Mem& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MOVUPS, &dst, &src);
  }
  inline void mulps(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MULPS, &dst, &src);
  }
  inline void mulps(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_MULPS, &dst, &src);
  }
  inline void mulss(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MULSS, &dst, &src);
  }
  inline void mulss(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_MULSS, &dst, &src);
  }
  inline void orps(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_ORPS, &dst, &src);
  }
  inline void orps(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_ORPS, &dst, &src);
  }
  inline void pavgb(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PAVGB, &dst, &src);
  }
  inline void pavgb(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PAVGB, &dst, &src);
  }
  inline void pavgw(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PAVGW, &dst, &src);
  }
  inline void pavgw(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PAVGW, &dst, &src);
  }
  inline void pextrw(const GPVar& dst, const MMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_PEXTRW, &dst, &src, &imm8);
  }
  inline void pinsrw(const MMVar& dst, const GPVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_PINSRW, &dst, &src, &imm8);
  }
  inline void pinsrw(const MMVar& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_PINSRW, &dst, &src, &imm8);
  }
  inline void pmaxsw(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PMAXSW, &dst, &src);
  }
  inline void pmaxsw(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMAXSW, &dst, &src);
  }
  inline void pmaxub(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PMAXUB, &dst, &src);
  }
  inline void pmaxub(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMAXUB, &dst, &src);
  }
  inline void pminsw(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PMINSW, &dst, &src);
  }
  inline void pminsw(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMINSW, &dst, &src);
  }
  inline void pminub(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PMINUB, &dst, &src);
  }
  inline void pminub(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMINUB, &dst, &src);
  }
  inline void pmovmskb(const GPVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PMOVMSKB, &dst, &src);
  }
  inline void pmulhuw(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PMULHUW, &dst, &src);
  }
  inline void pmulhuw(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMULHUW, &dst, &src);
  }
  inline void psadbw(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PSADBW, &dst, &src);
  }
  inline void psadbw(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSADBW, &dst, &src);
  }
  inline void pshufw(const MMVar& dst, const MMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_PSHUFW, &dst, &src, &imm8);
  }
  inline void pshufw(const MMVar& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_PSHUFW, &dst, &src, &imm8);
  }
  inline void rcpps(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_RCPPS, &dst, &src);
  }
  inline void rcpps(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_RCPPS, &dst, &src);
  }
  inline void rcpss(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_RCPSS, &dst, &src);
  }
  inline void rcpss(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_RCPSS, &dst, &src);
  }
  inline void prefetch(const Mem& mem, const Imm& hint)
  {
    _emitInstruction(INST_PREFETCH, &mem, &hint);
  }
  inline void psadbw(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PSADBW, &dst, &src);
  }
  inline void psadbw(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSADBW, &dst, &src);
  }
  inline void rsqrtps(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_RSQRTPS, &dst, &src);
  }
  inline void rsqrtps(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_RSQRTPS, &dst, &src);
  }
  inline void rsqrtss(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_RSQRTSS, &dst, &src);
  }
  inline void rsqrtss(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_RSQRTSS, &dst, &src);
  }
  inline void sfence()
  {
    _emitInstruction(INST_SFENCE);
  }
  inline void shufps(const XMMVar& dst, const XMMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_SHUFPS, &dst, &src, &imm8);
  }
  inline void shufps(const XMMVar& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_SHUFPS, &dst, &src, &imm8);
  }
  inline void sqrtps(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_SQRTPS, &dst, &src);
  }
  inline void sqrtps(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_SQRTPS, &dst, &src);
  }
  inline void sqrtss(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_SQRTSS, &dst, &src);
  }
  inline void sqrtss(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_SQRTSS, &dst, &src);
  }
  inline void stmxcsr(const Mem& dst)
  {
    _emitInstruction(INST_STMXCSR, &dst);
  }
  inline void subps(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_SUBPS, &dst, &src);
  }
  inline void subps(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_SUBPS, &dst, &src);
  }
  inline void subss(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_SUBSS, &dst, &src);
  }
  inline void subss(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_SUBSS, &dst, &src);
  }
  inline void ucomiss(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_UCOMISS, &dst, &src);
  }
  inline void ucomiss(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_UCOMISS, &dst, &src);
  }
  inline void unpckhps(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_UNPCKHPS, &dst, &src);
  }
  inline void unpckhps(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_UNPCKHPS, &dst, &src);
  }
  inline void unpcklps(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_UNPCKLPS, &dst, &src);
  }
  inline void unpcklps(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_UNPCKLPS, &dst, &src);
  }
  inline void xorps(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_XORPS, &dst, &src);
  }
  inline void xorps(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_XORPS, &dst, &src);
  }
  inline void addpd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_ADDPD, &dst, &src);
  }
  inline void addpd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_ADDPD, &dst, &src);
  }
  inline void addsd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_ADDSD, &dst, &src);
  }
  inline void addsd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_ADDSD, &dst, &src);
  }
  inline void andnpd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_ANDNPD, &dst, &src);
  }
  inline void andnpd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_ANDNPD, &dst, &src);
  }
  inline void andpd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_ANDPD, &dst, &src);
  }
  inline void andpd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_ANDPD, &dst, &src);
  }
  inline void clflush(const Mem& mem)
  {
    _emitInstruction(INST_CLFLUSH, &mem);
  }
  inline void cmppd(const XMMVar& dst, const XMMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_CMPPD, &dst, &src, &imm8);
  }
  inline void cmppd(const XMMVar& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_CMPPD, &dst, &src, &imm8);
  }
  inline void cmpsd(const XMMVar& dst, const XMMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_CMPSD, &dst, &src, &imm8);
  }
  inline void cmpsd(const XMMVar& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_CMPSD, &dst, &src, &imm8);
  }
  inline void comisd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_COMISD, &dst, &src);
  }
  inline void comisd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_COMISD, &dst, &src);
  }
  inline void cvtdq2pd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_CVTDQ2PD, &dst, &src);
  }
  inline void cvtdq2pd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTDQ2PD, &dst, &src);
  }
  inline void cvtdq2ps(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_CVTDQ2PS, &dst, &src);
  }
  inline void cvtdq2ps(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTDQ2PS, &dst, &src);
  }
  inline void cvtpd2dq(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_CVTPD2DQ, &dst, &src);
  }
  inline void cvtpd2dq(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTPD2DQ, &dst, &src);
  }
  inline void cvtpd2pi(const MMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_CVTPD2PI, &dst, &src);
  }
  inline void cvtpd2pi(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTPD2PI, &dst, &src);
  }
  inline void cvtpd2ps(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_CVTPD2PS, &dst, &src);
  }
  inline void cvtpd2ps(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTPD2PS, &dst, &src);
  }
  inline void cvtpi2pd(const XMMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_CVTPI2PD, &dst, &src);
  }
  inline void cvtpi2pd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTPI2PD, &dst, &src);
  }
  inline void cvtps2dq(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_CVTPS2DQ, &dst, &src);
  }
  inline void cvtps2dq(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTPS2DQ, &dst, &src);
  }
  inline void cvtps2pd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_CVTPS2PD, &dst, &src);
  }
  inline void cvtps2pd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTPS2PD, &dst, &src);
  }
  inline void cvtsd2si(const GPVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_CVTSD2SI, &dst, &src);
  }
  inline void cvtsd2si(const GPVar& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTSD2SI, &dst, &src);
  }
  inline void cvtsd2ss(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_CVTSD2SS, &dst, &src);
  }
  inline void cvtsd2ss(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTSD2SS, &dst, &src);
  }
  inline void cvtsi2sd(const XMMVar& dst, const GPVar& src)
  {
    _emitInstruction(INST_CVTSI2SD, &dst, &src);
  }
  inline void cvtsi2sd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTSI2SD, &dst, &src);
  }
  inline void cvtss2sd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_CVTSS2SD, &dst, &src);
  }
  inline void cvtss2sd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTSS2SD, &dst, &src);
  }
  inline void cvttpd2pi(const MMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_CVTTPD2PI, &dst, &src);
  }
  inline void cvttpd2pi(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTTPD2PI, &dst, &src);
  }
  inline void cvttpd2dq(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_CVTTPD2DQ, &dst, &src);
  }
  inline void cvttpd2dq(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTTPD2DQ, &dst, &src);
  }
  inline void cvttps2dq(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_CVTTPS2DQ, &dst, &src);
  }
  inline void cvttps2dq(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTTPS2DQ, &dst, &src);
  }
  inline void cvttsd2si(const GPVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_CVTTSD2SI, &dst, &src);
  }
  inline void cvttsd2si(const GPVar& dst, const Mem& src)
  {
    _emitInstruction(INST_CVTTSD2SI, &dst, &src);
  }
  inline void divpd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_DIVPD, &dst, &src);
  }
  inline void divpd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_DIVPD, &dst, &src);
  }
  inline void divsd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_DIVSD, &dst, &src);
  }
  inline void divsd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_DIVSD, &dst, &src);
  }
  inline void lfence()
  {
    _emitInstruction(INST_LFENCE);
  }
  inline void maskmovdqu(const GPVar& dst_ptr, const XMMVar& src, const XMMVar& mask)
  {
    _emitInstruction(INST_MASKMOVDQU, &dst_ptr, &src, &mask);
  }
  inline void maxpd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MAXPD, &dst, &src);
  }
  inline void maxpd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_MAXPD, &dst, &src);
  }
  inline void maxsd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MAXSD, &dst, &src);
  }
  inline void maxsd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_MAXSD, &dst, &src);
  }
  inline void mfence()
  {
    _emitInstruction(INST_MFENCE);
  }
  inline void minpd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MINPD, &dst, &src);
  }
  inline void minpd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_MINPD, &dst, &src);
  }
  inline void minsd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MINSD, &dst, &src);
  }
  inline void minsd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_MINSD, &dst, &src);
  }
  inline void movdqa(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MOVDQA, &dst, &src);
  }
  inline void movdqa(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVDQA, &dst, &src);
  }
  inline void movdqa(const Mem& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MOVDQA, &dst, &src);
  }
  inline void movdqu(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MOVDQU, &dst, &src);
  }
  inline void movdqu(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVDQU, &dst, &src);
  }
  inline void movdqu(const Mem& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MOVDQU, &dst, &src);
  }
  inline void movmskps(const GPVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MOVMSKPS, &dst, &src);
  }
  inline void movmskpd(const GPVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MOVMSKPD, &dst, &src);
  }
  inline void movsd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MOVSD, &dst, &src);
  }
  inline void movsd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVSD, &dst, &src);
  }
  inline void movsd(const Mem& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MOVSD, &dst, &src);
  }
  inline void movapd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MOVAPD, &dst, &src);
  }
  inline void movapd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVAPD, &dst, &src);
  }
  inline void movapd(const Mem& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MOVAPD, &dst, &src);
  }
  inline void movdq2q(const MMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MOVDQ2Q, &dst, &src);
  }
  inline void movq2dq(const XMMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_MOVQ2DQ, &dst, &src);
  }
  inline void movhpd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVHPD, &dst, &src);
  }
  inline void movhpd(const Mem& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MOVHPD, &dst, &src);
  }
  inline void movlpd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVLPD, &dst, &src);
  }
  inline void movlpd(const Mem& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MOVLPD, &dst, &src);
  }
  inline void movntdq(const Mem& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MOVNTDQ, &dst, &src);
  }
  inline void movnti(const Mem& dst, const GPVar& src)
  {
    _emitInstruction(INST_MOVNTI, &dst, &src);
  }
  inline void movntpd(const Mem& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MOVNTPD, &dst, &src);
  }
  inline void movupd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MOVUPD, &dst, &src);
  }
  inline void movupd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVUPD, &dst, &src);
  }
  inline void movupd(const Mem& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MOVUPD, &dst, &src);
  }
  inline void mulpd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MULPD, &dst, &src);
  }
  inline void mulpd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_MULPD, &dst, &src);
  }
  inline void mulsd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MULSD, &dst, &src);
  }
  inline void mulsd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_MULSD, &dst, &src);
  }
  inline void orpd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_ORPD, &dst, &src);
  }
  inline void orpd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_ORPD, &dst, &src);
  }
  inline void packsswb(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PACKSSWB, &dst, &src);
  }
  inline void packsswb(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PACKSSWB, &dst, &src);
  }
  inline void packssdw(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PACKSSDW, &dst, &src);
  }
  inline void packssdw(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PACKSSDW, &dst, &src);
  }
  inline void packuswb(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PACKUSWB, &dst, &src);
  }
  inline void packuswb(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PACKUSWB, &dst, &src);
  }
  inline void paddb(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PADDB, &dst, &src);
  }
  inline void paddb(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PADDB, &dst, &src);
  }
  inline void paddw(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PADDW, &dst, &src);
  }
  inline void paddw(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PADDW, &dst, &src);
  }
  inline void paddd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PADDD, &dst, &src);
  }
  inline void paddd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PADDD, &dst, &src);
  }
  inline void paddq(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PADDQ, &dst, &src);
  }
  inline void paddq(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PADDQ, &dst, &src);
  }
  inline void paddq(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PADDQ, &dst, &src);
  }
  inline void paddq(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PADDQ, &dst, &src);
  }
  inline void paddsb(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PADDSB, &dst, &src);
  }
  inline void paddsb(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PADDSB, &dst, &src);
  }
  inline void paddsw(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PADDSW, &dst, &src);
  }
  inline void paddsw(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PADDSW, &dst, &src);
  }
  inline void paddusb(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PADDUSB, &dst, &src);
  }
  inline void paddusb(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PADDUSB, &dst, &src);
  }
  inline void paddusw(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PADDUSW, &dst, &src);
  }
  inline void paddusw(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PADDUSW, &dst, &src);
  }
  inline void pand(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PAND, &dst, &src);
  }
  inline void pand(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PAND, &dst, &src);
  }
  inline void pandn(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PANDN, &dst, &src);
  }
  inline void pandn(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PANDN, &dst, &src);
  }
  inline void pause()
  {
    _emitInstruction(INST_PAUSE);
  }
  inline void pavgb(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PAVGB, &dst, &src);
  }
  inline void pavgb(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PAVGB, &dst, &src);
  }
  inline void pavgw(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PAVGW, &dst, &src);
  }
  inline void pavgw(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PAVGW, &dst, &src);
  }
  inline void pcmpeqb(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PCMPEQB, &dst, &src);
  }
  inline void pcmpeqb(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PCMPEQB, &dst, &src);
  }
  inline void pcmpeqw(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PCMPEQW, &dst, &src);
  }
  inline void pcmpeqw(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PCMPEQW, &dst, &src);
  }
  inline void pcmpeqd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PCMPEQD, &dst, &src);
  }
  inline void pcmpeqd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PCMPEQD, &dst, &src);
  }
  inline void pcmpgtb(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PCMPGTB, &dst, &src);
  }
  inline void pcmpgtb(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PCMPGTB, &dst, &src);
  }
  inline void pcmpgtw(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PCMPGTW, &dst, &src);
  }
  inline void pcmpgtw(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PCMPGTW, &dst, &src);
  }
  inline void pcmpgtd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PCMPGTD, &dst, &src);
  }
  inline void pcmpgtd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PCMPGTD, &dst, &src);
  }
  inline void pextrw(const GPVar& dst, const XMMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_PEXTRW, &dst, &src, &imm8);
  }
  inline void pextrw(const Mem& dst, const XMMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_PEXTRW, &dst, &src, &imm8);
  }
  inline void pmaxsw(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PMAXSW, &dst, &src);
  }
  inline void pmaxsw(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMAXSW, &dst, &src);
  }
  inline void pmaxub(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PMAXUB, &dst, &src);
  }
  inline void pmaxub(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMAXUB, &dst, &src);
  }
  inline void pminsw(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PMINSW, &dst, &src);
  }
  inline void pminsw(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMINSW, &dst, &src);
  }
  inline void pminub(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PMINUB, &dst, &src);
  }
  inline void pminub(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMINUB, &dst, &src);
  }
  inline void pmovmskb(const GPVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PMOVMSKB, &dst, &src);
  }
  inline void pmulhw(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PMULHW, &dst, &src);
  }
  inline void pmulhw(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMULHW, &dst, &src);
  }
  inline void pmulhuw(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PMULHUW, &dst, &src);
  }
  inline void pmulhuw(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMULHUW, &dst, &src);
  }
  inline void pmullw(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PMULLW, &dst, &src);
  }
  inline void pmullw(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMULLW, &dst, &src);
  }
  inline void pmuludq(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PMULUDQ, &dst, &src);
  }
  inline void pmuludq(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMULUDQ, &dst, &src);
  }
  inline void pmuludq(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PMULUDQ, &dst, &src);
  }
  inline void pmuludq(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMULUDQ, &dst, &src);
  }
  inline void por(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_POR, &dst, &src);
  }
  inline void por(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_POR, &dst, &src);
  }
  inline void pslld(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PSLLD, &dst, &src);
  }
  inline void pslld(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSLLD, &dst, &src);
  }
  inline void pslld(const XMMVar& dst, const Imm& src)
  {
    _emitInstruction(INST_PSLLD, &dst, &src);
  }
  inline void psllq(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PSLLQ, &dst, &src);
  }
  inline void psllq(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSLLQ, &dst, &src);
  }
  inline void psllq(const XMMVar& dst, const Imm& src)
  {
    _emitInstruction(INST_PSLLQ, &dst, &src);
  }
  inline void psllw(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PSLLW, &dst, &src);
  }
  inline void psllw(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSLLW, &dst, &src);
  }
  inline void psllw(const XMMVar& dst, const Imm& src)
  {
    _emitInstruction(INST_PSLLW, &dst, &src);
  }
  inline void pslldq(const XMMVar& dst, const Imm& src)
  {
    _emitInstruction(INST_PSLLDQ, &dst, &src);
  }
  inline void psrad(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PSRAD, &dst, &src);
  }
  inline void psrad(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSRAD, &dst, &src);
  }
  inline void psrad(const XMMVar& dst, const Imm& src)
  {
    _emitInstruction(INST_PSRAD, &dst, &src);
  }
  inline void psraw(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PSRAW, &dst, &src);
  }
  inline void psraw(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSRAW, &dst, &src);
  }
  inline void psraw(const XMMVar& dst, const Imm& src)
  {
    _emitInstruction(INST_PSRAW, &dst, &src);
  }
  inline void psubb(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PSUBB, &dst, &src);
  }
  inline void psubb(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSUBB, &dst, &src);
  }
  inline void psubw(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PSUBW, &dst, &src);
  }
  inline void psubw(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSUBW, &dst, &src);
  }
  inline void psubd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PSUBD, &dst, &src);
  }
  inline void psubd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSUBD, &dst, &src);
  }
  inline void psubq(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PSUBQ, &dst, &src);
  }
  inline void psubq(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSUBQ, &dst, &src);
  }
  inline void psubq(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PSUBQ, &dst, &src);
  }
  inline void psubq(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSUBQ, &dst, &src);
  }
  inline void pmaddwd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PMADDWD, &dst, &src);
  }
  inline void pmaddwd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMADDWD, &dst, &src);
  }
  inline void pshufd(const XMMVar& dst, const XMMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_PSHUFD, &dst, &src, &imm8);
  }
  inline void pshufd(const XMMVar& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_PSHUFD, &dst, &src, &imm8);
  }
  inline void pshufhw(const XMMVar& dst, const XMMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_PSHUFHW, &dst, &src, &imm8);
  }
  inline void pshufhw(const XMMVar& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_PSHUFHW, &dst, &src, &imm8);
  }
  inline void pshuflw(const XMMVar& dst, const XMMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_PSHUFLW, &dst, &src, &imm8);
  }
  inline void pshuflw(const XMMVar& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_PSHUFLW, &dst, &src, &imm8);
  }
  inline void psrld(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PSRLD, &dst, &src);
  }
  inline void psrld(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSRLD, &dst, &src);
  }
  inline void psrld(const XMMVar& dst, const Imm& src)
  {
    _emitInstruction(INST_PSRLD, &dst, &src);
  }
  inline void psrlq(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PSRLQ, &dst, &src);
  }
  inline void psrlq(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSRLQ, &dst, &src);
  }
  inline void psrlq(const XMMVar& dst, const Imm& src)
  {
    _emitInstruction(INST_PSRLQ, &dst, &src);
  }
  inline void psrldq(const XMMVar& dst, const Imm& src)
  {
    _emitInstruction(INST_PSRLDQ, &dst, &src);
  }
  inline void psrlw(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PSRLW, &dst, &src);
  }
  inline void psrlw(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSRLW, &dst, &src);
  }
  inline void psrlw(const XMMVar& dst, const Imm& src)
  {
    _emitInstruction(INST_PSRLW, &dst, &src);
  }
  inline void psubsb(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PSUBSB, &dst, &src);
  }
  inline void psubsb(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSUBSB, &dst, &src);
  }
  inline void psubsw(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PSUBSW, &dst, &src);
  }
  inline void psubsw(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSUBSW, &dst, &src);
  }
  inline void psubusb(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PSUBUSB, &dst, &src);
  }
  inline void psubusb(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSUBUSB, &dst, &src);
  }
  inline void psubusw(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PSUBUSW, &dst, &src);
  }
  inline void psubusw(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSUBUSW, &dst, &src);
  }
  inline void punpckhbw(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PUNPCKHBW, &dst, &src);
  }
  inline void punpckhbw(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PUNPCKHBW, &dst, &src);
  }
  inline void punpckhwd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PUNPCKHWD, &dst, &src);
  }
  inline void punpckhwd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PUNPCKHWD, &dst, &src);
  }
  inline void punpckhdq(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PUNPCKHDQ, &dst, &src);
  }
  inline void punpckhdq(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PUNPCKHDQ, &dst, &src);
  }
  inline void punpckhqdq(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PUNPCKHQDQ, &dst, &src);
  }
  inline void punpckhqdq(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PUNPCKHQDQ, &dst, &src);
  }
  inline void punpcklbw(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PUNPCKLBW, &dst, &src);
  }
  inline void punpcklbw(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PUNPCKLBW, &dst, &src);
  }
  inline void punpcklwd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PUNPCKLWD, &dst, &src);
  }
  inline void punpcklwd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PUNPCKLWD, &dst, &src);
  }
  inline void punpckldq(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PUNPCKLDQ, &dst, &src);
  }
  inline void punpckldq(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PUNPCKLDQ, &dst, &src);
  }
  inline void punpcklqdq(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PUNPCKLQDQ, &dst, &src);
  }
  inline void punpcklqdq(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PUNPCKLQDQ, &dst, &src);
  }
  inline void pxor(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PXOR, &dst, &src);
  }
  inline void pxor(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PXOR, &dst, &src);
  }
  inline void shufpd(const XMMVar& dst, const XMMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_SHUFPD, &dst, &src, &imm8);
  }
  inline void shufpd(const XMMVar& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_SHUFPD, &dst, &src, &imm8);
  }
  inline void sqrtpd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_SQRTPD, &dst, &src);
  }
  inline void sqrtpd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_SQRTPD, &dst, &src);
  }
  inline void sqrtsd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_SQRTSD, &dst, &src);
  }
  inline void sqrtsd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_SQRTSD, &dst, &src);
  }
  inline void subpd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_SUBPD, &dst, &src);
  }
  inline void subpd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_SUBPD, &dst, &src);
  }
  inline void subsd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_SUBSD, &dst, &src);
  }
  inline void subsd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_SUBSD, &dst, &src);
  }
  inline void ucomisd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_UCOMISD, &dst, &src);
  }
  inline void ucomisd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_UCOMISD, &dst, &src);
  }
  inline void unpckhpd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_UNPCKHPD, &dst, &src);
  }
  inline void unpckhpd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_UNPCKHPD, &dst, &src);
  }
  inline void unpcklpd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_UNPCKLPD, &dst, &src);
  }
  inline void unpcklpd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_UNPCKLPD, &dst, &src);
  }
  inline void xorpd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_XORPD, &dst, &src);
  }
  inline void xorpd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_XORPD, &dst, &src);
  }
  inline void addsubpd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_ADDSUBPD, &dst, &src);
  }
  inline void addsubpd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_ADDSUBPD, &dst, &src);
  }
  inline void addsubps(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_ADDSUBPS, &dst, &src);
  }
  inline void addsubps(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_ADDSUBPS, &dst, &src);
  }
  inline void haddpd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_HADDPD, &dst, &src);
  }
  inline void haddpd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_HADDPD, &dst, &src);
  }
  inline void haddps(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_HADDPS, &dst, &src);
  }
  inline void haddps(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_HADDPS, &dst, &src);
  }
  inline void hsubpd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_HSUBPD, &dst, &src);
  }
  inline void hsubpd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_HSUBPD, &dst, &src);
  }
  inline void hsubps(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_HSUBPS, &dst, &src);
  }
  inline void hsubps(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_HSUBPS, &dst, &src);
  }
  inline void lddqu(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_LDDQU, &dst, &src);
  }
  inline void movddup(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MOVDDUP, &dst, &src);
  }
  inline void movddup(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVDDUP, &dst, &src);
  }
  inline void movshdup(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MOVSHDUP, &dst, &src);
  }
  inline void movshdup(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVSHDUP, &dst, &src);
  }
  inline void movsldup(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_MOVSLDUP, &dst, &src);
  }
  inline void movsldup(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVSLDUP, &dst, &src);
  }
  inline void psignb(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PSIGNB, &dst, &src);
  }
  inline void psignb(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSIGNB, &dst, &src);
  }
  inline void psignb(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PSIGNB, &dst, &src);
  }
  inline void psignb(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSIGNB, &dst, &src);
  }
  inline void psignw(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PSIGNW, &dst, &src);
  }
  inline void psignw(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSIGNW, &dst, &src);
  }
  inline void psignw(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PSIGNW, &dst, &src);
  }
  inline void psignw(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSIGNW, &dst, &src);
  }
  inline void psignd(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PSIGND, &dst, &src);
  }
  inline void psignd(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSIGND, &dst, &src);
  }
  inline void psignd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PSIGND, &dst, &src);
  }
  inline void psignd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSIGND, &dst, &src);
  }
  inline void phaddw(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PHADDW, &dst, &src);
  }
  inline void phaddw(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PHADDW, &dst, &src);
  }
  inline void phaddw(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PHADDW, &dst, &src);
  }
  inline void phaddw(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PHADDW, &dst, &src);
  }
  inline void phaddd(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PHADDD, &dst, &src);
  }
  inline void phaddd(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PHADDD, &dst, &src);
  }
  inline void phaddd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PHADDD, &dst, &src);
  }
  inline void phaddd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PHADDD, &dst, &src);
  }
  inline void phaddsw(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PHADDSW, &dst, &src);
  }
  inline void phaddsw(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PHADDSW, &dst, &src);
  }
  inline void phaddsw(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PHADDSW, &dst, &src);
  }
  inline void phaddsw(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PHADDSW, &dst, &src);
  }
  inline void phsubw(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PHSUBW, &dst, &src);
  }
  inline void phsubw(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PHSUBW, &dst, &src);
  }
  inline void phsubw(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PHSUBW, &dst, &src);
  }
  inline void phsubw(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PHSUBW, &dst, &src);
  }
  inline void phsubd(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PHSUBD, &dst, &src);
  }
  inline void phsubd(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PHSUBD, &dst, &src);
  }
  inline void phsubd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PHSUBD, &dst, &src);
  }
  inline void phsubd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PHSUBD, &dst, &src);
  }
  inline void phsubsw(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PHSUBSW, &dst, &src);
  }
  inline void phsubsw(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PHSUBSW, &dst, &src);
  }
  inline void phsubsw(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PHSUBSW, &dst, &src);
  }
  inline void phsubsw(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PHSUBSW, &dst, &src);
  }
  inline void pmaddubsw(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PMADDUBSW, &dst, &src);
  }
  inline void pmaddubsw(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMADDUBSW, &dst, &src);
  }
  inline void pmaddubsw(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PMADDUBSW, &dst, &src);
  }
  inline void pmaddubsw(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMADDUBSW, &dst, &src);
  }
  inline void pabsb(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PABSB, &dst, &src);
  }
  inline void pabsb(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PABSB, &dst, &src);
  }
  inline void pabsb(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PABSB, &dst, &src);
  }
  inline void pabsb(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PABSB, &dst, &src);
  }
  inline void pabsw(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PABSW, &dst, &src);
  }
  inline void pabsw(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PABSW, &dst, &src);
  }
  inline void pabsw(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PABSW, &dst, &src);
  }
  inline void pabsw(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PABSW, &dst, &src);
  }
  inline void pabsd(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PABSD, &dst, &src);
  }
  inline void pabsd(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PABSD, &dst, &src);
  }
  inline void pabsd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PABSD, &dst, &src);
  }
  inline void pabsd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PABSD, &dst, &src);
  }
  inline void pmulhrsw(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PMULHRSW, &dst, &src);
  }
  inline void pmulhrsw(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMULHRSW, &dst, &src);
  }
  inline void pmulhrsw(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PMULHRSW, &dst, &src);
  }
  inline void pmulhrsw(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMULHRSW, &dst, &src);
  }
  inline void pshufb(const MMVar& dst, const MMVar& src)
  {
    _emitInstruction(INST_PSHUFB, &dst, &src);
  }
  inline void pshufb(const MMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSHUFB, &dst, &src);
  }
  inline void pshufb(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PSHUFB, &dst, &src);
  }
  inline void pshufb(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PSHUFB, &dst, &src);
  }
  inline void palignr(const MMVar& dst, const MMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_PALIGNR, &dst, &src, &imm8);
  }
  inline void palignr(const MMVar& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_PALIGNR, &dst, &src, &imm8);
  }
  inline void palignr(const XMMVar& dst, const XMMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_PALIGNR, &dst, &src, &imm8);
  }
  inline void palignr(const XMMVar& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_PALIGNR, &dst, &src, &imm8);
  }
  inline void blendpd(const XMMVar& dst, const XMMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_BLENDPD, &dst, &src, &imm8);
  }
  inline void blendpd(const XMMVar& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_BLENDPD, &dst, &src, &imm8);
  }
  inline void blendps(const XMMVar& dst, const XMMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_BLENDPS, &dst, &src, &imm8);
  }
  inline void blendps(const XMMVar& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_BLENDPS, &dst, &src, &imm8);
  }
  inline void blendvpd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_BLENDVPD, &dst, &src);
  }
  inline void blendvpd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_BLENDVPD, &dst, &src);
  }
  inline void blendvps(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_BLENDVPS, &dst, &src);
  }
  inline void blendvps(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_BLENDVPS, &dst, &src);
  }
  inline void dppd(const XMMVar& dst, const XMMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_DPPD, &dst, &src, &imm8);
  }
  inline void dppd(const XMMVar& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_DPPD, &dst, &src, &imm8);
  }
  inline void dpps(const XMMVar& dst, const XMMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_DPPS, &dst, &src, &imm8);
  }
  inline void dpps(const XMMVar& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_DPPS, &dst, &src, &imm8);
  }
  inline void extractps(const XMMVar& dst, const XMMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_EXTRACTPS, &dst, &src, &imm8);
  }
  inline void extractps(const XMMVar& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_EXTRACTPS, &dst, &src, &imm8);
  }
  inline void movntdqa(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_MOVNTDQA, &dst, &src);
  }
  inline void mpsadbw(const XMMVar& dst, const XMMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_MPSADBW, &dst, &src, &imm8);
  }
  inline void mpsadbw(const XMMVar& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_MPSADBW, &dst, &src, &imm8);
  }
  inline void packusdw(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PACKUSDW, &dst, &src);
  }
  inline void packusdw(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PACKUSDW, &dst, &src);
  }
  inline void pblendvb(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PBLENDVB, &dst, &src);
  }
  inline void pblendvb(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PBLENDVB, &dst, &src);
  }
  inline void pblendw(const XMMVar& dst, const XMMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_PBLENDW, &dst, &src, &imm8);
  }
  inline void pblendw(const XMMVar& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_PBLENDW, &dst, &src, &imm8);
  }
  inline void pcmpeqq(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PCMPEQQ, &dst, &src);
  }
  inline void pcmpeqq(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PCMPEQQ, &dst, &src);
  }
  inline void pextrb(const GPVar& dst, const XMMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_PEXTRB, &dst, &src, &imm8);
  }
  inline void pextrb(const Mem& dst, const XMMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_PEXTRB, &dst, &src, &imm8);
  }
  inline void pextrd(const GPVar& dst, const XMMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_PEXTRD, &dst, &src, &imm8);
  }
  inline void pextrd(const Mem& dst, const XMMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_PEXTRD, &dst, &src, &imm8);
  }
  inline void pextrq(const GPVar& dst, const XMMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_PEXTRQ, &dst, &src, &imm8);
  }
  inline void pextrq(const Mem& dst, const XMMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_PEXTRQ, &dst, &src, &imm8);
  }
  inline void phminposuw(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PHMINPOSUW, &dst, &src);
  }
  inline void phminposuw(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PHMINPOSUW, &dst, &src);
  }
  inline void pinsrb(const XMMVar& dst, const GPVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_PINSRB, &dst, &src, &imm8);
  }
  inline void pinsrb(const XMMVar& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_PINSRB, &dst, &src, &imm8);
  }
  inline void pinsrd(const XMMVar& dst, const GPVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_PINSRD, &dst, &src, &imm8);
  }
  inline void pinsrd(const XMMVar& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_PINSRD, &dst, &src, &imm8);
  }
  inline void pinsrq(const XMMVar& dst, const GPVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_PINSRQ, &dst, &src, &imm8);
  }
  inline void pinsrq(const XMMVar& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_PINSRQ, &dst, &src, &imm8);
  }
  inline void pinsrw(const XMMVar& dst, const GPVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_PINSRW, &dst, &src, &imm8);
  }
  inline void pinsrw(const XMMVar& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_PINSRW, &dst, &src, &imm8);
  }
  inline void pmaxuw(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PMAXUW, &dst, &src);
  }
  inline void pmaxuw(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMAXUW, &dst, &src);
  }
  inline void pmaxsb(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PMAXSB, &dst, &src);
  }
  inline void pmaxsb(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMAXSB, &dst, &src);
  }
  inline void pmaxsd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PMAXSD, &dst, &src);
  }
  inline void pmaxsd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMAXSD, &dst, &src);
  }
  inline void pmaxud(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PMAXUD, &dst, &src);
  }
  inline void pmaxud(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMAXUD, &dst, &src);
  }
  inline void pminsb(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PMINSB, &dst, &src);
  }
  inline void pminsb(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMINSB, &dst, &src);
  }
  inline void pminuw(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PMINUW, &dst, &src);
  }
  inline void pminuw(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMINUW, &dst, &src);
  }
  inline void pminud(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PMINUD, &dst, &src);
  }
  inline void pminud(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMINUD, &dst, &src);
  }
  inline void pminsd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PMINSD, &dst, &src);
  }
  inline void pminsd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMINSD, &dst, &src);
  }
  inline void pmovsxbw(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PMOVSXBW, &dst, &src);
  }
  inline void pmovsxbw(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMOVSXBW, &dst, &src);
  }
  inline void pmovsxbd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PMOVSXBD, &dst, &src);
  }
  inline void pmovsxbd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMOVSXBD, &dst, &src);
  }
  inline void pmovsxbq(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PMOVSXBQ, &dst, &src);
  }
  inline void pmovsxbq(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMOVSXBQ, &dst, &src);
  }
  inline void pmovsxwd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PMOVSXWD, &dst, &src);
  }
  inline void pmovsxwd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMOVSXWD, &dst, &src);
  }
  inline void pmovsxwq(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PMOVSXWQ, &dst, &src);
  }
  inline void pmovsxwq(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMOVSXWQ, &dst, &src);
  }
  inline void pmovsxdq(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PMOVSXDQ, &dst, &src);
  }
  inline void pmovsxdq(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMOVSXDQ, &dst, &src);
  }
  inline void pmovzxbw(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PMOVZXBW, &dst, &src);
  }
  inline void pmovzxbw(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMOVZXBW, &dst, &src);
  }
  inline void pmovzxbd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PMOVZXBD, &dst, &src);
  }
  inline void pmovzxbd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMOVZXBD, &dst, &src);
  }
  inline void pmovzxbq(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PMOVZXBQ, &dst, &src);
  }
  inline void pmovzxbq(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMOVZXBQ, &dst, &src);
  }
  inline void pmovzxwd(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PMOVZXWD, &dst, &src);
  }
  inline void pmovzxwd(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMOVZXWD, &dst, &src);
  }
  inline void pmovzxwq(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PMOVZXWQ, &dst, &src);
  }
  inline void pmovzxwq(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMOVZXWQ, &dst, &src);
  }
  inline void pmovzxdq(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PMOVZXDQ, &dst, &src);
  }
  inline void pmovzxdq(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMOVZXDQ, &dst, &src);
  }
  inline void pmuldq(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PMULDQ, &dst, &src);
  }
  inline void pmuldq(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMULDQ, &dst, &src);
  }
  inline void pmulld(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PMULLD, &dst, &src);
  }
  inline void pmulld(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PMULLD, &dst, &src);
  }
  inline void ptest(const XMMVar& op1, const XMMVar& op2)
  {
    _emitInstruction(INST_PTEST, &op1, &op2);
  }
  inline void ptest(const XMMVar& op1, const Mem& op2)
  {
    _emitInstruction(INST_PTEST, &op1, &op2);
  }
  inline void roundps(const XMMVar& dst, const XMMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_ROUNDPS, &dst, &src, &imm8);
  }
  inline void roundps(const XMMVar& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_ROUNDPS, &dst, &src, &imm8);
  }
  inline void roundss(const XMMVar& dst, const XMMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_ROUNDSS, &dst, &src, &imm8);
  }
  inline void roundss(const XMMVar& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_ROUNDSS, &dst, &src, &imm8);
  }
  inline void roundpd(const XMMVar& dst, const XMMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_ROUNDPD, &dst, &src, &imm8);
  }
  inline void roundpd(const XMMVar& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_ROUNDPD, &dst, &src, &imm8);
  }
  inline void roundsd(const XMMVar& dst, const XMMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_ROUNDSD, &dst, &src, &imm8);
  }
  inline void roundsd(const XMMVar& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_ROUNDSD, &dst, &src, &imm8);
  }
  inline void crc32(const GPVar& dst, const GPVar& src)
  {
    _emitInstruction(INST_CRC32, &dst, &src);
  }
  inline void crc32(const GPVar& dst, const Mem& src)
  {
    _emitInstruction(INST_CRC32, &dst, &src);
  }
  inline void pcmpestri(const XMMVar& dst, const XMMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_PCMPESTRI, &dst, &src, &imm8);
  }
  inline void pcmpestri(const XMMVar& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_PCMPESTRI, &dst, &src, &imm8);
  }
  inline void pcmpestrm(const XMMVar& dst, const XMMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_PCMPESTRM, &dst, &src, &imm8);
  }
  inline void pcmpestrm(const XMMVar& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_PCMPESTRM, &dst, &src, &imm8);
  }
  inline void pcmpistri(const XMMVar& dst, const XMMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_PCMPISTRI, &dst, &src, &imm8);
  }
  inline void pcmpistri(const XMMVar& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_PCMPISTRI, &dst, &src, &imm8);
  }
  inline void pcmpistrm(const XMMVar& dst, const XMMVar& src, const Imm& imm8)
  {
    _emitInstruction(INST_PCMPISTRM, &dst, &src, &imm8);
  }
  inline void pcmpistrm(const XMMVar& dst, const Mem& src, const Imm& imm8)
  {
    _emitInstruction(INST_PCMPISTRM, &dst, &src, &imm8);
  }
  inline void pcmpgtq(const XMMVar& dst, const XMMVar& src)
  {
    _emitInstruction(INST_PCMPGTQ, &dst, &src);
  }
  inline void pcmpgtq(const XMMVar& dst, const Mem& src)
  {
    _emitInstruction(INST_PCMPGTQ, &dst, &src);
  }
  inline void popcnt(const GPVar& dst, const GPVar& src)
  {
    _emitInstruction(INST_POPCNT, &dst, &src);
  }
  inline void popcnt(const GPVar& dst, const Mem& src)
  {
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
  inline void movbe(const GPVar& dst, const Mem& src)
  {
    ASMJIT_ASSERT(!dst.isGPB());
    _emitInstruction(INST_MOVBE, &dst, &src);
  }
  inline void movbe(const Mem& dst, const GPVar& src)
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

struct ASMJIT_API Compiler : public CompilerIntrinsics
{
  Compiler(CodeGenerator* codeGenerator = NULL) ASMJIT_NOTHROW;
  virtual ~Compiler() ASMJIT_NOTHROW;
  virtual void* make() ASMJIT_NOTHROW;
  virtual void serialize(Assembler& a) ASMJIT_NOTHROW;
  inline ETarget* _getTarget(uint32_t id);
};

