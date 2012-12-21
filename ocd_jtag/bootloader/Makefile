
#ARMGNU ?= arm-none-eabi
ARMGNU ?= arm-elf
COPS = -Wall -O2 -nostdlib -nostartfiles -ffreestanding 
SDB   = gdb-multiarch
JDB   = $(ARMGNU)-gdb

all : armjtag.hex armjtag.bin blinker07.elf

clean :
	rm -f *.o
	rm -f *.bin
	rm -f *.hex
	rm -f *.elf
	rm -f *.list
	rm -f *.img


armjtag.elf : vectors.o armjtag.o asm.o
	$(ARMGNU)-ld vectors.o armjtag.o asm.o -T memmap -o armjtag.elf
	$(ARMGNU)-objdump -D armjtag.elf > armjtag.list

armjtag.bin : armjtag.elf
	$(ARMGNU)-objcopy armjtag.elf -O binary armjtag.bin

armjtag.hex : armjtag.elf
	$(ARMGNU)-objcopy armjtag.elf -O ihex armjtag.hex

%.o: %.s
	$(ARMGNU)-as $< -o $@ -g

%.o: %.c
	$(ARMGNU)-gcc $(COPS) -c $< -o $@ -g

blinker07.elf : start.o asm.o blinker07.o interrupt.o 
	$(ARMGNU)-ld $^ -T memmap -o $@
	$(ARMGNU)-objdump -D blinker07.elf > blinker07.list

sdb: blinker07.elf
	$(SDB) -x gdbscript $<

jdb: blinker07.elf
	$(JDB) -x jtag_gdbscript $<	
