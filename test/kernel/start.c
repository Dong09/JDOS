#include "type.h"
#include "const.h"
#include "protect.h"
#include "string.h"
#include "global.h"


// PUBLIC void* disp_str();


PUBLIC void cstart(){
    // 将loader 中的 GDT 复制到新的 GDT 中
    memcpy(&gdt ,(void*)(*((u32*)(&gdt_ptr[2]))), *((u16*)(&gdt_ptr[0]))+1);
    //
    u16* p_gdt_limit = (u16*)(&gdt_ptr[0]);
    u32* p_gdt_base = (u32*)(&gdt_ptr[2]);
    *p_gdt_limit = GDT_SIZE * sizeof(DESCRIPTOR) - 1;
    *p_gdt_base = (u32)&gdt;

    // 
    u16* p_idt_limit = (u16*)(&idt_ptr[0]);
    u32* p_idt_base = (u32*)(&idt_ptr[2]);
    *p_idt_limit = IDT_SIZE * sizeof(DESCRIPTOR) - 1;
    *p_idt_base = (u32)&idt;

    disp_str("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
                "----\"cstart\" begins----\n");
    init_prot();
    disp_str("----\"cstart\" ends----\n");
}