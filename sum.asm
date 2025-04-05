; Name: Amrita Shrestha
; Lab Assignment 2 - Sum the File
; Lab Section: 03
; Date: 4/3/25

section .data
    pathname db "randomInt100.txt", 0       ; Establishes the path to the text file

    ; path name to other custom tester data files
    ; pathname db "sumTest1.txt", 0         ; Establishes the path to the custom text file
    ; pathname db "sumTest2.txt", 0         ; Establishes the path to the custom text file
    
    msg db "The sum is: ", 0x0A             ; Output message for sum result
    len equ $ - msg

    newline db 10, 0                        ; Newline character

section .bss
    buffer resb 1000                        ; Stores content from the file in buffer
    sum resd 1                              ; Stores the total sum of all the ints in file
    currNum resd 1                          ; Current data point
    sumStr resb 12                          ; ASCII representation of sum result

section .text
    global _start

_start:
    ; Opens the specified file
    mov eax, 5                              ; System open
    mov ebx, pathname                       ; Stores file name in ebx
    mov ecx, 0                              ; Reads file
    int 0x80                                ; Interrupt

    mov ebx, eax

    ; Reads file content into the buffer
    mov eax, 3                              ; System call
    mov ecx, buffer
    mov edx, 1000
    int 0x80

    mov edx, eax                            ; Reads the byte

    ; Initialize sum and currNum to store total sum result and current data point
    mov dword [sum], 0
    mov dword [currNum], 0
    mov esi, buffer

; Parses each data point in file
process_data_loop:
    mov al, [esi]                           ; Loads byte in esi into al
    cmp al, 0                               ; Compares character with null
    je exit                                 ; If null, jump to exit
    cmp al, '0'                             
    jl check_delimeter                      ; Checks for delimeter
    cmp al, '9'
    jg check_delimeter                      ; Checks for delimeter

    sub al, '0'                             ; Converts ASCII character to int
    movzx eax, al
    mov ebx, [currNum]                      ; Loads current data point to ebx
    imul ebx, ebx, 10                       ; Multiplies currNum by 10 (shift left by one decimal place)
    add ebx, eax                            ; Adds the new digit to current number
    mov [currNum], ebx                      ; Stores updated number back into currNum

    jmp next_character                      ; Jumps to next character

; Checks for a space to indicate end of a number
check_delimeter:
    mov eax, [currNum]
    add [sum], eax                          ; Adds current number to the total sum
    mov dword [currNum], 0                  ; Reset num to 0 for the next number

next_character:
    inc esi                                 ; Increments esi to point to the next character in the buffer
    jmp process_data_loop                   ; Processes the next digit until each digit is processed for currNum

; Stores the total sum and displays the result
exit:
    mov eax, [currNum]
    add [sum], eax

    ; Converts sum to its ASCII representation
    mov eax, [sum]
    mov edi, sumStr
    call int_to_str                         ; Converts the number to a string

    ; Outputs the sum onto the terminal
    mov eax, 4                              ; system call number (sys_write)
    mov ebx, 1                              ; file descriptor (stdout)
    mov ecx, msg                            ; message to write
    mov edx, len                            ; length of output message
    int 0x80                                ; calls kernel

    ; Outputs the sum
    mov eax, 4                              ; system call number (sys_write)
    mov ebx, 1                              ; file descriptor (stdout)
    mov ecx, sumStr                         ; pointer to sum result
    mov edx, 12                             ; length of sum result
    int 0x80                                ; calls kernel

    ; Print newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; Outputs the newline
    mov eax, 4                              ; system call number (sys_write)
    mov ebx, 1                              ; file descriptor (stdout)
    mov ecx, newline                        ; pointer to newline character
    mov edx, 1                              ; length of newline character
    int 0x80                                ; calls kernel

    ; Exit the program
    mov eax, 1                              ; system call to exit
    xor ebx, ebx                            ; Exit code 0
    int 0x80                                ; calls kernel

; Converts the int value of sum back to its string representation
int_to_str:
    mov ecx, 10
    mov ebx, 0
    mov edi, sumStr + 11
    mov byte [edi], 0                       ; Null-terminate string
    dec edi                                 ; Move edi one step back to store digits

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