###
 #  Stack frame macros
 ##
.macro SUB_PROLOGUE
    push %r15
    push %r14
    push %r13
    push %r12
    push %rbx
    push %rbp
    mov %rsp, %rbp
.endm

.macro SUB_EPILOGUE
    mov %rbp, %rsp
    pop %rbp
    pop %rbx
    pop %r12
    pop %r13
    pop %r14
    pop %r15
.endm

.macro SAVE_VOLATILE
    push %rax
    push %rcx
    push %rdx
    push %rsi
    push %rdi
.endm

.macro RESTORE_VOLATILE
    pop %rdi
    pop %rsi
    pop %rdx
    pop %rcx
    pop %rax
.endm
