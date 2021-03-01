;;======kernel.asm ======
;;[yankairen@dd test]$ nasm -f elf kernel.asm -o kernel.o
; [yankairen@dd test]$ nasm -f elf string.asm -o string.o
; [yankairen@dd test]$ nasm -f elf kliba.asm -o kliba.o
; [yankairen@dd test]$ gcc -m32 -c -fno-builtin -o start.o start.c
; [yankairen@dd test]$ ld -m elf_i386 -s -Ttext 0x30400 -o kernel.bin kernel.o string.o start.o kliba.o
; [yankairen@dd test]$ sudo mount -o loop b.img /mnt/floppy/
; [yankairen@dd test]$ sudo cp kernel.bin /mnt/floppy/
; [yankairen@dd test]$ sudo umount /mnt/floppy 
SELECTOR_KERNEL_CS      equ     8 

; 导入函数
extern cstart 
; 导入全局变量
extern gdt_ptr
extern idt_ptr
extern exception_handler

[SECTION .bss]
StackSpace          resb        2 * 1024 
StackTop:

[section .text]

global _start

global divide_error
global single_step_exception
global nmi
global breakpoint_exception 
global overflow 
global bounds_check
global inval_opcode 
global copr_not_available
global double_fault
global copr_seg_overrun
global inval_tss 
global segment_not_present
global stack_exception 
global general_protection 
global page_fault
global copr_error

_start:

    mov ah,0fh
    mov al,'K' 
    mov [gs:((80 * 1 + 39) * 2)],ax 

;;  此时 gs 指向 B8000h ，esp 指向 Loader 中某处，Kernel 入口是30400h
;;  cs、ds、es、fs、ss 表示的段统统指向内存地址 0h 
    ; jmp $ 
    mov esp,StackTop 
    sgdt [gdt_ptr]
    call cstart 

    lgdt [gdt_ptr]
    lidt [idt_ptr]

    jmp SELECTOR_KERNEL_CS:csinit 
csinit:
    ; push 0 
    ; popfd 
    ud2
    ; hlt
    

;;;;--------------------------------------------
divide_error:
    push 0xffffffff
    push 0
    jmp exception 

single_step_exception:
    push 0xffffffff
    push 1
    jmp exception 

nmi:
    push 0xffffffff
    push 2
    jmp exception 

breakpoint_exception:
    push 0xffffffff
    push 3
    jmp exception 

overflow:
    push 0xffffffff
    push 4
    jmp exception 

bounds_check:
    push 0xffffffff
    push 5
    jmp exception 

inval_opcode:
    push 0xffffffff
    push 6
    jmp exception 

copr_not_available:
    push 0xffffffff
    push 7
    jmp exception 

double_fault:
    push 8
    jmp exception 

copr_seg_overrun:
    push 0xffffffff
    push 9
    jmp exception 

inval_tss:
    push 10
    jmp exception 

segment_not_present:
    push 11
    jmp exception 

stack_exception:
    push 12
    jmp exception 

general_protection:
    push 13
    jmp exception 

page_fault:
    push 14
    jmp exception 

copr_error:
    push 0xffffffff
    push 16
    jmp exception 

exception:
    call exception_handler
    add esp, 4*2
    hlt 