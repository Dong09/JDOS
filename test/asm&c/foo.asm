;; nasm -f elf foo.asm -o foo.o
;; gcc -m32 -c bar.c -o bar.o
;; ld -m elf_i386 -s foo.o bar.o -o foobar

extern choose ; int choose(int a, int b)

[section .data]
	num1st		dd	3 
	num2nd 		dd 	4

[section .text] 

global _start 
global myprint 

_start:
	push dword [num2nd] 
	push dword [num1st]
	call choose 
	add esp ,8 

	mov ebx,0 
	mov eax,1 				;sys_exir 系统调用
	int 0x80 

myprint:
	mov edx,[esp + 8] 		; len
	mov ecx,[esp + 4] 		; msg
	mov ebx,1 
	mov eax,4 				;sys_write 系统调用
	int 0x80 
	ret 