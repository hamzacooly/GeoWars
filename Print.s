; Print.s
; Student names: change this to your names or look very silly
; Last modification date: change this to the last modification date or look very silly
; Runs on LM4F120 or TM4C123
; EE319K lab 7 device driver for any LCD
;
; As part of Lab 7, students need to implement these LCD_OutDec and LCD_OutFix
; This driver assumes two low-level LCD functions
; ST7735_OutChar   outputs a single 8-bit ASCII character
; ST7735_OutString outputs a null-terminated string 

    IMPORT   ST7735_OutChar
    IMPORT   ST7735_OutString
    EXPORT   LCD_OutDec
    EXPORT   LCD_OutFix

    AREA    |.text|, CODE, READONLY, ALIGN=2
    THUMB
	PRESERVE8

  

;-----------------------LCD_OutDec-----------------------
; Output a 32-bit number in unsigned decimal format
; Input: R0 (call by value) 32-bit unsigned number
; Output: none
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutDec
	PUSH {R7, LR}		;save LR because subroutine is called, save R11 so that stays 4 byte aligned
		CMP R0, #10    		;checking to see if the character is less than 10
		BLO ODEnd			;if the character is less than 10, go to the end
	    MOV R2, #10			;Put 10 in R2, this will be a divisor
		UDIV R3, R0, R2 	;Divide the unsigned 32 bit number by 10, store in R3 (R3 = R0/R2)
		MUL R1, R3, R2 		;R1 = num/(10*10)
		SUB R1, R0, R1 		;R1 = num%10
		PUSH {R1, R6}		;Save R1, R6 is to preserve 8 byte alignment
		MOVS R0, R3			;num = num/10, R0 will be used for input when the function calls itself
		BL LCD_OutDec		;Calling LCD_OutDec(Updated num)
		POP {R0, R6}		;restore R1 into R0, , R6 is to preserve 8 byte alignment
		
ODEnd   
		ADD R0, R0, #0x30	;converts to ASCII, puts in R0 so it can be the input for ST7735_OutChar
		BL ST7735_OutChar	;print character to LCD
		POP {R7, LR}		;balance stack

      BX  LR
;* * * * * * * * End of LCD_OutDec * * * * * * * *

; -----------------------LCD _OutFix----------------------
; Output characters to LCD display in fixed-point format
; unsigned decimal, resolution 0.001, range 0.000 to 9.999
; Inputs:  R0 is an unsigned 32-bit number
; Outputs: none
; E.g., R0=0,    then output "0.000 "
;       R0=3,    then output "0.003 "
;       R0=89,   then output "0.089 "
;       R0=123,  then output "0.123 "
;       R0=9999, then output "9.999 "
;       R0>9999, then output "*.*** "
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutFix

		PUSH {R0-R4, LR}
		LDR	R1, =0x270F
		CMP	R0, R1				;if R0<=9999,
		BLS	FixOut				;then proceed with fix
		MOV	R0, #"*"			;otherwise, output *.***
		BL	ST7735_OutChar
		MOV	R0, #"."
		BL	ST7735_OutChar
		MOV	R0, #"*"
		BL	ST7735_OutChar
		MOV	R0, #"*"
		BL	ST7735_OutChar
		MOV	R0, #"*"
		BL	ST7735_OutChar
		B	ExitOutFix
FixOut
		MOV	R1, #0x0A			;initialize starting values needed
		SUB	SP, SP, #40
		MOV	R12, #0x00
		MOV	R3, #0x00
		MOV	R4, #4
SetZero
		LSL	R2, R12, #2			;set number of leading zeros
		STR	R3, [SP, R2]
		ADD	R12, R12, #1
		SUBS R4, R4, #1
		BNE	SetZero
BacktoFix
		MOV	R12, #0x00			;reinitializes more values
		MOV	R4, #3
FixStore
		CMP	R0, #0x09
		BLS	LastNum2
		UDIV R2, R0, R1
		MLS	R3, R2, R1, R0
		MOV	R0, R2
		LSL	R2, R12, #2
		STR	R3, [SP, R2]
		ADD	R12, R12, #1
		B	FixStore
LastNum2
		LSL	R2, R12, #2
		STR	R0, [SP, R2]
		ADD	R12, R12, #1
Print
		MOV	R12, #4
		SUB	R12, R12, #1
		LSL	R2, R12, #2
		LDR R0, [SP, R2]
		ADD	R0, R0, #0x30
		BL	ST7735_OutChar			;prints X.000 (ones place)
		MOV	R0, #"."
		BL	ST7735_OutChar			;prints the decimal
		SUB	R12, R12, #1
		LSL R2, R12, #2
		LDR	R0, [SP, R2]
		ADD	R0, R0, #0x30
		BL	ST7735_OutChar			;prints 0.X00 (tenths place)
		SUB	R12, R12, #1
		LSL	R2, R12, #2
		LDR	R0, [SP, R2]
		ADD	R0, R0, #0x30
		BL	ST7735_OutChar			;prints 0.0X0 (hundredths place)
		SUB	R12, R12, #1
		LSL	R2, R12, #2
		LDR	R0, [SP, R2]
		ADD	R0, R0, #0x30
		BL	ST7735_OutChar			;prints 0.00X (thousandths place)
		ADD	SP, SP, #40
ExitOutFix
		POP	{R0-R4, PC}
		BX LR
     ALIGN
;* * * * * * * * End of LCD_OutFix * * * * * * * *

     ALIGN                           ; make sure the end of this section is aligned
     END                             ; end of file
