;
; Interrupt handler to display a frame.
; Or, the framing of the display.
;
FrameHandler: MACRO ?entry, ?settings, ?next
	this:
	; Modifies: hl
	Set:
		ld hl,Entry
		ld (0),hl
	handlerPointer: equ $ - 2
		ret
	; c = VDP port 1
	; Modifies: af, bc, hl
	Entry:
		IF DEBUG
		PROFILE_BEGIN 10
		ENDIF
		ld hl,?settings
	settings: equ $ - 2
		jp ?entry
	Return:
		xor a
		ld (pending),a
		IF DEBUG
		PROFILE_END 10
		ENDIF
		call ?next
		jp Interrupt_Return
	pending:
		db 0
	ENDM

; ix = this
; iy = interrupt
FrameHandler_Construct:
	call Interrupt_GetLineInterruptHandlerPointerIY
	ld (ix + FrameHandler.handlerPointer),l
	ld (ix + FrameHandler.handlerPointer + 1),h
	ret

; de = frame
; iy = this
; Modifies: hl
FrameHandler_SubmitIY:
	di
	ld (iy + FrameHandler.settings),e
	ei
	ld (iy + FrameHandler.settings + 1),d
	ld (iy + FrameHandler.pending),1
	jp iy

; iy = this
; Modifies: hl
FrameHandler_SubmitSameFrameIY:
	ld (iy + FrameHandler.pending),1
	jp iy

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
