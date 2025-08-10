;/------------------------------------------------------------------------------------------\
;|										Debug System										|
;|------------------------------------------------------------------------------------------|
;| PUBLIC FUNCTIONS:																		|
;|	DEBUG_Display 		- Switch over to a mode 3 debug screen								|
;|	DEBUG_ClearScreen	- Clear the screen and reset cursor to top left						|
;|	DEBUG_PrintChar		- Prints the character in A											|
;|	DEBUG_PrintMessage	- Prints a debug message on the screen								|
;|	DEBUG_PrintHexDEHL 	- print a 32bit number in DE:HL as hex								|
;|	DEBUG_PrintHexHL	- Prints the number in HL as hex									|
;|	DEBUG_PrintHexA		- Prints the number in A as hex										|
;|	DEBUG_PrintDEHL		- Print the number in DE:HL as decimal								|
;\------------------------------------------------------------------------------------------/

;--------------------------------------------------------------------------------------------
; Setup the debug display
;--------------------------------------------------------------------------------------------
; INPUT:
;	None
; OUTPUT:
;	None
;--------------------------------------------------------------------------------------------
DEBUG_Display:
							; Get the address to return to
							ld		de, @DD_Return
							ld		(@DD_Return + 1), sp

							; Get current HMPR
							in		a, (IO_HMPR)

							; Now we want to push our code onto stack "POP AF, OUT (IO_HMPR), A, RET"
							ld		bc, &c9fb
							push	bc
							ld		bc, &d3f1
							push	bc
							
							; Get the current SP
							ld		hl, 0
							add		hl, sp

							; Now push the return address, the data and the function address
							push	de
							push	af
							push	hl

							; Finally ask it do 
							ld		a, 2
							jp		SYSCALL_JMODE
@DD_Return:
							ld		sp, 0

							; Turn off the screen prompt
							ld		a, 1
							ld		(SVAR_SPROMPT), a

							; Clear the screen
							call	DEBUG_ClearScreen
							ret

;--------------------------------------------------------------------------------------------
; Clears the screen and then positions the cursor at he top left
;--------------------------------------------------------------------------------------------
; INPUT:
;	None
; OUTPUT:
;	None
;--------------------------------------------------------------------------------------------
DEBUG_ClearScreen:
							; Make sure the screen is clear
							xor		a
							call	SYSCALL_JCLSBL

							; Set the stream
							ld		a, 2
							call	SYSCALL_JSETSTRM

							; Move the cursor
							call	DEBUG_PrintMessage
							db		22,0,128
							ret 

;--------------------------------------------------------------------------------------------
; Prints the character in A - Seems pointless, but this could be updated to print in other ways
;--------------------------------------------------------------------------------------------
; INPUT:
;	A - The value to print
; OUTPUT:
;	None
;--------------------------------------------------------------------------------------------
DEBUG_PrintChar:
							rst		&10
							ret

;--------------------------------------------------------------------------------------------
; Prints a debug message
;--------------------------------------------------------------------------------------------
; INPUT:
;	Message - Data following function will be printed until a byte with bit 7 is found
; OUTPUT:
;	None
;--------------------------------------------------------------------------------------------
DEBUG_PrintMessage:
							; Get the return address as thats where the data is
							pop		hl
@DPM_Loop:					
							ld		a, (hl)
							inc		hl
							rlca
							srl		a
							push	af
							call	DEBUG_PrintChar
							pop		af
							jr		nc, @DPM_Loop

							; Return
							jp		(hl)

;--------------------------------------------------------------------------------------------
; Print a 32 bit hex number
;--------------------------------------------------------------------------------------------
; INPUT:
;	DE:HL - The 32Bit number to print in hex
; OUTPUT:
;	None
;--------------------------------------------------------------------------------------------
DEBUG_PrintHexDEHL:
							push	de

							; First print DE
							push	hl
							ex		de, hl
							call	DEBUG_PrintHexHL

							; Now print HL
							pop		hl
							call	DEBUG_PrintHexHL

							pop		de
							ret
							
;--------------------------------------------------------------------------------------------
; Prints a HL as hex
;--------------------------------------------------------------------------------------------
; INPUT:
;	HL - Number to print
; OUTPUT:
;	None
;--------------------------------------------------------------------------------------------
DEBUG_PrintHexHL:
							push	hl

							; Just print each part
							ld		a, h
							call	DEBUG_PrintHexA
							ld		a, l
							call	DEBUG_PrintHexA

							pop		hl
							ret

