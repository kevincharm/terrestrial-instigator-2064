.include "src/game/lib/stack.s"

.section .game.data
GAME_SCORE_TXT: .asciz "SCORE: "

.section .game.text
.global render_score
render_score:
    SUB_PROLOGUE

    # number -> string
    # rdx:rax / rcx
    xor %r14, %r14
    mov (GAME_SCORE), %rax
next_rem:
    xor %rdx, %rdx
    mov $10, %rcx
    div %rcx
    push %rdx
    inc %r14
    test %rax, %rax
    jnz next_rem
    test %rdx, %rdx
    jnz next_rem
no_more_digits:

    pop %rax
    test %rax, %rax
    jz leading_zero
not_leading_zero:
    push %rax
    jmp digits_rdy
leading_zero:
    cmp $1, %r14
    je not_leading_zero # the entire number is zero
    dec %r14
digits_rdy:

    mov $2, %rdi
    mov $2, %rsi
    mov $GAME_SCORE_TXT, %rdx
    call print
    # print the digits in the correct order
    xor %r15, %r15
print_digits:
    test %r14, %r14
    jz print_digits_end

    # figure out the x pos
    mov %r15, %rdi
    imul $8, %rdi
    add $56, %rdi       # + strlen(GAME_SCORE_TXT)

    mov $2, %rsi
    pop %rdx
    add $0x30, %rdx
    call putc

    dec %r14
    inc %r15
    jmp print_digits
print_digits_end:

    SUB_EPILOGUE
    ret
