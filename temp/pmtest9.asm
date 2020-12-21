;======================================
;pmtest9_2.asm
;编译方法：nasm pmtest9_2.asm -o pmtest9_2.bin
;======================================
%include "pm.inc";  常量，宏 以及一些说明
;org 07c00h


org 0100h
    jmp LABEL_BEGIN

[SECTION .gdt]
;GDT   
;                段基址    段界限     属性

LABEL_GDT:      Descriptor  0,  0,  0           ;空描述符
LABEL_DESC_NORMAL:  Descriptor  0,  0ffffh, DA_DRW          ;NORMAL描述符

LABEL_DESC_CODE32:  Descriptor  0,  SegCode32Len - 1, DA_CR| DA_32;  非一致代码段
LABEL_DESC_CODE16: Descriptor 0, 0ffffh, DA_C;  
LABEL_DESC_DATA: Descriptor 0, DataLen-1, DA_DRW; Data
LABEL_DESC_STACK: Descriptor 0, TopOfStack, DA_DRWA|DA_32;   
LABEL_DESC_VIDEO : Descriptor 0B8000h, 0ffffh, DA_DRW;  显存首地址
;GDT 就是一个数组结构

GdtLen  equ  $-LABEL_GDT  ;GDT长度
GdtPtr  dw   GdtLen - 1  ;GDT 界限
    dd 0  ; GDT基地址
;GdtPtr也是一个数据结构  前2字节是GDT界限  后4字节是GDT基地址

;GDT 选择子
SelectorNormal  equ LABEL_DESC_NORMAL - LABEL_GDT

SelectorCode32  equ     LABEL_DESC_CODE32 - LABEL_GDT
SelectorCode16  equ     LABEL_DESC_CODE16 - LABEL_GDT
SelectorData    equ     LABEL_DESC_DATA - LABEL_GDT
SelectorStack   equ     LABEL_DESC_STACK - LABEL_GDT
SelectorVideo   equ LABEL_DESC_VIDEO - LABEL_GDT
; END of [SECTION .gdt]



[SECTION .data1]  ;数据段
ALIGN 32
[BITS 32]
LABEL_DATA:

;实模式下使用这些符号
_wSPValueInRealMode     dw  0
DataLen         equ $ - LABEL_DATA
; END of [SECTION .data1]


;IDT
[SECTION .idt]
ALIGN   32
[BITS   32]
LABEL_IDT:
;门              目标选择子   偏移， DCount,  属性
%rep 32
        Gate    SelectorCode32, SpuriousHandler, 0, DA_386IGate
%endrep

.020h:      Gate    SelectorCode32, ClockHandler,   0,  DA_386IGate
; 要绕开 批量定义的中断门
%rep    95
        Gate    SelectorCode32, SpuriousHandler, 0, DA_386IGate
%endrep

.080h:      Gate    SelectorCode32, UserIntHandler, 0, DA_386IGate
;TODO important 
.081h:      Gate    SelectorCode32, PrinterHandler, 0,  DA_386IGate

IdtLen      equ $ - LABEL_IDT
IdtPtr      dw  IdtLen - 1  ;段界限
        dd  0       ;基地址
;end of section .idt





;全局堆栈段
[SECTION .gs]
ALIGN   32
[BITS 32]
LABEL_STACK:
    times 512 db 0
TopOfStack equ  $-LABEL_STACK-1

;end of [section.gs]



;这是一个16位代码段 这个程序修改了gdt中的一些值 然后执行跳转到第三个section
[SECTION .s16]
[BITS 16]
LABEL_BEGIN:
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0100h

    mov [LABEL_GO_BACK_TO_REAL+3], ax
    mov     [_wSPValueInRealMode],sp   ;是从零开始的？


    ;初始化16位的代码段描述符
    mov ax, cs
    movzx   eax, ax
    shl eax, 4
    add eax, LABEL_SEG_CODE16
    mov word [LABEL_DESC_CODE16 +2], ax
    shr eax, 16
    mov     byte [LABEL_DESC_CODE16 +4], al
    mov byte [LABEL_DESC_CODE16 +7], ah

    ;初始化32位代码段描述符
    xor eax, eax
    mov ax, cs
    shl eax, 4
    add eax, LABEL_SEG_CODE32
    mov word [LABEL_DESC_CODE32 + 2], ax
    shr eax, 16
    mov byte [LABEL_DESC_CODE32 + 4], al
    mov byte [LABEL_DESC_CODE32 + 7], ah

    ; 初始化数据段描述符  
        xor eax, eax  
        mov ax, ds  
        shl eax, 4  
        add eax, LABEL_DATA  
        mov word [LABEL_DESC_DATA + 2], ax  
        shr eax, 16  
    mov byte [LABEL_DESC_DATA + 4], al  
    mov byte [LABEL_DESC_DATA + 7], ah  

        ; 初始化堆栈段描述符  
        xor eax, eax  
        mov ax, ds  
        shl eax, 4  
        add eax, LABEL_STACK  
        mov word [LABEL_DESC_STACK + 2], ax  
        shr eax, 16  
        mov byte [LABEL_DESC_STACK + 4], al  
        mov byte [LABEL_DESC_STACK + 7], ah  

    ;为加载GDTR作准备
    xor eax, eax
    mov ax, ds
    shl eax, 4
    add eax, LABEL_GDT; eax <- gdt基地址
    mov     dword [GdtPtr + 2], eax; [GdtPtr + 2] <- gdt 基地址

    ;为加载IDTR作准备
    xor eax, eax
    mov ax, ds
    shl eax, 4
    add eax, LABEL_IDT  
    mov dword [IdtPtr + 2], eax

    ;加载GDTR
    lgdt    [GdtPtr]

    ;关中断
    cli

    ;加载IDTR
    lidt    [IdtPtr]

    ;打开地址线A20
    in  al, 92h
    or  al, 00000010b
    out 92h, al

    ;准备切换到保护模式
    mov eax, cr0
    or  eax, 1
    mov cr0, eax

    ;真正进入保护模式
    jmp dword   SelectorCode32:0 ;  执行这句会把SelectorCode32装入CS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LABEL_REAL_ENTRY:   ;从保护模式跳回到实模式就到了这里
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax

    mov     sp, [_wSPValueInRealMode]   ;指针调到了堆栈中  返回到实模式

    in  al, 92h
    and al, 11111101b;  关闭A20地址线
    out 92h, al

    sti;  开中断

    mov ax, 4c00h;
    int 21h;    回到dos
