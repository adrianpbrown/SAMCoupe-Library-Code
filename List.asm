;/------------------------------------------------------------------------------------------\
;|										Link List System									|
;|------------------------------------------------------------------------------------------|
;| PUBLIC FUNCTIONS:																		|
;|	LIST_Init 			- Initialise the list header structure								|
;|	LIST_Add			- Add a node into the list											|
;|	LIST_AddHead		- Add a node at the head of the list								|
;|	LIST_AddTail		- Add a node at the tail of the list								|
;|	LIST_Remove			- Remove a node from the list it is in								|
;|	LIST_RemoveHead		- Remove the head of the list										|
;|	LIST_RemoveTail		- Remove the tail of the list										|
;|	LIST_GetHead		- Get the head node of a list										|
;|	LIST_GetTail		- Get the tail node of a list										|
;|	LIST_GetNext		- Get the next node of a node										|
;|	LIST_GetPrev		- Get the previous node of a node									|
;|																							|
;| PUBLIC MACROS:																			|
;|	MACRO_LISTHDR_GetHead	- Get the head node of a list									|
;|	MACRO_LISTHDR_GetTail	- Get the tail node of a list									|
;|	MACRO_LISTNODE_GetNext	- Get the next node of a node									|
;|	MACRO_LISTNODE_GetPrev	- Get the previous node of a node								|
;\------------------------------------------------------------------------------------------/

;--------------------------------------------------------------------------------------------
; Some configuration defines
LIST_DEBUG:					EQU		1		; Do some additional debug

;--------------------------------------------------------------------------------------------
; Defines for list header
LISTHDR:					STRUCT
Head:						rs		2
Tail:						rs		2
TailPred:					rs		2
							ENDS

; Details of a list node
LISTNODE:					STRUCT
Next:						rs		2
Prev:						rs		2
							ENDS

;--------------------------------------------------------------------------------------------
; MACRO : Get Head of list
;--------------------------------------------------------------------------------------------
; INPUT:
;	IX = List header
; OUTPUT:
;	HL = Head Node
;--------------------------------------------------------------------------------------------
MACRO_LISTHDR_GetHead:		MACRO
							ld		l, (ix + LISTHDR.Head + 0)
							ld		h, (ix + LISTHDR.Head + 1)
							ENDM

;--------------------------------------------------------------------------------------------
; MACRO : Get Tail of list
;--------------------------------------------------------------------------------------------
; INPUT:
;	IX = List header
; OUTPUT:
;	HL = Tail Node
;--------------------------------------------------------------------------------------------
MACRO_LISTHDR_GetTail:		MACRO
							ld		l, (ix + LISTHDR.TailPred + 0)
							ld		h, (ix + LISTHDR.TailPred + 1)
							ENDM

;--------------------------------------------------------------------------------------------
; MACRO : Get Next node of the node
;--------------------------------------------------------------------------------------------
; INPUT:
;	HL = A List node
; OUTPUT:
;	HL = Next Node
;--------------------------------------------------------------------------------------------
MACRO_LISTNODE_GetNext:		MACRO
							ld		a, (hl)
							inc		hl
							ld		l, (hl)
							ld		h, a
							ENDM

;--------------------------------------------------------------------------------------------
; MACRO : Get Previous node of the node
;--------------------------------------------------------------------------------------------
; INPUT:
;	HL = A List node
; OUTPUT:
;	HL = Prev Node
;--------------------------------------------------------------------------------------------
MACRO_LISTNODE_GetPrev:		MACRO
							inc		hl
							inc		hl
							ld		a, (hl)
							inc		hl
							ld		l, (hl)
							ld		h, a
							ENDM

;--------------------------------------------------------------------------------------------
; Initialise a list header
;--------------------------------------------------------------------------------------------
; INPUT:
;	IX = List header to initialise
; OUTPUT:
;	None
;--------------------------------------------------------------------------------------------
LIST_Init:
							; Get IX into HL
							push	ix
							pop		hl

							; This is the TailPred address
							ld		(ix + LISTHDR.TailPred + 0), l
							ld		(ix + LISTHDR.TailPred + 1), h

							; Move onto the tail address
							inc		hl
							inc		hl

							; Set our head pointer
							ld		(ix + LISTHDR.Head + 0), l
							ld		(ix + LISTHDR.Head + 1), h

							; Clear the tail pointer
							xor		a
							ld		(ix + LISTHDR.Tail + 0), a
							ld		(ix + LISTHDR.Tail + 1), a

							ret

