;/------------------------------------------------------------------------------------------\
;| 									File Handling											|
;\------------------------------------------------------------------------------------------/

;--------------------------------------------------------------------------------------------
; Defines
DOS_INIT:					EQU		128
DOS_HGTHD:					EQU		129
DOS_HLOAD:					EQU		130
DOS_HVERY:					EQU		131
DOS_HSAVE:					EQU		132
DOS_HVAR:					EQU		139
DOS_HOFLE:					EQU		147
DOS_SBYT:					EQU		148
DOS_HWSAD:					EQU		149
DOS_HSVBK:					EQU		150
DOS_CFSM:					EQU		152
DOS_HGFLE:					EQU		158
DOS_LBYT:					EQU		159
DOS_HRSAD:					EQU		160
DOS_HLDBK:					EQU		161
DOS_REST:					EQU		164
DOS_PCAT:					EQU		165
DOS_HERAZ:					EQU		166

; Directory Track Offsets
DT_FileStatus:				EQU		0
DT_FileName:				EQU		1
DT_NumUsedSectorsH:			EQU		11
DT_NumUsedSectorsL:			EQU		12
DT_StartTrack:				EQU		13
DT_StartSector:				EQU		14
DT_SectorAddressMap:		EQU		15
DT_StartPageNumber:			EQU		236
DT_StartPageOffset:			EQU		237					; Remember this is &8000-&bfff
DT_NumLengthPages:			EQU		239
DT_NumLengthMod:			EQU		240

; Offsets for IX + 
FILEVars:					STRUCT
DirEntryIndex:				rs		1
CurrentTrack:				rs		1
CurrentSector:				rs		1
CurrentDrive:				rs		1
FileOffset:					rs		3
FileLength:					rs		3
BytesLeftOfSector:			rs		2
CurrentSectorPtr:			rs		2
							ENDS

;--------------------------------------------------------------------------------------------
; Initialise the resource system
FILE_Initialise:
							; Clear what sector we have cached
							ld		a, 255
							ld		(FILE_Variables + FILEVars.CurrentTrack), a
							ld		(FILE_Variables + FILEVars.CurrentSector), a
							
							ld		a, 1
							ld		(FILE_Variables + FILEVars.CurrentDrive), a

							; Probably should hook into the DOSER (5BC0H) handler
							ret


;--------------------------------------------------------------------------------------------
; Open a file (For now always in read mode)
; HL Points to the filename
FILE_OpenFile:
							; Get the variables
							ld		ix, FILE_Variables

							; First thing we need to do is find the disk header for this file
							call	_FILE_FindFile
							ret		nz

							; We now have the file, clear the offset into the file
							xor		a
							ld		(ix + FILEVars.FileOffset + 0), a
							ld		(ix + FILEVars.FileOffset + 1), a
							ld		(ix + FILEVars.FileOffset + 2), a

							ld		de, 510 - 9
							ld		(ix + FILEVars.BytesLeftOfSector + 0), e
							ld		(ix + FILEVars.BytesLeftOfSector + 1), d

							; Remember files have a 9 byte header so if we are at the start we are actually 9 bytes in
							ld		hl, FILE_Sector + 9
							ld		(ix + FILEVars.CurrentSectorPtr + 0), l
							ld		(ix + FILEVars.CurrentSectorPtr + 1), h

							; Now work out the actual length of the file
							ld		a, (FILE_Dir + DT_NumLengthPages)
							ld		hl, (FILE_Dir + DT_NumLengthMod)

							; Start by moving h 2 bits up
							rlc		h
							rlc		h

							; Now rotate back but bring in the 2 bits of page number
							srl		a
							rr		h
							srl		a
							rr		h

							; We now have the actual length
							ld		(ix + FILEVars.FileLength + 0), l
							ld		(ix + FILEVars.FileLength + 1), h
							ld		(ix + FILEVars.FileLength + 2), a

							; Load in the first sector
							ld		hl, (FILE_Dir + DT_StartTrack)
							ld		e, h
							ld		d, l
							call	FILE_ReadSector
							ret

