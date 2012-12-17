
;@ ------------------------------------------------------------------
;@ ------------------------------------------------------------------

.equ GPFSEL1, 0x20200004
.equ GPSET0,  0x2020001C
.equ GPCLR0,  0x20200028

.globl _start
_start:
    mov sp,#0x8000
    
    @translating ...    
        
    ldr r0,=GPFSEL1
    ldr r1, [r0]
    
    @ra &= ~(7<<18); // alternate function 000: gpio-input
    mov r2, #7
    mvn r2, r2, lsl #18
    and r1, r1, r2

    @ ra |= 1<<18;   // alternate function 001: gpio-output
    mov r2, #1
    mov r2, r2, lsl #18
    orr r1, r1, r2
        
    str r1, [r0]    
    
blink:
    bl on
    bl delay_1s
    bl off
    bl delay_1s
	b blink            
off:
    mov r2, #1
    mov r2, r2, lsl #16
	ldr r0,=GPSET0
    str r2, [r0]
	bx lr
on:
    mov r2, #1
    mov r2, r2, lsl #16
	ldr r0,=GPCLR0
    str r2, [r0]
	bx lr
	
delay_1s:
	LDR	R1, =0x01FFFFF		@ init register counter value ~ 1 second
	DELAY_LOOP:				@ REPEAT
	SUBS	R1, R1, #1		@ decrease counter by 1 and set flag
	BNE	DELAY_LOOP			@ UNTIL counter = 0 (Z flag set)
	bx lr


