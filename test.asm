%include "luislib.asm"

section .text align=16
    global _start

_start:
    lea rdi, [rel test_num]
    call stoi

    mov rdi, rax
    lea rsi, [rel test_buf]
    call itoa

    lea rdi, [rel test_buf]
    call print
    
    exit

section .bss
    test_buf: resb 18

section .data
    test_num: db "100"