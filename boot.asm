; The BIOS will load the program into address Ox7C00
ORG 0         ; Specify this as the start point of the asm program. 0 Now
            ; The origin should be 0 and we should jump ideally
BITS 16     ; Tells the assembler to only assemble 16 bit code
            ; Dont forget this starts in real mode
            ; That means only 1MB of RAM, no security max 16 bit address space
            ; Real mode has to be 16 bits

;;;;;;;;;;;;;;;;;;;
; Code below is to give space for the code that is overwritten when booting from usb
; Data in that section must not be important asit will be overwritten by BIOS
_start: ; leaves 3 bytes for BIOS when loading from USB
    jmp short start
    nop

times 33 db 0 ;; Fills in 33 null bytes after short start


start:      ; This is a label, this is where our program starts

    jmp 0x7c0:step2 ; Sets code segment to 7c0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Section below modifies the code so that all the registers are set manually
; As opposed to expecing BIOS to do it for us. 
step2:
    cli     ; Clear interrupt flags disables hardware interrupts
    mov ax, 0x7c0        ; Necessary when setting registers
    mov ds, ax            ; Put ax into ds
    mov es, ax            ; put ax into es

    mov ax, 0x00            ; set stack segment to 00
    mov ss, ax                    
    mov sp, 0x7c00          ; set the stack pointer to the highest memry location


    sti     ; Set interupts / Enables interrupts
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov si, message
    call print
    jmp $       ; Jump to the same spot. Inf loop

print:
    mov bx, 0

.loop: 
    lodsb               ; will load charcher si is pointing to
    cmp al, 0
    je .done
    call print_char
    jmp .loop

.done:                  ; NASM can set labels for only the label above. idk what that means
    ret

print_char:
    mov ah, 0eh ; This is real mode (16 bit programming)
    int 0x10    ; Call the interupt that will output the char to the screen
    ret

message: db 'Dalibors Amazing Operating System!', 0 ; Set a lable message as a double byte 2x8 with 0 null terminator

times 510- ($ - $$) db 0 ; This fills the first 510 bytes with 0 or the content to make a sector
; Line above will fill the 510 bytes with data if nothing and pad with 0
dw 0xAA55 ; Need 55AA in the last two bytes so BIOS knows to load this sector
            ; Big endian. 