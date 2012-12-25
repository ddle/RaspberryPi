#*******************************************************************************
# Makefile for Cross-Compile to ARM target. Tested with RaspberryPi v2
# Dung Le, 2012
#
# Usage:
# - change "NAME" below with your assembly program
# - build (assembling and linking):
#   > make
# - serial debug:
#   > make sdb
# - jtag debug:
#   > make jdb
# note: kernel.img can be preloaded to SDcard
#*******************************************************************************

NAME = timer_interrupt

CROSS_COMPILE ?= arm-elf
CC := $(CROSS_COMPILE)-gcc
LD := $(CROSS_COMPILE)-ld
AS := $(CROSS_COMPILE)-as
OBJDUMP := $(CROSS_COMPILE)-objdump
OBJCOPY := $(CROSS_COMPILE)-objcopy
SDB   = gdb-multiarch
JDB   = $(CROSS_COMPILE)-gdb
AFLAGS  = -gstabs+ -warn -fatal-warnings
LFLAGS  = -T memmap

OBJS =  start.o $(NAME).o led.o timer.o interrupt.o

all: $(NAME).elf kernel.img

kernel.img:	$(NAME)
	$(OBJCOPY) -O binary $< $@
	
$(NAME).elf: $(NAME)
	$(OBJCOPY) $< $@
	$(OBJDUMP) -D $@ > $(NAME).lst

$(NAME): $(OBJS)	
	$(LD) $^ -o $@ $(LFLAGS) --M $@.mp

%.o: %.s
	$(AS) $< -o $@ $(AFLAGS)

sdb: $(NAME).elf
	$(SDB) -x gdbscript $<

jdb: $(NAME).elf
	$(JDB) -x jtag_gdbscript $<
	
clean:
	rm -f *.lst *.elf *.mp *.o $(NAME) kernel.img
