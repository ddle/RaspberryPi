<<<<<<< HEAD
@===============================================================================
@ "Bare metal" Timer Interrupt Example for raspberry pi
@  Copyright by Dung Le, 2012
@ 
@ Description:
@===============================================================================
.global main
main:

.equ INTERVAL, 0xF4240              @ 1s

	@LDR SP, =STACK             @ setup stack
	@ADD SP, SP, #256           @ 
	BL led_init
	BL irq_init
	LDR R0, =INTERVAL           
	BL timer1_next_event
	BL irq_enable
	
LOOP:
	B LOOP
	
.global irq_handler	
irq_handler:
    STMFD    R13!, {R0-R1, LR}     @ save registers, R14
    LDR R0, =LED_STATE
    LDR R1, [R0]                   @ get current on/off state
    TST R1, #1                     @ Z flag set if LED OFF
    BNE OFF                        @ 
	BL led_on                      @ otherwise turn on
	MOV R1, #1                     @ switch the flag
	STR R1, [R0]	
	B DONE_LED
OFF:
	BL led_off                     @ turn off
	MOV R1, #0                     @ switch the flag
	STR R1, [R0]	
DONE_LED: 
	LDR R0, =INTERVAL           	
	BL timer1_next_event           @ set next interrupt interval
    LDMFD    R13!, {R0-R1, PC}     @ restore resister and return
    
.data
LED_STATE: .byte 0x0
STACK:            .rept 256
                  .byte 0x0
                  .endr
.end


=======
@===============================================================================
@ "Bare metal" Timer Interrupt Example for raspberry pi
@ Copyright by Dung Le, 2012
@===============================================================================
.global main
main:
.equ INTERVAL, 0xF4240             @ 1s

    LDR SP, =STACK                 @ setup stack
    ADD SP, SP, #256
    BL led_init
    BL irq_init
    LDR R0, =INTERVAL
    BL timer1_next_event
    BL irq_enable
    
LOOP:
    B LOOP
    
.global irq_handler    
irq_handler:
    STMFD    R13!, {R0-R1, LR}     @ save registers, R14
    LDR R0, =LED_STATE
    LDR R1, [R0]                   @ get current on/off state
    TST R1, #1                     @ Z flag set if LED OFF
    BNE OFF                        @ 
    BL led_on                      @ otherwise turn on
    MOV R1, #1                     @ switch the flag
    STR R1, [R0]    
    B DONE_LED
OFF:
    BL led_off                     @ turn off
    MOV R1, #0                     @ switch the flag
    STR R1, [R0]    
DONE_LED: 
    LDR R0, =INTERVAL               
    BL timer1_next_event           @ set next interrupt interval
    LDMFD    R13!, {R0-R1, PC}     @ restore resister and return
    
.data
LED_STATE:        .byte 0x0
STACK:            .rept 256
                  .byte 0x0
                  .endr
.end


>>>>>>> b7c46901c7958a0757bf40799f5330bcb7c60af6
