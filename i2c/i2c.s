@===============================================================================
@ "Bare metal" I2C driver for raspberry pi
@  Copyright by Dung Le, 2012
@ 
@ Description:
@ - Routines defined : i2c_read, i2c_write, i2c_flush_fifo, i2c_init
@ - A "main" loop is implemented as an example of using these routines
@ - The setup is:
@    compass sensor <--- I2C ---> RaspberryPi <--- I2C ---> Arduino
@    (sending slave 0x1E)            master                (receiving slave 0x4)
@ - external pull up on signal line may required
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

.equ ARDUINO_ADDR,      0x4    @ Arduino as receiving slave
.equ HMC5883_ADDR,     0x1E    @ HMC5883 as sending slave

@ message length
.equ len,                14

	LDR SP, =STACK             @ setup stack
	ADD SP, SP, #256           @ 
	BL led_init                @ initialize status led for indicator
	BL i2c_init
@==================== MAINLINE program =========================================
@ put HMC5883 into operating mode, see Datasheet page 18
	MOV R0, #HMC5883_ADDR
	BL i2c_set7bitSlaveAddress
	LDR R0, =HMC5883_CMD_0     @ continuous measurement mode (sample rate: 15HZ)
	MOV R1, #2                  
	BL i2c_write
@ Datasheet said wait 6ms...
	MOV R0, #10                @ wait 10ms
	BL delay_ms
	
LOOP:
	BL led_on                  @ LED on
@ read 6 bytes from 3-axis sensor	
	MOV R0, #HMC5883_ADDR
	BL i2c_set7bitSlaveAddress @ reset address for sure
	LDR R0, =XYZ               @ read param: pointer to 3-axis buffer	
	MOV R1, #6                 @ read param: 6 bytes
	BL i2c_read
	
	BL delay_1ms               @ wait a little bit before next transactions

@ now send received data to arduino		
	MOV R0, #ARDUINO_ADDR      @ 	
	BL i2c_set7bitSlaveAddress @
	LDR R0, =XYZ               @ 
	MOV R1, #6                 @ 
	BL i2c_write
		
	BL delay_1ms               @ wait a little bit before next transactions
	
@ now reset sensor internal address back to 0x3 for next read
	MOV R0, #HMC5883_ADDR      @ 	
	BL i2c_set7bitSlaveAddress @
	LDR R0, =HMC5883_CMD_1     @ select internal address 0x3
	MOV R1, #1                 @ 
	BL i2c_write	
			
	BL led_off	               @ LED off
	MOV R0, #100               @ wait interval between readings
	BL delay_ms
	B LOOP
	
@==================== initialize I2C  ==========================================
@ Description: initialize i2c bus
@ return none
@ TODO:
@ disable internal pull up?
@ set alternate function 0 (i2c) on SDA0 (GPIO_0) and SCL0 (GPIO_1)
@ set i2c speed to 100kHZ

i2c_init: 
	STMFD	R13!, {R0-R4, LR}	@ save registers, LR
