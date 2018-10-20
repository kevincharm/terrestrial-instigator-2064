.include "src/game/lib/stack.s"
.file "src/game/script/stage1.s"

.section .game.data
STAGE1_TIMER: .quad 0
SPEAKER_ADMIRAL: .asciz "ADMIRAL:"
SPEAKER_CAPTAIN: .asciz "CAPTAIN:"
DIALOG_EMPTY: .asciz ""

DIALOG0_1: .asciz "Here they come !!"
DIALOG0_2 = DIALOG_EMPTY

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

DIALOG11_1: .asciz "It seems to be peaceful."
DIALOG11_2 = DIALOG_EMPTY

.equ DIALOG_PERIOD, 180

.section .game.text
# void render_stage1();
# Doesn't actually render anything, just the stage script hooked up at 60Hz.
.global render_stage1
.type render_stage1, @function
render_stage1:
    SUB_PROLOGUE

    mov (GAME_STAGE), %r12
    cmp $10, %r12
    jne s1_end

    # Check if a key has been pressed
	call readKeyCode
	mov %rax, %rdi
	call ps2_translate_scancode
	mov %rax, %rdi
	call render_player
	call render_enemies_big
	call render_player_cannon
    call render_score

    mov (GAME_TIMER), %r12
    cmp $(1 * DIALOG_PERIOD), %r12
    jl s1_dialog0
    cmp $(7 * DIALOG_PERIOD), %r12
    jl s1_dialog_end
    cmp $(8 * DIALOG_PERIOD), %r12
    jl s1_dialog1
    cmp $(9 * DIALOG_PERIOD), %r12
    jl s1_dialog2
    cmp $(10 * DIALOG_PERIOD), %r12
    jl s1_dialog3
    cmp $(19 * DIALOG_PERIOD), %r12
    jl s1_dialog_end
    cmp $(20 * DIALOG_PERIOD), %r12
    jl s1_dialog4
    cmp $(21 * DIALOG_PERIOD), %r12
    jl s1_dialog5
    cmp $(22 * DIALOG_PERIOD), %r12
    jl s1_dialog6
    cmp $(23 * DIALOG_PERIOD), %r12
    jl s1_dialog7
    cmp $(24 * DIALOG_PERIOD), %r12
    jl s1_dialog8
    cmp $(25 * DIALOG_PERIOD), %r12
    jl s1_dialog9
    cmp $(26 * DIALOG_PERIOD), %r12
    jl s1_dialog10
    cmp $(30 * DIALOG_PERIOD), %r12
    jl s1_dialog_end
    cmp $(32 * DIALOG_PERIOD), %r12
    jl s1_dialog11
    jmp s1_mission_complete

s1_dialog0:
    mov $DIALOG0_1, %rdi
    mov $DIALOG0_2, %rsi
    call dialog_captain
    jmp s1_dialog_end

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

s1_dialog11:
    mov $DIALOG11_1, %rdi
    mov $DIALOG11_2, %rsi
    call dialog_captain
    jmp s1_dialog_end

