;/------------------------------------------------------------------------------------------\
;|									SAM Coupe Header 										|
;|------------------------------------------------------------------------------------------|
;| Defines various values for use in writing SAM Coupe software								|
;\------------------------------------------------------------------------------------------/

;--------------------------------------------------------------------------------------------
; INPUT/OUTPUT PORTS

I_D1_S1_STATUS:				EQU		224
I_D1_S1_TRACK:				EQU		225
I_D1_S1_SECTOR:				EQU		226
I_D1_S1_DATA:				EQU		227
I_D1_S2_STATUS:				EQU		228
I_D1_S2_TRACK:				EQU		229
I_D1_S2_SECTOR:				EQU		230
I_D1_S2_DATA:				EQU		231

O_D1_S1_COMMAND:			EQU		224
O_D1_S1_TRACK:				EQU		225
O_D1_S1_SECTOR:				EQU		226
O_D1_S1_DATA:				EQU		227
O_D1_S2_COMMAND:			EQU		228
O_D1_S2_TRACK:				EQU		229
O_D1_S2_SECTOR:				EQU		230
O_D1_S2_DATA:				EQU		231

I_D2_S1_STATUS:				EQU		240
I_D2_S1_TRACK:				EQU		241
I_D2_S1_SECTOR:				EQU		242
I_D2_S1_DATA:				EQU		243
I_D2_S2_STATUS:				EQU		244
I_D2_S2_TRACK:				EQU		245
I_D2_S2_SECTOR:				EQU		246
I_D2_S2_DATA:				EQU		247

O_D2_S1_COMMAND:			EQU		240
O_D2_S1_TRACK:				EQU		241
O_D2_S1_SECTOR:				EQU		242
O_D2_S1_DATA:				EQU		243
O_D2_S2_COMMAND:			EQU		244
O_D2_S2_TRACK:				EQU		245
O_D2_S2_SECTOR:				EQU		246
O_D2_S2_DATA:				EQU		247

IO_LMPR:					EQU		250
IO_HMPR:					EQU		251
IO_VMPR:					EQU		252

I_PEN:						EQU		248
I_STATUS:					EQU		249
I_MIDI_IN:					EQU		253
I_KEYBOARD:					EQU		254
I_ATTRIBUTES:				EQU		255

O_EXRAM_SECTION_C:			EQU		128
O_EXRAM_SECTION_D:			EQU		129
O_CLUT:						EQU		248
O_LINEINT:					EQU		249
O_MIDI_OUT:					EQU		253
O_BORDER:					EQU		254
O_SOUND:					EQU		255

I_SMB_CLK_1SEC:				EQU		&00ef
I_SMB_CLK_10SEC:			EQU		&10ef
I_SMB_CLK_1MIN:				EQU		&20ef
I_SMB_CLK_10MIN:			EQU		&30ef
I_SMB_CLK_1HOUR:			EQU		&40ef
I_SMB_CLK_10HOUR:			EQU		&50ef
I_SMB_CLK_1DAY:				EQU		&60ef
I_SMB_CLK_10DAY:			EQU		&70ef
I_SMB_CLK_1MONTH:			EQU		&80ef
I_SMB_CLK_10MONTH:			EQU		&90ef
I_SMB_CLK_1YEAR:			EQU		&a0ef
I_SMB_CLK_10YEAR:			EQU		&b0ef
I_SMB_CLK_WEEKDAY:			EQU		&c0ef

IO_DALLAS_CLK_CONTROL:		equ		&feef
IO_DALLAS_CLK_DATA:			equ		&ffef

IO_AL_CLK_CONTROL:			equ		&fdf5
IO_AL_CLK_CONTROL2:			equ		&fff5

O_ATOM_REGISTER_SELECT:		equ		245
IO_ATOM_DATA:				equ		247
I_ATOM_STROBE:				equ		246

