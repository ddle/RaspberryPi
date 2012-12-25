@===============================================================================

@  Copyright by Dung Le, 2012
@ 
@ Description:
@===============================================================================

@======================= registers map and constants ===========================
.equ CS,        0x20003000      @ System Timer Control/Status
.equ CLO,       0x20003004      @ lower 32 bits of free running counter(at 1MHz)
.equ C0,        0x2000300C            
.equ C1,        0x20003010      @ counter match register for timer 1
.equ C2,        0x20003014
.equ C3,        0x20003018

.equ IRQ1_EN,   0x2000B210      @ control reg for enable interrupts 
.equ IRQ1_PN,   0x2000B204      @ irq pending reg

@==========================  set next event on timer1 ==========================
@ Description: set up the counter match register so that timer 1 will generate
@ an interrupt signal after a specified interval. This is none-repeated interval
@ (happen once). Note that the max interval is 2^32 us
@ params:
@ R0 = time interval
@ return none

.global timer1_next_event
timer1_next_event: 
	STMFD	R13!, {R0-R3, LR}	@ save registers, LR
@ set the time interval for next event
	LDR R1, =CLO                @ counter address
	LDR R2, [R1]                @ get current running counter 
	ADD R2, R2, R0              @ set expire time for next event
	LDR R1, =C1                 @ counter match address
	STR R2, [R1]                @ reset current counter value to 0
@ clear detected match if any
	LDR R1, =CS                 @ get current match status
	LDR R2, [R1]
	MOV R3, #0x2                @ mask to write bit 1 (timer 1) to clear status
	ORR R2, R2, R3
	STR R2, [R1]
@ enable timer interrupt 
	LDR R1, =IRQ1_EN            @ interrupt enable reg
	LDR R2, [R1]
	MOV R3, #0x2                @ mask to set bit 1 (timer 1)
	ORR R2, R2, R3              @ set bit 1
	STR R2, [R1]
	LDMFD	R13!, {R0-R3, PC} 	@ restore resister and return



	


