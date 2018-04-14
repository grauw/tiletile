;
; Interrupt handler to display a frame.
; Or, the framing of the display.
;
DisplayFrameHandler_FRAME_LINE: equ 228

DisplayFrameHandler: MACRO ?entry
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
DisplayFrameHandler_Construct:
	call Interrupt_GetLineInterruptHandlerPointerIY
	ld (ix + DisplayFrameHandler.handlerPointer),l
	ld (ix + DisplayFrameHandler.handlerPointer + 1),h
	ret

; Waits until previous frame is displayed
; de = display frame
; iy = this
DisplayFrameHandler_SubmitIY:
	call DisplayFrameHandler_WaitIY
	di
	ld (iy + DisplayFrameHandler.settings),e
	ei
	ld (iy + DisplayFrameHandler.settings + 1),d
	ld (iy + DisplayFrameHandler.pending),1
	push iy
	pop de
	ld l,(iy + DisplayFrameHandler.handlerPointer)
	ld h,(iy + DisplayFrameHandler.handlerPointer + 1)
	di
	ld (hl),e
	inc hl
	ei
	ld (hl),d
	ret

; iy = this
DisplayFrameHandler_WaitIY:
	bit 0,(iy + DisplayFrameHandler.pending)
	ret z
	IF DEBUG
	PROFILE_BEGIN 29
	ENDIF
	halt
	IF DEBUG
	PROFILE_END 29
	ENDIF
	jr DisplayFrameHandler_WaitIY
