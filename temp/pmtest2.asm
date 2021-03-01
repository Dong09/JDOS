; %include "pm.inc"

; org 0100h
;         jmp LABEL_BEGIN

; [SECTION .gdt]
; 	;				段基址					段界限					属性
;     GDT_BEGIN: 		Descriptor 0, 			0,   					0
; 	GDT_NORMAL:		Descriptor 0,			0FFFFH,					DA_DRW
; 	GDT_CODE16:		Descriptor 0,			0FFFFH,					DA_C		
;     GDT_CODE32: 	Descriptor 0, 			LenOfCode32 - 1, 		DA_C + DA_32
; 	;
; 	GDT_DATA:		Descriptor 0,			DATALEN-1,				DA_DRW
; 	GDT_TEST:		Descriptor 0500000H,	0FFFFH,					DA_DRW
;     GDT_STACK: 		Descriptor 0, 			TopOfStack, 			DA_DRWA + DA_32
; 	;
;     GDT_VIDEO: 		Descriptor 0B8000H, 	0FFFFH,   				DA_DRW
; ; GDT 结束

; GdtLen equ $ - GDT_BEGIN
; GdtPtr 	dw GdtLen - 1
; 		dd 0

; ; 定义段选择子 在此处可以理解为 描述符的索引
; SelectorCode16		equ 	GDT_CODE16 - GDT_BEGIN
; SelectorCode32		equ 	GDT_CODE32 - GDT_BEGIN
; SelectorVideo 		equ 	GDT_VIDEO - GDT_BEGIN
; SelectorDATA		equ 	GDT_DATA - GDT_BEGIN
; SelectorTEST		equ 	GDT_TEST - GDT_BEGIN
; SelectorSTACK		equ 	GDT_STACK - GDT_BEGIN
; ; 选择子定义结束

; ; 数据段
; [SECTION .data1]
; ALIGN	32
; [BITS	32]

; LABEL_DATA:	
; SPValueInRealMode		dw 		0
; ;字符串
; PMMessage:				db 		"IN PROTECT MODE NOW"
; OffsetPMMessage			equ		PMMessage - $$
; StrTest:				db 		"ABCDEFGHIJKLMNOPQRSTUVWXYZ", 0
; OffsetStrTest			equ 	StrTest - $$ 
; DATALEN					equ 	$$ - LABEL_DATA

; ; 全局堆栈段
; [SECTION .gs]
; ALIGN	32
; [BITS	32]

; LABEL_STACK:
; 		times 512 db 0 
; TopOfStack				equ 	$ - LABEL_STACK - 1	


; [BITS 16]
; LABEL_BEGIN:
; 	mov ax, cs
; 	mov ds, ax
; 	mov es, ax
; 	mov ss, ax

; ;初始化32位代码段选择子
; ;我们可以在实模式下通过段寄存器×16 ＋ 偏移两 得到物理地址，
; ;那么，我们就可以将这个物理地址放到段描述符中，以供保护模式下使用，
; ;因为保护模式下只能通过段选择子 ＋ 偏移量
; 	xor eax, eax
; 	mov ax, cs
; 	shl eax, 4
; 	add eax, LABEL_CODE32
; 	mov word [GDT_CODE32 + 2],ax
; 	shr eax, 16
; 	mov byte [GDT_CODE32 + 4],al
; 	mov byte [GDT_CODE32 + 7],ah
; 	;得到段描述符表的物理地址，并将其放到GdtPtr中
; 	xor eax, eax
; 	mov ax, ds
; 	shl eax, 4
; 	add eax, GDT_BEGIN
; 	mov dword [GdtPtr + 2],eax

; 	;加载到gdtr,因为现在段描述符表在内存中，我们必须要让CPU知道段描述符 表在哪个位置
; 	;通过使用lgdtr就可以将源加载到gdtr寄存器中
; 	lgdt [GdtPtr]
; 	;关中断
; 	cli
; 	;打开A20线
; 	in al, 92h
; 	or al, 00000010b
; 	out 92h, al
; 	;准备切换到保护模式，设置PE为1
; 	mov eax, cr0
; 	or eax, 1
; 	mov cr0, eax
; 	;现在已经处在保护模式分段机制下，所以寻址必须使用段选择子：偏移量来 寻址
; 	;跳转到32位代码段中
; 	;因为此时偏移量位32位，所以必须dword告诉编译器，不然，编译器将阶段 成16位
; 	jmp dword SelectorCode32:0;跳转到32位代码段第一条指令开始执行

; [SECTION .code32]
; [BITS 32]
; LABEL_CODE32:
; 	mov ax, SelectorVideo
; 	mov es, ax
; 	xor edi, edi
; 	mov edi, (80 * 10 + 10)
; 	mov ah, 0ch
; 	mov al, '{'
; 	mov [es:edi],ax
; 	jmp $
; 	LenOfCode32 equ $ - LABEL_CODE32 







%include "pm.inc" ; 常量, 宏, 以及一些说明

org 0700h
 jmp LABEL_BEGIN                 ;LABEL_BEGIN 程序代码运行时的入口处，是在实模式下，不需要选择子。

