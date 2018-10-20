.include "src/game/lib/stack.s"

.section .game.data
GAME_SCORE_TXT: .asciz "SCORE: "

.section .game.text
.global render_score
render_score:
    SUB_PROLOGUE

    mov $2, %rdi
    mov $2, %rsi
    mov $GAME_SCORE_TXT, %rdx
    call print

    mov $56, %rdi
    mov $2, %rsi
    mov (GAME_SCORE), %rdx
    call print_num

    SUB_EPILOGUE
    ret