;end of section .s16




[SECTION .s32]
[BITS 32]

LABEL_SEG_CODE32:

    mov ax, SelectorData
    mov ds, ax;         数据段选择子
    mov es, ax

    mov ax, SelectorVideo;  视频段选择子
    mov gs, ax

    mov ax, SelectorStack
    mov ss, ax;         堆栈段选择子

    mov esp, TopOfStack

    call    Init8259A
    int 081h
    ; new add
    sti 
    jmp $  


    ; 到此停止
    jmp SelectorCode16:0


;Init8259A-------------------------------------------------
Init8259A:
    mov al, 011h
    out 020h, al    ; 主8259, ICW1.
    call    io_delay

    out 0A0h, al    ; 从8259, ICW1.
    call    io_delay

    mov al, 020h    ; IRQ0 对应中断向量 0x20
    out 021h, al    ; 主8259, ICW2.
    call    io_delay

    mov al, 028h    ; IRQ8 对应中断向量 0x28
    out 0A1h, al    ; 从8259, ICW2.
    call    io_delay

    mov al, 004h    ; IR2 对应从8259
    out 021h, al    ; 主8259, ICW3.
    call    io_delay

    mov al, 002h    ; 对应主8259的 IR2
    out 0A1h, al    ; 从8259, ICW3.
    call    io_delay

    mov al, 001h
    out 021h, al    ; 主8259, ICW4.
    call    io_delay

    out 0A1h, al    ; 从8259, ICW4.
    call    io_delay

    mov al, 11111110b   ; 仅仅开启定时器中断
;   mov al, 11111111b   ; 屏蔽主8259所有中断
    out 021h, al    ; 主8259, OCW1.
    call    io_delay

    mov al, 11111111b   ; 屏蔽从8259所有中断
    out 0A1h, al    ; 从8259, OCW1.
    call    io_delay

    ret
; Init8259A -----------------------------------------------

io_delay:
    nop
    nop
    nop
    nop
    ret

_PrinterHandler:
PrinterHandler  equ _PrinterHandler - $$
    mov ah, 02h
    mov al, 'R'
    mov [gs:((80 * 20 + 0) * 2)], ax    ; 屏幕第 0 行, 第 75 列。
    iretd

_SpuriousHandler:
SpuriousHandler equ _SpuriousHandler - $$
    mov ah, 0Ch             ; 0000: 黑底    1100: 红字
    mov al, '!'
    mov [gs:((80 * 0 + 75) * 2)], ax    ; 屏幕第 0 行, 第 75 列。
;   jmp $
    iretd

_UserIntHandler:
UserIntHandler  equ _UserIntHandler - $$
    mov ah, 0Ch
    mov al, 'D'
    mov [gs:((80 * 0 + 72) * 2)], ax    ; 屏幕第 0 行, 第 75 列。
    iretd

_ClockHandler:
ClockHandler    equ _ClockHandler - $$
    inc byte [gs:((80*0+70)*2)]
    mov     al, 20h     ; OCW2
    out 20h,    al    ;发送EOI end of interrupt 表示中断任务处理完成
    iretd




SegCode32Len    equ $-LABEL_SEG_CODE32
;end of section .s32

;16位的代码段 由32位代码段跳入  跳出后到实模式
[SECTION .s16code]
ALIGN 32
[BITS 16]
LABEL_SEG_CODE16:

    ;跳回实模式
    mov ax, SelectorNormal
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov eax, cr0
;   and al, 11111110b
    and eax, 7ffffffeh
    mov cr0, eax

LABEL_GO_BACK_TO_REAL:
    jmp 0:LABEL_REAL_ENTRY;    段地址会在程序开始处被设置为正确的值

Code16Len equ $ - LABEL_SEG_CODE16

;end of section .s16code