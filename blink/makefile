#***********************************************************************
# Example Makefile For ECE371 lab
#***********************************************************************
# Usage:
# - change "NAME" below with your assembly program
# - build (assembling and linking):
#   > make
# - launch debugger:
#   > make run
# - remove old builds
#   > make clean
#***********************************************************************

# change this to your assembly program's name
NAME = main

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