;--------------------------------------------------------------------------------------------
; Closes a file, doesnt really do much but clears a few variables
FILE_CloseFile:							
							; Get the variables
							ld		ix, FILE_Variables

							; We now have the actual length
							xor		a
							ld		(ix + FILEVars.FileLength + 0), a
							ld		(ix + FILEVars.FileLength + 1), a
							ld		(ix + FILEVars.FileLength + 2), a
							jp		_FILE_RepositionFile

;--------------------------------------------------------------------------------------------
; Seeks the file pointer to the offset from the start of the file
; A:HL = The amount to seek
FILE_SeekSet:
							; Set the offset
							ld		ix, FILE_Variables
							ld		(ix + FILEVars.FileOffset + 0), l
							ld		(ix + FILEVars.FileOffset + 1), h
							ld		(ix + FILEVars.FileOffset + 2), a
							jp		_FILE_RepositionFile

;--------------------------------------------------------------------------------------------
; Seeks the file pointer to the offset by adding the amount to the current file position
; A:HL = The amount to seek
FILE_SeekCur:				
							; Add to the offset
							ld		ix, FILE_Variables
							ld		d, a
							ld		a, (ix + FILEVars.FileOffset + 0)
							add		l
							ld		(ix + FILEVars.FileOffset + 0), a
							ld		a, (ix + FILEVars.FileOffset + 1)

							; Reember to use carry
							adc		h
							ld		(ix + FILEVars.FileOffset + 1), a
							ld		a, (ix + FILEVars.FileOffset + 2)
							adc		d
							ld		(ix + FILEVars.FileOffset + 2), a
							jp		_FILE_RepositionFile

;--------------------------------------------------------------------------------------------
; Seeks the file pointer to the offset by subtracting the amount from the end of the file
; A:HL = The amount to seek
FILE_SeekEnd:
							; Get the length of the file
							ld		ix, FILE_Variables
							ld		d, a
							ld		a, (ix + FILEVars.FileLength + 0)
							sub		l
							ld		(ix + FILEVars.FileLength + 0), a
							ld		a, (ix + FILEVars.FileLength + 1)
							sbc		h
							ld		(ix + FILEVars.FileLength + 1), a
							ld		a, (ix + FILEVars.FileLength + 2)
							sbc		d
							ld		(ix + FILEVars.FileLength + 2), a
							jp		_FILE_RepositionFile

;--------------------------------------------------------------------------------------------
; Read a sector into the sector buffer, check if its the one we have already
; D = Track
; E = Sector
FILE_ReadSector:
							push	bc

							; Check if we have the right sector already
							ld		a, (ix + FILEVars.CurrentTrack)
							cp		d
							jr		nz, @FRS_Read

							; Check the sector
							ld		a, (ix + FILEVars.CurrentSector)
							cp		e
							jr		z, @FRS_Cached
@FRS_Read:
							; Update the cache
							ld		(ix + FILEVars.CurrentTrack), d
							ld		(ix + FILEVars.CurrentSector), e
							
							; Remember if the interrupts are disabled and get the page
							ld 		a, i
							in		a, (250)
							push	af

							; Page in the system vars
							ld		a, &1f
							out		(250), a
							
							; Read the sector
							ld		a, (ix + FILEVars.CurrentDrive)
							ld		hl, FILE_Sector
							push	ix
							rst		&08
							db		DOS_HRSAD
							pop		ix

							; Restore the interrupt status
							pop		af
							jp		pe, @FRS_IntRestored
							di
@FRS_IntRestored:
							out		(250), a							
@FRS_Cached:
							; restore
							pop		bc
							ret

;--------------------------------------------------------------------------------------------
; Are we at the end of the file
FILE_IsEOF:
							ld		ix, FILE_Variables

							; Is the last byte equal to the length
							ld		a, (ix + FILEVars.FileOffset + 2)
							cp		(ix + FILEVars.FileLength + 2)
							ret		nz

							ld		a, (ix + FILEVars.FileOffset + 1)
							cp		(ix + FILEVars.FileLength + 1)
							ret		nz

							ld		a, (ix + FILEVars.FileOffset + 0)
							cp		(ix + FILEVars.FileLength + 0)
							ret


