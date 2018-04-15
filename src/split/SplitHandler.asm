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
	handlerPointer: equ $ - 2
		ret
	pending:
		db 0
	; c = VDP port 1
	; Modifies: af, bc
	Return:
		xor a
		ld (pending),a
		call ?next
		pop hl
		IF DEBUG
		PROFILE_END 10
		ENDIF
		jp Interrupt_Return
	; c = VDP port 1
	; Modifies: af, bc
	Entry:
		IF DEBUG
		PROFILE_BEGIN 10
		ENDIF
		push hl
		ld hl,?settings
	settings: equ $ - 2
	ENDM

; ix = this
; iy = interrupt
SplitHandler_Construct:
	call Interrupt_GetLineInterruptHandlerPointerIY
	ld (ix + SplitHandler.handlerPointer),l
	ld (ix + SplitHandler.handlerPointer + 1),h
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
SplitHandler_WaitIY:
	bit 0,(iy + SplitHandler.pending)
	ret z
	IF DEBUG
	PROFILE_BEGIN 29
	ENDIF
	halt
	IF DEBUG
	PROFILE_END 29
	ENDIF
	jr SplitHandler_WaitIY
