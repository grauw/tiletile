;
; Interrupt handler to display a frame.
; Or, the framing of the display.
;
FrameHandler_FRAME_LINE: equ 228

FrameHandler: MACRO ?entry
	Entry:
		IF DEBUG
		PROFILE_BEGIN 10
		ENDIF
		ld hl,0
	settings: equ $ - 2
		jp ?entry
	Return:
		xor a
		ld (pending),a
		IF DEBUG
		PROFILE_END 10
		ENDIF
		jp Interrupt_Return
	pending:
		db 0
	handlerPointer:
		dw 0
	ENDM

; ix = this
; iy = interrupt
FrameHandler_Construct:
	call Interrupt_GetLineInterruptHandlerPointerIY
	ld (ix + FrameHandler.handlerPointer),l
	ld (ix + FrameHandler.handlerPointer + 1),h
	ret

; Waits until previous frame is displayed
; de = frame
; iy = this
FrameHandler_SubmitIY:
	call FrameHandler_WaitIY
	di
	ld (iy + FrameHandler.settings),e
	ei
	ld (iy + FrameHandler.settings + 1),d
	ld (iy + FrameHandler.pending),1
	push iy
	pop de
	ld l,(iy + FrameHandler.handlerPointer)
	ld h,(iy + FrameHandler.handlerPointer + 1)
	di
	ld (hl),e
	inc hl
	ei
	ld (hl),d
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
