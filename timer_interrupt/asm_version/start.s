.globl _start
_start:

@ set up the interrupt vectors at 0x0
    ldr pc,reset_handler
    ldr pc,undefined_handler
    ldr pc,swi_handler
    ldr pc,prefetch_handler
    ldr pc,data_handler
    ldr pc,unused_handler
    ldr pc,irq_handler
    ldr pc,fiq_handler
reset_handler:      .word reset
undefined_handler:  .word hang
swi_handler:        .word hang
prefetch_handler:   .word hang
data_handler:       .word hang
unused_handler:     .word hang
irq_handler:        .word irq
fiq_handler:        .word hang

reset:
	mov r0,#0x8000
    mov r1,#0x0000
    ldmia r0!,{r2,r3,r4,r5,r6,r7,r8,r9}
    stmia r1!,{r2,r3,r4,r5,r6,r7,r8,r9}
    ldmia r0!,{r2,r3,r4,r5,r6,r7,r8,r9}
    stmia r1!,{r2,r3,r4,r5,r6,r7,r8,r9}

@ set up different stack pointers in different modes
    mrs r0, cpsr @ what mode we 're on?
/*
    @ (PSR_IRQ_MODE|PSR_IRQ_DIS)
    mov r0,#0x92
    msr cpsr_c,r0
    mov sp,#0x8000

    @ (PSR_FIQ_MODE|PSR_IRQ_DIS)
    mov r0,#0x91
    msr cpsr_c,r0
    mov sp,#0x4000

    @ (PSR_SVC_MODE|PSR_IRQ_DIS)
    mov r0,#0x93
    msr cpsr_c,r0
    mov sp,#0x8000000
*/
 
    
	bl main

hang: b hang

@ just need the address here, we put our handler later on by "hook and chain"

irq:
    b irq

