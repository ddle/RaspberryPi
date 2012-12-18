@========================== Delay loops =========================================
@ pass number of ms on R0 for appropriate delay
.global delay_ms
delay_ms:
	STMFD	R13!, {R0, LR}	    @ save registers, R14
	ms_LOOP:                    @ REPEAT
	BL delay_1ms
	SUBS	R0, R0, #1          @ decrease counter by 1 and set flag
	BNE	ms_LOOP                 @ UNTIL counter = 0 (Z flag set)
	LDMFD	R13!, {R0, PC}      @ restore resister and return	

.global delay_1ms
delay_1ms:
	STMFD	R13!, {R1, LR}	    @ save registers, R14
	MOV	R1, #0x3600             @ init register counter value ~ 1ms second
	ONEms_LOOP:                 @ REPEAT
	SUBS	R1, R1, #1          @ decrease counter by 1 and set flag
	BNE	ONEms_LOOP              @ UNTIL counter = 0 (Z flag set)
	LDMFD	R13!, {R1, PC}      @ restore resister and return	

.global delay_1s
delay_1s:
	STMFD	R13!, {R1, LR}	    @ save registers, R14
	MOV	R1, #0x0D00000          @ init register counter value ~ 1 second
	ONEs_LOOP:                  @ REPEAT
	SUBS	R1, R1, #1          @ decrease counter by 1 and set flag
	BNE	ONEs_LOOP               @ UNTIL counter = 0 (Z flag set)
	LDMFD	R13!, {R1, PC}      @ restore resister and return
