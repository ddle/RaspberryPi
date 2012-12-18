@ "Bare Metal" Raspberry pi: blink status led 
@ by Dung Le
@------------------------------------------------------------------


@ GPIO - status LED
.equ GPFSEL1,    0x20200004
.equ GPSET0,     0x2020001C
.equ GPCLR0,     0x20200028
.equ S_LED,              16

    BL led_init
LOOP:
    BL led_on
    BL delay_1s
    BL led_off
    BL delay_1s
    B LOOP

@==================== initialize status LED ====================================
led_init:
    STMFD    R13!, {R0-R3, LR}     @ save registers, R14
    LDR R0,=GPFSEL1
    LDR R1, [R0]    
    @ GPFSEL1 &= ~(3<<19); // CLEAR 20,19 (AF 00X: gpio)
    MOV R2, #3
    MVN R2, R2, lsl #19
    AND R1, R1, R2
    @ GPFSEL1 |= 1<<18;    // SET 18  (AF 001: gpio-output)
    MOV R2, #1
    MOV R2, R2, lsl #18
    ORR R1, R1, R2
    STR R1, [R0]  
    LDMFD    R13!, {R0-R3, PC}     @ restore resister and return
    
@========================== LED ON/OFF =========================================

led_off:
    STMFD    R13!, {R0, R2, LR}    @ save registers, R14
    MOV R2, #1
    MOV R2, R2, lsl #S_LED
    LDR R0,=GPSET0
    STR R2, [R0]
    LDMFD    R13!, {R0, R2, PC}    @ restore resister and return

led_on:
    STMFD    R13!, {R0, R2, LR}    @ save registers, R14
    MOV R2, #1
    MOV R2, R2, lsl #S_LED
    LDR R0,=GPCLR0
    STR R2, [R0]
    LDMFD    R13!, {R0, R2, PC}    @ restore resister and return	

delay_1s:
	LDR	R1, =0xD00000		
	DELAY_LOOP:				
	SUBS	R1, R1, #1		
	BNE	DELAY_LOOP			
	BX LR

