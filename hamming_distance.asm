; Name: Amrita Shrestha
; Lab Assignment 1 - Hamming Distance 
; Lab Section: 03
; Date: 3/6/25

section .data
    ; first set of string inputs
    str1 db 'foo', 0                             ; First predefined string
    str2 db 'bar', 0                             ; Second predefined string

    ; second set of string inputs
    ; str1 db 'this is a test', 0                ; First predefined string 
    ; str2 db 'of the emergency broadcast', 0    ; Second predefined string

    ; third set of string inputs (custom inputs)
    ; str1 db 'dog', 0                            ; First predefined string 
    ; str2 db 'fish', 0                            ; Second predefined string

    msg db 'Hamming distance: ', 0              ; Output message
    len equ $ - msg

    newline db 10                               ; Newline character

section .bss
   hamming_distance resd 1                      ; Reserves space for Hamming distance result (as a dword for larger distances)
   hamming_distance_ascii resb 10               ; Reserves space for the ASCII representation of the Hamming distance

section .text
    global _start

_start:
    mov esi, str1                               ; Loads the address of first string into the esi register
    mov edi, str2                               ; Loads the address of second string into the edi register
    xor ecx, ecx                                ; Clears the ecx register to be used as a counter for the hamming distance

; Compares the two strings
compare_strings_loop:
    mov al, [esi]                               ; Loads the next byte of first string into the al register
    mov ah, [edi]                               ; Loads the next byte of second string into the ah register
    test al, al                                 ; Checks if the end of the string is reached
    jz end_of_calculation                       ; If end of the first string is reached (as implied by 0), then jump to end_of_calculation
    test ah, ah                                 ; Checks if end of the second string is reached
    jz end_of_calculation                          ; If end of the second string is reached (as implied by 0), then jump to end_of_calculation
    xor al, ah                                  ; Uses XOR bytes to find differing bits

    ; Counts the differing bits in the al register
    mov bl, al                                  ; Copies al register to bl register to count the bits of a byte
    xor edx, edx                                ; Clears the edx register that will be used as a counter for the bits of this byte

count_num_bits:
    shr bl, 1                                   ; Shifts to the right by one bit to move the LSB into the carry flag
    adc edx, 0                                  ; Adds the carry flag to the edx register and counting the bit if it's set
    test bl, bl                                 ; Checks if all bits have been shifted and tested
    jnz count_num_bits                          ; If not all bits have been shifted/tested, then continue counting

    add ecx, edx                                ; Adds the edx and ecx registers to accumulate total Hamming distance
    inc esi                                     ; Moves on to the next character in first string
    inc edi                                     ; Moves on to next character in second string
    jmp compare_strings_loop                    ; Compares the next set of bits for the first and second strings 

; After completing the calculation, stores the calculated Hamming distance into hamming_distance
end_of_calculation:
    mov [hamming_distance], ecx

; Converts Hamming distance to ASCII
movzx eax, byte [hamming_distance]             ; Zero-extend the byte to a dword
add al, '0'                                    ; Converts result to ASCII
mov [hamming_distance], al                     ; Stores the ASCII character back into ax register

; Outputs the hamming distance onto the terminal
mov eax, 4                                     ; system call number (sys_write)
mov ebx, 1                                     ; file descriptor (stdout)
mov ecx, msg                                   ; message to write
mov edx, len                                   ; length of output message
int 0x80                                       ; calls kernel

; Outputs the Hamming distance
mov eax, 4                                     ; system call number (sys_write)
mov ebx, 1                                     ; file descriptor (stdout)
mov ecx, hamming_distance                      ; pointer to Hamming distance result
mov edx, 1                                     ; length of Hamming distance result
int 0x80                                       ; calls kernel

; Outputs the newline
mov eax, 4                                     ; system call number (sys_write)
mov ebx, 1                                     ; file descriptor (stdout)
mov ecx, newline                               ; pointer to newline character
mov edx, 1                                     ; length of newline character
int 0x80                                       ; calls kernel

; Exit the program
mov eax, 1                                     ; system call to exit
xor ebx, ebx                                   ; Exit code 0
int 0x80                                       ; calls kernel