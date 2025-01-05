%include "luislib.asm"

section .text align=16
    global _start

_start:
    lea rdi, [rel num_str]
    call stoi

    mov rdi, rax
    lea rsi, [rel buf]
    call itoa

    lea rdi, [rel buf]
    call print

    exit

section .bss
    buf: resb 10

section .data
    num_str: db "100"