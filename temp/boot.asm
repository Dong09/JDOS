
org 0100h 

BaseOfStack                 equ    07c00h    ; Boot状态下堆栈基地址(栈底, 从这个位置向低地址生长)
BaseOfLoader                equ    09000h    ; LOADER.BIN 被加载到的位置 ----  段地址
OffsetOfLoader              equ    0100h     ; LOADER.BIN 被加载到的位置 ---- 偏移地址
RootDirSectors              equ    14        ; 根目录占用空间
SectorNoOfRootDirectory     equ    19        ; Root Directory 的第一个扇区号


;;=============================================================

    jmp short LABEL_START
    nop                         ; 此nop不能少

    ;FAT12磁盘的头
    BS_OEMName          DB 'ForrestY'    ; OEM String, 必须 8 个字节
    BPB_BytsPerSec      DW 512        ; 每扇区字节数
    BPB_SecPerClus      DB 1        ; 每簇多少扇区
    BPB_RsvdSecCnt      DW 1        ; Boot 记录占用多少扇区
    BPB_NumFATs         DB 2        ; 共有多少 FAT 表
    BPB_RootEntCnt      DW 224        ; 根目录文件数最大值
    BPB_TotSec16        DW 2880        ; 逻辑扇区总数
    BPB_Media           DB 0xF0        ; 媒体描述符
    BPB_FATSz16         DW 9        ; 每FAT扇区数
    BPB_SecPerTrk       DW 18        ; 每磁道扇区数
    BPB_NumHeads        DW 2        ; 磁头数(面数)
    BPB_HiddSec         DD 0        ; 隐藏扇区数
    BPB_TotSec32        DD 0        ; 如果 wTotalSectorCount 是 0 由这个值记录扇区数
    BS_DrvNum           DB 0        ; 中断 13 的驱动器号
    BS_Reserved1        DB 0        ; 未使用
    BS_BootSig          DB 29h        ; 扩展引导标记 (29h)
    BS_VolID            DD 0        ; 卷序列号
    BS_VolLab           DB 'Tinix0.01  '; 卷标, 必须 11 个字节
    BS_FileSysType      DB 'FAT12   '    ; 文件系统类型, 必须 8个字节  

LABEL_START:    
    mov ax,cs 
    mov ds,ax 
    mov es,ax 
    mov ss,ax 
    mov sp,BaseOfStack 
    
    ;清屏
    mov ax,0600h 
    mov bx,0700h 
    mov cx,0 
    mov dx,0184fh 
    int 10h                 ;int 10h 设置显示模式，字符和字符串输出

    mov dh,0 
    call DispStr 

    xor ah,ah 
    xor dl,dl 
    int 13h                 ;int 13h 直接磁盘服务:软驱复位

    ;在A盘的根目录寻找LOADER.BIN
    mov word [wSectorNo],SectorNoOfRootDirectory
LABEL_SEARCH_IN_ROOT_DIR_BEGIN:
    cmp word [wRootDirSizeForLoop],0
    jz LABEL_NO_LOADERBIN
    dec word [wRootDirSizeForLoop]
    mov ax,BaseOfLoader
    mov es,ax 
    mov bx,OffsetOfLoader 
    mov ax,[wSectorNo]
    mov cl,1 
    call ReadSecotr
    
    mov si,LoaderFileName
    mov di,OffsetOfLoader 
    cld 
    mov dx,10h 
LABEL_SEARCH_FOR_LOADERBIN:
    cmp    dx, 0                                        ; ┓循环次数控制,
    jz    LABEL_GOTO_NEXT_SECTOR_IN_ROOT_DIR    ; ┣如果已经读完了一个 Sector,
    dec    dx                                            ; ┛就跳到下一个 Sector
    mov    cx, 11                                      ;11个字符，有一个不一样则不是所要找的文件
LABEL_CMP_FILENAME:
    cmp    cx, 0
    jz    LABEL_FILENAME_FOUND    ; 如果比较了 11 个字符都相等, 表示找到
    dec    cx
    lodsb                ; ds:si -> al
    cmp    al, byte [es:di]
    jz    LABEL_GO_ON
    jmp    LABEL_DIFFERENT        ; 只要发现不一样的字符就表明本 DirectoryEntry 不是
; 我们要找的 LOADER.BIN
LABEL_GO_ON:
    inc    di
    jmp    LABEL_CMP_FILENAME    ;    继续循环

LABEL_DIFFERENT:
    and    di, 0FFE0h                        ; else ┓    di &= E0 为了让它指向本条目开头
    add    di, 20h                            ;     ┃
    mov    si, LoaderFileName                    ;     ┣ di += 20h  下一个目录条目
    jmp    LABEL_SEARCH_FOR_LOADERBIN;    ┛

