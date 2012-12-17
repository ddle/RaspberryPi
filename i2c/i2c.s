@===============================================================================
@ "Bare metal" I2C driver for raspberry pi
@  Copyright by Dung Le, 2012
@===============================================================================
.text
.global _start
_start:
@======================= registers map and constants ===========================
/*
@ raspberry pi version 1 use I2C_0 on P1-3, P1-5
.equ I2C0_BASE,  0x20205000 
.equ C_REG,      0x20205000    @ control register  
.equ S_REG,      0x20205004    @ status register
.equ FIFO_REG,   0x20205010    @ data buffer register
.equ A_REG,      0x2020500C    @ slave address
.equ DLEN_REG,   0x20205008    @ data length
*/

@ raspberry pi version 2 use I2C_1 on P1-3, P1-5
.equ I2C0_BASE,  0x20804000 
.equ C_REG,      0x20804000    @ control register  
.equ S_REG,      0x20804004    @ status register
.equ FIFO_REG,   0x20804010    @ data buffer register
.equ A_REG,      0x2080400C    @ slave address register
.equ DLEN_REG,   0x20804008    @ data length

.equ SLAVE_ADDR,        0x4

@ GPIO - status LED
.equ GPFSEL1,    0x20200004
.equ GPSET0,     0x2020001C
.equ GPCLR0,     0x20200028
.equ S_LED,              16

@ message length
.equ len,                 4

@==================== initialize status LED ====================================
    MOV sp,#0x8000       
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
    
@==================== initialize I2C  ==========================================
@ Description: initialize i2c bus
@ return none
@ TODO:
@ disable internal pull up?
@ set alternate function 0 (i2c) on SDA0 (GPIO_0) and SCL0 (GPIO_1)
@ set i2c speed to 100kHZ

i2c_init: 
@ i2c status register: clear ERR,CLKT,DONE flag
	LDR R4, =I2C0_BASE      @ use base for register addressing
	LDR R2, [R4, #0x4]       @ S_REG
	ORR R2, R2, #0x100       @ write 1 to clear ERR flag, if any
	ORR R2, R2, #0x200       @ write 1 to clear CLKT flag, if any
	ORR R2, R2, #0x02        @ write 1 to clear DONE flag
	STR R2, [R4, #0x4]       @ save to S_REG
@ i2c control register
	LDR R1, =C_REG 
	LDR R0, =0x8030	           @ setting: enable i2c, clear buffer
	STR R0, [R1]
	
@==================== MAINLINE program =========================================
LOOP:
	BL off
	BL delay_1s
	MOV R0, #SLAVE_ADDR        @ Slave address	
	BL i2c_set7bitSlaveAddress
	LDR R0, =STRING_0          @ string pointer
	LDR R1, =LENGTH_0          @ data length
	MOV R2, #len
	STR R2, [R1]
	BL i2c_write
	BL on
	BL delay_1s
	B LOOP
	
@==================== set 7 bit slave address  =================================
@ Description: select slave address (7 bit) at the begining of i2c transactions
@ Params:
@	R0 = 7 bit address
@ Return: none

i2c_set7bitSlaveAddress:
	STMFD	R13!, {R1, LR}	@ save registers, R14
	LDR R1, =A_REG 
	STR R0, [R1]
	LDMFD	R13!, {R1, PC} 	@ restore resister and return
	
@==================== i2c write transactions ===================================
@ Description: write data string to i2c bus
@ Params
@	R0 = pointer to data
@	R1 = pointer to length of data
@ Return: error status
@ TODO: 
@ check params validity

i2c_write:
	STMFD	R13!, {R1-R4, LR}	@ save registers, LR
	
	LDR R4, =I2C0_BASE          @ use base for register addressing
@ set data length
	LDR R2, [R1]
	STR R2, [R4, #0x8]          @ set data length in DLEN_REG
	
@ configure write transaction
	LDR R2, [R4]                @ get C_REG content
	MVN R3, #0x1                @ mask for clearing READ bit (= Write)		
	AND R2, R2, R3
@ clear buffer before transmit and set start bit
	MOV R3, #0xA0               @ mask for setting CLEAR bits and START bit
	ORR R2, R2, R3          
	STR R2, [R4] 
	
@ now send ALL data bytes to FIFO until DONE
transmit_loop:
	LDR R2, [R4, #0x4]          @ get S_REG content
	
	TST R2, #0x100              @ check if bit 8 ERR is set (NACK)
	MOVNE R0, #2                @ return error code 2	
	BNE transmit_ERR2           @ exit on error
	
	TST R0, #0x200              @ check if bit 9 CLKT is set (timeout)
	MOVNE R0, #1                @ return error code 1	
	BNE transmit_ERR1           @ exit on error
	
	TST R2, #0x2                @ test DONE bit, 1 == all data have been sent
	MOVNE R0, #0                @ return error code 0	
	BNE transmit_done           @ exit
	
	TST R2, #0x10               @ test TXD bit, 0 == FIFO is FULL
	BEQ transmit_loop           @ if FIFO is FULL, poll again until avaiable
	
	LDR R2, [R1]                @ else get remaining number of bytes to be sent
	CMP R2, #0x0                @ check if there are still data in waiting
	BEQ transmit_loop           @ all bytes sent to FIFO, poll for DONE signal
		
	LDR R3, [R0], #1            @ else get the next byte and increment pointer
	STR R3, [R4, #0x10]         @ sent to FIFO	
	SUB R2, R2, #1              @ decrement byte counter
	STR R2, [R1]                @ save counter back to memory
	B transmit_loop             @ next byte...

transmit_ERR2:
	ORR R2, R2, #0x100          @ write 1 to clear ERR flag, if any
transmit_ERR1:
	ORR R2, R2, #0x200          @ write 1 to clear CLKT flag, if any
transmit_done:	
	ORR R2, R2, #0x02           @ write 1 to clear DONE flag
	STR R2, [R4, #0x4]          @ save to S_REG
	LDMFD	R13!, {R1-R4, PC} 	@ restore resister and pc
	
@========================== Delay loop =========================================
delay_1s:
	LDR	R1, =0x01FFFFF		@ init register counter value ~ 1 second
	DELAY_LOOP:				@ REPEAT
	SUBS	R1, R1, #1		@ decrease counter by 1 and set flag
	BNE	DELAY_LOOP			@ UNTIL counter = 0 (Z flag set)
	bx lr
	
@========================== LED ON/OFF =========================================
off:
    MOV R2, #1
    MOV R2, R2, lsl #S_LED
	LDR R0,=GPSET0
    STR R2, [R0]
	BX LR
on:
    MOV R2, #1
    MOV R2, R2, lsl #S_LED
	LDR R0,=GPCLR0
    STR R2, [R0]
	BX LR
	
@=========================== END OF PROGRAM ====================================
EXIT:
	NOP
.data

STRING_0: .byte 0x1, 0x2, 0x3, 0x4
.align 2
LENGTH_0: .word len

.end

