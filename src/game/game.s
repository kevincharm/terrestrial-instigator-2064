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
.global GAME_TIMER
GAME_TIMER: .quad 0
.global GAME_STAGE
GAME_STAGE: .quad 0
.global GAME_SCORE
GAME_SCORE: .quad 0
.global HIGH_SCORE
HIGH_SCORE: .quad 0

.section .game.text

gameInit:
	SUB_PROLOGUE

	movq $0, (GAME_TIMER)
	movq $0, (GAME_STAGE)
	movq $0, (GAME_SCORE)

	call init_player_cannon
	call init_enemies_big

	SUB_EPILOGUE
	ret

gameLoop:
	SUB_PROLOGUE

	# call vsync
	call clear_screen

	# stages
	call render_stage0_title_screen
	call render_stage0_intro
	call render_stage1
	call render_leaderboard

	# increment the game timer at 60Hz
	incq (GAME_TIMER)

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

vsync:
	SUB_PROLOGUE

	mov $0x3da, %dx
1:
	inb %dx, %al
	test $8, %al
	jnz 1b
2:
	inb %dx, %al
	test $8, %al
	jnz 2b

	SUB_EPILOGUE
	ret
