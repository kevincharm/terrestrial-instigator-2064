.include "src/game/lib/stack.s"
.include "src/game/lib/vga.s"

.section .game.data
S0_TITLE: .asciz "TERRESTRIAL INSTIGATOR"
S0_AUTHOR: .asciz "@kevincharm"
S0_CONTROLS_WASD: .asciz "* w,a,s,d to move"
S0_CONTROLS_E: .asciz "* e to shoot lazerssssss"
S0_CONTROLS_START: .asciz "* press any key to start"

.section .game.text
.global render_stage0_title_screen
render_stage0_title_screen:
    SUB_PROLOGUE

    # Only render if we are in stage 0 (title screen)
    mov (GAME_STAGE), %r12
    test %r12, %r12
    jnz s0_end

    # Check if a key has been pressed
	call readKeyCode
	cmp $0, %rax
    je render_s0
    # at this point, a key was pressed. so start the game!
    movq $10, (GAME_STAGE)
    movq $0, (GAME_TIMER)

render_s0:
    mov $76, %rdi
    mov $60, %rsi
    mov $S0_TITLE, %rdx
    call print

    mov $120, %rdi
    mov $74, %rsi
    mov $S0_AUTHOR, %rdx
    call print

    mov $2, %rdi
    mov $(VGA_HEIGHT - 30), %rsi
    mov $S0_CONTROLS_WASD, %rdx
    call print

    mov $2, %rdi
    mov $(VGA_HEIGHT - 20), %rsi
    mov $S0_CONTROLS_E, %rdx
    call print

    mov $2, %rdi
    mov $(VGA_HEIGHT - 10), %rsi
    mov $S0_CONTROLS_START, %rdx
    call print

s0_end:
    SUB_EPILOGUE
    ret
