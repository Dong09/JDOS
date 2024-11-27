#ifndef _ORANGES_CONST_H_
#define _ORANGES_CONST_H_

// 函数类型
#define PUBLIC
#define PRIVATE static
#define EXTERN extern

// GDT 和 IDT 中描述符的个数
#define GDT_SIZE    128 
#define IDT_SIZE    256

// 8259A interrupt controller ports.
#define INT_M_CTl       0x20
#define INT_S_CTL       0xA0
#define INT_M_CTLMASK   0x21 
#define INT_S_CTLMASK   0xA1

//
#define PRIVILEGE_KRNL		0	
#define PRIVILEGE_USER		3

#endif 