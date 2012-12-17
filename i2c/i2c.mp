
Memory Configuration

Name             Origin             Length             Attributes
ram              0x00008000         0x00010000
*default*        0x00000000         0xffffffff

Linker script and memory map

LOAD i2c.o

.text           0x00008000      0x178
 *(.text*)
 .text          0x00008000      0x178 i2c.o
                0x00008000                _start

.glue_7         0x00000000        0x0
 .glue_7        0x00000000        0x0 linker stubs

.glue_7t        0x00000000        0x0
 .glue_7t       0x00000000        0x0 linker stubs

.vfp11_veneer   0x00000000        0x0
 .vfp11_veneer  0x00000000        0x0 linker stubs

.v4_bx          0x00000000        0x0
 .v4_bx         0x00000000        0x0 linker stubs

.data           0x00008178        0x8
 *(.data*)
 .data          0x00008178        0x8 i2c.o

.bss            0x00008180        0x0
 *(.bss*)
 .bss           0x00008180        0x0 i2c.o
OUTPUT(i2c.elf elf32-littlearm)

.ARM.attributes
                0x00000000       0x10
 .ARM.attributes
                0x00000000       0x10 i2c.o

.stab           0x00000000      0x414
 .stab          0x00000000      0x414 i2c.o

.stabstr        0x00000000        0x7
 .stabstr       0x00000000        0x7 i2c.o
