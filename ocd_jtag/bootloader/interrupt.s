@===============================================================================

@  Copyright by Dung Le, 2012
@ 
@ Description:
@===============================================================================

.globl irq_enable
irq_enable:
    mrs r0,cpsr
    bic r0,r0,#0x80
    msr cpsr_c,r0
    bx lr
    
.globl irq_init
irq_init:
	@MOV	R0, #0x18               @ Load interrupt IRQ vector at address 0x18
	LDR	R0, =0x18               @ Load interrupt IRQ vector at address
	LDR	R4, [R0]                @ Read content of interrupt vector table at 0x18
	LDR	R1, =0xFFF              @ construct mask
	AND 	R4, R4, R1          @ Mask all but offset of part of intruction
	LDR R0, =0x20
	ADD	R4, R4, R0              @ build absolute address of IRQ procedure in literal pool
	LDR	R1, [R4]                @ Read BTLDR IRQ address from pool
	STR	R1, BTLDR_IRQ_ADDRESS   @ save BTLDR IRQ for later use
	LDR	R1, =INTR_DIRECTOR      @ load address of our INTERRUPT procedure
	STR	R1, [R4]                @ store this address in pool
	BX LR
	
INTR_DIRECTOR:
	STMFD    R13!, {R0-R12, LR} @ save registers, R14
    BL c_irq_handler
	LDMFD    R13!, {R0-R12, LR} @ restore resister and return
	SUBS PC, LR, #4	

BTLDR_IRQ_ADDRESS:	.word 0x0   @ Space to store bootloader IRQ address

