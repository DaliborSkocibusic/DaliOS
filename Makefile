all:
	nasm -f bin ./boot.asm -o ./boot.bin
	dd if=./message.txt >> ./boot.bin
	dd if=/dev/zero bs=512 count=1 >> ./boot.bin

#all means something
# dd if=/dev/zero bs=512 count=1 >> ./boot.bin sets the sector to 512
# dev/zero is null character im guessing. 