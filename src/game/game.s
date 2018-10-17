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
.include "src/game/lib/vga.s"
.file "src/game/game.s"

.global gameInit
.global gameLoop

.section .game.data
FMTSTR: .asciz "%u\n"

.section .game.text

gameInit:
	SUB_PROLOGUE

	call init_player_cannon
	mov $10, %rdi
	mov $10, %rsi
	# call spawn_enemy

	SUB_EPILOGUE
	ret

gameLoop:
	SUB_PROLOGUE

	call clear_screen

	# Check if a key has been pressed
	call readKeyCode
	cmp $0, %rax
	mov %rax, %rdi
	call ps2_translate_scancode
	mov %rax, %rdi
	call render_player
	call render_player_cannon
	call render_enemies_big

	SUB_EPILOGUE
	ret

clear_screen:
	mov $VGA_ADDR, %rdi
	mov $(VGA_WIDTH * VGA_HEIGHT / 8), %rcx
cls_loop:
	test %rcx, %rcx
	jz cls_loop_end
	movq $0, (%rdi, %rcx, 8)
	dec %rcx
	jmp cls_loop
cls_loop_end:
	ret
