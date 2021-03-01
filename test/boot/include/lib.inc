; ------------------------------------------------------------------------
; 显示 AL 中的数字
; ------------------------------------------------------------------------
DispAL:
	push	ecx
	push	edx
	push	edi

	mov	edi, [dwDispPos]

	mov	ah, 0Fh			; 0000b: 黑底    1111b: 白字
	mov	dl, al
	shr	al, 4
	mov	ecx, 2
.begin:
	and	al, 01111b
	cmp	al, 9
	ja	.1
	add	al, '0'
	jmp	.2
.1:
	sub	al, 0Ah
	add	al, 'A'
.2:
	mov	[gs:edi], ax
	add	edi, 2

	mov	al, dl
	loop	.begin
	;add	edi, 2

	mov	[dwDispPos], edi

	pop	edi
	pop	edx
	pop	ecx

	ret
; DispAL 结束-------------------------------------------------------------


; ------------------------------------------------------------------------
; 显示一个整形数
; ------------------------------------------------------------------------
DispInt:
	mov	eax, [esp + 4]
	shr	eax, 24
	call	DispAL

	mov	eax, [esp + 4]
	shr	eax, 16
	call	DispAL

	mov	eax, [esp + 4]
	shr	eax, 8
	call	DispAL

	mov	eax, [esp + 4]
	call	DispAL

	mov	ah, 07h			; 0000b: 黑底    0111b: 灰字
	mov	al, 'h'
	push	edi
	mov	edi, [dwDispPos]
	mov	[gs:edi], ax
	add	edi, 4
	mov	[dwDispPos], edi
	pop	edi

	ret
; DispInt 结束------------------------------------------------------------

; ------------------------------------------------------------------------
; 显示一个字符串
; ------------------------------------------------------------------------
DispStr:
	push ebp                    ;;ebp作为存取堆栈指针（存取堆栈中内容时所用到的指针），esp栈顶指针
	mov ebp, esp              ;;ebp指向堆栈栈顶
	push ebx                    ;;以后要用到bl，所以要压栈先保护起来
	push esi                     ;;源指针
	push edi             ;;目标指针   执行到这儿时ebp，esp的值已经不一样了。esp因为又压了三次所以加了12，ebp还是原来的ebp，push ebp后的堆栈指针

	mov esi, [ebp + 8] ; pszInfo   ;;跳进来之前push szPMMessage  esp-4，push ebp 后esp又-4，esp赋给ebp 所以ebp加8正好指向szPMMessage
	mov edi, [dwDispPos]            ;;将dwDisPos地址存放的显示位置赋给edi，初值为：(80 * 6 + 0) * 2 ; 屏幕第 6 行, 第 0 列。
	mov ah, 0Fh                          ;;ah的值表示要的是什么底什么颜色的字， ah=0ch就是黑底红字,可以改成och，看看效果！！！！

.1:

	lodsb                                  ;;  lodsb al,byte ptr ds:[esi],把ds，esi偏移处的一个字节赋给al。字符串为"In Protect Mode now. ^-^", 0Ah, 0Ah, 0
	test al, al                            ;;   该指令还可以用来测试一方寄存器是否为空: test ecx, ecx jz somewhere 如果ecx为零,设置ZF零标志为1,Jz跳转
	jz .2                                  ;;   这一段字符串的代码为：49 6e 20 50 72 6f 74 65 63 74 20 4d 6f 64 65 20 6e 6f 77 2e 20 5e 2d 5e 0a 0a 00   
	cmp al, 0Ah ; 是回车吗?          ;;     用bochs命令查看这段数据：xp   /27bx ds：0   27bx表示27个显示单元，以字节为单位，16进制显示。
	jnz .3
	push eax
	mov eax, edi
	mov bl, 160
	div bl
	and eax, 0FFh
	inc eax
	mov bl, 160
	mul bl
	mov edi, eax
	pop eax
	jmp .1                                 ;;上面代码的作用是使光标另起一行

.3:
	mov [gs:edi], ax                  ;;把ax值赋给视频段的地址处，从而显示出来。
	add edi, 2                           ;;传输的是ax，所以edi要加2
	jmp .1
.2:
	mov [dwDispPos], edi           ;;保护模式下的dwDisPos地址存放的是显示位置，初值为：(80 * 6 + 0) * 2 ; 屏幕第 6 行, 第 0 列。
	pop edi
	pop esi
	pop ebx
	pop ebp
	ret
; DispStr 结束------------------------------------------------------------

; ------------------------------------------------------------------------
; 换行
; ------------------------------------------------------------------------
DispReturn:
	push	szReturn
	call	DispStr			;printf("\n");
	add	esp, 4

	ret
; DispReturn 结束---------------------------------------------------------


; ------------------------------------------------------------------------
; 内存拷贝，仿 memcpy
; ------------------------------------------------------------------------
; void* MemCpy(void* es:pDest, void* ds:pSrc, int iSize);
; ------------------------------------------------------------------------
MemCpy:
	push	ebp
	mov	ebp, esp

	push	esi
	push	edi
	push	ecx

	mov	edi, [ebp + 8]	; Destination
	mov	esi, [ebp + 12]	; Source
	mov	ecx, [ebp + 16]	; Counter
.1:
	cmp	ecx, 0		; 判断计数器
	jz	.2		; 计数器为零时跳出

	mov	al, [ds:esi]		; ┓
	inc	esi			; ┃
					; ┣ 逐字节移动
	mov	byte [es:edi], al	; ┃
	inc	edi			; ┛

	dec	ecx		; 计数器减一
	jmp	.1		; 循环
.2:
	mov	eax, [ebp + 8]	; 返回值

	pop	ecx
	pop	edi
	pop	esi
	mov	esp, ebp
	pop	ebp

	ret			; 函数结束，返回
; MemCpy 结束-------------------------------------------------------------