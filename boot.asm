; The BIOS will load the program into address Ox7C00
ORG 0x7c00  ; Specify this as the start point of the asm program
            ; The origin should be 0 and we should jump ideally
BITS 16     ; Tells the assembler to only assemble 16 bit code

start:      ; This is a label, this is where our program starts
    mov ah, 0eh ; This is real mode (16 bit programming)
    mov al, 'A' ; Move A into the A register
    mov bx, 0
    int 0x10    ; Call the interupt that will output the char to the screen

    jmp $       ; Jump to the same spot. Inf loop

times 510- ($ - $$) db 0 ; This fills the first 510 bytes with 0 or the content to make a sector
; Line above will fill the 510 bytes with data if nothing and pad with 0
dw 0xAA55 ; Need 55AA in the last two bytes so BIOS knows to load this sector
            ; Big endian. 