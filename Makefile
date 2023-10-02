all:
	clear
	make clean
	nasm -f bin ./src/boot/boot.asm -o ./bin/boot.bin

clean:
	clear
	rm -rf ./bin/boot.bin

# now we can do make clean to delete the binary