;
; Interrupt handler to display a frame.
; Or, the framing of the display.
;
FrameHandler: MACRO ?line, ?settings, ?next
	this:
	; Modifies: af, bc, hl
	Activate:
		ld c,VDP_PORT_1
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
	; Modifies: af, bc, hl
	Return:
		xor a
		ld (pending),a
		IF DEBUG
		PROFILE_END 10
		ENDIF
		call ?next
		jp Interrupt_Return
	; c = VDP port 1
	; Modifies: af, bc, hl
	Entry:
		IF DEBUG
		PROFILE_BEGIN 10
		ENDIF
		ld hl,?settings
	settings: equ $ - 2
	ENDM

; ix = this
; iy = interrupt
FrameHandler_Construct:
	call Interrupt_GetLineInterruptHandlerPointerIY
	ld (ix + FrameHandler.handlerPointer),l
	ld (ix + FrameHandler.handlerPointer + 1),h
	ret

; iy = this
; Modifies: hl
FrameHandler_ActivateIY:
	di
	call System_JumpIY
	ld a,(VDP_MIRROR_8 + 15)
	out (c),a
	ld a,15 | VDP_REGISTER
	out (c),a
	ei
	ret

; de = frame
; iy = this
FrameHandler_SubmitIY:
	di
	ld (iy + FrameHandler.settings),e
	ei
	ld (iy + FrameHandler.settings + 1),d
	ld (iy + FrameHandler.pending),1
	ret

; iy = this
FrameHandler_SubmitSameFrameIY:
	ld (iy + FrameHandler.pending),1
	ret

; iy = this
FrameHandler_WaitIY:
	bit 0,(iy + FrameHandler.pending)
	ret z
	IF DEBUG
	PROFILE_BEGIN 29
	ENDIF
	halt
	IF DEBUG
	PROFILE_END 29
	ENDIF
	jr FrameHandler_WaitIY