;--------------------------------------------------------------------------------------------
; Add a node to the head of a list
;--------------------------------------------------------------------------------------------
; INPUT:
;	IX = List to add the node to
;	HL = Node to add
;	DE = Node to add after
; OUTPUT:
;	None
;--------------------------------------------------------------------------------------------
LIST_Add:
							; Remember our node
							push	hl

							; Get the next node of the node to add after and set the node to add to us
							ex		de, hl
							ld		c, (hl)
							ld		(hl), e
							inc		hl
							ld		b, (hl)
							ld		(hl), d
							dec		hl
							ex		de, hl

							; our nodes next is the previous next
							ld		(hl), c
							inc		hl
							ld		(hl), b
							inc		hl

							; Our previous is the previous
							ld		(hl), e
							inc		hl
							ld		(hl), d
							pop		hl

							; The previous->next previous is us
							inc		bc
							inc		bc
							ld		a, l
							ld		(bc), a
							inc		bc
							ld		a, h
							ld		(bc), a

							ret

;--------------------------------------------------------------------------------------------
; Add a node to the head of a list
;--------------------------------------------------------------------------------------------
; INPUT:
;	IX = List to add the node to the head of
;	HL = Node to add
; OUTPUT:
;	None
;--------------------------------------------------------------------------------------------
LIST_AddHead:				
							; Preserve the node
							push	hl

							; First get a copy ofthe node at the head of the list
							ld		e, (ix + LISTHDR.Head + 0)
							ld		d, (ix + LISTHDR.Head + 1)

							; Store the our node as the head
							ld		(ix + LISTHDR.Head + 0), l
							ld		(ix + LISTHDR.Head + 1), h

							; The item that was at the head is our next
							push	hl
							ld		(hl), e
							inc		hl
							ld		(hl), d
							inc		hl

							; Our previous item is the list itself
							ld		a, ixl
							ld		(hl), a
							inc		hl
							ld		a, ixh
							ld		(hl), a

							; Also whatever node was at the head - its previous points to us
							pop		hl
							ex		de, hl
							inc		hl
							inc		hl
							ld		(hl), e
							inc		hl
							ld		(hl), d

							; We have done
							pop		hl
							ret

;--------------------------------------------------------------------------------------------
; Add a node to the tail of a list
;--------------------------------------------------------------------------------------------
; INPUT:
;	IX = List to add the node to
;	HL = Node to add
; OUTPUT:
;	None
;--------------------------------------------------------------------------------------------
LIST_AddTail:	
							; Preserve the node address and list
							push	hl
							push	ix

							; First get a copy of whats a before the tail
							ld		e, (ix + LISTHDR.TailPred + 0)
							ld		d, (ix + LISTHDR.TailPred + 1)

							; Store the node to add as the tail pred
							ld		(ix + LISTHDR.TailPred + 0), l
							ld		(ix + LISTHDR.TailPred + 1), h

							; We need to put the tail as the next node
							inc		ix
							inc		ix

							; our next item is the tail
							push	hl
							ld		a, ixl
							ld		(hl), a
							inc		hl
							ld		a, ixh
							ld		(hl), a
							inc		hl

							; Our previous item is what was previous
							ld		(hl), e
							inc		hl
							ld		(hl), d

							; Also whatever node was at the tail - its next points to us
							pop		hl
							ex		de, hl
							ld		(hl), e
							inc		hl
							ld		(hl), d

							; We have done
							pop		ix
							pop		hl
							ret

;--------------------------------------------------------------------------------------------
; Remove an entry from the list
;--------------------------------------------------------------------------------------------
; INPUT:
;	HL = Node to remove
; OUTPUT:
;	None
;--------------------------------------------------------------------------------------------
LIST_Remove:
						push	hl
						
						; Get our next node (in DE) and prev node (in HL)
						ld		e, (hl)
						inc		hl
						ld		d, (hl)
						inc		hl
						ld		a, (hl)
						inc		hl
						ld		h, (hl)
						ld		l, a

						; Now set our previous node (HL) next to our next (DE)
						ld		(hl), e
						inc		hl
						ld		(hl), d
						dec		hl

						; And our next node prev (DE) to our previous (HL)
						ex		de, hl
						inc		hl
						inc		hl
						ld		(hl), e
						inc		hl
						ld		(hl), d

						pop	hl
						ret