[SECTION .gdt]
; GDT
;                                         段基址,       段界限     , 属性
LABEL_GDT:  Descriptor        0,                 0, 0       ; 空描述符
LABEL_DESC_NORMAL: Descriptor        0,            0ffffh, DA_DRW  ; Normal 描述符
LABEL_DESC_CODE32: Descriptor        0,  SegCode32Len - 1, DA_C + DA_32 ; 非一致代码段, 32
LABEL_DESC_CODE16: Descriptor        0,            0ffffh, DA_C  ; 非一致代码段, 16
LABEL_DESC_DATA: Descriptor        0, DataLen - 1, DA_DRW  ; Data
LABEL_DESC_STACK: Descriptor        0,        TopOfStack, DA_DRWA + DA_32 ; Stack, 32 位
LABEL_DESC_TEST: Descriptor 0500000h,            0ffffh, DA_DRW
LABEL_DESC_VIDEO: Descriptor  0B8000h,            0ffffh, DA_DRW  ; 显存首地址
; GDT 结束

GdtLen  equ $ - LABEL_GDT ; GDT长度
GdtPtr  dw GdtLen - 1 ; GDT界限
  dd 0  ; GDT基地址

; GDT 选择子
SelectorNormal  equ LABEL_DESC_NORMAL - LABEL_GDT
SelectorCode32  equ LABEL_DESC_CODE32 - LABEL_GDT
SelectorCode16  equ LABEL_DESC_CODE16 - LABEL_GDT    ;这个选择子跳转到下面的16位保护模式代码段。因为selector选择子是用在保护模式下的， 即使是16位的保护模式。
SelectorData  equ LABEL_DESC_DATA  - LABEL_GDT
SelectorStack  equ LABEL_DESC_STACK - LABEL_GDT
SelectorTest  equ LABEL_DESC_TEST  - LABEL_GDT
SelectorVideo  equ LABEL_DESC_VIDEO - LABEL_GDT
; END of [SECTION .gdt]

[SECTION .data1]  ; 数据段
ALIGN 32
[BITS 32]
LABEL_DATA:
SPValueInRealMode dw 0                     ;用来保存实模式下sp，并在跳回实模式前重新赋值给sp
; 字符串
PMMessage:  db "In Protect Mode now. ^-^", 0 ; 进入保护模式后显示此字符串
OffsetPMMessage  equ PMMessage - $$
StrTest:  db "ABCDEFGHIJKLMNOPQRSTUVWXYZ", 0
OffsetStrTest  equ StrTest - $$
DataLen   equ $ - LABEL_DATA
; END of [SECTION .data1]


; 全局堆栈段
[SECTION .gs]
ALIGN 32
[BITS 32]
LABEL_STACK:
 times 512 db 0

TopOfStack equ $ - LABEL_STACK - 1

; END of [SECTION .gs]


[SECTION .s16]                                          ;;这个段不需要选择子的，因为它是在实模式下。在这里要初始化段描述符的段基址。
[BITS 16]
LABEL_BEGIN:                                           ;;实模式下的代码
 mov ax, cs
 mov ds, ax
 mov es, ax
 mov ss, ax
 mov sp, 0100h

 mov [LABEL_GO_BACK_TO_REAL+3], ax      ;;改写跳回实模式前代码中的jmp 0：~这句中的0。0被实模式下的cs代替。
 mov [SPValueInRealMode], sp

 ; 初始化 16 位代码段描述符
 mov ax, cs
 movzx eax, ax
 shl eax, 4
 add eax, LABEL_SEG_CODE16
 mov word [LABEL_DESC_CODE16 + 2], ax
 shr eax, 16
 mov byte [LABEL_DESC_CODE16 + 4], al
 mov byte [LABEL_DESC_CODE16 + 7], ah

 ; 初始化 32 位代码段描述符
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

 ; 为加载 GDTR 作准备
 xor eax, eax
 mov ax, ds
 shl eax, 4
 add eax, LABEL_GDT  ; eax <- gdt 基地址
 mov dword [GdtPtr + 2], eax ; [GdtPtr + 2] <- gdt 基地址

 ; 加载 GDTR
 lgdt [GdtPtr]

 ; 关中断
 cli

 ; 打开地址线A20
 in al, 92h
 or al, 00000010b
 out 92h, al

 ; 准备切换到保护模式
 mov eax, cr0
 or eax, 1
 mov cr0, eax

 ; 真正进入保护模式
 jmp dword SelectorCode32:0    ;;执行这一句会把 SelectorCode32 装入 cs, 并跳转到32位代码保护模式处

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LABEL_REAL_ENTRY:  ; 从保护模式跳回到实模式就到了这里
 mov ax, cs
 mov ds, ax
 mov es, ax
 mov ss, ax

 mov sp, [SPValueInRealMode]

 in al, 92h  ; ┓
 and al, 11111101b ; ┣ 关闭 A20 地址线
 out 92h, al  ; ┛

 sti   ; 开中断

 mov ax, 4c00h ; ┓
 int 21h  ; ┛回到 DOS                                      

 ; END of [SECTION .s16]              ;;返回到实模式下完成回到DOS的功能               

