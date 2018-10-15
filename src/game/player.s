.include "src/game/lib/vga.s"

.section .game.data
.equ PLAYER_IDLE_OFFSET_X, (2 * 16)
.equ PLAYER_HEIGHT, 24
.equ PLAYER_WIDTH, 16

# void draw_player(int x, int y);
.global draw_player
.type draw_player, @function
draw_player:
    # Warning: no stackframe
	mov $VGA_ADDR, %r8
	mov $SHIP_VGA, %r9

	mov $VGA_WIDTH, %rdx
    sub %rdi, %rdx                      # minus x
	sub $PLAYER_WIDTH, %rdx			    # increment vga pointer by rdx after rendering a row

    mov (SHIP_VGA_WIDTH), %rcx
    sub $PLAYER_WIDTH, %rcx
    sub $PLAYER_IDLE_OFFSET_X, %rcx     # increment sprite pointer by rcx after rendering a row
    mov $32, %rcx

    mov %rsi, %rax
    imul $VGA_WIDTH, %rax
    add %rax, %r8                       # increment vga pointer by (y * vga_row_width)

	xor %r12, %r12
loopy:
	cmp $PLAYER_HEIGHT, %r12
	je loopy_end

    add %rdi, %r8                          # advance vga pointer by x pos per row
    add $PLAYER_IDLE_OFFSET_X, %r9         # advance sprite pointer by sprite_offset_x per row
	xor %r13, %r13
loopx:
	cmp $PLAYER_WIDTH, %r13
	je loopx_end

    # When rendering a row, just copy & increment sequentially
	mov (%r9), %al
	mov %al, (%r8)
    inc %r9
	inc %r8

	inc %r13
	jmp loopx
loopx_end:
	add %rdx, %r8                      # advance vga pointer by (row_width - player_width)
    add %rcx, %r9                      # advance sprite pointer by (sheet_width - sprite_offset_x)

	inc %r12
	jmp loopy
loopy_end:
    ret
