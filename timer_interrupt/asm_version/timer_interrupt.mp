
Memory Configuration

Name             Origin             Length             Attributes
ram              0x00008000         0x00010000
*default*        0x00000000         0xffffffff

Linker script and memory map

LOAD timer_interrupt.o
LOAD led.o
LOAD timer.o
LOAD interrupt.o
LOAD start.o

.text           0x00008000      0x1c4
 *(.text*)
 .text          0x00008000       0x70 timer_interrupt.o
                0x00008000                main
                0x00008028                irq_handler
 .text          0x00008070       0x68 led.o
                0x00008070                led_init
                0x0000809c                led_off
                0x000080b4                led_on
 .text          0x000080d8       0x44 timer.o
                0x000080d8                timer1_next_event
 .text          0x0000811c       0x58 interrupt.o
                0x0000811c                irq_enable
                0x0000812c                irq_init
 .text          0x00008174       0x50 start.o
                0x00008174                _start

.glue_7         0x00000000        0x0
 .glue_7        0x00000000        0x0 linker stubs

.glue_7t        0x00000000        0x0
 .glue_7t       0x00000000        0x0 linker stubs

.vfp11_veneer   0x00000000        0x0
 .vfp11_veneer  0x00000000        0x0 linker stubs

.v4_bx          0x00000000        0x0
 .v4_bx         0x00000000        0x0 linker stubs

.data           0x000081c4      0x101
 *(.data*)
 .data          0x000081c4      0x101 timer_interrupt.o
 .data          0x000082c5        0x0 led.o
 .data          0x000082c5        0x0 timer.o
 .data          0x000082c5        0x0 interrupt.o
 .data          0x000082c5        0x0 start.o

.bss            0x000082c5        0x0
 *(.bss*)
 .bss           0x000082c5        0x0 timer_interrupt.o
 .bss           0x000082c5        0x0 led.o
 .bss           0x000082c5        0x0 timer.o
 .bss           0x000082c5        0x0 interrupt.o
 .bss           0x000082c5        0x0 start.o
OUTPUT(timer_interrupt elf32-littlearm)

.ARM.attributes
                0x00000000       0x10
 .ARM.attributes
                0x00000000       0x10 timer_interrupt.o
 .ARM.attributes
                0x00000010       0x10 led.o
 .ARM.attributes
                0x00000020       0x10 timer.o
 .ARM.attributes
                0x00000030       0x10 interrupt.o
 .ARM.attributes
                0x00000040       0x10 start.o

.stab           0x00000000      0x4d4
 .stab          0x00000000      0x150 timer_interrupt.o
 .stab          0x00000150      0x12c led.o
                                0x138 (size before relaxing)
 .stab          0x0000027c       0xb4 timer.o
                                 0xc0 (size before relaxing)
 .stab          0x00000330       0xfc interrupt.o
                                0x108 (size before relaxing)
 .stab          0x0000042c       0xa8 start.o
                                 0xb4 (size before relaxing)

.stabstr        0x00000000       0x78
 .stabstr       0x00000000       0x78 timer_interrupt.o