;--------------------------------------------------------------------------------------------
; Prints a A as hex
;--------------------------------------------------------------------------------------------
; INPUT:
;	A - Number to print
; OUTPUT:
;	None
;--------------------------------------------------------------------------------------------
DEBUG_PrintHexA:
							push	af

							; Get the top digit
							rrca
							rrca
							rrca
							rrca

							; Print it
							call	_DEBUG_PrintDigit

							; Now do the bottom digit
							pop		af

							call	_DEBUG_PrintDigit

							ret

;--------------------------------------------------------------------------------------------
; Prints a nunmber as decimal
;--------------------------------------------------------------------------------------------
; INPUT:
;	DE:HL - 32 bit number to print as decimal
;	A - 0 for no leading digits, else the character to display (usually 0 or space)
; OUTPUT:
;	None
;--------------------------------------------------------------------------------------------
DEBUG_PrintDEHL:
							; Setup for print (largest number is FFFFFFFF which is 4294967295 in decimal - max 10 digits)
							push	de
							exx
							pop		hl
							ld		de, &3b9a						; 1,000,000,000 / 65536
							exx
							ld		de, &ca00						; 1,000,000,000 % 65536
							call	_DEBUG_CalcDigit

							; Now 100,000,000
							exx
							ld		de, &05f5						; 100,000,000 % 65536
							exx
							ld		de, &e100						; 100,000,000 / 65536
							call	_DEBUG_CalcDigit

							; 10,000,000
							exx
							ld		de, &0098						; 10,000,000 % 65536
							exx
							ld		de, &9680						; 10,000,000 / 65536
							call	_DEBUG_CalcDigit

							; 1,000,000
							exx
							ld		de, &000f						; 1,000,000 % 65536
							exx
							ld		de, &4240						; 1,000,000 / 65536
							call	_DEBUG_CalcDigit

							; 100,000
							exx
							ld		de, &0001						; 100,000 % 65536
							exx
							ld		de, &86a0						; 100,000 / 65536
							call	_DEBUG_CalcDigit

							; 10,000
							exx
							ld		de, &0000						; 10,000 % 65536
							exx
							ld		de, &2710						; 10,000 / 65536
							call	_DEBUG_CalcDigit

							; 1,000
							exx
							ld		de, &0000						; 10,000 % 65536
							exx
							ld		de, &03e8						; 1,000 / 65536
							call	_DEBUG_CalcDigit

							; 100
							exx
							ld		de, &0000						; 10,000 % 65536
							exx
							ld		de, &0064						; 100 / 65536
							call	_DEBUG_CalcDigit

							; 10
							exx
							ld		de, &0000						; 10,000 % 65536
							exx
							ld		de, &000a						; 10 / 65536
							call	_DEBUG_CalcDigit

							; Print the final digit
							ld		a, l
							add		"0"
							call	DEBUG_PrintChar

							ret

_DEBUG_CalcDigit:
							; Remember the leading character
							ex		af, af'

							; 32bit subtraction
							xor		a
@DCD_Loop:
							sbc		hl, de
							exx
							sbc		hl, de
							exx
							jr		c, @DCD_GotCount

							inc		a
							jr		@DCD_Loop
@DCD_GotCount:
							; Do an increase so we get the quotient back 
							add		hl, de
							exx
							adc		hl, de
							exx

							; We now have the value in to display
							and		a
							jr		nz, @DCD_NotZero

							; Now, if this is a leading 0, we want to display the leading character (maybe nothing), after
							; we have displayed a non-zero character this will always be "0"
							ex		af, af'
							and		a
							ret		z
							jp		@DCD_DoPrint

@DCD_NotZero:
							; We can just display the digit
							add		"0"
							call	@DCD_DoPrint

							; As this was a digit, all future 0's will print as "0"
							ld		a, "0"
							ret

@DCD_DoPrint:
							; Store HL'
							exx
							push	hl
							exx

							; Print the character
							call	DEBUG_PrintChar

							; Restore HL'
							exx
							pop		hl
							exx

							ret

;--------------------------------------------------------------------------------------------
; INTERNAL: Prints the digit in A, will print in hex so can be used for decimal as well
;--------------------------------------------------------------------------------------------
; INPUT:
;	A - Number to print
; OUTPUT:
;	None
;--------------------------------------------------------------------------------------------
_DEBUG_PrintDigit:			
							push	af

							; Mask off the top digits
							and		&0f

							; Is it a lette or digit
							cp		10
							jr		nc, @DPD_Letter
@DPD_Digit:				
							add		"0" - ("A" - 10)
@DPD_Letter:				
							add		"A" - 10
							call	DEBUG_PrintChar

							pop		af
							ret

;--------------------------------------------------------------------------------------------
; Variables
;--------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------
