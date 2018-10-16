TARGET = amd64-elf-

# include local Makefile. Copy local.mk.template and adapt
include local.mk

PREFIX=/usr
COMPPATH=$(PREFIX)/bin
CC = $(COMPPATH)/$(TARGET)gcc
CXX = $(COMPPATH)/$(TARGET)g++
AS = $(COMPPATH)/$(TARGET)as
AR = $(COMPPATH)/$(TARGET)ar
NM = $(COMPPATH)/$(TARGET)nm
LD = $(COMPPATH)/$(TARGET)ld
OBJDUMP = $(COMPPATH)/$(TARGET)objdump
OBJCOPY = $(COMPPATH)/$(TARGET)objcopy
RANLIB = $(COMPPATH)/$(TARGET)ranlib
STRIP = $(COMPPATH)/$(TARGET)strip
CFLAGS = -ffreestanding -mcmodel=large -mno-red-zone -mno-mmx -mno-sse -mno-sse2 -mno-sse3 -O3 -Wall -Wextra -W -g

DOCKER_IMAGE=kevincharm/i686-elf-gcc-toolchain:5.5.0
DOCKER_SH=docker run -it --rm \
	-v `pwd`:/work \
	-w /work \
	--security-opt seccomp=unconfined \
	$(DOCKER_IMAGE) /bin/bash -c

KERNEL_SRCS=\
	src/game/assets/player/ship_vga.s \
	src/game/assets/enemy_big/enemy_big.s \
	src/game/*.s \
	src/kernel/*.s

.PHONY: clean all _all kvm qemu

all:
	$(DOCKER_SH) "make _all"

_all: out/bootloader out/kernel

out/bootloader: out/boot.o src/bootloader/link_boot.ld | HD_img
	$(LD) -nostdlib -T src/bootloader/link_boot.ld -o $@ out/boot.o
	dd if=out/bootloader of=HD_img conv=notrunc

out/kernel: out/kernel.o src/kernel/link_kernel.ld | HD_img
	$(LD) -nostdlib -T src/kernel/link_kernel.ld -o $@ out/kernel.o
	dd if=out/kernel of=HD_img bs=512 seek=17 conv=notrunc

out/boot.o: src/bootloader/*.s | out
	$(AS) src/bootloader/*.s -o $@

out/kernel.o: $(KERNEL_SRCS) | out
	$(AS) $(KERNEL_SRCS) -o $@

%.s: %.bmp
	node tools/img2s.js $<

HD_img:
	dd if=/dev/zero of=$@ count=512

QEMU=qemu-system-x86_64
run: all
	$(QEMU) HD_img

debug: all
	$(QEMU) -s -S HD_img

out:
	mkdir out

clean:
	rm -f HD_img
	rm -rf out
	find src/game/assets -type f -name '*.s' -delete
