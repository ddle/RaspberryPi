OCD Jtag with GDB
-------------------------
from this project
https://github.com/dwelch67/raspberrypi/tree/master/armjtag

1. In model B rev 2 board, pin ARM_TMS has been routed to P1-13 so the updated 
layout is

	1 ARM_VREF                   P1-1
	2 ARM_TRST      22 GPIO_GEN3 P1-15  IN (22 ALT4)
	3 ARM_TDI     4/26 GPIO_GCLK P1-7   IN ( 4 ALT5)
	4 ARM_TMS    12/27 GPIO_GEN2 P1-13 OUT (27 ALT4)
	5 ARM_TCK    13/25 GPIO_GEN6 P1-22 OUT (25 ALT4)
	7 no connect
	9 ARM_TDO     5/24 GPIO_GEN5 P1-18 OUT (24 ALT4)

	4-20 ARM_GND                 P1-25
	
2. Using Jtag (test device was ARM-USB-OCD from Olimex) with GDB
ref http://openocd.sourceforge.net/doc//pdf/openocd.pdf
	- should have the tool installed first (openocd), under Linux use
	  "apt-get install openocd"
	- copy (jtag) bootloader to sdcard (kernel.img, bootcode.bin, start.elf)
	- make sure the ftdi driver for the device is installed
	- run "openocd -f arm-usb-ocd.cfg -f raspi.cfg". This should start up server 
	  and waiting for connections
	- open another terminal and use the gdb toolchain, e.g, arm-elf-gdb file.elf
	- under gdb connect to target with "target remote :3333"
	- download code to target with "load file.elf"
	- proceed with normal gdb command
	- sometimes if target is not "halt", use "monitor halt"
