/*
This file is part of gamelib-x64.

Copyright (C) 2014 Tim Hegeman

gamelib-x64 is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

gamelib-x64 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with gamelib-x64. If not, see <http://www.gnu.org/licenses/>.
*/

.include "src/game/lib/stack.s"
.file "src/game/game.s"

.global gameInit
.global gameLoop

.section .game.data
.equ VGA_MEM, 0xA0000
.equ VGA_WIDTH, 320
.equ VGA_HEIGHT, 200
FMTSTR: .asciz "%u\n"

.section .game.text

gameInit:
	SUB_PROLOGUE

	# test draw
	mov $VGA_MEM, %rdi
	mov $SHIP_VGA, %rsi
	# ship width = 16
	# ship height = 24

	mov $VGA_WIDTH, %rdx
	sub (SHIP_VGA_WIDTH), %rdx			# increment vga pointer by rdx after rendering a row

	xor %r12, %r12
loopy:
	cmp (SHIP_VGA_HEIGHT), %r12
	je loopy_end

	xor %r13, %r13
loopx:
	cmp (SHIP_VGA_WIDTH), %r13
	je loopx_end

	mov (%rsi), %al
	mov %al, (%rdi)
	inc %rsi							# advance the sprite pointer as we consume
	inc %rdi

	inc %r13
	jmp loopx
loopx_end:
	add %rdx, %rdi

	inc %r12
	jmp loopy
loopy_end:


	SUB_EPILOGUE
	ret

gameLoop:
	# Check if a key has been pressed
	call	readKeyCode
	cmpq	$0, %rax
	je		1f
	# If so, print a 'Y'
	movb	$'Y', %dl
	jmp		2f

1:
	# Otherwise, print a 'N'
	movb	$'N', %dl

2:
	movq	$0, %rdi
	movq	$0, %rsi
	movb	$0x0f, %cl
	call	putChar

	ret
