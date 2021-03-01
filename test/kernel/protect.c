//
#include "type.h"
#include "const.h"
#include "protect.h"
#include "string.h"
#include "global.h"
#include "proto.h"

void divide_error();
void single_step_exception();
void nmi();
void breakpoint_exception();
void overflow();
void bounds_check();
void inval_opcode();
void copr_not_available();
void double_fault();
void copr_seg_overrun();
void inval_tss();
void segment_not_present();
void stack_exception();
void general_protection();
void page_fault();
void copr_error();


// 用来初始化一个门描述符
PRIVATE void init_idt_desc(unsigned char vector, u8 desc_type, int_handler handler, unsigned char privilege){
    u16 SELECTOR_KERNEL_CS = 8;
    GATE* p_gate = &idt[vector];
    u32 base = (u32)handler;
    p_gate->offset_low = base & 0xffff;
    p_gate->selector = SELECTOR_KERNEL_CS;
    p_gate->dcount = 0;
    p_gate->attr = desc_type | (privilege << 5);
    p_gate->offset_high = (base >> 16) & 0xffff;
}

PUBLIC void init_prot(){
    init_8259A();
    init_idt_desc(INT_VECTOR_DIVIDE, DA_386IGate, divide_error, PRIVILEGE_KRNL);
    init_idt_desc(INT_VECTOR_DEBUG, DA_386IGate, single_step_exception, PRIVILEGE_KRNL);
    init_idt_desc(INT_VECTOR_NMI, DA_386IGate, nmi, PRIVILEGE_KRNL);
    init_idt_desc(INT_VECTOR_BREAKPOINT, DA_386IGate, breakpoint_exception, PRIVILEGE_USER);
    init_idt_desc(INT_VECTOR_OVERFLOW, DA_386IGate, overflow, PRIVILEGE_USER);
    init_idt_desc(INT_VECTOR_BOUNDS, DA_386IGate, bounds_check, PRIVILEGE_KRNL);
    init_idt_desc(INT_VECTOR_INVAL_OP, DA_386IGate, inval_opcode, PRIVILEGE_KRNL);
    init_idt_desc(INT_VECTOR_COPROC_NOT, DA_386IGate, copr_not_available, PRIVILEGE_KRNL);
    init_idt_desc(INT_VECTOR_DOUBLE_FAULT, DA_386IGate, double_fault, PRIVILEGE_KRNL);
    init_idt_desc(INT_VECTOR_COPROC_SEG, DA_386IGate, copr_seg_overrun, PRIVILEGE_KRNL);
    init_idt_desc(INT_VECTOR_INVAL_TSS, DA_386IGate, inval_tss, PRIVILEGE_KRNL);
    init_idt_desc(INT_VECTOR_SEG_NOT, DA_386IGate, segment_not_present, PRIVILEGE_KRNL);
    init_idt_desc(INT_VECTOR_STACK_FAULT, DA_386IGate, stack_exception, PRIVILEGE_KRNL);
    init_idt_desc(INT_VECTOR_PROTECTION, DA_386IGate, general_protection, PRIVILEGE_KRNL);
    init_idt_desc(INT_VECTOR_PAGE_FAULT, DA_386IGate, page_fault, PRIVILEGE_KRNL);
    init_idt_desc(INT_VECTOR_COPROC_ERR, DA_386IGate, copr_error, PRIVILEGE_KRNL);
}


PUBLIC void exception_handler(int vec_no, int err_code, int eip, int cs, int eflags){
    int i;
    int text_color = 0x74; // 灰底红字

    char *err_msg[] = {
        "#DE DIVIDE ERROR",
        "#DB RESERVED",
        "-- NMI INTERRUPT",
        "#BP BREAKPOINT",
        "#OF OVERFLOW",
        "#BR BOUND RANGE EXCEEDED",
        "#UD INVALID OPCODE (UNDEFINDE OPCODE)",
        "#NM DEVICE NOT AVAILABLE (NO MATH COPROCESSOR)",
        "DF DOUBLE FAULT",
        "    COPROCESSOR SEGMENT OVERRUN (RESERVED)",
        "#TS INVALID TSS",
        "#NP SEGMENT NOT PRESENT",
        "#SS STACK-SEGMENT FAULT",
        "#GP GENERAL PROTECTION",
        "#PF PAGE FAULT",
        "--  (INTEL RESERVED. DO NOT USE)",
        "#MF x87 FPU FLOATING-POINT ERROR (MATH FAULT)",
        "#AC ALIGNMENT CHECK",
        "#MC MACHINE CHECK",
        "#XF SIMD FLOATING-POINT EXCEPTION"
    };

    // 通过打印空格的方式清空屏幕前5行，并把 disp_pos 清零
    EXTERN int disp_pos;
    disp_pos = 0;
    for(i = 0;i<80*5;i++)
        disp_str(" ");
    disp_pos = 0;

    disp_color_str("EXCEPTION! --> ", text_color);
    disp_color_str(err_msg[vec_no],text_color);
    disp_color_str("\n",text_color);
    disp_color_str("EFLAGS:",text_color);
    disp_int(eflags);
    disp_color_str("CS:",text_color);
    disp_int(cs);
    disp_color_str("EIP:",text_color);
    disp_int(eip);

    if(err_code != 0xffffffff){
        disp_color_str("ERROR CODE:",text_color);
        disp_int(err_code);
    }

}