;--------------------------------------------------------------------------------------------
; Reads a byte from the file, returns the byte in A
FILE_ReadByte:
							; Are we EOF
							call	FILE_IsEOF
							ret		z

							; Get the address to read from
							ld		hl, (FILE_Variables + FILEVars.CurrentSectorPtr)
							ld		de, (FILE_Variables + FILEVars.BytesLeftOfSector)
							ld		a, d
							or		e
							jp		nz, @FRB_StillGotData

							; The next two bytes are the track and sector to load
							ld		d, (hl)
							inc		hl
							ld		e, (hl)
							call	FILE_ReadSector

							; Reset the sector ptr and bytes remaining
							ld		hl, FILE_Sector
							ld		de, 510
@FRB_StillGotData:
							; Remember where we were up to
							ld		a, (hl)
							inc		hl
							ld		(FILE_Variables + FILEVars.CurrentSectorPtr), hl

							; Read a byte
							dec		de
							ld		(FILE_Variables + FILEVars.BytesLeftOfSector), de

							; Now move on the file offset
							ld		hl, FILE_Variables + FILEVars.FileOffset
							inc		(hl)
							ret		nz
							inc		hl
							inc		(hl)
							ret		nz
							inc		hl
							inc		(hl)
							ret

;--------------------------------------------------------------------------------------------
; Reads a word from the file, returns the byte in HL
FILE_ReadWord:
							; For now read both bytes individually - This needs to be reworked
							call	FILE_ReadByte
							ret		z
							ex		af, af'
							call	FILE_ReadByte
							ret		z
							ld		d, a
							ex		af, af'
							ld		e, a
							ret

;--------------------------------------------------------------------------------------------
; Reads a Dword from the file, returns the byte in DE:HL
FILE_ReadDWord:
							; Read 2 words
							call	FILE_ReadWord
							ret		z
							push	hl
							call	FILE_ReadWord
							ret		z
							pop		de
							ret

;--------------------------------------------------------------------------------------------
; Read Bytes from the file into Page A, Offset HL, Length is D:BC bytes
FILE_ReadBytes:
							; Use our internal stack
							ld		(@FRB_SPStore + 1), sp
							ld		sp, DOS_StackEnd

							; Remember the page we are on
							ex		af, af'
							in		a, (IO_LMPR)
							push	af
							ex		af, af'

							; Read into Section B
							set		6, h

							; Lets get the right page into LMPR
							dec		a
							out		(IO_LMPR), a

@FRB_Loop1:
							push	de
@FRB_Loop2:							
							push	bc

							; Read a byte
							push	hl
							call	FILE_ReadByte
							pop		hl
							jr		z, @FRB_EOF

							; Store the byte into HL
							ld		(hl), a
							inc		hl
							bit		7, h
							jr		z, @FRB_SamePage

							; Reset the offset
							res		7, h
							set		6, h

							; Next page
							in		a, (250)
							inc		a
							out		(250), a
@FRB_SamePage:
							; Loop
							pop		bc
							dec		bc
							ld		a, b
							or		c
							jr		nz, @FRB_Loop2

							; Do the outer loop
							pop		de
							dec		d
							jr		nz, @FRB_Loop1							
							jr		@FRB_Exit

@FRB_EOF:					; Return how many bytes were left
							pop		bc
							pop		de
@FRB_Exit:
							pop		af
							out		(IO_LMPR), a

							; Reset the normal stack
@FRB_SPStore:				ld		sp, 0
							ret


