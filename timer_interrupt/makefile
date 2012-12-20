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

NAME = timer_interrupt

CROSS_COMPILE ?= arm-elf
CC := $(CROSS_COMPILE)-gcc
LD := $(CROSS_COMPILE)-ld
AS := $(CROSS_COMPILE)-as
OBJCOPY := $(CROSS_COMPILE)-objcopy
#DB   = arm-elf-insight
DB   = gdb-multiarch
AFLAGS  = -gstabs+ -warn -fatal-warnings
LFLAGS  = -T memmap

OBJS = $(NAME).o led.o timer.o interrupt.o vectors.o

all: $(NAME).elf kernel.img

kernel.img:	$(NAME)
	$(OBJCOPY) -O binary $< $@
	
$(NAME).elf: $(NAME)
	$(OBJCOPY) $< $@

$(NAME): $(OBJS)	
	$(LD) $^ -o $@ $(LFLAGS) --M $@.mp

%.o: %.s
	$(AS) $< -o $@ $(AFLAGS) -ad=$*.lst

db: $(NAME).elf
	$(DB) -x gdbscript $<
	
clean:
	rm -f *.lst *.elf *.mp *.o $(NAME) kernel.img
