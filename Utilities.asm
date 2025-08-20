;/------------------------------------------------------------------------------------------\
;|										Utilities											|
;|------------------------------------------------------------------------------------------|
;| Various utility functions for the Sam Coupe		 										|
;|------------------------------------------------------------------------------------------|
;| PUBLIC FUNCTIONS																			|
;| UTIL_Mult_HL_BC			- 16/16=>32 Multiply HL by DE returning DEHL					|
;| UTIL_Mult_H_E			- 8/8=>16 Multiply H by E returning in HL						|
;| UTIL_Div_EHL_D			- 24/8 Divide EHL by D returning EHL and remainder in A			|
;| UTIL_Div_AHL_DE			- 24/16 Divide AHL by DE returning CDE and remainder in HL		|
;| UTIL_Div_AHL_CDE			- 24/24Divide AHL by CDE returning CDE and remainder in AHL		|
;\------------------------------------------------------------------------------------------/

;--------------------------------------------------------------------------------------------
; 16bit * 16 bit = 32bit Multiply: Multiply DEHL = HL * BC
;--------------------------------------------------------------------------------------------
; INPUT:
;	HL = Value 1
;	BC = Value 2
; OUTPUT:
;	DE:HL = Answer of HL * BC
;--------------------------------------------------------------------------------------------
UTIL_Mult_HL_BC:
							; First free up HL, so really its DE * BC
							ex		de, hl
							ld		hl, 0

							; First loop can be optimised
							sla		e
							rl		d
							jr		nc, @UMHB_Loop

							; Yes we need to start with 
							ld		h, b
							ld		l, c
@UMHB_Loop:
							add		hl, hl
							rl		e
							rl		d
							jr		nc, @UMHB_NextLoop

							; Add on the value
							add		hl, bc

							; No carry
							jr		nc, @UMHB_NextLoop
							inc		de
@UMHB_NextLoop:
							dec		a
							jr		nz, @UMHB_Loop

							ret

;--------------------------------------------------------------------------------------------
; 8bit * 8 bit = 16bit Multiply: Multiply HL = H * E
;--------------------------------------------------------------------------------------------
; INPUT:
;	H = Value 1
;	E = Value 2
; OUTPUT:
;	HL = Answer of H * E
;--------------------------------------------------------------------------------------------
UTIL_Mult_H_E:
							; Optimse the first loop
							ld		d, 0

							; Get the combination of the top bits in l
							sla		h
							sbc		a, a
							and		e
							ld		l, a

							; Loop through teh rest of the bits
							ld		b, 7
@UMHE_Loop:
							add		hl, hl
							jr		nc, @UMHE_NoCarry
							add		hl, de
@UMHE_NoCarry:
							djnz	@UMHE_Loop
							ret

;--------------------------------------------------------------------------------------------
; 24bit / 8bit = 24bit : 8bit : Divide EHL = EHL / D - Remainder : A
;--------------------------------------------------------------------------------------------
; INPUT:
;	EHL = Dividend
;	D = Divisor
; OUTPUT:
;	E:HL = Quotiant
;	A = Remainder
;--------------------------------------------------------------------------------------------
UTIL_Div_EHL_D:
							; Loop through the divide
							xor		a
							ld		b, 24
@UDEHLD_Loop:
							add		hl, hl
							rl		e
							rla
							jr		c, @UDEHLD_Carry
							cp		d
							jr		c, @UDEHLD_NoOverflow
@UDEHLD_Carry:
							sub		d
							inc		l
@UDEHLD_NoOverflow:							
							djnz	@UDEHLD_Loop
							ret


;--------------------------------------------------------------------------------------------
; 24bit / 16bit = 24bit : 16bit : Divide CDE = AHL / HL - Remainder : HL
;--------------------------------------------------------------------------------------------
; INPUT:
;	A:HL = Dividend
;	DE = Divisor
; OUTPUT:
;	A:HL = Quotiant
;	DE = Remainder
;--------------------------------------------------------------------------------------------
UTIL_Div_AHL_DE:
							; Get HL into IX
							push	hl
							pop		ix
							ld		hl, 0
							ld		b, 24
@UDAHLDE_Loop:
							; Shift off top bit
							add		ix, ix
							rla

							; Handle remainder
							adc		hl, hl
							jr		c, @UDAHLDE_Overflow
							sbc		hl, de
							jr		nc, @UDAHLDE_SetBit
							add		hl, de
@UDAHLDE_EndLoop:							
							djnz	@UDAHLDE_Loop
							ld		c, a
							push	ix
							pop		de
							ret
@UDAHLDE_Overflow:
							or		a
							sbc		hl, de
@UDAHLDE_SetBit:
							inc		ix
							jr		@UDAHLDE_EndLoop

;--------------------------------------------------------------------------------------------
; 24bit / 24bit = 24bit : 24bit : Divide CDE = AHL / CDE - Remainder : AHL
;--------------------------------------------------------------------------------------------
; INPUT:
;	A:HL = Dividend
;	C:DE = Divisor
; OUTPUT:
;	C:DE = Quotiant
;	A:HL = Remainder
;--------------------------------------------------------------------------------------------
UTIL_Div_AHL_CDE:
							; Move AHL into alternate pair CHL
							push	hl
							ld		hl, 0
							exx
							pop		hl
							ld		c,a
							xor		a

							; Run through all the bits
							ld		b, 24
@UD_Loop:
							adc		hl, hl
							rl		c
							exx
							adc		hl, hl							
							adc		a
							sbc		hl, de
							sbc		c
							jr		nc, @UD_NoCarry
							add		hl, de
							adc		c
@UD_NoCarry:
							ccf
							exx
							djnz	@UD_Loop

							; Sort the results CDE
							adc		hl, hl
							rl		c
							ex		de, hl

							; And AHL as the mod
							exx
							push	hl
							exx
							pop		hl
							ret

;--------------------------------------------------------------------------------------------
