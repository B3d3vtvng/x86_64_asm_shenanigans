%macro exit 0
    mov rax, 0x2000001
    mov rdi, 0
    syscall
%endmacro

stoi:
    ;rdi: char* to buffer containing digit string
    push rdi

    push rbp
    mov rbp, rsp
    and rsp, -16

    sub rsp, 48
    
    call len

    dec rax
    mov qword[rsp], 0 ; int res
    mov qword[rsp+8], rax ; int cur_exp
    mov qword[rsp+16], 0 ; int cur_idx
    ; rsp+24 -> exp_res
    mov qword[rsp+32], rdi ;char* str
    mov qword[rsp+40], rax

    xor rdx, rdx
    jmp .stoi_loop
.stoi_loop:
    mov rax, [rsp+16]
    cmp rax, qword[rsp+40]
    je .stoi_loop_exit

    mov rdi, [rsp+8]
    call pow10
    mov qword[rsp+24], rax
    
    mov rax, [rsp+32] ; char* str in rax
    mov rdi, [rsp+16] ; cur_idx in rdi
    mov dl, [rax+rdi] ; cur_idx_char in rdx
    sub dl, 48 ;align from ascii

    mov rax, [rsp+24] ; exp_res in rax
    imul rax, rdx ; exp_res * cur_idx_char in rax
    
    mov rdi, [rsp]
    add rax, rdi ; Add digit result to main result
    mov qword[rsp], rax

    inc qword[rsp+16]
    jmp .stoi_loop
.stoi_loop_exit:
    mov rax, [rsp]
    
    xor rdi, rdi
    xor rdx, rdx

    mov rsp, rbp
    pop rbp

    pop rdi
    ret


itoa:
    ; rdi: sint_64
    ; rsi: preallocated buffer for output
    push rdi
    push rsi

    push rbp
    mov rbp, rsp
    and rsp, -16

    sub rsp, 32

    mov qword[rsp], rdi ; sint_64 num
    mov qword[rsp+8], rsi ; char* buf
    mov qword[rsp+16], 1 ; bool trailing_0
    mov qword[rsp+24], 18 ; sint_64 cur_exp

    jmp .itoa_loop
.itoa_loop:
    cmp qword[rsp+24], 0
    jl .itoa_loop_end

    mov rdi, [rsp+24]
    call pow10
    mov rdi, rax

    mov rax, [rsp]
    xor rdx, rdx
    div rdi
    mov qword[rsp], rdx

    cmp rax, 0
    je .zero

    cmp qword[rsp+16], 1
    je .trailing_0_end

    jmp .ascii_convert
.zero:
    cmp qword[rsp+16], 1
    je .skip_0

    jmp .ascii_convert
.skip_0:
    dec qword[rsp+24]
    jmp .itoa_loop
.trailing_0_end:
    mov qword[rsp+16], 0
    
    jmp .ascii_convert
.ascii_convert:
    add rax, 48

    mov rdi, [rsp+8]
    mov rdx, 20
    sub rdx, [rsp+24]
    mov byte[rdi+rdx], al

    dec qword[rsp+24]

    jmp .itoa_loop
.itoa_loop_end:
    

    mov rax, [rsp+8]

    xor rdi, rdi
    xor rdx, rdx

    mov rsp, rbp
    pop rbp

    pop rsi
    pop rdi
    ret


strip_null:
    ; rdi: char* buf
    ; rsi: int len
    push rdi
    push rsi
    push rbx

    push rbp
    mov rbp, rsp
    and rsp, -16

    sub rsp, 16
    mov qword[rsp], rdi ; buf ptr
    mov qword[rsp+8], rsi ; len

    mov rdi, rsi
    call calculate_stack_alignment

    add rsi, rax
    sub rsp, rsi ; rsp+16... -> temporary buffer for cleared string

    mov rax, 0
    mov rbx, 0
    xor rdx, rdx
    jmp .strip_null_loop
.strip_null_loop:
    cmp rax, [rsp+8]
    je .strip_null_loop_end

    mov dl, [rsp+rax]
    cmp dl, 0
    je .skip_null

    mov byte[rsp+16+rbx], dl

    inc rax
    inc rbx

    jmp .strip_null_loop
.skip_null:
    inc rax
    jmp .skip_null_loop
.skip_null_loop_end:
    mov rdi, [rsp]
    mov rsi, rsp+16
    mov rdx, [rsp+8]
    call strcpy

    mov rsp, rbp
    pop rbp

    pop rbx
    pop rsi
    pop rdi

    ret

strcpy:
    ; rdi: char* to buf1
    ; rsi: char* to buf2
    ; rdx: int length
    xor rax, rax
    dec rdx
    jmp .strcpy_loop
.strcpy_loop:
    cmp rax, rdx
    je .strcpy_loop_end

    mov bl, [rsi+rax]
    mov byte[rdi+rax], bl

    jmp .strcpy_loop
.strcpy_loop_end
    mov rax, rdi

    ret


    
calculate_stack_alignment:
    ; rdi: alloc length
    xor rdx, rdx
    mov rax, rdi
    mov rdi, 16
    div rdi

    cmp rdx, 0
    je .is_aligned

    mov rax, 16
    sub rax, rdx

    xor rdi, rdi
    xor rdx, rdx

    ret
.is_aligned:
    mov rax, 0

    xor rdi, rdi
    xor rdx, rdx

    ret


pow10:
    ;rdi: exp: int
    
    push rbp
    mov rbp, rsp
    and rsp, -16

    push rdi

    mov rax, 1
    cmp rdi, 0
    je .exit
    mov rax, 10
    dec rdi
    jmp .pow10_loop
.pow10_loop:
    cmp rdi, 0
    je .exit
    imul rax, 10
    dec rdi
    jmp .pow10_loop
.exit:
    pop rdi

    mov rsp, rbp
    pop rbp

    ret


len:
    ;char* in rdi
    push rdi
    xor rax, rax
    jmp .len_loop
.len_loop:
    cmp byte[rdi+rax], 0
    je .len_loop_end
    inc rax
    jmp .len_loop
.len_loop_end:
    pop rdi
    ret


print:
    ;char* in rdi
    push rbp
    mov rbp, rsp
    and rsp, -16

    call len

    mov rdx, rax
    mov rax, 0x2000004
    mov rsi, rdi
    mov rdi, 1
    syscall

    mov rsp, rbp
    pop rbp
    ret


read:
    ;rdi: preallocated char* buffer for input
    ;rsi: length of the input buffer (int)
    push rbp
    mov rbp, rsp
    and rsp, -16

    push rdi
    push rsi

    mov rax, 0x2000003
    mov rdx, rsi
    mov rsi, rdi
    mov rdi, 0
    syscall

    pop rsi
    pop rdi

    mov rsp, rbp
    pop rbp

    ret