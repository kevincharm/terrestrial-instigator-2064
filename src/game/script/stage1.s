.include "src/game/lib/stack.s"
.file "src/game/script/stage1.s"

.section .game.data
STAGE1_TIMER: .quad 0
TESTSTR: .asciz "somebody set up us"

.section .game.text
# void render_stage1();
# Doesn't actually render anything, just the stage script hooked up at 60Hz.
.global render_stage1
.type render_stage1, @function
render_stage1:
    SUB_PROLOGUE

    mov (GAME_TIMER), %r12

    # Text test
    SAVE_VOLATILE
    mov $10, %rdi
    mov $10, %rsi
    mov $TESTSTR, %rdx
    call print
    RESTORE_VOLATILE

    # GAME_TIMER increments at 60Hz with the render. So 1sec=60ticks
    cmp $20, %r12
    je s1_spawn_mid
    cmp $50, %r12
    je s1_spawn_two

    # No matches
    jmp s1_end

s1_spawn_mid:
	mov $(VGA_WIDTH / 2), %rdi
	mov $10, %rsi
	call spawn_enemy
    jmp s1_end

s1_spawn_two:
	mov $200, %rdi
	mov $10, %rsi
	call spawn_enemy
	mov $50, %rdi
	mov $10, %rsi
	call spawn_enemy
    jmp s1_end

s1_end:
    SUB_EPILOGUE
    ret
