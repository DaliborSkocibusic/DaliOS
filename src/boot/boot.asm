; The BIOS will load the program into address Ox7C00
ORG 0x7c00         ; Specify this as the start point of the asm program. 0 Now
            ; The origin should be 0 and we should jump ideally
BITS 16     ; Tells the assembler to only assemble 16 bit code
            ; Dont forget this starts in real mode
            ; That means only 1MB of RAM, no security max 16 bit address space
            ; Real mode has to be 16 bits

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gtd_data - gdt_start
_start: ; leaves 3 bytes for BIOS when loading from USB
    jmp short start
    nop

times 33 db 0 ;; Fills in 33 null bytes after short start

start:      ; This is a label, this is where our program starts
    jmp 0:step2 ; Sets code segment to 7c0

; ;; To run qemu-system-x86_64 -hda ./boot.bin 
;; to run on usb stick
;; go to bootloader dir
;; sudo fdisk -l ; shows all file systems
;; usb likely /dev/sdb
;; get dd 
;; sudo dd if=./boot.bin of=./dev/sdb

;; need to make sure this is working with gdb
;; sudo apt install gdb
;; crank with $gdb
;;            (gdb) target remote | qemu-system-x86_64 -hda ./boot.bin -S -gdb stdio
;; step in with c
;; Ctrl + c to go to (gdb) you can see what line you are on
;; layout asm shows th easm
;; info registers shows we are in prot mode by cs = 8


;; We are now in protected mode
;; We cant call interrupts or read from disk
;; interrupts will make bad things happen. idk what yet..
;; we need our own drivers

step2:
    cli     ; Clear interrupt flags disables hardware interrupts
    mov ax, 0x00          ; Necessary when setting registers
    mov ds, ax            ; Put ax into ds
    mov es, ax            ; put ax into es
    mov ss, ax                    
    mov sp, 0x7c00          ; set the stack pointer to the highest memry location
    sti     ; Set interupts / Enables interrupts

;; This is us going into protected mode. I think
.load_protected:
    cli
    lgdt[gdt_descriptor] ;; Load the descriptor table at gdt_descriptor
    mov eax, cr0 ; 
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:load32 ; COde seg is 0x8

; Global Descriptor Table
; https://wiki.osdev.org/Global_Descriptor_Table
; It tells the cpu about memory segments

gdt_start:


gdt_null:   ; Need a null segment
    dd 0x0 ; 32bit of 0's or 4 bytes
    dd 0x0

; offset 0x8
gdt_code:     ; CS should point to this
    dw 0xffff ; Segment limit of first 0 - 15 bits
    dw 0      ; Base 0 -15 bits
    db 0      ; Base 16-23 bits
    db 0x9a   ; Access byte
    db 11001111b ; High 4 bit flags and the low 4 bit flags
    db 0      ; Base 24-31 bits

; Ofset 0x10
gtd_data:     ; Should be linked to DS, SS, ES, FS, GS
    dw 0xffff ; Segment limit of first 0 - 15 bits
    dw 0      ; Base 0 -15 bits
    db 0      ; Base 16-23 bits
    db 0x92   ; Access byte
    db 11001111b ; High 4 bit flags and the low 4 bit flags
    db 0      ; Base 24-31 bits

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1 ;; This is the size
    dd gdt_start               ;; This is the offset

[BITS 32]
load32:
    mov eax, 1         ; Sector want to load from. 0 is boot sector
    mov ecx, 100       ; 
    mov edi, 0x0100000 ; Should be 1MB
    call ata_lba_read
    jmp CODE_SEG:0x0100000

ata_lba_read:          ; Driver that talks to the motherboard
    mov ebx, eax       ; Backup LBA for later
    shr eax, 24        ; Shift to get the top 8 bits
    or eax, 0xE0       ; Selects the master drive
    mov dx, 0x1F6      ; 
    out dx, al         ; Finsied sending the top 8 bits of lba

    ; Send the toal sectors to be read
    mov eax, ecx       
    mov dx, 0x1F2
    out dx, al
    ; Finished sending the total sectors to be read

    ; Send more bits of the LBA
    mov eax, ebx      ; Restore LBA from backup
    mov dx, 0x1F3
    out dx, al; 
    ; Finished sending more bits of the LBA

    ; Send more bits of the LBA
    mov dx, 0x1F4
    mov eax, ebx ; Restore each time
    shr eax, 8
    out dx, al
    ; Finished sending more bits of the LBA

    ; Send upper 16 bits of LBA
    mov dx, 0x1F5
    mov eax, ebx
    shr eax, 16
    ; Finsihed sending upper 16 bits of LBA

    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

    ; Read all sectors into memory
.next_sector:
    push ecx


; Checking if we need to read
.try_again:
    mov dx, 0x1f7
    in al, dx
    test al, 8
    jz .try_again

; We need to read 256 words at a time
    mov ecx, 256
    mov dx, 0x1F0
    rep insw     ; Reads 256 words
    pop ecx
    Loop .next_sector
    ret


times 510- ($ - $$) db 0 ; This fills the first 510 bytes with 0 or the content to make a sector
; Line above will fill the 510 bytes with data if nothing and pad with 0
dw 0xAA55 ; Need 55AA in the last two bytes so BIOS knows to load this sector
            ; Big endian. 

;; One byte is two hex digits
;; i.e. 0x00 to 0xFF is a single byte
;; 512b is 0x200
;; Commit 15 is good. 