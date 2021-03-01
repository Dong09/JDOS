#ifndef _ORANGES_PROTECT_H_
#define _ORANGES_PROTECT_H_ 

typedef struct s_descriptor{
    u16 limit_low;              // LIMIT
    u16 base_low;               //BASE
    u8  base_mid;               //BASE
    u8  attr1;                  //P(1) DPL(2) DT(1) TYPE(4)
    u8  limit_high_attr2;       //G(1) D(1) O(1) AVL(1) LIMITHIGH(4)
    u8  base_high;              //BASE
}DESCRIPTOR;

typedef struct s_gate{
    u16 offset_low;
    u16 selector;
    u8  dcount;
    u8  attr;
    u16 offset_high;
}GATE;

// 中断向量
#define INT_VECTOR_IRQ0 0x20 
#define INT_VECTOR_IRQ8 0x28 

#define INT_VECTOR_DIVIDE 0
#define INT_VECTOR_DEBUG 1
#define INT_VECTOR_NMI 2
#define INT_VECTOR_BREAKPOINT 3 
#define INT_VECTOR_OVERFLOW 4
#define INT_VECTOR_BOUNDS 5
#define INT_VECTOR_INVAL_OP 6
#define INT_VECTOR_COPROC_NOT 7
#define INT_VECTOR_DOUBLE_FAULT 8
#define INT_VECTOR_COPROC_SEG 9
#define INT_VECTOR_INVAL_TSS 10
#define INT_VECTOR_SEG_NOT 11
#define INT_VECTOR_STACK_FAULT 12
#define INT_VECTOR_PROTECTION 13
#define INT_VECTOR_PAGE_FAULT 14
#define INT_VECTOR_COPROC_ERR 16

// 中断门
#define DA_386IGate 0x8E  // 386 中断门类型值

#endif 