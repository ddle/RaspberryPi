
#ARMGNU ?= arm-linux-gnueabi
ARMGNU ?= arm-elf
AOPS = --warn --fatal-warnings 
COPS = -Wall -Werror -O2 -nostdlib -nostartfiles -ffreestanding 
SDB   = gdb-multiarch
JDB   = $(ARMGNU)-gdb
gcc : blinker01.hex blinker01.bin

all : gcc

clean :
	rm -f *.o
	rm -f *.bin
	rm -f *.hex
	rm -f *.elf
	rm -f *.list
	rm -f *.img
	rm -f *.bc
	rm -f *.clang.opt.s

sdb: blinker01.elf
	$(SDB) -x gdbscript $<

jdb: blinker01.elf
	$(JDB) -x jtag_gdbscript $<	

vectors.o : vectors.s
	$(ARMGNU)-as vectors.s -o vectors.o -g

blinker01.o : blinker01.c
	$(ARMGNU)-gcc $(COPS) -c blinker01.c -o blinker01.o -g

blinker01.elf : memmap vectors.o blinker01.o 
	$(ARMGNU)-ld vectors.o blinker01.o -T memmap -o blinker01.elf
	$(ARMGNU)-objdump -D blinker01.elf > blinker01.list

blinker01.bin : blinker01.elf
	$(ARMGNU)-objcopy blinker01.elf -O binary blinker01.bin

blinker01.hex : blinker01.elf
	$(ARMGNU)-objcopy blinker01.elf -O ihex blinker01.hex

