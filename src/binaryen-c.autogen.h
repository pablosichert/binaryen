// src/binaryen-c.autogen.h

BINARYEN_API BinaryenExpressionRef
BinaryenRttCanon(BinaryenModuleRef module, HeapType heapType);

BINARYEN_API BinaryenExpressionRef
BinaryenRttSub(BinaryenModuleRef module, BinaryenExpressionRef parent);

BINARYEN_API BinaryenExpressionRef
BinaryenStructNew(BinaryenModuleRef module, BinaryenExpressionRef rtt, BinaryenExpressionRef* operands, BinaryenIndex num_operands);

BINARYEN_API BinaryenExpressionRef
BinaryenStructGet(BinaryenModuleRef module, uint32_t index, BinaryenExpressionRef ref, uint32_t signed_, BinaryenType type);

BINARYEN_API BinaryenExpressionRef
BinaryenStructSet(BinaryenModuleRef module, uint32_t index, BinaryenExpressionRef value, BinaryenExpressionRef ref);

BINARYEN_API BinaryenExpressionRef
BinaryenArrayNew(BinaryenModuleRef module, BinaryenExpressionRef rtt, BinaryenExpressionRef size, BinaryenExpressionRef init);

BINARYEN_API BinaryenExpressionRef
BinaryenArrayGet(BinaryenModuleRef module, BinaryenExpressionRef index, BinaryenExpressionRef ref, uint32_t signed_);

BINARYEN_API BinaryenExpressionRef
BinaryenArraySet(BinaryenModuleRef module, BinaryenExpressionRef value, BinaryenExpressionRef index, BinaryenExpressionRef ref);

BINARYEN_API BinaryenExpressionRef
BinaryenArrayLen(BinaryenModuleRef module, BinaryenExpressionRef ref);
