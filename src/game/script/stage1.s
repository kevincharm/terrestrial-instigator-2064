.include "src/game/lib/stack.s"
.file "src/game/script/stage1.s"

.section .game.data
STAGE1_TIMER: .quad 0
SPEAKER_ADMIRAL: .asciz "ADMIRAL:"
DIALOG1_1: .asciz "Resistance is futile."
DIALOG1_2: .asciz "Surrender now!"
SPEAKER_CAPTAIN: .asciz "JENKINS:"
DIALOG2_1: .asciz "We need to hold them"
DIALOG2_2: .asciz "off a little longer!"

.section .game.text
# void render_stage1();
# Doesn't actually render anything, just the stage script hooked up at 60Hz.
.global render_stage1
.type render_stage1, @function
render_stage1:
    SUB_PROLOGUE

    mov (GAME_TIMER), %r12
    cmp $180, %r12
    jl s1_dialog1
    cmp $360, %r12
    jl s1_dialog2
    jmp s1_dialog_end

s1_dialog1:
    mov $DIALOG1_1, %rdi
    mov $DIALOG1_2, %rsi
    call dialog_admiral
    jmp s1_dialog_end

s1_dialog2:
    mov $DIALOG2_1, %rdi
    mov $DIALOG2_2, %rsi
    call dialog_captain
    jmp s1_dialog_end

s1_dialog_end:
    # GAME_TIMER increments at 60Hz with the render. So 1sec=60ticks
    cmp $20, %r12
    je s1_spawn_mid
    cmp $50, %r12
    je s1_spawn_two
    cmp $120, %r12
    je s1_spawn_mid
    cmp $150, %r12
    je s1_spawn_mid

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