;--------------------------------------------------------------------------------------------
; DISK BIT ALLOCATIONS
DISKCMD_Restore:			EQU		%00000000			; FLAGS: DisableSpinUp, Verify, StepRate
DISKCMD_Seek:				EQU		%00010000			; FLAGS: DisableSpinUp, Verify, StepRate
DISKCMD_Step:				EQU		%00100000			; FLAGS: UpdateTrack, DisableSpinUp, Verify, StepRate
DISKCMD_Step_In:			EQU		%01000000			; FLAGS: UpdateTrack, DisableSpinUp, Verify, StepRate
DISKCMD_Step_Out:			EQU		%01100000			; FLAGS: UpdateTrack, DisableSpinUp, Verify, StepRate
DISKCMD_ReadSector:			EQU		%10000000			; FLAGS: MultipleSector, DisableSpinUp, Delay
DISKCMD_WriteSector:		EQU		%10100000			; FLAGS: MultipleSector, DisableSpinUp, Delay, WritePreComp, DeletedDataMark
DISKCMD_ReadAddress:		EQU		%11000000			; FLAGS: DisableSpinUp, Delay
DISKCMD_ReadTrack:			EQU		%11010000			; FLAGS: DisableSpinUp, Delay
DISKCMD_WriteTrack:			EQU		%11110000			; FLAGS: DisableSpinUp, Delay, WritePreComp
DISKCMD_ForceInterrupt:		EQU		%11010000			; FLAGS: Immediate, IndexPulse, Terminate

DISKFLAG_UpdateTrack:		EQU		%00010000
DISKFLAG_MultipleSector:	EQU		%00010000
DISKFLAG_DisableSpinUp:		EQU		%00001000
DISKFLAG_Verify:			EQU		%00000100
DISKFLAG_Delay:				EQU		%00000100
DISKFLAG_StepRate2:			EQU		%00000010
DISKFLAG_StepRate3:			EQU		%00000011
DISKFLAG_StepRate6:			EQU		%00000000
DISKFLAG_StepRate12:		EQU		%00000001
DISKFLAG_WritePreComp:		EQU		%00000010
DISKFLAG_DeletedDataMark:	EQU		%00000001
DISKFLAG_Immediate:			EQU		%00001000
DISKFLAG_IndexPulse:		EQU		%00000100
DISKFLAG_Terminate:			EQU		%00000000

DISKSTATUS_MotorOn_Bit:		EQU		7
DISKSTATUS_WriteProtect_Bit:	EQU		6
DISKSTATUS_SpinUp_Bit:		EQU		5
DISKSTATUS_Record_Bit:		EQU		5
DISKSTATUS_RNF_Bit:			EQU		4
DISKSTATUS_SeekError_Bit:	EQU		4
DISKSTATUS_CRCError_Bit:	EQU		3
DISKSTATUS_LostData_Bit:	EQU		2
DISKSTATUS_Track00_Bit:		EQU		2
DISKSTATUS_DataRequest_Bit:	EQU		1
DISKSTATUS_IndexPulse_Bit:	EQU		1
DISKSTATUS_Busy_Bit:		EQU		0

DISKSTATUS_MotorOn:			EQU		%10000000
DISKSTATUS_WriteProtect:	EQU		%01000000
DISKSTATUS_SpinUP:			EQU		%00100000
DISKSTATUS_Record:			EQU		%00100000
DISKSTATUS_RNF:				EQU		%00010000
DISKSTATUS_SeekError:		EQU		%00010000
DISKSTATUS_CRCError:		EQU		%00001000
DISKSTATUS_LostData:		EQU		%00000100
DISKSTATUS_Track00:			EQU		%00000100
DISKSTATUS_DataRequest:		EQU		%00000010
DISKSTATUS_IndexPulse:		EQU		%00000010
DISKSTATUS_Busy:			EQU		%00000001

