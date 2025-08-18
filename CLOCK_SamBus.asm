;/------------------------------------------------------------------------------------------\
;|									CLOCK: SamBus 											|
;|------------------------------------------------------------------------------------------|
;| All the code needed to read the SamBus clock												|
;|------------------------------------------------------------------------------------------|
;| PUBLIC FUNCTIONS:																		|
;|	SAMBS_IsPresent			- Detects if the SAMBUS Clock is present on the system			|
;|	SAMBUS_ReadClock		- Reads the current date and time into a buffer					|
;\------------------------------------------------------------------------------------------/

;--------------------------------------------------------------------------------------------
; Detects if a SamBus clock is present on the system
;--------------------------------------------------------------------------------------------
; INPUT:
;	None
; OUTPUT:
;	None
;--------------------------------------------------------------------------------------------
SAMBUS_IsPresent:
							; See if we can change the year on the SamBus clock
							ld		bc, I_SMB_CLK_10YEAR
							ld		d, 15

							; Remember the current value
							in		e, (c)
@SBIP_Loop:							
							; Change and check
							out		(c), d
							in		a, (c)
							and		15
							cp		d
							jr		nz, @SBIP_DoneCheck
							dec		d
							jr		@SBIP_Loop
@SBIP_DoneCheck:
							; Restore the value, if D was 255 then we have a SMB Clock
							out		(c), e
							inc		d

							; Z if SamBus clock present - else NZ
							ret

;--------------------------------------------------------------------------------------------
; Reads the date + time from the SAMBUS clock, reads in Day/Month/Year/Hour/Minutes/Seconds
;--------------------------------------------------------------------------------------------
; INPUT:
;	HL : 6 byte buffer to read into
; OUTPUT:
;	FLAGS : NZ - Clock read OK or Z - Error reading clock
;--------------------------------------------------------------------------------------------
SAMBUS_ReadClock:
							; Hold the clock
							ld		bc, I_SMB_CLK_CONTROL
							ld		de, 2000
@SBRC_HoldLoop:
							; Set the hold
							ld		a, 1
							out		(c), a

							; See if we are still busy
							in		a, (c)
							and		%00000010
							jr		z, @SBRC_Ready

							; Turn off the hold
							xor		a
							out		(c), a
							dec		de
							cp		d
							jr		nz, @SBRC_HoldLoop

							; Must be an error with the clock
							ret
@SBRC_Ready:
							; Now read the values
							ld		bc, I_SMB_CLK_1DAY
@SBRC_DMYLoop:
							; Read it							
							call	@SBRC_ReadPair

							; Move on
							ld		a, b
							add		&10
							ld		b, a

							; Stop when we get to the end
							cp		&c0
							jr		nz, @SBRC_DMYLoop

							; Now read the HMS
							ld		b, &40
@SBRC_HMSLoop:
							; Read it							
							call	@SBRC_ReadPair

							; Move on
							ld		a, b
							sub		&30
							ld		b, a
							jr		nc, @SBRC_HMSLoop

							; Finally unpause the clock
							ld		b, &d0
							xor		a
							out		(c), a
							ret

@SBRC_ReadPair:				
							; Read the low digit
							in		a, (C)
							and		&0f
							ld		e, a

							; Move to the 10's digit
							ld		a, b
							add		&10
							ld		b, a

							; Read this 
							in		a, (c)
							and		&0f

							; Multiply by 10
							add		a
							ld		d, a
							add		a
							add		a
							add		d

							; Add the units digit
							add		e

							; Store it
							ld		(hl), a
							inc		hl
							ret

;--------------------------------------------------------------------------------------------