@ i2c status register: clear ERR,CLKT,DONE flag
	LDR R4, =I2C0_BASE         @ use base for register addressing
	LDR R2, [R4, #0x4]         @ S_REG
	ORR R2, R2, #0x100         @ write 1 to clear ERR flag, if any
	ORR R2, R2, #0x200         @ write 1 to clear CLKT flag, if any
	ORR R2, R2, #0x02          @ write 1 to clear DONE flag
	STR R2, [R4, #0x4]         @ save to S_REG
@ i2c control register
	LDR R1, =C_REG 
	LDR R0, =0x8030	           @ setting: enable i2c, clear buffer
	STR R0, [R1]
	LDMFD	R13!, {R0-R4, PC} 	@ restore resister and return
	
@==================== set 7 bit slave address  =================================
@ Description: select slave address (7 bit) at the begining of i2c transactions
@ Params:
@	R0 = 7 bit address
@ Return: none

i2c_set7bitSlaveAddress:
	STMFD	R13!, {R1, LR}	    @ save registers, R14
	LDR R1, =A_REG 
	STR R0, [R1]
	LDMFD	R13!, {R1, PC} 	    @ restore resister and return
	
@==================== i2c write transactions ===================================
@ Description: write data string to i2c bus
@ Params
@	R0 = pointer to data buffer
@	R1 = length of data
@ Return: error status (-2): NACK, (-1): TIMEOUT, (0): NORMAL RETURN
@ TODO: 
@ check params validity

i2c_write:
	STMFD	R13!, {R2-R5, LR}	@ save registers, LR
	LDR R4, =I2C0_BASE          @ use base for register addressing
	LDR R2, =WRITE_LENGTH       @ data length
@ set data length
	STR R1, [R2]                @ save current data length to memory
	STR R1, [R4, #0x8]          @ set data length in DLEN_REG
@ configure write transaction
	LDR R5, [R4]                @ get C_REG content
	MVN R3, #0x1                @ mask for clearing READ bit (= Write)		
	AND R5, R5, R3
@ clear FIFO before transmit and set start bit
	MOV R3, #0xB0               @ mask for setting CLEAR bits and START bit
	ORR R5, R5, R3          
	STR R5, [R4] 
	
@ now send ALL data bytes to FIFO until DONE
transmit_loop:
	LDR R5, [R4, #0x4]          @ get S_REG content
	
	TST R5, #0x100              @ check if bit 8 ERR is set (NACK)
	MOVNE R0, #2                @ return error code 2	
	BNE transmit_ERR2           @ exit on error
	
	TST R5, #0x200              @ check if bit 9 CLKT is set (timeout)
	MOVNE R0, #1                @ return error code 1	
	BNE transmit_ERR1           @ exit on error
	
	TST R5, #0x2                @ test DONE bit, 1 == all data have been sent
	MOVNE R0, #0                @ return error code 0	
	BNE transmit_done           @ exit
	
	TST R5, #0x10               @ test TXD bit, 0 == FIFO is FULL
	BEQ transmit_loop           @ if FIFO is FULL, poll again until avaiable
	
	LDR R5, [R2]                @ else get remaining number of bytes to be sent
	CMP R5, #0x0                @ check if there are still data in waiting
	BEQ transmit_loop           @ all bytes sent to FIFO, poll for DONE signal		
	
	SUB R5, R5, #1              @ else decrement byte counter
	STR R5, [R2]                @ save counter back to memory
	
	LDRB R3, [R0], #1           @ get the next byte and increment pointer
	STRB R3, [R4, #0x10]        @ sent to FIFO	
	
	B transmit_loop             @ next byte...

transmit_ERR2:
	ORR R5, R5, #0x100          @ write 1 to clear ERR flag, if any
transmit_ERR1:
	ORR R5, R5, #0x200          @ write 1 to clear CLKT flag, if any
transmit_done:	
	ORR R5, R5, #0x02           @ write 1 to clear DONE flag
	STR R5, [R4, #0x4]          @ save to S_REG
	LDMFD	R13!, {R2-R5, PC} 	@ restore resister and return

@==================== i2c read transactions ===================================
@ Description: read some amounts of data out of the i2c bus (FIFO)
@ Params
@	R0 = pointer to read buffer
@	R1 = number of bytes to read
@ Return: error status (-2): NACK, (-1): TIMEOUT, (0): NORMAL RETURN
@ TODO: 
@ check params validity

i2c_read:
	STMFD	R13!, {R2-R5, LR}	@ save registers, LR
	LDR R4, =I2C0_BASE          @ use base for register addressing
	LDR R2, =READ_LENGTH        @ data length
@ set data length in memory and DLEN_REG
	STR R1, [R2]                @ save current data length to memory
	STR R1, [R4, #0x8]          @ set data length in DLEN_REG
@ configure read transaction
	LDR R5, [R4]                @ get C_REG content
	MOV R3, #0x1                @ mask for setting READ bit (=read)		
	ORR R5, R5, R3
@ set start bit
	MOV R3, #0x80               @ mask for setting START bit
	ORR R5, R5, R3          
	STR R5, [R4] 

receive_loop:
	LDR R5, [R4, #0x4]          @ get S_REG content
	
	TST R5, #0x100              @ check if bit 8 ERR is set (NACK)
	MOVNE R0, #2                @ return error code 2	
	BNE receive_ERR2            @ exit on error
	
	TST R5, #0x200              @ check if bit 9 CLKT is set (timeout)
	MOVNE R0, #1                @ return error code 1	
	BNE receive_ERR1            @ exit on error
	
	TST R5, #0x2                @ DONE bit, 1==all requested data have been read
	MOVNE R0, #0                @ return error code 0	
	BNE receive_done            @ exit
	
	TST R5, #0x20               @ test RXD bit, 0 == FIFO is empty
	BEQ receive_loop            @ if FIFO is empty, poll again until avaiable
	
	LDR R5, [R2]                @ else get remaining number of bytes to be read
	CMP R5, #0x0                @ check if there are still data in waiting
	BEQ receive_loop            @ all requested bytes read, poll for DONE signal		
	
	SUB R5, R5, #1              @ else decrement byte counter
	STR R5, [R2]                @ save counter back to memory
	
	LDRB R3, [R4, #0x10]        @ get byte from FIFO
	STRB R3, [R0], #1           @ save to buffer and increment pointer
	
	B receive_loop              @ process next byte...

receive_ERR2:
	ORR R5, R5, #0x100          @ write 1 to clear ERR flag, if any
receive_ERR1:
	ORR R5, R5, #0x200          @ write 1 to clear CLKT flag, if any
receive_done:	
	ORR R5, R5, #0x02           @ write 1 to clear DONE flag
	STR R5, [R4, #0x4]          @ save to S_REG
	LDMFD	R13!, {R2-R5, PC} 	@ restore resister and return


@========================== Flush FIFO =========================================
i2c_flush_fifo:
	STMFD	R13!, {R3-R5, LR}  @ save registers, R14
	LDR R4, =C_REG
	LDR R5, [R4]                @ get C_REG content
	MOV R3, #0x30               @ mask for setting CLEAR bits
	ORR R5, R5, R3          
	STR R5, [R4]
	LDMFD	R13!, {R3-R5, PC} 	@ restore resister and return
	
@=========================== END OF PROGRAM ====================================
EXIT:
	NOP
	
.data
WRITE_BUFFER:     .ascii "hello world!\r\n"

.align 2
WRITE_LENGTH:     .word 0x0

READ_BUFFER:      .rept 256    @ static buffer for receiving data
                  .byte 0x0
                  .endr

READ_LENGTH:      .word 0x0  

HMC5883_CMD_0:    .byte 0x2     @ select mode register
                  .byte 0x0     @ continuous measurement mode
.align 2
HMC5883_CMD_1:                  
                  .byte 0x3     @ select reg 3 (MSB X, 1st byte in the packet)
                  
.align 2
XYZ:              .byte 0x0     @ X, MSB
                  .byte 0x0     @ X, LSB
                  .byte 0x0     @ Y, MSB
                  .byte 0x0     @ Y, LSB
                  .byte 0x0     @ Z, MSB
                  .byte 0x0     @ Z, LSB
                  
.align 2            
STACK:            .rept 256
                  .byte 0x0
                  .endr
                  
.end

