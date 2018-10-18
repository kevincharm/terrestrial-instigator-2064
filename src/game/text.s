.include "src/game/lib/stack.s"

.equ FONT_HEIGHT, 8
.equ FONT_WIDTH, 8

.section .game.text
# void print(int x, int y, char *str);
.global print
print:
    SUB_PROLOGUE

	mov $VGA_ADDR, %r8
	mov $FONT_VGA, %r9
p_char:
    mov (%rdx), %al
    test %al, %al
    jz p_char_end

    # char to print in %al
    SAVE_VOLATILE
    xor %rdx, %rdx
    mov %al, %dl
    call putc
    RESTORE_VOLATILE

    # next char will be x+16
    add $FONT_WIDTH, %rdi
    inc %rdx
    jmp p_char
p_char_end:

    SUB_EPILOGUE
    ret

# void putc(int x, int y, char c);
.global putc
putc:
    SUB_PROLOGUE

    sub $0x20, %rdx
    imul $FONT_WIDTH, %rdx
    mov %rdx, %r15                      # sprite x_offset -> r15

	mov $VGA_ADDR, %r8
	mov $FONT_VGA, %r9

	mov $VGA_WIDTH, %rdx
    sub %rdi, %rdx                      # minus x
	sub $FONT_WIDTH, %rdx			    # increment vga pointer by rdx after rendering a row

    mov (FONT_VGA_WIDTH), %rcx
    sub $FONT_WIDTH, %rcx
    sub %r15, %rcx                      # increment sprite pointer by rcx after rendering a row

    mov %rsi, %rax
    imul $VGA_WIDTH, %rax
    add %rax, %r8                       # increment vga pointer by (y * vga_row_width)

	xor %r12, %r12
putc_y:
	cmp $FONT_HEIGHT, %r12
	je putc_y_end

    add %rdi, %r8                          # advance vga pointer by x pos per row
    add %r15, %r9         # advance sprite pointer by sprite_offset_x per row
	xor %r13, %r13
putc_x:
	cmp $FONT_WIDTH, %r13
	je putc_x_end

    # When rendering a row, just copy & increment sequentially
	mov (%r9), %al
    cmp $0, %al
    je putc_x_skip                       # check transparent pixel
	mov %al, (%r8)
putc_x_skip:
    inc %r9
	inc %r8

	inc %r13
	jmp putc_x
putc_x_end:
	add %rdx, %r8                      # advance vga pointer by (row_width - FONT_WIDTH)
    add %rcx, %r9                      # advance sprite pointer by (sheet_width - sprite_offset_x)

	inc %r12
	jmp putc_y
putc_y_end:

    SUB_EPILOGUE
    ret
