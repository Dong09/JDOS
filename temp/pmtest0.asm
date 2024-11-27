%include "pm.inc"

org 0100h
jmp LABEL_BEGIN
[SECTION .gdt]
GDT_BEGIN: Descriptor 0, 0,   0
GDT_CODE32: Descriptor 0, LenOfCode32 - 1, DA_C + DA_32
GDT_VIDEO: Descriptor 0B8000H, 0FFFFH,   DA_DRW
GdtLen equ $ - GDT_BEGIN
GdtPtr dw GdtLen - 1
dd 0
;定义段选择子
SelectorCode32 equ GDT_CODE32 - GDT_BEGIN
SelectorVideo equ GDT_VIDEO - GDT_BEGIN
[SECTION .main]
[BITS 16]
LABEL_BEGIN:
mov ax, cs
mov ds, ax
mov es, ax
mov ss, ax

;初始化32位代码段选择子
;我们可以在实模式下通过段寄存器×16 ＋ 偏移两 得到物理地址，
;那么，我们就可以将这个物理地址放到段描述符中，以供保护模式下使用，
;因为保护模式下只能通过段选择子 ＋ 偏移量
xor eax, eax
mov ax, cs
shl eax, 4
add eax, LABEL_CODE32
mov word [GDT_CODE32 + 2],ax
shr eax, 16
mov byte [GDT_CODE32 + 4],al
mov byte [GDT_CODE32 + 7],ah
;得到段描述符表的物理地址，并将其放到GdtPtr中
xor eax, eax
mov ax, ds
shl eax, 4
add eax, GDT_BEGIN
mov dword [GdtPtr + 2],eax

;加载到gdtr,因为现在段描述符表在内存中，我们必须要让CPU知道段描述符 表在哪个位置
;通过使用lgdtr就可以将源加载到gdtr寄存器中
lgdt [GdtPtr]
;关中断
cli
;打开A20线
in al, 92h
or al, 00000010b
out 92h, al
;准备切换到保护模式，设置PE为1
mov eax, cr0
or eax, 1
mov cr0, eax
;现在已经处在保护模式分段机制下，所以寻址必须使用段选择子：偏移量来 寻址
;跳转到32位代码段中
;因为此时偏移量位32位，所以必须dword告诉编译器，不然，编译器将阶段 成16位
jmp dword SelectorCode32:0;跳转到32位代码段第一条指令开始执行

[SECTION .code32]
[BITS 32]
LABEL_CODE32:
mov ax, SelectorVideo
mov es, ax
xor edi, edi
mov edi, (80 * 10 + 10)
mov ah, 0ch
mov al, '{'
mov [es:edi],ax
jmp $
LenOfCode32 equ $ - LABEL_CODE32 
