.include "src/game/lib/stack.s"
.file "src/game/script/stage1.s"

.section .game.data
STAGE1_TIMER: .quad 0
SPEAKER_ADMIRAL: .asciz "ADMIRAL:"
SPEAKER_CAPTAIN: .asciz "CAPTAIN:"
DIALOG_EMPTY: .asciz ""

DIALOG1_1: .asciz "Somebody set up us the"
DIALOG1_2: .asciz "bomb."

DIALOG2_1: .asciz "What !"
DIALOG2_2: .asciz "It's you !!"

DIALOG3_1: .asciz "How are you gentlemen !!"
DIALOG3_2 = DIALOG_EMPTY

DIALOG4_1: .asciz "All your base are"
DIALOG4_2: .asciz "belong to us."

DIALOG5_1: .asciz "You are on the way to"
DIALOG5_2: .asciz "destruction."

DIALOG6_1: .asciz "What you say !!"
DIALOG6_2 = DIALOG_EMPTY

DIALOG7_1: .asciz "You have no chance to"
DIALOG7_2: .asciz "survive make your time."

DIALOG8_1: .asciz "Ha ha ha ha ...."
DIALOG8_2 = DIALOG_EMPTY

DIALOG9_1: .asciz "You know what you doing."
DIALOG9_2 = DIALOG_EMPTY

DIALOG10_1: .asciz "For great justice."
DIALOG10_2 = DIALOG_EMPTY

.equ DIALOG_PERIOD, 180

.section .game.text
# void render_stage1();
# Doesn't actually render anything, just the stage script hooked up at 60Hz.
.global render_stage1
.type render_stage1, @function
render_stage1:
    SUB_PROLOGUE

    mov (GAME_TIMER), %r12
    cmp $(1 * DIALOG_PERIOD), %r12
    jl s1_dialog1
    cmp $(2 * DIALOG_PERIOD), %r12
    jl s1_dialog2
    cmp $(3 * DIALOG_PERIOD), %r12
    jl s1_dialog3
    cmp $(4 * DIALOG_PERIOD), %r12
    jl s1_dialog4
    cmp $(5 * DIALOG_PERIOD), %r12
    jl s1_dialog5
    cmp $(6 * DIALOG_PERIOD), %r12
    jl s1_dialog6
    cmp $(7 * DIALOG_PERIOD), %r12
    jl s1_dialog7
    cmp $(8 * DIALOG_PERIOD), %r12
    jl s1_dialog8
    cmp $(9 * DIALOG_PERIOD), %r12
    jl s1_dialog9
    cmp $(10 * DIALOG_PERIOD), %r12
    jl s1_dialog10
    jmp s1_spawn_start

s1_dialog1:
    mov $DIALOG1_1, %rdi
    mov $DIALOG1_2, %rsi
    call dialog_captain
    jmp s1_dialog_end

s1_dialog2:
    mov $DIALOG2_1, %rdi
    mov $DIALOG2_2, %rsi
    call dialog_captain
    jmp s1_dialog_end

s1_dialog3:
    mov $DIALOG3_1, %rdi
    mov $DIALOG3_2, %rsi
    call dialog_admiral
    jmp s1_dialog_end

s1_dialog4:
    mov $DIALOG4_1, %rdi
    mov $DIALOG4_2, %rsi
    call dialog_admiral
    jmp s1_dialog_end

s1_dialog5:
    mov $DIALOG5_1, %rdi
    mov $DIALOG5_2, %rsi
    call dialog_admiral
    jmp s1_dialog_end

s1_dialog6:
    mov $DIALOG6_1, %rdi
    mov $DIALOG6_2, %rsi
    call dialog_captain
    jmp s1_dialog_end

s1_dialog7:
    mov $DIALOG7_1, %rdi
    mov $DIALOG7_2, %rsi
    call dialog_admiral
    jmp s1_dialog_end

s1_dialog8:
    mov $DIALOG8_1, %rdi
    mov $DIALOG8_2, %rsi
    call dialog_admiral
    jmp s1_dialog_end

s1_dialog9:
    mov $DIALOG9_1, %rdi
    mov $DIALOG9_2, %rsi
    call dialog_captain
    jmp s1_dialog_end

s1_dialog10:
    mov $DIALOG10_1, %rdi
    mov $DIALOG10_2, %rsi
    call dialog_captain
    jmp s1_dialog_end

s1_dialog_end:
    jmp s1_end

s1_spawn_start:
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