;--------------------------------------------------------------------------------------------
; Remove an entry from the head of the list
;--------------------------------------------------------------------------------------------
; INPUT:
;	IX = List to remove the head of
; OUTPUT:
;	HL = Node removed (or Z Flag Set if empty)
;--------------------------------------------------------------------------------------------
LIST_RemoveHead:
						; First get a copy ofthe node at the head of the list
						ld		l, (ix + LISTHDR.Head + 0)
						ld		h, (ix + LISTHDR.Head + 1)

						; Get whats next
						ld		e, (hl)
						inc		hl
						ld		d, (hl)

						; Check its not null (i.e. empty list)
						ld		a, d
						or		e
						ret		z

						; This becomes the new list head
						ld		(ix + LISTHDR.Head + 0), e
						ld		(ix + LISTHDR.Head + 1), d

						; Now the list header becomes the next nodes previous 
						inc		de
						inc		de
						ld		a, ixl
						ld		(de), a
						inc		de
						ld		a, ixh
						ld		(de), a

						; Done - just sort the return
						dec		hl
						ret

;--------------------------------------------------------------------------------------------
; Remove an entry from the tail of the list
;--------------------------------------------------------------------------------------------
; INPUT:
;	IX = List to remove the tail of
; OUTPUT:
;	HL = Node removed (or Z Flag Set if empty)
;--------------------------------------------------------------------------------------------
LIST_RemoveTail:
						; First get a copy ofthe node before the tail
						ld		l, (ix + LISTHDR.TailPred + 0)
						ld		h, (ix + LISTHDR.TailPred + 1)

						; Get its previous
						inc		hl
						inc		hl
						ld		e, (hl)
						inc		hl
						ld		d, (hl)

						; Check its not null (i.e. empty list)
						ld		a, d
						or		e
						ret		z

						; Set our previous as the tailpred
						ld		(ix + LISTHDR.TailPred + 0), e
						ld		(ix + LISTHDR.TailPred + 1), d

						; Now the list header becomes the previous nodes next 
						ld		a, ixl
						ld		(de), a
						inc		de
						ld		a, ixh
						ld		(de), a

						; Done - just sort the return
						dec		hl
						dec		hl
						dec		hl
						ret

;--------------------------------------------------------------------------------------------
; Add the head of a list
;--------------------------------------------------------------------------------------------
; INPUT:
;	IX = List to add the node to
; OUTPUT:
;	HL = Head node
;--------------------------------------------------------------------------------------------
LIST_GetHead:
						; Get the head node
						ld		l, (ix + LISTHDR.Head + 0)
						ld		h, (ix + LISTHDR.Head + 1)

						ret

;--------------------------------------------------------------------------------------------
; Add the tail of a list
;--------------------------------------------------------------------------------------------
; INPUT:
;	IX = List to add the node to
; OUTPUT:
;	HL = Tail node
;--------------------------------------------------------------------------------------------
LIST_GetTail:
						; Get the tail node
						ld		l, (ix + LISTHDR.Tail + 0)
						ld		h, (ix + LISTHDR.Tail + 1)

						ret
							
;--------------------------------------------------------------------------------------------
; Add the next node of a node
;--------------------------------------------------------------------------------------------
; INPUT:
;	HL = The node to get the next node of
; OUTPUT:
;	HL = Next node
;--------------------------------------------------------------------------------------------
LIST_GetNext:
						; Get the next node
						ld		a, (hl)
						inc		hl
						ld		h, (hl)
						ld		l, a
						
						ret

;--------------------------------------------------------------------------------------------
; Add the previous node of a node
;--------------------------------------------------------------------------------------------
; INPUT:
;	HL = The node to get the previous node of
; OUTPUT:
;	HL = Previous node
;--------------------------------------------------------------------------------------------
LIST_GetPrev:
						; Get the previous node
						inc		hl
						inc		hl
						ld		a, (hl)
						inc		hl
						ld		h, (hl)
						ld		l, a
						
						ret

;--------------------------------------------------------------------------------------------
; INTERNAL: Called when there is an error
;--------------------------------------------------------------------------------------------
; INPUT:
;	None
; OUTPUT:
;	None
;--------------------------------------------------------------------------------------------
if LIST_DEBUG
_LIST_InternalError:
							ld		a, r
							and		7
							out		(254), a
							jr		_LIST_InternalError
							ret
endif

;--------------------------------------------------------------------------------------------
; Variables
;--------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------
