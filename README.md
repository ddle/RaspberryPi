Raspberry Pi projects
Dung Le, 2012
---------------------------------------
references:

	- https://github.com/dwelch67/raspberrypi
	
	- bootloader for serial debug https://github.com/jamieiles/rpi-gdb

notes:

	- to build, type make. There are makefiles for both C and Asm frameworks
	
	- to debug, use "make db". This starts remote gdb (serial) section using the
	  gdbscript. Then "load <binary>" to upload. The debug framework inludes: 
	  
		  + gdb-multiarch
		  
		  + serial connection to ARM target via uart (3 wires tx,rx and gnd)
		  
		  + bootloader preloaded in the target board. see "rpi-gdb"

1. rpi-gdb: bootloader for serial debug

	- to use, just copy content of bootloader folder to SD card
	
2. blink: blink the status LED on board. 

	This example project uses custom makefiles for two different frameworks
	
	- C : "c_Makefile". codes include all related C files, linker script
	  (memmap) and startup code (vector.s)
	  
	- Assembly: "makefile". code includes main.s amd linker script (memmap)


