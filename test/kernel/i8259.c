// 初始化 8259A
#include "type.h"
#include "const.h"
#include "protect.h"
#include "string.h"

PUBLIC void init_8259A(){
    // Master 8259, ICW1
    out_byte(INT_M_CTl, 0x11);

    // Slave 8259, ICW1
    out_byte(INT_S_CTL, 0x11);

    // Master 8259, ICW2, 设置 主8259 的中断入口地址为 0x20
    out_byte(INT_M_CTLMASK, INT_VECTOR_IRQ0);

    // SLAVE 8259,ICW2, 设置 从8259 的中断入口地址为 0x28
    out_byte(INT_S_CTLMASK, INT_VECTOR_IRQ8);

    // Master 8259, ICW3,IR2 对应 从8259
    out_byte(INT_M_CTLMASK, 0x4);

    // SLAVE 8259, ICW3, 对应 主8259 的IR2
    out_byte(INT_S_CTLMASK, 0x2);

    // Master 8259, ICW4
    out_byte(INT_M_CTLMASK, 0x1);

    // SLAVE 8259, ICW4 
    out_byte(INT_S_CTLMASK, 0x1);

    // Master 8259, OCW1 
    out_byte(INT_M_CTLMASK, 0xFF);

    //SLAVE 8259, OCW1
    out_byte(INT_S_CTLMASK, 0xFF);
}