#########################
# Makefile for Orange's #
#########################

## This is the command
## make image -f Makefile.boot ##

# Entry point 
ENTRYPOINT = 0x30400

# Offset of Entry point 
ENTRYOFFSET = 0x400

# Programs, flags,etc.
ASM = nasm
DASM = ndisasm
CC = gcc
LD = ld
ASMBFLAGS = -I boot/include/
ASMKFLAGS = -I include/ -f elf
CFLAGS = -I include/ -m32 -c -fno-builtin
LDFLAGS = -m elf_i386 -s -Ttext $(ENTRYPOINT)
DASMFLAGS = -u -o $(ENTRYPOINT) -e $(ENTRYOFFSET)

# This Programe 
ORANGESBOOT = boot/boot.bin boot/loader.bin
ORANGESKERNEL = kernel.bin
OBJS = kernel/kernel.o kernel/start.o kernel/i8259.o \
 kernel/global.o kernel/protect.o lib/kliba.o lib/string.o lib/klib.o
DASMOUTPUT = kernel.bin.asm

# ALL Phony Targets 
.PHONY : everything final image clean realclean disasm all buildimg

# Default starting position 
everything : $(ORANGESBOOT) $(ORANGESKERNEL)

all : realclean everything

final : all clean

image : final buildimg

clean:
	rm -f $(OBJS)

realclean :
	rm -f $(OBJS) $(ORANGESBOOT) $(ORANGESKERNEL)

disasm:
	$(DASM) $(DASMFLAGS) $(ORANGESKERNEL) > $(DASMOUTPUT)

# 
buildimg : 
	dd if=boot/boot.bin of=b.img bs=512 count=1 conv=notrunc
	sudo mount -o loop b.img /mnt/floppy
	sudo cp -fv boot/loader.bin /mnt/floppy
	sudo cp -fv kernel.bin /mnt/floppy
	sudo umount /mnt/floppy

boot/boot.bin : boot/boot.asm boot/include/loader.inc boot/include/fat12hdr.inc 
	$(ASM) $(ASMBFLAGS) -o $@ $<

boot/loader.bin : boot/loader.asm boot/include/loader.inc \
 boot/include/lib.inc boot/include/fat12hdr.inc boot/include/pm.inc 
	$(ASM) $(ASMBFLAGS) -o $@ $<

$(ORANGESKERNEL) : $(OBJS)
	$(LD) $(LDFLAGS) -o $(ORANGESKERNEL) $(OBJS)

kernel/kernel.o : kernel/kernel.asm
	$(ASM) $(ASMKFLAGS) -o $@ $<

kernel/start.o : kernel/start.c include/string.h include/type.h \
 include/const.h include/protect.h include/proto.h
	$(CC) $(CFLAGS) -o $@ $<

kernel/i8259.o : kernel/i8259.c include/type.h include/const.h \
 include/protect.h include/proto.h
	$(CC) $(CFLAGS) -o $@ $<

kernel/global.o : kernel/global.c include/type.h include/const.h \
 include/protect.h include/proto.h include/string.h include/global.h
	$(CC) $(CFLAGS) -o $@ $<

kernel/protect.o : kernel/protect.c include/type.h include/const.h \
 include/protect.h include/proto.h include/string.h include/global.h
	$(CC) $(CFLAGS) -o $@ $<

lib/kliba.o : lib/kliba.asm
	$(ASM) $(ASMKFLAGS) -o $@ $<

lib/klib.o : lib/klib.c include/type.h include/const.h \
 include/protect.h include/proto.h include/string.h include/global.h
	$(CC) $(CFLAGS) -o $@ $<

lib/string.o : lib/string.asm
	$(ASM) $(ASMKFLAGS) -o $@ $<

start.o: kernel/start.c /usr/include/stdc-predef.h include/type.h \
 include/const.h include/protect.h