LABEL_GOTO_NEXT_SECTOR_IN_ROOT_DIR:
    add    word [wSectorNo], 1
    jmp    LABEL_SEARCH_IN_ROOT_DIR_BEGIN

LABEL_NO_LOADERBIN:
    mov    dh, 2            ; "No LOADER."
    call    DispStr            ; 显示字符串
%ifdef    _BOOT_DEBUG_
    mov    ax, 4c00h        ; ┓
    int    21h            ; ┛没有找到 LOADER.BIN, 回到 DOS
%else
    jmp    $            ; 没有找到 LOADER.BIN, 死循环在这里
%endif

LABEL_FILENAME_FOUND:            ; 找到 LOADER.BIN 后便来到这里继续
    jmp $
;     mov    ax, RootDirSectors
;     and    di, 0FFE0h        ; di -> 当前条目的开始
;     add    di, 01Ah        ; di -> 首 Sector,该条目对应的开始簇号(扇区号)，看根目录条目格式表
;     mov    cx, word [es:di]
;     push    cx            ; 保存此 Sector 在 FAT 中的序号
;     add    cx, ax
;     add    cx, DeltaSectorNo    ; 这句完成时 cl 里面变成 LOADER.BIN 的起始扇区号 (从 0 开始数的序号)
;     mov    ax, BaseOfLoader
;     mov    es, ax            ; es <- BaseOfLoader
;     mov    bx, OffsetOfLoader    ; bx <- OffsetOfLoader    于是, es:bx = BaseOfLoader:OffsetOfLoader = BaseOfLoader * 10h + OffsetOfLoader
;     mov    ax, cx            ; ax <- Sector 号

; LABEL_GOON_LOADING_FILE:
;     push    ax            ; ┓
;     push    bx            ; ┃
;     mov    ah, 0Eh            ; ┃ 每读一个扇区就在 "Booting  " 后面打一个点, 形成这样的效果:
;     mov    al, '.'            ; ┃
;     mov    bl, 0Fh            ; ┃ Booting ......
;     int    10h            ; ┃AL=字符，BH=页码，BL=颜色（只适用于图形模式）
;     pop    bx            ; ┃
;     pop    ax            ; ┛

;     mov    cl, 1
;     call    ReadSector
;     pop    ax            ; 取出此 Sector 在 FAT 中的序号,见132行
;     call    GetFATEntry
;     cmp    ax, 0FFFh
;     jz    LABEL_FILE_LOADED
;     push    ax            ; 保存 Sector 在 FAT 中的序号
;     mov    dx, RootDirSectors
;     add    ax, dx
;     add    ax, DeltaSectorNo
;     add    bx, [BPB_BytsPerSec]
;     jmp    LABEL_GOON_LOADING_FILE
; LABEL_FILE_LOADED:

;     mov    dh, 1            ; "Ready."
;     call    DispStr            ; 显示字符串

; ; *****************************************************************************************************
;     jmp    BaseOfLoader:OffsetOfLoader    ; 这一句正式跳转到已加载到内存中的 LOADER.BIN 的开始处
;                         ; 开始执行 LOADER.BIN 的代码
;                         ; Boot Sector 的使命到此结束
; ; *****************************************************************************************************




;;========================================================================  
;变量
wRootDirSizeForLoop     dw      RootDirSectors
wSectorNo               dw      0        ; 要读取的扇区号
bOdd                    db      0        ; 奇数还是偶数
;字符串
LoaderFileName          db      'LOADER BIN', 0
MessageLength           equ     9 
BootMessage             db      'Booting..'
Message1                db      'Ready.   '
Message2                db      'No LOADER'


;;========================================================================    
DispStr:    
    mov ax,MessageLength 
    mul dh 
    add ax,BootMessage 
    mov bp,ax 
    mov ax,ds 
    mov es,ax 
    mov cx,MessageLength 
    mov ax,01301h 
    mov bx,0007h 
    mov dl,0 
    int 10h 
    ret 

;;========================================================================  
ReadSecotr:
    push bp 
    mov bp,sp 
    sub esp,2 

    mov byte [bp-2],cl 
    push bx 
    mov bl,[BPB_SecPerTrk]
    div bl 
    inc ah 
    mov cl,ah 
    mov dh,al
    shr al,1 
    mov ch,al 
    and dh,1
    pop bx 

    mov dl,[BS_DrvNum]
.GoOnReading:
    mov ah,2 
    mov al,byte [bp-2]
    int 13h 
    jc .GoOnReading

    add esp,2 
    pop bp 

    ret 
