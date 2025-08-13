;/------------------------------------------------------------------------------------------\
;|									SAM Coupe Header 										|
;|------------------------------------------------------------------------------------------|
;| Defines various values for use in writing SAM Coupe software								|
;\------------------------------------------------------------------------------------------/

;--------------------------------------------------------------------------------------------
; INPUT/OUTPUT PORTS
IO_LMPR:					EQU		250
IO_HMPR:					EQU		251
IO_VMPR:					EQU		252

I_PEN:						EQU		248
I_STATUS:					EQU		249
I_MIDI_IN:					EQU		253
I_KEYBOARD:					EQU		254
I_ATTRIBUTES:				EQU		255

O_CLUT:						EQU		248
O_LINEINT:					EQU		249
O_MIDI_OUT:					EQU		253
O_BORDER:					EQU		254
O_SOUND:					EQU		255

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
; System variables
SVAR_SPROMPT:				EQU		&5abb
SVAR_PAGCOUNT:				EQU		&5b83
SVAR_MODCOUNT:				EQU		&5b84
SVAR_DOSFLG:				EQU		&5bc2

;--------------------------------------------------------------------------------------------
; System defines
SYS_ALLOCTABLE:				EQU		&5100

;--------------------------------------------------------------------------------------------