s1_dialog_end:

    # GAME_TIMER increments at 60Hz with the render. So 1sec=60ticks
    # wave one
    cmp $(1 * DIALOG_PERIOD), %r12
    je s1_spawn_mid
    cmp $(2 * DIALOG_PERIOD), %r12
    je s1_spawn_two_left
    cmp $(3 * DIALOG_PERIOD), %r12
    je s1_spawn_mid
    cmp $(4 * DIALOG_PERIOD), %r12
    je s1_spawn_two_right
    cmp $(6 * DIALOG_PERIOD), %r12
    je s1_spawn_three
    # wave two
    cmp $(10 * DIALOG_PERIOD), %r12
    je s1_spawn_mid
    cmp $(10 * DIALOG_PERIOD), %r12
    je s1_spawn_two_left
    cmp $(10 * DIALOG_PERIOD), %r12
    je s1_spawn_two_right
    cmp $(11 * DIALOG_PERIOD), %r12
    je s1_spawn_three
    cmp $(12 * DIALOG_PERIOD), %r12
    je s1_spawn_two_right
    cmp $(12 * DIALOG_PERIOD), %r12
    je s1_spawn_two_left
    cmp $(13 * DIALOG_PERIOD), %r12
    je s1_spawn_mid
    cmp $(13 * DIALOG_PERIOD), %r12
    je s1_spawn_two_left
    cmp $(13 * DIALOG_PERIOD), %r12
    je s1_spawn_two_right
    cmp $(14 * DIALOG_PERIOD), %r12
    je s1_spawn_three
    cmp $(15 * DIALOG_PERIOD), %r12
    je s1_spawn_two_right
    cmp $(15 * DIALOG_PERIOD), %r12
    je s1_spawn_two_left
    cmp $(16 * DIALOG_PERIOD), %r12
    je s1_spawn_mid
    cmp $(16 * DIALOG_PERIOD), %r12
    je s1_spawn_two_left
    cmp $(16 * DIALOG_PERIOD), %r12
    je s1_spawn_two_right
    cmp $(16 * DIALOG_PERIOD), %r12
    je s1_spawn_three
    cmp $(17 * DIALOG_PERIOD), %r12
    je s1_spawn_two_right
    cmp $(17 * DIALOG_PERIOD), %r12
    je s1_spawn_two_left
    # wave three
    cmp $(26 * DIALOG_PERIOD), %r12
    je s1_spawn_armada
    cmp $(27 * DIALOG_PERIOD), %r12
    je s1_spawn_armada
    cmp $(28 * DIALOG_PERIOD), %r12
    je s1_spawn_armada

    # No matches
    jmp s1_end

s1_spawn_mid:
	mov $(VGA_WIDTH / 2), %rdi
	mov $10, %rsi
	call spawn_enemy
    jmp s1_end

s1_spawn_two_left:
	mov $200, %rdi
	mov $10, %rsi
	call spawn_enemy
    mov $220, %rdi
	mov $0, %rsi
	call spawn_enemy
	mov $50, %rdi
	mov $10, %rsi
	call spawn_enemy
    mov $70, %rdi
	mov $30, %rsi
	call spawn_enemy
    jmp s1_end

s1_spawn_two_right:
    mov $280, %rdi
	mov $10, %rsi
	call spawn_enemy
    mov $260, %rdi
	mov $20, %rsi
	call spawn_enemy
	mov $80, %rdi
	mov $10, %rsi
	call spawn_enemy
    mov $40, %rdi
	mov $0, %rsi
	call spawn_enemy
    jmp s1_end

s1_spawn_three:
    mov $80, %rdi
	mov $10, %rsi
	call spawn_enemy
	mov $160, %rdi
	mov $10, %rsi
	call spawn_enemy
    mov $240, %rdi
	mov $10, %rsi
	call spawn_enemy
    jmp s1_end

s1_spawn_armada:
	mov $200, %rdi
	mov $10, %rsi
	call spawn_enemy
    mov $220, %rdi
	mov $0, %rsi
	call spawn_enemy
	mov $50, %rdi
	mov $10, %rsi
	call spawn_enemy
    mov $70, %rdi
	mov $30, %rsi
	call spawn_enemy
    mov $280, %rdi
	mov $10, %rsi
	call spawn_enemy
    mov $260, %rdi
	mov $20, %rsi
	call spawn_enemy
	mov $80, %rdi
	mov $10, %rsi
	call spawn_enemy
    mov $40, %rdi
	mov $0, %rsi
	call spawn_enemy
    jmp s1_end

s1_mission_complete:
    # set the high score
    movq $11, (GAME_STAGE)
    mov (GAME_SCORE), %rax
    mov (HIGH_SCORE), %rdx
    cmp %rdx, %rax
    jg s1_new_high_score
    jmp s1_end
s1_new_high_score:
    mov %rax, (HIGH_SCORE)
    jmp s1_end

s1_end:
    SUB_EPILOGUE
    ret
