
#ARMGNU ?= arm-linux-gnueabi
ARMGNU ?= arm-elf
AOPS = --warn --fatal-warnings 
COPS = -Wall -Werror -O2 -nostdlib -nostartfiles -ffreestanding 
DB   = gdb-multiarch
gcc : blinker07.hex blinker07.bin

all : gcc clang

clean :
	rm -f *.o
	rm -f *.bin
	rm -f *.hex
	rm -f *.elf
	rm -f *.list
	rm -f *.img
	rm -f *.bc
	rm -f *.clang.opt.s

db: blinker07.elf
	$(DB) -x gdbscript $<

vectors.o : vectors.s
	$(ARMGNU)-as vectors.s -o vectors.o -ggdb3 

blinker07.o : blinker07.c
	$(ARMGNU)-gcc $(COPS) -c blinker07.c -o blinker07.o -ggdb3 

blinker07.elf : memmap vectors.o blinker07.o 
	$(ARMGNU)-ld vectors.o blinker07.o -T memmap -o blinker07.elf
	$(ARMGNU)-objdump -D blinker07.elf > blinker07.list

blinker07.bin : blinker07.elf
	$(ARMGNU)-objcopy blinker07.elf -O binary blinker07.bin

blinker07.hex : blinker07.elf
	$(ARMGNU)-objcopy blinker07.elf -O ihex blinker07.hex

