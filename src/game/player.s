.include "src/game/lib/vga.s"

# void draw_player(int x, int y);
.global draw_player
.type draw_player, @function
draw_player:
    # Warning: no stackframe
	mov $VGA_ADDR, %rdi
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
    ret
