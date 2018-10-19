.include "src/game/lib/stack.s"
.section .game.text
# void dialog_admiral(const char *line1, const char *line2);
.global dialog_admiral
dialog_admiral:
    SUB_PROLOGUE

    push %rsi
    push %rdi

    call draw_admiral
    mov $30, %rdi
    mov $135, %rsi
    mov $SPEAKER_ADMIRAL, %rdx
    call print
    mov $30, %rdi
    mov $150, %rsi
    pop %rdx
    call print
    mov $30, %rdi
    mov $160, %rsi
    pop %rdx
    call print

    SUB_EPILOGUE
    ret

.global draw_admiral
draw_admiral:
    SUB_PROLOGUE

    mov $220, %rdi
    mov $70, %rsi

	mov $VGA_ADDR, %r8
	mov $ADMIRAL_VGA, %r9

	mov $VGA_WIDTH, %rdx
    sub %rdi, %rdx                      # minus x
	sub (ADMIRAL_VGA_WIDTH), %rdx			    # increment vga pointer by rdx after rendering a row

    mov %rsi, %rax
    imul $VGA_WIDTH, %rax
    add %rax, %r8                       # increment vga pointer by (y * vga_row_width)

	xor %r12, %r12
da_y:
	cmp (ADMIRAL_VGA_HEIGHT), %r12
	je da_y_end

    add %rdi, %r8                          # advance vga pointer by x pos per row
	xor %r13, %r13
da_x:
	cmp (ADMIRAL_VGA_WIDTH), %r13
	je da_x_end

    # When rendering a row, just copy & increment sequentially
	mov (%r9), %al
    cmp $36, %al
    je da_x_skip                       # check transparent pixel
	mov %al, (%r8)
da_x_skip:
    inc %r9
	inc %r8

	inc %r13
	jmp da_x
da_x_end:
	add %rdx, %r8                      # advance vga pointer by (row_width - FONT_WIDTH)

	inc %r12
	jmp da_y
da_y_end:

    SUB_EPILOGUE
    ret
