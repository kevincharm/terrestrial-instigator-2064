.include "src/game/lib/stack.s"
.include "src/game/lib/vga.s"

.section .game.data
S0_INTRO_1: .asciz "In A.D. 2101"
S0_INTRO_2: .asciz "War was beginning."

.section .game.text
.global render_stage0_intro
render_stage0_intro:
    SUB_PROLOGUE

    # Only render if we are in stage 0 (title screen)
    mov (GAME_STAGE), %r12
    cmp $9, %r12
    jne s0_intro_end

    mov (GAME_TIMER), %r12
    cmp $180, %r12
    jl s0_intro_1
    cmp $360, %r12
    jl s0_intro_2
    jmp s0_intro_start_game

s0_intro_1:
    mov $114, %rdi
    mov $100, %rsi
    mov $S0_INTRO_1, %rdx
    call print
    jmp s0_intro_end

s0_intro_2:
    mov $100, %rdi
    mov $100, %rsi
    mov $S0_INTRO_2, %rdx
    call print
    jmp s0_intro_end

s0_intro_start_game:
    # at this point, a key was pressed. so start the game!
    movq $10, (GAME_STAGE)
    movq $0, (GAME_TIMER)

s0_intro_end:
    SUB_EPILOGUE
    ret