;--------------------------------------------------------------------------------------------
; Repositinon the various settings once the file offset has been amended
_FILE_RepositionFile:
							ld		l, (ix + FILEVars.FileOffset + 0)
							ld		h, (ix + FILEVars.FileOffset + 1)
							ld		a, (ix + FILEVars.FileOffset + 2)
							
							; We actually need to read 9 bytes further on to skip the header
							ld		de, 9
							add		hl, de
							adc		0
							ld		c, a

							; Divide this down to find the track and offset
							ld		de, 510
							call	_FILE_DivCHLByDE

							; IX is destroyed in the div
							ld		ix, FILE_Variables

							; We can ignore C as it would have to be 0 given the divide, HL is the number of tracks we need to find
							ld		b, h
							ld		c, l

							; Work out the number of bytes left in this sector
							ld		hl, 510
							or		a
							sbc		hl, de
							ld		(ix + FILEVARS.BytesLeftOfSector + 0), l
							ld		(ix + FILEVARS.BytesLeftOfSector + 1), h

							; Work out the pointer
							ld		hl, FILE_Sector
							add		hl, de
							ld		(ix + FILEVars.CurrentSectorPtr + 0), l
							ld		(ix + FILEVars.CurrentSectorPtr + 1), h

							; Now we need to use the SAM to work out the track / sector
							ld		hl, (FILE_Dir + DT_StartTrack)
							ld		e, h
							ld		d, l					

							; Are we wanting the first sector?
							ld		a, b
							or		c
							jr		z, @FRF_ReadSector

							; Get the starting sam details for the first track and sector
							push	bc
							call	_FILE_GetSAMOffset

							; Get the starting address we need
							ld		h, 0
							ld		de, FILE_Dir + DT_SectorAddressMap
							add		hl, de
							pop		bc
							
							; Move the mask into D
							ld		d, a

@FRF_Loop:
							; Move to the next sector
							rlc		d
							jr		nc, @FRF_NotNextByte

							inc		hl

@FRF_NotNextByte:							
							; We know the current bit will be set, so lets find the next
							ld		a, (hl)
							and		d
							jr		z, @FRF_Loop

							; Found another track and sector
							dec		bc
							ld		a, b
							or		c
							jr		nz, @FRF_Loop

							; Convert the detials into track and sector
							ld		a, d
							ld		de, FILE_Dir + DT_SectorAddressMap
							or		a
							sbc		hl, de

							; Multiply this by 8
							add		hl, hl
							add		hl, hl	
							add		hl, hl

							; tshi bit is wrong
							ld		e, a
							ld		d, 0
							add		hl, de

							; Divide it down
							ld		c, 10
							call	_FILE_DivHLByC
							ld		e, a
							ld		d, l
							ld		a, 79
							cp		d
							jr		nc, @FRF_ReadSector
							ld		a, 48
							add		d
							ld		d, a
@FRF_ReadSector:
							; We can now read this sector in
							call	FILE_ReadSector
							ret
							
;--------------------------------------------------------------------------------------------
; Runs through the directory tracks and finds the appropraite file header
; HL Points to the filename
_FILE_FindFile:
							; Start at the beginning
							xor		a
							ld		(ix + FILEVars.DirEntryIndex), a

							; Put filename into de
							ex		de, hl
@FFF_Loop:
							; Store the filename
							push	de
							
							; Convert the file index into Track / Sector
							ld		a, (ix + FILEVars.DirEntryIndex)
							ld		b, 0
							srl		a
							rl		b
							call	_FILE_DivABy10

							; Sectors go from 1 to 10
							inc		e

							; Now read the sector for D1
							call	FILE_ReadSector
							
							; Recall the filename we are looking for
							pop		de
@FFF_NextDirEntry:
							; Now see if the filename is correct
							ld		c, 0
							ld		hl, FILE_Sector
							add		hl, bc
							ld		a, (hl)
							and		a
							jr		z, @FFF_NoFile

							; Check the name
							call	_FILE_CheckName
							jr		z, @FFF_Found
@FFF_NoFile:
							; Move onto the next file
							inc		(ix + FILEVars.DirEntryIndex)
							ld		a, 80
							cp		(ix + FILEVars.DirEntryIndex)
							jr		nz, @FFF_Loop

							; No file found - Clear Z
							inc		a
							ret
@FFF_Found:
							; Copy the entry
							ld		de, FILE_Dir
							ld		bc,	256
							ldir
							ret

;--------------------------------------------------------------------------------------------
; Converts a track and sector into the offset into the sam
; Inputs:
; D = Track
; E = Sector
; Output:
; L = Offset into SAM
; A = Bit Mask
_FILE_GetSAMOffset:
							; Remember the sector
							ld		a, e

							; Get the offset
							ld		e, d
							ld		l, d
							ld		d, 0
							ld		h, 0

							; Multiply HL by 10
							add		hl, hl
							add		hl, hl
							add		hl, de
							add		hl, hl

							; So, if we are on side 2, we need to subtract 1280 to removethe top bit being set for side 2, 
							; but then we need to add 760 to get past the 76 tracks from side 1 (-1280 + 760 = -520)
							; If we are on side 1, we just need to subtract 40 to ignore the directory tracks

							; Was this side 2
							bit		7, e
							jr		z, @FGSO_Side1

							ld		de, -520
							add		hl, de
							jr		@FGSO_Side2Done
