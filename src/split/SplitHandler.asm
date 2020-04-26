;
; Line interrupt handler for a split.
;
SplitHandler: MACRO ?line, ?settings, ?next
	this:
	; c = VDP port 1
	; Modifies: af, bc, hl
	Activate:
		ld a,(VDP_MIRROR_8 + 23)
		add a,?line
	line: equ $ - 1
		ld (VDP_MIRROR_8 + 19),a
		out (c),a
		ld a,19 | VDP_REGISTER
		out (c),a  ; interrupt line
		ld hl,(15 | VDP_REGISTER) << 8 | 1
		out (c),l
		out (c),h  ; status register 1
		in a,(c)   ; clear FH
		ld hl,Entry
		ld (0),hl
	lineHandlerPointer: equ $ - 2
		ret
	pending:
		db 0
	; c = VDP port 1
	Return:
		xor a
		ld (pending),a
		call ?next
	next: equ $ - 2
		jp 0
	return: equ $ - 2
	; c = VDP port 1
	; Modifies: af, bc, de, hl
	Entry:
		ld hl,?settings
	settings: equ $ - 2
	ENDM

; ix = this
; iy = interrupt
SplitHandler_Construct:
	call Interrupt_GetAddressesIY
	ld (ix + SplitHandler.lineHandlerPointer),l
	ld (ix + SplitHandler.lineHandlerPointer + 1),h
	ld (ix + SplitHandler.return),e
	ld (ix + SplitHandler.return + 1),d
	ret

; ix = this
; iy = interrupt
SplitHandler_SetAsFrameReturn:
	call Interrupt_GetAddressesIY
	ld (ix + SplitHandler.return),c
	ld (ix + SplitHandler.return + 1),b
	ret

; iy = this
; Modifies: hl
SplitHandler_ActivateIY:
	ld c,VDP_PORT_1
	di
	call System_JumpIY
	ld a,(VDP_MIRROR_8 + 15)
	ld b,15
	call VDP_SetRegister
	ei
	ret

; de = split
; iy = this
SplitHandler_SubmitIY:
	di
	ld (iy + SplitHandler.settings),e
	ei
	ld (iy + SplitHandler.settings + 1),d
	ld (iy + SplitHandler.pending),1
	ret

; iy = this
SplitHandler_SubmitSameSplitIY:
	ld (iy + SplitHandler.pending),1
	ret

; iy = this
SplitHandler_WaitIY: PROC
	bit 0,(iy + SplitHandler.pending)
	ret z
	halt
Loop:
	bit 0,(iy + SplitHandler.pending)
	ret z
	halt
	jr Loop
	ENDP
