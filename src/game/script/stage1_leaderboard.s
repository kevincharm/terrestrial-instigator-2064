.include "src/game/lib/stack.s"

.section .game.data
MISSION_COMPLETE: .asciz "Mission complete!"
LEADERBOARD_YOUR_SCORE: .asciz "YOUR SCORE:"
LEADERBOARD_HIGH_SCORE: .asciz "HIGH SCORE:"
LEADERBOARD_NEW_GAME: .asciz "* press any key to start a new game"

.section .game.text
.global render_leaderboard
render_leaderboard:
    SUB_PROLOGUE

    mov (GAME_STAGE), %r12
    cmp $11, %r12
    jne s1_leaderboard_end

    # Check if a key has been pressed
	call readKeyCode
    test %rax, %rax
    jnz s1_leaderboard_new_game

    mov $92, %rdi
    mov $80, %rsi
    mov $MISSION_COMPLETE, %rdx
    call print

    mov $100, %rdi
    mov $110, %rsi
    mov $LEADERBOARD_YOUR_SCORE, %rdx
    call print

    mov $196, %rdi
    mov $110, %rsi
    mov (GAME_SCORE), %rdx
    call print_num

    mov $100, %rdi
    mov $120, %rsi
    mov $LEADERBOARD_HIGH_SCORE, %rdx
    call print

    mov $196, %rdi
    mov $120, %rsi
    mov (HIGH_SCORE), %rdx
    call print_num

    mov $2, %rdi
    mov $190, %rsi
    mov $LEADERBOARD_NEW_GAME, %rdx
    call print

    jmp s1_leaderboard_end

s1_leaderboard_new_game:
    call gameInit
    jmp s1_leaderboard_end

s1_leaderboard_end:
    SUB_EPILOGUE
    ret
