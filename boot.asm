org 0100h ;告诉编译器,程序加载到内存地址07c00h

    mov ax,cs

    mov ds,ax

    mov es,ax

    call DispStr    ;调用显示字符串例程

    jmp $          ;无限循环

DispStr:

    mov ax,BootMessage

    mov bp,ax      ;es:bp = 字符串地址

    mov cx,16      ;cx = 字符串长度

    mov ax,01301h  ; ah = 13h,  al = 01h

    mov bx,000ch    ;页号为0(bh = 0) 黑底红字(bl = 0Ch,高亮)

    mov dl,0

    int 10h        ;10h号中断

    ret

BootMessage:  db "Hello, OS World!"

times 510-($-$$)  db 0      ;填充剩下的空间，使生成的二进制代码恰好为512字节

dw 0xaa55          ;MBR结束标志
