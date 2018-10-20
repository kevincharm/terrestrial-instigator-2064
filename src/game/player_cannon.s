.include "src/game/lib/vga.s"
.include "src/game/lib/stack.s"
.file "src/game/player_cannon.s"

.section .game.data
#   uint32_t cannons[]
#   ((packed))struct cannon { 
#       u16 x
#       u16 y
#   }
.equ PLAYER_CANNONS_SIZEOF, 4
.equ PLAYER_CANNONS_LEN, (PLAYER_CANNONS_SIZEOF * 30)
.equ PLAYER_CANNON_UNUSED, 0xffffffff
PLAYER_CANNONS: .skip PLAYER_CANNONS_LEN

.section .game.text
.global init_player_cannon
.type init_player_cannon, @function
init_player_cannon:
    SUB_PROLOGUE

    # clear the cannons array (fill with 0xff)
    xor %rcx, %rcx
    mov $PLAYER_CANNONS, %rdi
cl_cannon_loop:
    cmp $PLAYER_CANNONS_LEN, %rcx
    je cl_cannon_loop_end
    movb $0xff, (%rdi, %rcx, 1)
    inc %rcx
    jmp cl_cannon_loop
cl_cannon_loop_end:

    SUB_EPILOGUE
    ret

.global fire_player_cannon
.type fire_player_cannon, @function
fire_player_cannon:
    SUB_PROLOGUE

    mov $PLAYER_CANNONS, %rbx
    xor %rcx, %rcx
fpc_find_free_block:
    cmp $(PLAYER_CANNONS_LEN / PLAYER_CANNONS_SIZEOF), %rcx
    je fpc_fire_abort                   # no free blocks
    cmpl $PLAYER_CANNON_UNUSED, (%rbx, %rcx, 4)
    je fpc_found_free_block
    inc %rcx
    jmp fpc_find_free_block
fpc_found_free_block:
    # prep rax for loading x, y
    xor %rax, %rax
    mov (PLAYER_X), %ax
    mov %ax, (%rbx, %rcx, 4)        # x -> lsb
    mov (PLAYER_Y), %ax
    mov %ax, 2(%rbx, %rcx, 4)       # y -> msb

fpc_fire_abort:
    # fail silently ( # Y O L O )
    SUB_EPILOGUE
    ret

.global render_player_cannon
.type render_player_cannon, @function
render_player_cannon:
    SUB_PROLOGUE

    mov $PLAYER_CANNONS, %r12
    xor %rcx, %rcx
for_each_cannon:
    cmp $(PLAYER_CANNONS_LEN / PLAYER_CANNONS_SIZEOF), %rcx
    je for_each_cannon_end
    # prep rax for x, y
    xor %r15, %r15
    mov (%r12, %rcx, 4), %r15w        # x -> r15w
    cmp $0xffff, %r15w
    je move_done
    xor %rbx, %rbx
    mov 2(%r12, %rcx, 4), %bx       # y -> bx
    cmp $0, %bx
    jle free_cannon
    # y--
    dec %bx
    # update the new y value in the cannon array
    mov %bx, 2(%r12, %rcx, 4)
    SAVE_VOLATILE                   # we're using rcx as counter, a volatile reg
    mov %r15, %rdi
    mov %rbx, %rsi
    call draw_cannon
    mov %r15, %rdi
    mov %rbx, %rsi
    mov %rcx, %rdx
    call intersect_enemy
    RESTORE_VOLATILE
    jmp move_done
free_cannon:
    movl $PLAYER_CANNON_UNUSED, (%r12, %rcx, 4)
move_done:
    inc %rcx
    jmp for_each_cannon
for_each_cannon_end:

    SUB_EPILOGUE
    ret

# void intersect_enemy(int x, int y)
intersect_enemy:
    SUB_PROLOGUE

    mov $ENEMIES_BIG, %r12
    xor %r13, %r13
ie_each_enemy:
    cmp $(ENEMIES_BIG_LEN / ENEMIES_BIG_SIZEOF), %r13
    je ie_each_enemy_end

    # check for intersection with each enemy
    # cannon.x -> rdi
    # cannon.y -> rsi
    # cannon_i -> rdx
    # enemy.x -> ax
    xor %rax, %rax
    mov (%r12, %r13, 8), %ax
    # abort if unallocated
    cmp $0xffff, %ax
    je ie_no_intersect
    # enemy.y -> r15w
    xor %r15, %r15
    mov 2(%r12, %r13, 8), %r15w
    # all conditions must be met for intersection
    # abort if cannon.x < enemy.x
    cmp %rax, %rdi
    jl ie_no_intersect
    # abort if cannon.x > enemy.x + ENEMY_BIG_WIDTH
    add $ENEMY_BIG_WIDTH, %rax
    cmp %rax, %rdi
    jg ie_no_intersect
    # abort if cannon.y < enemy.y
    cmp %r15, %rsi
    jl ie_no_intersect
    # abort if cannon.y > enemy.y + ENEMY_BIG_HEIGHT
    add $ENEMY_BIG_HEIGHT, %r15
    cmp %r15, %rsi
    jg ie_no_intersect
    # at this point, we know that cannon intersects enemy, so free both
    mov $PLAYER_CANNONS, %rax
    movl $PLAYER_CANNON_UNUSED, (%rax, %rdx, 4)
    mov $ENEMIES_BIG, %rax
    movq $ENEMY_BIG_UNUSED, (%rax, %r13, 8)
    # give the player a point, she deserves it!
    incq (GAME_SCORE)
ie_no_intersect:

    inc %r13
    jmp ie_each_enemy
ie_each_enemy_end:

    SUB_EPILOGUE
    ret

# void draw_cannon(int x, int y)
draw_cannon:
    SUB_PROLOGUE

    mov $VGA_ADDR, %r8
    mov %rsi, %rax
    imul $VGA_WIDTH, %rax
    add %rdi, %rax                  # rax = y*vga_width + x
    add $(PLAYER_WIDTH / 2), %rax   # center the cannon
    movb $0x0b, (%r8, %rax, 1)

    SUB_EPILOGUE
    ret