;--------------------------------------------------------------------------------------------
; SYSTEM CALLS
SYSCALL_JSCRN:				EQU		&0100
SYSCALL_JSVIN:				EQU		&0103
SYSCALL_JHEAPROOM:			EQU		&0106
SYSCALL_JWKROOM:			EQU		&0109
SYSCALL_JMKRBIG:			EQU		&010c
SYSCALL_JCALLBAS:			EQU		&010f
SYSCALL_JSETSTRM:			EQU		&0112
SYSCALL_JPOMSG:				EQU		&0115
SYSCALL_JEXPT1NUM:			EQU		&0118
SYSCALL_JEXPTSTR:			EQU		&011b
SYSCALL_JEXPTEXPR:			EQU		&011e
SYSCALL_JGETINT:			EQU		&0121
SYSCALL_JSTKFETCH:			EQU		&0124
SYSCALL_JSTKSTORE:			EQU		&0127
SYSCALL_JSBUFFET:			EQU		&012a
SYSCALL_JFARLDIR:			EQU		&012d
SYSCALL_JFARLDDR:			EQU		&0130
SYSCALL_JPUT:				EQU		&0133
SYSCALL_JGRAB:				EQU		&0136
SYSCALL_JPLOT:				EQU		&0139
SYSCALL_JDRAW:				EQU		&013c
SYSCALL_JDRAWTO:			EQU		&013f
SYSCALL_JCIRCLE:			EQU		&0142
SYSCALL_JFILL:				EQU		&0145
SYSCALL_JBLITZ:				EQU		&0148
SYSCALL_JROLL:				EQU		&014b
SYSCALL_JCLSBL:				EQU		&014e
SYSCALL_JCLSLOWER:			EQU		&0151
SYSCALL_JPALET:				EQU		&0154
SYSCALL_JOPSCR:				EQU		&0157
SYSCALL_JMODE:				EQU		&015a
SYSCALL_JTDUMP:				EQU		&015d
SYSCALL_JGDUMP:				EQU		&0160
SYSCALL_JRECLAIM:			EQU		&0163	
SYSCALL_JKBFLUSH:			EQU		&0166
SYSCALL_JWAITKEY:			EQU		&016c
SYSCALL_JBEEP:				EQU		&016f
SYSCALL_JSAVE:				EQU		&0172
SYSCALL_JLOAD:				EQU		&0175
SYSCALL_JLDVD:				EQU		&0178
SYSCALL_JEDGE2:				EQU		&017b
SYSCALL_JSTRS:				EQU		&017e
SYSCALL_JSENDA:				EQU		&0181
SYSCALL_JNCHAR:				EQU		&0184
SYSCALL_JGRCOMP:			EQU		&0187
SYSCALL_JGTTOK:				EQU		&018a
SYSCALL_JCLSCR:				EQU		&018d

;--------------------------------------------------------------------------------------------
; Vectors
VEC_DMPV:					EQU		&5ada
VEC_SETIYV:					EQU		&5adc
VEC_PRTOKV:					EQU		&5ade
VEC_MNIV:					EQU		&5ae0
VEC_FRAMIV:					EQU		&5ae2
VEC_LINIV:					EQU		&5ae4
VEC_COMSV:					EQU		&5ae6
VEC_MIPV:					EQU		&5ae8
VEC_MOPV:					EQU		&5aea
VEC_EDITV:					EQU		&5aec
VEC_RSTOBV:					EQU		&5aee
VEC_RST28V:					EQU		&5af0
VEC_RST30V:					EQU		&5af2
VEC_CMDV:					EQU		&5af4
VEC_EVALUW:					EQU		&5af6
VEC_LPRTV:					EQU		&5af8
VEC_MTOKV:					EQU		&5afa
VEC_MOUSV:					EQU		&5afc
VEC_KURV:					EQU		&5afe

;--------------------------------------------------------------------------------------------
; System variables
SVAR_SLDEV:					EQU		&5a06
SVAR_SELNUM:				EQU		&5a07
SVAR_FL6OR8:				EQU		&5a35
SVAR_CSA:					EQU		&5a7b
SVAR_CHAD:					EQU		&5a97
SVAR_XPTR:					EQU		&5aa3
SVAR_SPROMPT:				EQU		&5abb
SVAR_PAGCOUNT:				EQU		&5b83
SVAR_MODCOUNT:				EQU		&5b84
SVAR_DOSFLG:				EQU		&5bc2
SVAR_DOSCNT:				EQU		&5bc3
SVAR_PRAMTP:				EQU		&5cb4

;--------------------------------------------------------------------------------------------
; System defines
SYS_ALLOCTABLE:				EQU		&5100

;--------------------------------------------------------------------------------------------
