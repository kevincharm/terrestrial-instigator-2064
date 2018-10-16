.include "src/game/lib/stack.s"
.file "src/game/player_cannon.s"

.section .game.data
#   uint32_t cannons[]
#   ((packed))struct cannon { 
#       u16 x
#       u16 y
#   }
.equ PLAYER_CANNONS_LEN, (4 * 20)
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

    //

    SUB_EPILOGUE
    ret
