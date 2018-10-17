.include "src/game/lib/stack.s"
.file "src/game/enemy_big.s"

.section .game.data
#   uint64_t enemies[]
#   ((packed))struct enemies {
#       u16 x
#       u16 y
#       u16 anim_counter
#       u16 kind
#   }
.equ ENEMIES_BIG_LEN, (8 * 1)
.equ ENEMY_BIG_UNUSED, 0xffffffffffffffff
ENEMIES_BIG: .skip ENEMIES_BIG_LEN

.section .game.text
.global init_enemies_big
.type init_enemies_big, @function
init_enemies_big:
    SUB_PROLOGUE

    # clear the cannons array (fill with 0xff)
    xor %rcx, %rcx
    mov $ENEMIES_BIG, %rdi
cl_enemies_loop:
    cmp $ENEMIES_BIG_LEN, %rcx
    je cl_enemies_loop_end
    movb $0xff, (%rdi, %rcx, 1)
    inc %rcx
    jmp cl_enemies_loop
cl_enemies_loop_end:

    SUB_EPILOGUE
    ret

# void spawn_enemy(int x, int y);
# x and y are capped at 16 bits unsigned
.global spawn_enemy
.type spawn_enemy, @function
spawn_enemy:
    SUB_PROLOGUE

    push %rsi                       # save y
    push %rdi                       # save x

    mov $ENEMIES_BIG, %rbx
    xor %rcx, %rcx
se_find_free_block:
    # we're incrementing by 2 bytes each time
    # scale of 2 is being used for index %rcx
    cmp $ENEMIES_BIG_LEN, %rcx
    je se_spawn_abort                   # no free blocks
    cmpq $ENEMY_BIG_UNUSED, (%rbx, %rcx, 1)
    je se_found_free_block
    add $8, %rcx
    jmp se_find_free_block
se_found_free_block:
    # prep rax for loading x, y
    xor %rax, %rax
    pop %ax                         # get 16 bits from x
    mov %ax, (%rbx, %rcx, 1)        # u16 x
    pop %ax                         # get 16 bits from y
    mov %ax, 2(%rbx, %rcx, 1)       # u16 y
    movw $0, 4(%rbx, %rcx, 1)       # u16 anim_counter (init with 0)

se_spawn_abort:
    # fail silently ( # Y O L O )
    SUB_EPILOGUE
    ret

# void render_enemies_big();
.global render_enemies_big
.type render_enemies_big, @function
render_enemies_big:
    SUB_PROLOGUE

    mov $ENEMIES_BIG, %r12
    xor %rcx, %rcx
for_each_enemy_big:
    cmp $ENEMIES_BIG_LEN, %rcx
    je for_each_enemy_big_end
    # prep rax for x, y
    xor %rax, %rax
    mov (%r12, %rcx, 1), %ax        # x -> ax
    cmp $0xffff, %ax
    je reb_move_done
    xor %rbx, %rbx
    mov 2(%r12, %rcx, 1), %bx       # y -> bx
    cmp $168, %bx                   # TODO: HARD CODED VGA_HEIGHT-ENEMY_HEIGHT
    jge reb_free_enemy
    lea 4(%r12, %rcx, 1), %rdx      # *anim_count -> 3rd arg for draw_enemy_big
    # y++
    inc %bx
    # update the new y value in the cannon array
    mov %bx, 2(%r12, %rcx, 1)
    mov %rax, %rdi
    mov %rbx, %rsi
    call draw_enemy_big
    jmp reb_move_done
reb_free_enemy:
    movq $ENEMY_BIG_UNUSED, (%r12, %rcx, 1)
reb_move_done:
    add $8, %rcx
    jmp for_each_enemy_big
for_each_enemy_big_end:

    SUB_EPILOGUE
    ret

.equ ENEMY_BIG_HEIGHT, 32
.equ ENEMY_BIG_WIDTH, 32
.equ ENEMY_BIG_ANIM_PERIOD, 10

# void draw_enemy_big(int x, int y, uint16_t *anim_counter);
draw_enemy_big:
    SUB_PROLOGUE

    mov %rdx, %r15                  # *anim_counter -> r15

    mov (%r15), %ax
    dec %ax
    test %ax, %ax
    jz deb_p_anim_reset
    cmp $(ENEMY_BIG_ANIM_PERIOD / 2), %ax
    jl deb_p_anim_toggle
    jmp deb_p_anim_done
deb_p_anim_toggle:
    mov $1, %r11
    jmp deb_p_anim_done
deb_p_anim_reset:
    xor %r11, %r11
    mov $ENEMY_BIG_ANIM_PERIOD, %ax
deb_p_anim_done:
    mov %ax, (%r15)

	mov $VGA_ADDR, %r8
	mov $ENEMY_BIG_VGA, %r9

	mov $VGA_WIDTH, %rdx
    sub %rdi, %rdx                      # minus x
	sub $ENEMY_BIG_WIDTH, %rdx			    # increment vga pointer by rdx after rendering a row

    mov (ENEMY_BIG_VGA_WIDTH), %rcx
    sub $ENEMY_BIG_WIDTH, %rcx             # increment sprite pointer by rcx after rendering a row

    mov %rsi, %rax
    imul $VGA_WIDTH, %rax
    add %rax, %r8                       # increment vga pointer by (y * vga_row_width)

    test %r11, %r11
    jz deb_sprite_ptr_y_off_done
    mov (ENEMY_BIG_VGA_WIDTH), %rax
    imul $ENEMY_BIG_HEIGHT, %rax
    add %rax, %r9
deb_sprite_ptr_y_off_done:

	xor %r12, %r12
deb_loopy:
	cmp $ENEMY_BIG_HEIGHT, %r12
	je deb_loopy_end

    add %rdi, %r8                          # advance vga pointer by x pos per row
	xor %r13, %r13
deb_loopx:
	cmp $ENEMY_BIG_WIDTH, %r13
	je deb_loopx_end

    # When rendering a row, just copy & increment sequentially
	mov (%r9), %al
    cmp $36, %al
    je deb_loopx_skip                       # check transparent pixel
	mov %al, (%r8)
deb_loopx_skip:
    inc %r9
	inc %r8

	inc %r13
	jmp deb_loopx
deb_loopx_end:
	add %rdx, %r8                      # advance vga pointer by (row_width - ENEMY_BIG_width)
    add %rcx, %r9                      # advance sprite pointer by (sheet_width - sprite_offset_x)

	inc %r12
	jmp deb_loopy
deb_loopy_end:

    SUB_EPILOGUE
    ret

