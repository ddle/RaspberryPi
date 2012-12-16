#***********************************************************************
# Usage:
# - change "NAME" below with your assembly program
# - build (assembling and linking):
#   > make
# - launch debugger:
#   > make db
#***********************************************************************

# change this to your assembly program's name
NAME = i2c

LD   = arm-elf-ld
AS   = arm-elf-as
#DB   = arm-elf-insight
DB   = gdb-multiarch
AFLAGS  = -ad=$(NAME).lst -gstabs
LFLAGS  = --M $(NAME).mp -T memmap

all:
	$(AS) $(NAME).s -o $(NAME).o $(AFLAGS) 
	$(LD) $(NAME).o -o $(NAME).elf $(LFLAGS)

db:
	$(AS) $(NAME).s -o $(NAME).o $(AFLAGS) 
	$(LD) $(NAME).o -o $(NAME).elf $(LFLAGS)
	$(DB) -x gdbscript $(NAME).elf
clean:
	-rm $(NAME).lst $(NAME).elf $(NAME).mp $(NAME).o
