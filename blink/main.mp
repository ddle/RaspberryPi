
Memory Configuration

Name             Origin             Length             Attributes
ram              0x00008000         0x00010000
*default*        0x00000000         0xffffffff

Linker script and memory map

LOAD main.o

.text           0x00008000       0x90
 *(.text*)
 .text          0x00008000       0x90 main.o
 *(.glue_7t)
 .glue_7t       0x00000000        0x0 linker stubs
 *(.glue_7)
 .glue_7        0x00000000        0x0 linker stubs

.vfp11_veneer   0x00000000        0x0
 .vfp11_veneer  0x00000000        0x0 linker stubs

.v4_bx          0x00000000        0x0
 .v4_bx         0x00000000        0x0 linker stubs

.data           0x00008090        0x0
 *(.data*)
 .data          0x00008090        0x0 main.o

.bss            0x00008090        0x0
 *(.bss*)
 .bss           0x00008090        0x0 main.o
OUTPUT(main elf32-littlearm)

.ARM.attributes
                0x00000000       0x10
 .ARM.attributes
                0x00000000       0x10 main.o

.stab           0x00000000      0x1b0
 .stab          0x00000000      0x1b0 main.o

.stabstr        0x00000000       0x35
 .stabstr       0x00000000       0x35 main.o
