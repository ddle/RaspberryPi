
@ GPIO - status LED
.equ GPFSEL1,    0x20200004
.equ GPSET0,     0x2020001C
.equ GPCLR0,     0x20200028
.equ S_LED,              16

@==================== initialize status LED ====================================
.global led_init
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
.global led_off
led_off:
    STMFD    R13!, {R0, R2, LR}    @ save registers, R14
    MOV R2, #1
    MOV R2, R2, lsl #S_LED
    LDR R0,=GPSET0
    STR R2, [R0]
    LDMFD    R13!, {R0, R2, PC}    @ restore resister and return

.global led_on
led_on:
    STMFD    R13!, {R0, R2, LR}    @ save registers, R14
    MOV R2, #1
    MOV R2, R2, lsl #S_LED
    LDR R0,=GPCLR0
    STR R2, [R0]
    LDMFD    R13!, {R0, R2, PC}    @ restore resister and return
