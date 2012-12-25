#*******************************************************************************
# Makefile for Cross-Compile to ARM target. Tested with RaspberryPi v2
# Dung Le, 2012
#
# Usage:
# - change "NAME" below with your assembly program
# - build (assembling and linking):
#   > make
# - debug:
#   > make db
# note: kernel.img can be preloaded to SDcard
#
#*******************************************************************************

NAME = main

CROSS_COMPILE ?= arm-elf
CC := $(CROSS_COMPILE)-gcc
LD := $(CROSS_COMPILE)-ld
AS := $(CROSS_COMPILE)-as
OBJCOPY := $(CROSS_COMPILE)-objcopy
OBJDUMP := $(CROSS_COMPILE)-objdump

SDB   = gdb-multiarch
JDB   = $(CROSS_COMPILE)-gdb
AFLAGS  = -gstabs+ -warn -fatal-warnings
LFLAGS  = -T memmap

OBJS = $(NAME).o


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

sdb:$(NAME).elf
	$(SDB) -x gdbscript $<

jdb: $(NAME).elf
	$(JDB) -x jtag_gdbscript $<	
	
clean:
	rm -f *.lst *.elf *.mp *.o $(NAME) kernel.img
