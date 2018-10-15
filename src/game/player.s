.include "src/game/lib/vga.s"

.equ PLAYER_IDLE_OFFSET_X, (2 * 16)
.equ PLAYER_HEIGHT, 24
.equ PLAYER_WIDTH, 16
.equ PLAYER_MOVE_UNIT, 8

.section .game.data
PLAYER_X: .quad 0
PLAYER_Y: .quad 0

.section .game.text
# void render_player(char key);
.global render_player
.type render_player, @function
render_player:
    SUB_PROLOGUE

    # check if a move key was pressed
chk_move_up:
    cmp $'w', %di
    jne chk_move_down
    cmpq $0, (PLAYER_Y)
    je chk_move_done                    # max(0, y)
    subq $PLAYER_MOVE_UNIT, (PLAYER_Y)
chk_move_down:
    cmp $'s', %di
    jne chk_move_left
    cmpq $(VGA_HEIGHT - PLAYER_HEIGHT), (PLAYER_Y)
    je chk_move_done                    # min(VGA_HEIGHT - PLAYER_HEIGHT, x)
    addq $PLAYER_MOVE_UNIT, (PLAYER_Y)
chk_move_left:
    cmp $'a', %di
    jne chk_move_right
    cmpq $0, (PLAYER_X)
    je chk_move_done                    # max(0, x)
    subq $PLAYER_MOVE_UNIT, (PLAYER_X)
chk_move_right:
    cmp $'d', %di
    jne chk_move_done
    cmpq $(VGA_WIDTH - PLAYER_WIDTH), (PLAYER_X)
    je chk_move_done                    # min(VGA_WIDTH - PLAYER_WIDTH, x)
    addq $PLAYER_MOVE_UNIT, (PLAYER_X)
chk_move_done:

    mov (PLAYER_X), %rdi
    mov (PLAYER_Y), %rsi
    call draw_player

    SUB_EPILOGUE
    ret

# void draw_player(int x, int y);
draw_player:
    SUB_PROLOGUE

	mov $VGA_ADDR, %r8
	mov $SHIP_VGA, %r9

	mov $VGA_WIDTH, %rdx
    sub %rdi, %rdx                      # minus x
	sub $PLAYER_WIDTH, %rdx			    # increment vga pointer by rdx after rendering a row

    mov (SHIP_VGA_WIDTH), %rcx
    sub $PLAYER_WIDTH, %rcx
    sub $PLAYER_IDLE_OFFSET_X, %rcx     # increment sprite pointer by rcx after rendering a row

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
    cmp $36, %al
    je loopx_skip                       # check transparent pixel
	mov %al, (%r8)
loopx_skip:
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

    SUB_EPILOGUE
    ret
