BaseOfLoader                equ         09000h 
OffsetOfLoader              equ         0100h 

BaseOfLoaderPhyAddr         equ         BaseOfLoader * 10h
KernelEntryPointPhyAddr     equ         0x30400

BaseOfKernelFile            equ         08000h    ; Kernel.BIN 被加载到的位置 ----  段地址
OffsetOfKernelFile          equ         0h        ; KERNEL.BIN 被加载到的位置 ---- 偏移地址

BaseOfKernelFilePhyAddr     equ         BaseOfKernelFile * 10h
