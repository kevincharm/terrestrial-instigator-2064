.include "src/game/lib/vga.s"
.include "src/game/lib/stack.s"
.file "src/game/player_cannon.s"

.section .game.data
#   uint32_t cannons[]
#   ((packed))struct cannon { 
#       u16 x
#       u16 y
#   }
.equ PLAYER_CANNONS_LEN, (4 * 10)
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
    cmp $PLAYER_CANNONS_LEN, %rcx
    je fpc_fire_abort                   # no free blocks
    cmpl $PLAYER_CANNON_UNUSED, (%rbx, %rcx, 1)
    je fpc_found_free_block
    add $4, %rcx
    jmp fpc_find_free_block
fpc_found_free_block:
    # prep rax for loading x, y
    xor %rax, %rax
    mov (PLAYER_X), %ax
    mov %ax, (%rbx, %rcx, 1)        # x -> lsb
    mov (PLAYER_Y), %ax
    mov %ax, 2(%rbx, %rcx, 1)       # y -> msb

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
    cmp $PLAYER_CANNONS_LEN, %rcx
    je for_each_cannon_end
    # prep rax for x, y
    xor %rax, %rax
    mov (%r12, %rcx, 1), %ax        # x -> ax
    cmp $0xffff, %ax
    je move_done
    xor %rbx, %rbx
    mov 2(%r12, %rcx, 1), %bx       # y -> bx
    cmp $0, %bx
    jle free_cannon
    # y--
    dec %bx
    # update the new y value in the cannon array
    mov %bx, 2(%r12, %rcx, 1)
    mov %rax, %rdi
    mov %rbx, %rsi
    call draw_cannon
    jmp move_done
free_cannon:
    movl $PLAYER_CANNON_UNUSED, (%r12, %rcx, 1)
move_done:
    add $4, %rcx
    jmp for_each_cannon
for_each_cannon_end:

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
