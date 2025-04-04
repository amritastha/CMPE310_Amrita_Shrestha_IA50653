section .data
    pathname db "test.txt", 0
    newline db 10, 0
    msg db "Sum: ", 0x0A

section .bss
    buffer resb 1000
    sum resd 1
    currNum resd 1
    str1 resb 12

section .text
    global _start

_start:
    ; Open file
    mov eax, 5
    mov ebx, pathname
    mov ecx, 0
    int 0x80

    mov ebx, eax

    ; Read file into buffer
    mov eax, 3
    mov ecx, buffer
    mov edx, 1000
    int 0x80

    mov edx, eax

    ; Init sum and num
    mov dword [sum], 0
    mov dword [currNum], 0
    mov esi, buffer

read_data_loop:
    mov al, [esi]
    cmp al, 0
    je exit
    cmp al, '0'
    jl delim
    cmp al, '9'
    jg delim

    sub al, '0'
    movzx eax, al
    mov ebx, [currNum]
    imul ebx, ebx, 10
    add ebx, eax
    mov [currNum], ebx

    jmp next

delim:
    mov eax, [currNum]
    add [sum], eax
    mov dword [currNum], 0

next:
    inc esi
    jmp read_data_loop

exit:
    mov eax, [currNum]
    add [sum], eax

    mov eax, [sum]
    mov edi, str1
    call int_to_str

    ; Prints the sum is message
    mov eax, 4
    mov ebx, 1
    mov ecx, msg
    mov edx, 5
    int 0x80

    ; Print sum
    mov eax, 4
    mov ebx, 1
    mov ecx, str1
    mov edx, 12
    int 0x80

    ; Print newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; Exit
    mov eax, 1
    mov ebx, 0
    int 0x80

; Converts the sum back to a string
int_to_str:
    mov ecx, 10
    mov ebx, 0
    mov edi, str1 + 11
    mov byte [edi], 0
    dec edi

convert:
    mov edx, 0
    div ecx
    add dl, '0'
    mov [edi], dl
    dec edi
    inc ebx
    test eax, eax
    jnz convert

    inc edi
    ret