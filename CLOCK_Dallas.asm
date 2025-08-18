;/------------------------------------------------------------------------------------------\
;|									CLOCK: Dallas Original									|
;|------------------------------------------------------------------------------------------|
;| All the code needed to read an original Dallas Clock										|
;|------------------------------------------------------------------------------------------|
;| PUBLIC FUNCTIONS:																		|
;|	DALLAS_IsPresent		- Detects if the DALLAS Clock is present on the system			|
;|	DALLAS_ReadClock		- Reads the current date and time into a buffer					|
;\------------------------------------------------------------------------------------------/

;--------------------------------------------------------------------------------------------
; Detects if a Dallas original is present on the system
;--------------------------------------------------------------------------------------------
; INPUT:
;	None
; OUTPUT:
;	Z Flag set if we have dallas else NZ
;--------------------------------------------------------------------------------------------
DALLAS_IsPresent:
							; Is it a DALLAS clock
							ld		de, &003f

							; Remember the value and again see if we can set it
							call	_DALLAS_ReadRegister
							ex		af, af'
@DIP_CheckDALLAS:
							; Write the value
							ld		a, d
							call	_DALLAS_WriteRegister
							call	_DALLAS_ReadRegister
							cp		d
							jr		nz, @DIP_NoDallas

							; Move on
							dec		d
							jr		nz, @DIP_CheckDALLAS
@DIP_NoDallas:			
							ex		af, af'
							call	_DALLAS_WriteRegister
							ex		af, af'

							; Z if Dallas is present - else NZ
							ret

;--------------------------------------------------------------------------------------------
; Reads the date + time from the DALLAS clock, reads in Day/Month/Year/Hour/Minutes/Seconds
;--------------------------------------------------------------------------------------------
; INPUT:
;	HL : 6 byte buffer to read into
; OUTPUT:
;	FLAGS : NZ - Clock read OK or Z - Error reading clock (Doesnt happen on DALLAS)
;--------------------------------------------------------------------------------------------
DALLAS_ReadClock:
							; First we need to pause the clock
							ld		e, 11
							call	_DALLAS_ReadRegister
							or		&80
							call	_DALLAS_WriteRegister

							; Get the D/M/Y
							ld		e, 7
@DRC_DMYLoop:
							; Read the value
							call	_DALLAS_ReadRegister
							call	_DALLAS_ConvertBCD
							
							; Store it
							ld		(hl), a
							inc		hl

							; Do all the values
							inc		e
							ld		a, e
							cp		10
							jr		nz, @DRC_DMYLoop

							; Now read the S/M/H
							ld		e, 4
@DRC_HMSLoop:
							; Read the value
							call	_DALLAS_ReadRegister
							call	_DALLAS_ConvertBCD
							
							; Store it
							ld		(hl), a
							inc		hl

							; Do all the values
							dec		e
							dec		e
							jp		p, @DRC_HMSLoop

							; Finally we can un-pause the clock
							ld		e, 11
							call	_DALLAS_ReadRegister
							and		&7f
							call	_DALLAS_WriteRegister
							ret

;--------------------------------------------------------------------------------------------
; Read a register on the DALLAS clock system
;--------------------------------------------------------------------------------------------
; INPUT:
;	E : Address to read
; OUTPUT:
;	A : Data read
;--------------------------------------------------------------------------------------------
_DALLAS_ReadRegister:
							; Write to the control - then inc b to move to data
							ld		bc, IO_DALLAS_CLK_CONTROL
							out		(c), e
							inc		b
							in		a, (c)
							ret

;--------------------------------------------------------------------------------------------
; Write a register on the DALLAS clock system
;--------------------------------------------------------------------------------------------
; INPUT:
;	E : Address to write
;	A : Data to write
; OUTPUT:
;	None
;--------------------------------------------------------------------------------------------
_DALLAS_WriteRegister:
							; Write to the control - then inc b to move to data
							ld		bc, IO_DALLAS_CLK_CONTROL
							out		(c), e
							inc		b
							out		(c), a
							ret

;--------------------------------------------------------------------------------------------
; Convert BCD to Decimal
;--------------------------------------------------------------------------------------------
; INPUT:
;	A : BCD Value
; OUTPUT:
;	A : Decimal Value
;--------------------------------------------------------------------------------------------
_DALLAS_ConvertBCD:
							; Remember the BCD
							ld		b, a

							; Mask off the top digit
							and		&f0

							; Convert to -6 * top digit
							rra
							ld		d, a
							rra
							rra
							sub		d

							; Add this to the original value to convert
							add		b
							ret

;--------------------------------------------------------------------------------------------
