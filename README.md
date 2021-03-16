"# JDOS" 

需要工具：bochs gcc nasm ld
主要文件为 test 文件夹下的内容，必要的文件为以下文件。

########### 目录结构描述
test
├── boot
│   ├── include
│   |   ├── fat12hdr.inc
│   |   ├── lib.inc
│   |   ├── loader.inc
│   |   ├── pm.inc
│   ├── boot.asm
│   └── loader.asm
├── include
│   ├── const.h
│   ├── global.h
│   ├── protect.h
│   ├── proto.h
│   ├── string.h
│   └── type.h
├── kernel
│   ├── global.c
│   ├── i8259.c
│   ├── kernel.asm
│   ├── protect.c
│   └── start.c
├── lib
│   ├── klib.c
│   ├── kliba.asm
│   └── string.asm
├── b.img
├── bochsrc
└── Makefile

