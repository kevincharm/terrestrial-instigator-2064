.include "src/game/lib/stack.s"
.section .game.text
.global draw_captain
draw_captain:
    SUB_PROLOGUE

    mov $0, %rdi
    mov $70, %rsi

	mov $VGA_ADDR, %r8
	mov $CAPTAIN_JENKINS_VGA, %r9

	mov $VGA_WIDTH, %rdx
    sub %rdi, %rdx                      # minus x
	sub (CAPTAIN_JENKINS_VGA_WIDTH), %rdx			    # increment vga pointer by rdx after rendering a row

    mov %rsi, %rax
    imul $VGA_WIDTH, %rax
    add %rax, %r8                       # increment vga pointer by (y * vga_row_width)

	xor %r12, %r12
dp_y:
	cmp (CAPTAIN_JENKINS_VGA_HEIGHT), %r12
	je dp_y_end

    add %rdi, %r8                          # advance vga pointer by x pos per row
	xor %r13, %r13
dp_x:
	cmp (CAPTAIN_JENKINS_VGA_WIDTH), %r13
	je dp_x_end

    # When rendering a row, just copy & increment sequentially
	mov (%r9), %al
    cmp $36, %al
    je dp_x_skip                       # check transparent pixel
	mov %al, (%r8)
dp_x_skip:
    inc %r9
	inc %r8

	inc %r13
	jmp dp_x
dp_x_end:
	add %rdx, %r8                      # advance vga pointer by (row_width - FONT_WIDTH)

	inc %r12
	jmp dp_y
dp_y_end:

    SUB_EPILOGUE
    ret