[SECTION .s32]; 32 位代码段. 由实模式跳入.            ;;32位代码保护模式，需要选择子SelectorCode32
[BITS 32]

LABEL_SEG_CODE32:
 mov ax, SelectorData
 mov ds, ax   ; 数据段选择子
 mov ax, SelectorTest
 mov es, ax   ; 测试段选择子
 mov ax, SelectorVideo
 mov gs, ax   ; 视频段选择子

 mov ax, SelectorStack
 mov ss, ax   ; 堆栈段选择子

 mov esp, TopOfStack


 ; 下面显示一个字符串
 mov ah, 0Ch   ; 0000: 黑底    1100: 红字
 xor esi, esi
 xor edi, edi
 mov esi, OffsetPMMessage ; 源数据偏移
 mov edi, (80 * 10 + 0) * 2 ; 目的数据偏移。屏幕第 10 行, 第 0 列。
 cld
.1:
 lodsb
 test al, al
 jz .2
 mov [gs:edi], ax
 add edi, 2
 jmp .1
.2: ; 显示完毕

 call DispReturn

 call TestRead
 call TestWrite
 call TestRead

 ; 到此停止
 jmp SelectorCode16:0                       ;;跳转到16位代码的保护模式，需要选择子。

                                                       ;;同时完成对CS高速缓冲寄存器的段属性和段界限的赋值,使之符合实模式要求

;-------------------------------------------------------------------------
; ------------------------------------------------------------------------以下为函数（子程序）定义
TestRead:
 xor esi, esi
 mov ecx, 8
.loop
 mov al, [es:esi]
 call DispAL
 inc esi
 loop .loop

 call DispReturn

 ret
; TestRead 结束-----------------------------------------------------------


; ------------------------------------------------------------------------
TestWrite:
 push esi
 push edi
 xor esi, esi
 xor edi, edi
 mov esi, OffsetStrTest ; 源数据偏移
 cld
.1:
 lodsb
 test al, al
 jz .2
 mov [es:edi], al
 inc edi
 jmp .1
.2:

 pop edi
 pop esi

 ret
; TestWrite 结束----------------------------------------------------------


; ------------------------------------------------------------------------
; 显示 AL 中的数字
; 默认地:
; 数字已经存在 AL 中
; edi 始终指向要显示的下一个字符的位置
; 被改变的寄存器:
; ax, edi
; ------------------------------------------------------------------------
DispAL:
 push ecx
 push edx                                           ;;push主要看看那些要用到，那些要xor，循环用的ecx一般都要push

 mov ah, 0Ch   ; 0000: 黑底    1100: 红字
 mov dl, al
 shr al, 4                                             ;;先对al的高4位处理
 mov ecx, 2                                                   
.begin:
 and al, 01111b                                    ;;第二次循环处理al的低四位
 cmp al, 9
 ja .1
 add al, '0'
 jmp .2
.1:
 sub al, 0Ah
 add al, 'A'
.2:
 mov [gs:edi], ax
 add edi, 2

 mov al, dl                                    ;;要处理al的低四位
 loop .begin
 add edi, 2

 pop edx
 pop ecx

 ret
; DispAL 结束-------------------------------------------------------------


; ------------------------------------------------------------------------
DispReturn:
 push eax
 push ebx
 mov eax, edi
 mov bl, 160
 div bl
 and eax, 0FFh
 inc eax
 mov bl, 160
 mul bl
 mov edi, eax
 pop ebx
 pop eax

 ret
; DispReturn 结束---------------------------------------------------------
;-------------------------------------------------------------函数定义结束

SegCode32Len equ $ - LABEL_SEG_CODE32
; END of [SECTION .s32]


; 16 位代码段. 由 32 位代码段跳入, 跳出后到实模式
[SECTION .s16code]
ALIGN 32
[BITS 16]
LABEL_SEG_CODE16:                                       ;;16位代码保护模式，需要选择子SelectorCode16跳转到这儿，在这里主要是从新跳回到实模式。
 ; 跳回实模式:
 mov ax, SelectorNormal              ;;通过符合实模式段属性，段界限的选择子SelectorNormal，对个寄存器的高速缓存重新赋值，使之符合实模式的状态
 mov ds, ax
 mov es, ax
 mov fs, ax
 mov gs, ax
 mov ss, ax

 mov eax, cr0
 and al, 11111110b
 mov cr0, eax

LABEL_GO_BACK_TO_REAL:
 jmp 0:LABEL_REAL_ENTRY ; 段地址会在程序开始处被设置成正确的值   ;;通过实模式下的跳转，完成对CS的赋值

Code16Len equ $ - LABEL_SEG_CODE16 ;;对上句应由LABEL_REAL_ENTRY这个门牌号，推测到那个街道号LABEL_BEGIN。街道号，门牌号好

; END of [SECTION .s16code]              ;;发现保护模式下的编程很清楚，大量运用[section .!!!]来间隔代码，通过选择子完成各section之间的跳转。
;注：这个代码是建立在原来代码基础上的，原本没这么长。