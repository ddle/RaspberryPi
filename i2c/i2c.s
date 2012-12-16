@===============================================================================
@ "Bare metal" I2C driver for raspberry pi
@  Copyright by Dung Le, 2012
@===============================================================================
.text
.global _start
_start:

@ registers map:
.equ IDBR, 0x40301688
.equ ICR , 0x40301690
.equ ISR , 0x40301698
.equ GPDR2, 0x40E00014
.equ GRER2, 0x40E00038
.equ ICMR , 0x40D00004
.equ ICIP , 0x40D00000
.equ GEDR2, 0X40E00050
	
@==================== initialize I2C CONTROLLER ================================
	LDR R10, =ICR		@ I2C CONTROL REGISTER
	LDR R9, =IDBR		@ I2C DATA BUFFER
	LDR R8, =ISR		@ I2C STATUS REGISTER	
	MOV R0, #0x60		@ CONTROL WORD TO ENABLE I2C UNIT, AS MASTER WITH SCL
	STR R0, [R10]		@ WRITE TO I2C CONTROL REGISTER
@===============================================================================

@==================== MAINLINE program =========================================
LOOP:
B LOOP
@===============================================================================

@==================== POLLTB procedure =========================================
@ HALL: PROCEDURE TO POLL ICR[TB] STATUS
@ ALSO CHECK IF AN ACK ERROR OCCURRED AND ISR[BED] WAS SET

POLLTB:
	LDR R0, [R8]		@ READ REGISTER CONTEND
	TST R0, #0x400		@ CHECK IF BED ON BIT 10 IS SET = ACK ERROR
	MOVNE R0, #1		@ RETURN ERROR CODE = 1 IN R0 IF ACK ERROR
	BNE EXIT			@ EXIT ON ERROR
	LDR R0, [R10]		@ I2C CONTROL REGISTER
	TST R0, #0x08		@ CHECK IF TB ON BIT 3 RESET = 0 FOR TX/RX DONE
	BNE POLLTB			@ LOOP UNTIL TB BIT = 0
	MOV PC,LR			@ RETURN
@===============================================================================

@==================== MAX7313_MOD_REG procedure ================================
@ PASSING PARAMETTERS NEEDED : 
@	R2 = INTERNAL REGISTER ADDRESS
@	R3 = BYTE TO MODIFY
@	R4 = CLEAR/SET MODE : 0 = CLEAR, 1 = SET, 2 = BLINK MODE
@ TO USE BLINK MODE, PASS THE DESIRED VALUES TO R3 (ACTIVE LOW, BIT 3-5, OTHER 
@ BITS SHOULD BE 0, FOR E.G PASS 0b00101000 TO LIGHT LED P4)
@ RETURN : NONE

MAX7313_MOD_REG:
@ SAVE REGS
	STMFD	R13!, {R0-R4, R14}		@ save registers, R14
@ READ reg PATTERN :
@ S + SLAVE ADD + W -> [REGISTER ADD] -> S + SLAVE ADD + R -> READ BUFFER -> P

@ START, SEND SLAVE ADDRESS AND R/nW = 0 TO WRITE
	MOV R0, #0x42		@ ADDRESS : 7BITS + WRITE BIT {7'b0100 001,0}
	STR R0, [R9]		@ WRITE TO IDBR
	MOV R0, #0x69		@ SEND WORD TO ICR TB = 1, STOP = 0, START = 1
	STR R0, [R10]		@ WRITE TO ICR
	BL POLLTB		@ WAIT FOR BYTE SEND AND ACK RECEIVE

@ SEND INTERNAL REGISTER ADDRESS
	MOV R0, R2		@ ADDRESS CODE
	STR R0, [R9]		@ WRITE TO IDBR
	MOV R0, #0x68		@ SEND WORD TO ICR TB = 1, STOP = 0, START = 0
	STR R0, [R10]		@ WRITE TO ICR
	BL POLLTB		@ WAIT FOR BYTE SEND AND ACK RECEIVE
	
@ START, SEND SLAVE ADDRESS AND R/nW = 1 TO READ
	MOV R0, #0x43		@ ADDRESS : 7BITS + read BIT {7'b0100 001,1}
	STR R0, [R9]		@ WRITE TO IDBR
	MOV R0, #0x69		@ SEND WORD TO ICR TB = 1, STOP  = 0, START = 1
	STR R0, [R10]		@ WRITE TO ICR
	BL POLLTB		@ WAIT FOR BYTE SEND AND ACK RECEIVE
	
@ SET UP READ RANGE BYTES SENT FROM MAX7313	
	MOV R0, #0x68		@ SEND WORD TO ICR TB = 1, STOP = 0, START = 0
	STR R0, [R10]		@ WRITE TO ICR
	BL POLLTB		@ WAIT FOR BYTE SEND AND ACK RECEIVE
	
@ READ REGISTER CONTENT ON BUFFER THEN STOP
	LDR R1, [R9]		@ READ BUFFER
	MOV R0, #0x6E		@ SEND TO ICR TB = 1,STOP = 1,START = 0,ACK=1
	STR R0, [R10]		@ WRITE TO ICR
	BL POLLTB		@ WAIT FOR BYTE SEND AND ACK RECEIVE

@ MODIFY 
	CMP R4,#0		@ IF MODE == CLEAR
	BICEQ R1, R1, R3	@ APPLY CLEAR
	BEQ ENDMOD
	CMP R4,#1		@ IF MODE == SET
	ORREQ R1, R1, R3	@ APPLY SET
	BEQ ENDMOD
				@ ELSE : BLINK MODE
	BIC R1, R1, #0x38	@ CLEAR BIT 3,4,5 FIRST
	ORR R1, R1, R3		@ THEN MASK WITH VALUE ON R3

ENDMOD:
@ WRITE BACK TO INTERNAL REGISTER
@ WRITE PATTERN : {101}+SLAVE ADD+W->{100}[REGISTER ADD]->{110} DATA BYTE
@ SEND SLAVE ADDRESS AND R/nW = 0 TO WRITE
	MOV R0, #0x42		@ ADDRESS : 7BITS + WRITE BIT {7'b0100 001,0}
	STR R0, [R9]		@ WRITE TO IDBR
	MOV R0, #0x69		@ SEND WORD TO ICR TB = 1, STOP = 0, START = 1
	STR R0, [R10]		@ WRITE TO ICR
@ WAIT FOR BYTE SEND AND ACK RECEIVE
	BL POLLTB
@ SEND INTERNAL REGISTER ADDRESS
	MOV R0, R2		@ ADDRESS CODE FOR CONFIGURATION REGISTER P0-P7
	STR R0, [R9]		@ WRITE TO IDBR
	MOV R0, #0x68		@ SEND WORD TO ICR TB = 1, STOP = 0, START = 0
	STR R0, [R10]		@ WRITE TO ICR
@ WAIT FOR BYTE SEND AND ACK RECEIVE
	BL POLLTB
@ SEND BYTE TO MODIFY
	STRB R1, [R9]		@ WRITE TO IDBR
	MOV R0, #0x6A		@ SEND WORD TO ICR TB = 1, STOP = 1, START = 0
	STR R0, [R10]		@ WRITE TO ICR
@ WAIT FOR BYTE SEND AND ACK RECEIVE
	BL POLLTB
@ RESTORE AND RETURN	
	LDMFD	R13!, {R0-R4, PC} 		@ restore resister and pc
@===============================================================================

@============================END OF PROGRAM=======================================
EXIT:
	NOP
.end

