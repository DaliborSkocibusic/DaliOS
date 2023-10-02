[BITS 32] ;; Tesl the asm this is 32 bit code
global _start

CODE_SEG equ 0x08
DATA_SEG equ 0x10

_start:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    ;; Setting all the registers to start from the data seg in memeory
    mov ebp, 0x00200000 ;; ebp now were in 32 bit i.e. 4 byte or 00 20 00 00
    mov esp, ebp

    ; Enable A20 Line: https://wiki.osdev.org/A20_Line
    in al, 0x92
    or al, 2
    out 0x92, al

    jmp $