@FGSO_Side1:
							ld		de, -40
							add		hl, de
@FGSO_Side2Done:
							; Add the sector to it
							dec		a
							ld		e, a
							ld		d, 0
							add		hl, de

							; We now have hl as the bit number, so divide down to get the actual offset
							ld		a, l
							and		7
							ld		b, a

							; Divide it down
							srl		h
							rr		l
							srl		h
							rr		l
							srl		h
							rr		l

							; Now A is the bit number and L is the offset (h should be 0) - Convert A to bit mask
							and		a
							ld		a, 1
							ret		z

							; Bit offset wasnt zero so loop to set it
@FGSO_Loop:
							sla		a
							djnz	@FGSO_Loop
							
							ret

;--------------------------------------------------------------------------------------------
; Divide A by E
; A = Number to divide
; D = Result
; E = Remained
_FILE_DivABy10:				
							ld		e, 10
_FILE_DivAByE:
							push	af
							push	bc

							; Set up the registers
   							ld		d, a 
							xor		a
   							ld		b, 8
@FDB_Loop:
							sla		d
   							rla
   							cp		e
   							jr		c, @FDB_Skip
   							sub		e
   							inc		d
@FDB_Skip:   
   							djnz	@FDB_Loop
   
							ld		e, a

							pop		bc
							pop		af
   							ret

;--------------------------------------------------------------------------------------------
; 24bit divide CHL by DE answer in CHL, Remainder in DE
_FILE_DivCHLByDE:
							; For speed get HL into IX
							push	hl
							pop		ix
							
							; Setup the remainder
							ld		hl, 0

							; 24 bit loop
							ld		b, 24
@FDCHL_Loop:
							add		ix, ix
							rl		c
							adc		hl, hl
							jr		c, @FDCHL_Overflow
							sbc		hl, de
							jr		nc, @FDCHL_SetBit
							add		hl,de
							djnz	@FDCHL_Loop
							push	ix
							pop		de
							ex		de, hl
							ret
@FDCHL_Overflow:
							or		a
							sbc		hl,de
@FDCHL_SetBit:
							inc		ix
							djnz	@FDCHL_Loop

							; Get remainder back in de
							push	ix
							pop		de
							ex		de, hl
							ret

;--------------------------------------------------------------------------------------------
; Divide HL by C - Answer in HL,remainder in A
_FILE_DivHLByC:
   							xor		a
   							ld		b, 16

@FDHLC_Loop:
   							add		hl, hl
   							rla
   							jr		c, @FDHLC_Overflow
   							cp		c
   							jr		c, @FDHLC_Skip
@FDHLC_Overflow:
							sub	c
							inc	l
@FDHLC_Skip:							
							djnz	@FDHLC_Loop
							
							ret

;--------------------------------------------------------------------------------------------
_FILE_CheckName:
							push	de
							push	hl
							push	bc

							; Skip the file status
							inc		hl

							; Test 10 characters
							ld		b, 10
@FCN_Loop:
							; Get the current character 
							ld		a, (de)
							xor		(hl)
							and		&df
							jr		nz, @FCN_NotSame 

							inc		hl
							inc		de
							djnz	@FCN_Loop

							; This is the right one
							xor		a
@FCN_NotSame:				
							pop		bc
							pop		hl
							pop		de
							ret

;--------------------------------------------------------------------------------------------
FILE_Error:				
							ld		a, r
							and		7
							out		(254), a
							jr		FILE_Error

							; Make debugging easier
							ret


;--------------------------------------------------------------------------------------------
; Variables
FILE_Variables:				ds		FILEVars.SizeOf
FILE_Dir:					ds		256
FILE_Sector:				ds		512

DOS_Stack:					ds		32
DOS_StackEnd:

;--------------------------------------------------------------------------------------------
