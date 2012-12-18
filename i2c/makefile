#***********************************************************************
# Usage:
# - change "NAME" below with your assembly program
# - build (assembling and linking):
#   > make
# - launch debugger:
#   > make db
#***********************************************************************

NAME = i2c

CROSS_COMPILE ?= arm-elf
CC := $(CROSS_COMPILE)-gcc
LD := $(CROSS_COMPILE)-ld
AS := $(CROSS_COMPILE)-as
OBJCOPY := $(CROSS_COMPILE)-objcopy
#DB   = arm-elf-insight
DB   = gdb-multiarch
AFLAGS  = -gstabs+ -warn -fatal-warnings
LFLAGS  = -T memmap

OBJS = $(NAME).o

all: $(NAME).elf

$(NAME).elf: $(NAME)
	$(OBJCOPY) $< $@

$(NAME): $(OBJS)	
	$(LD) $^ -o $@ $(LFLAGS) --M $@.mp

%.o: %.s
	$(AS) $< -o $@ $(AFLAGS) -ad=$*.lst

db: $(NAME).elf
	$(DB) -x gdbscript $<
	
clean:
	rm -f *.lst *.elf *.mp *.o $(NAME)
